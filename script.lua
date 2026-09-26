--[[
    ===================================================================
    🌊 HATCH OR CRACK AN EGG! - AUTO MUA SÔNG & BÁN TRỨNG V2.5
    Game: [👺] Ấp hoặc nứt một quả trứng (by Get it or Lose it)
    Repository: https://github.com/khahuynh963/hatch_or_crack_an_egg.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus.
    
    TÍNH NĂNG MỚI V2.5 (BẢO VỆ TUYỆT ĐỐI - KHÔNG CLICK NHẦM SHOP / VẬT PHẨM KHÁC):
    1. 🛡️ CHỐNG TƯƠNG TÁC NHẦM VÀO SHOP & VẬT PHẨM KHÁC:
       - Loại bỏ 100% việc bay hoặc click nhầm vào "EGG DROP SHOP", quầy đổi vé (Tickets), vòng quay (Odds), máy gắp, và các shop gamepass/robux.
       - Bộ lọc 3 lớp nghiêm ngặt (Blacklist): Kiểm tra tên đối tượng, cây thư mục cha/ông, nội dung ProximityPrompt, và chữ GUI/Billboard.
       - Giới hạn chi tiết mô hình (<= 25 parts): Ngăn chặn việc nhận diện tòa nhà/quầy shop/bệ trưng bày làm trứng sông.
       - Loại bỏ hoàn toàn Remote mua chung chung ('buyegg', 'purchaseegg') gây tự động mở bảng EGG DROP SHOP.
       - Tự động đóng các bảng Shop Popup nếu vô tình bị mở (Auto Close Shop Popups).
    2. 🔥 CHU TRÌNH BÁN TẤT CẢ TRỨNG TỰ ĐỘNG CHUẨN 100% GIAO DIỆN GAME:
       - Bước 1: Tự động bấm nút [Bán] màu xanh ở thanh menu phía trên (hoặc tương tác Thị trường trứng).
       - Bước 2: Bấm chọn dòng [2. Bán tất cả trứng] trong bảng "Người bán trứng".
       - Bước 3: Bấm chọn dòng xác nhận [1. Có, bán chúng đi] để hoàn tất bán sạch toàn bộ trứng lấy tiền.
    3. 💰 AUTO BÁN THEO ĐỘ HIẾM (CHỈ ĐƯỢC BÁN):
       - Tự lọc và chỉ bán các độ hiếm cho phép (Thường, Không phổ biến, Hiếm).
       - Khóa an toàn không bán trứng xịn (Huyền tuyệt, Huyền thoại, Bật mí, Giới hạn).
    4. 🌊 AUTO MUA TRỨNG TRÊN SÔNG:
       - Chỉ dịch chuyển đúng 1 lần duy nhất cho mỗi quả trứng (Memory Blacklist).
       - Chỉ quét trứng trên dòng sông, tuyệt đối không dịch chuyển lung tung.
       - Tự động quay về chỗ cũ (Auto Return To Base) sau khi mua.
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ── Safe GUI Container Helper ──
local function getGuiContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        elseif syn and syn.protect_gui then
            local f = Instance.new("Folder")
            syn.protect_gui(f)
            f.Parent = game:GetService("CoreGui")
            container = f
        elseif game:GetService("CoreGui") then
            container = game:GetService("CoreGui")
        end
    end)
    if not container then
        pcall(function()
            container = LocalPlayer:WaitForChild("PlayerGui")
        end)
    end
    return container
end

-- Clear old GUI instances
pcall(function()
    local c = getGuiContainer()
    if c and c:FindFirstChild("HatchOrCrackRiverHubGui") then
        c.HatchOrCrackRiverHubGui:Destroy()
    end
    if c and c:FindFirstChild("HatchOrCrackHubGui") then
        c.HatchOrCrackHubGui:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("HatchOrCrackRiverHubGui") then
        game:GetService("CoreGui").HatchOrCrackRiverHubGui:Destroy()
    end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HatchOrCrackRiverHubGui") then
        LocalPlayer.PlayerGui.HatchOrCrackRiverHubGui:Destroy()
    end
end)

-- ── State Management (Đúng chuẩn độ hiếm trong game) ──
local State = {
    -- 1. River Egg Buy
    AutoBuyRiverEggs = false,
    MinRiverRarityIndex = 4, -- Default Huyền tuyệt+
    AutoTpToRiverEgg = true,
    AutoReturnToBase = true, -- Tự động quay về chỗ cũ sau khi mua
    InfiniteRiverRange = true,
    AutoCloseShopPopups = true, -- Tự động đóng mọi bảng shop nếu mở nhầm
    BuyRarities = {
        Common = false,      -- Thường
        Uncommon = false,    -- Không phổ biến
        Rare = false,        -- Hiếm
        Epic = true,         -- Huyền tuyệt
        Legendary = true,    -- Huyền thoại
        Mythic = true,       -- Huyền thoại (Mythic)
        Secret = true,       -- Bật mí
        Limited = true       -- Giới hạn
    },

    -- 2. Sell System
    AutoSellAllEggs = false, -- Chu trình Bán ➔ Bán tất cả trứng ➔ Có, bán chúng đi
    AutoSellByRarity = false, -- Bán theo độ hiếm chọn
    SellRarities = {
        Common = true,       -- Thường (Tự bán)
        Uncommon = true,     -- Không phổ biến (Tự bán)
        Rare = true,         -- Hiếm (Tự bán)
        Epic = false,        -- Huyền tuyệt (Khóa an toàn)
        Legendary = false,   -- Huyền thoại (Khóa an toàn)
        Mythic = false,      -- Huyền thoại (Mythic) (Khóa an toàn)
        Secret = false,      -- Bật mí (Khóa an toàn)
        Limited = false      -- Giới hạn (Khóa an toàn)
    },

    -- 3. Utility & Performance
    AntiAFK = true,
    FPSBooster = false -- Tối ưu đồ họa đạt chuẩn 60 FPS không giật lag
}

local MinRarityPresets = {
    {Name = "⚪ Thường+ (Common+)", Key = "Common", Rank = 1},
    {Name = "🟢 Không phổ biến+", Key = "Uncommon", Rank = 2},
    {Name = "🔵 Hiếm+", Key = "Rare", Rank = 3},
    {Name = "🟣 Huyền tuyệt+", Key = "Epic", Rank = 4},
    {Name = "🟠 Huyền thoại+", Key = "Legendary", Rank = 5},
    {Name = "🔴 Huyền thoại (Mythic)+", Key = "Mythic", Rank = 6},
    {Name = "🌈 Bật mí (Secret)+", Key = "Secret", Rank = 7},
    {Name = "⭐ Giới hạn (Limited Only)", Key = "Limited", Rank = 8}
}

-- ── Memory System (Chống dịch chuyển lặp lại) ──
local ProcessedRiverEggs = {} -- [Instance] = os.clock()
local PurchasedCount = 0
local SoldCount = 0
local CachedRemotes = {}
local isBuyingActive = false
local isSellingActive = false

local function isEggProcessed(obj)
    if not obj then return true end
    if ProcessedRiverEggs[obj] then
        if (os.clock() - ProcessedRiverEggs[obj]) < 90 then
            return true
        end
    end
    return false
end

local function markEggProcessed(obj)
    if obj then
        ProcessedRiverEggs[obj] = os.clock()
        PurchasedCount = PurchasedCount + 1
    end
end

-- ── Status Label Callbacks (Chống spam cập nhật UI) ──
local updateStatusUI = function(msg) end
local updateEggCountUI = function(count, bestEgg, boughtTotal, soldTotal) end

local lastStatusMsg = ""
local function setStatus(msg)
    if msg == lastStatusMsg then return end
    lastStatusMsg = msg
    pcall(function()
        updateStatusUI(msg)
    end)
end

-- ── Anti-AFK 24/7 Engine ──
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
end)

