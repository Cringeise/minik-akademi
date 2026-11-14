# Minik Akademi v15

Pastel tasarımlı, telefon ve masaüstü uyumlu TYT fen öğrenme platformu. Site tek bir `index.html` dosyasıyla çalışır; ek sunucu veya ücretli ön yüz servisi gerektirmez.

## Dersler

| Ders | Konu | Test sorusu | Yorum sorusu | Sanal atölye |
|---|---:|---:|---:|---:|
| TYT Fizik | 11 | 440 | 44 | Fizik laboratuvarı |
| TYT Kimya | 7 | 70 | 28 | 4 etkileşimli model |
| TYT Biyoloji | 8 | 80 | 32 | 6 etkileşimli model |

Kimya ve biyoloji konu anlatımları, açıklamalı testler, yorum soruları, hızlı tekrar kartları ve deney/simülasyon alanları içerir. Fizik tarafındaki önceki içerik korunmuştur. İlerleme, test cevapları ve yorum yanıtları yerel kayda ve hesap bağlantısı varsa Supabase eşitlemesine eklenir.

## GitHub Pages ile yayınlama

1. Depo görünürlüğünü **Public** tut.
2. **Settings → Pages → Build and deployment → Source** bölümünde **GitHub Actions** seç.
3. **Actions** sekmesinde **Publish Minik Akademi** iş akışının tamamlanmasını kontrol et.
4. Site adresi genellikle `https://cringeise.github.io/minik-akademi/` biçimindedir.

`.github/workflows/deploy.yml` dosyası `main` dalına her gönderimde siteyi yayımlamak üzere ayarlanmıştır.

## Supabase kurulumu

1. Supabase projesinde SQL Editor'ü aç.
2. `supabase/student_progress.sql` dosyasının içeriğini çalıştır.
3. Site kodunda yalnızca Supabase URL ve publishable/anon anahtarı bulunmalıdır. `service_role` veya secret key'i istemci koduna ekleme.
4. Canlı URL belli olduktan sonra Authentication → URL Configuration bölümündeki Site URL ve Redirect URLs alanlarını bu adresle eşleştir.

### E-posta doğrulaması ve ücretsiz kullanım

Supabase'in varsayılan e-posta servisi kısıtlıdır. Harici SMTP olmadan doğrulama veya parola yenileme e-postalarının her adrese ulaşacağı garanti değildir. Ücretli servis eklenmedi. E-posta doğrulamasını kapatmak güvenlik tercihini değiştirir; bunu yalnızca etkilerini bilerek Supabase panelinden yap.

## Gizlilik ve kayıtlar

- Parola Supabase Auth tarafından işlenir; uygulama parolayı yerel depolamada saklamaz.
- Hesaplı kullanımda ilerleme verileri kullanıcıya özel satırda tutulur; tablo RLS ile korunur.
- Hesapsız kullanımda kayıtlar kullanılan tarayıcının yerel depolamasında kalır.
- Siteye reklam veya analitik takip SDK'sı eklenmemiştir.
- Kimya ve biyoloji atölyeleri güvenli dijital eğitim modelleridir; gerçek kimyasal madde kullanma talimatı içermez.

## Proje notları

- Ana uygulama: `index.html`
- Gizlilik notu: `gizlilik.html`
- Supabase tablo ve RLS kurulumu: `supabase/student_progress.sql`
- Otomatik GitHub Pages yayını: `.github/workflows/deploy.yml`
