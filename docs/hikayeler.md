# ModaRota İade Servisi — Kullanıcı Hikâyeleri

**Dayanak:** `docs/karar-kartlari.md` (K1–K5), `docs/karar-ve-varsayim-tablosu.md` (V1–V3), `docs/iade-politikasi.md`
**Veri:** `data/orders.json` (S-1001, S-1002, S-1003), `data/closed_days.json` (2026-03-05, 2026-03-06)

## Veriden türetilen referans değerler

Üç siparişin teslim tarihi de **2026-03-01**'dir. Kapalı günler 2026-03-05 ve 2026-03-06'dır; ikisi de teslim tarihi ile son iade tarihi arasında kalır.

| Hesap | Sonuç |
|---|---|
| Teslimden 14 gün sonra (kapalı gün yok) | 2026-03-15 |
| Aradaki kapalı gün sayısı (K1) | 2 |
| Uzatılmış son iade tarihi | 2026-03-17 |
| Hasar bildirimi için teslimden 3 gün sonra (K4) | 2026-03-04 |

> ⚠ Varsayım (V-gün): "14 gün içinde" ifadesinde teslim günü sayılmaz, 14. gün dahildir. Kartlarda gün sayma biçimi yazılı değildir. Bu varsayım onaylanana kadar aşağıdaki sınır tarihleri (03-15, 03-17, 03-04) kesin kural değildir.

---

## US-01 — Kapalı günlerin iade süresini uzatması

**Hikâye:** Bir **müşteri** olarak, depo kapalı günlerin iade süremden sayılmamasını istiyorum, böylece depo kapalıyken geçen günler yüzünden iade hakkımı kaybetmem.

**Kabul kriterleri:**

1. **Given** S-1001 siparişi 2026-03-01'de teslim edilmiş ve 2026-03-05 ile 2026-03-06 depo kapalı günlerdir,
   **When** müşteri 2026-03-17 tarihinde iade talebi oluşturur,
   **Then** talep süre içinde kabul edilir (14 günlük süre 2 kapalı gün nedeniyle 2 gün uzamıştır).
2. **Given** aynı sipariş ve aynı kapalı günler,
   **When** müşteri 2026-03-18 tarihinde iade talebi oluşturur,
   **Then** talep süre dışında kalır.
3. **Given** S-1001 siparişi,
   **When** müşteri 2026-03-16 tarihinde talep oluşturur,
   **Then** talep kabul edilir; kapalı günler sayılmasaydı bu tarih süre dışı olacaktı (2026-03-15).

**Kaynak:** K1 (Çelişki satırı 17: Politika §1, §5 ile)
**⚠ Varsayım:** Gün sayma biçimi (V-gün) — yukarıdaki not.

---

## US-02 — Kampanyalı üründe ödenen tutarın iadesi

**Hikâye:** Bir **müşteri** olarak, kampanyalı ürünümde bile ödediğim tutarın iade edilmesini istiyorum, böylece fazla veya eksik para almam.

**Kabul kriterleri:**

1. **Given** S-1002 siparişi kampanyalıdır (`onCampaign: true`, `listPrice` 240, `paidAmount` 180),
   **When** süresi içinde iade talebi onaylanır,
   **Then** iade tutarı 180'dir (liste fiyatı olan 240 değil).
2. **Given** S-1001 siparişi kampanyasızdır (`paidAmount` 240, `listPrice` 240),
   **When** süresi içinde iade talebi onaylanır,
   **Then** iade tutarı 240'tır.

**Kaynak:** K3 (Politika §10 ile uyumlu)

---

## US-03 — Süre kontrolünün talep tarihine göre yapılması

**Hikâye:** Bir **çağrı merkezi temsilcisi** olarak, süre kontrolünün talebin hangi kanaldan geldiğine bakmadan yapılmasını istiyorum, böylece aynı koşuldaki müşterilere aynı sonucu veririm.

**Kabul kriterleri:**

1. **Given** S-1001 siparişi 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-03-17 tarihinde müşteri hesabı üzerinden oluşturulur,
   **Then** süre teslim tarihinden başlatılarak kontrol edilir ve talep kabul edilir.
2. **Given** aynı sipariş,
   **When** talep 2026-03-17 tarihinde çağrı merkezi aracılığıyla oluşturulur,
   **Then** sonuç 1. kriterle aynıdır (kabul).
3. **Given** aynı sipariş,
   **When** talep 2026-03-18 tarihinde herhangi bir kanaldan oluşturulur,
   **Then** talep her iki kanalda da süre dışı sayılır.

**Kaynak:** K5 (Politika §4, §5 ile)
**⚠ Varsayım:** Gün sayma biçimi (V-gün). Kanal listesi (hesap, çağrı merkezi) yalnızca Politika §4'tür; kartlarda başka kanal yoktur.

