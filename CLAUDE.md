# amber_flutter — ứng dụng Flutter cho amber-v4

Flutter app (Dart), client duy nhất của backend amber-v4 (repo riêng). Ứng dụng
cá nhân, 1 người dùng. Chạy chủ yếu dưới dạng **web** (deploy Vercel, dùng trên
Safari iPhone), ngoài ra build được Android/iOS/desktop.

Comment trong code viết tiếng Việt — giữ nguyên thói quen đó.

## Bàn giao cuối ngày 22/10/2026 (ghi nhận lịch sử; trạng thái hybrid mới ở dưới)

> Các mốc production trong mục này đã cũ. Mốc hiện tại (06/11/2026: Flutter `dpl_BETF3w7jAYTj2X93kpUELbq99WC6`, backend `dpl_8iQN7PQ4QVvsvwzinxXeyCfThF3R`) nằm ở "Triển khai production".

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
flutter run -d web-server --web-hostname 0.0.0.0 --web-port=8080  # thử trên thiết bị cùng mạng LAN
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
- **Đang chạy** (07/11/2026): `dpl_CYHVDdQhxRyUP9pBpZf3hSNLsy3z`, build từ `eabc020` (màn Hôm nay + Thư viện, `LogActivity` chịu giá trị lạ và có PRACTICE, chat luyện AI + sheet ghi phút cuối phiên,
  sửa/xoá buổi luyện AI, "Luyện AI" ở thống kê). Vercel chỉ có MỘT deployment mới sau `dpl_BETF3…`, nên code bước 1 (`3380b61`…`c749444`) và bước 3 (`826530b`…`eabc020`) lên production cùng lúc ở bản này,
  không có bản trung gian chỉ có bước 1. Alias `amber.duangmai.io.vn`. Backend tương ứng: `dpl_GnH36PhDwqLmo6a6pzoXyMHF1wJu` (`ff7dee8`, migration 0012) — xem `amber-v4/CLAUDE.md`.
  **Mốc rollback**: `dpl_BETF3w7jAYTj2X93kpUELbq99WC6` (`9d40500`, kho thẻ 06/11); trước nữa `dpl_CJiB92WeSeYdNi59umAQzB5RNMRy` (`6b553ea`, nhạc 24/10), `dpl_heGz1HrjdSXTtK32WFfokveyCFtL` (`fc4ba11`) và
  `dpl_HRmzMgqVB3Y3uwoF3CVHqJTuoa6j` (`a2c3b8e`, 22/10). Rollback: `vercel rollback dpl_BETF3w7jAYTj2X93kpUELbq99WC6` chạy trong `amber_flutter/deploy` (đã nối project `amber-flutter`); khôi phục:
  `vercel promote dpl_CYHVDdQhxRyUP9pBpZf3hSNLsy3z` (hoặc promote từ dashboard). Chưa thử lệnh rollback; chưa kiểm gói Vercel có cho rollback xa hơn "bản production ngay trước" hay không.
  Lưu ý: lùi về `dpl_BETF3…` (không có PRACTICE) khi backend đã có log PRACTICE vẫn chạy được nhờ `LogActivity.unknown` của bản bước 1, nhưng bản đó coi `PRACTICE` là buổi lạ nên bỏ qua trong danh sách.
- **`API_BASE_URL` phải là `https://api.duangmai.io.vn`.** Ví dụ trong comment đầu `tool/deploy_web.sh` (`API_BASE_URL=https://amber-v4.vercel.app …`) gây hiểu nhầm — đừng chép nó: script không đặt sẵn giá trị nào
  (thiếu biến thì dừng với lỗi). Script cần: `flutter`, `rsync`, Vercel CLI đã đăng nhập, `deploy/.vercel` đã nối `amber-flutter` (deploy/ bị gitignore, giữ liên kết qua các lần chạy), và `main` sạch.