-- ── Intelligent Remote Scanner (Tối ưu cực đại: Chỉ quét ReplicatedStorage và lưu cache vĩnh viễn) ──
local function findRemote(patternList)
    for _, pattern in ipairs(patternList) do
        local cached = CachedRemotes[pattern]
        if cached ~= nil then
            if cached ~= false and cached.Parent then
                return cached
            end
        end
    end

    -- Quét duy nhất 1 lần trong ReplicatedStorage (Nơi lưu 99% remote của Roblox, không đụng vào Workspace)
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            local lowerName = desc.Name:lower()
            for _, pattern in ipairs(patternList) do
                if lowerName:find(pattern:lower()) then
                    CachedRemotes[pattern] = desc
                    return desc
                end
            end
        end
    end

    -- Lưu dấu false cho các pattern không có trong game để KHÔNG BAO GIỜ quét lại
    for _, pattern in ipairs(patternList) do
        if CachedRemotes[pattern] == nil then
            CachedRemotes[pattern] = false
        end
    end
    return nil
end

-- ── Instant ProximityPrompt Optimizer ──
local function optimizePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0
        prompt.Enabled = true
        if State.InfiniteRiverRange then
            prompt.MaxActivationDistance = 99999
        end
    end)
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    optimizePrompt(prompt)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 100)
            fireproximityprompt(prompt)
        end
    end)
    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.01)
        prompt:InputHoldEnd()
    end)
end

-- ── DANH SÁCH TỪ KHÓA BỊ CHẶN TUYỆT ĐỐI (SHOP, DROP, TICKET, MÁY MÓC, VẬT PHẨM KHÁC) ──
local SHOP_AND_ITEM_BLACKLIST = {
    -- Shop, Store & Vendors
    "shop", "cửa hàng", "cua hang", "store", "kiosk", "stand", "booth", "stall", "cart",
    -- Egg Drop & Ticket features (EGG DROP SHOP, Golden Drop)
    "drop", "eggdrop", "goldendrop", "ticket", "vé", "ve", "odds", "tỉ lệ", "ti le", "chance", "rate",
    -- Market, Trading, Pedestals & NPCs
    "market", "thị trường", "thi truong", "chợ", "cho", "merchant", "trader", "seller", "dealer", "vendor", "npc", "pedestal",
    -- Gamepasses, Robux & Products
    "pass", "gamepass", "robux", "devproduct", "product", "vip", "premium",
    -- Machines, Incubators & Nests (Máy ấp, tổ chim, bệ ấp)
    "machine", "incubator", "nest", "tổ", "to", "ấp", "ap", "hatch", "crack", "multiplier", "lever", "cần gạt", "can gat",
    -- Pet & Titan showcases
    "titan", "pet", "voi", "companion", "statue", "tượng", "tuong",
    -- Mini games, Spins, Wheels, Crates & Chests
    "spin", "wheel", "roulette", "crate", "box", "chest", "rương", "ruong", "hòm", "hom",
    -- Rebirth, Index & Leaderboards
    "rebirth", "tái sinh", "tai sinh", "index", "mục lục", "muc luc", "leaderboard", "bảng", "bang", "rank", "top",
    -- Quests, Stories & Teleports
    "reward", "gift", "phần thưởng", "phan thuong", "free", "miễn phí", "mien phi", "daily", "quest", "nhiệm vụ", "story", "cốt truyện",
    "door", "gate", "portal", "cổng", "cong", "teleport", "plot", "base", "tycoon", "lobby", "spawn", "zone", "island",
    -- Display & GUI
    "billboard", "surfacegui", "screengui", "sign", "board"
}

local PROMPT_BLACKLIST = {
    "shop", "cửa hàng", "cua hang", "store",
    "drop", "ticket", "vé", "ve", "odds", "tỉ lệ", "ti le",
    "open", "view", "mở", "mo", "xem", "interact", "talk", "nói chuyện",
    "pull", "lever", "gạt", "gat", "hatch", "ấp", "ap",
    "multiplier", "roll", "spin", "wheel", "quay",
    "pass", "robux", "free", "miễn phí", "free in", "need 5",
    "rebirth", "tái sinh", "tai sinh", "sell", "bán", "ban",
    "upgrade", "nâng cấp", "craft", "chế tạo",
    "claim reward", "gift", "daily"
}

