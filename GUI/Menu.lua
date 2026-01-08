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