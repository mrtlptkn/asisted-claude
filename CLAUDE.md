# ModaRota İade Servisi

## Amaç

İade ve değişim taleplerini alıp iade süresini ve tutarını iş kurallarına göre
hesaplayan küçük bir Web API.

## Teknoloji

C# / ASP.NET Core Web API (LTS sürüm), xUnit. Veri: data/ klasöründeki JSON dosyaları.
Kodlama standartları: csharp-aspnet-standartlari skill'i.

## Kaynaklar

- İş kuralları ve kabul kriterleri: docs/spec.md
- Paydaş kararları: docs/karar-kartlari.md
- Politika: docs/iade-politikasi.md

## Çalışma kuralları

- Önce plan, sonra kod. Plan onaylanmadan dosya değiştirme.
- Spec'te olmayan bir kural ekleme, önce sor.
- Her iş kuralı için test yaz.
- Gerçek müşteri verisi koda veya loglara yazılmaz.
- Komutlar: dotnet build, dotnet test
