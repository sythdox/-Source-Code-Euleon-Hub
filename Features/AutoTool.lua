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