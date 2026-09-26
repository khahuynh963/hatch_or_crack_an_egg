--[[
    ===================================================================
    🌊 HATCH OR CRACK AN EGG! - AUTO MUA & BÁN TRỨNG THEO ĐỘ HIẾM V2.2
    Game: [👺] Ấp hoặc nứt một quả trứng (by Get it or Lose it)
    Repository: https://github.com/khahuynh963/hatch_or_crack_an_egg.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus.
    
    TÍNH NĂNG MỚI V2.2:
    1. 💰 AUTO BÁN TRỨNG CHỈ ĐƯỢC BÁN (SELECTIVE AUTO SELL):
       - Tự động bán trứng trong túi / cầm trên tay khi đủ điều kiện.
       - BỘ LỌC BẢO VỆ NGHIÊM NGẶT: Chỉ bán đúng các độ hiếm được người dùng chọn (mặc định chỉ bán Common, Uncommon, Rare).
       - Khóa an toàn 100% không bao giờ bán trứng xịn (Epic, Legendary, Mythic, Divine, Secret).
       - Tự động kích hoạt: Remote bán + Chạm ô Sell Zone / Pad + Prompt NPC Sell + Nút bán trong GUI.
       - Nút [💰 Bán ngay lập tức (Sell Now)] hỗ trợ bán nhanh chỉ 1 chạm.
    2. 🌊 AUTO MUA TRỨNG TRÊN SÔNG (RIVER EGG AUTO-BUY):
       - Chỉ dịch chuyển đúng 1 lần duy nhất cho mỗi quả trứng (Memory Blacklist).
       - Chỉ quét trứng trên dòng sông, tuyệt đối không dịch chuyển vào máy ấp hay plot người khác.
       - Tự động quay về chỗ cũ (Auto Return To Base) sau khi mua.
    3. 🧪 DEBUG & TEST CÔNG CỤ TRỰC TIẾP TRÊN MENU.
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

-- ── State Management ──
local State = {
    -- 1. River Egg Buy
    AutoBuyRiverEggs = false,
    MinRiverRarityIndex = 4, -- Default Epic+
    AutoTpToRiverEgg = true,
    AutoReturnToBase = true, -- Tự động quay về chỗ cũ sau khi mua
    InfiniteRiverRange = true,
    BuyRarities = {
        Common = false,
        Uncommon = false,
        Rare = false,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Divine = true,
        Secret = true
    },

    -- 2. Selective Auto Sell (Chỉ được bán các độ hiếm chọn)
    AutoSellEggs = false,
    SellRarities = {
        Common = true,      -- Mặc định cho phép bán
        Uncommon = true,    -- Mặc định cho phép bán
        Rare = true,        -- Mặc định cho phép bán
        Epic = false,       -- Mặc định KHÓA bảo vệ
        Legendary = false,  -- Mặc định KHÓA bảo vệ
        Mythic = false,     -- Mặc định KHÓA bảo vệ
        Divine = false,     -- Mặc định KHÓA bảo vệ
        Secret = false      -- Mặc định KHÓA bảo vệ
    },

    -- 3. Utility
    AntiAFK = true
}

local MinRarityPresets = {
    {Name = "⚪ Tất cả (Common+)", Rank = 1},
    {Name = "🟢 Uncommon+", Rank = 2},
    {Name = "🔵 Rare+", Rank = 3},
    {Name = "🟣 Epic+", Rank = 4},
    {Name = "🟠 Legendary+", Rank = 5},
    {Name = "🔴 Mythic+", Rank = 6},
    {Name = "🟡 Divine+", Rank = 7},
    {Name = "🌈 Secret / Supreme Only", Rank = 8}
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

-- ── Status Label Callbacks ──
local updateStatusUI = function(msg) end
local updateEggCountUI = function(count, bestEgg, boughtTotal, soldTotal) end

local function setStatus(msg)
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

-- ── Intelligent Remote Scanner ──
local function findRemote(patternList)
    for _, pattern in ipairs(patternList) do
        if CachedRemotes[pattern] and CachedRemotes[pattern].Parent then
            return CachedRemotes[pattern]
        end
    end

    local searchRoots = {ReplicatedStorage, Workspace}
    for _, root in ipairs(searchRoots) do
        for _, desc in ipairs(root:GetDescendants()) do
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

-- ── Lọc và phát hiện các khu vực máy / plot của người chơi ──
local function getExcludedContainers()
    local excluded = {}
    local blacklistNames = {
        "plot", "base", "tycoon", "machine", "incubator", "nest", 
        "shop", "stand", "display", "statue", "leaderboard", "lobby", "spawn"
    }

    for _, desc in ipairs(Workspace:GetChildren()) do
        local n = desc.Name:lower()
        for _, bName in ipairs(blacklistNames) do
            if n:find(bName) then
                table.insert(excluded, desc)
                break
            end
        end
    end
    return excluded
end

-- ── Đánh giá độ hiếm của quả trứng ──
local function evaluateEggRarity(obj)
    local bestRank = 1
    local bestRarityName = "Common"

    local function checkText(str)
        if not str then return end
        local lower = str:lower()
        if lower:find("supreme") or lower:find("cosmic") or lower:find("secret") or lower:find("vô cực") or lower:find("tối thượng") then
            if 8 > bestRank then bestRank = 8; bestRarityName = "Secret" end
        elseif lower:find("divine") or lower:find("thần thánh") or lower:find("thiên thần") or lower:find("angel") then
            if 7 > bestRank then bestRank = 7; bestRarityName = "Divine" end
        elseif lower:find("mythic") or lower:find("thần thoại") or lower:find("dragon") or lower:find("rồng") then
            if 6 > bestRank then bestRank = 6; bestRarityName = "Mythic" end
        elseif lower:find("legendary") or lower:find("huyền thoại") or lower:find("golden") or lower:find("vàng") then
            if 5 > bestRank then bestRank = 5; bestRarityName = "Legendary" end
        elseif lower:find("epic") or lower:find("sử thi") or lower:find("tím") then
            if 4 > bestRank then bestRank = 4; bestRarityName = "Epic" end
        elseif lower:find("rare") or lower:find("hiếm") or lower:find("lam") then
            if 3 > bestRank then bestRank = 3; bestRarityName = "Rare" end
        elseif lower:find("uncommon") or lower:find("lục") then
            if 2 > bestRank then bestRank = 2; bestRarityName = "Uncommon" end
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

    return bestRarityName, bestRank
end

-- ── Kiểm tra nghiêm ngặt: Có đúng là trứng trên dòng sông không? ──
local function verifyRiverEgg(obj, excludedList)
    if not obj or not obj.Parent then return false, "No parent" end
    if isEggProcessed(obj) then return false, "Already processed" end

    -- Không phải là nhân vật người chơi
    if obj:FindFirstAncestorOfClass("Player") then
        return false, "In player character"
    end

    -- 1. Kiểm tra toàn bộ cây tổ tiên (Tránh plot, máy ấp, shop)
    local cur = obj.Parent
    while cur and cur ~= Workspace do
        local cName = cur.Name:lower()
        if cName:find("machine") or cName:find("incubator") or cName:find("nest") 
           or cName:find("plot") or cName:find("base") or cName:find("tycoon") 
           or cName:find("gear") or cName:find("shop") or cName:find("stand") 
           or cName:find("display") or cName:find("leaderboard") or cName:find("statue")
           or cName:find("spawn") then
            return false, "In machine/plot: " .. cur.Name
        end
        for _, ex in ipairs(excludedList) do
            if cur == ex then
                return false, "In excluded container: " .. ex.Name
            end
        end
        cur = cur.Parent
    end

    -- 2. Kiểm tra ProximityPrompt / ClickDetector
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
    local cd = obj:FindFirstChildOfClass("ClickDetector") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ClickDetector", true))

    if not prompt and not cd then
        return false, "No prompt or click detector"
    end

    -- 3. Kiểm tra nội dung Prompt: TUYỆT ĐỐI LOẠI BỎ cần gạt hoặc nút ấp máy
    if prompt then
        local act = (prompt.ActionText or ""):lower()
        local objText = (prompt.ObjectText or ""):lower()

        if act:find("pull") or act:find("lever") or act:find("hatch") or act:find("ấp") 
           or act:find("gạt") or act:find("multiplier") or act:find("roll") or act:find("start")
           or objText:find("lever") or objText:find("multiplier") or objText:find("gear") then
            return false, "Machine prompt: " .. act
        end
    end

    -- 4. Tìm phần Part vật lý
    local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
    if not part then
        return false, "No physical part"
    end

    return true, "Valid River Egg", part, prompt, cd
end

-- ── Quét danh sách trứng thực sự đang trôi trên sông ──
local function getRiverEggs()
    local riverEggs = {}
    local excludedList = getExcludedContainers()
    local minRank = MinRarityPresets[State.MinRiverRarityIndex].Rank

    local totalEggsFound = 0
    local highestEggFound = nil
    local highestEggRank = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) then
            local oName = obj.Name:lower()
            if oName:find("egg") or oName:find("trứng") then
                local isValid, reason, part, prompt, cd = verifyRiverEgg(obj, excludedList)
                if isValid then
                    totalEggsFound = totalEggsFound + 1
                    local rarityName, rank = evaluateEggRarity(obj)
                    
                    if rank > highestEggRank then
                        highestEggRank = rank
                        highestEggFound = rarityName
                    end

                    local shouldBuy = false
                    if State.BuyRarities[rarityName] then
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
                            Rarity = rarityName,
                            Rank = rank
                        })
                    end
                end
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

