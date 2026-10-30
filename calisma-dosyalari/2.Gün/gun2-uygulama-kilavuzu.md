# Gün 2: Uygulama Kılavuzu

Bu dosya, 2.günde kullanılan uygulama örneklerini **sırayla nasıl yürüteceğinizi** anlatır:

> **Doğrulama notu:** Claude Code komutları (`/agents`, `/rewind`, plan mode kısayolu) ve skill/subagent dosya biçimi sürüme göre değişebilir. Eğitimden önce kılavuzu bir kez baştan sona kendiniz çalıştırın. Aşağıdaki "beklenen çıktı" bölümleri kabul aralığıdır, birebir aynı çıktı beklemeyin.

---

## 1. Günün akışı (tek bakışta)

```
Adım 1  Kurulum ve ekipler
   │
Adım 2  CLAUDE.md ile proje bağlamı
   │
Adım 3  SPEC (iş analisti öncülüğünde)
   │     karar kartları → karar-varsayım-tablosu → kullanıcı hikâyeleri
   │     → Given-When-Then → docs/spec.md          [slash komut: /acceptance-criteria]
   │
Adım 4  TECH STACK SKILL + proje iskeleti
   │     (csharp-aspnet-standartlari skill'i, plan mode)
   │
Adım 5  SPEC'TEN KODA (geliştirici öncülüğünde)
   │     US-01, US-02, US-05 için iş kuralı kodu
   │
Adım 6  SUBAGENT 1: code-reviewer (kod incelemesi)
   │
Adım 7  SUBAGENT 2: test-engineer (Given-When-Then → xUnit testi)
   │                                               [slash komut: /gwt-test]
Adım 8  Checkpoint ile oturumu geri Alma
```

**Kim ne kullanır:** İş analistleri claude.ai Project'te, geliştiriciler Claude Code'da çalışır. Adım 3'ün sonunda analist spec'i geliştiriciye dosya olarak verir. Bu devir, günün ana temasıdır.

**Dosya akışı:**

```
karar-kartlari.md ──► (Project) karar/varsayım tablosu ──► kullanıcı hikâyeleri
                                                              │
                                                       docs/spec.md
                                                              │
CLAUDE.md + skill ─────────────────────────────────────► kod (src/)
                                                              │
                                              code-reviewer ──┤
                                              test-engineer ──┴──► tests/
```

---

## 2. Eğitimden önce hazırlayacağınız repo

Repo **yalnızca bu dosyaları** içerir. Kod yazılmamıştır. Proje iskeletini katılımcılar Adım 4'te Claude Code ile kuracak.

```
iade-uygulamasi-lab/
├── CLAUDE.md                              # Adım 2'de katılımcılar yazar
├── docs/
│   ├── karar-kartlari.md                  # gun2-karar-kartlari.md dosyası
│   └── iade-politikasi.md                 # iade-politikasi.md dosyası
├── data/
│   ├── siparisler.json                    # aşağıda
│   └── kapali-gunler.json                 # aşağıda
└── .claude/
    ├── skills/csharp-aspnet-standartlari/SKILL.md
    ├── agents/code-reviewer.md
    ├── agents/test-engineer.md
    └── commands/
        ├── kabul-kriteri.md
        └── gwt-test.md
```

### data/orders.json

```json
[
	{
		"orderNo": "S-1001",
		"deliveryDate": "2026-03-01",
		"paidAmount": 240,
		"listPrice": 240,
		"onCampaign": false,
		"personalized": false
	},
	{
		"orderNo": "S-1002",
		"deliveryDate": "2026-03-01",
		"paidAmount": 180,
		"listPrice": 240,
		"onCampaign": true,
		"personalized": false
	},
	{
		"orderNo": "S-1003",
		"deliveryDate": "2026-03-01",
		"paidAmount": 300,
		"listPrice": 300,
		"onCampaign": false,
		"personalized": true
	}
]
```

### data/closed-days.json

```json
["2026-03-05", "2026-03-06"]
```

### .claude/skills/csharp-aspnet-standartlari/SKILL.md

Bu skill, "bu projede C# kodu nasıl yazılır" bilgisini taşır. Claude kod yazarken bunu kullanır.

