# 🥚 HATCH OR CRACK AN EGG! ([👺] ẤP HOẶC NỨT MỘT QUẢ TRỨNG) - ULTIMATE AUTO HUB V2.0

Script hỗ trợ tự động chơi, tối ưu hóa hệ số nhân và **tự động mua trứng trôi trên dòng sông theo độ hiếm** toàn diện cho tựa game **[👺] Ấp hoặc nứt một quả trứng** (Hatch or Crack an Egg) trên Roblox, được phát triển bởi nhóm **Get it or Lose it**.

Tương thích mượt mà 100% cho **Delta Executor (Android & PC)**, Codex, Wave, Hydrogen, Fluxus và Solara.

---

## 🚀 Cách Sử Dụng (Script Execution Command)

Chỉ cần sao chép lệnh bên dưới và dán vào Executor của bạn (Delta / Codex / Wave / Fluxus):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/hatch_or_crack_an_egg/main/loader.lua"))()
```

Hoặc chạy trực tiếp file script chính:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/hatch_or_crack_an_egg/main/script.lua"))()
```

---

## ✨ Tính Năng Nổi Bật (Key Features)

### 🌊 1. Auto Mua Trứng Trên Dòng Sông Theo Độ Hiếm (River Eggs Auto-Buy - MỚI V2.0)
* **🔍 Tự Động Quét & Nhận Diện Trứng Trôi**: Quét tức thời toàn bộ các quả trứng đang trôi trên dòng sông / băng chuyền trung tâm (River / Conveyor).
* **💎 Nhận Diện Phân Loại Độ Hiếm (Rarity Classifier)**:
  * ⚪ **Common**: Trứng thường
  * 🟢 **Uncommon**: Trứng lục
  * 🔵 **Rare**: Trứng hiếm
  * 🟣 **Epic**: Trứng sử thi
  * 🟡 **Legendary**: Trứng huyền thoại
  * 🔴 **Mythic**: Trứng thần thoại
  * ✨ **Divine**: Trứng thần thánh
  * 👑 **Secret / Supreme**: Trứng bí mật / tối thượng
* **🎯 Bộ Lọc Độ Hiếm Tối Thiểu (Min Rarity Selector)**:
  * Chuyển nhanh ngưỡng độ hiếm mong muốn: `ALL` -> `UNCOMMON+` -> `RARE+` -> `EPIC+` -> `LEGENDARY+` -> `MYTHIC+` -> `DIVINE+` -> `SECRET ONLY`.
* **🔘 Bộ Tùy Chọn Từng Bậc Độ Hiếm Riêng Biệt**: Cho phép bạn tick chọn chính xác những loại trứng muốn mua, bỏ qua các loại không cần thiết.
* **🌐 Mua Tầm Xa (Infinite Range Purchase)**: Kích hoạt ProximityPrompt / Remote mua trứng từ xa ngay khi trứng vừa xuất hiện trên đầu nguồn sông mà không cần chạy lại gần.
* **⚡ Tùy Chọn Auto Teleport**: Tự động dịch chuyển tức thời đến sát quả trứng trên sông để kích hoạt mua 100% không bao giờ trượt.
* **🛡️ Chống Mua Nhầm**: Tự động bỏ qua các quả trứng đang được ấp hoặc đã nằm trong máy của người chơi khác.

### 🎰 2. Smart Auto Multiplier & Crash Cashout (Tự Động Gạt Cần & Ấp Chốt Lời)
* **⚡ Tự Động Gạt Cần (Auto Pull Lever)**: Tự động gạt cần nâng hệ số nhân quả trứng từ `x1.00` lên dần `x2.00`, `x5.00`, `x24.0`, `x1,000`...
* **💰 Tự Động Ấp Chốt Lời (Auto Cashout / Hatch)**: 
  * Ngay khi hệ số đạt hoặc vượt mức mục tiêu bạn đã chọn, script sẽ **tức thì kích hoạt Hatch / Claim** để chốt lời an toàn 100%, không lo rủi ro quả trứng bị nứt vỡ tan tành (`CRACKS AT RANDOM`).
