# ModaRota İade Servisi — Spec

**Kaynaklar:** `docs/hikayeler.md`, `docs/karar-kartlari.md`, `docs/iade-politikasi.md`. Tutarlılık kontrolü için `data/orders.json`, `data/closed_days.json` ve `docs/karar-ve-varsayim-tablosu.md` de okundu.
**Not:** İstemde `docs/hikayeleri.md` yazıyor; projedeki gerçek dosya `docs/hikayeler.md`.

## Kural durumları

- **Kesin:** Karar kartında (K1–K5) karşılığı var.
- **Politika:** Yalnızca `iade-politikasi.md`'de var, kartta karşılığı yok. Yayımlanmış metin olarak geçerlidir ama kartla doğrulanmamıştır.
- **Varsayım:** V1–V3 veya hikâyenin kendi varsayımı. Kesin kural değildir.

Bu spec'te "Kesin" kural tablosunda yer almayan hiçbir şey kesin kural gibi yazılmamıştır.

---

## US-01 — Kapalı günlerin iade süresini uzatması

**Kaynak:** K1 (Politika §1, §5, §13 ile çelişki: kartlar esas alındı)
**Etiket:** Gün sayma biçimi (O1) kullanıcı tarafından onaylandı; kartta yazılı değildir, onaylı karar olarak işlendi.

**Kural durumu**

| Kural | Durum | Karşılık |
|---|---|---|
| Teslim tarihi ile son iade tarihi arasındaki her depo kapalı gün, 14 günlük süreyi bir gün uzatır. | Kesin | K1 |
| Teslim günü sayılmaz, 14. gün dahildir. | Onaylı karar (kartta yok) | O1, kullanıcı onayı |
| Uzatılan aralığa yeni bir kapalı gün düşerse süre tekrar uzar (zincirleme). | Onaylı karar (kartta yok) | Kullanıcı kararı; K1 "arasındaki her kapalı gün" der, zincirleme için açık hüküm yok |
| Talep tarihi teslim tarihinden önceyse talep reddedilir. | Onaylı karar (kartta yok) | Kullanıcı kararı |
| Teslim gününün kendisinde oluşturulan talep kabul edilir. | Onaylı karar (kartta yok) | Kullanıcı kararı (O10) |
| Depo kapalı bir günde oluşturulan talep, süre içinde olsa bile reddedilir. | Onaylı karar (kartta yok) | Kullanıcı kararı (O11) |
| Süre uzatması kapalı günlerin yalnızca teslim ile (uzatılmış) son iade tarihi arasında kalanlarını sayar. | Onaylı karar (kartta yok) | Kullanıcı kararı (ek kriter B) |

**Kabul kriterleri**

1. **Given** S-1001 2026-03-01'de teslim edilmiş ve 2026-03-05 ile 2026-03-06 depo kapalı günlerdir,
   **When** müşteri 2026-03-17'de iade talebi oluşturur,
   **Then** talep süre içinde kabul edilir. *(Tarih sınırı ⚠ gün sayma varsayımına bağlı.)*
2. **Given** aynı sipariş ve kapalı günler,
   **When** müşteri 2026-03-18'de talep oluşturur,
   **Then** talep süre dışında kalır. *(⚠ aynı varsayım)*
3. **Given** S-1001,
   **When** müşteri 2026-03-16'da talep oluşturur,
   **Then** talep kabul edilir; kapalı günler sayılmasaydı süre 2026-03-15'te bitecekti. *(⚠ aynı varsayım)*

**Onaylı ek kriterler** (kullanıcı onayıyla eklendi; kartta karşılığı yok). 4–6. kriterler `data/closed_days.json` içinde karşılığı olmayan **test verisi** gerektirir, bu yüzden Given kısmında belirtilmiştir. Tarihleri veri dosyasına yazmadım.

4. **(A — kapalı gün yok)** **Given** S-1001'in teslim tarihi 2026-03-01 ve kapalı gün listesi boştur *(test verisi)*,
   **When** müşteri 2026-03-15'te talep oluşturur,
   **Then** talep kabul edilir.
   **When** müşteri 2026-03-16'da talep oluşturur,
   **Then** talep süre dışı olarak reddedilir.
