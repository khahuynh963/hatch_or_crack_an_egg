# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA SÔNG & BÁN TRỨNG V2.7

Script chuyên biệt tự động quét **mua trứng trôi trên dòng sông**, **tự động bán sạch trứng khi balo đầy**, và **bán tất cả trứng theo quy trình chuẩn game 3 bước** cho tựa game **[👺] Ấp hoặc nứt một quả trứng** (Hatch or Crack an Egg) trên Roblox, được phát triển bởi nhóm **Get it or Lose it**.

Tương thích mượt mà 100% cho **Delta Executor (Android & PC)**, Codex, Wave, Hydrogen, Fluxus và Solara.

---

## 🚀 Cách Sử Dụng (Script Execution Command)

Chỉ cần sao chép lệnh bên dưới và dán vào Executor của bạn (Delta / Codex / Wave / Fluxus):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/hatch_or_crack_an_egg/main/loader.lua"))()
```

Hoặc nạp trực tiếp file script chính:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/hatch_or_crack_an_egg/main/script.lua"))()
```

---

## 🎒 Tính Năng Nâng Cấp V2.7: Khắc Phục Lỗi Nhảy Quá Nhanh & Tối Ưu Bán Trứng

Phiên bản V2.7 khắc phục toàn diện 2 vấn đề lớn được người chơi phản hồi:

1. **⏱️ Khắc Phục Lỗi Mua Trứng "Nhảy Đến Rồi Nhảy Về Quá Nhanh"**:
   * **Bám sát theo quả trứng**: Khi trứng đang trôi trên băng chuyền sông, nhân vật liên tục điều chỉnh tọa độ bay theo sát quả trứng (cự ly 2.5 studs).
   * **Duy trì thời gian dừng tại trứng (`EggStayDuration`)**: Cho phép server đủ thời gian nhận diện và xử lý ProximityPrompt (mặc định 0.75s, có nút bấm trên giao diện để đổi `0.5s ➔ 0.75s ➔ 1.0s ➔ 1.25s ➔ 1.5s`).
   * **Kiểm tra trạng thái nhặt thực tế**: Chỉ khi quả trứng thực sự biến mất khỏi Workspace (đã mua thành công) thì nhân vật mới bay về chỗ cũ! Nếu chưa mua kịp do ping, script chỉ tạm hoãn 3.5s để thử lại ngay sau đó thay vì bỏ lỡ.
2. **🔥 Khắc Phục Triệt Để Chức Năng Bán Trứng Khi Balo Đầy (Sell All Eggs)**:
   * **Sửa lỗi biến ScreenGui nil**: Loại bỏ hoàn toàn lỗi crash ngầm trong các hàm kiểm tra balo và quét nút bấm.
   * **Chống đóng ngược menu**: Kiểm tra trước nếu bảng thoại "Người bán trứng" đã mở sẵn thì không bấm nút TopBar nữa (tránh tình trạng bấm nút làm đóng menu).
   * **Dự phòng dịch chuyển đến quầy Thị Trường Trứng**: Nếu nút [Bán] trên TopBar không mở được thoại, script tự động dịch chuyển nhân vật đến trước quầy bán trứng trong map và kích hoạt ProximityPrompt trực tiếp.
   * **Mô phỏng phím số 2 và phím số 1**: Kết hợp cả click chuột/chạm tay cảm ứng (`VirtualInputManager`, `VirtualUser`, `firesignal`) cùng phím số `2` (Bán tất cả) và `1` (Xác nhận Có, bán chúng đi).
   * **Khóa chống chen ngang**: Khi đang thực hiện chu trình bán, vòng lặp mua trứng sông lập tức tạm dừng để nhường quyền ưu tiên 100% cho bán trứng.

---

## 💎 Danh Sách Độ Hiếm Chuẩn Theo In-Game Index

Script đã được cấu hình trùng khớp 100% với danh mục Index trong game:

| Bậc | Tên Hiển Thị Trong Game | Tên Gốc Tiếng Anh | Mua Mặc Định | Bán Mặc Định (Chế độ lọc) |
|---|---|---|---|---|
| 1 | ⚪ **Thường** | Common | OFF | **ON** (Tự bán dọn túi) |
| 2 | 🟢 **Không phổ biến** | Uncommon | OFF | **ON** (Tự bán dọn túi) |
| 3 | 🔵 **Hiếm** | Rare | OFF | **ON** (Tự bán cày tiền) |
| 4 | 🟣 **Huyền tuyệt** | Epic | **ON** | **OFF** (Khóa an toàn) |
| 5 | 🟠 **Huyền thoại** | Legendary | **ON** | **OFF** (Khóa bảo vệ) |
| 6 | 🔴 **Huyền thoại (Mythic)** | Mythic | **ON** | **OFF** (Khóa bảo vệ) |
| 7 | 🌈 **Bật mí** | Secret | **ON** | **OFF** (Khóa bảo vệ) |
| 8 | ⭐ **Giới hạn** | Limited | **ON** | **OFF** (Khóa bảo vệ) |

---

## ✨ Tính Năng Nổi Bật Khác

### 🌊 Auto Mua Trứng Trên Dòng Sông (River Egg Auto-Buy)
* **🚀 Dịch Chuyển Đúng 1 Lần / Quả (Memory Blacklist)**: Mỗi quả trứng chỉ được dịch chuyển đến và kích hoạt mua đúng 1 lần duy nhất. Script ghi nhớ quả đó trong 90 giây và không bao giờ dịch chuyển lặp lại gây giật lag.
* **🌊 Chỉ Quét Trứng Trên Sông (Không Dịch Chuyển Lung Tung)**:
  * Loại trừ 100% các quả trứng nằm trong máy ấp, nest, bệ đỡ hoặc plot của người chơi khác.
  * Bỏ qua các cần gạt và nút ấp của máy (Pull Lever, Hatch, Ấp, Gạt cần).
* **🔙 Auto Return To Base**: Tự động bay về vị trí máy ấp ban đầu sau khi mua trứng xong (0.15s), không lo bị rớt xuống nước.
* **🎯 Mua Theo Ngưỡng Tối Thiểu (Min Rarity)**: Chọn nhanh mức độ hiếm sàn muốn mua (`Thường+` đến `Giới hạn Only`).
* **🔘 Tùy Chọn Từng Bậc Độ Hiếm Riêng Biệt**: Cho phép tick chọn chính xác từng loại trứng muốn gom theo chuẩn Index.
* **🌐 Mua Tầm Xa Vô Hạn (Infinite Range)**: Mở khóa khoảng cách `99999` và thời gian giữ `0s Hold`.

### 💰 Bán Theo Độ Hiếm Chọn (Chỉ Được Bán)
* Hỗ trợ chế độ bán lọc nếu bạn chỉ muốn bán các bậc trứng cấp thấp (`Thường`, `Không phổ biến`, `Hiếm`) và giữ lại trứng xịn.

### 🧪 Công Cụ Test Trực Tiếp Trên Menu (Debug Tools)
* **📍 Dịch Chuyển Thử Nghiệm 1 Lần (Test TP Once)**: Bấm để test bay đến 1 quả trứng hợp lệ trên sông mua thử và tự quay về.
* **🔍 Quét Kiểm Tra Dòng Sông (Debug Scan)**: Báo cáo số lượng trứng hợp lệ và số trứng đã mua/bán.
* **🗑️ Xóa Bộ Nhớ Trứng Đã Mua (Reset Memory)**: Xóa cache lịch sử nếu muốn quét lại từ đầu.
* **🛡️ Anti-AFK Tích Hợp**: Tự động chống văng game 20 phút để bạn an tâm treo máy cày xuyên đêm.

---

## 🎨 Giao Diện Cyberpunk River Tối Ưu Màn Hình
* Tông màu chủ đạo **Neon Cyan, Vàng Kim & Ocean Blue**.
* Khung điều khiển có thể kéo thả tự do trên màn hình (Draggable).
* **Nút Tròn Thu Nhỏ (Floating Icon Toggle 🌊)**: Dễ dàng ẩn/hiện bảng điều khiển khi đang chơi trên điện thoại (Delta Executor).
* **Thanh Trạng Thái (Live Banner)**: Cập nhật liên tục số trứng trên sông, số trứng đã mua và số trứng đã bán.

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/hatch_or_crack_an_egg.git`
* **Tác giả**: `khahuynh963`
