# amber_flutter — ứng dụng Flutter cho amber-v4

Flutter app (Dart), client duy nhất của backend amber-v4 (repo riêng). Ứng dụng
cá nhân, 1 người dùng. Chạy chủ yếu dưới dạng **web** (deploy Vercel, dùng trên
Safari iPhone), ngoài ra build được Android/iOS/desktop.

Comment trong code viết tiếng Việt — giữ nguyên thói quen đó.

## Bàn giao cuối ngày 22/10/2026 (ghi nhận lịch sử; trạng thái hybrid mới ở dưới)

Ba repo cùng `~/Documents/My Workspace/`: `amber_flutter` (repo này), `amber-v4` (backend), `amber-brain` (Python, chạy bằng systemd).

**Đã làm hôm nay**
- amber_flutter (đã push + deploy): `9d93d24` chat Amber + ô nhập tiếng Anh · `f3b70db` `AppBarBack` cho 22 màn · `a2c3b8e` cột "hôm nay" 0 phút ở biểu đồ tuần ·
  docs `bf5628b`, `fee9f14`. Trà Đình học tập (`3a2cf70`…`c6cab78`) cũng lên production hôm nay.
- amber-v4 (đã push + deploy): Trà Đình học tập `3f85734`…`97fb8ad` (migration 0008) · `c7f82cb` `agent_logs.route`/`cloud_model` (0009) · `e957c71` Next 16.3.8 · docs `36e6f84`.
- amber-brain: gemma là mặc định + Groq (chitchat/tutor) + credential guard + log mọi lượt + outbox tách dev/prod (`server_host`) + báo cổng bị chiếm + Modelfile khớp bản cài.
  **CHƯA COMMIT**: 21 file sửa + 15 file mới (nhánh `master`, HEAD `2bd40b4`); service đang chạy thẳng từ working tree đó.

**Production lúc này**
- Web Flutter: xem "Triển khai production" (id + rollback). Backend amber-v4: `dpl_HPsMYszoLZbXzyKTv2pqiGx9v9L8` (code `e957c71`), rollback
  `vercel rollback dpl_6XqURxEW2ak4NZxG1WUizMz8oxMM`; DB Neon production đã áp 10/10 migration (đến 0009), không có nhánh sao lưu cho 0008/0009 (dựa vào PITR).
- amber-brain: user service `amber-brain` (bản cài `~/.config/systemd/user/amber-brain.service` = `amber-brain/systemd/amber-brain.service`), `AGENT_MODE=gemma`,
  `LLM_MODEL=amber-gemma4` (Ollama có amber-gemma4 và qwen3:4b-instruct), cổng 8765 (`0.0.0.0`), `GROQ_API_KEY` trong `~/.config/amber-brain/secrets.env` (EnvironmentFile, 600),
  phiên đăng nhập `~/.config/amber-brain/session-api.duangmai.io.vn.json` (600; làm lại: `cd amber-brain && .venv/bin/python -m amber_brain.login`), `.env` của repo trỏ PROD.
  Kiểm: `curl -s 127.0.0.1:8765/v1/status` → PROD / gemma / amber-gemma4; `journalctl --user -u amber-brain | grep log-push` → đẩy log thành công (22:08, 22:20 sau khi backend lên 0009, không 401).

**Việc tiếp theo (theo thứ tự)**
1. amber-brain: `git status`, `.venv/bin/python run_tests.py` (375 test), rồi commit toàn bộ công việc hôm nay (chưa có commit nào) và push.
2. amber-brain gửi `route`/`cloudModel` trong payload outbox (backend đã nhận từ 0009; hiện route chỉ nằm trong `tool_result`): thêm cột + `_FIELDS` + test.
3. Kiểm `AppBarBack` trên iPhone thật (nhất là sau khi đổi tab Trà Đình). Tuỳ chọn: đổi tab sang `context.replace` để giữ lịch sử; lọc `?route=` ở màn Dữ liệu huấn luyện.
4. Dọn: nhánh Neon `backup-truoc-workout-20261013`; 2 file `docs/*.md` chưa theo dõi ở amber-v4; terminal chat `amber_brain.chat` vẫn dùng agent legacy;
   `scripts/export_dataset.py --local` đọc cả hai host.

