-- // Prefetch
do
    if not isfolder("Eternity") then
        makefolder("Eternity")
    end
    --
    if not isfolder("Eternity/Games") then
        makefolder("Eternity/Games")
    end
    if not isfolder("Eternity/Modules") then
        makefolder("Eternity/Modules")
    end
    --
    if isfile("Eternity/Games/Universal.lua") then
        writefile("Eternity/Games/Universal.lua", game:HttpGet("https://raw.githubusercontent.com/ixeternal/lua/main/Universal.lua"))
    end
    if not isfile("Eternity/Modules/Library.lua") then
        writefile("Eternity/Modules/Library.lua", game:HttpGet("https://raw.githubusercontent.com/ixeternal/lua/main/Library.lua"))
    end
end

-- // Variables
local Players = game:GetService("Players")
--
local LocalPlayer = Players.LocalPlayer

-- // Tables
local Library, Utility, Flags, Theme = loadfile("Eternity/Modules/Library.lua")()
local Eternity = {
    Games = {"Universal", "Criminality (IN DEV)"},
    Account = {
        Username = LocalPlayer.Name or "Eternal"
    }
}

-- // Loader
do
    local Window = Library:Loader({Name = ("Welcome To Eternity, %s."):format(Eternity.Account.Username)}) do
        --  
        local MainLoader = Window:Page({Name = "Eternity"}) do
            --
            local Loader = MainLoader:Section({Name = "Loader", Fill = false, Size = 141}) do
                --
                Loader:Dropdown({Name = "Choose Branch:", Options = Eternity.Games, Max = #Eternity.Games, Default = "Universal", Pointer = "Eternity_Game"})
                --
                Loader:Button({Name = "Load", Pointer = "Eternity_Load", Callback = function() 
                    if isfile("Eternity/Games/".. tostring(Flags["Eternity_Game"]:Get() ..".lua")) then
                        loadfile("Eternity/Games/".. tostring(Flags["Eternity_Game"]:Get() ..".lua"))()
                        Window:Unload()
                    end
                end})
                --
                Loader:Button({Name = "Unload", Pointer = "Eternity_Unload", Callback = function() 
                    Window:Unload()
                end})
                --
                Loader:Label({Name = "Note: This is a beta version of the cheat \n Report any bugs to Eternal", Middle = true, Pointer = "Eternity_Label"})
                --
            end 
            --
            local Settings = MainLoader:Section({Name = "Settings", Fill = false, Size = 130}) do
                --
                Settings:Button({Name = "Rejoin", Pointer = "Eternity_Rejoin", Callback = function() 
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
                end})
                --
                Settings:Slider({Name = "Max Frames Per Second", Default = 360, Minimum = 1, Maximum = 360, Prefix = " Fps", Decimals = 0.01, Pointer = "Eternity_FpsCap", Callback = function(Number)
                    setfpscap(Number)
                end})
                --
            end 
        end
        -- 
    end
    --
    Window.uibind = Enum.KeyCode.Home
    Window:Initialize()
end
