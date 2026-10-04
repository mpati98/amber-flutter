#!/usr/bin/env bash
# Build Flutter web (release) rồi deploy lên Vercel production.
#   API_BASE_URL=https://amber-v4.vercel.app tool/deploy_web.sh
# deploy/ giữ liên kết project Vercel (.vercel/) qua các lần chạy, vì
# `flutter build` có thể xoá build/web.
set -euo pipefail

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "Lỗi: thiếu biến API_BASE_URL (URL backend, vd https://amber-v4.vercel.app)." >&2
  echo "Dùng: API_BASE_URL=https://... tool/deploy_web.sh" >&2
  exit 1
fi
if ! command -v vercel >/dev/null 2>&1; then
  echo "Lỗi: chưa cài Vercel CLI (npm i -g vercel)." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

# API_BASE_URL được đọc lúc biên dịch (String.fromEnvironment) — phải qua --dart-define.
flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"

mkdir -p deploy
rsync -a --delete --exclude .vercel build/web/ deploy/

cd deploy
vercel --prod
