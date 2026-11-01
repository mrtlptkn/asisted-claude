#!/bin/bash
# audit-config-changes.sh
# Görev: Bir ayar dosyası (settings, skills) değiştiğinde kimin, ne zaman, hangi dosyayı değiştirdiğini log dosyasına yazar.
# Ne zaman çalışır: Oturum sırasında bir yapılandırma dosyası değiştiğinde (ConfigChange olayı).
# Not: Bu hook yalnızca kayıt tutar, değişikliği engellemez (her zaman 0 ile çıkar).

# 1) Claude Code'un hook'a gönderdiği bilgi paketini oku (jq gerekmez, sed yeterli)
INPUT=$(cat)

SOURCE=$(echo "$INPUT" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
FILE=$(echo "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
SESSION=$(echo "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# 2) Kim? İşletim sistemi kullanıcısı ve makine adı
WHO="${USERNAME:-${USER:-$(whoami)}}"
HOST=$(hostname)

# 3) Log klasörü: kendi ortamınıza göre değiştirin (ideal olarak merkezi bir log sistemi)
LOG_DIR="${CLAUDE_AUDIT_LOG_DIR:-$HOME/.claude-audit}"
mkdir -p "$LOG_DIR"

# 4) Bir satır JSON olarak ekle
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"user\":\"$WHO\",\"host\":\"$HOST\",\"source\":\"$SOURCE\",\"file\":\"$FILE\",\"session\":\"$SESSION\"}" >> "$LOG_DIR/config-changes.log"

exit 0   # 0 = sadece kayıt, değişikliği engelleme