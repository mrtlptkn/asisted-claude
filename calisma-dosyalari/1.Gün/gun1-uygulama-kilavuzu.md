# Gün 1 — Claude Temelleri

**Senaryo:** ModaRota — iade ve değişim süreci. 1. ve 2. gündeki atölyeler bu senaryo üzerinden yapılır.
**Kimler için:** İş analistleri ve yazılım geliştiriciler.

---

## Senaryo metinleri (1. ve 2. gün boyunca kullanılacak)

Aşağıdaki iki metin, atölyelerde kullanacağınız tek kaynaktır. Her atölyede ihtiyaç duyduğunuz metni buradan kopyalayın.

### Metin 1 — Yayımlanmış iade politikası (15 parça)

Bu metin ModaRota web sitesinde yayımlanmış politikanın tamamıdır. Atölye 1.3'te parçalar tek tek gönderilecek, Atölye 1.5'te ise tamamı tek seferde kullanılacak.

> **Parça 1/15 — Genel süre:** Satın aldığınız ürünleri teslim tarihinden itibaren 14 gün içinde iade edebilirsiniz. Kişiye özel üretilen ürünler iade kapsamı dışındadır.
>
> **Parça 2/15 — Ürün koşulu:** Ürünün kullanılmamış ve etiketinin sökülmemiş olması gerekir.
>
> **Parça 3/15 — Ambalaj:** Ürün, teslim edildiği orijinal ambalajıyla birlikte iade edilmelidir. Ambalajın zarar görmesi durumunda ayrıca bir hüküm yoktur.
>
> **Parça 4/15 — Talep oluşturma:** İade talebi müşteri hesabı üzerinden veya çağrı merkezi aracılığıyla oluşturulur.
>
> **Parça 5/15 — Talep tarihi:** Talep, 14 günlük süre içinde oluşturulmuş olmalıdır. Talep tarihi, talebin oluşturulduğu tarihtir.
>
> **Parça 6/15 — Anlaşmalı kargo:** Anlaşmalı kargo firması kullanıldığında iade kargo ücreti firmamıza aittir.
>
> **Parça 7/15 — Anlaşmalı olmayan kargo:** Anlaşmalı olmayan bir kargo firması kullanılırsa iade kargo ücreti müşteriye aittir.
>
> **Parça 8/15 — Değişim:** Aynı ürünün farklı beden veya renk talebi, değişim olarak işlenir. Değişim, stokta ürün olması hâlinde yapılır.
>
> **Parça 9/15 — Stok yoksa:** İstenen değişim ürünü stokta yoksa müşteriye iade seçeneği sunulur. Bu durum için bir süre belirtilmemiştir.
>
> **Parça 10/15 — İade tutarı:** Ödenen tutar iade edilir. Kampanyalı veya indirimli ürünler için ayrı bir hüküm bulunmamaktadır.
>
> **Parça 11/15 — Ödeme yöntemi:** İade süresi ödeme yöntemine göre değişebilir. Ödeme yöntemlerine göre süreler ayrıca belirtilmemiştir.
>
> **Parça 12/15 — Hasarlı teslimat:** Müşteri teslim anında hasar fark ederse iade talebi açabilir. Kargo firması hasarlı teslim ettiğinde kargo ücretinin kime ait olacağı belirtilmemiştir.
>
> **Parça 13/15 — Kapalı günler:** Depo kapalı olan günlerin 14 günlük süreye sayılıp sayılmayacağı belirtilmemiştir.
>
> **Parça 14/15 — İtiraz:** İtiraz durumunda müşteri temsilcisi karar verir. Karar için kullanılacak ölçütler yazılı değildir.
>
> **Parça 15/15 — Yürürlük:** Bu politika web sitesinde yayımlandığı tarihten itibaren geçerlidir. Güncelleme tarihi belirtilmemiştir.

### Metin 2 — Çağrı merkezi görüşme notu

