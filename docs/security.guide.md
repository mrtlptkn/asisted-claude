# Claude ile Güvenli Çalışma Rehberi

Bu belge, ModaRota İade Servisi'nde Claude ile çalışırken güvenlik açısından nelere dikkat ettiğimizi anlatır. Her önlemin karşılığı `.claude` klasöründe bulunur.

## Özet

| Risk | Önlem | Nerede |
|------|-------|--------|
| Gizli bilgilerin okunması | `deny` kuralları | `.claude/settings.json` |
| Gizli bilgilerin koda/loga yazılması | Güvenlik kuralları | `.claude/rules/security.md` |
| Paydaş belgelerinin değiştirilmesi | `protect-files.sh` hook'u | `.claude/hooks/` |
| İzinlerin atlanması | Bypass ve auto mod kapalı | `.claude/settings.json` |
| Kırık kodla "bitti" denmesi | `test-before-stop.sh` hook'u | `.claude/hooks/` |
| Uzak depoda istenmeyen yazma | GitLab yazma araçları `deny` | `.claude/settings.json` |
| Onaysız değişiklik | Önce plan, sonra kod | `CLAUDE.md`, `CLAUDE.local.md` |

## 1. Gizli bilgi koruması

- Kimlik bilgisi, parola, token, connection string ve gerçek müşteri verisi koda, testlere, loglara ve prompt'a yazılmaz (`rules/security.md`).
- Claude'un şu dosyaları okuması engellenir (`permissions.deny`):
  - `.env`, `.env.*`
  - `secrets/` klasörü
  - `appsettings.json`, `appsettings.Production.json`, `appsettings.Staging.json`
  - Windows ve Linux UserSecrets klasörleri
- Aynı dosyaların `cat` ve `Get-Content` ile okunması da engellenir. Böylece Read aracı kapalıyken komut satırı üzerinden dolanılamaz.
- `dotnet user-secrets` komutları Claude için yasaktır. Gizli değerleri geliştirici kendisi tanımlar.
- Dokümanlarda ve örneklerde yalnızca sahte yer tutucu değerler kullanılır.

## 2. Korunan dosyalar

`docs/karar-kartlari.md` ve `docs/iade-politikasi.md` yalnızca iş analisti tarafından değiştirilir.

- `protect-files.sh`, `Edit|Write|Bash|PowerShell` araçlarından önce çalışır (PreToolUse).
- Edit/Write ile bu dosyalara yazma girişimi engellenir.
- Bash/PowerShell komutunda bu dosya adı ve yazma işareti (`>`, `tee`, `sed -i`, `mv`, `cp`, `rm`, `Set-Content`, `Out-File` vb.) birlikte geçerse engellenir.
- Engellenen işlemde hook `exit 2` ile durur ve Claude'a gerekçeyi bildirir. Değişiklik gerekiyorsa Claude kullanıcıya sorar.

## 3. İzin modları ve allow listesi

- `disableBypassPermissionsMode` ve `disableAutoMode` `"disable"` değeriyle kapatılmıştır. İzin istemleri atlanamaz.
  - `disableBypassPermissionsMode`: `--dangerously-skip-permissions` modunu kapatır. Bu modda Claude onay istemeden komut çalıştırır ve dosya yazar.
  - `disableAutoMode`: Onayların Claude tarafından otomatik geçildiği modu kapatır. Risk değerlendirmesi insanda kalır.
  - Kurumsal önemi:
    - **Denetlenebilirlik:** Dosya yazma, komut çalıştırma ve GitLab işlemleri insan onayından geçer.
    - **Veri koruma:** `deny` kuralları ve hook'lar, onay adımıyla birlikte ikinci savunma katmanı olur.
    - **Prompt injection:** Claude'un okuduğu içerikteki kötü niyetli talimatın sessizce çalıştırılması engellenir.
    - **Tutarlılık:** Takımdaki herkes aynı kurallarla çalışır.
  - Sınır: Bu ayarlar proje düzeyinde bir öneridir. Geliştirici `settings.local.json` veya `--settings` ile değiştirebilir. Kurumsal olarak zorlamak için aynı anahtarlar `managed-settings.json` içine konmalıdır.
- Onaysız çalışabilen komutlar yalnızca `dotnet build`, `dotnet test` ve `dotnet format` komutlarıdır.
- GitLab tarafında yalnızca salt okunur araçlara izin verilir: iş öğelerini ve projeleri listeleme/okuma.
- Merge request kabulü, MR review kaydı, MR kaydetme, commit ekleme ve pipeline kaydetme `deny` listesindedir. Uzak depoyu değiştiren her işlem insan kararıyla yapılır.

## 4. Kalite kapısı (Quality Gate)

`test-before-stop.sh`, Claude cevabını bitirmeden önce (Stop olayı) `dotnet test` çalıştırır. Test kırıksa `exit 2` ile Claude'u geri gönderir. `stop_hook_active` kontrolü sonsuz döngüyü önler. Solution dosyası henüz yoksa hook hiçbir şey yapmaz.

## 5. Çalışma disiplini

- Önce plan, sonra kod. Plan onaylanmadan dosya değiştirilmez.
- Spec'te olmayan kural eklenmez, önce sorulur.
- Her iş kuralı için test yazılır.
- Emin olunmayan durumda tahmin edilmez, tek bir soru sorulur.
- `CLAUDE.local.md` kişiseldir, commit edilmez.

## 6. Ayar katmanları

| Dosya | Kim değiştirebilir? | Ne için? |
|-------|---------------------|----------|
| `~/.claude/settings.json` | Kullanıcı | Kişisel tercihler |
| `.claude/settings.json` | Projeye yazabilen herkes (MR ile) | Takım kuralları |
| `.claude/settings.local.json` | Kullanıcı | Kişisel istisnalar |
| `managed-settings.json` | Yalnızca yönetici | Güvenlik ve uyumluluk politikası |

Öncelik sırası: yönetilen ayarlar > komut satırı > yerel > proje > kullanıcı.

## 7. Bilinen sınırlar

- `.claude/settings.json` bir öneridir. Geliştirici `settings.local.json` veya `--settings` ile değiştirebilir. Zorlayıcı politika için `managed-settings.json` gerekir.
- Hook'lar `sed` ve `grep` ile metin eşleştirir. Dosya adını dolaylı oluşturan komutlar (değişken birleştirme gibi) atlatabilir. Hook, kasıtlı saldırıya karşı değil, kazara hataya karşı korumadır.
- `deny` kalıpları bilinen komut biçimlerini kapsar. Farklı bir araçla okuma mümkün olabilir, bu yüzden gizli bilgiler zaten proje dizininde tutulmamalıdır.
- `.env`, `secrets/`, `appsettings.Production.json`, `appsettings.Staging.json`, `CLAUDE.local.md` ve `.claude/settings.local.json` `.gitignore`'a eklendi. `.gitignore` yalnızca henüz izlenmeyen dosyaları korur. Daha önce commit edilmiş bir dosya git geçmişinde kalır, bu yüzden gizli bilgi hiç commit edilmemelidir.

## 8. Kontrol listesi

- [ ] Koda, teste, loga veya prompt'a gizli bilgi yazmadım.
- [ ] `.env` ve `appsettings*.json` dosyaları commit edilmiyor.
- [ ] `docs/karar-kartlari.md` ve `docs/iade-politikasi.md` dosyalarını değiştirmedim.
- [ ] `dotnet build` ve `dotnet test` geçiyor.
- [ ] Uzak depoya yazan işlemleri kendim onayladım.
