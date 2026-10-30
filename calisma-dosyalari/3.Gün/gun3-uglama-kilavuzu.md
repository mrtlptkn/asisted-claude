# Gün 3 — Hook'lar ve GitLab MCP ile Uçtan Uca Üretim Süreci

**Uygulama Kılavuzu**

Bu kılavuz iki şeyi bir arada anlatır:

1. **Hook'lar:** Claude'un yapmaması gerekeni engelleyen küçük kontrol betikleri.
2. **GitLab + MCP:** Claude Code'un GitLab'da issue açıp, kodu yazıp, merge request (MR) açtığı, ama **son kararı insana bıraktığı** bir süreç.

Bu klavuz uçtan uca calude ile üretim sürecini adım adım bir akış halinde uygulayabilmeniz için yazıldı. Her adımda kodları **nerede** çalışacağınız köşeli parantezle yazılı:

- **[Terminal]**: komut satırı (Windows'ta Git Bash)
- **[Claude Code]**: `claude` yazıp açtığınız Claude Code ekranı
- **[GitLab]**: tarayıcıda GitLab sayfası

---

## İçindekiler

1. Bugün ne yapacağız? (akış özeti)
2. Ön hazırlık
3. **Bölüm A:** Hook'lar
4. **Bölüm B:** MCP nedir, neden önemli, GitLab'a nasıl bağladık?
5. **Bölüm C:** Claude Code MCP ve GitLab ile uçtan uca kod üretim süreci (6 adım)
6. Sorun giderme
7. Ek: betik dosyaları ve ayarlar

---

## 1. Bugün ne yapacağız? (akış özeti)

Gün 2'de süreci elle yönettik. Bugün aynı süreci Claude Code ile **otomatikleştiriyoruz**, ama güvenlik frenlerini koyarak.

| Adım | Ne yapıyoruz?                                                 | Kim yapar?             | Nerede görünür?            |
| ---- | ------------------------------------------------------------- | ---------------------- | -------------------------- |
| 0    | Hook'ları kurmak (korumalı dosya + "bitti demeden test")      | Siz                    | `.claude/` klasörü         |
| 1    | Testleri çalıştıracak **pipeline** (`.gitlab-ci.yml`) kurmak  | Siz                    | GitLab → Build → Pipelines |
| 2    | Claude'un MR'ı **birleştirmesini ve onaylamasını** yasaklamak | Siz                    | `.claude/settings.json`    |
| 3    | Kullanıcı hikâyesinden **issue açmak**                        | Claude Code (MCP)      | GitLab → Plan → Issues     |
| 4    | Issue'yu çekip **plan → kod → test** yapmak                   | Claude Code + hook'lar | Yerel proje, yeni branch   |
| 5    | **Commit, push ve MR** açmak                                  | Claude Code (MCP)      | GitLab → Merge requests    |
| 6    | Pipeline sonucunu görüp MR'ı **inceleyip birleştirmek**       | **Siz (analist)**      | GitLab, MR sayfası         |

**Tek cümlede:** Claude Code işin büyük kısmını yapar, **onay ve merge her zaman insanda kalır.**

---

## 2. Ön hazırlık

Başlamadan şunlar hazır olmalı:

- [ ] Gün 2'den kalan proje (`iade-app-lab`) bilgisayarınızda ve **GitLab'a push edilmiş**.
- [ ] `dotnet --version` bir sürüm gösteriyor (projeler **.NET 9** hedefliyor).
- [ ] `git --version` çalışıyor.
- [ ] Claude Code kurulu (`claude --version`).
- [ ] Windows kullanıyorsanız **Git Bash** kurulu (hook betikleri `bash` ile çalışır): `bash --version`.
- [ ] Bir GitLab hesabı ve proje.

> Eğitimde kullandığımız tüm veriler hayalidir. Gerçek müşteri verisi kullanmayın.

---

# BÖLÜM A — Hook'lar

## A1. Hook nedir?

**Tek cümle:** Hook, Claude bir şey yapmadan önce ya da yaptıktan sonra **kendiliğinden çalışan küçük bir kontrol betiğidir.**

**Benzetme:** Kapıdaki güvenlik görevlisi. Claude içeri girmek ister, görevli kimliğe bakar. Uygunsa geçirir, değilse "olmaz, şu nedenle" der. Claude gerekçeyi okur ve davranışını değiştirir.

**CLAUDE.md'den farkı:**

|                  | Ne yapar                           | Claude uymak zorunda mı?               |
| ---------------- | ---------------------------------- | -------------------------------------- |
| CLAUDE.md, skill | Claude'a kuralı **yazarız** (rica) | Hayır. Çoğu zaman uyar, bazen unutur   |
| Hook             | Kuralı **betikle kontrol ederiz**  | Evet. Betik "dur" derse işlem yapılmaz |

## A2. Bu eğitimde iki hook kullanıyoruz

| Hook                    | Ne zaman çalışır?                               | Ne yapar?                                                                   | Neden önemli?                                                           |
| ----------------------- | ----------------------------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| **1. protect-files**    | Claude bir dosyayı **değiştirmeden hemen önce** | Dosya `docs/karar-kartlari.md` ya da `docs/iade-politikasi.md` ise durdurur | Karar kartlarını yalnızca iş analisti değiştirmeli                      |
| **2. test-before-stop** | Claude **"bitti" demek üzereyken**              | `dotnet test` çalıştırır, test kırıksa Claude'u geri gönderir               | Claude "tamamlandı" dediğinde kodun gerçekten çalıştığından emin oluruz |

Claude Code'da bunlardan çok daha fazla hook olayı var (A8'de hepsi listelendi). Biz en çok işe yarayan ikisini seçtik.