> Tarih: 14.03.2026 · Süre: 35 dk · Not tutan: BA · Görüşülen: Elif Arslan (çağrı merkezi yöneticisi)
>
> Müşteri değişim istiyor ama kargo ücretini kim ödüyor bilmiyor. Temsilciler kendi inisiyatifiyle karar veriyor, bu yüzden iki müşteri aynı durumda farklı cevap alabiliyor.
>
> Depo iki gün kapalıydı (kar tatili). O günlerin 14 günlük iade süresine sayılıp sayılmayacağı itiraz konusu oldu. Şu an elle istisna giriyoruz, kaydı tutulmuyor.
>
> Kampanyalı ürünler iade edilebiliyor mu, net değil. Finans "indirimli tutar üzerinden" diyor ama hangi tutar olduğu kampanya tipine göre değişiyor.
>
> Bir de kargo firması hasarlı teslim ettiğinde süreç farklı işlemeli ama bunun yazılı bir kuralı yok.

---

## 1 — LLM nedir?

**Hedef:** Modelin "tahmin ederek" yazdığını ve belirsiz sorularda neden uydurabildiğini görmek.

**Arka plan:** LLM, metindeki bir sonraki parçayı (token) tahmin eder. Bu yüzden akıcı ama her zaman doğru olmayan cevaplar üretebilir. Belirsiz soru, belirsiz cevap getirir.

**Görev 1 (10 dk):** Aynı konuyu iki farklı soruyla sorun. Her soruyu yeni bir sohbette sorun.

- Soru A: `İade talebi nedir?`
- Soru B: `Yüksek hacimli bir e-ticaret sitesi için iade talebinin iş kurallarını üç madde ile açıkla.`

Her iki çıktıyı kaydedin. Hangisi size daha kullanılabilir geldi, neden?

**Görev 2 (15 dk):** Var olmayabilecek bir bilgi sorun (yeni sohbette):

> 2019'da Türkiye'de yürürlüğe giren iade süresi kanununun numarası nedir?

Model cevap verdiyse, cevabın doğrulanabilir olup olmadığını not edin.

**Kontrol listesi**

- [ ] İki çıktıyı da kaydettim
- [ ] Hangisinin daha kullanılabilir olduğunu yazdım
- [ ] Uydurma olabilecek cevabı işaretledim

**Sık yapılan hata:** Model bir cevap verdiği için doğru olduğunu varsaymak. Her önemli bilgiyi kaynağıyla doğrulayın.

**Tartışma:** Hangi iş adımında belirsizlik modele bırakılmamalı?

---

## 2 — Claude Ailesi ve Arayüzler

**Hedef:** Aynı görevi farklı modellerle yaparak hız ve ayrıntı farkını görmek.

**Görev:** Aşağıdaki prompt'u üç modelle, her biri için yeni bir sohbette çalıştırın (Haiku, Sonnet, Opus). Prompt kendi içinde tam bağlam verir, bu yüzden başka bir metne ihtiyaç duymaz: 

**Uyarı:** iade-politikası.md dosyasını bağlama ekleyelim.

```
ModaRota adlı Türk e-ticaret firmasının iade politikasında üç konu açık değildir:
(1) Depo kapalı günlerin 14 günlük süreye sayılıp sayılmadığı,
(2) Kampanyalı ürünlerin hangi tutar üzerinden iade edileceği,
(3) Hasarlı teslimatta kargo ücretinin kime ait olduğu.
Bu üç belirsiz iş kuralını açıkla. Her biri için netleştirici bir soru yaz.
Notta olmayan bir bilgiyi uydurma.
```

Her çıktı için tabloyu doldurun:

| Model  | Süre (sizin hissiniz) | Ayrıntı (1-5) | Doğruluk (1-5) | Not |
| ------ | --------------------- | ------------- | -------------- | --- |
| Haiku  |                       |               |                |     |
| Sonnet |                       |               |                |     |
| Opus   |                       |               |                |     |

**Ekip kararı:** Bu iş için hangi model? Gerekçesini bir cümleyle yazın.

**Kontrol listesi**

- [ ] Üç modelle çalıştırdım
- [ ] Tabloyu doldurdum
- [ ] Ekip kararımı yazdım

---

## 3.Claude Session yönetimi

**Hedef:** Uzun sohbetin neden bozulabildiğini görmek ve oturum devri yapmayı öğrenmek.

**Girdi:** Yukarıdaki **Metin 1 — Yayımlanmış iade politikası**, 15 parça. Parçaları kopyalamadan önce hepsini bir kez okuyun.

**Görev 1 (20 dk):**

