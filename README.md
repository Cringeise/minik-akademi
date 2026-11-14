# Minik Akademi v17

Pastel tasarımlı, telefon ve masaüstü uyumlu TYT fen öğrenme platformu. Ana uygulama tek bir `index.html` dosyasıyla çalışır; ek sunucu veya ücretli ön yüz servisi gerektirmez.

## Dersler

| Ders | Konu | Soru bankası | Yorum sorusu | Etkileşimli atölye |
|---|---:|---:|---:|---:|
| TYT Fizik | 11 | 440 | 44 | Fizik laboratuvarı |
| TYT Kimya | 7 | 280 | 28 | 4 dijital model |
| TYT Biyoloji | 8 | 320 | 32 | 6 dijital model |

Her konuda dört ayrı test ve toplam 40 soru bulunur. Fizik bankası v17'de baştan düzenlendi; 11 konuda 440 farklı soru kökü vardır. Testler açıklamalı geri bildirim, cevap kaydı ve konu tamamlama akışıyla çalışır.

## Ders Sayacı

- Yağmurlu Lo-Fi manzaralı, animasyonlu ayrı odak sayfası.
- Pomodoro çalışma ve mola döngüsü; dördüncü turun ardından uzun mola.
- Serbest kronometre, oturum kaydı, ders ve günlük hedef seçimi.
- Günlük toplam ve son yedi günün çalışma geçmişi.
- Kayıtlar cihazda saklanır; hesap senkronizasyonu etkinse mevcut Supabase hesap verisine de eklenir.

## Çıkmış Sorular ve MEB kaynakları

Ders kütüphanesindeki **Çıkmış Sorular & Kaynaklar** bölümünden OGM TYT 2018–2026 arşivi ile fizik, kimya ve biyoloji MEB kitaplarına erişilir. Resmî sınav soruları kendi yayımlandıkları kaynaklarda açılır; izin olmadan Minik Akademi içinde yeniden yayımlanmaz. Soru bankasındaki sorular özgündür ve ilgili konu becerilerini çalıştırmak üzere hazırlanmıştır.

## GitHub Pages ile yayınlama

1. Depo görünürlüğünü **Public** tut.
2. **Settings → Pages → Build and deployment → Source** bölümünde **GitHub Actions** seç.
3. **Actions** sekmesinde **Publish Minik Akademi** iş akışının tamamlanmasını kontrol et.
4. Site adresi: `https://cringeise.github.io/minik-akademi/`

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
- Ders sayacı oturumları yerel olarak saklanır ve hesap senkronizasyonuna eklenir.
- Siteye reklam veya analitik takip SDK'sı eklenmemiştir.
- Kimya ve biyoloji atölyeleri güvenli dijital eğitim modelleridir; gerçek kimyasal madde kullanma talimatı içermez.

## Proje dosyaları

- Ana uygulama: `index.html`
- Gizlilik notu: `gizlilik.html`
- Supabase tablo ve RLS kurulumu: `supabase/student_progress.sql`
- Otomatik GitHub Pages yayını: `.github/workflows/deploy.yml`
