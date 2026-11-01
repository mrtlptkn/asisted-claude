---
paths:
  - "tests/**/*.cs"
---

# Test kuralları

- Test sınıfı, test edilen konunun adıyla biter: `ReturnWindowTests`, `ReturnReasonTests`.
- Test metot adı: `US{numara}_{Durum}_{BeklenenSonuç}`. Örnek: `US01_Request17March_Accepted`, `US01_Request18March_RejectedOutOfWindow`.
- Numara spec'teki kullanıcı hikâyesinin numarasıdır. Spec'te olmayan numara uydurma, issue numarası kullan: `Issue2_ReturnReasonTests`.
- Her test Given / When / Then yorum satırlarıyla bölümlenir.
- Sınır değerleri (son gün ve son günden sonraki gün) ayrıca test edilir.
- Testte gerçek tarih değeri kullanılır, rastgele değer değil.
- Beklenen değer spec'ten gelir. Kod değişince test beklentisi kod uysun diye değiştirilmez.