**Bẫy đã gặp**
- Cổng 8765 do service giữ; chạy thử bằng tay dùng `BRAIN_PORT=8766` + backend dev (cổng bị chiếm thì server báo rõ và thoát mã 1). Không bao giờ chạy test ghi (`test:brain-logs`, e2e) với production.
- `amber-brain/data/brain.db` dùng chung dev + prod: mỗi dòng `agent_logs` có `server_host`; outbox và sync chỉ xét host đang nối, `unknown` không bao giờ được đẩy — đừng bỏ bộ lọc này.
- Trước MỌI lần push: `git log --oneline origin/main..main` (hôm nay đã có 8 commit Trà Đình + migration 0008 nằm chờ). amber-v4: migrate production TRƯỚC, push SAU (push tự deploy).
  Flutter: push KHÔNG deploy, dùng `tool/deploy_web.sh` từ cây sạch.
- Máy này không có thông tin đăng nhập GitHub và không có `neonctl`: người dùng tự `git push` và tạo/xoá nhánh Neon; `vercel` CLI đã đăng nhập.
- `python` không có trong PATH: dùng `amber-brain/.venv/bin/python`. Không bao giờ in giá trị `.env`/`secrets.env`/token.

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
- **Đang chạy** (22/10/2026): `dpl_HRmzMgqVB3Y3uwoF3CVHqJTuoa6j` (build từ `a2c3b8e`: nút quay lại chung `AppBarBack` cho mọi màn có AppBar + cột "hôm nay" 0 phút của biểu đồ tuần).
  **Mốc rollback**: `dpl_BJRCxCkkH2tYGjkjc5pfE6kqY27P` (build từ `9d93d24`: Trà Đình học tập + chat Amber tiếng Anh); trước nữa `dpl_GcdByVm5Qm17oTRWRKsyimNHwXwZ`
  (`95162a5`, bản 13/10) và `dpl_7udy1WmxgqjXqrE4YpTAMrMqEK7s`. Rollback: `vercel rollback dpl_BJRCxCkkH2tYGjkjc5pfE6kqY27P` (hoặc promote từ dashboard).
- Brain: `tool/deploy_web.sh` chỉ truyền `API_BASE_URL`, nên `BRAIN_BASE_URL` giữ mặc định `http://127.0.0.1:8765` (cổng dịch vụ; 8766 chỉ là cổng chạy thử
  trên máy dev, không đưa vào bản build). Kiểm: bundle chỉ có đúng một URL brain là `127.0.0.1:8765`.
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

### amber-brain hybrid: trạng thái hiện tại

- Màn chat và đầu màn dữ liệu huấn luyện có banner log-push dùng chung (commit `9e4b8a9`). Chỉ cảnh báo khi brain online và `lastError != null` hoặc `pending >= 5`; brain cũ không có `logPush` thì không cảnh báo. Mã lỗi được đổi sang câu thân thiện, chat dùng tiếng Anh và màn dữ liệu dùng tiếng Việt.
- Dữ liệu huấn luyện (`/tang-kinh-cac/du-lieu-huan-luyen`): lọc Tất cả/LOCAL/CLOUD; mỗi dòng hiển thị tuyến và model khi CLOUD, có dấu đã sửa; form cấu trúc cho 9 action PATCH `correctedOutput`, có thể xoá bản sửa (commit `7f17feb`). Backend là nơi duy nhất quyết định eligibility.
- Nợ kiểm thử: chưa có contract test với backend cho PATCH `correctedOutput` và lọc `route`.

### Route (`app_router.dart`)

