# amber_flutter — ứng dụng Flutter cho amber-v4

Flutter app (Dart), client duy nhất của backend amber-v4 (repo riêng). Ứng dụng
cá nhân, 1 người dùng. Chạy chủ yếu dưới dạng **web** (deploy Vercel, dùng trên
Safari iPhone), ngoài ra build được Android/iOS/desktop.

Comment trong code viết tiếng Việt — giữ nguyên thói quen đó.

## Lệnh

```bash
flutter pub get
flutter run -d chrome                                   # API mặc định http://localhost:3000
flutter run --dart-define=API_BASE_URL=https://...      # trỏ backend khác
flutter analyze                                         # phải sạch trước khi commit
flutter test                                            # widget/unit test (test/)
API_BASE_URL=https://... tool/deploy_web.sh             # build web release + vercel --prod
```

Dev local: chạy amber-v4 trước (`npm run dev` :3000).

## Cấu hình

- **`API_BASE_URL`** đọc lúc biên dịch bằng `String.fromEnvironment`
  (`lib/shared/services/api_client.dart`) — phải truyền qua `--dart-define`,
  không có file `.env`. Thiếu thì dùng `http://localhost:3000`.
- `tool/deploy_web.sh` build vào `build/web` rồi rsync sang `deploy/`
  (gitignore, giữ `.vercel/` liên kết project). Header cache nằm ở `web/vercel.json`.

## Kiến trúc

**flutter_riverpod** (state), **dio** (HTTP), **go_router** (điều hướng),
**flutter_secure_storage** (token).

```
lib/
  main.dart
  shared/
    router/app_router.dart    toàn bộ route + redirect đăng nhập
    services/api_client.dart  Dio chung: Bearer, refresh khi 401
    services/token_storage.dart
    providers/auth_provider.dart
    theme/ utils/ widgets/    form_bits.dart = form toàn màn hình dùng chung
  features/<tòa>/
    models/ providers/ services/ screens/ widgets/ utils/
test/                         cấu trúc song song lib/ (features/, shared/)
```

Tòa: `auth`, `du_do` (trang chủ), `nghi_su_duong`, `tang_kinh_cac`, `kieu_lau`, `tra_dinh`.

### Route (`app_router.dart`)

| Tòa | Route |
|---|---|
| Dư Đồ (trang chủ) | `/` |
| Đăng nhập | `/login` |
| Nghị Sự Đường | `/nghi-su-duong`, `/du-an[/:projectId]`, `/finance[/:projectId]`, `/hoc-tap[/:courseId]` — 3 mảng ở **cấp gốc** |
| Tàng Kinh Các | `/tang-kinh-cac`, `/tang-kinh-cac/{sach,tai-lieu,ke-hoach-doc}` |
| Kiều Lâu | `/kieu-lau` |
| Trà Đình | `/tra-dinh`, `/tra-dinh/placement-test`, `/tra-dinh/:sessionId` |

`alert.href` của Kiều Lâu (backend trả) dùng thẳng với `context.go` — đổi path
phải sửa cả amber-v4. `placement-test` phải đứng trước `:sessionId`.

### Xác thực (`api_client.dart`)

- Đăng nhập `/api/mobile/auth/login` → access token (1h) + refresh token (30 ngày,
  xoay vòng), lưu secure storage.
- Interceptor chỉ gắn Bearer cho đúng origin của API (so scheme+host+port).
- 401 → refresh **một lần dùng chung** cho mọi request đang chờ (refresh token
  dùng xong bị xoá), rồi retry. Server từ chối refresh → xoá token, router về
  `/login`; lỗi mạng thì giữ token.

## Quy ước

- **Form nhập liệu mở bằng `showFinanceSheet` + `FinanceSheetBody`**
  (`shared/widgets/form_bits.dart`), không dùng `showModalBottomSheet` hay
  `AlertDialog` có ô nhập: trên Safari iOS bàn phím đẩy sheet/dialog khuất màn.
  Không tự cộng `viewInsets`, không `autofocus` (iOS chỉ mở bàn phím khi chạm thật).
- Lỗi API hiện bằng SnackBar hoặc dòng lỗi trong form (`sheetError`);
  `apiErrorMessage(e, fallback)` (`shared/utils/api_error.dart`) lấy `message`
  server trả về, không có thì dùng câu fallback.
- Tiền từ backend là chuỗi — tự parse; hiển thị bằng `formatVnd` (`shared/utils/currency.dart`).
- Giờ Việt Nam: `shared/utils/vn_time.dart`.

## Tính năng đặc thù

- **Ghi âm** (`record`) → POST `/api/tra-dinh/transcribe`.
- **Đọc thành tiếng** (`just_audio`) ← POST `/api/tra-dinh/speak` (WAV Groq, header
  độ dài 0xFFFFFFFF — sửa ở `tra_dinh/utils/wav_header.dart`).
- **Upload** ảnh bìa / tệp (`image_picker`, `file_picker`) → POST
  `/api/tang-kinh-cac/upload` (backend chặn > 4 MB). Mở tệp qua `file_opener`
  (bản io / web riêng).