```markdown
---
name: csharp-aspnet-standartlari
description: ASP.NET Core Web API ve xUnit ile C# kodu yazarken veya incelerken kullan. Proje yapısı, İngilizce adlandırma, tarih işleme, hata kodları ve test kuralları içerir.
---

# C# / ASP.NET Core standartları

## Genel kural

Bu standartlar sıfırdan kurulan projeler için geçerlidir. Tüm kod kimlikleri (proje, klasör, dosya, namespace, sınıf, metot, özellik, değişken, test adları) İngilizcedir. Kullanıcıya görünen mesajlar ve yorum satırları Türkçedir.

## Proje yapısı

- Solution: `ReturnService.slnx`
- `src/ReturnService`: Web API (.NET 9, `net9.0`). İş kuralları `Domain/` klasöründe, uç noktalar `Endpoints/` klasöründe.
- `tests/ReturnService.Tests`: xUnit testleri.
- İş kuralları (süre, tutar, kargo) ayrı sınıflarda olur ve doğrudan test edilebilir. Uç nokta sınıfında iş kuralı olmaz.

## Adlandırma

- Sınıf, record, arayüz, metot ve özellik adları PascalCase, İngilizce: `ReturnDurationCalculator`, `ReturnRequest`, `ReturnEndpoints`.
- Arayüzler `I` ile başlar: `IOrderSource`, `IClosedDayProvider`.
- Yerel değişken ve parametreler camelCase, İngilizce: `orderNo`, `requestDate`.
- Sabitler PascalCase: `ReturnWindowDays = 14`.
- Dosya adı, içindeki ana sınıfın adıyla aynı olur.
- Kimlik adlarında Türkçe karakter (ı, ş, ğ, ç, ö, ü) kullanılmaz.
- Veri dosyalarının adları İngilizce olur: `data/orders.json`, `data/closed-days.json`.

## Türkçe kalan yerler

- Kullanıcıya dönen mesajlar Türkçe: `"İade nedeni zorunludur."`. Bunlar kimlik değil, metindir.
- Yorum satırları Türkçe.

## Kodlama kuralları

- Tarihler için `DateOnly` kullan. `DateTime.Now` ve `DateTime.Today` kullanma. Tarih her zaman parametre olarak gelir.
- İstek ve yanıt modelleri için `record` kullan.
- Girdi doğrulaması uç noktada yapılır: sipariş bulunamazsa 404, geçersiz tarih veya alan 400.
- Sihirli sayıları (ör. 14 gün) adlandırılmış sabit olarak tanımla.
- Kimlik bilgisi ve gerçek müşteri verisi koda, testlere veya loglara yazılmaz.

## Test kuralları

- Test sınıfı, test edilen konunun adıyla biter: `ReturnWindowTests`, `ReturnReasonTests`.
- Test metot adı: `US{numara}_{Durum}_{BeklenenSonuç}`. Örnekler: `US01_Request17March_Accepted`, `US01_Request18March_RejectedOutOfWindow`.
- Numara spec'teki kullanıcı hikâyesinin numarasıdır. Spec'te olmayan bir numara uydurulmaz; bu durumda issue numarası kullanılır: `Issue2_ReturnReasonTests`.
- Her test Given / When / Then yorum satırlarıyla bölümlenir.
- Sınır değerleri (son gün ve son günden sonraki gün) ayrıca test edilir.
- Testte gerçek tarih değeri kullanılır, rastgele değer değil.
- Beklenen değer spec'ten gelir. Kod değişince test beklentisi kod uysun diye değiştirilmez.

## Komutlar

- Derleme: `dotnet build`
- Test: `dotnet test`
- Biçim: `dotnet format`
```

### .claude/agents/code-reviewer.md

