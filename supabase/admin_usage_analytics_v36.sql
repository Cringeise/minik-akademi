-- Minik Akademi v36: account-level usage, focus and learning analytics.
-- Safe to re-run. Student rows remain private; only the admin RPC aggregates them.
-- Authorization uses trusted auth.jwt()->'app_metadata'->>'role', never user_metadata.

CREATE OR REPLACE FUNCTION public.record_usage(p_session_id uuid, p_page text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'auth'
AS $function$
DECLARE
  v_user_id uuid := auth.uid();
  v_page text;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING errcode = '42501';
  END IF;
  IF p_session_id IS NULL THEN
    RAISE EXCEPTION 'Session id is required' USING errcode = '22023';
  END IF;

  v_page := CASE
    WHEN p_page IN (
      'home','courses','focus','lab','physics','chemistry','biology',
      'progress','reports','notebook','achievements','wrongbook',
      'formulas','map','sources','notes','other'
    ) THEN p_page
    ELSE 'other'
  END;

  INSERT INTO public.usage_sessions(
    user_id, session_id, started_at, last_seen_at, duration_seconds, page_counts
  )
  VALUES (v_user_id, p_session_id, now(), now(), 0, jsonb_build_object(v_page, 1))
  ON CONFLICT (user_id, session_id) DO UPDATE
  SET duration_seconds = public.usage_sessions.duration_seconds +
        GREATEST(
          0,
          LEAST(
            90,
            FLOOR(EXTRACT(EPOCH FROM (now() - public.usage_sessions.last_seen_at)))::bigint
          )
        ),
      last_seen_at = now(),
      page_counts = public.usage_sessions.page_counts ||
        jsonb_build_object(
          v_page,
          COALESCE((public.usage_sessions.page_counts->>v_page)::bigint, 0) + 1
        );
END;
$function$;

DROP FUNCTION IF EXISTS public.admin_get_user_usage();

CREATE FUNCTION public.admin_get_user_usage()
RETURNS TABLE(
  user_id uuid,
  email text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  total_seconds bigint,
  session_count bigint,
  last_active timestamptz,
  page_counts jsonb,
  focus_seconds bigint,
  focus_session_count bigint,
  focus_by_subject jsonb,
  focus_days bigint,
  question_attempts bigint,
  correct_questions bigint,
  wrong_questions bigint,
  completed_topics bigint,
  xp_points bigint,
  activity_days bigint,
  topic_performance jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'auth'
AS $function$
BEGIN
  IF COALESCE(auth.jwt()->'app_metadata'->>'role', '') <> 'admin' THEN
    RAISE EXCEPTION 'Admin access required' USING errcode = '42501';
  END IF;

  RETURN QUERY
  SELECT
    u.id,
    u.email::text,
    u.created_at,
    u.last_sign_in_at,
    COALESCE(site.total_seconds, 0)::bigint,
    COALESCE(site.session_count, 0)::bigint,
    site.last_active,
    COALESCE(site.page_counts, '{}'::jsonb),
    COALESCE(focus.focus_seconds, 0)::bigint,
    COALESCE(focus.focus_session_count, 0)::bigint,
    COALESCE(focus.focus_by_subject, '{}'::jsonb),
    COALESCE(focus.focus_days, 0)::bigint,
    CASE
      WHEN COALESCE(activity.question_attempts, 0) > 0 THEN activity.question_attempts
      WHEN COALESCE(p.data->>'solved', '') ~ '^[0-9]+$' THEN (p.data->>'solved')::bigint
      ELSE 0
    END::bigint,
    CASE WHEN COALESCE(activity.question_attempts, 0) > 0
      THEN activity.correct_questions ELSE NULL END::bigint,
    CASE WHEN COALESCE(activity.question_attempts, 0) > 0
      THEN GREATEST(activity.question_attempts - activity.correct_questions, 0)
      ELSE NULL END::bigint,
    CASE
      WHEN jsonb_typeof(p.data->'completed') = 'array'
      THEN jsonb_array_length(p.data->'completed')::bigint
      ELSE 0::bigint
    END,
    CASE
      WHEN COALESCE(p.data->>'points', '') ~ '^[0-9]+$'
      THEN (p.data->>'points')::bigint
      ELSE 0::bigint
    END,
    COALESCE(activity.activity_days, 0)::bigint,
    COALESCE(activity.topic_performance, '{}'::jsonb)
  FROM auth.users AS u
  LEFT JOIN public.student_progress AS p ON p.user_id = u.id
  LEFT JOIN LATERAL (
    SELECT
      COALESCE(SUM(us.duration_seconds), 0)::bigint AS total_seconds,
      COUNT(us.session_id)::bigint AS session_count,
      MAX(us.last_seen_at) AS last_active,
      COALESCE(
        (
          SELECT jsonb_object_agg(page_totals.page_name, page_totals.heartbeat_count)
          FROM (
            SELECT page_entry.key AS page_name,
                   SUM(page_entry.value::bigint)::bigint AS heartbeat_count
            FROM public.usage_sessions AS us2
            CROSS JOIN LATERAL jsonb_each_text(us2.page_counts) AS page_entry(key, value)
            WHERE us2.user_id = u.id
            GROUP BY page_entry.key
          ) AS page_totals
        ),
        '{}'::jsonb
      ) AS page_counts
    FROM public.usage_sessions AS us
    WHERE us.user_id = u.id
  ) AS site ON TRUE
  LEFT JOIN LATERAL (
    WITH focus_entries AS (
      SELECT
        CASE
          WHEN COALESCE(item.value->>'seconds', '') ~ '^[0-9]+$'
          THEN (item.value->>'seconds')::bigint
          ELSE 0::bigint
        END AS seconds,
        COALESCE(NULLIF(BTRIM(item.value->>'subject'), ''), 'Genel') AS subject,
        CASE
          WHEN COALESCE(item.value->>'date', '') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
          THEN item.value->>'date'
          ELSE NULL
        END AS focus_day
      FROM jsonb_array_elements(
        CASE
          WHEN jsonb_typeof(p.data->'focusSessions') = 'array'
          THEN p.data->'focusSessions'
          ELSE '[]'::jsonb
        END
      ) AS item(value)
    ),
    subject_totals AS (
      SELECT focus_entries.subject, SUM(focus_entries.seconds)::bigint AS seconds
      FROM focus_entries
      GROUP BY focus_entries.subject
    )
    SELECT
      COALESCE(SUM(focus_entries.seconds), 0)::bigint AS focus_seconds,
      COUNT(*)::bigint AS focus_session_count,
      COALESCE(
        (SELECT jsonb_object_agg(subject_totals.subject, subject_totals.seconds)
         FROM subject_totals),
        '{}'::jsonb
      ) AS focus_by_subject,
      COUNT(DISTINCT focus_entries.focus_day)
        FILTER (WHERE focus_entries.focus_day IS NOT NULL)::bigint AS focus_days
    FROM focus_entries
  ) AS focus ON TRUE
  LEFT JOIN LATERAL (
    WITH activity_entries AS (
      SELECT
        entry.key AS activity_day,
        entry.value AS activity_data,
        CASE
          WHEN COALESCE(entry.value->>'attempts', '') ~ '^[0-9]+$'
          THEN (entry.value->>'attempts')::bigint
          ELSE 0::bigint
        END AS attempts,
        CASE
          WHEN COALESCE(entry.value->>'correct', '') ~ '^[0-9]+$'
          THEN (entry.value->>'correct')::bigint
          ELSE 0::bigint
        END AS correct
      FROM jsonb_each(
        CASE
          WHEN jsonb_typeof(p.data->'activity') = 'object'
          THEN p.data->'activity'
          ELSE '{}'::jsonb
        END
      ) AS entry(key, value)
    ),
    topic_entries AS (
      SELECT
        topic.key AS topic_name,
        CASE
          WHEN COALESCE(topic.value->>'attempts', '') ~ '^[0-9]+$'
          THEN (topic.value->>'attempts')::bigint
          ELSE 0::bigint
        END AS attempts,
        CASE
          WHEN COALESCE(topic.value->>'correct', '') ~ '^[0-9]+$'
          THEN (topic.value->>'correct')::bigint
          ELSE 0::bigint
        END AS correct
      FROM activity_entries
      CROSS JOIN LATERAL jsonb_each(
        CASE
          WHEN jsonb_typeof(activity_entries.activity_data->'topicStats') = 'object'
          THEN activity_entries.activity_data->'topicStats'
          ELSE '{}'::jsonb
        END
      ) AS topic(key, value)
    ),
    topic_totals AS (
      SELECT
        topic_entries.topic_name,
        SUM(topic_entries.attempts)::bigint AS attempts,
        SUM(topic_entries.correct)::bigint AS correct
      FROM topic_entries
      GROUP BY topic_entries.topic_name
    )
    SELECT
      COALESCE(SUM(activity_entries.attempts), 0)::bigint AS question_attempts,
      COALESCE(SUM(activity_entries.correct), 0)::bigint AS correct_questions,
      COUNT(*) FILTER (WHERE activity_entries.attempts > 0)::bigint AS activity_days,
      COALESCE(
        (
          SELECT jsonb_object_agg(
            topic_totals.topic_name,
            jsonb_build_object(
              'attempts', topic_totals.attempts,
              'correct', topic_totals.correct,
              'wrong', GREATEST(topic_totals.attempts - topic_totals.correct, 0)
            )
          )
          FROM topic_totals
        ),
        '{}'::jsonb
      ) AS topic_performance
    FROM activity_entries
  ) AS activity ON TRUE
  ORDER BY COALESCE(site.total_seconds, 0) DESC, u.created_at DESC;
END;
$function$;

-- Keep raw session rows inaccessible through the public Data API.
ALTER TABLE public.usage_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.usage_sessions FROM anon, authenticated;

-- Explicit function grants. Both SECURITY DEFINER functions still enforce
-- auth.uid() or the trusted app_metadata admin role internally.
REVOKE ALL ON FUNCTION public.record_usage(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_usage(uuid, text) TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.admin_get_user_usage() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_get_user_usage() TO authenticated, service_role;