## A3. Hook nasıl çalışır? (üç parça)

```
   OLAY                      BETİK                          KARAR
   Claude bir dosyayı  →   protect-files.sh çalışır   →   0 = devam et
   düzenlemek üzere         (dosya yoluna bakar)           2 = dur, nedenini Claude'a söyle
```

1. **Olay:** Hangi anda çalışacağı. Bizde: `PreToolUse` (Claude bir aracı kullanmadan önce) ve `Stop` (Claude bitirmeden önce).
2. **Betik:** Çalışacak küçük program. Claude ona "ne yapmak üzereyim" bilgisini metin olarak gönderir.
3. **Karar:** Betik bir sayı bırakır. **0** = devam et, **2** = dur. Betiğin ekrana yazdığı mesajı Claude okur.

`settings.json` bu üçünü bağlar: "Şu olayda şu betiği çalıştır."

## A4. Hook'ları projeye koyma

Hedef klasör yapısı:

```
iade-app-lab/
└── .claude/
    ├── settings.json
    └── hooks/
        ├── protect-files.sh
        └── test-before-stop.sh
```

Dosyaların içerikleri **Ek 1, Ek 2 ve Ek 3**'tedir. Adımlar:

1. **[Terminal]** Proje klasörüne girin: `cd iade-app-lab`
2. `.claude/hooks/` klasörünü oluşturun, iki `.sh` dosyasını içine koyun.
3. `settings.json` dosyasını `.claude/` altına koyun. Projede zaten bir `settings.json` varsa üzerine yazmayın, yalnızca `"hooks"` bölümünü ekleyin.
4. Kontrol: `ls .claude .claude/hooks`
5. **[Terminal]** `claude` yazıp Claude Code'u açın (açıksa kapatıp yeniden açın).
6. **[Claude Code]** Kaydı kontrol edin:

```
/hooks
```

**Ne görmelisiniz?** İki kayıt: `PreToolUse` altında `Edit|Write|Bash|PowerShell`, ve `Stop`.

> **Güvenlik notu:** Hook'lar sizin yetkinizle çalışan komutlardır. Başkasından aldığınız bir projedeki `.claude/settings.json` içindeki hook'ları Claude Code'u açmadan önce okuyun.

## A5. Hook'ları deneyin

### Hook 1: protect-files

**Deneme A: engellenmesi gereken istek.** **[Claude Code]**:

```
docs/karar-kartlari.md dosyasının en sonuna şu satırı ekle: "deneme satırı". Başka hiçbir şeyi değiştirme, soru sorma.
```

**Beklenen:**

- Dosya **değişmez**.
- Claude dosyanın korumalı olduğunu ve bunu iş analistinin yapması gerektiğini söyler.

**Deneme B: izin verilmesi gereken istek (kontrol).**

```
docs/spec.md dosyasının en sonuna "<!-- hook denemesi -->" satırını ekle.
```

**Beklenen:** Satır eklenir. Hook yalnızca korunan dosyalarda durdurur. Sonra geri alın: **[Terminal]** `git restore docs/spec.md`

### Hook 2: test-before-stop

**Önce** testlerin geçtiğinden emin olun: **[Claude Code]** `dotnet test çalıştır`.

**Görev-1**

```
Koddan ReturnWindowCalculator içindeki ReturnWindowDays sabitini 15 yap. ve dotnet test komutu ile testleri yeniden çalıştır. test-before-stop otomatik olarak devreye girecektir.
```

**Beklenen akış:**


1. Claude hata özetini görür. Testi değiştirmesi yasak olduğu için ya değişikliği geri alır ya da "bu değişiklik spec ile (14 gün) çelişiyor" diye açıklayıp size sorar.

Denemeden sonra geri alın: **[Terminal]**

```
git status
git restore .
```

`git restore .` yalnızca değiştirilmiş dosyaları eski haline döndürür, yeni `.claude/` dosyalarınıza dokunmaz.

> Hook bir kez durdurduktan sonra ikinci "bitti" denemesine izin verir. Bu bir güvenlik freni: Claude sonsuz döngüye girmesin diye.

## A6. İki ders (denemelerden öğrendiklerimiz)

**Ders 1: Bir yolu kapatırsanız Claude başka yol bulabilir.**
Hook'u ilk yazdığımızda yalnızca Claude'un `Edit` ve `Write` araçlarına bakıyordu. Claude dosyayı `Bash` ile yazdı (`printf ... >> docs/karar-kartlari.md`) ve hook'u atlamış oldu. Hook'u `Bash` ve `PowerShell` komutlarına da bakacak şekilde genişlettik.

**Ders 2: Yapay zeka testi koda uydurmaya eğilimlidir.**
`test-before-stop` ilk yazıldığında mesajı "kırık testleri düzelt" idi. Claude kırık testi **testin beklenen değerini değiştirerek** "düzeltti". Çözüm iki parçalı:

1. Hook mesajına açıkça yazdık: "Testler spec'ten üretildi, testi değiştirme; kodu düzelt, değişikliği geri al ya da çelişki varsa sor."
2. `CLAUDE.md`'ye şu kuralı ekleyin:

```
Testler spec'in ifadesidir. Test kırılırsa testi veya beklenen değeri kod uysun diye değiştirme.
Kodu spec'e uydur. Kod ile spec çelişiyorsa önce kullanıcıya sor.
```