```markdown
---
name: code-reviewer
description: C# kodunu docs/spec.md'ye, CLAUDE.md'ye ve csharp-aspnet-standartlari skill'ine göre inceler. Kod yazıldıktan sonra kullan. Kodu değiştirmez, yalnızca bulgu raporlar.
tools: Read, Grep, Glob
---

Sen deneyimli bir C# kod inceleyicisisin. Kodu değiştirmezsin, yalnızca raporlarsın.

İnceleme sırası:

1. docs/spec.md'yi oku. Kod, spec'teki iş kurallarını ve kabul kriterlerini karşılıyor mu?
2. CLAUDE.md ve csharp-aspnet-standartlari skill'indeki kurallara uyuluyor mu?
3. Hata durumları (sipariş yok, geçersiz tarih) ele alınmış mı?
4. Spec'te olmayan bir kural kodda var mı?

Çıktı biçimi (Markdown tablo):
| No | Dosya:satır | Bulgu | Önem (Yüksek/Orta/Düşük) | Hangi US veya kural | Öneri |

Kurallar:

- Her bulgu için spec'teki ilgili maddeyi belirt.
- Emin olmadığın bir şeyi bulgu yapma, "Soru" olarak ayrı listele.
- En sonda "Spec'e uygun olanlar" başlığıyla kısa bir olumlu özet ver.
```

### .claude/agents/test-engineer.md

```markdown
---
name: test-engineer
description: docs/spec.md'deki Given-When-Then kabul kriterlerini xUnit testlerine dönüştürür ve çalıştırır. Test yazılması, test eksiklerinin giderilmesi veya kapsam kontrolü istendiğinde kullan.
tools: Read, Grep, Glob, Write, Edit, Bash
---

Sen bir test mühendisisin. docs/spec.md'deki her kabul kriterini bir xUnit testine dönüştürürsün.

Dönüştürme kuralı:

- Given satırı → test içindeki hazırlık (Arrange)
- When satırı → çağrılan metot (Act)
- Then satırı → Assert

Kurallar:

- Test adı: US{numara}_{Durum}_{BeklenenSonuç}.
- Her testin üstüne hangi US ve hangi kriteri karşıladığını yorum olarak yaz.
- Sınır değerlerini ayrıca test et.
- Kodu değiştirme. Test geçmiyorsa nedenini raporla.
- Çalıştırma: dotnet test.

Çıktının sonunda şu tabloyu ver:
| US | Kabul kriteri | Test adı | Sonuç (Geçti/Kaldı) |
```

### .claude/commands/acceptance-criteria.md

```markdown
Aşağıdaki iş kuralı için Given-When-Then biçiminde kabul kriterleri yaz: $ARGUMENTS

Kurallar:

- En az bir olumlu, bir olumsuz ve bir sınır değeri senaryosu olsun.
- Somut tarih ve tutar kullan (2026 yılı).
- Kuralın kaynağını (karar kartı numarası veya "Varsayım") yaz.
- Spec'te olmayan kural ekleme. Eksik bilgi varsa soru olarak yaz.
```

### .claude/commands/gwt-test.md

```markdown
test-engineer subagent'ını kullan. docs/spec.md içindeki şu kullanıcı hikâyesinin
tüm kabul kriterlerini xUnit testine dönüştür ve çalıştır: $ARGUMENTS
Sonunda kriter-test eşleme tablosunu ver.
```

## Projedeki dosyaları görüntüleme

Skills: ! ls .claude/skills
Command: ! ls .claude/commands
Agents: ! ls .claude/agents
Hooks: ! ls .claude/hooks

---

## 1. User Story Oluşturma (İş Analisti)

### Genel Konsept

**Amaç:** İş analistinin açık soruları kararlarla kapatması ve geliştiricinin kodlayabileceği bir spec üretmesi.

**Karar ve varsayım tablosu**

Karar ve varsayım tablosu, user story yazmadan önce neyin kesin, neyin hâlâ belirsiz olduğunu tek yerde görmek için çıkarılır.

1. Kararlar sahiplerin verdiği kesin kurallardır. Hikâyeler ve kabul kriterleri bunlara dayanır.
2. Varsayımlar cevabı olmayan ama ilerlemek için geçici kabul edilen konulardır. Açıkça işaretlenir, böylece sahibi onaylamadan spec’e kesin kural olarak girmez.
3. Politika kontrolü politikadaki, kartlarda sorulmamış kuralların da listede kalmasını sağlar.

Bu tablo, hikâyelerin her birini bir karar ya da varsayıma bağlamayı ve sonradan bir kararın değişmesi durumunda hangi hikâyelerin güncelleneceğini bulmayı kolaylaştırır.