-- ── Tự Động Đóng Các Bảng Shop / Popup Bị Mở Nhầm (Siêu nhẹ: Chỉ quét Frame cấp 1 của UI) ──
local function autoCloseShopPopups()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end

    local closedAny = false

    for _, screen in ipairs(pGui:GetChildren()) do
        if screen:IsA("ScreenGui") and screen ~= ScreenGui then
            -- Chỉ kiểm tra các Frame / Dialog hiển thị ở cấp trên cùng
            for _, frame in ipairs(screen:GetChildren()) do
                if (frame:IsA("Frame") or frame:IsA("ImageLabel")) and frame.Visible then
                    local fName = frame.Name:lower()
                    local isShop = false

                    if fName:find("eggdrop") or fName:find("shop") or fName:find("drop") or fName:find("ticket") then
                        isShop = true
                    else
                        for _, child in ipairs(frame:GetChildren()) do
                            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Visible then
                                local txt = child.Text:lower()
                                if txt:find("egg drop shop") or txt:find("golden drop") or txt:find("need 5 tickets") 
                                   or txt:find("ticket a drop") or txt:find("more tickets") then
                                    isShop = true
                                    break
                                end
                            end
                        end
                    end

                    if isShop then
                        for _, btn in ipairs(frame:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                local bName = btn.Name:lower()
                                local bText = btn:IsA("TextButton") and btn.Text:lower() or ""
                                if bName:find("close") or bName:find("exit") or bName == "x" or bName == "closebutton"
                                   or bText == "x" or bText == "✕" or bText == "✖" then
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                        firesignal(btn.Activated)
                                    end
                                    pcall(function()
                                        frame.Visible = false
                                    end)
                                    closedAny = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closedAny
end

-- ── Lọc và phát hiện các khu vực máy / plot của người chơi (Lưu Cache 30s) ──
local CachedExcludedContainers = nil
local lastExcludedScan = 0
local function getExcludedContainers()
    if CachedExcludedContainers and (os.clock() - lastExcludedScan < 30) then
        return CachedExcludedContainers
    end
    lastExcludedScan = os.clock()
    CachedExcludedContainers = {}
    for _, desc in ipairs(Workspace:GetChildren()) do
        local n = desc.Name:lower()
        for _, bName in ipairs(SHOP_AND_ITEM_BLACKLIST) do
            if n:find(bName) then
                table.insert(CachedExcludedContainers, desc)
                break
            end
        end
    end
    return CachedExcludedContainers
end

-- ── Đánh giá độ hiếm chính xác theo Index game ──
local function evaluateEggRarity(obj)
    local bestRank = 1
    local bestRarityKey = "Common"
    local bestRarityName = "Thường"

    local function checkText(str)
        if not str then return end
        local lower = str:lower()

        -- Bỏ qua text quảng cáo hoặc tỉ lệ của shop/drop
        if lower:find("drop") or lower:find("ticket") or lower:find("odds") or lower:find("belt eggs") or lower:find("free in") then
            return
        end

        -- 8. Giới hạn (Limited / Exclusive)
        if lower:find("giới hạn") or lower:find("gioi han") or lower:find("limited") or lower:find("exclusive") then
            if 8 > bestRank then bestRank = 8; bestRarityKey = "Limited"; bestRarityName = "Giới hạn" end
        -- 7. Bật mí (Secret / Supreme)
        elseif lower:find("bật mí") or lower:find("bat mi") or lower:find("secret") or lower:find("supreme") or lower:find("bí mật") or lower:find("tối thượng") then
            if 7 > bestRank then bestRank = 7; bestRarityKey = "Secret"; bestRarityName = "Bật mí" end
        -- 6. Huyền thoại (Mythic / Thần thoại)
        elseif lower:find("mythic") or lower:find("thần thoại") or lower:find("than thoai") or lower:find("divine") or lower:find("thần thánh") then
            if 6 > bestRank then bestRank = 6; bestRarityKey = "Mythic"; bestRarityName = "Huyền thoại (Mythic)" end
        -- 5. Huyền thoại (Legendary)
        elseif lower:find("huyền thoại") or lower:find("huyen thoai") or lower:find("legendary") or lower:find("golden") or lower:find("vàng") then
            if 5 > bestRank then bestRank = 5; bestRarityKey = "Legendary"; bestRarityName = "Huyền thoại" end
        -- 4. Huyền tuyệt (Epic)
        elseif lower:find("huyền tuyệt") or lower:find("huyen tuyet") or lower:find("epic") or lower:find("sử thi") or lower:find("tím") then
            if 4 > bestRank then bestRank = 4; bestRarityKey = "Epic"; bestRarityName = "Huyền tuyệt" end
        -- 3. Hiếm (Rare)
        elseif lower:find("hiếm") or lower:find("hiem") or lower:find("rare") or lower:find("lam") then
            if 3 > bestRank then bestRank = 3; bestRarityKey = "Rare"; bestRarityName = "Hiếm" end
        -- 2. Không phổ biến (Uncommon)
        elseif lower:find("không phổ biến") or lower:find("khong pho bien") or lower:find("bất thường") or lower:find("uncommon") or lower:find("lục") then
            if 2 > bestRank then bestRank = 2; bestRarityKey = "Uncommon"; bestRarityName = "Không phổ biến" end
        -- 1. Thường (Common)
        elseif lower:find("thường") or lower:find("thuong") or lower:find("common") or lower:find("phổ biến") then
            if 1 >= bestRank then bestRank = 1; bestRarityKey = "Common"; bestRarityName = "Thường" end
        end
    end

    checkText(obj.Name)

    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
    if prompt then
        checkText(prompt.ObjectText)
        checkText(prompt.ActionText)
    end

    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            checkText(desc.Text)
        elseif desc:IsA("StringValue") then
            checkText(desc.Value)
        end
    end

    pcall(function()
        for attrName, attrVal in pairs(obj:GetAttributes()) do
            checkText(tostring(attrName))
            checkText(tostring(attrVal))
        end
    end)

    return bestRarityKey, bestRank, bestRarityName
end

-- ── Kiểm tra nghiêm ngặt: Có đúng là trứng trên dòng sông không? (CHỐNG CLICK NHẦM SHOP) ──
local function verifyRiverEgg(obj, excludedList)
    if not obj or not obj.Parent then return false, "No parent" end
    if isEggProcessed(obj) then return false, "Already processed" end

    -- Không phải là nhân vật người chơi
    if obj:FindFirstAncestorOfClass("Player") then
        return false, "In player character"
    end

    local oName = obj.Name:lower()

    -- 1. KIỂM TRA TÊN VẬT THỂ: Loại bỏ triệt để shop, egg drop, ticket, machine, titan/pet, v.v.
    for _, bWord in ipairs(SHOP_AND_ITEM_BLACKLIST) do
        if oName:find(bWord) then
            return false, "Blacklisted object name: " .. obj.Name .. " (" .. bWord .. ")"
        end
    end

    -- 2. KIỂM TRA TOÀN BỘ CÂY TỔ TIÊN (Từ Parent lên tận Workspace)
    local cur = obj.Parent
    while cur and cur ~= Workspace do
        local cName = cur.Name:lower()
        for _, bWord in ipairs(SHOP_AND_ITEM_BLACKLIST) do
            if cName:find(bWord) then
                return false, "In blacklisted container: " .. cur.Name .. " (" .. bWord .. ")"
            end
        end
        for _, ex in ipairs(excludedList) do
            if cur == ex then
                return false, "In excluded container: " .. ex.Name
            end
        end
        cur = cur.Parent
    end

    -- 3. KIỂM TRA ĐỘ PHỨC TẠP CỦA MODEL (Trứng sông <= 25 chi tiết; Shop/Tòa nhà/Bệ đỡ >= 30 chi tiết)
    if obj:IsA("Model") then
        local descCount = #obj:GetDescendants()
        if descCount > 25 then
            return false, "Structure model too complex (" .. descCount .. " parts), not a river egg"
        end
    end

    -- 4. KIỂM TRA PROXIMITY PROMPT / CLICK DETECTOR
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
    local cd = obj:FindFirstChildOfClass("ClickDetector") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ClickDetector", true))

    if not prompt and not cd then
        return false, "No prompt or click detector"
    end

    -- 5. KIỂM TRA NỘI DUNG PROMPT: Loại trừ ActionText & ObjectText của Shop, Drop, Ticket, Máy
    if prompt then
        local act = (prompt.ActionText or ""):lower()
        local objText = (prompt.ObjectText or ""):lower()
        local combinedPrompt = act .. " " .. objText

        for _, pbWord in ipairs(PROMPT_BLACKLIST) do
            if combinedPrompt:find(pbWord) then
                return false, "Blacklisted prompt action/object: " .. combinedPrompt .. " (" .. pbWord .. ")"
            end
        end
    end

    -- 6. KIỂM TRA NỘI DUNG TEXT TRONG GUI/BILLBOARD (Chỉ quét nếu có BillboardGui/SurfaceGui)
    if obj:FindFirstChildWhichIsA("BillboardGui", true) or obj:FindFirstChildWhichIsA("SurfaceGui", true) then
        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local t = desc.Text:lower()
                if t:find("egg drop") or t:find("golden drop") or t:find("tickets") 
                   or t:find("shop") or t:find("odds") or t:find("free in") or t:find("robux")
                   or t:find("cửa hàng") or t:find("tỉ lệ") then
                    return false, "Contains shop text in GUI: " .. desc.Text
                end
            end
        end
    end

    -- 7. TÌM BASEPART VẬT LÝ
    local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
    if not part then
        return false, "No physical part"
    end

    return true, "Valid River Egg", part, prompt, cd
end

-- ── Bộ Nhớ Đệm Container Dòng Sông (Giảm 99.9% tải CPU - Không quét lại Map liên tục) ──
local CachedRiverContainers = nil
local lastContainerScanTime = 0

local function getRiverContainers()
    if CachedRiverContainers and (os.clock() - lastContainerScanTime < 15) then
        return CachedRiverContainers
    end
    lastContainerScanTime = os.clock()
    CachedRiverContainers = {}

    local candidateNames = {"belt", "river", "conveyor", "stream", "belteggs", "rivereggs", "spawnedeggs", "movingeggs", "eggs"}

    for _, child in ipairs(Workspace:GetChildren()) do
        local cName = child.Name:lower()
        for _, cand in ipairs(candidateNames) do
            if cName:find(cand) and not cName:find("shop") and not cName:find("market") and not cName:find("plot") then
                table.insert(CachedRiverContainers, child)
                break
            end
        end
    end

    local mapFolder = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("MapFolder")
    if mapFolder then
        for _, child in ipairs(mapFolder:GetChildren()) do
            local cName = child.Name:lower()
            for _, cand in ipairs(candidateNames) do
                if cName:find(cand) and not cName:find("shop") and not cName:find("market") then
                    table.insert(CachedRiverContainers, child)
                    break
                end
            end
        end
    end

    return CachedRiverContainers
end

-- ── Quét danh sách trứng thực sự đang trôi trên sông (SIÊU TỐI ƯU 60 FPS) ──
local function getRiverEggs()
    local riverEggs = {}
    local excludedList = getExcludedContainers()
    local minRank = MinRarityPresets[State.MinRiverRarityIndex].Rank

    local totalEggsFound = 0
    local highestEggFound = nil
    local highestEggRank = 0

    local checkedObjects = {}
    local riverContainers = getRiverContainers()

    local function processCandidate(obj)
        if not obj or checkedObjects[obj] then return end
        checkedObjects[obj] = true

        if (obj:IsA("Model") or obj:IsA("BasePart")) then
            local oName = obj.Name:lower()
            local isNameEgg = oName:find("egg") or oName:find("trứng") or oName:find("belt")
            if isNameEgg or (#riverContainers > 0 and obj.Parent and obj.Parent ~= Workspace) then
                local isValid, reason, part, prompt, cd = verifyRiverEgg(obj, excludedList)
                if isValid then
                    totalEggsFound = totalEggsFound + 1
                    local rKey, rank, rName = evaluateEggRarity(obj)
                    
                    if rank > highestEggRank then
                        highestEggRank = rank
                        highestEggFound = rName
                    end

                    local shouldBuy = false
                    if State.BuyRarities[rKey] then
                        shouldBuy = true
                    elseif rank >= minRank then
                        shouldBuy = true
                    end

                    if shouldBuy then
                        table.insert(riverEggs, {
                            Instance = obj,
                            Part = part,
                            Prompt = prompt,
                            ClickDetector = cd,
                            RarityKey = rKey,
                            RarityName = rName,
                            Rank = rank
                        })
                    end
                end
            end
        end
    end

    -- 1. Nếu tìm thấy container sông / băng chuyền: CHỈ QUÉT NỘI DUNG CONTAINER ĐÓ (Siêu nhẹ, chỉ vài chục part)
    if #riverContainers > 0 then
        for _, container in ipairs(riverContainers) do
            for _, child in ipairs(container:GetChildren()) do
                processCandidate(child)
                if child:IsA("Model") or child:IsA("Folder") then
                    for _, subChild in ipairs(child:GetChildren()) do
                        processCandidate(subChild)
                    end
                end
            end
        end
    else
        -- 2. Nếu không có folder sông, CHỈ QUÉT CON TRỰC TIẾP CỦA WORKSPACE (Tuyệt đối không GetDescendants 50.000 part)
        for _, obj in ipairs(Workspace:GetChildren()) do
            local oName = obj.Name:lower()
            if oName:find("egg") or oName:find("trứng") or oName:find("belt") then
                processCandidate(obj)
            end
        end
    end

    pcall(function()
        updateEggCountUI(totalEggsFound, highestEggFound or "Chưa có", PurchasedCount, SoldCount)
    end)

    table.sort(riverEggs, function(a, b)
        return a.Rank > b.Rank
    end)

    return riverEggs
end

-- ── Thực hiện mua 1 quả trứng duy nhất (Chỉ bay 1 lần, tuyệt đối không gọi remote shop) ──
local function buySingleRiverEgg(eggData, isManualTest)
    if isBuyingActive then return false end
    isBuyingActive = true

    local obj = eggData.Instance
    local part = eggData.Part
    local prompt = eggData.Prompt
    local cd = eggData.ClickDetector
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp or not part or not part.Parent then
        isBuyingActive = false
        return false
    end

    markEggProcessed(obj)

    local originalCFrame = hrp.CFrame
    local didTeleport = false

    -- 1. DỊCH CHUYỂN ĐÚNG 1 LẦN
    if State.AutoTpToRiverEgg or isManualTest then
        setStatus("🚀 Bay đến trứng sông: " .. obj.Name .. " [" .. eggData.RarityName .. "] (1 Lần)")
        
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.2, 0))
        didTeleport = true
        task.wait(0.12)
    else
        setStatus("⚡ Mua từ xa: " .. obj.Name .. " [" .. eggData.RarityName .. "]")
    end

    -- 2. KÍCH HOẠT PROXIMITY PROMPT (Cơ chế thu thập chính quy trên sông)
    if prompt then
        if State.InfiniteRiverRange then
            prompt.RequiresLineOfSight = false
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 99999
        end
        triggerPrompt(prompt)
    end

    -- 3. KÍCH HOẠT CLICK DETECTOR
    if cd and fireclickdetector then
        fireclickdetector(cd, 0)
        fireclickdetector(cd)
    end

    -- 4. BẮN REMOTE EVENT MUA TRỨNG SÔNG CHUYÊN BIỆT (TUYỆT ĐỐI KHÔNG BẮN REMOTE 'buyegg' CỦA SHOP)
    local riverRemote = findRemote({"buyriveregg", "riveregg", "claimriveregg", "buyriver", "claimbeltegg", "takebeltegg", "beltegg", "buybelt", "takeegg"})
    if riverRemote then
        pcall(function()
            if riverRemote:IsA("RemoteEvent") then
                riverRemote:FireServer(obj)
            elseif riverRemote:IsA("RemoteFunction") then
                riverRemote:InvokeServer(obj)
            end
        end)
    end

    task.wait(0.12)

    -- 5. TỰ ĐỘNG ĐÓNG POPUP SHOP NẾU VÔ TÌNH BẬT MỞ
    if State.AutoCloseShopPopups then
        pcall(function()
            autoCloseShopPopups()
        end)
    end

    -- 6. QUAY VỀ VỊ TRÍ CŨ NẾU BẬT AUTO RETURN
    if didTeleport and State.AutoReturnToBase and originalCFrame then
        setStatus("🔙 Đã mua xong! Đang quay lại vị trí ban đầu...")
        task.wait(0.08)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = originalCFrame
    end

    setStatus("✅ ĐÃ MUA THÀNH CÔNG: " .. obj.Name .. " [" .. eggData.RarityName .. "] (Đã ghi nhớ, không dịch chuyển lại)")
    
    task.wait(0.25)
    isBuyingActive = false
    return true