- Brain: `tool/deploy_web.sh` chỉ truyền `API_BASE_URL`, nên `BRAIN_BASE_URL` giữ mặc định `http://127.0.0.1:8765` (cổng dịch vụ; 8766 chỉ là cổng chạy thử
  trên máy dev, không đưa vào bản build). Kiểm: bundle chỉ có đúng một URL brain là `127.0.0.1:8765`.
- Kiểm sau deploy (không đăng nhập, không ghi): `https://amber.duangmai.io.vn` trả 200; `main.dart.js` chứa
  `api.duangmai.io.vn`, không chứa `localhost:3000` (chữ "localhost" đơn lẻ trong code Flutter là bình thường); chuỗi tiếng
  Việt trong bundle bị mã hoá `\uXXXX` / `\xXX` nên đừng tìm thẳng theo chữ có dấu — giải mã các chuỗi thoát trước rồi mới tìm (cách đã dùng ngày 06/11/2026 để thấy "Ôn thẻ hôm nay", "Nhóm khó";
  `main.dart.js` khi đó 4,2 MB, khoảng 1,2 MB khi nén).
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

Tòa: `auth`, `du_do` (trang chủ), `nghi_su_duong`, `tang_kinh_cac`, `kieu_lau`, `tra_dinh`, `amber_brain` (chat với amber-brain: không có route riêng, là khung chat nổi `AmberChatDock` bật từ nút tròn góc phải dưới; Home đã gắn, màn khác gắn khi làm lại theo bộ thiết kế mới); feature `du_lieu_huan_luyen` (mục con của Tàng Kinh Các, không dùng chung model/API với sách và tài liệu).

### amber-brain hybrid: trạng thái hiện tại

- Màn chat và đầu màn dữ liệu huấn luyện có banner log-push dùng chung (commit `9e4b8a9`). Chỉ cảnh báo khi brain online và `lastError != null` hoặc `pending >= 5`; brain cũ không có `logPush` thì không cảnh báo. Mã lỗi được đổi sang câu thân thiện, chat dùng tiếng Anh và màn dữ liệu dùng tiếng Việt.
- Dữ liệu huấn luyện (`/tang-kinh-cac/du-lieu-huan-luyen`): lọc Tất cả/LOCAL/CLOUD; mỗi dòng hiển thị tuyến và model khi CLOUD, có dấu đã sửa; form cấu trúc cho 9 action PATCH `correctedOutput`, có thể xoá bản sửa (commit `7f17feb`). Backend là nơi duy nhất quyết định eligibility.
- Nợ kiểm thử: chưa có contract test với backend cho PATCH `correctedOutput` và lọc `route`.

### Route (`app_router.dart`)

| Tòa | Route |
|---|---|
| Dư Đồ (trang chủ) | `/` |
| Đăng nhập | `/login` |
| Amber (chat AI) | không còn route (đã bỏ `/amber` ngày 12/11/2026) — khung chat nổi `AmberChatDock` |
| Nghị Sự Đường | `/nghi-su-duong`, `/du-an[/:projectId]`, `/finance[/:projectId]`, `/hoc-tap[/:courseId]` — 3 mảng ở **cấp gốc** |
| Tàng Kinh Các | `/tang-kinh-cac`, `/tang-kinh-cac/{sach,tai-lieu,ke-hoach-doc}`, `/tang-kinh-cac/du-lieu-huan-luyen[/:logId]` (nhật ký amber-brain, feature `du_lieu_huan_luyen` riêng, gọi `/api/brain-logs` của amber-v4, không gọi brain) |
| Kiều Lâu | `/kieu-lau`, `/kieu-lau/nhac-thu-nghiem` (trình phát MP3 tạm thời) |
| Trà Đình | `/tra-dinh` (Học tập, 3 tab `?tab=overview\|schedule\|stats`), `/tra-dinh/luyen-tap` (màn luyện AI cũ), `/tra-dinh/placement-test`, `/tra-dinh/hoc-tap/courses[?subjectId=&status=]`, `/tra-dinh/hoc-tap/courses/:courseId`, `/tra-dinh/hoc-tap/wishlist`, `/tra-dinh/hoc-tap/the[?subjectId=]` (kho thẻ), `/tra-dinh/hoc-tap/the/them` (nhập thẻ từ Claude), `/tra-dinh/hoc-tap/the/on` (ôn thẻ), `/tra-dinh/hoc-tap/the/thong-ke` (Nhóm khó), `/tra-dinh/:sessionId` |

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

