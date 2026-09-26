--[[
    ===================================================================
    🥚 HATCH OR CRACK AN EGG! (ẤP HOẶC NỨT MỘT QUẢ TRỨNG) - ULTIMATE AUTO HUB V1.0
    Game: [👺] Ấp hoặc nứt một quả trứng (by Get it or Lose it)
    Repository: https://github.com/khahuynh963/hatch_or_crack_an_egg.git
    Tương thích 100% với Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus.
    
    Tính năng cốt lõi:
    1. 🎰 Smart Auto Multiplier Farm (Tự gạt cần nâng hệ số x1.0 -> x1,000)
    2. 💰 Auto Cash Out / Hatch (Tự động ấp chốt lời đúng hệ số mục tiêu, tránh nứt vỡ)
    3. 🥚 Auto Start New Egg (Tự động nạp trứng mới ngay khi nở hoặc vỡ để treo máy 24/7)
    4. 🎯 Bộ Chiến Lược Mục Tiêu: An toàn (x2.0), Cân bằng (x3.0), Mạo hiểm (x5.0), Jackpot (x10 -> x100)
    5. ⚡ Instant ProximityPrompt (0s Hold cần gạt và nút ấp trứng)
    6. 🧲 Auto Collect Cash & Rewards (Tự hút tiền, kim cương sinh ra)
    7. 🔄 Auto Rebirth & Machine Upgrades (Tự chuyển sinh & nâng cấp máy)
    8. 🏃 WalkSpeed Customizer & Lướt CFrame Siêu Tốc (2x -> 50x)
    9. 🦘 Infinite Jump, Noclip & Float Mode
    10. 🛡️ Anti-AFK 24/7 & FPS Booster
    ===================================================================
--]]

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

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
    if c and c:FindFirstChild("HatchOrCrackHubGui") then
        c.HatchOrCrackHubGui:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("HatchOrCrackHubGui") then
        game:GetService("CoreGui").HatchOrCrackHubGui:Destroy()
    end
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HatchOrCrackHubGui") then
        LocalPlayer.PlayerGui.HatchOrCrackHubGui:Destroy()
    end
end)

-- ── State Management ──
local State = {
    AutoFarm = false,
    TargetMultiplier = 2.0,
    MultiplierPresetIndex = 1,
    AutoStartNewEgg = true,
    InstantPrompt = true,
    
    AutoCollectCash = false,
    AutoRebirth = false,
    AutoUpgradeMachine = false,
    
    SpeedEnabled = false,
    WalkSpeed = 60,
    CFrameBoost = false,
    CFrameSpeedIndex = 2,
    InfiniteJump = false,
    Noclip = false,
    FloatMode = false,
    
    AntiAFK = true,
    FPSBoost = false
}

local TargetPresets = {
    {Name = "🛡️ Cực An Toàn (x1.5)", Multiplier = 1.5},
    {Name = "🛡️ An Toàn (x2.0)", Multiplier = 2.0},
    {Name = "⚖️ Cân Bằng (x3.0)", Multiplier = 3.0},
    {Name = "🚀 Mạo Hiểm (x5.0)", Multiplier = 5.0},
    {Name = "🔥 Liều Ăn Nhiều (x10.0)", Multiplier = 10.0},
    {Name = "⚡ Siêu Lợi Nhuận (x24.0)", Multiplier = 24.0},
    {Name = "👑 Jackpot (x100.0)", Multiplier = 100.0}
}

local CFrameMultipliers = {2, 5, 10, 20, 40}
local CachedRemotes = {}

-- ── Status Label Callbacks ──
local updateStatusUI = function(msg) end
local updateCurrentMultUI = function(mult) end

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

-- Background Prompt Optimizer Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.InstantPrompt then
            pcall(function()
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        optimizePrompt(prompt)
                    end
                end
            end)
        end
    end
end)