end

-- ═══════════════════════════════════════════════════════════
-- 🔥 CHU TRÌNH BÁN TẤT CẢ TRỨNG (BẤM BÁN ➔ BÁN TẤT CẢ ➔ XÁC NHẬN)
-- ═══════════════════════════════════════════════════════════

-- Bước 1: Mở menu Người bán trứng (Bấm chữ [Bán] trên thanh bar hoặc tương tác Prompt)
local function openSellMarketUI()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end

    local opened = false

    -- Cách 1: Tìm nút chữ [Bán] màu xanh trên thanh TopBar
    for _, btn in ipairs(pGui:GetDescendants()) do
        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and not btn:IsDescendantOf(ScreenGui) then
            local text = btn:IsA("TextButton") and btn.Text or ""
            local lowerText = text:lower():gsub("%s+", "")
            local lowerName = btn.Name:lower()

            -- Tránh tuyệt đối click nhầm các nút Cửa Hàng, Tái Sinh, Mục Lục, Pass
            if lowerName:find("shop") or lowerName:find("store") or lowerName:find("cart") 
               or lowerText:find("cửa hàng") or lowerText:find("tái sinh") or lowerText:find("mục lục")
               or lowerText:find("pass") or lowerName:find("rebirth") then
                continue
            end

            if lowerText == "bán" or lowerText == "ban" or lowerName == "sell" or lowerName == "sellbutton" or lowerName == "btn_sell" then
                if firesignal then
                    firesignal(btn.MouseButton1Click)
                    firesignal(btn.Activated)
                end
                opened = true
                break
            end
        end
    end

    -- Cách 2: Tương tác với ProximityPrompt của Thị trường trứng (Egg Market - Sell Eggs)
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local act = (prompt.ActionText or ""):lower()
            local obj = (prompt.ObjectText or ""):lower()
            -- Không tương tác nếu có từ khóa buy, drop, ticket, shop
            if (act:find("sell") or act:find("bán") or obj:find("market") or obj:find("thị trường"))
               and not act:find("buy") and not act:find("drop") and not act:find("ticket") and not act:find("shop") then
                triggerPrompt(prompt)
                opened = true
                break
            end
        end
    end

    return opened
