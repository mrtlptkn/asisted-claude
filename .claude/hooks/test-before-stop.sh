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
 
# 4) Solution dosyasını (.sln veya .slnx) bul. Yoksa (iskelet henüz kurulmadıysa) hiçbir şey yapma
SLN=$(find . -maxdepth 2 -path ./.vs -prune -o \( -name "*.sln" -o -name "*.slnx" \) -print | head -n 1)
[ -z "$SLN" ] && exit 0
 
# 5) Testleri çalıştır
OUT=$(dotnet test "$SLN" --nologo -v q 2>&1)
if [ $? -ne 0 ]; then
  # Bu mesajı Claude okur ve kırık testleri düzeltmeye döner
  echo "dotnet test başarısız. Bitirmeden önce kırık testleri düzeltme sadece neden kırık olduğunu açıkla:" >&2
  echo "$OUT" | tail -n 30 >&2
  exit 2   # 2 = dur, Claude'a geri dön
fi
 
exit 0       # 0 = testler geçti, bitirebilir