---

## US-04 — Hasarlı teslimatın süresi içinde bildirilmesi

**Hikâye:** Bir **müşteri** olarak, hasarlı teslim aldığım ürünü bildirebilmek ve kargo ücretini ödememek istiyorum, böylece firmanın hatası için masraf etmem.

**Kabul kriterleri:**

1. **Given** S-1001 siparişi 2026-03-01'de hasarlı teslim edilmiştir,
   **When** müşteri hasarı 2026-03-04 tarihinde bildirir,
   **Then** bildirim 3 günlük süre içindedir ve kargo ücreti firmaya aittir.
2. **Given** aynı sipariş,
   **When** müşteri hasarı 2026-03-05 tarihinde bildirir,
   **Then** bildirim 3 günlük süreyi aşmıştır; talebin bundan sonraki akışı kartlarda tanımlı değildir ve ayrıca karara bağlanmalıdır.

**Kaynak:** K4 (Çelişki satırı 18: Politika §12 ile)
**⚠ Varsayım:** Gün sayma biçimi (V-gün). K1 yalnızca 14 günlük süreyi uzattığı için 03-05 ve 03-06 kapalı günlerinin 3 günlük hasar süresini uzatmadığı varsayılmıştır; kartlarda bu konuda yazılı kural yoktur.

---

## US-05 — Kişiye özel ürünün iade kapsamı dışında kalması

**Hikâye:** Bir **çağrı merkezi temsilcisi** olarak, kişiye özel ürünler için iade talebinin otomatik reddedilmesini istiyorum, böylece müşteriye yanlış beklenti vermem.

**Kabul kriterleri:**

1. **Given** S-1003 siparişi kişiye özeldir (`personalized: true`) ve 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-03-17 tarihinde, yani süre içinde oluşturulur,
   **Then** talep süre nedeniyle değil, ürün kişiye özel olduğu için iade kapsamı dışında kalır.
2. **Given** S-1001 siparişi kişiye özel değildir (`personalized: false`) ve aynı tarihte teslim edilmiştir,
   **When** talep 2026-03-17 tarihinde oluşturulur,
   **Then** kişiye özel ürün engeli uygulanmaz.

**Kaynak:** Politika §1 (Tablo satır 8: V3)
**⚠ Varsayım:** V3 — kişiye özel ürünün hasarı iade kapsamına girer mi sorusunun kartta cevabı yoktur. Bu hikâye yalnızca Politika §1'deki genel dışlamayı kapsar; kişiye özel ürün **hasar** talebi kesin kural olarak yazılmamıştır.

---

## Tutarsızlıklar

1. **Dosya adları uyuşmuyor.** İstemde `siparisler.json` ve `kapali-gunler.json` geçiyor. Projedeki gerçek dosyalar `data/orders.json` ve `data/closed_days.json`. Hikâyeler gerçek dosyalara dayanır.
2. **Alan adı uyuşmuyor.** İstemde `deliveryDatei` yazıyor; dosyada alan `deliveryDate` olarak geçiyor (yazım hatası sayıldı).
3. **Veride talep ve bildirim tarihi yok.** Dosyalarda yalnızca teslim tarihi (hepsi 2026-03-01) var. Kriterlerdeki 2026-03-04, 03-05, 03-16, 03-17 ve 03-18 tarihleri veriden hesaplanmış sınır değerleridir, veri dosyasından okunmuş tarihler değildir.
4. **Tüm siparişlerin teslim tarihi aynı.** Üç siparişin teslim tarihi aynı olduğu için farklı teslim tarihlerinde kapalı günlerin etkisi test edilemez. Kapalı günlerin 14 günlük pencerenin dışında kaldığı durum için veri yok.
5. **Kargo bilgisi yok.** Siparişlerde kargo firması alanı bulunmaz. K2 (değişimde kargo ücreti) için veriye dayalı örnek yazılamadı, bu yüzden K2 hikâyesi eklenmedi.
6. **Hasar bilgisi yok.** Hiçbir siparişte hasar alanı yok. US-04'te S-1001'in hasarlı teslim edildiği, kriterin kendi koşulu olarak (Given) kabul edildi.
7. **Politika ile kart çelişkileri** (tabloda 17 ve 18): Politika §13 kapalı günler için hüküm içermez; K1 uzatma kuralını getirir (US-01). Politika §12 hasar için süre vermez; K4 3 günlük süre getirir (US-04). Hikâyelerde kartlar esas alınmıştır.
8. **Ortak belirsizlik.** Gün sayma biçimi (teslim günü dahil mi, 14. gün dahil mi) hiçbir kartta yok. Tüm sınır tarihleri bu varsayıma bağlıdır.