- **Bộ thiết kế mới (12/11/2026, `design/DESIGN.md` + bản mẫu `design/ref/*.html` ở thư mục workspace)** — đã áp cho Home, Đăng nhập, Nghị Sự Đường,
  Tàng Kinh Các (+ Sách, Tài liệu, Kế hoạch đọc, Dữ liệu huấn luyện và chi tiết), Nghị Sự Đường (+ Dự án, chi tiết dự án, Tài chính, tháng tài chính,
  kế hoạch học tập, chi tiết kế hoạch; Lịch dự kiến / Thống kê chỉ khung chung), Kiều Lâu (+ Nhạc và trình phát mini), Trà Đình (Hôm nay); các màn con khác còn giao diện cũ.
  `ScrollCard` và `ChoiceRow` (form_bits) đã vẽ lại theo bộ thiết kế nên màn cũ dùng chúng cũng gần giống. Màn có nội dung rộng (bảng việc): `DesignPage(stacked: true)`.
  Thêm cho màn con: `DesignButton.primary/outline`, `FrameToolbar` (chip + nút "+ Thêm", xuống dòng khi khung < 420), `designInput(hint)`. Màn mới / màn làm lại dùng:
  - `DesignPage` (`shared/widgets/design_page.dart`): thanh trên (← vàng + tên + logo Amber mở `AccountMenu`) → `overview` → `content(context, DesignSize)` → `hint` / `footer`;
    tự gắn nền, chat nổi `AmberChatDock`, responsive (`DesignLayout` trong `design_tokens.dart`: < 600 dọc lề 14, 600–1024 cột 760, ≥ 1024 cột 1120 với tổng quan rộng 380 bên trái).
  - `OverviewBlock` + `OverviewRow` (nhãn rộng 70 ở Home, 90 ở các tòa; `footer` cho hộp cảnh báo), `ListFrame` + `FrameRows` + `FrameRow` (chữ Hán trong `GlyphCircle`),
    `DesignChipRow` (chip lọc cuộn ngang), `DesignPill`, `DesignProgressBar` — đều ở `shared/widgets/list_frame.dart` / `overview_block.dart`.
  - Màu / chữ: `DesignColors`, `DesignText` (font Gelasio qua google_fonts thay Georgia — Flutter web không dùng được font cài trên máy). Chữ đậm dùng `DesignText.bold`
    hoặc `DesignText.serif(fontWeight: …)`, KHÔNG `copyWith(fontWeight:)` (ra chữ đậm giả).
  - Thông báo: `showToast(context, msg, type: ToastType.error|success|warning|info)` (`shared/widgets/app_toast.dart`) thay SnackBar trắng mặc định.
  - Test của màn dùng `DesignPage`: chữ tên mục thường xuất hiện 2 lần (nhãn tổng quan + dòng trong khung) → tìm trong đúng key của dòng; hàng chip cuộn ngang → `ensureVisible` trước khi bấm.

- **Mọi `Scaffold` có AppBar phải đặt `leading: const AppBarBack(...)`** (`shared/widgets/app_bar_back.dart`; `fallback` = trang cha, mặc định `/`). Flutter chỉ tự thêm mũi tên
  khi Navigator còn trang để pop, mà `context.go` (đổi tab của Trà Đình, xoá query) thay cả stack → màn mất đường về Âm Dương Giới (lỗi trên iPhone 22/10/2026).
  `test/shared/widgets/app_bar_back_test.dart` quét `lib/features` và fail nếu có `appBar: AppBar(` không dùng nó. Màn theo bộ thiết kế mới dùng
  `DesignPage` / `DesignScaffold` (nút ← mặc định về `backFallback`, `goBackOr` như AppBarBack); chỉ Home được `backFallback: null` — test cũng kiểm điều này. URL của app là dạng hash (`/#/tra-dinh`), đường dẫn
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
- **Màn kho thẻ (06/11/2026) dùng màu của theme**, không dùng token `AppColors`: `Theme.of(context).colorScheme` (primary = vàng, secondary, error, surface), `theme.success`,
  `theme.textMuted` / `textFaint`. Ngoại lệ có chủ ý: "Cần ôn lại" dùng `Colors.amber` (ColorScheme không có hổ phách). `ScrollCard` là widget cũ của các màn chưa làm lại theo bộ thiết kế mới.
