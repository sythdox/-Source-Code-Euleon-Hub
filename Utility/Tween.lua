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