**Görev-1: Claude.AI üzerinden yapılabilir**

`iade-politikasi.md` ve `karar-kartlari.md`. Bu prompt, kartlardaki 5 kararı ve 3 cevapsız soruyu tek bir tabloya toplar.

```
Ekteki iade-politikasi.md ve karar-kartlari.md dosyalarını kullanarak karar ve varsayım tablosu hazırla.

1. Karar kartlarındaki 5 kararı (K1-K5) tabloya al. Karar metnini karttan aynen kopyala, değiştirme.
2. "Cevabı olmayan sorular" bölümündeki 3 soruyu V1, V2, V3 olarak numaralandır. Her biri için bir varsayım öner ve neden varsayım olduğunu yaz. Varsayım önerisi, sahibi onaylayana kadar karar gibi yazılmasın; durum sütununda "Varsayım (onay bekliyor)" yaz.
3. Politika kontrolü: iade-politikasi.md içinde hiçbir kartta geçmeyen kuralları bul. Bunları "Politika (değişmedi)" durumuyla tabloya ekle.
4. Çelişki kontrolü: Bir kart ile politika arasında çelişki varsa "Çelişki" durumuyla işaretle ve iki metni yan yana yaz. Karar verme.
5. Karar kartlarında ve politikada olmayan hiçbir kuralı karar olarak yazma.

Tablo sütunları: No | Soru / Konu | Durum (Karar / Varsayım (onay bekliyor) / Politika (değişmedi) / Çelişki) | Metin | Kaynak (K1-K5, V1-V3 veya politika parça no)

Çıktıyı karar-ve-varsayim-tablosu.md olarak ver.
```

**Uyarı**: Bundan sonraki adımlar claude code üzerinden yapılacaktır. Örnek proje şablonunun hazır olması gerekir.

**Görev-2:**

karar-kartlari.md ve karar-ve-varsayim-tablosu.md dosyalarından ve veri dosyalarından kullanıcı hikayeleri oluşturma.

```
/docs/karar-kartlari.md, /docs/karar-ve-varsayim-tablosu.md  ve aşağıdaki veri dosyalarına dayanarak
ModaRota iade servisi için 5 kullanıcı hikâyesi yaz.

Eklenen veri dosyaları:
- data/orders.json: örnek siparişler (orderNo, paidAmount, deliveryDate, personalized)
- data/closed-days.json: kapalı günler listesi

Her hikâye için:
- ID: US-01, US-02...
- Hikâye: "Bir <rol> olarak, <amaç> istiyorum, böylece <fayda>."
- Kabul kriterleri: Given-When-Then biçiminde, en az 2 kriter.
  Örnekler yalnızca siparisler.json ve kapali-gunler.json içindeki sipariş numaralarını ve tarihleri kullanmalı. Kendi tarih veya sipariş uydurma.
- Kaynak: Karar kartı (K1...) veya Varsayım (V1...).
- Varsayım gerektiriyorsa "⚠ Varsayım" etiketi ekle.

Kısıtlar:
- Karar kartlarında olmayan hiçbir kuralı kesin kural gibi yazma.
- Veri dosyalarındaki bir tarih veya sipariş hikâyeyle uyuşmazsa "Tutarsızlıklar"
  bölümünde belirt.

Çıktı biçimi:
- Tek bir Markdown dosyası olarak ver, dosya adı: docs/hikayeler.md
- Yapı: başlık, hikâyeler (US-01...), en sonda "Tutarsızlıklar" bölümü.
```

**Görev-3:** İş Analistinden aldığımız User Story üzerinden Spec.md dosyasını Oluşturma (Developer)