- **Hàng chip / bộ lọc phải cuộn NGANG, không bao giờ xuống dòng**: dùng `ChipScrollRow` (`tra_dinh/hoc_tap/widgets/card_widgets.dart`), không dùng `Wrap` (lỗi bố cục trên iPhone cũ). `SegmentedButton` bọc trong `SingleChildScrollView` ngang.
  Hai nút phụ đặt cạnh nhau (Kho thẻ / Thống kê thẻ) dùng `Wrap` để xuống dòng khi hẹp.
- **Không dùng lookbehind (`(?<!…)`, `(?<=…)`) trong `RegExp`** của code chạy trên web: Safari iOS cũ (trước 16.4) không hỗ trợ và `RegExp` ném lỗi lúc chạy. `maskPhrase` tự kiểm ranh giới từ bằng mã thay vì lookbehind.
- Màn mới phải không tràn ở bề rộng 320 px với chữ phóng to ×2,0 (test bằng `tester.platformDispatcher.textScaleFactorTestValue = 2.0`). **Font của `flutter_test` rộng hơn font thật**: một dòng có thể tràn chỉ trong test
  (đã gặp ở `TodayCard` ngày 06/11/2026, sau đó sửa hẳn bằng `Flexible` / `Expanded`); đừng khẳng định vị trí tương đối của các phần tử phụ thuộc bề rộng chữ.

## Tính năng đặc thù

- **Ghi âm** (`record`) → POST `/api/tra-dinh/transcribe`.
- **Đọc thành tiếng** (`just_audio`) ← POST `/api/tra-dinh/speak` (WAV Groq, header
  độ dài 0xFFFFFFFF — sửa ở `tra_dinh/utils/wav_header.dart`).