* **🎯 Bộ Mục Tiêu Chốt Lời Linh Hoạt**:
  * 🛡️ **Cực An Toàn (x1.5)**: Win rate 98%+, tích lũy vốn cực nhanh.
  * 🛡️ **An Toàn (x2.0)**: Mặc định tối ưu, nhân đôi tiền thưởng ổn định.
  * ⚖️ **Cân Bằng (x3.0)**: Lợi nhuận gấp 3 lần với tỷ lệ thắng cao.
  * 🚀 **Mạo Hiểm (x5.0)**: Dành cho ai muốn nhân nhanh tài sản.
  * 🔥 **Liều Ăn Nhiều (x10.0)**: Lợi nhuận gấp 10 lần.
  * ⚡ **Siêu Lợi Nhuận (x24.0) & 👑 Jackpot (x100.0)**: Săn mốc nhân khổng lồ như trên thumbnail!
* **🥚 Auto Start New Egg**: Tự động kích hoạt nạp quả trứng mới ngay khi trứng cũ đã nở thành công hoặc rủi ro bị vỡ, giúp bạn treo máy cày tiền 24/7 không cần can thiệp tay.
* **⚡ Instant ProximityPrompt (0s Hold)**: Loại bỏ hoàn toàn thời gian giữ phím E trên cần gạt và nút ấp trứng, thao tác tức thời.

### 💰 3. Tiền & Tiến Trình Nâng Cấp (Progression)
* **🧲 Auto Collect Cash & Coins**: Tự động hút toàn bộ tiền, kim cương và phần thưởng rơi quanh máy ấp.
* **🔄 Auto Rebirth**: Tự động chuyển sinh khi đủ điều kiện để nhận thêm hệ số nhân may mắn vĩnh viễn.
* **⚡ Auto Upgrade Machine**: Tự động dùng tiền nâng cấp cấp bậc máy ấp và tỷ lệ may mắn.

### 🏃 4. Tốc Độ & Can Thiệp Vật Lý Gian Lận (Movement)
* **⚡ WalkSpeed Customizer**: Tùy chỉnh tốc độ di chuyển linh hoạt từ 32 đến 400 với Stepped Loop chống reset tốc độ.
* **🌀 Lướt CFrame Siêu Âm**: Hỗ trợ tăng tốc độ lướt CFrame mượt mà (2x, 5x, 10x, 20x, 40x) không bị giật lag hay rubberband.
* **🦘 Infinite Jump**: Nhảy vô hạn trên không trung.
* **👻 Noclip**: Đi xuyên tường, rào chắn và chướng ngại vật trên bản đồ.
* **🛸 Float / Hover**: Khóa độ cao trục Y giúp nhân vật bay lơ lửng trên không trung.

### 🛡️ 5. Hỗ Trợ Treo Máy 24/7 & Tối Ưu Hiệu Năng
* **🛡️ Anti-AFK 24/7**: Chống bị văng game (Kick for idle 20 minutes) giúp bạn yên tâm treo máy cày cuốc xuyên đêm.
* **🚀 FPS Booster / Low Graphics**: Tắt bóng đổ, khử hiệu ứng hạt nặng hạt để máy chạy mát, tiết kiệm pin khi treo nhiều tài khoản trên điện thoại hoặc giả lập PC.

---

## 🎨 Giao Diện Cyberpunk Tối Ưu Màn Hình
* Tông màu chủ đạo **Golden Egg Gold & Neon Multiplier Green** bắt mắt.
* Bảng hiển thị **Hệ Số Hiện Tại [ x... ]** cập nhật thời gian thực.
* Khung điều khiển có thể kéo thả tự do trên màn hình (Draggable).
* Tích hợp **Nút Tròn Thu Nhỏ (Floating Icon Toggle 🥚)** giúp bạn ẩn/hiện bảng điều khiển nhanh chóng khi đang chơi trên điện thoại (Delta Executor).

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/hatch_or_crack_an_egg.git`
* **Tác giả**: `khahuynh963`