1. Yeni bir sohbet açın.
2. Metin 1'in **15 parçasını sırayla, her biri ayrı bir mesaj olarak** gönderin. Her mesajın başına `Parça N/15` yazın.
3. 15. parçadan sonra şu soruyu sorun:

   > Depo kapalıyken 14 günlük süre dolan bir ürün için kişiye özel üretim varsa iade edilebilir mi?

   

4. Cevabı kaydedin. Yanıtın hangi parçalara dayandığını da not edin.
5. Aynı metni tek mesajda, tamamını birden gönderin (yeni sohbet açarak) ve iki cevabı karşılaştırın.

**Görev 2:** Oturum devri: 
(Özet, Kaynak metin ve Project Kullanımı) Üç yöntemi karşılaştırın.

1. Görev 1'deki uzun sohbette aşağıdaki şablonu yapıştırın. Şablon, sorulan soruyu ve verilen cevabı özetin zorunlu bir parçası yapar.

   ```
   Şimdiye kadar konuştuğumuz iade politikası üzerine bir özet çıkar. Şu başlıkları kullan:

   1. Kesin kurallar: Her kuralın yanına hangi parçada geçtiğini yaz.
   2. Sorulan sorular ve verilen cevaplar: Her soruyu ve cevabını aynen yaz, cevabın
      dayandığı parçayı belirt.
   3. Açık kalan konular: Metinde net olmayan noktaları yaz.
   4. Metin dışı çıkarımlar: Kendi yorumunla eklediğin şeyleri ayrıca işaretle.

   Özet, bu konuşmayı hiç görmemiş biri tarafından okunup soruları cevaplanabilecek
   kadar ayrıntılı olsun.
   ```

2. Yeni bir sohbet açın. Önce **Metin 1'in 15 parçasının tamamını** yapıştırın. Özet tek başına yeterli değildir, kaynak metin de bu pencerede olmalıdır.
3. Ardından özeti yapıştırın ve şu soruyu sorun:

   > Depo kapalıyken 14 günlük süre dolan bir ürün için kişiye özel üretim varsa iade edilebilir mi?

4. Cevabı kaydedin ve şu üç koşulu kontrol edin:
   - Parça numarası doğru mu?
   - Metinde olmayan bir bilgi eklenmiş mi?
   - "Kesin cevap veremem" gerekçesi metne dayanıyor mu?

**Görev 3: Project bilgi dosyası**

Project, konuşma geçmişini taşımaz, ama kaynak dosyaları kalıcı tutar. Bu görevde kaynağı konuşmaya yapıştırmak yerine Project'e yüklersiniz.

1. Claude'da bir Project oluşturun (adı: `ModaRota İade Lab`).
2. Project'in bilgi (knowledge) alanına Metin 1'in tamamını bir dosya olarak yükleyin (`iade-politikasi.md`).
3. Project içinde yeni bir sohbet açın. Özet yapıştırmadan, yalnızca şu soruyu sorun:

   > Depo kapalıyken 14 günlük süre dolan bir ürün için kişiye özel üretim varsa iade edilebilir mi? Yanıtını hangi parçalara dayandırdığını belirt.

4. Cevabı kaydedin ve Görev 2'deki iki cevapla karşılaştırın. Üç yöntemi tabloya yazın:

| Yöntem                            | Kaynak nerede?  | Cevap parça numarası içeriyor mu? | Metin dışı çıkarım var mı? |
| --------------------------------- | --------------- | --------------------------------- | -------------------------- |
| Özet + kaynak metin (yeni sohbet) | Yapıştırılmış   |                                   |                            |
| Yalnızca özet                     | Yok             |                                   |                            |
| Project bilgi dosyası             | Project dosyası |                                   |                            |

**Tartışma:** Hangi yöntem kaynağı en güvenilir şekilde taşıdı? Project kullanmak neyi değiştirdi, neyi değiştirmedi? 

**İpucu:** Project, konuşma geçmişini taşımaz. Kararları ve açık soruları yine özetle devretmek gerekir.)

**Beklenen sonuç:** Özet + kaynak metin ve Project yöntemleri, cevabın mantığını ve parça numarasını koruyabilmelidir. Yalnızca özetle yapılan denemede kaynak olmadığı için parça numarası eksik kalabilir ya da metin dışı bilgi eklenebilir. Bu fark, kaynağın neden birlikte taşınması gerektiğini gösterir.

