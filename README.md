# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA TRỨNG TRÊN SÔNG V2.1

Script chuyên biệt tự động quét và **mua trứng trôi trên dòng sông theo độ hiếm** cho tựa game **[👺] Ấp hoặc nứt một quả trứng** (Hatch or Crack an Egg) trên Roblox, được phát triển bởi nhóm **Get it or Lose it**.

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

## ⚡ Cải Tiến V2.1 (Kiểm Soát Dịch Chuyển & Bộ Lọc Sông Nghiêm Ngặt)

### 1. 🚀 Dịch Chuyển Đúng 1 Lần / Quả (Chống Dịch Chuyển Lặp Lại)
* **Ghi Nhớ Lịch Sử Trứng Đã Mua (Memory Blacklist)**: Mỗi quả trứng sau khi được script dịch chuyển đến và kích hoạt mua sẽ được đánh dấu vào bộ nhớ lưu vết. Script **tuyệt đối không dịch chuyển lại quả trứng đó lần thứ 2**, dù quả trứng vẫn còn trôi thêm vài giây trước khi rơi khỏi sông.
* **1 Mục Tiêu Tối Ưu Mỗi Lượt**: Script lựa chọn đúng 1 quả trứng có phẩm cấp cao nhất để xử lý tuần tự, loại bỏ hoàn toàn hiện tượng dịch chuyển qua lại giữa nhiều quả trứng gây giật lag (teleport lung tung).
* **🔙 Auto Return To Base (Tự Quay Về Chỗ Cũ)**: Ngay sau khi bay đến trứng và bấm mua xong (0.15s), nhân vật sẽ **tự động bay ngược về lại vị trí máy ấp ban đầu** để bạn không bị rớt xuống nước hay trôi dạt ra xa.

### 2. 🌊 Chỉ Kiểm Tra Trứng Trên Dòng Sông (Không Dịch Chuyển Lung Tung)
* **Loại Trừ 100% Máy Ấp & Base Người Chơi**: Thuật toán kiểm tra toàn bộ cây thư mục để loại bỏ bất kỳ quả trứng nào đang nằm trong máy ấp, nest, bệ đỡ hoặc plot của người chơi khác.
* **Loại Trừ Cần Gạt & Nút Ấp Máy**: Tự động phát hiện và bỏ qua các tương tác của máy (Pull Lever, Hatch, Ấp, Gạt cần). Chỉ nhận diện đúng tương tác mua quả trứng trên dòng sông.

### 3. 🧪 Công Cụ Kiểm Tra & Test Trực Tiếp Trên Menu
* **📍 Dịch Chuyển Thử Nghiệm 1 Lần (Test TP Once)**: Bấm nút để script tìm ngay 1 quả trứng hợp lệ trên sông và bay đến mua thử 1 lần duy nhất, giúp bạn kiểm tra cơ chế hoạt động thực tế.
* **🔍 Quét Kiểm Tra Dòng Sông (Debug Scan)**: Báo cáo tức thì số lượng trứng hợp lệ đang có trên sông và số lượng trứng đã gom thành công.
* **🗑️ Xóa Bộ Nhớ Trứng Đã Mua (Reset Memory)**: Xóa sạch cache lịch sử nếu muốn quét lại từ đầu.

---

## ✨ Tính Năng Cốt Lõi (Core Features)

### 💎 Phân Loại & Lọc Độ Hiếm Đầy Đủ 8 Bậc
* ⚪ **Common**: Trứng thường
* 🟢 **Uncommon**: Trứng lục
* 🔵 **Rare**: Trứng hiếm
* 🟣 **Epic**: Trứng sử thi
* 🟠 **Legendary**: Trứng huyền thoại
* 🔴 **Mythic**: Trứng thần thoại
* 🟡 **Divine**: Trứng thần thánh
* 🌈 **Secret / Supreme**: Trứng tối thượng / bí mật

### 🎯 Tùy Chọn Mua Linh Hoạt
* **🎯 Mua Theo Ngưỡng Tối Thiểu (Min Rarity Selector)**:
  * Nút bấm xoay vòng nhanh chọn ngưỡng độ hiếm bạn muốn gom:  
    `⚪ Common+` ➔ `🟢 Uncommon+` ➔ `🔵 Rare+` ➔ `🟣 Epic+` ➔ `🟠 Legendary+` ➔ `🔴 Mythic+` ➔ `🟡 Divine+` ➔ `🌈 Secret Only`.
* **🔘 Tick Chọn Riêng Biệt Từng Bậc Độ Hiếm**: Tự do bật/tắt chính xác những loại trứng bạn muốn script mua.
* **🌐 Mua Tầm Xa Vô Hạn (Infinite Range)**: Tự động mở khóa `MaxActivationDistance = 99999` và thời gian giữ `HoldDuration = 0s`.
* **🛡️ Anti-AFK Tích Hợp**: Tự động chống văng game 20 phút để bạn an tâm treo máy săn trứng hiếm xuyên đêm.

---

## 🎨 Giao Diện Cyberpunk River Tối Ưu Màn Hình
* Tông màu chủ đạo **Neon Cyan & Ocean Blue**.
* Khung điều khiển có thể kéo thả tự do trên màn hình (Draggable).
* **Nút Tròn Thu Nhỏ (Floating Icon Toggle 🌊)**: Dễ dàng ẩn/hiện bảng điều khiển khi đang chơi trên điện thoại (Delta Executor).
* **Status Bar**: Hiển thị chi tiết trạng thái từng quả trứng vừa mua thành công.

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/hatch_or_crack_an_egg.git`
* **Tác giả**: `khahuynh963`
