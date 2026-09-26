# 🌊 HATCH OR CRACK AN EGG! - AUTO MUA & BÁN TRỨNG THEO ĐỘ HIẾM V2.2

Script chuyên biệt tự động quét **mua trứng trôi trên dòng sông** và **tự động bán trứng có chọn lọc (chỉ được bán)** cho tựa game **[👺] Ấp hoặc nứt một quả trứng** (Hatch or Crack an Egg) trên Roblox, được phát triển bởi nhóm **Get it or Lose it**.

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

## ✨ Tính Năng Nổi Bật V2.2

### 💰 1. Auto Bán Trứng Chỉ Được Bán (Selective Auto Sell - MỚI V2.2)
* **🎯 Chỉ Bán Các Độ Hiếm Được Phép**:
  * Tự động quét trứng trong túi (Backpack) và trên tay nhân vật (Equipped Tools).
  * Chỉ tiến hành bán những quả trứng có độ hiếm được bạn bật cho phép bán.
  * **🛡️ Khóa Bảo Vệ Trứng Xịn 100%**:
    * ⚪ **Common**: Mặc định **BẬT** (Bán dọn túi)
    * 🟢 **Uncommon**: Mặc định **BẬT** (Bán dọn túi)
    * 🔵 **Rare**: Mặc định **BẬT** (Bán kiếm tiền)
    * 🟣 **Epic**: Mặc định **TẮT** (Khóa an toàn)
    * 🟠 **Legendary**: Mặc định **TẮT** (Khóa bảo vệ trứng huyền thoại)
    * 🔴 **Mythic**: Mặc định **TẮT** (Khóa bảo vệ trứng thần thoại)
    * 🟡 **Divine**: Mặc định **TẮT** (Khóa bảo vệ trứng thần thánh)
    * 🌈 **Secret / Supreme**: Mặc định **TẮT** (Khóa bảo vệ trứng tối thượng)
* **⚡ Cơ Chế Bán Đa Tầng Tức Thời**:
  * Tự động chạm ô Bán (Sell Pad / Sell Zone / Sell Platform).
  * Tự động bắn các Remote bán trứng an toàn (`sellegg`, `sellall`, `sellinv`).
  * Tự động tương tác với NPC Sell và bấm nút Sell trong giao diện.
* **💰 Nút Bán Ngay Lập Tức (Sell Now - 1 Lần)**: Bấm phát bán ngay các trứng hợp lệ đang có mà không cần đợi chu kỳ lặp.

---

### 🌊 2. Auto Mua Trứng Trên Dòng Sông (River Egg Auto-Buy)
* **🚀 Dịch Chuyển Đúng 1 Lần / Quả (Memory Blacklist)**: Mỗi quả trứng chỉ được dịch chuyển đến và kích hoạt mua đúng 1 lần duy nhất. Script ghi nhớ quả đó trong 90 giây và không bao giờ dịch chuyển lặp lại gây giật lag.
* **🌊 Chỉ Quét Trứng Trên Sông (Không Dịch Chuyển Lung Tung)**:
  * Loại trừ 100% các quả trứng nằm trong máy ấp, nest, bệ đỡ hoặc plot của người chơi khác.
  * Bỏ qua các cần gạt và nút ấp của máy (Pull Lever, Hatch, Ấp, Gạt cần).
* **🔙 Auto Return To Base**: Tự động bay về vị trí máy ấp ban đầu sau khi mua trứng xong (0.15s), không lo bị rớt xuống nước.
* **🎯 Mua Theo Ngưỡng Tối Thiểu (Min Rarity)**: Chọn nhanh mức độ hiếm sàn muốn mua (`Common+` đến `Secret Only`).
* **🔘 Tùy Chọn Từng Bậc Độ Hiếm Riêng Biệt**: Cho phép tick chọn chính xác từng loại trứng muốn gom.
* **🌐 Mua Tầm Xa Vô Hạn (Infinite Range)**: Mở khóa khoảng cách `99999` và thời gian giữ `0s Hold`.

---

### 🧪 3. Công Cụ Test Trực Tiếp Trên Menu (Debug Tools)
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
