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
flutter test                                            # widget/unit test (test/); test/integration tự bỏ qua nếu thiếu dart-define
API_BASE_URL=https://api.duangmai.io.vn tool/deploy_web.sh   # build web release + vercel --prod
```

Test hợp đồng với backend thật (`test/integration/nsd_backend_contract_test.dart`) cần
`--dart-define=NSD_API_BASE_URL=… --dart-define=NSD_API_TOKEN=…` và GHI dữ liệu thật (tự dọn). **Chỉ chạy trên backend
dev (Neon dev branch), không bao giờ trỏ vào `https://api.duangmai.io.vn`.**

Dev local: chạy amber-v4 trước (`npm run dev` :3000).

## Cấu hình

- **`API_BASE_URL`** đọc lúc biên dịch bằng `String.fromEnvironment`
  (`lib/shared/services/api_client.dart`) — phải truyền qua `--dart-define`,
  không có file `.env`. Thiếu thì dùng `http://localhost:3000`.
- `tool/deploy_web.sh` build vào `build/web` rồi rsync sang `deploy/`
  (gitignore, giữ `.vercel/` liên kết project). Header cache nằm ở `web/vercel.json`.

## Triển khai production

- Project Vercel `amber-flutter` (alias `amber.duangmai.io.vn`) **không nối Git**: `git push` KHÔNG deploy. Deploy bằng
  `API_BASE_URL=https://api.duangmai.io.vn tool/deploy_web.sh` từ `main` sạch, SAU khi backend amber-v4 đã deploy.
- **Đang chạy** (13/10/2026): `dpl_GcdByVm5Qm17oTRWRKsyimNHwXwZ` (build từ `95162a5`, có ghi buổi tập).
  **Mốc rollback**: `dpl_7udy1WmxgqjXqrE4YpTAMrMqEK7s` (`vercel rollback <id>` hoặc promote từ dashboard).
- Kiểm sau deploy (không đăng nhập, không ghi): `https://amber.duangmai.io.vn` trả 200; `main.dart.js` chứa
  `api.duangmai.io.vn`, không chứa `localhost:3000` (chữ "localhost" đơn lẻ trong code Flutter là bình thường); chuỗi tiếng
  Việt trong bundle bị mã hoá `\uXXXX` nên đừng tìm theo chữ có dấu.
- **Máy này không có thông tin đăng nhập GitHub**: người dùng tự `git push`; đừng cố push hay cấu hình credential.

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

Tòa: `auth`, `du_do` (trang chủ), `nghi_su_duong`, `tang_kinh_cac`, `kieu_lau`, `tra_dinh`, `amber` (chat với amber-brain); feature `du_lieu_huan_luyen` (mục con của Tàng Kinh Các, không dùng chung model/API với sách và tài liệu).

### Route (`app_router.dart`)

| Tòa | Route |
|---|---|
| Dư Đồ (trang chủ) | `/` |
| Đăng nhập | `/login` |
| Amber (chat AI) | `/amber` |
| Nghị Sự Đường | `/nghi-su-duong`, `/du-an[/:projectId]`, `/finance[/:projectId]`, `/hoc-tap[/:courseId]` — 3 mảng ở **cấp gốc** |
| Tàng Kinh Các | `/tang-kinh-cac`, `/tang-kinh-cac/{sach,tai-lieu,ke-hoach-doc}`, `/tang-kinh-cac/du-lieu-huan-luyen[/:logId]` (nhật ký amber-brain, feature `du_lieu_huan_luyen` riêng, gọi `/api/brain-logs` của amber-v4, không gọi brain) |
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
- **Việc hằng ngày + ghi buổi tập** (`features/nghi_su_duong`): `Routine.kind` CHECK (tick) | WORKOUT. Bấm việc WORKOUT đến hạn
  hôm nay mở `WorkoutLogSheet` (`widgets/workout_log_sheet.dart`, qua `showFinanceSheet`): tổng phút (1–1440, bắt buộc) + danh
  sách bài (tên, kiểu đo REPS / SETS_REPS / DURATION, chỉ hiện ô số của kiểu đó), thêm/xoá dòng. Điền sẵn từ `todayLog`, nếu chưa
  có thì từ `lastWorkout` (giữ bài, để trống phút). Lưu = PUT `/api/du-an/routines/:id/logs/:hôm-nay`; nút "Xoá buổi tập" (chỉ khi đã
  có log) = DELETE. Thẻ hiện "30 phút · 4 bài" thay ô tick. Validate ở `utils/workout_form.dart` (`validateWorkoutForm`, giới hạn khớp
  backend); mã lỗi `not_today`, `kind_locked`, `not_scheduled`, validate zod → câu tiếng Việt qua `routineErrorMessage`. Form thêm/sửa
  việc có chọn loại; việc đã có log (thấy trong 7 ngày) thì khoá loại, log cũ hơn thì server trả 409 `kind_locked`. Việc CHECK giữ
  nguyên (tick/bỏ tick, cho phép ngày đã qua ở backend). Test hợp đồng với backend thật: `test/integration/nsd_backend_contract_test.dart`.
