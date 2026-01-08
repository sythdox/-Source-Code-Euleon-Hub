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