-- ── Player Machine / Plot Detector ──
local function getPlayerMachine()
    -- Method 1: Check Plot / Base owned by player
    local searchRoots = {"Plots", "Bases", "Tycoons", "Machines", "Incubators"}
    for _, rootName in ipairs(searchRoots) do
        local container = Workspace:FindFirstChild(rootName)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                local owner = item:FindFirstChild("Owner") or item:FindFirstChild("Player") or item:FindFirstChild("ClaimedBy")
                if owner and (owner.Value == LocalPlayer or owner.Value == LocalPlayer.Name or tostring(owner.Value) == LocalPlayer.Name) then
                    return item
                end
            end
        end
    end

    -- Method 2: Check Machine closest to player
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local closestMachine = nil
        local closestDist = 9999
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local oName = obj.Name:lower()
                if oName:find("machine") or oName:find("incubator") or oName:find("nest") or oName:find("egg_stand") or oName:find("gear") then
                    local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if pPart then
                        local dist = (pPart.Position - hrp.Position).Magnitude
                        if dist < closestDist and dist <= 45 then
                            closestDist = dist
                            closestMachine = obj
                        end
                    end
                end
            end
        end
        if closestMachine then
            return closestMachine
        end
    end

    return nil
end

-- ── Parse Multiplier from Machine Text ──
local function getCurrentEggMultiplier(machine)
    local maxMult = 1.0
    local found = false

    local function checkContainer(container)
        if not container then return end
        for _, desc in ipairs(container:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local text = desc.Text
                if text and #text > 0 then
                    local lower = text:lower()
                    
                    -- Pattern: x2.00, x24.0, x100, 2.50x
                    local mVal = lower:match("x%s*([%d%.]+)") or lower:match("([%d%.]+)%s*x")
                    if mVal then
                        local num = tonumber(mVal)
                        if num and num >= 1.0 then
                            if num > maxMult then
                                maxMult = num
                                found = true
                            end
                        end
                    end
                end
            end
        end
    end

    if machine then
        checkContainer(machine)
    end

    -- Also check PlayerGui for floating billboard / HUD egg multiplier
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        checkContainer(pGui)
    end

    return maxMult, found
end

-- ── Movement & Character Physics Engine ──
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum and State.SpeedEnabled then
        if hum.WalkSpeed ~= State.WalkSpeed then
            hum.WalkSpeed = State.WalkSpeed
        end
    end

    if State.CFrameBoost and hrp and hum and hum.MoveDirection.Magnitude > 0 then
        local mult = CFrameMultipliers[State.CFrameSpeedIndex] or 5
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (mult * 0.25))
    end

    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if State.FloatMode and hrp then
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    if State.SpeedEnabled and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = State.WalkSpeed
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ⚙️ BACKGROUND AUTOMATION LOOPS
-- ═══════════════════════════════════════════════════════════

