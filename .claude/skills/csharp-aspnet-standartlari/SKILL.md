---
name: csharp-aspnet-standartlari
description: ASP.NET Core Web API ve xUnit ile C# kodu yazarken veya incelerken kullan. Proje yapısı, tarih işleme, doğrulama ve hata kodları içerir.
---

# C# / ASP.NET Core standartları

Adlandırma, test ve güvenlik kuralları `.claude/rules/` altındadır.

## Proje yapısı

- Solution: `ReturnService.slnx`
- `src/ReturnService`: Web API (.NET 9, `net9.0`). İş kuralları `Domain/`, uç noktalar `Endpoints/` klasöründe.
- `tests/ReturnService.Tests`: xUnit testleri.
- İş kuralları (süre, tutar, kargo) ayrı sınıflarda olur ve doğrudan test edilebilir. Uç nokta sınıfında iş kuralı olmaz.

## Kodlama kuralları

- Tarihler için `DateOnly` kullan. `DateTime.Now` ve `DateTime.Today` kullanma. Tarih her zaman parametre olarak gelir.
- İstek ve yanıt modelleri için `record` kullan.
- Girdi doğrulaması uç noktada yapılır: sipariş bulunamazsa 404, geçersiz tarih veya alan 400.
- Sihirli sayıları (ör. 14 gün) adlandırılmış sabit olarak tanımla.

## Komutlar

- Derleme: `dotnet build`
- Test: `dotnet test`
- Biçim: `dotnet format`