-- ── Thực hiện mua 1 quả trứng duy nhất (Chỉ bay 1 lần, không bay lung tung) ──
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

    -- 1. DỊCH CHUYỂN ĐÚNG 1 LẦN (Nếu bật TP hoặc đang bấm nút Test)
    if State.AutoTpToRiverEgg or isManualTest then
        setStatus("🚀 Bay đến trứng sông: " .. obj.Name .. " [" .. eggData.Rarity .. "] (1 Lần)")
        
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.2, 0))
        didTeleport = true
        task.wait(0.12)
    else
        setStatus("⚡ Mua từ xa: " .. obj.Name .. " [" .. eggData.Rarity .. "]")
    end

    -- 2. KÍCH HOẠT PROXIMITY PROMPT
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

    -- 4. BẮN REMOTE EVENT MUA TRỨNG SÔNG
    local buyRemote = findRemote({"buyegg", "riverbuy", "purchaseegg", "buyriver", "claimriveregg", "takeegg"})
    if buyRemote then
        if buyRemote:IsA("RemoteEvent") then
            buyRemote:FireServer(obj)
            buyRemote:FireServer(obj.Name)
        elseif buyRemote:IsA("RemoteFunction") then
            buyRemote:InvokeServer(obj)
        end
    end

    task.wait(0.15)

    -- 5. QUAY VỀ VỊ TRÍ CŨ NẾU BẬT AUTO RETURN
    if didTeleport and State.AutoReturnToBase and originalCFrame then
        setStatus("🔙 Đã mua xong! Đang quay lại vị trí ban đầu...")
        task.wait(0.08)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = originalCFrame
    end

    setStatus("✅ ĐÃ MUA THÀNH CÔNG: " .. obj.Name .. " [" .. eggData.Rarity .. "] (Đã ghi nhớ, không dịch chuyển lại)")
    
    task.wait(0.25)
    isBuyingActive = false
    return true
