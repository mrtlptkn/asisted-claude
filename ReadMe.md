# ModaRota İade Servisi - Claude Code Çalışma Notları

İade ve değişim taleplerini alıp iade süresini ve tutarını iş kurallarına göre hesaplayan küçük bir Web API (C# / ASP.NET Core, xUnit). Bu belge, projeyi Claude Code ile geliştirirken kullandığımız yapıyı özetler.

Güvenlik önlemleri için: [docs/security.guide.md](docs/security.guide.md)

## Proje belgeleri

- `CLAUDE.md`: Proje talimatları (commit edilir)
- `CLAUDE.local.md`: Kişisel notlar (commit edilmez)
- `docs/spec.md`: İş kuralları ve kabul kriterleri
- `docs/karar-kartlari.md`, `docs/iade-politikasi.md`: Paydaş kararları ve politika (Claude değiştiremez)

## .claude klasörü

| Yol | Görev |
|-----|-------|
| `settings.json` | İzinler (`allow`/`deny`) ve hook tanımları |
| `rules/naming.md` | Adlandırma kuralları (kimlikler İngilizce, mesajlar ve yorumlar Türkçe) |
| `rules/security.md` | Güvenlik kuralları |
| `rules/testing.md` | Test kuralları |
| `hooks/protect-files.sh` | Korunan belgelere yazmayı engeller (PreToolUse) |
| `hooks/test-before-stop.sh` | Testler kırıkken "bitti" denmesini engeller (Stop) |
| `agents/code-reviewer.md` | Kod inceleme ajanı (kodu değiştirmez) |
| `agents/test-engineer.md` | Kabul kriterlerini xUnit testine çeviren ajan |
| `skills/csharp-aspnet-standartlari/` | C# / ASP.NET Core kodlama standartları |
| `commands/acceptance-criteria.md` | Given-When-Then kabul kriteri yazar |
| `commands/gwt-test.md` | Kabul kriterini xUnit testine çevirir ve çalıştırır |

## Komutlar

```bash
dotnet build
dotnet test
```

## Sık kullanılan Claude Code komutları

| Komut | Ne yapar? |
|-------|-----------|
| `/context` | Konuşma bağlamının ne kadar dolduğunu gösterir |
| `/clear` | Sohbeti tamamen temizler |
| `/compact karar-kartlari ve iade-politikasi` | Bağlamı özetler, belirtilen konulara öncelik verir |
| `/memory` | Bellek dosyalarını görüntüler ve düzenler |

## Bağlam ve bellek

- Her prompt gönderiminde yüklenenler: `CLAUDE.md` ve `.claude/rules/` altında `paths` belirtilmemiş kural dosyaları.
- `CLAUDE.md` ile `CLAUDE.local.md` birlikte varsa kurallar birbirini ezmez, birleştirilir.
- Claude belleğinin konumu: `C:\Users\[USER]\.claude\projects\[PROJE]\memory`

## Gizli bilgiler (user-secrets)

Gizli değerler koda, testlere veya loglara yazılmaz. Geliştirici kendi makinesinde tanımlar. Bu komutlar Claude için yasaktır (`deny`), kendiniz çalıştırın. Aşağıdaki değer sahte bir yer tutucudur:

```bash
dotnet user-secrets init
dotnet user-secrets set "ApiKey" "<GIZLI_DEGER>"
```

## Ayar dosyaları

| Dosya | Kim değiştirebilir? | Ne için? |
|-------|---------------------|----------|
| `C:\Users\[USER]\.claude\settings.json` | Kullanıcı | Kişisel tercihler |
| `.claude/settings.json` | Projeye yazabilen herkes (MR ile) | Takım kuralları |
| `.claude/settings.local.json` | Kullanıcı | Kişisel istisnalar |
| `managed-settings.json` | Yalnızca yönetici | Güvenlik ve uyumluluk politikası |

Öncelik sırası: yönetilen ayarlar > komut satırı > yerel > proje > kullanıcı. Yönetilen bir anahtarı hiçbir kullanıcı dosyası ya da `--settings` geçersiz kılamaz.

### managed-settings.json

Claude Code'u kuran kurumun, geliştiricilerin değiştiremeyeceği kuralları koyduğu ayar dosyasıdır. Yapısı `settings.json` ile aynıdır, önceliği en yüksektir.

Neden gerekir? `.claude/settings.json` bir öneridir. Geliştirici kendi `.claude/settings.local.json` dosyasıyla ya da `--settings` bayrağıyla kuralları değiştirebilir. Kurumsal bir güvenlik politikası için bu yeterli değildir.

| İşletim sistemi | Yol |
|-----------------|-----|
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` veya `C:\ProgramData\ClaudeCode\managed-settings.json` |
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux ve WSL | `/etc/claude-code/managed-settings.json` |

## Çalışma şekli

- Önce plan, sonra kod. Plan onaylanmadan dosya değiştirilmez.
- Herhangi bir işlem (dosya değiştirme, komut çalıştırma, kod yazma vb.) yapmadan önce kullanıcıya sorulur ve onay alınır.
- Spec'te olmayan kural eklenmez, önce sorulur.
- Her iş kuralı için test yazılır.