end

-- Bước 2: Bấm chọn dòng [2. Bán tất cả trứng] trong bảng "Người bán trứng"
local function clickOptionSellAllEggs()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end

    -- Tìm theo nội dung text hiển thị
    for _, desc in ipairs(pGui:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and not desc:IsDescendantOf(ScreenGui) then
            local text = desc.Text:lower()
            if text:find("bán tất cả trứng") or text:find("ban tat ca trung") or text:find("sell all eggs") then
                local btn = desc:IsA("TextButton") and desc or desc:FindFirstAncestorWhichIsA("TextButton") or desc:FindFirstAncestorWhichIsA("ImageButton")
                if btn and firesignal then
                    firesignal(btn.MouseButton1Click)
                    firesignal(btn.Activated)
                    return true
                end
            end
        end
    end

    -- Tìm theo tên Button / Option 2 trong dialog
    for _, desc in ipairs(pGui:GetDescendants()) do
        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and not desc:IsDescendantOf(ScreenGui) then
            local n = desc.Name:lower()
            if n == "option2" or n == "choice2" or n == "button2" or n == "2" then
                if firesignal then
                    firesignal(desc.MouseButton1Click)
                    firesignal(desc.Activated)
                    return true
                end
            end
        end
    end

    return false
end

-- Bước 3: Bấm chọn xác nhận [1. Có, bán chúng đi]
local function clickConfirmSellAll()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end

    -- Tìm theo nội dung text hiển thị xác nhận
    for _, desc in ipairs(pGui:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and not desc:IsDescendantOf(ScreenGui) then
            local text = desc.Text:lower()
            if text:find("có, bán chúng đi") or text:find("co, ban chung di") or text:find("bán chúng đi") or text:find("yes, sell them") then
                local btn = desc:IsA("TextButton") and desc or desc:FindFirstAncestorWhichIsA("TextButton") or desc:FindFirstAncestorWhichIsA("ImageButton")
                if btn and firesignal then
                    firesignal(btn.MouseButton1Click)
                    firesignal(btn.Activated)
                    return true
                end
            end
        end
    end

    -- Tìm theo tên Option 1 / Confirm Button
    for _, desc in ipairs(pGui:GetDescendants()) do
        if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and not desc:IsDescendantOf(ScreenGui) then
            local n = desc.Name:lower()
            if n == "option1" or n == "choice1" or n == "button1" or n == "confirm" or n == "yes" then
                if firesignal then
                    firesignal(desc.MouseButton1Click)
                    firesignal(desc.Activated)
                    return true
                end
            end
        end
    end

    return false
end

-- Toàn bộ chu trình Bán Tất Cả Trứng
local function executeSellAllFlow()
    if isSellingActive then return false end
    isSellingActive = true

    setStatus("💰 [Bước 1/3] Đang bấm nút [Bán] trên thanh công cụ...")
    openSellMarketUI()
    task.wait(0.2)

    setStatus("💰 [Bước 2/3] Đang chọn [2. Bán tất cả trứng]...")
    local step2 = clickOptionSellAllEggs()
    if not step2 then
        task.wait(0.15)
        step2 = clickOptionSellAllEggs()
    end
    task.wait(0.25)

    setStatus("💰 [Bước 3/3] Đang xác nhận [1. Có, bán chúng đi]...")
    local step3 = clickConfirmSellAll()
    if not step3 then
        task.wait(0.15)
        step3 = clickConfirmSellAll()
    end

    -- Bắn Remote dự phòng nếu có
    local sellAllRemote = findRemote({"sellall", "sellegg", "selleggs", "dialogue", "eggmarket", "selleverything", "sellinv"})
    if sellAllRemote then
        pcall(function()
            if sellAllRemote:IsA("RemoteEvent") then
                sellAllRemote:FireServer(2)
                sellAllRemote:FireServer("SellAllEggs")
                sellAllRemote:FireServer(1)
                sellAllRemote:FireServer(true)
            elseif sellAllRemote:IsA("RemoteFunction") then
                sellAllRemote:InvokeServer(2)
                sellAllRemote:InvokeServer(1)
            end
        end)
    end

    SoldCount = SoldCount + 1
    setStatus("✅ ĐÃ BÁN TẤT CẢ TRỨNG THÀNH CÔNG! (Bán ➔ Bán tất cả ➔ Có, bán chúng đi)")
    
    task.wait(0.3)
    isSellingActive = false
    return true
end

-- ═══════════════════════════════════════════════════════════
-- 💰 BÁN THEO ĐỘ HIẾM CHỌN (SELECTIVE SELL)
-- ═══════════════════════════════════════════════════════════

local CachedSellZones = nil
local lastSellZoneScan = 0
local function getSellZones()
    if CachedSellZones and #CachedSellZones > 0 and (os.clock() - lastSellZoneScan < 60) then
        return CachedSellZones
    end
    lastSellZoneScan = os.clock()
    CachedSellZones = {}

    local function checkContainer(container)
        if not container then return end
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("BasePart") and not obj:FindFirstAncestorOfClass("Player") then
                local n = obj.Name:lower()
                if n:find("sell") or n:find("bán") or n:find("deposit") or n:find("cashin") then
                    table.insert(CachedSellZones, obj)
                end
            end
        end
    end

    checkContainer(Workspace)
    checkContainer(Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Buildings"))
    return CachedSellZones
end

local function getSellableItems()
    local sellable = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local sources = {backpack, char}

    for _, container in ipairs(sources) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") or item:IsA("Folder") then
                    local rKey, rank, rName = evaluateEggRarity(item)
                    if State.SellRarities[rKey] == true then
                        table.insert(sellable, {
                            Instance = item,
                            RarityKey = rKey,
                            RarityName = rName,
                            Rank = rank
                        })
                    end
                end
            end
        end
    end
    return sellable
end

local function executeSelectiveSell()
    if isSellingActive then return end
    isSellingActive = true

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local sellableItems = getSellableItems()

    for _, sItem in ipairs(sellableItems) do
        local tool = sItem.Instance
        if tool:IsA("Tool") and hum and tool.Parent == LocalPlayer:FindFirstChild("Backpack") then
            pcall(function()
                hum:EquipTool(tool)
            end)
            task.wait(0.04)
        end
    end

    if hrp then
        local sellZones = getSellZones()
        for _, zone in ipairs(sellZones) do
            pcall(function()
                if firetouchinterest then
                    firetouchinterest(hrp, zone, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, zone, 1)
                end
            end)
        end
    end

    local sellRemote = findRemote({"sellegg", "selleggs", "sellall", "sell", "sellinv", "sellinventory", "sellitem", "cashin"})
    if sellRemote then
        pcall(function()
            if sellRemote:IsA("RemoteEvent") then
                for _, sItem in ipairs(sellableItems) do
                    sellRemote:FireServer(sItem.Instance)
                    sellRemote:FireServer(sItem.Instance.Name)
                end
                sellRemote:FireServer()
                sellRemote:FireServer("Sell")
            elseif sellRemote:IsA("RemoteFunction") then
                for _, sItem in ipairs(sellableItems) do
                    sellRemote:InvokeServer(sItem.Instance)
                end
                sellRemote:InvokeServer()
            end
        end)
    end

    SoldCount = SoldCount + 1
    setStatus("💰 Đã kích hoạt bán trứng theo độ hiếm chọn!")

    task.wait(0.3)
    isSellingActive = false
end

-- ═══════════════════════════════════════════════════════════
-- ⚙️ BACKGROUND LOOPS
-- ═══════════════════════════════════════════════════════════

-- 1. Auto Buy River Eggs Loop (Tần suất tối ưu 0.6s - Siêu nhẹ, không giật lag)
task.spawn(function()
    while true do
        task.wait(0.6)
        if State.AutoBuyRiverEggs and not isBuyingActive then
            pcall(function()
                local eggs = getRiverEggs()

                if #eggs == 0 then
                    setStatus("🌊 Đang quan sát dòng sông... (Chưa có trứng phù hợp tiêu chí)")
                    return
                end

                local targetEgg = nil
                for _, eggData in ipairs(eggs) do
                    if not isEggProcessed(eggData.Instance) then
                        targetEgg = eggData
                        break
                    end
                end

                if targetEgg then
                    buySingleRiverEgg(targetEgg, false)
                end
            end)
        end
    end
end)

-- 2. Auto Sell All Eggs Loop (Chạy chu trình Bán ➔ Bán tất cả ➔ Xác nhận mỗi 3.5s)
task.spawn(function()
    while true do
        task.wait(3.5)
        if State.AutoSellAllEggs and not isSellingActive then
            pcall(function()
                executeSellAllFlow()
            end)
        end
    end
end)

-- 3. Auto Selective Sell Loop (Bán theo độ hiếm chọn mỗi 2.0s)
task.spawn(function()
    while true do
        task.wait(2.0)
        if State.AutoSellByRarity and not isSellingActive then
            pcall(function()
                executeSelectiveSell()
            end)
        end
    end
end)

-- 4. Auto Close Unwanted Shop Popups Loop (Kiểm tra nhẹ nhàng mỗi 1.5s)
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoCloseShopPopups then
            pcall(function()
                autoCloseShopPopups()
            end)
        end
    end
end)

-- ── Chế độ Tối ưu Đồ họa (FPS Booster 60 FPS) ──
local function toggleFPSBooster(enable)
    pcall(function()
        local lighting = game:GetService("Lighting")
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        
        if enable then
            pcall(function() settings().Rendering.QualityLevel = 1 end)
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            
            for _, v in ipairs(Workspace:GetChildren()) do
                if v:IsA("Model") or v:IsA("Folder") then
                    for _, p in ipairs(v:GetChildren()) do
                        if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Smoke") or p:IsA("Fire") or p:IsA("Sparkles") then
                            p.Enabled = false
                        end
                    end
                end
            end
            setStatus("⚡ Đã BẬT Chế Độ Siêu Mượt (FPS Booster)! Giảm tải để đạt 60 FPS.")
        else
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
            if lighting then
                lighting.GlobalShadows = true
            end
            setStatus("ℹ️ Đã TẮT Chế Độ Siêu Mượt.")
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 🎨 GIAO DIỆN CHUYÊN BIỆT (RIVER EGG AUTO-BUY & SELL HUB UI V2.5)
-- ═══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HatchOrCrackRiverHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiContainer()

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 325, 0, 480)
MainFrame.Position = UDim2.new(0.5, -162, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 210, 255)
MainStroke.Thickness = 1.8
MainStroke.Parent = MainFrame

-- Draggable Logic for MainFrame
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 42)
Topbar.BackgroundColor3 = Color3.fromRGB(18, 28, 42)
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarBottomFill = Instance.new("Frame")
TopbarBottomFill.Size = UDim2.new(1, 0, 0, 10)
TopbarBottomFill.Position = UDim2.new(0, 0, 1, -10)
TopbarBottomFill.BackgroundColor3 = Color3.fromRGB(18, 28, 42)
TopbarBottomFill.BorderSizePixel = 0
TopbarBottomFill.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌊 MUA & BÁN TRỨNG SÔNG V2.5"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -68, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 48, 68)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 14
MinBtn.Parent = Topbar
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Topbar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

-- Floating Toggle Icon Button (Mobile / Delta)
local FloatingToggle = Instance.new("ImageButton")
FloatingToggle.Name = "RiverEggFloatingToggle"
FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
FloatingToggle.Position = UDim2.new(0, 20, 0.4, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(13, 20, 30)
FloatingToggle.Visible = false
FloatingToggle.Parent = ScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = FloatingToggle

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(0, 210, 255)
floatStroke.Thickness = 2
floatStroke.Parent = FloatingToggle

local floatLabel = Instance.new("TextLabel")
floatLabel.Size = UDim2.new(1, 0, 1, 0)
floatLabel.BackgroundTransparency = 1
floatLabel.Text = "🌊"
floatLabel.TextSize = 24
floatLabel.Parent = FloatingToggle

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingToggle.Visible = true
end)

FloatingToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingToggle.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable Floating Toggle
local fDragging, fDragStart, fStartPos
FloatingToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fDragStart = input.Position
        fStartPos = FloatingToggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                fDragging = false
            end
        end)
    end