5. **(B — kapalı gün aralığın dışında)** **Given** S-1001 (teslim 2026-03-01), kapalı günler 2026-03-05 ve 2026-03-06'dır ve ek olarak 2026-03-20 kapalıdır *(test verisi)*,
   **When** son iade tarihi hesaplanır,
   **Then** sonuç 2026-03-17'dir; 2026-03-20 uzatılmış aralığın dışında kaldığı için sayılmaz.
6. **(C — zincirleme uzatma)** **Given** S-1001 (teslim 2026-03-01), kapalı günler 2026-03-05, 2026-03-06 ve ek olarak 2026-03-16'dır *(test verisi)*,
   **When** son iade tarihi hesaplanır,
   **Then** sonuç 2026-03-18'dir: ilk uzatma 2026-03-17'ye götürür, bu aralığa düşen 2026-03-16 süreyi bir gün daha uzatır.
   **When** müşteri 2026-03-18'de talep oluşturur, **Then** kabul edilir; 2026-03-19'da talep oluşturursa süre dışı olarak reddedilir.
7. **(D — teslimden önce talep)** **Given** S-1001 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-02-28'de (teslimden bir gün önce) oluşturulur,
   **Then** talep reddedilir.
8. **(O10 — teslim günü)** **Given** S-1001 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-03-01'de (teslim gününde) oluşturulur,
   **Then** talep kabul edilir.
9. **(O11 — kapalı günde talep)** **Given** S-1001 2026-03-01'de teslim edilmiştir ve 2026-03-05 depo kapalı günüdür,
   **When** talep 2026-03-05'te oluşturulur (son iade tarihi 2026-03-17 olduğu için süre içindedir),
   **Then** talep depo kapalı günde oluşturulduğu için reddedilir.
   **When** talep 2026-03-07'de (kapalı günlerden sonraki ilk açık gün) oluşturulur,
   **Then** talep kabul edilir.

---

## US-02 — Kampanyalı üründe ödenen tutarın iadesi

**Kaynak:** K3 (Politika §10 ile uyumlu)
**Etiket:** Yok

**Kural durumu**

| Kural | Durum | Karşılık |
|---|---|---|
| İade tutarı müşterinin ödediği tutardır; kampanya tipinin önemi yoktur. | Kesin | K3 |

**Kabul kriterleri**

1. **Given** S-1002 kampanyalıdır (`listPrice` 240, `paidAmount` 180),
   **When** süresi içinde iade talebi onaylanır,
   **Then** iade tutarı 180'dir.
2. **Given** S-1001 kampanyasızdır (`paidAmount` 240),
   **When** süresi içinde iade talebi onaylanır,
   **Then** iade tutarı 240'tır.

---

## US-03 — Süre kontrolünün talep tarihine göre yapılması

**Kaynak:** K5 (Politika §4, §5)
**Etiket:** ⚠ Varsayım — gün sayma biçimi

**Kural durumu**

| Kural | Durum | Karşılık |
|---|---|---|
| Süre teslim tarihinden başlar; kanalın önemi yoktur; talebin oluşturulduğu tarih kontrol edilir. | Kesin | K5 |
| Talep kanalları: müşteri hesabı ve çağrı merkezi. | Politika | §4 (kartta yok) |
| Gün sayma biçimi. | ⚠ Varsayım | Kartta yok |

**Kabul kriterleri**

1. **Given** S-1001 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-03-17'de müşteri hesabı üzerinden oluşturulur,
   **Then** süre teslim tarihinden başlatılarak kontrol edilir ve talep kabul edilir. *(⚠)*
2. **Given** aynı sipariş,
   **When** talep 2026-03-17'de çağrı merkezi aracılığıyla oluşturulur,
   **Then** sonuç 1. kriterle aynıdır. *(⚠)*
3. **Given** aynı sipariş,
   **When** talep 2026-03-18'de herhangi bir kanaldan oluşturulur,
   **Then** talep her iki kanalda da süre dışı sayılır. *(⚠)*

---

## US-04 — Hasarlı teslimatın süresi içinde bildirilmesi

**Kaynak:** K4 (Politika §12 ile çelişki: kartlar esas alındı)
**Etiket:** ⚠ Varsayım — gün sayma biçimi; kapalı günlerin hasar süresine etkisi

**Kural durumu**