**Sınır:** Hook'lar bir **korkuluktur, güvenlik duvarı değil.** Claude bir Python betiği yazıp onunla da dosyayı değiştirebilir. Tam güvence için depo koruması (korumalı branch, zorunlu MR onayı) ve insan incelemesi gerekir. Bölüm C'deki süreç tam olarak bunu yapıyor.



## A7. Tüm hook olayları ve anlamları

Hook = "şu **olay** olunca şu betiği çalıştır". Aşağıdaki liste Claude Code'un resmi dokümanındaki olayları verir. Sürüme göre değişebilir; sizin sürümünüzdekileri `/hooks` gösterir.

**Durdurabilir mi?** = betik `exit 2` ile çıkınca olay engellenir ya da Claude geri gönderilir. "Hayır" ise hook yalnızca bilgi ya da kayıt içindir.

> ⭐ = bu eğitimde kullandığımız iki hook.

### Claude'un çalışma döngüsü (en çok kullanılanlar)

| Olay                 | Ne zaman çalışır?                           | Durdurabilir mi?   | Örnek kullanım                                    |
| -------------------- | ------------------------------------------- | ------------------ | ------------------------------------------------- |
| `UserPromptSubmit`   | Prompt gönderdiniz, Claude henüz işlemedi   | Evet               | Prompt'ta parola ya da TC kimlik no varsa engelle |
| ⭐ `PreToolUse`      | Claude bir **aracı** kullanmadan hemen önce | Evet               | `protect-files`: korunan dosyaya yazmayı engelle  |
| `PostToolUse`        | Araç **başarıyla** çalıştıktan sonra        | Hayır (iş yapıldı) | Dosya yazılınca kodu otomatik biçimlendir         |
| `PostToolUseFailure` | Araç **hata verdikten** sonra               | Hayır              | Hata kaydı tut                                    |
| `PostToolBatch`      | Bir grup araç çağrısı bittikten sonra       | Evet               | Toplu işlem sonrası genel kontrol                 |
| ⭐ `Stop`            | Claude "tamam" demek üzere                  | Evet               | `test-before-stop`: test kırıksa geri gönder      |
| `StopFailure`        | Tur API hatasıyla bitti                     | Hayır              | Hata bildirimi gönder                             |

### İzinler

| Olay                | Ne zaman çalışır?                          | Durdurabilir mi?         | Örnek kullanım                            |
| ------------------- | ------------------------------------------ | ------------------------ | ----------------------------------------- |
| `PermissionRequest` | Bir araç için izin kararı gerekiyor        | Hayır (karar nesnesiyle) | Bazı komutlara otomatik izin ver / reddet |
| `PermissionDenied`  | Otomatik modda bir araç çağrısı reddedildi | Hayır                    | Reddedilenleri kaydet                     |

### Alt ajanlar ve görevler

| Olay            | Ne zaman çalışır?                  | Durdurabilir mi? | Örnek kullanım                    |
| --------------- | ---------------------------------- | ---------------- | --------------------------------- |
| `SubagentStart` | Bir alt ajan başladı               | Hayır            | Hangi ajan ne zaman başladı logla |
| `SubagentStop`  | Alt ajan işini bitirdi             | Evet             | Rapor yazmadan bitmesin           |
| `TaskCreated`   | Görev listesine görev eklendi      | Evet             | Kurala uymayan görevi engelle     |
| `TaskCompleted` | Görev "tamamlandı" işaretlendi     | Evet             | Test geçmeden tamamlanmasın       |
| `TeammateIdle`  | Ajan ekibinde bir üye boşa çıkıyor | Evet             | İleri seviye                      |

### Oturum yaşam döngüsü

| Olay                                 | Ne zaman çalışır?                               | Durdurabilir mi? | Örnek kullanım                             |
| ------------------------------------ | ----------------------------------------------- | ---------------- | ------------------------------------------ |
| `Setup`                              | `--init` ya da `--maintenance` ile başlatılınca | Hayır            | Kurulum işleri                             |
| `SessionStart`                       | Oturum açıldı ya da devam etti                  | Hayır            | Oturum başında proje durumunu Claude'a ver |
| `SessionEnd`                         | Oturum kapanıyor                                | Hayır            | Temizlik, kayıt                            |
| `PreCompact` / `PostCompact`         | Konuşma özetlenmeden önce / sonra               | Evet / Hayır     | Önemli notları özetten önce kaydet         |
| `PreModelSwitch` / `PostModelSwitch` | Model değişmeden önce / sonra                   | Evet / Hayır     | Belirli modele geçişi engelle              |

### Ortam ve yapılandırma

| Olay                                | Ne zaman çalışır?                        | Durdurabilir mi? | Örnek kullanım                    |
| ----------------------------------- | ---------------------------------------- | ---------------- | --------------------------------- |
| `InstructionsLoaded`                | `CLAUDE.md` ya da kural dosyası yüklendi | Hayır            | Yüklenen kuralları denetle        |
| `ConfigChange`                      | Oturum sırasında ayar dosyası değişti    | Evet             | İzinsiz ayar değişikliğini yakala |
| `CwdChanged`                        | Çalışma klasörü değişti                  | Hayır            | Klasöre göre ortam hazırla        |
| `DirectoryAdded`                    | `/add-dir` ile klasör eklendi            | Hayır            | Eklenen klasörü denetle           |
| `FileChanged`                       | İzlenen dosya diskte değişti             | Hayır            | `docs/spec.md` değişince uyar     |
| `WorktreeCreate` / `WorktreeRemove` | Git worktree oluşturuluyor / siliniyor   | Kısmen           | Hazırlık / temizlik               |

### Bildirim, ekran, MCP

