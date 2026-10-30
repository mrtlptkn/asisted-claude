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