| Kural | Durum | Karşılık |
|---|---|---|
| Hasarlı teslimatta kargo ücreti firmaya aittir. | Kesin | K4 |
| Müşteri hasarı teslimden itibaren 3 gün içinde bildirmelidir. | Kesin | K4 |
| Gün sayma biçimi (2026-03-04 son gün). | ⚠ Varsayım | Kartta yok |
| Depo kapalı günler 3 günlük hasar süresini uzatmaz. | ⚠ Varsayım | K1 yalnızca 14 günlük süreyi kapsar |
| 3 gün aşıldığında talebin akışı. | Tanımsız | Kartta yok |

**Kabul kriterleri**

1. **Given** S-1001 2026-03-01'de hasarlı teslim edilmiştir,
   **When** müşteri hasarı 2026-03-04'te bildirir,
   **Then** bildirim süre içindedir ve kargo ücreti firmaya aittir. *(⚠ gün sayma)*
2. **Given** aynı sipariş,
   **When** müşteri hasarı 2026-03-05'te bildirir,
   **Then** bildirim 3 günlük süreyi aşmıştır. Sonraki akış kartlarda tanımlı değildir (bkz. Eksik kriterler E1). *(⚠ gün sayma ve kapalı gün varsayımı)*

---

## US-05 — Kişiye özel ürünün iade kapsamı dışında kalması

**Kaynak:** Politika §1; Varsayım V3 (hikâyede V3 olarak etiketli)
**Etiket:** ⚠ Varsayım (V3)

**Kural durumu**

| Kural | Durum | Karşılık |
|---|---|---|
| Kişiye özel üretilen ürünler iade kapsamı dışındadır. | Politika | §1 (karar kartı yok) |
| Kişiye özel ürünün **hasarı** iade kapsamına girer mi. | ⚠ Varsayım (onay bekliyor) | V3: kapsam dışı öneri; hasar talebi ayrıca karara bağlanmalı |
| Talebin "otomatik reddedilmesi". | Tanımsız | Ne kartta ne politikada var |

**Kabul kriterleri**

1. **Given** S-1003 kişiye özeldir (`personalized: true`), 2026-03-01'de teslim edilmiştir,
   **When** talep 2026-03-17'de, süre içinde oluşturulur,
   **Then** talep süre nedeniyle değil, ürün kişiye özel olduğu için iade kapsamı dışında kalır. *(Politika §1; ⚠ gün sayma)*
2. **Given** S-1001 kişiye özel değildir (`personalized: false`),
   **When** talep 2026-03-17'de oluşturulur,
   **Then** kişiye özel ürün engeli uygulanmaz.

---

## Açık sorular

Hikâyelerdeki kuralların kartta karşılığı olmayan veya kartla çelişen noktaları. Hiçbiri kesin kural olarak kabul edilmemiştir.

| No | Soru | İlgili | Durum |
|---|---|---|---|
| O1 | Gün sayma biçimi: teslim günü sayılmaz, 14. gün dahil. | US-01, 03, 04 | **Onaylandı** (kullanıcı). Kartta yok; onaylı karar olarak geçerli. US-03/04'teki ⚠ etiketleri bu onaya göre güncellenmedi. |
| O2 | Depo kapalı günler 3 günlük hasar bildirim süresini de uzatır mı? K1 yalnızca 14 günlük süreden söz eder. | US-04 | Kartta yok |
| O3 | Hasar bildirimi süresi aşılırsa ne olur (red mi, istisna mı)? | US-04 | Kartta yok |
| O4 | Kişiye özel ürün talebi "otomatik reddedilir" mi, yoksa temsilci mi karar verir? Politika §14 itirazda temsilciyi yetkili kılar, ölçüt yazılı değil. | US-05 | Kartta yok, V1 ile ilişkili |
| O5 | Kişiye özel ürünün hasarı iade kapsamına girer mi? | US-05 | V3, onay bekliyor |
| O6 | Çağrı merkezi temsilcisinin istisna yetkisi var mı? US-03 ve US-05 temsilci rolünü kullanıyor ama hiçbir kriter yetki vermiyor. | US-03, 05 | V1, onay bekliyor |
| O7 | Kapalı gün olan bir günde (örn. 2026-03-05) yapılan hasar bildirimi veya talep kabul edilir mi? | US-04 | Kartta yok |
| O8 | Politika §12 "teslim anında" der, K4 "3 gün içinde" der. Kart esas alındı; politika metninin güncellenmesi gerekir. | US-04 | Çelişki (tablo satır 18) |
| O9 | Politika §1/§5 14 günü kapalı gün istisnası olmadan yazar; K1 uzatma getirir. Kart esas alındı. | US-01 | Çelişki (tablo satır 17) |
| O10 | Teslim gününün kendisinde (2026-03-01) oluşturulan talep kabul edilir. | US-01 | **Karar verildi** (kullanıcı), kriter 8 |
| O11 | Depo kapalı bir günde (örn. 2026-03-05) oluşturulan talep kabul edilmez. | US-01 | **Karar verildi** (kullanıcı), kriter 9. O7'nin talep kısmını kapatır; hasar bildirimi (US-04) için O7 açık kalır. |

