-- GUI/Menu.lua

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()

getgenv().EuleonFlags = getgenv().EuleonFlags or {
    TempGatherTime = 5,
    TempPriority = 1,
    AutoConvertToggle = false,
    AutoConvertPercent = 90,
    ["AutoFarm/FieldList"] = {}
}

do
    local Window = Compkiller.new({
        Name = "Euleon Hub",
        Icon = "rbxassetid://0"
    })

    -- Auto Farm tab
    local AutoFarmTab = Window:DrawTab({
        Name = "Auto Farm"
    })

    -- Tools section
    local ToolsSection = AutoFarmTab:DrawSection({
        Name = "Tools"
    })

    local AutoTool = require("Features/AutoTool")
    ToolsSection:AddToggle({
        Name = "Auto Tool Use",
        Default = false,
        Callback = function(value)
            if value then
                AutoTool:Start(0.1)
            else
                AutoTool:Stop()
            end
        end
    })

    -- Convert section
    local ConvertSection = AutoFarmTab:DrawSection({
        Name = "Convert"
    })

    local AutoConvert = require("Features/AutoConvert")
    ConvertSection:AddToggle({
        Name = "Auto Convert",
        Default = false,
        Callback = function(value)
            EuleonFlags.AutoConvertToggle = value
            if value then
                AutoConvert:Start(EuleonFlags.AutoConvertPercent)
            else
                AutoConvert:Stop()
            end
        end
    })

    ConvertSection:AddSlider({
        Name = "Convert At %",
        Min = 50,
        Max = 100,
        Default = 90,
        Callback = function(value)
            EuleonFlags.AutoConvertPercent = value
            AutoConvert:SetThreshold(value)
            if EuleonFlags.AutoConvertToggle then
                AutoConvert:CheckAndConvert()
            end
        end
    })

    -- Field Farming section
    local FarmSection = AutoFarmTab:DrawSection({
        Name = "Field Farming"
    })

    FarmSection:AddToggle({
        Name = "Enable Auto Farm",
        Default = false,
        Callback = function(enabled)
            print("Auto Farm enabled:", enabled)
        end
    })

    local function UpdateFieldListText()
        local list = EuleonFlags["AutoFarm/FieldList"]
        if #list == 0 then return "Selected Fields: None" end
        
        local lines = {"Selected Fields:"}
        for i, entry in ipairs(list) do
            table.insert(lines, i .. ". " .. entry.field .. " (" .. entry.time .. " min, prio " .. entry.priority .. ")")
        end
        return table.concat(lines, "\n")
    end

    local fieldListLabel = FarmSection:AddParagraph({
        Title = "Field List",
        Content = UpdateFieldListText()
    })

    FarmSection:AddButton({
        Name = "Refresh List Display",
        Callback = function()
            fieldListLabel:SetContent(UpdateFieldListText())
        end
    })

    -- Add field 
    local AddFieldSection = AutoFarmTab:DrawSection({
        Name = "Add New Field",
        Collapsible = true
    })

    local allFields = {
        "Sunflower Field", "Dandelion Field", "Mushroom Field", "Blue Flower Field",
        "Clover Field", "Spider Field", "Strawberry Field", "Bamboo Field",
        "Pineapple Patch", "Stump Field", "Cactus Field", "Pumpkin Patch",
        "Pine Tree Forest", "Rose Field", "Mountain Top Field", "Coconut Field",
        "Pepper Patch"
    }

    local selectedField = "Sunflower Field"
    AddFieldSection:AddDropdown({
        Name = "Select Field to Add",
        Values = allFields,
        Default = "Sunflower Field",
        Callback = function(selected)
            selectedField = selected
        end
    })

    AddFieldSection:AddTextBox({
        Name = "Gather Time (mins)",
        Default = "5",
        Placeholder = "Time in minutes",
        Callback = function(text)
            EuleonFlags.TempGatherTime = tonumber(text) or 5
        end
    })

    AddFieldSection:AddTextBox({
        Name = "Priority (order)",
        Default = "1",
        Placeholder = "Number (1 = first)",
        Callback = function(text)
            EuleonFlags.TempPriority = tonumber(text) or 1
        end
    })

    AddFieldSection:AddButton({
        Name = "Add Field to List",
        Callback = function()
            local fieldList = EuleonFlags["AutoFarm/FieldList"]
            local newEntry = {
                field = selectedField,
                time = EuleonFlags.TempGatherTime,
                priority = EuleonFlags.TempPriority
            }

            for _, entry in ipairs(fieldList) do
                if entry.priority >= newEntry.priority then
                    entry.priority = entry.priority + 1
                end
            end

            table.insert(fieldList, newEntry)
            table.sort(fieldList, function(a, b)
                return a.priority < b.priority
            end)

            fieldListLabel:SetContent(UpdateFieldListText())
        end
    })

    -- Other tabs
    Window:DrawTab({Name = "Movement"})
    Window:DrawTab({Name = "Combat"})
    Window:DrawTab({Name = "Misc"})
    Window:DrawTab({Name = "Onett SaveFile"})
    Window:DrawTab({Name = "Settings"})

    -- Load notification
    Compkiller.newNotify({
        Title = "Euleon Hub",
        Content = "Loaded successfully! Ready when you are 🐝"
    })
end

return {}