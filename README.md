# Minik Akademi v21

Pastel tasarımlı, telefon ve masaüstü uyumlu TYT fen öğrenme platformu. Ana uygulama tek bir `index.html` dosyasıyla çalışır; ek sunucu veya ücretli ön yüz servisi gerektirmez.

## Dersler

| Ders | Konu | Soru bankası | Yorum sorusu | Etkileşimli atölye |
|---|---:|---:|---:|---:|
| TYT Fizik | 11 | 440 | 44 | Fizik laboratuvarı |
| TYT Kimya | 7 | 280 | 28 | 4 dijital model |
| TYT Biyoloji | 8 | 320 | 32 | 6 dijital model |

Fizik bankası 11 konuda 440 farklı soru kökü içerir. Her konuda dört ayrı test ve toplam 40 soru bulunur.

## Ders Sayacı ve Lo-Fi çalışma odası

- Fotoğraf gerçekçiliğinde yağmurlu gece çalışma odası.
- İsteğe bağlı yağmur ambiyansı; aç/kapat düğmesi ve ses seviyesi kontrolü. Ses tarayıcıda Web Audio ile üretilir; harici ses dosyası yüklenmez.
- Sol köşede mini espresso makinesi ve rafta şeffaf cam kupa. Kupayı makinenin tepsisine sürükleyince demleme animasyonu çalışır.
- Pomodoro veya serbest sayaç odak süresince ilerledikçe kupadaki kahve seviyesi azalır; sayaç durduğunda ve molada sabit kalır.
- Yerel saatle 19.00–07.00 arasında tüm sayfalarda otomatik koyu tema; gündüz sayaç çalışırken de odak koyu teması. Açık renkli kalan kart ve paneller ek taramayla koyulaştırılır.
- 25/5 dakika Pomodoro döngüsü; dördüncü turun ardından 15 dakikalık uzun mola. Serbest kronometre, oturum kaydı, ders ve günlük hedef seçimi.
- Günlük toplam ve son yedi günün çalışma geçmişi.

## Çıkmış Sorular ve MEB kaynakları

Ders kütüphanesindeki **Çıkmış Sorular & Kaynaklar** bölümünden OGM TYT 2018–2026 arşivi ile fizik, kimya ve biyoloji MEB kitaplarına erişilir. Resmî sınav soruları kendi yayımlandıkları kaynaklarda açılır; izin olmadan Minik Akademi içinde yeniden yayımlanmaz. Soru bankasındaki sorular özgündür ve ilgili konu becerilerini çalıştırmak üzere hazırlanmıştır.

## GitHub Pages ile yayınlama

1. Depo görünürlüğünü **Public** tut.
2. **Settings → Pages → Build and deployment → Source** bölümünde **GitHub Actions** seç.
3. **Actions** sekmesinde **Publish Minik Akademi** iş akışının tamamlanmasını kontrol et.
4. Site adresi: `https://cringeise.github.io/minik-akademi/`

## Supabase kurulumu

1. Supabase projesinde SQL Editor'ü aç.
2. `supabase/student_progress.sql` dosyasının içeriğini çalıştır.
3. Site kodunda yalnızca Supabase URL ve publishable/anon anahtarı bulunmalıdır. `service_role` veya secret key'i istemci koduna ekleme.
4. Canlı URL belli olduktan sonra Authentication → URL Configuration bölümündeki Site URL ve Redirect URLs alanlarını bu adresle eşleştir.

## Gizlilik ve kayıtlar

- Parola Supabase Auth tarafından işlenir; uygulama parolayı yerel depolamada saklamaz.
- Hesaplı kullanımda ilerleme verileri kullanıcıya özel satırda tutulur; tablo RLS ile korunur.
- Hesapsız kullanımda kayıtlar kullanılan tarayıcının yerel depolamasında kalır.
- Ders sayacı oturumları yerel olarak saklanır ve hesap senkronizasyonuna eklenir.
- Yağmur sesi kullanıcının açıkça başlatmasıyla üretilir; ses verisi kaydedilmez.

## Proje dosyaları

- Ana uygulama: `index.html`
- Gizlilik notu: `gizlilik.html`
- Supabase tablo ve RLS kurulumu: `supabase/student_progress.sql`
- Otomatik GitHub Pages yayını: `.github/workflows/deploy.yml`