end

-- ═══════════════════════════════════════════════════════════
-- 💰 ENGINE AUTO BÁN TRỨNG (CHỈ ĐƯỢC BÁN CÁC ĐỘ HIẾM ĐÃ CHỌN)
-- ═══════════════════════════════════════════════════════════

-- Tìm các khu vực Sell Pad / Sell Zone trên bản đồ
local function getSellZones()
    local zones = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:FindFirstAncestorOfClass("Player") then
            local n = obj.Name:lower()
            if n:find("sell") or n:find("bán") or n:find("deposit") or n:find("cashin") then
                table.insert(zones, obj)
            end
        end
    end
    return zones
end

-- Tìm các quả trứng trong túi / trên tay thỏa mãn điều kiện CHỈ ĐƯỢC BÁN
local function getSellableItems()
    local sellable = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local sources = {backpack, char}

    for _, container in ipairs(sources) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Model") or item:IsA("Folder") then
                    local rarityName, rank = evaluateEggRarity(item)
                    -- Kiểm tra nghiêm ngặt: Có nằm trong danh sách ĐƯỢC PHÉP BÁN không?
                    if State.SellRarities[rarityName] == true then
                        table.insert(sellable, {
                            Instance = item,
                            Rarity = rarityName,
                            Rank = rank
                        })
                    end
                end
            end
        end
    end
    return sellable