**Kontrol listesi**

- [ ] 15 parçalı ve tek mesajlık cevapları karşılaştırdım
- [ ] 15. mesajdaki soruya verilen cevabın doğruluğunu not ettim
- [ ] Oturum devir özetini yazdım ve yeni sohbette test ettim

**Sık yapılan hata:** Her şeyi tek sohbette sürdürmek. Konu değiştiğinde yeni sohbet açmak context yönetimi açısından daha az maliyetli ve doğru bir çözümdür.

---

## 4.Görüşme Notundan Gereksinim Çıkarma

**Hedef:** Prompt'a rol, bağlam, kısıt ve çıktı formatı eklendiğinde sonucun nasıl değiştiğini görmek.

**Girdi:** Yukarıdaki **Metin 2 — Çağrı merkezi görüşme notu** (tam metin). Prompt'larda bu metni `[GÖRÜŞME NOTU]` yerine aynen yapıştırın.

**Uyarı:** iade-politikasi.md dosyasını bağlama ekleyelim.

**Görev adımları**

1. Yeni bir sohbet açın. Prompt A'yı yazın ve `[GÖRÜŞME NOTU]` yerine Metin 2'yi koyun. Çıktıyı kaydedin.

   ```
   Bu nottan gereksinimleri çıkar.

   [GÖRÜŞME NOTU]
   ```

2. Yeni bir sohbet açın. Prompt B'yi yazın, `[GÖRÜŞME NOTU]` yerine Metin 2'yi koyun. Çıktıyı kaydedin.

   ```
   Rolün: 10 yıllık deneyimli bir iş analisti.

   Bağlam: Türkiye'de faaliyet gösteren orta ölçekli bir e-ticaret firmasının
   iade ve değişim sürecini yeniden tasarlıyoruz. Aşağıdaki not, çağrı merkezi
   yöneticisiyle yapılan görüşmeden alınmıştır.

   Görev: Nottan iş gereksinimlerini çıkar.

   Kısıtlar:
   - Notta açıkça yazmayan hiçbir şeyi varsayma.
   - Varsayım gerekiyorsa ayrı bir başlık altında işaretle.
   - Mevzuat yorumu yapma.

   Çıktı formatı: Markdown tablo. Sütunlar: Gereksinim no | Gereksinim ifadesi |
   Dayandığı cümle | Belirsizlik (Var/Yok)

   [GÖRÜŞME NOTU]
   ```


4. İki çıktıyı yan yana koyun ve karşılaştırma tablosunu doldurun.

| Ölçüt                             | A (zayıf) | B (yapılandırılmış) |
| --------------------------------- | --------- | ------------------- |
| Çıkarılan gereksinim sayısı       |           |                     |
| Kaynak cümle gösterilmiş mi?      |           |                     |
| Uydurulmuş bilgi var mı?          |           |                     |
| Doğrudan spec'e aktarılabilir mi? |           |                     |


**Kontrol listesi**

- [ ] İki çıktıyı da kaydettim
- [ ] Karşılaştırma tablosunu doldurdum
- [ ] Kendi işimden bir örnek için aynı yapıyı denedim

**Sık yapılan hata:** İki prompt'u aynı sohbette art arda çalıştırmak. Model önceki cevabını gördüğü için A ve B  yapı olarak benzer görünebilir. Her prompt yeni sohbette çalıştırılmalı.


---

## 5. As-Is/To-be Analizi

As-is, süreç bugün gerçekte nasıl işliyor sorusunun cevabıdır. To-be, sürecin gelecekte nasıl olmasını istediğimizi anlatan hedef durumdur.

**Hedef:** Belirsiz bir isteği müşteriye gidecek sorulara çevirmek ve bir süreç metninden to-be önerisi çıkarmak.

**Girdi:** Bu görevi yerine getirmek için iade-politikası.md ve  ve Metin 2 (görüşme notu) birlikte bağlama tanımlayın. 


**Uyarı:** Doğru bir as-is süreci için sadece politika metni, procedür (yazılı belge) ve paydaş görüşmeleri (çağrı merkezi, depo, finans) yeterli değildir. Aynı zamanda bu sürece veri ve gözlem (veri kayıtları, itirazlar) dahil edilmelidir. Şuan örnek olarak iade politikası metni ve müşteri görüşme örneği baz alınmıştır. 


