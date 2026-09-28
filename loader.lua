--[[
    ===================================================================
    🌊 HATCH OR CRACK AN EGG! - AUTO MUA SÔNG & BÁN TRỨNG V2.7
    Game: [👺] Ấp hoặc nứt một quả trứng (by Get it or Lose it)
    Repository: https://github.com/khahuynh963/hatch_or_crack_an_egg.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus.
    ===================================================================
--]]

pcall(function()
    local container = (gethui and gethui()) or game:GetService("CoreGui")
    if container then
        if container:FindFirstChild("HatchOrCrackRiverHubGui") then
            container.HatchOrCrackRiverHubGui:Destroy()
        end
        if container:FindFirstChild("HatchOrCrackHubGui") then
            container.HatchOrCrackHubGui:Destroy()
        end
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") then
        if pl.PlayerGui:FindFirstChild("HatchOrCrackRiverHubGui") then
            pl.PlayerGui.HatchOrCrackRiverHubGui:Destroy()
        end
        if pl.PlayerGui:FindFirstChild("HatchOrCrackHubGui") then
            pl.PlayerGui.HatchOrCrackHubGui:Destroy()
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/hatch_or_crack_an_egg/main/script.lua?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))))()