end)
FloatingToggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if fDragging then
            local delta = input.Position - fDragStart
            FloatingToggle.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end
end)

-- Live River Stats Banner
local StatsBanner = Instance.new("Frame")
StatsBanner.Name = "StatsBanner"
StatsBanner.Size = UDim2.new(1, -16, 0, 34)
StatsBanner.Position = UDim2.new(0, 8, 0, 48)
StatsBanner.BackgroundColor3 = Color3.fromRGB(18, 28, 42)
StatsBanner.BorderSizePixel = 0
StatsBanner.Parent = MainFrame

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 6)
sbCorner.Parent = StatsBanner

local sbStroke = Instance.new("UIStroke")
sbStroke.Color = Color3.fromRGB(0, 210, 255)
sbStroke.Thickness = 1.2
sbStroke.Parent = StatsBanner

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -12, 1, 0)
StatsLabel.Position = UDim2.new(0, 8, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "🌊 Sông: [ 0 ] | [ - ] | Mua: [ 0 ] | Bán: [ 0 ]"
StatsLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.TextSize = 11
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = StatsBanner

local lastCount, lastBest, lastBought, lastSold = -1, "", -1, -1
updateEggCountUI = function(count, bestEgg, boughtTotal, soldTotal)
    if count == lastCount and bestEgg == lastBest and boughtTotal == lastBought and soldTotal == lastSold then
        return
    end
    lastCount, lastBest, lastBought, lastSold = count, bestEgg, boughtTotal, soldTotal
    StatsLabel.Text = "🌊 Sông: [" .. tostring(count) .. "] | " .. tostring(bestEgg) .. " | Mua: [" .. tostring(boughtTotal) .. "] | Bán: [" .. tostring(soldTotal) .. "]"
end

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -16, 0, 26)
StatusBar.Position = UDim2.new(0, 8, 1, -32)
StatusBar.BackgroundColor3 = Color3.fromRGB(18, 28, 42)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 1, 0)
StatusLabel.Position = UDim2.new(0, 6, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Sẵn sàng | Đang quan sát dòng sông..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 210, 230)
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