**Görev 1:** iade-politikasi.md ve görüsme-metni.md dosyasını bağlama ekleyip aşağıdaki promptu yazın.

```
Aşağıdaki iki kaynağı kullanarak as-is ve to-be analizini hazırla. Sonucu tek bir Markdown dosyası olarak ver. Dosya adı: as-is-to-be-analizi.md

Kaynaklar:
- iade-politikasi.md
- görüşme-notu.md

Dosyanın yapısı şu başlıklarla olsun:

## 1. Yazılı as-is
Politika metninden süreci madde madde çıkar. Her maddenin yanına kaynağını yaz: (İade Politikası, parça no).

## 2. Uygulamadaki as-is
Görüşme notundan, sürecin pratikte nasıl işlediğini madde madde çıkar. Her maddenin yanına kaynağını yaz: (Görüşme Metni).

## 3. Fark tablosu
Politika ile uygulama arasındaki farkları ve çelişkileri bir tabloda göster.
Sütunlar: Konu | Politika | Görüşme Notu | Fark/Belirsizlik

## 4. To-be önerisi
En fazla üç değişiklikle bir to-be öner. Her değişiklik için hangi farkı ya da belirsizliği giderdiğini yaz.

Kurallar:
- Notlarda açıkça yazmayan hiçbir şeyi varsayma.
- Karar verme, yalnızca öner. Kesin kuralları sen belirleme.
- Her maddenin yanında kaynağını belirt.
- Dosyanın başına kaynakların listesini ve analiz tarihini ekle.
```

**Not:** Çıkan sonucu bir sonraki adımda karar-kartlarini üretmek için kullanacağız.

**Görev 2: Karar kartı Oluşturma**

Karar kartları, analizde açık kalan soruların her birinin tek bir kapalı soru olarak yazıldığı, sahibinin (birimin) belirlendiği ve cevabın kaynağıyla birlikte kaydedildiği kısa kayıtlardır. Her kart, bir paydaşın vereceği tek bir karar için kullanılır ve spec, kararlara bu kart numaraları üzerinden dayanır.

as-is-to-be-analizi.md bağlama ekleyip aşağıdaki promptu yazın.

```
Kaynak: as-is-to-be-analizi.md
Durum: Taslak. Karar sütunları sahipler cevap verene kadar boş.

## Karar kartları

| Kart | Soru | Sahip (birim) | Karar | Kaynak |
|---|---|---|---|---|
| K1 | ... | Depo / Finans / Çağrı merkezi / Yazılım | *(boş)* | Politika parça no, Görüşme notu |

Kart numaraları K1'den başlasın. Her kart için:
- Soru: Tek ve kapalı bir soru olsun (evet/hayır ya da tek bir değer sorusu). "Nasıl olmalı?" gibi açık soru değil, "Kapalı günler süreye sayılacak mı?" gibi somut soru yaz.
- Sahip: Yalnızca birim adı yaz. Kişi adı uydurma.
- Karar: Boş bırak. Kendi önerini "Öneri" sütununa değil, sadece kartın altındaki notlara yaz.
- Kaynak: Hangi politika parçasına ya da görüşme cümlesine dayandığını yaz.

## Varsayım listesi

Analizde var ama cevabı belli olmayan, kart olamayacak sorular burada yer alsın. Her biri için:
| Soru | Neden kart değil | Varsayım önerisi | Onaylayacak sahip |
Varsayım önerisi bir öneri olarak yazılsın, kesin kural gibi değil.

## Kapsam dışı

As-is veya to-be'de geçen ama karar gerektirmeyen maddeleri (örneğin yalnızca bilgi amaçlı olanlar) kısaca listele. Gerekçesini bir cümleyle yaz.

Kurallar:
- Analizde açıkça yazmayan bir kuralı karar olarak yazma.
- Aynı soruyu iki kart olarak yazma. Birbirine benzeyen sorular tek karta birleşsin.
- Bir kartın sahibi belli değilse "Sahip: belirlenmedi" yaz, tahmin etme.
- En fazla 10 kart üret. Daha fazlası varsa önceliklendirip ilk 10'u yaz, geri kalanı varsayım listesine geçsin.

```