```
Aşağıdaki dosyaları oku:
- docs/hikayeler.md
- docs/karar-kartlari.md
- docs/iade-politikasi.md

Bu dosyalardan docs/spec.md oluştur. Kurallar:
- Her hikâye için bir bölüm aç: numara, başlık, kaynak (K/V numarası), ⚠ etiketi varsa
  onu koru, Given-When-Then kriterleri.
- Hikâyedeki her kuralın karar kartında (K1–K5) karşılığını kontrol et. Karşılığı
  yoksa kuralı kesin kabul etme; "Açık sorular" bölümüne yaz.
- V1–V3 varsayımlarını kesin kural gibi yazma, "Varsayım" olarak işaretle.
- Eksik kabul kriterlerini kendin uydurma. Tespit ettiğin boşlukları
  "Eksik kriterler" listesinde ayrı tut.
- Hikâyedeki tarih veya sipariş verisi docs/../data/ dosyalarıyla uyuşmuyorsa
  "Tutarsızlıklar" bölümünde belirt.
- Kod yazma, yalnızca docs/spec.md dosyasını oluştur.
- Bitince dosyayı yaz ve kısa bir özet ver.
```

**Görev-4:** User Story'de eksik kabul kriteri varsa /acceptance-criteria komutu ile spec üretimi\*\*

Analistin hikâyeleri geliştiriciye gönderir. Geliştirici bir hikâyenin sınır değer kriteri eksikse şunu çalıştırır:Şuan 

```
/acceptance-criteria Kişiye özel üretilen ürünler iade edilemez.
```

```
`doc/spec.md` dosyasına yeni spec'i ekle.
```

## 2. User Storyden Spec oluşturma ve Kod Geliştirme

**Görev-1: Proje İskeleti Oluşturma**

Plan mode'a geçin (arayüzün gösterdiği şekilde). Prompt:

```
/plan
```

```
CLAUDE.md, docs/spec.md ve csharp-aspnet-standartlari skill'ini oku.
Bu proje için boş bir iskelet kurma planı hazırla. Henüz dosya oluşturma.

İskelet şunları içersin:
- src/ReturnService (ASP.NET Core Web API), Domain/ ve Endpoints/ klasörleriyle
- tests/ReturnService.Tests (xUnit), src projesine referansla
- data/ klasöründeki JSON dosyalarını okuyan basit bir sipariş ve kapalı gün kaynağı

İş kuralı kodu yazma, yalnızca iskelet. Planın sonunda iskeleti doğrulamak için çalıştıracağın komutları yaz.
```

```
/model claude-sonnet-5-5
/effort

Planı onayladım. İskeleti kur. Sonunda dotnet build ve dotnet test komutlarını
çalıştır ve sonucu özetle. /effort medium /model sonet 5.5
```

**Beklenen çıktı:** İki proje, bir solution, `dotnet build` başarılı, `dotnet test` çalışıyor (henüz test yok ya da boş). Sipariş ve kapalı gün kaynağı JSON dosyalarını okuyor.

**Takılma:** .NET SDK yoksa Claude Code komutu çalıştıramaz. Eğitimden önce her bilgisayarda `dotnet --version` kontrol edin.

**Kontrol listesi (Adım 4):**

- [ ] Skill'in kurallarını Claude özetledi
- [ ] Plan okunup onaylandı
- [ ] dotnet build başarılı

---

**Görev-2: Spec'ten Kod Üretimi**

**Amaç:** Given-When-Then kriterlerini hedef alarak iş kuralı kodunu küçük adımlarla yazdırmak.

**"Given-When-Then'i koda nasıl dökeriz?"**

| Kriter satırı                        | Kodda karşılığı                           |
| ------------------------------------ | ----------------------------------------- |
| Given (teslim tarihi, kapalı günler) | Metoda verilen girdiler / testte hazırlık |
| When (talep tarihi, işlem)           | Çağrılan iş kuralı metodu                 |
| Then (kabul, son tarih 17.03)        | Metodun döndürdüğü değer / Assert         |

Yani her kabul kriteri hem kodun **hedefini** hem testin **iskeletini** verir. Bu adımda kriteri hedef olarak verirsiniz, Adım 7'de teste çevirirsiniz.

**Adım 1: US-01 Spec için Plan Çıkarma — (Geliştirici, plan mode)**