| Tòa | Route |
|---|---|
| Dư Đồ (trang chủ) | `/` |
| Đăng nhập | `/login` |
| Amber (chat AI) | `/amber` |
| Nghị Sự Đường | `/nghi-su-duong`, `/du-an[/:projectId]`, `/finance[/:projectId]`, `/hoc-tap[/:courseId]` — 3 mảng ở **cấp gốc** |
| Tàng Kinh Các | `/tang-kinh-cac`, `/tang-kinh-cac/{sach,tai-lieu,ke-hoach-doc}`, `/tang-kinh-cac/du-lieu-huan-luyen[/:logId]` (nhật ký amber-brain, feature `du_lieu_huan_luyen` riêng, gọi `/api/brain-logs` của amber-v4, không gọi brain) |
| Kiều Lâu | `/kieu-lau` |
| Trà Đình | `/tra-dinh` (Học tập, 3 tab `?tab=overview\|schedule\|stats`), `/tra-dinh/luyen-tap` (màn luyện AI cũ), `/tra-dinh/placement-test`, `/tra-dinh/hoc-tap/courses[?subjectId=&status=]`, `/tra-dinh/hoc-tap/courses/:courseId`, `/tra-dinh/hoc-tap/wishlist`, `/tra-dinh/:sessionId` |

`alert.href` của Kiều Lâu (backend trả) dùng thẳng với `context.go` — đổi path
phải sửa cả amber-v4. Mọi route con cố định của `/tra-dinh` (`luyen-tap`, `placement-test`, `hoc-tap/...`) phải đứng trước `:sessionId`.

### Xác thực (`api_client.dart`)

- Đăng nhập `/api/mobile/auth/login` → access token (1h) + refresh token (30 ngày,
  xoay vòng), lưu secure storage.
- Interceptor chỉ gắn Bearer cho đúng origin của API (so scheme+host+port).
- 401 → refresh **một lần dùng chung** cho mọi request đang chờ (refresh token
  dùng xong bị xoá), rồi retry. Server từ chối refresh → xoá token, router về
  `/login`; lỗi mạng thì giữ token.

## Quy ước

- **Mọi `Scaffold` có AppBar phải đặt `leading: const AppBarBack(...)`** (`shared/widgets/app_bar_back.dart`; `fallback` = trang cha, mặc định `/`). Flutter chỉ tự thêm mũi tên
  khi Navigator còn trang để pop, mà `context.go` (đổi tab của Trà Đình, xoá query) thay cả stack → màn mất đường về Âm Dương Giới (lỗi trên iPhone 22/10/2026).
  `test/shared/widgets/app_bar_back_test.dart` quét `lib/features` và fail nếu có `appBar: AppBar(` không dùng nó. URL của app là dạng hash (`/#/tra-dinh`), đường dẫn
  thường như `/tra-dinh` luôn 404 trên Vercel — không phải lỗi.

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
- **Học tập của Trà Đình** (`features/tra_dinh/hoc_tap/{models,services,providers,screens,widgets,utils}`): API `/api/tra-dinh/hoc-tap/*`
  (môn, khóa, phần, tổng quan) qua `HocTapApi` (`hocTapApiProvider`). Mọi thao tác ghi đi qua `hocTapActionsProvider` — nó
  invalidate tổng quan, danh sách khóa, chi tiết và `routinesProvider` (routine STUDY tính từ nhật ký học). Tick phần ở chi
  tiết khóa là lạc quan (`StudyCourseDetailNotifier.setSectionDone`, lỗi thì hoàn tác). Mã lỗi backend → tiếng Việt ở
  `utils/hoc_tap_errors.dart`. Fixture JSON thật của backend ở `test/fixtures/hoc_tap/` (chụp từ dev). Màu chữ phụ mới:
  `Theme.of(context).textMuted` / `textFaint` (AppThemeColors). **Thống kê** (`screens/stats_tab.dart`, `widgets/stats_chart.dart`, API `GET /stats`): `?tab=stats&range=7|30|all&subject=<id|all>`;
  biểu đồ cột tự vẽ bằng Container (không thư viện), bucket `week` khi range=all > 92 ngày; So với kế hoạch + Cả lộ trình từ `overallDeltaDays`.
  Tab Lịch nhớ view + date trong `scheduleNavProvider` khi chuyển tab. Mọi màn tải dữ liệu dùng `AsyncValue.settled` (`utils/async_view.dart`):
  chưa có giá trị mà có lỗi → hiện lỗi + Thử lại ngay, không kẹt khung chờ khi Riverpod tự thử lại. "Thiếu lý do" của Lịch chỉ dựa vào `needsReason` của server.
  **Lịch** (`screens/schedule_tab.dart`, API `GET /schedule` ≤ 62 ngày): `?tab=schedule&view=week|month&date=YYYY-MM-DD` (mặc định tuần chứa hôm nay);
  tuần = banner so kế hoạch gốc + `ScheduleDayRow` mỗi ngày; tháng = lưới thứ Hai–Chủ nhật (`utils/schedule_range.dart: monthGrid`, 35 hoặc 42 ngày),
  bấm ô → bottom sheet cùng `ScheduleDayRow`. Lỗi tải hiện ngay (kể cả khi Riverpod đang tự thử lại) kèm nút Thử lại. `studyScheduleProvider` nằm trong danh sách invalidate sau mọi mutation.
  **Ghi buổi học** (`widgets/log_sheet.dart`, `showLogSheet`): chỉ hôm nay; mở từ thẻ Hôm nay, chi tiết khóa hoặc `/tra-dinh?openLog=1&subjectId=…`
  (shell mở Tổng quan, mở sheet một lần rồi xoá query). Tổng "đã ghi + đang nhập" < mục tiêu mới hiện công tắc dừng + lý do (`ReasonPicker`);
  sửa / xoá buổi hôm nay từ thẻ Hôm nay. Ngày thiếu lý do: `missing_reason_sheet.dart` (từng ngày, cũ trước).
  Test hợp đồng với backend thật: `test/integration/hoc_tap_backend_contract_test.dart` (cùng `--dart-define` như nsd).