end

-- Thực hiện quy trình bán an toàn (Chỉ bán trứng được chọn)
local function executeSell()
    if isSellingActive then return end
    isSellingActive = true

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    local sellableItems = getSellableItems()

    -- 1. Cầm các item thỏa mãn điều kiện lên tay để bán
    for _, sItem in ipairs(sellableItems) do
        local tool = sItem.Instance
        if tool:IsA("Tool") and hum and tool.Parent == LocalPlayer:FindFirstChild("Backpack") then
            pcall(function()
                hum:EquipTool(tool)
            end)
            task.wait(0.04)
        end
    end

    -- 2. Chạm vào tất cả các ô Sell Zone / Sell Pad (firetouchinterest)
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

    -- 3. Bắn các Remote Bán trứng an toàn
    local sellRemote = findRemote({"sellegg", "selleggs", "sellall", "sell", "sellinv", "sellinventory", "sellitem", "cashin"})
    if sellRemote then
        pcall(function()
            if sellRemote:IsA("RemoteEvent") then
                -- Bắn bán từng item cụ thể đã lọc
                for _, sItem in ipairs(sellableItems) do
                    sellRemote:FireServer(sItem.Instance)
                    sellRemote:FireServer(sItem.Instance.Name)
                end
                -- Bắn bán chung
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

    -- 4. Kích hoạt các ProximityPrompt bán trứng của NPC / Máy bán
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local act = (prompt.ActionText or ""):lower()
            local oText = (prompt.ObjectText or ""):lower()
            if act:find("sell") or act:find("bán") or oText:find("sell") or oText:find("bán") then
                triggerPrompt(prompt)
            end
        end
    end

    -- 5. Kích hoạt nút Sell trong PlayerGui nếu có
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in ipairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible and not btn:IsDescendantOf(ScreenGui) then
                local bName = btn.Name:lower()
                local bText = btn:IsA("TextButton") and btn.Text:lower() or ""
                if bName:find("sell") or bName:find("bán") or bText:find("sell") or bText:find("bán") then
                    if firesignal then
                        firesignal(btn.MouseButton1Click)
                        firesignal(btn.Activated)
                    end
                end
            end
        end
    end

    SoldCount = SoldCount + 1
    setStatus("💰 Đã kích hoạt bán trứng (Chỉ bán các độ hiếm được chọn)!")

    task.wait(0.3)
    isSellingActive = false
end

-- ═══════════════════════════════════════════════════════════
-- ⚙️ BACKGROUND LOOPS
-- ═══════════════════════════════════════════════════════════

-- 1. Auto Buy River Eggs Loop
task.spawn(function()
    while true do
        task.wait(0.35)
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

-- 2. Auto Sell Eggs Loop (Chạy chu kỳ 1.5 giây)
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.AutoSellEggs and not isSellingActive then
            pcall(function()
                executeSell()
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎨 GIAO DIỆN CHUYÊN BIỆT (RIVER EGG AUTO-BUY & SELL HUB UI V2.2)
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
Title.Text = "🌊 MUA & BÁN TRỨNG SÔNG V2.2"
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

updateEggCountUI = function(count, bestEgg, boughtTotal, soldTotal)
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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1180)
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
-- ── SECTION 1: AUTO MUA TRỨNG TRÊN SÔNG (RIVER BUY) ──
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

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 2: AUTO BÁN TRỨNG (CHỈ ĐƯỢC BÁN) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("💰 AUTO BÁN TRỨNG (CHỈ ĐƯỢC BÁN)", Color3.fromRGB(255, 200, 0))

createToggle("💰 Bật Auto Bán Trứng (Auto Sell)", State.AutoSellEggs, function(val)
    State.AutoSellEggs = val
    setStatus(val and "💰 Đã BẬT Auto Bán Trứng (Chỉ bán các độ hiếm cho phép)!" or "⏸️ Đã TẮT Auto Bán Trứng.")
end, Color3.fromRGB(255, 200, 0))

createActionButton("💰 Bán Ngay Lập Tức (Sell Now - 1 Lần)", Color3.fromRGB(150, 100, 20), function()
    setStatus("💰 Đang thực hiện bán ngay lập tức...")
    executeSell()
end)

createSectionHeader("🎯 DANH SÁCH CHỈ ĐƯỢC BÁN (SELL FILTERS):", Color3.fromRGB(255, 215, 0))

createToggle("⚪ Bán Common (Trứng thường)", State.SellRarities.Common, function(val)
    State.SellRarities.Common = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🟢 Bán Uncommon (Trứng lục)", State.SellRarities.Uncommon, function(val)
    State.SellRarities.Uncommon = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🔵 Bán Rare (Trứng hiếm)", State.SellRarities.Rare, function(val)
    State.SellRarities.Rare = val
end, Color3.fromRGB(255, 200, 0))

createToggle("🟣 Bán Epic (Sử thi) [Khóa an toàn]", State.SellRarities.Epic, function(val)
    State.SellRarities.Epic = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🟠 Bán Legendary [Khóa an toàn]", State.SellRarities.Legendary, function(val)
    State.SellRarities.Legendary = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🔴 Bán Mythic [Khóa an toàn]", State.SellRarities.Mythic, function(val)
    State.SellRarities.Mythic = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🟡 Bán Divine [Khóa an toàn]", State.SellRarities.Divine, function(val)
    State.SellRarities.Divine = val
end, Color3.fromRGB(255, 70, 70))

createToggle("🌈 Bán Secret / Supreme [Khóa an toàn]", State.SellRarities.Secret, function(val)
    State.SellRarities.Secret = val
end, Color3.fromRGB(255, 70, 70))

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 3: TEST VÀ DEBUG KIỂM TRA DỊCH CHUYỂN ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🧪 KIỂM TRA & TEST DỊCH CHUYỂN (DEBUG)", Color3.fromRGB(0, 230, 255))

createActionButton("📍 Dịch Chuyển Thử Nghiệm 1 Lần (Test TP Once)", Color3.fromRGB(30, 80, 130), function()
    setStatus("🔍 Đang tìm kiếm trứng sông hợp lệ để test dịch chuyển 1 lần...")
    local eggs = getRiverEggs()
    if #eggs > 0 then
        local target = eggs[1]
        setStatus("🎯 Tìm thấy: " .. target.Instance.Name .. " [" .. target.Rarity .. "]. Đang test...")
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

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 4: BỘ LỌC ĐỘ HIẾM MUỐN MUA (BUY RARITY) ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("💎 CHỌN ĐỘ HIẾM MUỐN MUA (BUY FILTERS)", Color3.fromRGB(0, 230, 255))

createToggle("⚪ Trứng Thường (Common)", State.BuyRarities.Common, function(val)
    State.BuyRarities.Common = val
end)

createToggle("🟢 Trứng Lục (Uncommon)", State.BuyRarities.Uncommon, function(val)
    State.BuyRarities.Uncommon = val
end)

createToggle("🔵 Trứng Hiếm (Rare)", State.BuyRarities.Rare, function(val)
    State.BuyRarities.Rare = val
end)

createToggle("🟣 Trứng Sử Thi (Epic)", State.BuyRarities.Epic, function(val)
    State.BuyRarities.Epic = val
end)

createToggle("🟠 Trứng Huyền Thoại (Legendary)", State.BuyRarities.Legendary, function(val)
    State.BuyRarities.Legendary = val
end)

createToggle("🔴 Trứng Thần Thoại (Mythic)", State.BuyRarities.Mythic, function(val)
    State.BuyRarities.Mythic = val
end)

createToggle("🟡 Trứng Thần Thánh (Divine)", State.BuyRarities.Divine, function(val)
    State.BuyRarities.Divine = val
end)

createToggle("🌈 Trứng Tối Thượng (Secret / Supreme)", State.BuyRarities.Secret, function(val)
    State.BuyRarities.Secret = val
end)

-- ═══════════════════════════════════════════════════════════
-- ── SECTION 5: HỖ TRỢ TREO MÁY ──
-- ═══════════════════════════════════════════════════════════

createSectionHeader("🛡️ HỖ TRỢ TREO MÁY SĂN TRỨNG", Color3.fromRGB(0, 230, 255))

createToggle("🛡️ Anti-AFK 24/7 (Chống Văng Game)", State.AntiAFK, function(val)
    State.AntiAFK = val
end)

setStatus("Đã khởi tạo thành công River Egg Auto-Buy & Sell Hub V2.2!")
