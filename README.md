# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA TRỨNG TRÊN SÔNG THEO ĐỘ HIẾM

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

## ✨ Tính Năng Chuyên Biệt (Features)

### 🌊 1. Tự Động Quét & Nhận Diện Trứng Trên Sông (River Egg Scanner)
* **🔍 Quét Liên Tục Dòng Sông**: Tự động dò tìm tất cả các quả trứng đang trôi dọc theo dòng nước / băng chuyền trung tâm (River / Conveyor).
* **📊 Hiển Thị Trực Quan Realtime**: Banner hiển thị số lượng trứng đang trôi trên sông và bậc độ hiếm cao nhất đang có mặt trên sông theo thời gian thực.
* **🛡️ Chống Mua Nhầm**: Tự động loại trừ và bỏ qua các quả trứng đã nằm trong máy ấp hoặc khu vực của người chơi khác.

### 💎 2. Phân Loại & Lọc Độ Hiếm Đầy Đủ 8 Bậc (Rarity Classifier)
* ⚪ **Common**: Trứng thường
* 🟢 **Uncommon**: Trứng lục
* 🔵 **Rare**: Trứng hiếm
* 🟣 **Epic**: Trứng sử thi
* 🟠 **Legendary**: Trứng huyền thoại
* 🔴 **Mythic**: Trứng thần thoại
* 🟡 **Divine**: Trứng thần thánh
* 🌈 **Secret / Supreme**: Trứng tối thượng / bí mật

### 🎯 3. Tùy Chọn Mua Linh Hoạt
* **🎯 Mua Theo Ngưỡng Tối Thiểu (Min Rarity Selector)**:
  * Nút bấm xoay vòng nhanh chọn ngưỡng độ hiếm bạn muốn gom:  
    `⚪ Common+` ➔ `🟢 Uncommon+` ➔ `🔵 Rare+` ➔ `🟣 Epic+` ➔ `🟠 Legendary+` ➔ `🔴 Mythic+` ➔ `🟡 Divine+` ➔ `🌈 Secret Only`.
* **🔘 Tick Chọn Riêng Biệt Từng Bậc Độ Hiếm**: Tự do bật/tắt chính xác những loại trứng bạn muốn script mua, bỏ qua các loại không cần thiết.

### ⚡ 4. Cơ Chế Mua Tức Thời & Không Trượt Trứng
* **🌐 Mua Tầm Xa Vô Hạn (Infinite Range)**: Tự động mở khóa `MaxActivationDistance = 99999` và thời gian giữ `HoldDuration = 0s` trên ProximityPrompt của trứng để mua tức thời ngay từ xa mà không cần chạy lại gần mép sông.
* **🚀 Tự Động Bay Cạnh Trứng (Auto Teleport)**: Tùy chọn dịch chuyển tức thời nhân vật đến sát quả trứng đang trôi để vượt qua mọi kiểm tra khoảng cách vật lý của máy chủ Roblox, đảm bảo tỷ lệ mua thành công 100%.
* **⚡ Kích Hoạt Đa Tầng (Multi-Trigger Engine)**: Kết hợp đồng thời ProximityPrompt, ClickDetector và bắn Remote mua trứng để đạt tốc độ mua nhanh nhất có thể.

### 🛡️ 5. Hỗ Trợ Treo Máy 24/7 (Anti-AFK)
* **🛡️ Anti-AFK Tích Hợp**: Tự động gửi tín hiệu giữ kết nối liên tục, chống bị văng game sau 20 phút không hoạt động để bạn yên tâm treo máy gom trứng hiếm xuyên đêm.

---

## 🎨 Giao Diện Cyberpunk River Tối Ưu Màn Hình
* Tông màu chủ đạo **Neon Cyan & Ocean Blue** phong cách dòng sông hiện đại.
* Khung điều khiển có thể kéo thả tự do trên màn hình (Draggable).
* **Nút Tròn Thu Nhỏ (Floating Icon Toggle 🌊)**: Dễ dàng ẩn/hiện bảng điều khiển khi đang chơi trên điện thoại (Delta Executor).
* **Status Bar**: Hiển thị chi tiết tên và độ hiếm của từng quả trứng vừa mua thành công.

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/hatch_or_crack_an_egg.git`
* **Tác giả**: `khahuynh963`