- **Routine kind STUDY** (nhãn "Học"): `Routine.isStudy`; thẻ `widgets/study_routine_row.dart` — vòng tiến độ, "X / Y phút · chuỗi N ngày", không tick;
  bấm → `/tra-dinh?openLog=1&subjectId=…`; `pendingReasonDates` → hàng "Thiếu lý do" mở sheet lý do. Form việc hằng ngày cho tạo loại Học
  (chọn môn có mục tiêu và chưa có routine STUDY; sửa thì khoá loại, đổi môn được).
- **Việc hằng ngày + ghi buổi tập** (`features/nghi_su_duong`): `Routine.kind` CHECK (tick) | WORKOUT. Bấm việc WORKOUT đến hạn
  hôm nay mở `WorkoutLogSheet` (`widgets/workout_log_sheet.dart`, qua `showFinanceSheet`): tổng phút (1–1440, bắt buộc) + danh
  sách bài (tên, kiểu đo REPS / SETS_REPS / DURATION, chỉ hiện ô số của kiểu đó), thêm/xoá dòng. Điền sẵn từ `todayLog`, nếu chưa
  có thì từ `lastWorkout` (giữ bài, để trống phút). Lưu = PUT `/api/du-an/routines/:id/logs/:hôm-nay`; nút "Xoá buổi tập" (chỉ khi đã
  có log) = DELETE. Thẻ hiện "30 phút · 4 bài" thay ô tick. Validate ở `utils/workout_form.dart` (`validateWorkoutForm`, giới hạn khớp
  backend); mã lỗi `not_today`, `kind_locked`, `not_scheduled`, validate zod → câu tiếng Việt qua `routineErrorMessage`. Form thêm/sửa
  việc có chọn loại; việc đã có log (thấy trong 7 ngày) thì khoá loại, log cũ hơn thì server trả 409 `kind_locked`. Việc CHECK giữ
  nguyên (tick/bỏ tick, cho phép ngày đã qua ở backend). Test hợp đồng với backend thật: `test/integration/nsd_backend_contract_test.dart`.
