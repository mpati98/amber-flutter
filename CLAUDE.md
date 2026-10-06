# amber_flutter — ứng dụng Flutter cho amber-v4

Flutter app (Dart) kết nối tới backend amber-v4. Giao diện cho các tòa: Nghị Sự Đường (projects/tasks/finance/learning), Tàng Kinh Các (tài liệu & highlight), Kiều Lâu (alert & RSS), Trà Đình (luyện tiếng Anh), Hồ sơ (settings).

## Lệnh

```bash
flutter pub get          # cài dependencies
flutter run              # chạy app (cần emulator hoặc thiết bị)
flutter build apk        # build APK
flutter build ios        # build iOS
dart fix --apply         # fix deprecation warnings
```

## Kiến trúc

Dùng **flutter_riverpod** (state management), **dio** (HTTP client), **go_router** (navigation), **flutter_secure_storage** (lưu token).

```
lib/
  main.dart              app entry point
  models/                domain models (project, task, user, etc.)
  providers/             Riverpod providers (API calls, state)
  screens/               UI screens (tòa-specific)
  widgets/               reusable UI components
  services/              API service (Bearer token qua dio interceptor)
```

Không có tests, kiểm chứng bằng run app trên emulator.

## API Communication

- **Base URL**: từ env, `NEXT_PUBLIC_API_URL` (lấy từ amber-v4 hoặc hardcode local)
- **Auth**: access token từ `/api/mobile/auth/login`, lưu secure storage
- **Refresh**: access token sống 1h, refresh token xoay vòng (30 ngày)
- **Header**: `Authorization: Bearer <token>` (dio interceptor)
- **Error handling**: 401 → logout & redirect login, 4xx/5xx → show toast

## Môi trường

```bash
# .env (không commit)
NEXT_PUBLIC_API_URL=http://localhost:3000  # local amber-v4
# hoặc production: https://api.duangmai.io.vn
```

Dev local: chạy amber-v4 trước (`npm run dev` :3000), sau đó flutter connect.

## Tòa chính

| Tòa | Chức năng | Route |
|---|---|---|
| Nghị Sự Đường | Projects, tasks, finance, learning | `/du-an`, `/task/<id>`, `/finance/<id>`, `/hoc-tap/<id>` |
| Tàng Kinh Các | Sách, tài liệu, highlights | `/documents`, `/highlights` |
| Kiều Lâu | Alerts & RSS feeds | `/alerts` |
| Trà Đình | English learning (chat, recording, TTS, placement test) | `/tra-dinh` |
| Hồ sơ | User settings | `/profile` |

## Lưu ý

- **Ghi âm**: dùng `record` package; client gửi WAV tới `/api/tra-dinh/transcribe`
- **Phát âm**: dùng `just_audio` + Groq TTS từ backend
- **File**: image_picker + file_picker; upload lên Vercel Blob qua backend (`/api/tang-kinh-cac/upload-blob`)
- **Secure storage**: Flutter Secure Storage để lưu token, refresh token
