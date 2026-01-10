-- Features/AutoConvert.lua
local AutoConvert = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerHiveCommand = ReplicatedStorage.Events.PlayerHiveCommand
local Tween = require("Utility/Tween")

local function getPollenPercentage()
    local coreStats = LocalPlayer:FindFirstChild("CoreStats")
    if not coreStats then return 0 end
    
    local pollen = coreStats:FindFirstChild("Pollen")
    local capacity = coreStats:FindFirstChild("Capacity")
    
    if pollen and capacity and capacity.Value > 0 then
        return (pollen.Value / capacity.Value) * 100
    end
    return 0
end

function AutoConvert:Start(thresholdPercent)
    if self.running then return end
    
    self.running = true
    self.threshold = thresholdPercent or 90
    
    
    self:CheckAndConvert()
    
    while self.running do
        task.wait(1)
        self:CheckAndConvert()
    end
end

function AutoConvert:Stop()
    self.running = false
end

function AutoConvert:CheckAndConvert()
    local percentage = getPollenPercentage()
    if percentage >= self.threshold then
        local success, err = pcall(function()
            self:ConvertAtHive()
        end)
        
        if not success then
            warn("[AutoConvert] Error:", err)
        end
    end
end

function AutoConvert:ConvertAtHive()
    if self.isConverting then return end
    self.isConverting = true
    
    local HiveClaim = require("Features/HiveClaim")
    local hive = HiveClaim.GetPlayerHive()
    
    if not hive then 
        self.isConverting = false
        return 
    end
    
    local spawnPos = hive:FindFirstChild("SpawnPos")
    if spawnPos then
        local arrived = false
        
        local tween = Tween:Teleport(spawnPos.Value.Position + Vector3.new(0, 3, 0), function(success)
            arrived = success
        end)
        
        if tween then
            local startWait = tick()
            while not arrived and tick() - startWait < 15 do
                task.wait(0.1)
            end
        end
    end
    
    if not LocalPlayer.Character then
        self.isConverting = false
        return
    end
    
    PlayerHiveCommand:FireServer("ToggleHoneyMaking")
    
    local coreStats = LocalPlayer:FindFirstChild("CoreStats")
    if coreStats then
        local pollen = coreStats:FindFirstChild("Pollen")
        if pollen then
            local startTime = tick()
            while pollen.Value > 0 and tick() - startTime < 30 do
                task.wait(1)
            end
        end
    end
    
    task.wait(1)
    self.isConverting = false
end

function AutoConvert:SetThreshold(percent)
    self.threshold = math.clamp(percent, 50, 100)
    
   
    if self.running then
        self:CheckAndConvert()
    end
end

return AutoConvert