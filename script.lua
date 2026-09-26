--[[
    ===================================================================
    🌊 HATCH OR CRACK AN EGG! - AUTO MUA TRỨNG TRÊN SÔNG (RIVER BUY HUB)
    Game: [👺] Ấp hoặc nứt một quả trứng (by Get it or Lose it)
    Repository: https://github.com/khahuynh963/hatch_or_crack_an_egg.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus.
    
    TÍNH NĂNG CHUYÊN BIỆT:
    - Quét & nhận diện toàn bộ trứng đang trôi trên dòng sông / băng chuyền.
    - Phân loại 8 bậc độ hiếm: Common, Uncommon, Rare, Epic, Legendary, Mythic, Divine, Secret / Supreme.
    - Lọc theo ngưỡng tối thiểu (Min Rarity) & Bật/Tắt riêng từng bậc độ hiếm.
    - Mua tầm xa vô hạn (Infinite Range ProximityPrompt 0s Hold).
    - Tự động bay cạnh trứng (Auto Teleport) để mua thành công 100%.
    - Tự động bỏ qua trứng trong máy ấp của người chơi khác.
    - Anti-AFK 24/7 tích hợp chống văng game khi treo máy săn trứng.
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
    AutoBuyRiverEggs = false,
    MinRiverRarityIndex = 4, -- Default Epic+
    AutoTpToRiverEgg = false,
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

local CachedRemotes = {}

-- ── Status Label Callbacks ──
local updateStatusUI = function(msg) end
local updateEggCountUI = function(count, bestEgg) end

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

-- ── Player Machine / Plot Detector (Exclude Eggs in Machines) ──
local function getMachinesAndPlots()
    local machines = {}
    local searchRoots = {"Plots", "Bases", "Tycoons", "Machines", "Incubators"}
    for _, rootName in ipairs(searchRoots) do
        local container = Workspace:FindFirstChild(rootName)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                table.insert(machines, item)
            end
        end
    end
    return machines
end

-- ── Evaluate Egg Rarity on River / Conveyor ──
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

    -- 1. Check Name
    checkText(obj.Name)

    -- 2. Check ProximityPrompt Text
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
    if prompt then
        checkText(prompt.ObjectText)
        checkText(prompt.ActionText)
    end

    -- 3. Check Child UI TextLabels
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            checkText(desc.Text)
        elseif desc:IsA("StringValue") then
            checkText(desc.Value)
        end
    end

    -- 4. Check Attributes
    pcall(function()
        for attrName, attrVal in pairs(obj:GetAttributes()) do
            checkText(tostring(attrName))
            checkText(tostring(attrVal))
        end
    end)

    return bestRarityName, bestRank
end

-- ── Scan River / Conveyor Eggs ──
local function getRiverEggs()
    local riverEggs = {}
    local machines = getMachinesAndPlots()
    local minRank = MinRarityPresets[State.MinRiverRarityIndex].Rank

    local totalEggsFound = 0
    local highestEggFound = nil
    local highestEggRank = 0

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and not obj:FindFirstAncestorOfClass("Player") then
            local oName = obj.Name:lower()
            if oName:find("egg") or oName:find("trứng") then
                -- Check if egg is inside someone's machine / plot
                local inMachine = false
                for _, m in ipairs(machines) do
                    if obj:IsDescendantOf(m) then
                        inMachine = true
                        break
                    end
                end

                if not inMachine then
                    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ProximityPrompt", true))
                    local cd = obj:FindFirstChildOfClass("ClickDetector") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("ClickDetector", true))

                    if prompt or cd then
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
                            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                            if part then
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
        end
    end

    pcall(function()
        updateEggCountUI(totalEggsFound, highestEggFound or "None")
    end)

    table.sort(riverEggs, function(a, b)
        return a.Rank > b.Rank
    end)

    return riverEggs
end

-- ═══════════════════════════════════════════════════════════
-- ⚙️ BACKGROUND RIVER EGG BUYING LOOP
-- ═══════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.25)
        if State.AutoBuyRiverEggs then
            pcall(function()
                local eggs = getRiverEggs()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if #eggs == 0 then
                    setStatus("🌊 Đang quét dòng sông... (Chưa có trứng phù hợp)")
                end

                for _, eggData in ipairs(eggs) do
                    local obj = eggData.Instance
                    local prompt = eggData.Prompt
                    local cd = eggData.ClickDetector
                    local part = eggData.Part

                    if hrp and part and part.Parent then
                        -- Optional Teleport to egg
                        if State.AutoTpToRiverEgg then
                            local dist = (part.Position - hrp.Position).Magnitude
                            if dist > 8 then
                                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.5, 0))
                                task.wait(0.08)
                            end
                        end

                        -- Trigger ProximityPrompt
                        if prompt then
                            if State.InfiniteRiverRange then
                                prompt.RequiresLineOfSight = false
                                prompt.HoldDuration = 0
                                prompt.MaxActivationDistance = 99999
                            end
                            triggerPrompt(prompt)
                        end

                        -- Trigger ClickDetector
                        if cd and fireclickdetector then
                            fireclickdetector(cd, 0)
                            fireclickdetector(cd)
                        end

                        -- Attempt Remote Fires
                        local buyRemote = findRemote({"buyegg", "riverbuy", "purchaseegg", "buyriver", "claimriveregg", "takeegg"})
                        if buyRemote then
                            if buyRemote:IsA("RemoteEvent") then
                                buyRemote:FireServer(obj)
                                buyRemote:FireServer(obj.Name)
                            elseif buyRemote:IsA("RemoteFunction") then
                                buyRemote:InvokeServer(obj)
                            end
                        end

                        setStatus("🌊 Đã kích hoạt mua trứng: " .. obj.Name .. " [" .. eggData.Rarity .. "]")
                        task.wait(0.12)
                    end
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎨 GIAO DIỆN CHUYÊN BIỆT (RIVER EGG AUTO-BUY HUB UI)
-- ═══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HatchOrCrackRiverHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiContainer()

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 470)
MainFrame.Position = UDim2.new(0.5, -160, 0.18, 0)
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
Title.Text = "🌊 AUTO MUA TRỨNG SÔNG"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
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
StatsLabel.Text = "🌊 Trứng trên sông: [ 0 ] | Cao nhất: [ Chưa có ]"
StatsLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
StatsLabel.Font = Enum.Font.SourceSansBold
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = StatsBanner