```
docs/spec.md, docs/karar-kartlari.md ve csharp-aspnet-standartlari skill'ini oku.

Kapsam: yalnızca US-01 hikayesi planla. Diğer hikâyeleri planlama.
Bu adımda test yazma; testler daha sonra /gwt-test US-01 ile üretilecek.

Plan modunda, henüz kod yazma:
1. Son iade tarihi hesabı: Domain/ altında sınıf ve metod imzası. Hesap K1'e göre:
   teslim tarihi + 14 gün, kapalı günler kadar uzar. Tarihler metoda parametre olarak
   gelsin, DateTime.Now kullanılmasın. Kapalı günler data/kapali-gunler.json'dan okunur.
2. Kabul/red kararı için ayrı bir metod. HTTP uç noktası Endpoints/ altında olsun.
   İş kuralı uç noktadan ayrı kalsın.
3. Spec'te olmayan kural ekleme. Sınır değeri (17.03) için spec'te kriter yoksa bunu "önerilen ek kriter" olarak işaretle ve onay iste.
4. Kapsam dışı kalanları listele.
5. Planın sonunda dotnet build komutunu beklenen sonucuyla yaz.
```

**Adım 2: Api Test**

Uygulamayı çalıştırın (`dotnet run --project src/ReturnService`) ve şu isteği gönderin (kullandığınız araç Swagger, curl veya .http dosyası olabilir):

```
curl POST /returns/window-check
```

```json
{
	"orderNo": "S-1001",
	"requestDate": "2026-03-17",
}
```

Expected response: `status: Accepted`, `lastReturnDate: 2026-03-17`, `refundAmount: 240`, `shippingFeeBearer: Company`.

Send the same request with `requestDate: 2026-03-18`: `status: Rejected`.

## 3. Subagentlar ile Çalışma

Claude Code’un tek bir sohbette her işi yapması yerine, belirli bir iş için ayrı bir uzman asistan çağırabilmesine sub agent denir. Her sub agent kendi bağlam penceresinde çalışır, kendi araç izinlerine sahiptir ve sonunda ana sohbete yalnızca özetini döndürür.

### Neden kullanılır?

1. **Bağlam temiz kalır.** Uzun bir test çıktısı ya da çok sayıda dosya ana sohbeti şişirmez. Ana sohbet kararlara odaklanır.
   İşler paralel yürür. Bir sub agent test yazarken, ana sohbetten başka bir işe devam edebilirsiniz.
2. **Rol ayrılığı sağlanır.** Yazan ile inceleyen farklı olduğunda, kendi işini kendisi onaylamaz. Bu, Gün 2'de “testi koda uydurma” sorununu azaltır.
3. **Yetki sınırlanır.** Bir sub agent’a yalnızca ihtiyacı olan araçları verebilirsiniz. Örneğin inceleme yapan bir ajan dosyaları değiştirmek zorunda değildir.

### Agent 1: code-reviewer

**Amaç:** Ayrı bir bağlamda çalışan bir inceleyici ile kodu spec kod üretimini kontrol etmek.

**Görev-1: Code Review Agent Çalıştırma**

```
code-reviewer subagent'ını kullan. src/ klasöründeki kodu docs/spec.md'deki US-01'e göre incele.
```

**Beklenen çıktı:** Bulgu tablosu (dosya, bulgu, önem, ilgili US, öneri) ve "spec'e uygun olanlar" özeti. Tipik bulgular: hata durumunun eksikliği (geçersiz tarih), sihirli sayı (14), uç noktada iş kuralı sızması, spec'te olmayan alan.

```
Bulgu 1 için önce plan sun
```

**Görev-2 Bulguları değerlendirin**

İş analisti bulguları spec'e göre okur ve her biri için şunu işaretler: **Gerçek hata / Spec'te yok / Tercih meselesi.**

**Görev-3 Bulguları Düzelt**

```
code-reviewer'ın Yüksek önemli bulgularını düzelt. Orta ve Düşük olanlara dokunma.Her düzeltmeyi hangi bulguya bağlı olduğunu belirterek açıkla. Bitince dotnet build çalıştır.
```

**Kontrol listesi (Adım 6):**

- [ ] Subagent'ı çalıştırdım ve bulgu tablosunu aldım
- [ ] Her bulguyu "gerçek / spec'te yok / tercih" olarak işaretledim
- [ ] Yüksek önemli bulguları düzelttim

**Sık yapılan hata:** Her bulguyu körü körüne düzeltmek. Bazıları spec'te olmayan bir istek olabilir.

---

### Agent 2: test-engineer