## Eksik kriterler

Tespit edilen boşluklar. Kriter uydurulmamıştır; kartlar veya paydaş kararı gelince yazılmalıdır.

- **E1:** Hasar bildirimi 3 günü aştığında beklenen sonuç (US-04, O3).
- **E2:** Kargo ücretinin kime ait olduğu (K2: anlaşmalı kargoda firma, değil ise müşteri; değişimde de aynı). Hiçbir hikâyede kriteri yok. Siparişlerde kargo alanı da olmadığından veriye dayalı örnek yazılamaz.
- **E3:** Değişim akışı (Politika §8) ve stokta olmayan değişim (Politika §9, V2). Hikâye yok.
- **E4:** Ürün koşulu (Politika §2) ve ambalaj (Politika §3) için kriter yok. Ambalaj hasarında hüküm yok.
- **E5:** Ödeme yöntemine göre iade süresi (Politika §11). Hikâye ve kart yok.
- **E6:** İtiraz akışı (Politika §14, V1). Hikâye ve ölçüt yok.
- **E7:** *(US-01 için kapatıldı: zincirleme uzatma kullanıcı kararıyla US-01 kriter 6 olarak eklendi. Veri dosyasında zincirleme örneği yok, kriter test verisi gerektirir.)*
- **E8:** Hasarlı ürün için iade tutarı ve ürün koşulu etkileşimi (Politika §2 ile K4).

V2 hiçbir hikâyede kullanılmamıştır; V1 yalnızca rol üzerinden dolaylıdır.

## Tutarsızlıklar

Veri dosyaları (`data/orders.json`, `data/closed_days.json`) ile hikâyeler karşılaştırıldı.

**Uyuşanlar:** S-1001 (240/240, kampanyasız, özel değil), S-1002 (180/240, kampanyalı) ve S-1003 (özel) hikâyelerdeki değerlerle birebir uyuşuyor. Kapalı günler 2026-03-05 ve 2026-03-06 hikâyelerle uyuşuyor.

**Uyuşmayanlar ve eksikler**

1. **Talep ve bildirim tarihi veride yok.** Hikâyelerdeki 2026-03-04, 03-05, 03-16, 03-17 ve 03-18 tarihleri teslim tarihi (2026-03-01) ve kapalı günlerden hesaplanmış değerlerdir, veri dosyasından okunmamıştır.
2. **Hasar ve kargo alanı veride yok.** US-04'teki "hasarlı teslim" S-1001 için veride kayıtlı değildir; yalnızca kriterin kendi koşuludur. Kargo firması bilgisi de yoktur (E2).
3. **Tüm siparişlerin teslim tarihi aynı** (2026-03-01). Farklı teslim tarihlerinde kapalı gün etkisi veriyle test edilemez.
4. **Kapalı gün olan tarihte bildirim** (US-04 kriter 2: 2026-03-05) veri açısından depo kapalı bir güne denk geliyor; bunun etkisi tanımsız (O7).
5. **US-01 ek kriterleri (4–6) için veri yok.** Kapalı gün listesi boş olan, aralık dışında kapalı günü olan ve zincirleme uzatma gerektiren veri `data/closed_days.json` içinde bulunmuyor. Kriterler test verisi (ör. sahte `IClosedDayProvider`) ile sınanmalı; gerçek veri dosyası değiştirilmemelidir.
5b. **Dosya adı farkları.** İstemler `hikayeleri.md`, `siparisler.json`, `kapali-gunler.json`, `deliveryDatei` adlarını kullanıyor; gerçek adlar `hikayeler.md`, `orders.json`, `closed_days.json`, `deliveryDate`.
6. **Kaynak etiketi.** US-05, V3 etiketli ama V3 kişiye özel ürünün **hasarını** konu alır. Hikâye ise Politika §1'deki genel dışlamayı test eder. Bu iki konu aynı şey değildir (O5).