-- 1. SMART AUTO MULTIPLIER & CRASH CASHOUT LOOP
task.spawn(function()
    while true do
        task.wait(0.18)
        if State.AutoFarm then
            pcall(function()
                local machine = getPlayerMachine()
                local currentMult, found = getCurrentEggMultiplier(machine)
                updateCurrentMultUI(currentMult)

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                -- Case A: Multiplier reached or exceeded target -> CASHOUT / HATCH!
                if currentMult >= State.TargetMultiplier then
                    setStatus("💰 ĐẠT MỤC TIÊU x" .. tostring(currentMult) .. "! ĐANG CHỐT LỜI (HATCH)...")

                    -- Method 1: Trigger Hatch / Cashout Remote
                    local hatchRemote = findRemote({"hatch", "cashout", "claim", "collect", "take", "hatchegg", "finish"})
                    if hatchRemote then
                        if hatchRemote:IsA("RemoteEvent") then
                            hatchRemote:FireServer()
                            hatchRemote:FireServer(true)
                            hatchRemote:FireServer("Hatch")
                        elseif hatchRemote:IsA("RemoteFunction") then
                            hatchRemote:InvokeServer()
                        end
                    end

                    -- Method 2: Trigger ProximityPrompt on Machine
                    if machine then
                        for _, prompt in ipairs(machine:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                local act = (prompt.ActionText or ""):lower()
                                local obj = (prompt.ObjectText or ""):lower()
                                if act:find("hatch") or act:find("claim") or act:find("cash") or act:find("ấp") or act:find("nhận") 
                                   or obj:find("hatch") or obj:find("claim") then
                                    triggerPrompt(prompt)
                                end
                            end
                        end
                    end

                    -- Method 3: In-game UI Button
                    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if pGui then
                        for _, desc in ipairs(pGui:GetDescendants()) do
                            if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                                local name = desc.Name:lower()
                                local text = desc:IsA("TextButton") and desc.Text:lower() or ""
                                if (name:find("hatch") or name:find("claim") or name:find("cash") or text:find("hatch") or text:find("ấp") or text:find("chốt")) 
                                   and not name:find("hub") and desc.Visible then
                                    if firesignal then
                                        firesignal(desc.MouseButton1Click)
                                        firesignal(desc.Activated)
                                    end
                                end
                            end
                        end
                    end

                    task.wait(0.6)
                    return
                end

                -- Case B: Multiplier still below target -> PULL LEVER / MULTIPLY!
                if currentMult < State.TargetMultiplier then
                    setStatus("⚡ Hệ số: x" .. string.format("%.2f", currentMult) .. " / Mục tiêu: x" .. tostring(State.TargetMultiplier) .. " -> Đang gạt cần...")

                    -- Method 1: Trigger Lever / Multiply Remote
                    local multRemote = findRemote({"multiply", "pulllever", "lever", "upgrade", "upgradeegg", "cracks", "roll", "risk"})
                    if multRemote then
                        if multRemote:IsA("RemoteEvent") then
                            multRemote:FireServer()
                            multRemote:FireServer("Lever")
                            multRemote:FireServer("Multiply")
                        elseif multRemote:IsA("RemoteFunction") then
                            multRemote:InvokeServer()
                        end
                    end

                    -- Method 2: Trigger ProximityPrompt for Lever
                    if machine then
                        for _, prompt in ipairs(machine:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                local act = (prompt.ActionText or ""):lower()
                                local obj = (prompt.ObjectText or ""):lower()
                                if act:find("pull") or act:find("lever") or act:find("upgrade") or act:find("gạt") or act:find("nhân") or act:find("tăng") 
                                   or obj:find("lever") or obj:find("cần") then
                                    triggerPrompt(prompt)
                                end
                            end
                        end
                    end

                    -- Method 3: Click UI Lever / Multiply button
                    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if pGui then
                        for _, desc in ipairs(pGui:GetDescendants()) do
                            if desc:IsA("TextButton") or desc:IsA("ImageButton") then
                                local name = desc.Name:lower()
                                local text = desc:IsA("TextButton") and desc.Text:lower() or ""
                                if (name:find("lever") or name:find("pull") or name:find("mult") or text:find("pull") or text:find("gạt") or text:find("nhân")) 
                                   and not name:find("hub") and desc.Visible then
                                    if firesignal then
                                        firesignal(desc.MouseButton1Click)
                                        firesignal(desc.Activated)
                                    end
                                end
                            end
                        end
                    end
                end

                -- Case C: Auto Start New Egg if needed
                if State.AutoStartNewEgg then
                    local newEggRemote = findRemote({"newegg", "startegg", "spawnegg", "placeegg", "buyegg"})
                    if newEggRemote then
                        if newEggRemote:IsA("RemoteEvent") then
                            newEggRemote:FireServer()
                            newEggRemote:FireServer(1)
                        elseif newEggRemote:IsA("RemoteFunction") then
                            newEggRemote:InvokeServer()
                        end
                    end

                    if machine then
                        for _, prompt in ipairs(machine:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                local act = (prompt.ActionText or ""):lower()
                                local obj = (prompt.ObjectText or ""):lower()
                                if act:find("start") or act:find("new") or act:find("place") or act:find("bắt đầu") or act:find("đặt") then
                                    triggerPrompt(prompt)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Collect Cash & Coins Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoCollectCash then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part:FindFirstAncestorOfClass("Player") then
                        local name = part.Name:lower()
                        if name:find("coin") or name:find("gem") or name:find("cash") or name:find("money") or name:find("drop") or name:find("reward") then
                            if (part.Position - hrp.Position).Magnitude <= 70 then
                                if firetouchinterest then
                                    firetouchinterest(hrp, part, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, part, 1)
                                else
                                    part.CFrame = hrp.CFrame
                                end
                            end
                        end
                    end
                end

                local collectRemote = findRemote({"collectcash", "claimcash", "collectall", "collectmoney"})
                if collectRemote then
                    if collectRemote:IsA("RemoteEvent") then
                        collectRemote:FireServer()
                    elseif collectRemote:IsA("RemoteFunction") then
                        collectRemote:InvokeServer()
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Rebirth Loop
task.spawn(function()
    while true do
        task.wait(3.5)
        if State.AutoRebirth then
            pcall(function()
                local rebirthRemote = findRemote({"rebirth", "prestige", "chuyensinh", "rebirthremote"})
                if rebirthRemote then
                    if rebirthRemote:IsA("RemoteEvent") then
                        rebirthRemote:FireServer()
                    elseif rebirthRemote:IsA("RemoteFunction") then
                        rebirthRemote:InvokeServer()
                    end
                    setStatus("🔄 Đã kích hoạt Auto Rebirth!")
                end
            end)
        end
    end
end)

-- 4. Auto Upgrade Machine Loop
task.spawn(function()
    while true do
        task.wait(3.0)
        if State.AutoUpgradeMachine then
            pcall(function()
                local upRemote = findRemote({"upgrademachine", "upgradenest", "upgradeluck", "speedupgrade", "upgradespeed"})
                if upRemote then
                    if upRemote:IsA("RemoteEvent") then
                        upRemote:FireServer()
                    elseif upRemote:IsA("RemoteFunction") then
                        upRemote:InvokeServer()
                    end
                    setStatus("⚡ Đang nâng cấp Máy Ấp / Tỷ lệ may mắn...")
                end
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎨 GIAO DIỆN CYBERPUNK (HATCH OR CRACK HUB UI)
-- ═══════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HatchOrCrackHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiContainer()

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 215, 0) -- Golden Egg Gold
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
Topbar.BackgroundColor3 = Color3.fromRGB(22, 30, 42)
Topbar.BorderSizePixel = 0
Topbar.Parent = MainFrame

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarBottomFill = Instance.new("Frame")
TopbarBottomFill.Size = UDim2.new(1, 0, 0, 10)
TopbarBottomFill.Position = UDim2.new(0, 0, 1, -10)
TopbarBottomFill.BackgroundColor3 = Color3.fromRGB(22, 30, 42)
TopbarBottomFill.BorderSizePixel = 0
TopbarBottomFill.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🥚 HATCH OR CRACK HUB 🎰"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -68, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(38, 50, 70)
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
FloatingToggle.Name = "HatchOrCrackFloatingToggle"
FloatingToggle.Size = UDim2.new(0, 48, 0, 48)
FloatingToggle.Position = UDim2.new(0, 20, 0.4, 0)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
FloatingToggle.Visible = false
FloatingToggle.Parent = ScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = FloatingToggle

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(255, 215, 0)
floatStroke.Thickness = 2
floatStroke.Parent = FloatingToggle

local floatLabel = Instance.new("TextLabel")
floatLabel.Size = UDim2.new(1, 0, 1, 0)
floatLabel.BackgroundTransparency = 1
floatLabel.Text = "🥚"
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

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -16, 0, 26)
StatusBar.Position = UDim2.new(0, 8, 1, -32)
StatusBar.BackgroundColor3 = Color3.fromRGB(22, 30, 42)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 1, 0)
StatusLabel.Position = UDim2.new(0, 6, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Sẵn sàng | Hatch or Crack Hub v1.0"
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
Scroll.Size = UDim2.new(1, -16, 1, -84)
Scroll.Position = UDim2.new(0, 8, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

-- ── UI Component Helpers ──
local function createSectionHeader(titleText)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Text = " " .. titleText
    header.TextColor3 = Color3.fromRGB(0, 230, 118) -- Neon Multiplier Green
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = Scroll
    return header
end

local function createToggle(title, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(24, 32, 46)
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
    btn.BackgroundColor3 = defaultVal and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 62, 80)
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
        btn.BackgroundColor3 = currentVal and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 62, 80)
        btn.Text = currentVal and "ON" or "OFF"
        btn.TextColor3 = currentVal and Color3.fromRGB(15, 20, 28) or Color3.fromRGB(180, 190, 200)
        pcall(callback, currentVal)
    end)
    return frame
end

-- ── BUILD CONTROLS ──

-- SECTION 1: AUTO MULTIPLIER & CASHOUT
createSectionHeader("🎰 SMART AUTO MULTIPLIER & CHỐT LỜI")

-- Multiplier Live Display Box
local MultBox = Instance.new("Frame")
MultBox.Size = UDim2.new(1, -4, 0, 36)
MultBox.BackgroundColor3 = Color3.fromRGB(18, 26, 38)
MultBox.BorderSizePixel = 0
MultBox.Parent = Scroll
local mbCorner = Instance.new("UICorner")
mbCorner.CornerRadius = UDim.new(0, 6)
mbCorner.Parent = MultBox
local mbStroke = Instance.new("UIStroke")
mbStroke.Color = Color3.fromRGB(0, 230, 118)
mbStroke.Thickness = 1.2
mbStroke.Parent = MultBox

local MultDisplayLabel = Instance.new("TextLabel")
MultDisplayLabel.Size = UDim2.new(1, -12, 1, 0)
MultDisplayLabel.Position = UDim2.new(0, 8, 0, 0)
MultDisplayLabel.BackgroundTransparency = 1
MultDisplayLabel.Text = "Hệ Số Hiện Tại: [ x1.00 ]"
MultDisplayLabel.TextColor3 = Color3.fromRGB(0, 230, 118)
MultDisplayLabel.Font = Enum.Font.SourceSansBold
MultDisplayLabel.TextSize = 14
MultDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
MultDisplayLabel.Parent = MultBox

updateCurrentMultUI = function(mult)
    MultDisplayLabel.Text = "Hệ Số Hiện Tại: [ x" .. string.format("%.2f", mult) .. " ]"
end

createToggle("⚡ Bật Auto Gạt Cần & Ấp Trứng", State.AutoFarm, function(val)
    State.AutoFarm = val
    setStatus(val and "🎰 Đã BẬT Auto Farm Crash Multiplier!" or "⏸️ Đã TẮT Auto Farm.")
end)

-- Target Multiplier Preset Cycle Button
local btnTargetMult = Instance.new("TextButton")
btnTargetMult.Size = UDim2.new(1, -4, 0, 32)
btnTargetMult.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
btnTargetMult.Text = "🎯 Mục Tiêu Chốt Lời: [ " .. TargetPresets[State.MultiplierPresetIndex].Name .. " ]"
btnTargetMult.TextColor3 = Color3.fromRGB(255, 215, 0)
btnTargetMult.Font = Enum.Font.SourceSansBold
btnTargetMult.TextSize = 12
btnTargetMult.Parent = Scroll
local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 6)
tmCorner.Parent = btnTargetMult

btnTargetMult.MouseButton1Click:Connect(function()
    State.MultiplierPresetIndex = (State.MultiplierPresetIndex % #TargetPresets) + 1
    local p = TargetPresets[State.MultiplierPresetIndex]
    State.TargetMultiplier = p.Multiplier
    btnTargetMult.Text = "🎯 Mục Tiêu Chốt Lời: [ " .. p.Name .. " ]"
    setStatus("🎯 Đã chuyển mục tiêu chốt lời sang: " .. p.Name)
end)

createToggle("🥚 Tự Động Nạp Trứng Mới (Auto Next Egg)", State.AutoStartNewEgg, function(val)
    State.AutoStartNewEgg = val
end)

createToggle("⚡ Gạt Cần & Ấp 0s Hold (Instant Prompt)", State.InstantPrompt, function(val)
    State.InstantPrompt = val
end)

-- SECTION 2: TIỀN VÀ TIẾN TRÌNH (PROGRESSION)
createSectionHeader("💰 TIỀN & TIẾN TRÌNH (PROGRESSION)")

createToggle("🧲 Tự Hút Tiền & Phần Thưởng (Coins/Gems)", State.AutoCollectCash, function(val)
    State.AutoCollectCash = val
end)

createToggle("🔄 Tự Động Chuyển Sinh (Auto Rebirth)", State.AutoRebirth, function(val)
    State.AutoRebirth = val
end)

createToggle("⚡ Tự Nâng Cấp Máy Ấp / Tỷ Lệ May Mắn", State.AutoUpgradeMachine, function(val)
    State.AutoUpgradeMachine = val
end)

-- SECTION 3: TỐC ĐỘ & VẬT LÝ GIAN LẬN
createSectionHeader("🏃 TỐC ĐỘ & VẬT LÝ GIAN LẬN")

createToggle("⚡ Tăng Tốc Độ Chạy (Speed Boost)", State.SpeedEnabled, function(val)
    State.SpeedEnabled = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not val then
        hum.WalkSpeed = 16
    end
end)

-- Speed Cycle Button
local btnSpeedCycle = Instance.new("TextButton")
btnSpeedCycle.Size = UDim2.new(1, -4, 0, 30)
btnSpeedCycle.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
btnSpeedCycle.Text = "🏃 Tốc độ WalkSpeed: [ " .. tostring(State.WalkSpeed) .. " ] (Chạm để đổi)"
btnSpeedCycle.TextColor3 = Color3.fromRGB(0, 230, 118)
btnSpeedCycle.Font = Enum.Font.SourceSansBold
btnSpeedCycle.TextSize = 12
btnSpeedCycle.Parent = Scroll
local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 6)
scCorner.Parent = btnSpeedCycle

local speedPresets = {32, 60, 100, 150, 250, 400}
local speedIdx = 2
btnSpeedCycle.MouseButton1Click:Connect(function()
    speedIdx = (speedIdx % #speedPresets) + 1
    State.WalkSpeed = speedPresets[speedIdx]
    btnSpeedCycle.Text = "🏃 Tốc độ WalkSpeed: [ " .. tostring(State.WalkSpeed) .. " ] (Chạm để đổi)"
    if State.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = State.WalkSpeed
    end
end)

-- CFrame Boost Toggle Button
local btnCFrame = Instance.new("TextButton")
btnCFrame.Size = UDim2.new(1, -4, 0, 30)
btnCFrame.BackgroundColor3 = Color3.fromRGB(28, 38, 54)
btnCFrame.Text = "🌀 Lướt CFrame Siêu Âm: [ OFF ]"
btnCFrame.TextColor3 = Color3.fromRGB(180, 190, 200)
btnCFrame.Font = Enum.Font.SourceSansBold
btnCFrame.TextSize = 12
btnCFrame.Parent = Scroll
local cfCorner = Instance.new("UICorner")
cfCorner.CornerRadius = UDim.new(0, 6)
cfCorner.Parent = btnCFrame

btnCFrame.MouseButton1Click:Connect(function()
    if not State.CFrameBoost then
        State.CFrameBoost = true
        State.CFrameSpeedIndex = 1
    else
        State.CFrameSpeedIndex = State.CFrameSpeedIndex + 1
        if State.CFrameSpeedIndex > #CFrameMultipliers then
            State.CFrameBoost = false
            State.CFrameSpeedIndex = 1
        end
    end

    if State.CFrameBoost then
        local mult = CFrameMultipliers[State.CFrameSpeedIndex] or 5
        btnCFrame.Text = "🌀 Lướt CFrame Siêu Âm: [ ON " .. tostring(mult) .. "x ]"
        btnCFrame.TextColor3 = Color3.fromRGB(0, 230, 118)
    else
        btnCFrame.Text = "🌀 Lướt CFrame Siêu Âm: [ OFF ]"
        btnCFrame.TextColor3 = Color3.fromRGB(180, 190, 200)
    end
end)

createToggle("🦘 Nhảy Vô Hạn (Infinite Jump)", State.InfiniteJump, function(val)
    State.InfiniteJump = val
end)

createToggle("👻 Đi Xuyên Tường & Hàng Rào (Noclip)", State.Noclip, function(val)
    State.Noclip = val
end)

createToggle("🛸 Giữ Bay Lơ Lửng (Float / Hover)", State.FloatMode, function(val)
    State.FloatMode = val
end)

-- SECTION 4: TREO MÁY & BẢO VỆ
createSectionHeader("🛡️ TREO MÁY 24/7 & GIẢM LAG")

createToggle("🛡️ Anti-AFK 24/7 (Chống Văng Game)", State.AntiAFK, function(val)
    State.AntiAFK = val
end)

createToggle("🚀 Giảm Đồ Họa Treo Máy (FPS Booster)", State.FPSBoost, function(val)
    State.FPSBoost = val
    pcall(function()
        if val then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            setStatus("🚀 Đã bật chế độ giảm lag FPS Boost!")
        else
            Lighting.GlobalShadows = true
            setStatus("Đã tắt chế độ FPS Boost.")
        end
    end)
end)

setStatus("Đã khởi tạo thành công Hatch or Crack Hub V1.0!")
