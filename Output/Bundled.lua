-- Bundled by luabundle {"luaVersion":"5.1","version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)



local Startups = 
{
    
    HiveClaim = require("Features/HiveClaim"),

}

-- then shot that runs all the start ups
require("GUI/Menu")
print("Euleon Hub loaded!")
end)
__bundle_register("GUI/Menu", function(require, _LOADED, __bundle_register, __bundle_modules)
-- GUI/Menu.lua

-- Load library from public repo
local Atlas = loadstring(game:HttpGet("https://raw.githubusercontent.com/sythdox/-Source-Code-Euleon-Hub/main/GUI/Library-Src.lua"))()
do  -- UI creation
   
    local UI = Atlas.new({
        Name = "Euleon Hub";
        ConfigFolder = "EuleonHub";         -- Folder for saved configs
        Credit = "Syth.dox";
        Color = Color3.fromRGB(4, 231, 255);
        Bind = "LeftControl";               -- UI Toggle
        UseLoader = false;                  -- Disable loader/key system
    })

    -- Create pages 

    -- Auto Farm page
    local autoFarmPage = UI:CreatePage("Auto Farm")
    -- Tool Sections
    local ToolsSection = autoFarmPage:CreateSection("Tools")


    -- auto tool toggle
    local AutoTool = require("Features/AutoTool")
    ToolsSection:CreateToggle({
        Name = "Auto Tool Use";
        Flag = "AutoToolToggle";
        Default = false;
        Callback = function(value)
            if value then
                AutoTool:Start(0.1)
            else
                AutoTool:Stop()
            end
        end;
    })

    -- Convert Sections
    local ConvertSection = autoFarmPage:CreateSection("Convert")
    -- auto convert
    local AutoConvert = require("Features/AutoConvert")
    ConvertSection:CreateToggle({
     Name = "Auto Convert";
     Flag = "AutoConvertToggle";
     Default = false;
     Callback = function(value)
         if value then
            AutoConvert:Start(90)  -- Default 90%
         else
            AutoConvert:Stop()
         end
     end;
    })
    ConvertSection:CreateSlider({
     Name = "Convert At %";
     Flag = "AutoConvertPercent";
     Min = 50;
     Max = 100;
     Default = 90;
     Callback = function(value)
        AutoConvert:SetThreshold(value)
     end;
    })



    UI:CreatePage("Movement")
    UI:CreatePage("Combat")
    UI:CreatePage("Misc")
    UI:CreatePage("Onett SaveFile")
    UI:CreatePage("Settings")

    -- Load Notif
    UI:Notify({
        Title = "Euleon Hub";
        Content = "Loaded successfully! Ready when you are 🐝";
    })
end

return {}
end)
__bundle_register("Features/AutoConvert", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Features/AutoConvert.lua
local AutoConvert = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerHiveCommand = ReplicatedStorage.Events.PlayerHiveCommand
local Tween = require("Utility/Tween")

function AutoConvert:Start(thresholdPercent)
    if self.running then return end
    
    self.running = true
    self.threshold = thresholdPercent or 90
    
    while self.running do
        task.wait(1)
        
        local coreStats = LocalPlayer:FindFirstChild("CoreStats")
        if not coreStats then
            
        else
            local pollen = coreStats:FindFirstChild("Pollen")
            local capacity = coreStats:FindFirstChild("Capacity")
            
            if pollen and capacity and capacity.Value > 0 then
                local percentage = (pollen.Value / capacity.Value) * 100
                
                if percentage >= self.threshold then
                    local success, err = pcall(function()
                        self:ConvertAtHive()
                    end)
                    
                    if not success then
                        warn("[AutoConvert] Error:", err)
                    end
                end
            end
        end
    end
end

function AutoConvert:Stop()
    self.running = false
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
end

return AutoConvert
end)
__bundle_register("Features/HiveClaim", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Features/HiveClaim.lua
local HiveClaim = {}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

function HiveClaim.ClaimHive()
    local hives = Workspace.Honeycombs:GetChildren()
    
    for _, hive in ipairs(hives) do
        if hive:FindFirstChild("Owner") and hive.Owner.Value == nil then
            if hive:FindFirstChild("HiveID") then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local spawnPos = hive:FindFirstChild("SpawnPos")
                    if spawnPos then
                        character.HumanoidRootPart.CFrame = spawnPos.Value + Vector3.new(0, 3, 0)
                    end
                end
                
                ReplicatedStorage.Events.ClaimHive:FireServer(hive.HiveID.Value)
                return hive
            end
        end
    end
    
    return nil
end
function HiveClaim.GetPlayerHive()
    local hives = Workspace.Honeycombs:GetChildren()
    
    for _, hive in ipairs(hives) do
        if hive:FindFirstChild("Owner") and hive.Owner.Value == LocalPlayer then
            return hive
        end
    end
    
    return nil
end

-- Claims Hive
HiveClaim.ClaimHive()

return HiveClaim
end)
__bundle_register("Utility/Tween", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Utility/Tween.lua
local Tween = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

function Tween:Teleport(position, callback)
    local character = Players.LocalPlayer.Character
    if not character then 
        if callback then callback(false) end
        return 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        if callback then callback(false) end
        return 
    end
    
    local currentPos = humanoidRootPart.Position
    local distance = (position - currentPos).Magnitude
    
    
    local duration = math.clamp(distance / 50, 1, 10)
    
    local targetCFrame = CFrame.new(position) * humanoidRootPart.CFrame.Rotation
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = targetCFrame
    })
    
    tween.Completed:Connect(function()
        if callback then callback(true) end
    end)
    
    tween:Play()
    return tween
end

function Tween:ToPosition(position, callback)
    return self:Teleport(position, callback)
end

function Tween:ToObject(object, callback)
    if not object then 
        if callback then callback(false) end
        return 
    end
    
    local part = object:FindFirstChild("PrimaryPart") or object:IsA("BasePart") and object
    if not part then 
        if callback then callback(false) end
        return 
    end
    
    return self:Teleport(part.Position + Vector3.new(0, 3, 0), callback)
end

return Tween
end)
__bundle_register("Features/AutoTool", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Features/AutoTool.lua
local AutoTool = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolCollect = ReplicatedStorage.Events.ToolCollect

function AutoTool:Start(interval)
    interval = interval or 0.1
    
    self.running = true
    self.connection = RunService.Heartbeat:Connect(function()
        if not self.running then return end
        toolCollect:FireServer()
        task.wait(interval)
    end)
end

function AutoTool:Stop()
    self.running = false
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

return AutoTool
end)
return __bundle_require("__root")