# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA SÔNG & BÁN TRỨNG V2.6

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

## 🎒 Tính Năng Mới V2.6: Tự Động Bán Khi Balo Đầy (Full Backpack Auto-Sell)

Giải quyết triệt để vấn đề đầy balo làm gián đoạn quá trình cày cuốc và gom trứng xịn:

1. **📊 Nhận Diện Dung Lượng Balo Thời Gian Thực**:
   * Tự động quét và đọc chính xác thông số balo hiển thị trên góc phải màn hình game (dạng `471/500`, `472/500`, `500/500`).
   * Hiển thị trực tiếp thông số này lên thanh trạng thái GUI: `🎒 Balo: [471/500]` giúp bạn dễ dàng theo dõi.
2. **⚡ Balo Đầy Tự Động Kích Hoạt Bán Trứng**:
   * Ngay khi số lượng trứng trong balo chạm ngưỡng tối đa (`cur >= max`, ví dụ 500/500), script sẽ tự động kích hoạt chu trình bán tất cả để giải phóng 100% dung lượng balo lấy tiền mặt.
3. **🤝 Tích Hợp Đồng Bộ Với Auto Mua Sông**:
   * Trước mỗi lần mua trứng sông, script sẽ kiểm tra balo. Nếu balo đã đầy, nó sẽ **tạm dừng mua để bán sạch balo trước**, sau đó mới tiếp tục gom trứng xịn. Tránh hoàn toàn việc bay đến quả trứng sông nhưng không nhặt được vì đầy túi!
4. **🔥 Khắc Phục Toàn Diện Lỗi Nút Bán (Multi-Input Click & Polling)**:
   * **Nhận diện chính xác nút [Bán]**: Tìm kiếm TextLabel mang chữ "Bán" / "BÁN" chuẩn UTF-8 nằm bên trong `ImageButton` trên thanh TopBar.
   * **Cơ chế Click Đa Nền Tảng (Multi-Input)**: Kết hợp đồng thời `firesignal`, `getconnections`, và **`VirtualInputManager`** (mô phỏng thao tác click chuột / chạm tay phần cứng tại đúng tọa độ tâm của nút trên màn hình).
   * **Hệ thống Polling thông minh**: Chờ bảng thoại "Người bán trứng" xuất hiện tối đa 2.5s cho bước 2 (`2. Bán tất cả trứng`) và bước 3 (`1. Có, bán chúng đi`), kèm cơ chế tự động bấm lại nếu game bị lag.

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
