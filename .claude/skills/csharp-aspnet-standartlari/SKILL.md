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
- Veri dosyalarının adları İngilizce olur: `data/orders.json`, `data/closed_days.json`.

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