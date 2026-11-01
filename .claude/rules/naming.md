# Adlandırma kuralları

Tüm kod kimlikleri (proje, klasör, dosya, namespace, sınıf, metot, özellik, değişken, test adları) İngilizcedir.

- Sınıf, record, arayüz, metot, özellik: PascalCase. Örnek: `ReturnDurationCalculator`, `ReturnRequest`.
- Arayüzler `I` ile başlar: `IOrderSource`, `IClosedDayProvider`.
- Yerel değişken ve parametre: camelCase. Örnek: `orderNo`, `requestDate`.
- Sabitler PascalCase: `ReturnWindowDays = 14`.
- Dosya adı, içindeki ana sınıfın adıyla aynı olur.
- Kimlik adlarında Türkçe karakter (ı, ş, ğ, ç, ö, ü) kullanılmaz.
- Veri dosyalarının adları İngilizce ve kebab-case olur: `data/orders.json`, `data/closed-days.json`.

Türkçe kalan yerler:
- Kullanıcıya dönen mesajlar: `"İade nedeni zorunludur."`
- Yorum satırları.