**Amaç:** Spec'teki her kabul kriterini testi yazılmış, çalıştırılmış bir kontrol hâline getirmek.

**Eğitmen anlatımı:** Given-When-Then → Arrange-Act-Assert eşlemesini gösterin. Örnek (US-01'in 17 Mart kriteri):

```csharp
// US-01, kriter 1: 17.03'te talep kabul edilir
[Fact]
public void US01_Talep17Mart_Kabul()
{
    // Given: teslim 01.03.2026, depo 05.03 ve 06.03'te kapalı
    var teslim = new DateOnly(2026, 3, 1);
    var kapaliGunler = new[] { new DateOnly(2026, 3, 5), new DateOnly(2026, 3, 6) };
    var hesaplayici = new IadeSureHesaplayici();

    // When: son iade tarihi hesaplanır
    var sonTarih = hesaplayici.SonIadeTarihiHesapla(teslim, kapaliGunler);

    // Then: son iade tarihi 17.03.2026'dır, 17.03 talebi süre içindedir
    Assert.Equal(new DateOnly(2026, 3, 17), sonTarih);
}
```

Bu bir **örnektir**. Gerçek sınıf ve metot adları Adım 5'te Claude'un yazdığı koda göre değişir.


**Beklenen çıktı:** Her kriter için bir test, adlarda US kodu, bir eşleme tablosu (kriter, test adı, sonuç). `dotnet test` çalıştırılmış olmalı.


**Görev-1 Unit Test Yazdırma**

```
/gwt-test US-01
```

**Görev-2: Unit Test İnceleme**

Test gerçek bir kontrol yapıyor mu?

```
US-01'in testleri için analiz et: kapalı gün sayımı koddan çıkarılırsa (süre
sadece 14 gün olursa) hangi testler kırılır? Kırılmayan test varsa nedenini açıkla ve eksik testi öner. Kodu değiştirme.
```

**Beklenen çıktı:** En az iki test (17.03 kabul, son iade tarihi 17.03) kırılmalı. Kırılmıyorsa model eksik testi önermelidir.

**Kontrol listesi (Adım 7):**

- [ ] Her kriter için test var
- [ ] `dotnet test` çalıştı, sonucu kaydettim
- [ ] "Kırılır mı?" analizini yaptım

---




## 4. Checkpoint Kullanımı

Checkpoint, Claude Code’un her değişiklikten önce oturumun anlık durumunu kaydetmesidir. Bu sayede Claude bir dosyayı değiştirdiğinde, önceki hâline geri dönebilirsiniz.

**Ne işe yarar?**

**Geri alma:** Claude yanlış bir değişiklik yaptıysa, o noktaya dönebilirsiniz. Git commit’ine ihtiyaç yoktur.
**Deneme yapma:** Farklı bir yaklaşım denemek istediğinizde, mevcut hâlinizi bozmadan deneyebilirsiniz.
**Konuşmayı geri alma:** Yalnızca kodu değil, konuşmanın o noktasına da dönebilirsiniz.

**Nasıl kullanılır?**

Claude Code’da her kullanıcı mesajından önce bir checkpoint oluşur. Geri dönmek için Esc tuşuna iki kez basın ya da /rewind komutunu kullanın. Açılan listeden bir noktayı seçin, kod ve/veya konuşma o noktaya döner.

**Dikkat edilecekler:**

1. Checkpoint, Git’in yerine geçmez. Önemli işleri yine commit ile kaydedin.
2. Checkpoint, Claude Code dışında yapılan değişiklikleri (örneğin elle düzenlediğiniz dosyaları) geri almaz.
3. Bash komutlarıyla yapılan değişiklikler her zaman geri alınamayabilir. Bu yüzden Gün 3'te hook’larla Bash yazmalarını da denetliyoruz.

**Görev-1:**

Aşağıdaki promptu göndererek, bilerek bir hatalı kod üretimi yapın. Ve Unit testlerin değiştiğini gözlemleyin. Claude Code tepkisini not edin, değişikliği yaptımı yoksa bizi öncesinde uyardı mı ?

```
İade süresi hesabını değiştir: depo kapalı günler 14 günlük süreye sayılsın, yani kapalı günler süreyi uzatmasın.
```