updateStatusUI = function(msg)
    StatusLabel.Text = tostring(msg)
end

-- Scroll Content Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ScrollContent"
Scroll.Size = UDim2.new(1, -16, 1, -126)
Scroll.Position = UDim2.new(0, 8, 0, 88)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 210, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1420)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

-- ── UI Component Helpers ──
local function createSectionHeader(titleText, color)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Text = " " .. titleText
    header.TextColor3 = color or Color3.fromRGB(0, 230, 255)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = Scroll
    return header
end

local function createToggle(title, defaultVal, callback, activeColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(20, 30, 44)
    frame.BorderSizePixel = 0
    frame.Parent = Scroll

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(240, 245, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local onCol = activeColor or Color3.fromRGB(0, 210, 255)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -48, 0.5, -11)
    btn.BackgroundColor3 = defaultVal and onCol or Color3.fromRGB(45, 58, 75)
    btn.Text = defaultVal and "ON" or "OFF"
    btn.TextColor3 = defaultVal and Color3.fromRGB(15, 20, 28) or Color3.fromRGB(180, 190, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 5)
    bCorner.Parent = btn

    local currentVal = defaultVal
    btn.MouseButton1Click:Connect(function()
        currentVal = not currentVal
        btn.BackgroundColor3 = currentVal and onCol or Color3.fromRGB(45, 58, 75)
        btn.Text = currentVal and "ON" or "OFF"
        btn.TextColor3 = currentVal and Color3.fromRGB(15, 20, 28) or Color3.fromRGB(180, 190, 200)
        pcall(callback, currentVal)
    end)
    return frame
end

local function createActionButton(title, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(24, 36, 52)
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 1: BÁN TẤT CẢ TRỨNG (THEO 3 HÌNH GAME) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🔥 BÁN TẤT CẢ TRỨNG (CHUẨN MENU GAME)", Color3.fromRGB(255, 170, 0))

createActionButton("🔥 BÁN TẤT CẢ TRỨNG NGAY (SELL ALL NOW)", Color3.fromRGB(180, 60, 20), function()
    executeSellAllFlow()
end)

createToggle("⚡ Auto Bán Tất Cả Trứng (Tự Bán ➔ Xác Nhận)", State.AutoSellAllEggs, function(val)
    State.AutoSellAllEggs = val
    setStatus(val and "⚡ Đã BẬT Auto Bán Tất Cả Trứng (Chu trình Bán ➔ Bán tất cả ➔ Xác nhận)!" or "⏸️ Đã TẮT Auto Bán Tất Cả.")
end, Color3.fromRGB(255, 170, 0))

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 2: AUTO MUA TRỨNG TRÊN SÔNG (RIVER BUY) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🌊 AUTO MUA TRỨNG TRÊN SÔNG", Color3.fromRGB(0, 220, 255))

createToggle("🌊 Bật Auto Mua Trứng Sông", State.AutoBuyRiverEggs, function(val)
    State.AutoBuyRiverEggs = val
    setStatus(val and "🌊 Đã BẬT Auto Mua Trứng Trên Sông!" or "⏸️ Đã TẮT Auto Mua Trứng.")
end)

-- Min Rarity Cycle Button
local btnMinRarity = Instance.new("TextButton")
btnMinRarity.Size = UDim2.new(1, -4, 0, 32)
btnMinRarity.BackgroundColor3 = Color3.fromRGB(24, 36, 52)
btnMinRarity.Text = "🎯 Mua Từ Mức: [ " .. MinRarityPresets[State.MinRiverRarityIndex].Name .. " ]"
btnMinRarity.TextColor3 = Color3.fromRGB(255, 215, 0)
btnMinRarity.Font = Enum.Font.SourceSansBold
btnMinRarity.TextSize = 12
btnMinRarity.Parent = Scroll
local mrCorner = Instance.new("UICorner")
mrCorner.CornerRadius = UDim.new(0, 6)
mrCorner.Parent = btnMinRarity

btnMinRarity.MouseButton1Click:Connect(function()
    State.MinRiverRarityIndex = (State.MinRiverRarityIndex % #MinRarityPresets) + 1
    local r = MinRarityPresets[State.MinRiverRarityIndex]
    btnMinRarity.Text = "🎯 Mua Từ Mức: [ " .. r.Name .. " ]"
    setStatus("🎯 Đã chọn mua trứng từ mốc: " .. r.Name)
end)

createToggle("🚀 Tự Bay Cạnh Trứng (Chỉ 1 Lần / Quả)", State.AutoTpToRiverEgg, function(val)
    State.AutoTpToRiverEgg = val
    setStatus(val and "🚀 Đã BẬT Auto TP đến trứng sông (1 lần duy nhất/quả)." or "Đã TẮT Auto TP.")
end)

createToggle("🔙 Tự Quay Về Chỗ Cũ Sau Khi Mua", State.AutoReturnToBase, function(val)
    State.AutoReturnToBase = val
    setStatus(val and "🔙 Đã BẬT: Mua xong sẽ tự động bay về chỗ cũ." or "Đã TẮT tự quay về.")
end)

createToggle("⚡ Mua Tầm Xa Vô Hạn (Infinite Range)", State.InfiniteRiverRange, function(val)
    State.InfiniteRiverRange = val
end)

createToggle("🛡️ Tự Đóng Shop Popup Mở Nhầm", State.AutoCloseShopPopups, function(val)
    State.AutoCloseShopPopups = val
    setStatus(val and "🛡️ Đã BẬT: Tự động đóng mọi popup shop nếu vô tình mở nhầm!" or "Đã TẮT tự đóng popup.")
end)

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 3: BÁN THEO ĐỘ HIẾM CHỌN (CHỈ ĐƯỢC BÁN) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("💰 BÁN THEO ĐỘ HIẾM (CHỈ ĐƯỢC BÁN)", Color3.fromRGB(255, 200, 0))

createToggle("💰 Bật Bán Theo Độ Hiếm Chọn", State.AutoSellByRarity, function(val)
    State.AutoSellByRarity = val
    setStatus(val and "💰 Đã BẬT Auto Bán Trứng (Chỉ bán độ hiếm cho phép)!" or "⏸️ Đã TẮT Bán Theo Độ Hiếm.")
end, Color3.fromRGB(255, 200, 0))

createActionButton("💰 Bán Trứng Đã Lọc (Sell Selected Once)", Color3.fromRGB(150, 100, 20), function()
    setStatus("💰 Đang bán các trứng theo độ hiếm cho phép...")
    executeSelectiveSell()
end)

createSectionHeader("🎯 ĐỘ HIẾM CHỈ ĐƯỢC BÁN (THEO GAME):", Color3.fromRGB(255, 215, 0))

createToggle("⚪ Bán Thường (Common)", State.SellRarities.Common, function(val)
    State.SellRarities.Common = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🟢 Bán Không phổ biến (Uncommon)", State.SellRarities.Uncommon, function(val)
    State.SellRarities.Uncommon = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🔵 Bán Hiếm (Rare)", State.SellRarities.Rare, function(val)
    State.SellRarities.Rare = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🟣 Bán Huyền tuyệt (Epic) [Khóa an toàn]", State.SellRarities.Epic, function(val)
    State.SellRarities.Epic = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🟠 Bán Huyền thoại [Khóa an toàn]", State.SellRarities.Legendary, function(val)
    State.SellRarities.Legendary = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🔴 Bán Huyền thoại (Mythic) [Khóa an toàn]", State.SellRarities.Mythic, function(val)
    State.SellRarities.Mythic = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🌈 Bán Bật mí (Secret) [Khóa an toàn]", State.SellRarities.Secret, function(val)
    State.SellRarities.Secret = val
end, Color3.fromRGB(255, 70, 70))

createToggle("⭐ Bán Giới hạn (Limited) [Khóa an toàn]", State.SellRarities.Limited, function(val)
    State.SellRarities.Limited = val
end, Color3.fromRGB(255, 70, 70))

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 4: TEST VÀ DEBUG KIỂM TRA DỊCH CHUYỂN ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🧪 KIỂM TRA & TEST DỊCH CHUYỂN (DEBUG)", Color3.fromRGB(0, 230, 255))

createActionButton("📍 Dịch Chuyển Thử Nghiệm 1 Lần (Test TP Once)", Color3.fromRGB(30, 80, 130), function()
    setStatus("🔍 Đang tìm kiếm trứng sông hợp lệ để test dịch chuyển 1 lần...")
    local eggs = getRiverEggs()
    if #eggs > 0 then
        local target = eggs[1]
        setStatus("🎯 Tìm thấy: " .. target.Instance.Name .. " [" .. target.RarityName .. "]. Đang test...")
        buySingleRiverEgg(target, true)
    else
        setStatus("⚠️ Hiện chưa có quả trứng hợp lệ nào trên sông để test!")
    end
end)

createActionButton("🔍 Quét Kiểm Tra Dòng Sông (Debug Scan)", Color3.fromRGB(35, 50, 70), function()
    local eggs = getRiverEggs()
    setStatus("📊 Kết quả quét: Có " .. tostring(#eggs) .. " trứng hợp lệ trên sông | Đã mua: " .. tostring(PurchasedCount) .. " | Đã bán: " .. tostring(SoldCount))
end)

createActionButton("🗑️ Xóa Bộ Nhớ Trứng Đã Mua (Reset Memory)", Color3.fromRGB(70, 35, 45), function()
    ProcessedRiverEggs = {}
    setStatus("🗑️ Đã xóa bộ nhớ! Script có thể quét lại các trứng cũ nếu cần.")
end)

createActionButton("❌ Đóng Mọi Popup Shop Đang Mở (Close Popups)", Color3.fromRGB(180, 40, 50), function()
    local closed = autoCloseShopPopups()
    setStatus(closed and "✅ Đã đóng popup shop thành công!" or "ℹ️ Không phát hiện bảng shop nào đang mở.")
end)

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 5: BỘ LỌC ĐỘ HIẾM MUỐN MUA (BUY FILTERS) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("💎 ĐỘ HIẾM MUỐN MUA (THEO GAME)", Color3.fromRGB(0, 230, 255))

createToggle("⚪ Thường (Common)", State.BuyRarities.Common, function(val)
    State.BuyRarities.Common = val
end)

createToggle("🟢 Không phổ biến (Uncommon)", State.BuyRarities.Uncommon, function(val)
    State.BuyRarities.Uncommon = val
end)

createToggle("🔵 Hiếm (Rare)", State.BuyRarities.Rare, function(val)
    State.BuyRarities.Rare = val
end)

createToggle("🟣 Huyền tuyệt (Epic)", State.BuyRarities.Epic, function(val)
    State.BuyRarities.Epic = val
end)

createToggle("🟠 Huyền thoại (Legendary)", State.BuyRarities.Legendary, function(val)
    State.BuyRarities.Legendary = val
end)

createToggle("🔴 Huyền thoại (Mythic)", State.BuyRarities.Mythic, function(val)
    State.BuyRarities.Mythic = val
end)

createToggle("🌈 Bật mí (Secret)", State.BuyRarities.Secret, function(val)
    State.BuyRarities.Secret = val
end)

createToggle("⭐ Giới hạn (Limited)", State.BuyRarities.Limited, function(val)
    State.BuyRarities.Limited = val
end)

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 6: HỖ TRỢ TREO MÁY ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🛡️ HỖ TRỢ TREO MÁY SĂN TRỨNG", Color3.fromRGB(0, 230, 255))

createToggle("🛡️ Anti-AFK 24/7 (Chống Văng Game)", State.AntiAFK, function(val)
    State.AntiAFK = val
end)

createToggle("⚡ Chế Độ Siêu Mượt 60 FPS (FPS Booster)", State.FPSBooster, function(val)
    State.FPSBooster = val
    toggleFPSBooster(val)
end, Color3.fromRGB(0, 255, 180))

setStatus("Đã khởi tạo thành công River Egg Auto-Buy & Sell Hub V2.5 (Tối ưu 60 FPS - Chống lag & Chống click nhầm shop)!")