updateEggCountUI = function(count, bestEgg)
    StatsLabel.Text = "🌊 Trứng trên sông: [ " .. tostring(count) .. " ] | Cao nhất: [ " .. tostring(bestEgg) .. " ]"
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
StatusLabel.Text = "Sẵn sàng | Đang quét trứng trên sông..."
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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

-- ── UI Component Helpers ──
local function createSectionHeader(titleText)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.Text = " " .. titleText
    header.TextColor3 = Color3.fromRGB(0, 230, 255)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = Scroll
    return header
end

local function createToggle(title, defaultVal, callback)
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

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.Position = UDim2.new(1, -48, 0.5, -11)
    btn.BackgroundColor3 = defaultVal and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(45, 58, 75)
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
        btn.BackgroundColor3 = currentVal and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(45, 58, 75)
        btn.Text = currentVal and "ON" or "OFF"
        btn.TextColor3 = currentVal and Color3.fromRGB(15, 20, 28) or Color3.fromRGB(180, 190, 200)
        pcall(callback, currentVal)
    end)
    return frame
end

-- ── BUILD RIVER CONTROLS ──

createSectionHeader("🌊 ĐIỀU KHIỂN CHÍNH (MASTER CONTROLS)")

createToggle("🌊 Bật Auto Mua Trứng Dòng Sông", State.AutoBuyRiverEggs, function(val)
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

createToggle("🚀 Tự Bay Cạnh Trứng Sông (Auto TP)", State.AutoTpToRiverEgg, function(val)
    State.AutoTpToRiverEgg = val
    setStatus(val and "🚀 Đã BẬT Auto TP đến trứng sông." or "Đã TẮT Auto TP.")
end)

createToggle("⚡ Mua Tầm Xa Vô Hạn (Infinite Range)", State.InfiniteRiverRange, function(val)
    State.InfiniteRiverRange = val
end)

createSectionHeader("💎 CHỌN ĐỘ HIẾM MUỐN MUA (RARITY FILTERS)")

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

createSectionHeader("🛡️ HỖ TRỢ TREO MÁY SĂN TRỨNG")

createToggle("🛡️ Anti-AFK 24/7 (Chống Văng Game)", State.AntiAFK, function(val)
    State.AntiAFK = val
end)

setStatus("Đã khởi tạo thành công River Egg Auto-Buy Hub!")