| Olay                                | Ne zaman çalışır?                                     | Durdurabilir mi? | Örnek kullanım               |
| ----------------------------------- | ----------------------------------------------------- | ---------------- | ---------------------------- |
| `Notification`                      | Claude Code bildirim gönderdi ("izninizi bekliyorum") | Hayır            | Masaüstü bildirimi / ses çal |
| `MessageDisplay`                    | Claude'un metni ekranda gösterilirken                 | Hayır            | Çıktıyı izle                 |
| `UserPromptExpansion`               | Yazdığınız komut (ör. `/gwt-test`) prompt'a açıldı    | Evet             | Belirli komutları engelle    |
| `Elicitation` / `ElicitationResult` | MCP sunucusu sizden bilgi istedi / siz cevapladınız   | Evet             | İsteği ya da cevabı denetle  |

### Hook'u yazmanın yolları (işleyici türleri)

| Tür          | Ne yapar?                                                                     |
| ------------ | ----------------------------------------------------------------------------- |
| `command` ⭐ | Bir komut ya da betik çalıştırır, kararı çıkış koduyla verir                  |
| `http`       | Olay bilgisini bir web adresine gönderir (şirket içi bir servis karar versin) |
| `mcp_tool`   | Bağlı bir MCP sunucusunun aracını çağırır                                     |
| `prompt`     | Bir Claude modeline "izin ver / verme" diye sorar                             |
| `agent`      | Bir alt ajan dosyaları okuyup koşulu doğrular (deneysel)                      |

**Anlatırken şunu yapın:** Tabloyu ezberletmeyin. Üç soruya indirin: Claude **yapmadan önce** mi (PreToolUse), **yaptıktan sonra** mı (PostToolUse), **bitirirken** mi (Stop) kontrol etmek istiyorum? Gerisi bu üç fikrin farklı anlardaki halidir.

---

# BÖLÜM B — MCP nedir, neden önemli, GitLab'a nasıl bağladık?

## B1. MCP nedir?

**MCP (Model Context Protocol)**, Claude'un dış sistemlerle (GitLab, takvim, e-posta...) konuşmasını sağlayan standart bir bağlantı yoludur. Her sistem Claude'a bir dizi **araç** sunar. Örneğin GitLab, "issue aç", "MR oluştur", "pipeline oku" gibi araçlar verir.

**Benzetme:** Claude'un elleri vardır ama bir şeye uzanamaz. MCP, Claude'a GitLab'a uzanan bir kol takmak gibidir.

## B2. Neden önemli?

- **Kopyala-yapıştırdan kurtarır.** MCP olmadan issue'yu GitLab'dan kopyalayıp prompt'a yapıştırırdınız, sonucu da elle geri taşırdınız. MCP ile Claude issue'yu kendisi okur, MR'ı kendisi açar.
- **Süreç tek yerde toplanır.** İş tanımı (issue), kod (branch), inceleme (MR) ve test (pipeline) aynı akışta, Claude Code'dan yönetilir.
- **İz bırakır.** Claude'un yaptığı her şey GitLab'da görünür: issue, commit, MR, pipeline. Analist ne olduğunu kendi ekranında görür.

## B3. Dikkat edilecekler (güvenlik)

- **Yetki = risk.** MCP ile Claude, sizin hesabınızın yapabildiği şeyleri yapabilir. Bu yüzden **Adım 2'de merge ve onay araçlarını yasaklıyoruz.**
- **Gerekmeyen aracı kapatın.** Yasaklanan (`deny`) araçlar Claude'a hiç gösterilmez.
- **Güvenmediğiniz içerikten sakının.** GitLab'ın kendi uyarısı: MCP araçları, issue ya da yorum içine gizlenmiş talimatlara (prompt injection) açık olabilir. Yalnızca güvendiğiniz GitLab nesneleri üzerinde kullanın.
- **Veritabanına doğrudan bağlamayın.** Bir yapay zekanın canlı veritabanına MCP ile bağlanıp tabloları okuması önerilmez. Bu eğitimde yalnızca GitLab (kod ve iş takibi) örneği var.

## B4. GitLab MCP'ye nasıl bağladık?

GitLab'ın kendi MCP sunucusu vardır. Bağlantı tek komut ve bir tarayıcı onayıyla kurulur.

**1. [Terminal]** Sunucuyu ekleyin:

```
claude mcp remove GitLab -s user

claude mcp add -s user --transport http GitLab https://gitlab.com/api/v4/mcp

```

