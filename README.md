# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA & BÁN TẤT CẢ TRỨNG V2.4

Script chuyên biệt tự động quét **mua trứng trôi trên dòng sông** và **tự động bán tất cả trứng theo quy trình chuẩn game** cho tựa game **[👺] Ấp hoặc nứt một quả trứng** (Hatch or Crack an Egg) trên Roblox, được phát triển bởi nhóm **Get it or Lose it**.

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

## 🔥 Tính Năng Mới V2.4: Bán Tất Cả Trứng (Chuẩn Menu Game)

Dựa trên 3 hình ảnh giao diện thực tế của game, script tự động thực hiện chu trình bán 3 bước chuẩn xác 100%:

1. **Bước 1**: Tự động bấm nút **[Bán]** màu xanh trên thanh công cụ phía trên màn hình (hoặc tương tác ProximityPrompt `Egg Market / Sell Eggs` tại Thị trường trứng).
2. **Bước 2**: Trong bảng hội thoại **Người bán trứng**, script tự động click dòng **`2. Bán tất cả trứng`** (kèm hiển thị tổng số tiền nhận được như $1.05B, $599B).
3. **Bước 3**: Khi bảng xác nhận bật lên, script tự động click dòng **`1. Có, bán chúng đi`** để hoàn tất bán sạch toàn bộ trứng lấy tiền ngay lập tức!

* **Nút bấm thủ công**: **`🔥 BÁN TẤT CẢ TRỨNG NGAY (SELL ALL NOW)`** — 1 click duy nhất chạy trọn vẹn chu trình 3 bước trên.
* **Nút gạt tự động**: **`⚡ Auto Bán Tất Cả Trứng`** — Tự động lặp lại chu trình sau mỗi 3.5 giây, giúp bạn thoải mái treo máy gom tiền mà không bao giờ bị đầy túi!

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