- **Nhạc Kiều Lâu** (`features/kieu_lau`) → `/api/music/*`: upload MP3 private qua
  client token Vercel Blob, giới hạn 50 MiB; phát bằng `streamUrl` từ GET
  `/tracks` (signed URL, làm mới sau 50 phút), không dùng `blobUrl`. Player dùng
  `just_audio`, giữ trạng thái/mini-player khi chuyển giữa các màn Kiều Lâu;
  Media Session trên web nằm sau conditional bridge (native là no-op), đồng bộ
  metadata, trạng thái, vị trí và các action điều khiển khi API được trình duyệt hỗ trợ.
  Music release 24/10/2026: migration backend 0010 và backend code đã lên Production;
  Flutter Music đã deploy Production (`dpl_CJiB92WeSeYdNi59umAQzB5RNMRy`, nay là mốc rollback của đợt kho thẻ — xem "Triển khai production").
  Contract test `test/integration/music_backend_contract_test.dart` chỉ được
  chạy với backend DEV, cần `MUSIC_API_BASE_URL` và `MUSIC_API_TOKEN`.
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
- **Kho thẻ từ vựng của Trà Đình** (cùng thư mục `features/tra_dinh/hoc_tap`; thiết kế: `amber-v4/docs/tra-dinh-the-tu-vung-ke-hoach.md`; luật và API: mục "Kho thẻ từ vựng" trong `amber-v4/CLAUDE.md`).
  Lên production 06/11/2026 (`9d40500`). 4 route tĩnh, đứng trước `:sessionId`, đều nhận `?subjectId=` (thiếu thì dùng môn đầu của Tổng quan qua `CardSubjectGate`):
  `/tra-dinh/hoc-tap/the` (kho thẻ), `.../the/them` (nhập từ Claude), `.../the/on` (ôn), `.../the/thong-ke` (Nhóm khó). Vào từ khối "Thẻ hôm nay" của Tổng quan (`widgets/cards_today_block.dart`: Bắt đầu / Tiếp tục ôn, Kho thẻ,
  Thống kê thẻ, "Ngày ôn tập kế tiếp"; backend cũ không có khối `cards` thì ẩn hẳn) và từ thanh trên của kho thẻ.
  - `models/`: `study_card.dart` (thẻ, `CardStage`, `CardKind`, `CardCounts`, kết quả parse / nhập, `TopicCount`), `study_card_queue.dart` (`CardBucket`, `CardRating`, `QueueCard` + `next`, `CardProgress`, `CardQueue`, `ReviewResult`),
    `study_card_insights.dart` (`CardInsights`, `InsightGroup`, `HardCard`), `study_overview.dart` (`CardsToday`), `study_enums.dart` (`LogActivity`), `study_log.dart` / `study_schedule.dart` (`activity`), `study_stats.dart` (`statsCourseKeys`).
    Parse chịu được trường thiếu / sai kiểu (không ném).
  - `providers/card_provider.dart`: `CardLibraryNotifier` (giữ bộ lọc + trang, cuộn vô hạn bằng con trỏ, bỏ kết quả cũ về muộn), `cardTopicsProvider`, `CardActions`, `recentLessonLogsProvider` (buổi HỌC BÀI 14 ngày gần nhất để gắn thẻ khi nhập),
    `CardInsightsNotifier` (đổi kỳ 7/30/90 giữ dữ liệu cũ tới khi có dữ liệu mới). `providers/card_review_provider.dart`: phiên ôn (bên dưới).
  - `screens/`: `card_library_screen`, `card_import_screen`, `card_review_screen`, `card_session_end_screen`, `card_insights_screen`. `widgets/`: `card_widgets` (`ChipScrollRow`, `FilterPill`, `KindTag`, `TopicTag`, `CardRow`, `CardSubjectGate`),
    `card_sheet`, `card_filter_sheet`, `card_review_widgets`, `cards_today_block`. `widgets/log_sheet.dart` có công tắc "Loại: Học bài / Ôn thẻ"; buổi CARD_REVIEW mở form riêng (chỉ phút + ghi chú, PATCH / xoá, không bao giờ gửi `courseId`, `sections`).
  - `utils/`: `card_format.dart` (`cardDueLabel`, `ratingDueLabel`, `waitMinutes`, `countdownLabel`, `cardErrorMessage`, `parseErrorLine`), `card_mask.dart` (`maskPhrase`), `card_prompt.dart` (lời nhắc tạo thẻ),
    `card_insights_prompt.dart` (`buildInsightsPrompt`, lời nhắc phân tích nhóm khó), `log_labels.dart` (`logTitle`: buổi CARD_REVIEW hiện "Ôn thẻ", không khóa "Ôn tập"; `lessonPickLabel`). Lỗi kiểm tra từng trường của backend
    (`{error: {fieldErrors: {phrase: ['single_word']}}}`) và mọi mã 409 / 404 của thẻ → câu tiếng Việt trong `hoc_tap_errors.dart` + `card_format.dart`; test kiểm mọi lý do của `study-card-parse.ts` đều có câu.
  - **Phiên ôn (`CardReviewNotifier`)** — `ReviewPhase`: `loading` → `question` (mặt trước) → `answer` (mặt sau + 3 nút) → … → `waiting` / `done` / `empty` / `error`. `load({quiet})` tải hàng ôn; `showAnswer()`; `rate(rating)` khoá ba nút trong lúc gọi
    (`busy`), thành công thì bỏ thẻ khỏi hàng, lấy `progress` / `soonestDueAt` từ phản hồi rồi chọn trạng thái bằng `reviewPhaseFor` (còn thẻ → question; hết thẻ mà `soonestDueAt != null` → waiting; `planned == 0` → empty; còn lại → done).
    409 (`already_finished_today`, `not_due_yet`, `not_in_today_plan`, `card_suspended`) hoặc 404 `card_not_found` → thông báo ngắn + tải lại hàng; lỗi mạng → giữ thẻ để bấm lại; `finish()` từ màn chờ. Màn chờ đếm ngược theo
    `cardReviewClockProvider` (test điều khiển được thời gian), tự tải lại khi tới giờ và thử lại mỗi 5 giây nếu server chưa coi là đến hạn. Màn kết thúc lưu số phút bằng `POST /logs {activity: 'CARD_REVIEW'}` rồi `context.go('/tra-dinh')`;
    mở lại khi hôm nay đã ôn xong từ trước (`reviewedThisSession == 0`) thì tiêu đề "Hôm nay đã ôn xong" và không có ba chip.
  - **Che cụm** (`maskPhrase`): tìm cụm đúng như đã viết (không phân biệt hoa thường); không có thì khớp theo thân từ (từ ≤ 3 chữ giữ nguyên, từ dài bỏ 2 chữ cuối rồi `\w*`, nên "look forward to" khớp "looking forward to"); vẫn không có → mặt trước KHÔNG hiện câu ví dụ,
    chỉ hiện nghĩa. Ranh giới từ tự kiểm (xem luật lookbehind ở "Quy ước").
  - **Nhãn dưới ba nút** (`ratingDueLabel`, từ `next[rating]` của server): "Giữ lịch" (Đã nhớ của thẻ ôn thêm HARD/RANDOM giữ nguyên giai đoạn và hạn), "N phút", "Ngày mai", "CN 08/11", "Tháng 12", "Quý 1/2027". Kiểm "ngày khác → Ngày mai" TRƯỚC
    "dưới 1 giờ → N phút" (lúc 23:30, "Cần ôn lại" hẹn 00:00 là "Ngày mai": server coi thẻ hẹn sang ngày khác là xong hôm nay).
  - **Test**: `test/features/tra_dinh/hoc_tap/` — `card_*_test.dart`, `cards_today_block_test.dart`, `log_sheet_card_review_test.dart`; `FakeHocTapApi` (`hoc_tap_test_support.dart`) có sẵn móc cho thẻ, hàng ôn, review, insights. Fixture JSON thật chụp từ backend dev ở
    `test/fixtures/hoc_tap/` (`card*.json`, `cards_*.json`, `card_queue*.json`, `card_review*.json`, `card_insights_*.json`, `overview_cards.json`, `stats_card_review.json`, `schedule_card_review.json`, `logs_today_*.json`); chụp bằng script `tsx` tạm ở amber-v4
    với user thử (xoá sau), không chụp từ production. **Contract test** `test/integration/hoc_tap_backend_contract_test.dart` (5 ca: học tập, kho thẻ, ôn thẻ, buổi CARD_REVIEW, thống kê nhóm khó): chỉ chạy với backend DEV, cần `NSD_API_BASE_URL` và
    `NSD_API_TOKEN` (access token của một user thử trên dev, tạo bằng script tạm ở amber-v4 rồi xoá user); tự dọn dữ liệu (xoá môn thử, cascade); riêng ca "Ôn thẻ" tự bỏ qua khi còn < 10 phút tới nửa đêm giờ VN. Tổng (12/11/2026, sau bộ thiết kế mới): `flutter test` = 1042 test qua, 13 bỏ qua khi không có `--dart-define`.
  - **Giới hạn đã biết**: mặt sau thẻ chưa có nhãn nguồn buổi học (backend chỉ trả `sourceLogId`); màn Nhóm khó không có trạng thái riêng "môn chưa có thẻ nào"; thứ tự thẻ trong hàng ôn là thứ tự suy ra của backend (kế hoạch không lưu vị trí);
    chưa có liên kết giữa các thẻ; layout chưa đối chiếu mockup (agent không mở được canvas) — cần xem trên iPhone thật.
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