- `GitLab` sunucunun adıdır. **Adı büyük harfle yazdık, çünkü araç adları bu isimden türer** (Adım 2'de önemli olacak).
- `-s user` sunucuyu bu bilgisayardaki **tüm projeler** için kullanılabilir yapar. Ayar kişisel dosyanızda durur (Windows'ta `C:\Users\<kullanıcı>\.claude.json`), projeye girmez ve GitLab'a push edilmez.
- Kurumsal (self-managed) GitLab kullanıyorsanız `gitlab.com` yerine kendi adresinizi yazın.

**2. [Claude Code]** `claude` ile açın ve:

```
/mcp
```

Listeden **GitLab** sunucusunu seçin. Tarayıcı açılır, GitLab hesabınızla giriş yapıp **izin verin** (OAuth).

**3. [Claude Code]** Tekrar `/mcp` yazın. Şunu görmelisiniz:

```
Status: connected
Auth:   authenticated
Tools:  42 tools
```

**Araçları görmek için:** `/mcp` → GitLab → **View tools**. Bir araca girince tam adını görürsünüz, örneğin `mcp__GitLab__accept_merge_request`.

> **Sorun çıkarsa:**
>
> - GitLab.com'da grubunuzun **MCP sunucu erişimine izin vermesi** gerekebilir (grup ayarlarında).
> - "GitLab" adıyla daha önce bir kayıt varsa `claude mcp add` üzerine yazmaz. `claude mcp list` ile kapsamına bakın, `claude mcp remove GitLab -s local` (ya da `-s user`) ile silin, tekrar ekleyin.
> - Kimlik doğrulama bozulursa `/mcp` → GitLab → **Re-authenticate**.

---

# BÖLÜM C — GitLab ile uçtan uca süreç

Bu bölümdeki örnek iş: **"İade talebinde iade nedeni zorunlu olsun."** Küçük ve izole (Gün 2'den bağımsız): 1 kural, 2 kabul kriteri, 5 test case'den oluşur.

## Adım 1: Pipeline'ı (CI) kurun

**Pipeline nedir?** GitLab'ın, kodunuz her push edildiğinde testleri **otomatik çalıştırdığı** düzenektir. Sonuç yeşil (geçti) ya da kırmızı (kaldı) olur. Testleri çalıştıran makineye **runner** denir. gitlab.com'da hazır runner'lar var, kurulum gerekmez.

**1. [GitLab]** Runner'ı kontrol edin: Proje → **Settings → CI/CD → Runners**. "Enable instance runners for this project" **açık** olmalı.

> Yeni hesaplarda GitLab, hazır runner'ları kullanmak için kimlik doğrulaması (telefon ya da kart) isteyebilir. Pipeline bu nedenle takılırsa önce bunu tamamlayın.

**2.** Proje kök klasörüne (`IadeServisi.slnx` ile aynı yere) **`.gitlab-ci.yml`** adlı dosyayı koyun (içeriği Ek 4'te):

> **Çok önemli:** Dosya adı **nokta ile başlamalı**: `.gitlab-ci.yml`. `gitlab-ci.yml` yazarsanız GitLab dosyayı görmez ve pipeline hiç başlamaz.

**3. [Terminal]**

```
git add .gitlab-ci.yml
git commit -m "CI: dotnet test pipeline"
git push
```

**4. [GitLab]** **Build → Pipelines** ekranında pipeline başlar. Birkaç dakika sonra **yeşil (passed)** olmalı.

**Beklenen:** Yeşil pipeline.

> **Sürüm hatası:** Pipeline `Framework 'Microsoft.NETCore.App', version '9.0.0' was not found` hatası verirse, imaj sürümü projeyle uyuşmuyor demektir. Projeler `net9.0` hedeflediği için dosyada **`sdk:9.0`** imajı kullanılmalı (`sdk:10.0` değil).

## Adım 2: Claude'un merge yapmasını yasaklayın

Hedef: Claude Code MR **açabilsin**, ama **birleştiremesin ve onaylayamasın.** Bu karar analistte kalacak.

**1.** `.claude/settings.json` dosyasına `permissions.deny` bölümünü ekleyin (tam dosya Ek 3'te):

```json
"permissions": {
  "deny": [
    "mcp__GitLab__accept_merge_request",
    "mcp__GitLab__save_merge_request_review"
  ]
},
```

- `accept_merge_request`: MR'ı birleştiren araç.
- `save_merge_request_review`: MR'ı onaylayan araç. Bunu da kapatmazsak Claude kendi açtığı MR'ı kendisi onaylayabilir.
- **Araç adı `mcp__<sunucu adı>__<araç adı>` biçimindedir.** Sunucuyu `GitLab` adıyla eklediğimiz için `mcp__GitLab__...` yazıyoruz. Büyük/küçük harf önemli olabilir. Doğru adı `/mcp` → GitLab → View tools → aracı seçince görürsünüz (**Full name** satırı).

**2. [Claude Code]** Kapatıp yeniden açın, kuralı kontrol edin:

```
/permissions
```

**Deny** sekmesinde iki satır görünmeli.

**3. Deneyin:**

```
GitLab MCP'de accept_merge_request aracını kullanmayı dene (örnek olarak !999 numaralı MR için).
```

**Beklenen:** Claude "böyle bir araç yok" der. Bu **başarıdır**: yasaklanan araçlar Claude'a hiç gösterilmez. Claude'un MR ile ilgili elinde yalnızca `get_merge_request`, `list_merge_requests` ve `save_merge_request` (oluşturma/güncelleme) kalır.

**4. [Terminal]**

```
git add .claude/settings.json
git commit -m "MCP: merge ve onay araclarini yasakla"
git push
```

## Adım 3: Issue açın (Claude Code → GitLab)

İş analisti kullanıcı hikâyesini yazar, Claude Code onu GitLab'da issue'ya çevirir. **[Claude Code]**:

```
GitLab'daki neominal-akademi-group/return-service-lab projesinde yeni bir issue aç.

Başlık: İade talebinde iade nedeni zorunlu olsun

Açıklama:
Kullanıcı hikâyesi: Müşteri hizmetleri çalışanı olarak, iade talebi oluştururken iade nedeninin boş geçilmesini istemiyorum, çünkü iade nedenlerini raporlayabilmem gerekiyor.

Kabul kriterleri:
- AC-1: İade nedeni boş ya da yalnızca boşluklardan oluşuyorsa talep reddedilir ve "İade nedeni zorunludur." mesajı döner.
- AC-2: İade nedeni dolu ise iade talebinin mevcut davranışı değişmez.

Issue'yu açtıktan sonra numarasını ve bağlantısını yaz. Kod yazma, başka bir şey yapma.
```

> Proje yolunu (`neominal-akademi-group/return-service-lab`) kendi GitLab projenizle değiştirin.

**Beklenen:** Claude `save_work_item` aracını kullanır (ilk seferde izin ister, onaylayın) ve `#2` gibi bir issue numarası verir. **[GitLab]** **Plan → Issues** ekranında issue görünür.

## Adım 4: Issue'yu çekin, plan yapın, kodu ve testi yazın

Bu adımda hook'ların ikisi de devrede.

**1. [Terminal]** `main` güncel ve temiz olsun:

```
git checkout main
git pull
git status
```

`git status` "nothing to commit" demeli.

**2. [Claude Code]** **Shift+Tab** ile **plan moduna** geçin (alt çubukta "plan mode" yazar). Plan modunda Claude dosya değiştirmez, yalnızca okur ve plan sunar.

**3. Prompt'u yazın** (issue numarasını kendinize göre değiştirin):

```
GitLab'daki neominal-akademi-group/return-service-lab projesinden #1 numaralı issue'yu çek ve oku.

Kod tabanındaki ilgili dosyalara bak (iade talebi uç noktası ve modeli, mevcut testler).

Sonra kısa bir plan sun: hangi dosyalar değişecek, hangi testler eklenecek. Planda şunlar olsun:
- Değişiklikler feature/issue-1-iade-nedeni adlı yeni bir branch'te yapılacak.
- Her kabul kriteri (AC-1, AC-2) için en az bir test yazılacak.
- docs/ klasöründeki dosyalara dokunulmayacak.
- Commit ve push yapılmayacak.

Onayımı bekle, kod yazma.
```

**4. Planı okuyun.** Kısa olmalı (birkaç dosya, 2-3 test). Claude büyük ihtimalle şunu soracak: _"Spec'te iade nedeni kuralı yok, issue'yu kural kaynağı sayayım mı?"_ Bu soru `CLAUDE.md`'deki "spec'te olmayan kural ekleme, önce sor" kuralından gelir, iyi bir işarettir. Bu örnekte kural kaynağı analistin açtığı issue olduğu için cevap **evet**. Gerçek projede kuralın spec'e de işlenmesi gerekirdi.

Test dosyası adı için şunu isteyin (hikâye numarası uydurmamak için):

```
planı onayla.
```

Planı onaylayın. Claude branch'i açar, kodu ve testi yazar, `dotnet test` çalıştırır. "Bitti" derken `test-before-stop` hook'u testleri bir kez daha çalıştırır.

**5. Yapılan işi kontrol edin. [Terminal]:**

```
git branch
git status
dotnet test
dotnet test --list-tests
git diff
```

**Beklenen:**

- `feature/issue-2-iade-nedeni` branch'indesiniz.
- Değişen dosyalar: `IadeEndpoints.cs`, `IadeTalebiModelleri.cs` ve yeni `Issue2_IadeNedeniTests.cs`. `docs/` ve `US01_...` dosyalarında değişiklik yok.
- Tüm testler geçiyor (örnekte 10: 5 eski + 5 yeni).

## Adım 5: Commit, push ve MR

`main`'e hiçbir şey gitmez. Kod ayrı bir branch'ten MR olarak gider.

**[Claude Code]** Plan modundan çıkın (**Shift+Tab**), `feature/issue-2-iade-nedeni` branch'indeyken:

**Prompt 1: commit mesajı önerisi**

```
Değişiklikleri commit etmeye hazırla:

1. git status ile değişen dosyaların yalnızca plandaki dosyalar olduğunu doğrula.
2. Önce bana kısa bir commit mesajı öner (Türkçe, tek satır, issue numarasını içersin, örnek: "İade talebinde iade nedeni zorunlu (#1)"). Onayımı bekle, henüz commit atma.
```

Claude mesaj önerir. Uygunsa:

```
Evet, bu mesajla commit at ve feature/issue-2-iade-nedeni branch'ini origin'e push et. main'e push etme.
```

**Prompt 2: MR açma**

```
GitLab'da neominal-akademi-group/return-service-lab projesinde bir merge request aç:
- Kaynak branch: feature/issue-1-iade-nedeni, hedef branch: main
- Başlık: İade talebinde iade nedeni zorunlu (#1)
- Açıklama: Issue #1'nin ne istediğini 2 cümleyle özetle, hangi dosyaların değiştiğini ve kaç testin eklendiğini yaz, en sonda tek satır olarak "Closes #1" ekle.
Merge etme ve onaylama; bunlar analistin işi.
MR açıldıktan sonra numarasını ve bağlantısını yaz.
```

**Beklenen:** Claude `save_merge_request` ile `!1` gibi bir MR açar ve bağlantısını verir.

**[GitLab]** **Code → Merge requests**: MR görünür, issue #2'ye bağlıdır ve birkaç saniye içinde **pipeline** otomatik başlar.

> **"Closes #2" ne işe yarar?** MR `main`'e birleştirildiğinde issue #2 **otomatik kapanır.** MR açıkken issue açık kalır, bu normaldir.
>
> GitLab MR'a Duo gibi bir reviewer'ı kendiliğinden atayabilir. Proje ayarından gelir, Claude'un işi değildir.

## Adım 6: Analist olarak inceleyin ve birleştirin

**Bu adımı Claude'a yaptırmıyoruz**, Adım 2'de yasakladığımız şey tam bu. **[GitLab]** tarayıcıda:

1. MR sayfasını açın: Proje → **Code → Merge requests → !1**.
2. **Changes** sekmesinde değişikliklere bakın (3 dosya, küçük diff).
3. **Pipeline'ın yeşil** olduğunu görün.
4. **Merge** düğmesine basın.

**Beklenen:**

- MR **Merged** olur (kaynak branch silinmişse bu da normal).
- Issue #2 **otomatik kapanır.**
- `main` üzerinde yeni bir pipeline başlar ve yeşil biter.

**İsteğe bağlı: süreci Claude'a okutun.** **[Claude Code]**:

```
GitLab'daki neominal-akademi-group/iade-app-lab projesinde MR !1'in ve issue #2'nin son durumunu özetle. main branch'indeki son pipeline'ın sonucu nedir?
```

Claude yalnızca **okur** (`get_merge_request`, `list_pipelines`). Yazma yetkisi gerektiren bir şey yapmaz.

---

# Akış özeti (Gün 3)

| Adım              | Kim yaptı?           | Araç                             | Sonuç                                      |
| ----------------- | -------------------- | -------------------------------- | ------------------------------------------ |
| Hook'ları kurmak  | Siz                  | `.claude/hooks`, `settings.json` | Korumalı dosyalar, "bitti demeden test"    |
| CI kurulumu       | Siz                  | `.gitlab-ci.yml`, GitLab runner  | Pipeline yeşil                             |
| Güvenlik freni    | Siz                  | `permissions.deny`               | Merge ve onay araçları Claude'dan gizlendi |
| Issue açma        | Claude Code          | MCP: `save_work_item`            | Issue #1                                   |
| Plan, kod, test   | Claude Code + 2 hook | Plan modu, `dotnet test`         | 3 dosya, 5 yeni test                       |
| Commit, push, MR  | Claude Code          | `git`, MCP: `save_merge_request` | MR !1 (`Closes #1`)                        |
| Pipeline          | GitLab               | `.gitlab-ci.yml`                 | Yeşil                                      |
| İnceleme ve merge | **Siz (analist)**    | GitLab arayüzü                   | MR birleşti, issue kapandı                 |

## Akışın ana mesajları

- **Claude Code işi yapar, karar insanda kalır.** Merge ve onay teknik olarak Claude'a kapatıldı.
- **Üç güvenlik katmanı birlikte çalışır:** hook'lar (yapmadan önce / bitirmeden önce kontrol), `permissions.deny` (aracı gizleme), MR incelemesi (insan).
- **Claude'un özetine değil gerçek çıktıya bakın.** `git diff`, `--list-tests` ve pipeline sonucu gerçeği gösterir.
- **Testler spec'in ifadesidir.** Claude testi koda uydurmamalı; hook mesajı ve `CLAUDE.md` bunu söyler, MR incelemesi bunu doğrular.
- **Kural kaynağını açıkça belirtin.** Spec'te olmayan bir kural geldiğinde Claude'un "önce sor" demesi istenen davranıştır.

---

# Sorun giderme

| Belirti                                               | Çözüm                                                                                                                                                                                                   |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/hooks` boş                                          | Claude Code'u kapatıp yeniden açın. `settings.json` geçerli JSON mu? (Sondaki virgül ve yorum satırı olmaz.)                                                                                            |
| Hook 1 çalışmıyor, Claude korumalı dosyayı değiştirdi | Claude Code ekranında işlemin başlığına bakın: `Bash(...)` ya da `PowerShell(...)` mi? Matcher `Edit\|Write\|Bash\|PowerShell` olmalı. Dosyayı geri alın: `git restore docs/karar-kartlari.md`          |
| Hook'un neyi gördüğünü anlamak                        | `protect-files.sh` içinde `INPUT=$(cat)` satırının altına geçici olarak `echo "$INPUT" >> "$CLAUDE_PROJECT_DIR/.claude/hook-debug.txt"` ekleyin ve matcher'ı `*` yapın. İş bitince ikisini de geri alın |
| Hook 2 hiç tetiklenmiyor                              | Proje klasöründe `.sln` ya da `.slnx` var mı? `find . -maxdepth 2 -name "*.sln*"`                                                                                                                       |
| Hook 2 çok bekletiyor                                 | Normal: her "bitti" anında `dotnet test` çalışır                                                                                                                                                        |
| Windows'ta betik çalışmıyor                           | Git Bash kurulu mu? `bash --version` yazdırıyor mu?                                                                                                                                                     |
| Hook çalıştı mı görmek                                | `claude --debug` ile açın, hook kayıtları görünür                                                                                                                                                       |
| Pipeline hiç başlamıyor                               | Dosya adı `.gitlab-ci.yml` mi (başında nokta)? Dosya `main` branch'inde mi? `Settings → CI/CD → Runners` açık mı?                                                                                       |
| Pipeline ".NET 9.0 bulunamadı" hatası veriyor         | `.gitlab-ci.yml` içinde `image: mcr.microsoft.com/dotnet/sdk:9.0` olmalı                                                                                                                                |
| Pipeline kimlik doğrulama istiyor                     | gitlab.com hazır runner'lar için telefon/kart doğrulaması gerekebilir                                                                                                                                   |
| `/permissions` deny kuralı tutmuyor                   | Araç adı `/mcp` → GitLab → View tools'taki **Full name** ile birebir aynı mı? (`mcp__GitLab__...`)                                                                                                      |
| GitLab MCP "connected" değil                          | `/mcp` → GitLab → **Re-authenticate** ya da **Reconnect**                                                                                                                                               |
| Claude "accept_merge_request diye araç yok" diyor     | Beklenen davranış. Yasak çalışıyor                                                                                                                                                                      |
| MR açık ama issue kapanmadı                           | Normal. Issue, MR **birleştirilince** kapanır (açıklamada `Closes #2` olmalı)                                                                                                                           |

---

# Ek: dosyalar

## Ek 1: `.claude/hooks/protect-files.sh`

```bash
#!/bin/bash
# protect-files.sh
# Görev: Claude'un karar kartlarını ve iade politikasını değiştirmesini engeller.
# Ne zaman çalışır: Claude bir aracı kullanmadan hemen önce (PreToolUse).
# Kapsam: Edit ve Write araçları + Bash/PowerShell komutları ile yazma girişimleri.

# 1) Claude Code'un hook'a gönderdiği bilgi paketini oku
INPUT=$(cat)

# 2) Hangi araç çağrılıyor? (jq gerekmez, sed yeterli)
TOOL_NAME=$(echo "$INPUT" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

MESAJ="Karar kartları ve politika yalnızca iş analisti tarafından değiştirilir. Değişiklik gerekiyorsa iş analistine sor."

case "$TOOL_NAME" in
  # Okuyan araçlar serbest
  Read|Grep|Glob)
    exit 0
    ;;

  # Komut satırı araçları: komutta korunan bir dosya adı geçiyor VE yazma işareti varsa engelle
  Bash|PowerShell)
    if echo "$INPUT" | grep -Eq 'karar-kartlari\.md|iade-politikasi\.md'; then
      if echo "$INPUT" | grep -Eqi '>|tee |sed +-i|(^|[^a-z])(mv|cp|rm) |Set-Content|Add-Content|Out-File|Remove-Item|Move-Item|Copy-Item'; then
        echo "Engellendi: komut korumalı bir dosyaya yazmaya çalışıyor. $MESAJ" >&2
        exit 2   # 2 = dur, bu işlemi yapma
      fi
    fi
    exit 0
    ;;
esac

# 3) Edit ve Write için: paketin içinden dosya yolunu ayıkla
FILE_PATH=$(echo "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# 4) Windows yollarını düzelt: "\" yerine "/" kullan, arka arkaya gelen "/" işaretlerini teke indir
FILE_PATH="${FILE_PATH//\\//}"
FILE_PATH=$(echo "/$FILE_PATH" | tr -s '/')

# 5) Korunan dosyalar
for p in "/docs/karar-kartlari.md" "/docs/iade-politikasi.md"; do
  if [[ "$FILE_PATH" == *"$p"* ]]; then
    # Bu mesajı Claude okur ve davranışını ona göre değiştirir
    echo "Engellendi: $FILE_PATH korumalı. $MESAJ" >&2
    exit 2   # 2 = dur, bu işlemi yapma
  fi
done

exit 0       # 0 = devam et
```

## Ek 2: `.claude/hooks/test-before-stop.sh`

```bash
#!/bin/bash
# test-before-stop.sh
# Görev: Claude "bitti" demeden önce testleri çalıştırır; test kırıksa Claude'u geri gönderir.
# Ne zaman çalışır: Claude cevabını bitirmek üzereyken (Stop olayı).

# 1) Claude Code'un hook'a gönderdiği bilgi paketini oku
INPUT=$(cat)

# 2) Hook bu turda zaten bir kez durdurduysa bu sefer izin ver (sonsuz döngüyü önler)
if echo "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# 3) Proje klasörüne geç
cd "$CLAUDE_PROJECT_DIR" || exit 0

# 4) Solution dosyasını (.sln veya .slnx) bul. Yoksa hiçbir şey yapma
SLN=$(find . -maxdepth 2 \( -name "*.sln" -o -name "*.slnx" \) | head -n 1)
[ -z "$SLN" ] && exit 0

# 5) Testleri çalıştır
OUT=$(dotnet test "$SLN" --nologo -v q 2>&1)
if [ $? -ne 0 ]; then
  # Bu mesajı Claude okur
  echo "dotnet test başarısız. Testler docs/spec.md'deki kabul kriterlerinden üretildi: testi ya da beklenen değerleri kod uysun diye DEĞİŞTİRME. Kırık test, kodun spec'e uymadığını gösterir. Ya kodu spec'e uygun hale getir ya da yaptığın değişikliği geri al. Değişiklik spec ile çelişiyorsa dur ve kullanıcıya sor. Test çıktısı:" >&2
  echo "$OUT" | tail -n 30 >&2
  exit 2   # 2 = dur, Claude'a geri dön
fi

exit 0       # 0 = testler geçti, bitirebilir
```

## Ek 3: `.claude/settings.json`

```json
{
	"permissions": {
		"deny": [
			"mcp__GitLab__accept_merge_request",
			"mcp__GitLab__save_merge_request_review"
		]
	},
	"hooks": {
		"PreToolUse": [
			{
				"matcher": "Edit|Write|Bash|PowerShell",
				"hooks": [
					{
						"type": "command",
						"command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/protect-files.sh\""
					}
				]
			}
		],
		"Stop": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/test-before-stop.sh\""
					}
				]
			}
		]
	}
}
```

## Ek 4: `.gitlab-ci.yml` (proje kök klasöründe, adı nokta ile başlar)

```yaml
# Her push'ta ve her merge request'te testleri çalıştırır.
# Testler geçerse pipeline yeşil, kırılırsa kırmızı olur.

test:
  image: mcr.microsoft.com/dotnet/sdk:9.0
  script:
    - dotnet test IadeServisi.slnx --nologo
```

---

## Kaynaklar

- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [GitLab MCP sunucusu](https://docs.gitlab.com/user/model_context_protocol/mcp_server/)
