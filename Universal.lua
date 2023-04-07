
-- // Tables
local Library, Utility, Flags, Theme = loadfile("Eternity/Modules/Library.lua")()
local Eternity, Visuals, Misc, Color, Math = {
    Connections = {},
    Account = {
        Username = "Eternal",
        UserID = "2137"
    },
    Locals = {
        Window = {},
        LastStutter = tick(),
        TriggerTick = tick(),
        AimAssistFOV = 15,
        DeadzoneFOV = 10,
        PartSizes = {
            ["Head"] = Vector3.new(2, 1, 1),
            ["Torso"] = Vector3.new(2, 2, 1),
            ["Left Arm"] = Vector3.new(1, 2, 1),
            ["Right Arm"] = Vector3.new(1, 2, 1),
            ["Left Leg"] = Vector3.new(1, 2, 1),
            ["Right Leg"] = Vector3.new(1, 2, 1)
        }
    },
}, {
    Bases = {},
    Base = {}
}, {
}, {
}, {}

-- Services
local UserInputService, TeleportService, RunService, Workspace, Lighting, Players = game:GetService("UserInputService"), game:GetService("TeleportService"), game:GetService("RunService"), game:GetService("Workspace"), game:GetService("Lighting"), game:GetService("Players") 

-- Locals
local LocalPlayer = Players.LocalPlayer

-- Variables
local GetUpvalue = debug.getupvalue
--
local Find, Clear = table.find, table.clear
--
local Huge, Pi, Clamp, Round, Abs, Floor = math.huge, math.pi, math.clamp, math.round, math.abs, math.floor
--
local Create, Resume = coroutine.create, coroutine.resume
--
local CreateRenderObject = GetUpvalue(Drawing.new, 1)
local DestroyRenderObject = GetUpvalue(GetUpvalue(Drawing.new, 7).__index, 3)
local SetRenderProperty = GetUpvalue(GetUpvalue(Drawing.new, 7).__newindex, 4)
local GetRenderProperty = GetUpvalue(GetUpvalue(Drawing.new, 7).__index, 4)
--
do -- Renders
    for Index = 1, 2 do
        local Circle = (Index == 1 and "AimAssist" or "Deadzone")
        --
        Visuals[Circle .. "Circle"] = CreateRenderObject("Circle")
        SetRenderProperty(Visuals[Circle .. "Circle"], "Filled", true)
        SetRenderProperty(Visuals[Circle .. "Circle"], "ZIndex", 59)
        --
        Visuals[Circle .. "Outline"] = CreateRenderObject("Circle")
        SetRenderProperty(Visuals[Circle .. "Outline"], "Thickness", 1.5)
        SetRenderProperty(Visuals[Circle .. "Outline"], "Filled", false)
        SetRenderProperty(Visuals[Circle .. "Outline"], "ZIndex", 60)
    end
end


do -- Color
    function Color:Multiply(Color, Multiplier)
        return Color3.new(Color.R * Multiplier, Color.G * Multiplier, Color.B * Multiplier)
    end
    --
    function Color:Add(Color, Addition)
        return Color3.new(Color.R + Addition, Color.G + Addition, Color.B + Addition)
    end
    --
    function Color:Lerp(Value, MinColor, MaxColor)
        if Value <= 0 then return MaxColor end
        if Value >= 100 then return MinColor end
        --
        return Color3.new(
            MaxColor.R + (MinColor.R - MaxColor.R) * Value,
            MaxColor.G + (MinColor.G - MaxColor.G) * Value,
            MaxColor.B + (MinColor.B - MaxColor.B) * Value
        )
    end
end

do -- Math
    function Math:RoundVector(Vector)
        return Vector2.new(Round(Vector.X), Round(Vector.Y))
    end
    --
    function Math:Shift(Number)
        return Acos(Cos(Number * Pi)) / Pi
    end
    --
    function Math:Random(Number)
        return Random(-Number, Number)
    end
    --
    function Math:RandomVec3(X, Y, Z)
        return Vector3.new(Math:Random(X), Math:Random(Y), Math:Random(Z))
    end
end

do -- Eternity
    --
    function Eternity:PlayerAdded(Player)
        Visuals:Create({Player = Player})
    end
    --
    function Eternity:ActiveKey(Key)
        if Key == "Off" then
            return true
        elseif Key == "MB1" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif Key == "MB2" then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif Key == "Ctrl" then
            return UserInputService:IsKeyDown(Enum.KeyCode["LeftControl"])
        elseif Key == "Alt" then
            return UserInputService:IsKeyDown(Enum.KeyCode["LeftAlt"])
        else
            return UserInputService:IsKeyDown(Enum.KeyCode[Key])
        end
    end
    --
    function Eternity:ToHitboxes(Hitboxes)
        if Hitboxes == "Upper Top" then
            return {"Head", "Torso"}
        elseif Hitboxes == "Top" then
            return {"Head", "Torso", "Arms"}
        elseif Hitboxes == "Lower" then
            return {"Torso", "Arms", "Legs"}
        elseif Hitboxes == "All" then
            return {"Head", "Torso", "Arms", "Legs"}
        else
            return {Hitboxes}
        end
    end
    --
    function Eternity:GetBodyParts(Character, RootPart, Indexes, Hitboxes)
        local Parts = {}
        local Hitboxes = Hitboxes or {"Head", "Torso", "Arms", "Legs"}
        --
        for Index, Part in pairs(Character:GetChildren()) do
            if Part:IsA("BasePart") and Part ~= RootPart then
                if Find(Hitboxes, "Head") and Part.Name:lower():find("head") then
                    Parts[Indexes and Part.Name or #Parts + 1] = Part
                elseif Find(Hitboxes, "Torso") and Part.Name:lower():find("torso") then
                    Parts[Indexes and Part.Name or #Parts + 1] = Part
                elseif Find(Hitboxes, "Arms") and Part.Name:lower():find("arm") then
                    Parts[Indexes and Part.Name or #Parts + 1] = Part
                elseif Find(Hitboxes, "Legs") and Part.Name:lower():find("leg") then
                    Parts[Indexes and Part.Name or #Parts + 1] = Part
                elseif (Find(Hitboxes, "Arms") and Part.Name:lower():find("hand")) or (Find(Hitboxes, "Legs ") and Part.Name:lower():find("foot")) then
                    Parts[Indexes and Part.Name or #Parts + 1] = Part
                end
            end
        end
        --
        return Parts
    end
    --
    function Eternity:GetBoundingBox(BodyParts, RootPart)
        local Size = Vector3.new(0, 0, 0)
        --
        for Index, Value in pairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
            local Part = BodyParts[Value]
            local PartSize = (Part and Part.Size or Eternity.Locals.PartSizes[Value])
            --
            if Value == "Head" then
                Size = (Size + Vector3.new(0, PartSize.Y, 0))
            elseif Value == "Torso" then
                Size = (Size + Vector3.new(PartSize.X, PartSize.Y, PartSize.Z))
            elseif Value == "Left Arm" then
                Size = (Size + Vector3.new(PartSize.X, 0, 0))
            elseif Value == "Right Arm" then
                Size = (Size + Vector3.new(PartSize.X, 0, 0))
            elseif Value == "Left Leg" then
                Size = (Size + Vector3.new(0, PartSize.Y, 0))
            elseif Value == "Right Leg" then
                Size = (Size + Vector3.new(0, PartSize.Y, 0))
            end
        end
        --
        return (RootPart.CFrame + Vector3.new(0, -0.125, 0)), Size
    end
    --
    function Eternity:GetCharacter(Player)
        return Player.Character
    end
    --
    function Eternity:GetPlayerParent(Player)
        return Player.Parent
    end
    --
    function Eternity:GetHumanoid(Player, Character)
        return Character:FindFirstChildOfClass("Humanoid")
    end
    --
    function Eternity:GetHealth(Player, Character, Humanoid)
        if Humanoid then
            return Clamp(Humanoid.Health, 0, Humanoid.MaxHealth), Humanoid.MaxHealth
        end
    end
    --
    function Eternity:GetRootPart(Player, Character, Humanoid)
        return Humanoid.RootPart
    end
    --
    function Eternity:GetTeam(Player)
        return Player.Team
    end
    --
    function Eternity:CheckTeam(Player1, Player2)
        return (Eternity:GetTeam(Player1) ~= Eternity:GetTeam(Player2))
    end
    --
    function Eternity:GetIgnore(Unpacked)
        if Unpacked then
            return
        else
            return {}
        end
    end
    --
    function Eternity:GetOrigin(Origin)
        if Origin == "Head" then
            local Object, Humanoid, RootPart = Eternity:ValidateClient(Client)
            local Head = Object:FindFirstChild("Head")
            --
            if Head and Head:IsA("RootPart") then
                return Head.CFrame.Position
            end
        elseif Origin == "Torso" then
            local Object, Humanoid, RootPart = Eternity:ValidateClient(Client)
            --
            if RootPart then
                return RootPart.CFrame.Position
            end
        end
        --
        return Workspace.CurrentCamera.CFrame.Position
    end
    --
    function Eternity:GetPlayers()
        return Players:GetPlayers()
    end
    --
    function Eternity:PlayerAdded(Player)
        Visuals:Create({Player = Player})
    end
    --
    function Eternity:RayCast(Part, Origin, Ignore, Distance)
        local Ignore = Ignore or {}
        local Distance = Distance or 2000
        --
        local Cast = Ray.new(Origin, (Part.Position - Origin).Unit * Distance)
        local Hit = Workspace:FindPartOnRayWithIgnoreList(Cast, Ignore)
        --
        return (Hit and Hit:IsDescendantOf(Part.Parent)) == true, Hit
    end
    --
    function Eternity:ValidateClient(Player)
        local Object = Eternity:GetCharacter(Player)
        local Humanoid = (Object and Eternity:GetHumanoid(Player, Object))
        local RootPart = (Humanoid and Eternity:GetRootPart(Player, Object, Humanoid))
        --
        return Object, Humanoid, RootPart
    end
    --
    function Eternity:ClientAlive(Player, Character, Humanoid)
        local Health, MaxHealth = Eternity:GetHealth(Player, Character, Humanoid)
        --
        return (Health > 0)
    end
    --
    function Eternity:RoundVector(Vector)
        return Vector2.new(math.round(Vector.X), math.round(Vector.Y))
    end
    --
    function Eternity:UpdateFieldOfView()
        local ScreenSize = Workspace.CurrentCamera.ViewportSize
        --
        local FieldOfView = tonumber(Flags["LegitAimAssist_FieldOfView"]:Get())
        local Deadzone = ((Flags["LegitAimAssist_Deadzone"]:Get() == true) and tonumber(Flags["LegitAimAssist_DeadzoneAmmount"]:Get()) or 0)
        local Multiplier = (Eternity.Locals.PossibleTarget and Eternity.Locals.PossibleTarget.Multiplier or 1)
        --
        Eternity.Locals.AimAssistFOV = ((FieldOfView / 100) * ScreenSize.Y)
        Eternity.Locals.DeadzoneFOV = (Eternity.Locals.AimAssistFOV * 0.9) * (Deadzone / 100)
        --
        Eternity.Locals.VisualAimAssistFOV = (Eternity.Locals.AimAssistFOV * Multiplier)
        Eternity.Locals.VisualDeadzoneFOV = (Eternity.Locals.DeadzoneFOV * Multiplier)
    end
    --
    function Eternity:GetAimAssistTarget()
        local Target = {
            Player = nil,
            Object = nil,
            Part = nil,
            Vector = nil,
            Magnitude = Huge
        }
        --
        local MouseLocation = UserInputService:GetMouseLocation()
        --
        local FieldOfView = tonumber(Flags["LegitAimAssist_FieldOfView"]:Get()) 
        local Origin = "Camera" -
        local FOVType = Flags["LegitAimAssist_FOVType"]:Get()
        local Deadzone = "Off" 
        local Hitboxes = Flags["LegitAimAssist_Hitbox"]:Get() 
        --
        local Checks = Flags["LegitAimAssist_Checks"]:Get()
        --
        local TeamCheck = Find(Checks, "Team") 
        local WallCheck = Find(Checks, "Wall") 
        local VisibleCheck = Find(Checks, "Visible") 
        local ForceFieldCheck = Find(Checks, "Forcefield")
        local AliveCheck = Find(Checks, "Alive") 
        --
        local Disabled = false 
        local FieldOfView = Eternity.Locals.AimAssistFOV / 2
        local Disabled2 = false 
        local Deadzone = Eternity.Locals.DeadzoneFOV / 2
        --
        local Dynamic = 625
        local DynamicHigh = Dynamic * 2
        local DynamicLow = Dynamic / 8.5
        --
        local PossibleTarget = {
            Player = nil,
            Object = nil,
            Magnitude = Huge
        }
        --
        for Index, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                if (TeamCheck and not Eternity:CheckTeam(Client, Player)) then continue end
                --
                local Object, Humanoid, RootPart = Eternity:ValidateClient(Player)
                --
                if (Object and Humanoid and RootPart) then
                    if (ForceFieldCheck and Object:FindFirstChildOfClass("ForceField")) then continue end
                    if (AliveCheck and not Eternity:ClientAlive(Player, Character, Humanoid)) then continue end
                    --
                    local Position, Visible = Workspace.CurrentCamera:WorldToViewportPoint(RootPart.CFrame.Position)
                    local Position2 = Vector2.new(Position.X, Position.Y)
                    local Magnitude = (MouseLocation - Position2).Magnitude
                    local Distance = (Workspace.CurrentCamera.CFrame.Position - RootPart.CFrame.Position).Magnitude
                    local SelfAimAssistFOV = FieldOfView
                    local SelfDeadzoneFOV = Deadzone
                    local SelfMultiplier = 1
                    --
                    if FOVType == "Dynamic" then
                        SelfMultiplier = (Distance - DynamicLow) > 0 and (1 - ((Distance - DynamicLow) / Dynamic)) or (1 + (Clamp(Abs((Distance - DynamicLow) * 1.75), 0, DynamicHigh) / 100)) * 1.25
                    end
                    --
                    if Visible and Magnitude <= PossibleTarget.Magnitude then
                        PossibleTarget = {
                            Player = Player,
                            Object = Object,
                            Distance = Distance,
                            Multiplier = SelfMultiplier,
                            Magnitude = Magnitude
                        }
                    end
                    --
                    SelfAimAssistFOV = (SelfAimAssistFOV * SelfMultiplier)
                    SelfDeadzoneFOV = (SelfDeadzoneFOV * SelfMultiplier)
                    --
                    if ((not Disabled) and not (Magnitude <= SelfAimAssistFOV)) then continue end
                    --
                    if Visible and Magnitude <= Target.Magnitude then
                        local ClosestPart, ClosestVector, ClosestMagnitude = nil, nil, Huge
                        --
                        for Index2, Part in pairs(Eternity:GetBodyParts(Object, RootPart, false, Hitboxes)) do
                            if (VisibleCheck and not (Part.Transparency ~= 1)) then continue end
                            --
                            local Position3, Visible2 = Workspace.CurrentCamera:WorldToViewportPoint(Part.CFrame.Position)
                            local Position4 = Vector2.new(Position3.X, Position3.Y)
                            local Magnitude2 = (MouseLocation - Position4).Magnitude
                            --
                            if Position4 and Visible2 then
                                if ((not Disabled) and not (Magnitude2 <= SelfAimAssistFOV)) then continue end
                                if (WallCheck and not Eternity:RayCast(Part, Eternity:GetOrigin(Origin), {Eternity:GetCharacter(LocalPlayer), Eternity:GetIgnore(true)})) then continue end
                                --
                                if Magnitude2 <= ClosestMagnitude then
                                    ClosestPart = Part
                                    ClosestVector = Position4
                                    ClosestMagnitude = Magnitude2
                                end
                            end
                        end
                        --
                        if ClosestPart and ClosestVector and ClosestMagnitude then
                            Target = {
                                Player = Player,
                                Object = Object,
                                Part = ClosestPart,
                                Vector = ClosestVector,
                                Distance = Distance,
                                Multiplier = SelfMultiplier,
                                Magnitude = ClosestMagnitude
                            }
                        end
                    end
                end
            end
        end
        --
        if Target.Player and Target.Object and Target.Part and Target.Vector and Target.Magnitude then
            PossibleTarget = {
                Player = Target.Player,
                Object = Target.Object,
                Distance = Target.Distance,
                Multiplier = Target.Multiplier,
                Magnitude = Target.Magnitude
            }
            --
            Eternity.Locals.Target = Target
        else
            Eternity.Locals.Target = nil
        end
        --
        if PossibleTarget and PossibleTarget.Distance and PossibleTarget.Multiplier then
            Eternity.Locals.PossibleTarget = PossibleTarget
        else
            Eternity.Locals.PossibleTarget = nil
        end
    end
    --
    function Eternity:AimAssist()
        if Eternity.Locals.Target and Eternity.Locals.Target.Part and Eternity.Locals.Target.Vector then
            local Stutter = tonumber(Flags["LegitAimAssist_Stutter"]:Get())
            local Deadzone = (Flags["LegitAimAssist_Deadzone"]:Get() == false)
            local Multiplier = Eternity.Locals.Target.Multiplier
            --
            local Tick = tick()
            --
            if ((Tick - Eternity.Locals.LastStutter) >= (Stutter / 1000)) and not ((not Deadzone) and not (Eternity.Locals.Target.Magnitude >= ((Eternity.Locals.DeadzoneFOV * Multiplier) / 2))) then
                Eternity.Locals.LastStutter = Tick
                --
                local MouseLocation = UserInputService:GetMouseLocation()
                local MoveVector =  (Eternity.Locals.Target.Vector - MouseLocation)
                local Smoothness = Vector2.new((Flags["LegitAimAssist_HorizontalSmoothing"]:Get() / 10), (Flags["LegitAimAssist_VerticalSmoothing"]:Get() / 10))
                --
                local FinalVector = Eternity:RoundVector(Vector2.new(MoveVector.X / Smoothness.X, MoveVector.Y / Smoothness.Y))
                --
                mousemoverel(FinalVector.X, FinalVector.Y)
            end
        end
    end
    --
    function Eternity:GetTriggerBotTarget()
        local Targets = {}
        --
        local MouseLocation = UserInputService:GetMouseLocation()
        --
        local Hitboxes = Flags["LegitTriggerbot_Hitbox"]:Get()
        local Origin = Flags["LegitTriggerbot_WallCheckOrigin"]:Get()
        --
        local Checks = Flags["LegitTriggetbot_Checks"]:Get()
        --
        local TeamCheck = Find(Checks, "Team")
        local WallCheck = Find(Checks, "Wall")
        local VisibleCheck = Find(Checks, "Visible")
        local ForceFieldCheck = Find(Checks, "Forcefield")
        local AliveCheck = Find(Checks, "Alive")
        --
        for Index, Player in pairs(Eternity:GetPlayers()) do
            if Player ~= Client then
                if (TeamCheck and not Eternity:CheckTeam(Client, Player)) then continue end
                --
                local Object, Humanoid, RootPart = Eternity:ValidateClient(Player)
                --
                if (Object and Humanoid and RootPart) then
                    if (ForceFieldCheck and Object:FindFirstChildOfClass("ForceField")) then continue end
                    if (AliveCheck and not Eternity:ClientAlive(Player, Character, Humanoid)) then continue end
                    --
                    for Index2, Part in pairs(Eternity:GetBodyParts(Object, RootPart, false, Hitboxes)) do
                        if (VisibleCheck and not (Part.Transparency ~= 1)) then continue end
                        if (WallCheck and not Eternity:RayCast(Part, Eternity:GetOrigin(Origin), {Eternity:GetCharacter(LocalPlayer), Eternity:GetIgnore(true)})) then continue end
                        --
                        Targets[#Targets + 1] = Part
                    end
                end
            end
        end
        --
        local PointRay = Workspace.CurrentCamera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y, 0)
        local Hit, Position, Normal, Material = Workspace:FindPartOnRayWithWhitelist(Ray.new(PointRay.Origin, PointRay.Direction * 1000), Targets, false, false)
        --
        if Hit then
            Eternity.Locals.TriggerTarget = {
                Part = Hit,
                Position = Position,
                Material = Material
            }
        else
            Eternity.Locals.TriggerTarget = nil
        end
    end
    --
    function Eternity:TriggerBot()
        if Eternity.Locals.TriggerTarget then
            local Tick = tick()
            --
            local TriggerDelay = tonumber(Flags["LegitTriggerbot_Delay"]:Get())
            local Interval = tonumber(Flags["LegitTriggerbot_Interval"]:Get())
            --
            if ((Tick - Eternity.Locals.TriggerTick) >= (Interval / 1000)) then
                Eternity.Locals.TriggerTick = Tick
                --
                if TriggerDelay ~= 0 then
                    Delay(TriggerDelay / 1000, function()
                        mouse1press()
                        task.wait(0.05)
                        mouse1release()
                    end)
                else
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end
            end
        end
    end
    --
    function Eternity:Unload()
        for Index, Value in pairs(Eternity.Connections) do
            Value:Disconnect()
        end
        --
        DestroyRenderObject(Visuals.AimAssistCircle)
        DestroyRenderObject(Visuals.AimAssistOutline)
        --
        DestroyRenderObject(Visuals.DeadzoneCircle)
        DestroyRenderObject(Visuals.DeadzoneOutline)
        --
        Clear(Eternity)
    end
end

do -- Visuals
    function Visuals:Create(Properties)
        if Properties then
            if Properties.Player then
                local Self = setmetatable({
                    Player = Properties.Player,
                    Info = {
                        Tick = tick()
                    },
                    Renders = {
                        Weapon = CreateRenderObject("Text"),
                        Distance = CreateRenderObject("Text"),
                        HealthBarOutline = CreateRenderObject("Square"),
                        HealthBarInline = CreateRenderObject("Square"),
                        HealthBarValue = CreateRenderObject("Text"),
                        BoxFill = CreateRenderObject("Square"),
                        BoxOutline = CreateRenderObject("Square"),
                        BoxInline = CreateRenderObject("Square"),
                        Name = CreateRenderObject("Text")
                    }
                }, {
                    __index = Visuals.Base
                })
                --
                do -- Renders.Name
                    SetRenderProperty(Self.Renders.Name, "Text", Self.Player.Name)
                    SetRenderProperty(Self.Renders.Name, "Size", 13)
                    SetRenderProperty(Self.Renders.Name, "Center", true)
                    SetRenderProperty(Self.Renders.Name, "Outline", true)
                    SetRenderProperty(Self.Renders.Name, "Font", 2)
                    SetRenderProperty(Self.Renders.Name, "Visible", false)
                end
                --
                do -- Renders.Box
                    -- Inline
                    SetRenderProperty(Self.Renders.BoxInline, "Thickness", 1.25)
                    SetRenderProperty(Self.Renders.BoxInline, "Filled", false)
                    SetRenderProperty(Self.Renders.BoxInline, "Visible", false)
                    -- Outline
                    SetRenderProperty(Self.Renders.BoxOutline, "Thickness", 2.5)
                    SetRenderProperty(Self.Renders.BoxOutline, "Filled", false)
                    SetRenderProperty(Self.Renders.BoxOutline, "Visible", false)
                    -- Fill
                    SetRenderProperty(Self.Renders.BoxFill, "Filled", true)
                    SetRenderProperty(Self.Renders.BoxFill, "Visible", false)
                end
                --
                do -- Renders.HealthBar
                    -- Inline
                    SetRenderProperty(Self.Renders.HealthBarInline, "Filled", true)
                    SetRenderProperty(Self.Renders.HealthBarInline, "Visible", false)
                    -- Outline
                    SetRenderProperty(Self.Renders.HealthBarOutline, "Filled", true)
                    SetRenderProperty(Self.Renders.HealthBarOutline, "Visible", false)
                    -- Value
                    SetRenderProperty(Self.Renders.HealthBarValue, "Size", 13)
                    SetRenderProperty(Self.Renders.HealthBarValue, "Center", false)
                    SetRenderProperty(Self.Renders.HealthBarValue, "Outline", true)
                    SetRenderProperty(Self.Renders.HealthBarValue, "Font", 2)
                    SetRenderProperty(Self.Renders.HealthBarValue, "Visible", false)
                end
                --
                do -- Renders.Distance
                    SetRenderProperty(Self.Renders.Distance, "Size", 13)
                    SetRenderProperty(Self.Renders.Distance, "Center", true)
                    SetRenderProperty(Self.Renders.Distance, "Outline", true)
                    SetRenderProperty(Self.Renders.Distance, "Font", 2)
                    SetRenderProperty(Self.Renders.Distance, "Visible", false)
                end
                --
                do -- Renders.Weapon
                    SetRenderProperty(Self.Renders.Weapon, "Size", 13)
                    SetRenderProperty(Self.Renders.Weapon, "Center", true)
                    SetRenderProperty(Self.Renders.Weapon, "Outline", true)
                    SetRenderProperty(Self.Renders.Weapon, "Font", 2)
                    SetRenderProperty(Self.Renders.Weapon, "Visible", false)
                end
                --
                Visuals.Bases[Properties.Player] = Self
                --
                return Self
            end
        end
    end
    --
    function Visuals:Update()
        local MouseLocation = UserInputService:GetMouseLocation()
        --
        if (Flags["VisualsFOV_AimAssist"]:Get() == true) and (Flags["LegitAimAssist_Enabled"]:Get() == true) then
            local AimAssistColor1, AimAssistTransparency1 = Flags["VisualsFOV_AimAssist_Color"]:Get().Color, Flags["VisualsFOV_AimAssist_Color"]:Get().Transparency or Color3.fromHex("#38afa3"), 0.65
            local AimAssistColor2, AimAssistTransparency2 = Flags["VisualsFOV_AimAssist_Outline_Color"]:Get().Color, Flags["VisualsFOV_AimAssist_Outline_Color"]:Get().Transparency or Color3.fromHex("#38c8c8"), 0.75
            local FieldOfView = Eternity.Locals.VisualAimAssistFOV / 2
            --
            SetRenderProperty(Visuals.AimAssistCircle, "Position", MouseLocation)
            SetRenderProperty(Visuals.AimAssistCircle, "Color", AimAssistColor1)
            SetRenderProperty(Visuals.AimAssistCircle, "Transparency", 1 - AimAssistTransparency1)
            SetRenderProperty(Visuals.AimAssistCircle, "Radius", FieldOfView)
            SetRenderProperty(Visuals.AimAssistCircle, "NumSides", 60)
            SetRenderProperty(Visuals.AimAssistCircle, "Visible", true)
            --
            SetRenderProperty(Visuals.AimAssistOutline, "Position", MouseLocation)
            SetRenderProperty(Visuals.AimAssistOutline, "Color", AimAssistColor2)
            SetRenderProperty(Visuals.AimAssistOutline, "Transparency", 1 - AimAssistTransparency2)
            SetRenderProperty(Visuals.AimAssistOutline, "Radius", FieldOfView)
            SetRenderProperty(Visuals.AimAssistOutline, "NumSides", 60)
            SetRenderProperty(Visuals.AimAssistOutline, "Visible", true)
        else
            SetRenderProperty(Visuals.AimAssistCircle, "Visible", false)
            SetRenderProperty(Visuals.AimAssistOutline, "Visible", false)
        end
        --
        if (Flags["VisualsFOV_Deadzone"]:Get() == true) and (Flags["LegitAimAssist_Enabled"]:Get() == true) and (Flags["LegitAimAssist_Deadzone"]:Get() == true) then
            local DeadzoneColor1, DeadzoneTransparency1 = Flags["VisualsFOV_Deadzone_Color"]:Get().Color, Flags["VisualsFOV_Deadzone_Color"]:Get().Transparency or Color3.fromHex("#050c0f"), 0.65  
            local DeadzoneColor2, DeadzoneTransparency2 = Flags["VisualsFOV_Deadzone_Outline_Color"]:Get().Color, Flags["VisualsFOV_Deadzone_Outline_Color"]:Get().Transparency or Color3.fromHex("#0a0f14"), 0.75
            local FieldOfView = Eternity.Locals.VisualDeadzoneFOV / 2
            --
            SetRenderProperty(Visuals.DeadzoneCircle, "Position", MouseLocation)
            SetRenderProperty(Visuals.DeadzoneCircle, "Color", DeadzoneColor1)
            SetRenderProperty(Visuals.DeadzoneCircle, "Transparency", 1 - DeadzoneTransparency1)
            SetRenderProperty(Visuals.DeadzoneCircle, "Radius", FieldOfView)
            SetRenderProperty(Visuals.DeadzoneCircle, "NumSides", 60)
            SetRenderProperty(Visuals.DeadzoneCircle, "Visible", true)
            --
            SetRenderProperty(Visuals.DeadzoneOutline, "Position", MouseLocation)
            SetRenderProperty(Visuals.DeadzoneOutline, "Color", DeadzoneColor2)
            SetRenderProperty(Visuals.DeadzoneOutline, "Transparency", 1 - DeadzoneTransparency2)
            SetRenderProperty(Visuals.DeadzoneOutline, "Radius", FieldOfView)
            SetRenderProperty(Visuals.DeadzoneOutline, "NumSides", 60)
            SetRenderProperty(Visuals.DeadzoneOutline, "Visible", true)
        else
            SetRenderProperty(Visuals.DeadzoneCircle, "Visible", false)
            SetRenderProperty(Visuals.DeadzoneOutline, "Visible", false)
        end
    end
end

do -- UI Init
    --
    local Window = Library:New({Name = ("Eternity - %s - (%s)"):format(Eternity.Account.Username, game.PlaceId), Style = 1, Size = Vector2.new(550, 610)}) do
        --
        local LegitPage = Window:Page({Name = "Legit"}) do 
            --
            local AimAssistSection = LegitPage:Section({Name = "Aim Assist", Side = "Left"}) do
                --
                AimAssistSection:Toggle({Name = "Enabled", Default = false, Pointer = "LegitAimAssist_Enabled"}):Keybind({Default = Enum.UserInputType.MouseButton1, Mode = "On Hold", KeybindName = "Aim Assist", Pointer = "LegitAimAssist_ReadjustmentKey"})
                --
                --AimAssistSection:Dropdown({Name = "Readjustment Key", Options = {"MB1", "MB2"}, Max = 1, Default = "MB1", Pointer = "LegitAimAssist_ReadjustmentKey"})
                --
                --AimAssistSection:Toggle({Name = "Aim Only With Weapon", Default = false, Pointer = "LegitAimAssist_AimIfWeapon"})
                --
                AimAssistSection:Slider({Name = "Field Of View", Default = 15, Minimum = 0, Maximum = 100, Prefix = "%", Decimals = 0.01, Pointer = "LegitAimAssist_FieldOfView"})
                --
                AimAssistSection:Dropdown({ Options = {"Static", "Dynamic"}, Max = 2, Default = "Static", Pointer = "LegitAimAssist_FOVType"})
                --
                AimAssistSection:Toggle({Name = "Deadzone", Default = false, Pointer = "LegitAimAssist_Deadzone"})
                --
                AimAssistSection:Slider({Name = "Deadzone Field Of View", Default = 10, Minimum = 0, Maximum = 50, Prefix = "%", Decimals = 0.01, Pointer = "LegitAimAssist_DeadzoneAmmount"})
                --
                AimAssistSection:Multibox({Name = "Aim Assist Checks", Options = {"Wall", "Visible", "Alive", "Forcefield"}, Default = {"Wall", "Visible", "Alive", "Forcefield"}, Minimum = 1, Pointer = "LegitAimAssist_Checks"})
                --
                AimAssistSection:Slider({Name = "Horizontal Smoothing", Default = 13, Minimum = 0, Maximum = 100, Prefix = "%", Decimals = 0.01, Pointer = "LegitAimAssist_HorizontalSmoothing"})
                --
                AimAssistSection:Slider({Name = "Vertical Smoothing", Default = 13, Minimum = 0, Maximum = 100, Prefix = "%", Decimals = 0.01, Pointer = "LegitAimAssist_VerticalSmoothing"})
                --
                AimAssistSection:Multibox({Name = "Hit Boxes", Options = {"Head", "Torso", "Arms", "Legs"}, Default = {"Head"}, Minimum = 1, Pointer = "LegitAimAssist_Hitbox"})
                --
                AimAssistSection:Slider({Name = "Stutter", Default = 0, Minimum = 0, Maximum = 50, Prefix = "ms", Decimals = 0.01, Pointer = "LegitAimAssist_Stutter"})
            end
            --
            local TriggerBotSection = LegitPage:Section({Name = "Trigger Bot", Side = "Right"}) do
                --
                TriggerBotSection:Toggle({Name = "Enabled", Default = false, Pointer = "LegitTriggerbot_Enabled"}):Keybind({Default = Enum.KeyCode.N, Mode = "Toggle", KeybindName = "Trigger Bot", Pointer = "LegitTriggerbot_ReadjustmentKey"})
                --
                TriggerBotSection:Multibox({Name = "Hit Boxes", Options = {"Head", "Torso", "Arms", "Legs"}, Default = {"Head"}, Minimum = 1, Pointer = "LegitTriggerbot_Hitbox"})
                --
                TriggerBotSection:Multibox({Name = "Trigger Bot Checks", Options = {"Wall", "Visible", "Alive", "Forcefield"}, Default = {"Wall", "Visible", "Alive", "Forcefield"}, Minimum = 1, Pointer = "LegitTriggetbot_Checks"})
                --
                TriggerBotSection:Dropdown({Name = "Wall Check Origin", Options = {"Camera", "Head", "Torso"}, Max = 2, Default = "Camera", Pointer = "LegitTriggerbot_WallCheckOrigin"})
                --
                TriggerBotSection:Slider({Name = "Delay", Default = 10, Minimum = 0, Maximum = 1000, Prefix = "ms", Decimals = 0.01, Pointer = "LegitTriggerbot_Delay"})
                --
                TriggerBotSection:Slider({Name = "Interval", Default = 10, Minimum = 0, Maximum = 1000, Prefix = "%", Decimals = 0.01, Pointer = "LegitTriggerbot_Interval"})
                --
            end
        end
        --
        local RagePage = Window:Page({Name = "Rage"}) do 
            --
            local RageSection = RagePage:Section({Name = "Main", Side = "Left"}) do
                --
                RageSection:Toggle({Name = "Enabled", Default = false, Pointer = "bitch2"})
                --
            end
            --
        end
        --
        local EspPage = Window:Page({Name = "ESP"}) do 
            --
            local EspSection = EspPage:Section({Name = "Player ESP", Side = "Left"}) do
                --
                EspSection:Toggle({Name = "Enabled", Default = false, Pointer = "PlayerESP_Enabled"})
                --
                EspSection:Toggle({Name = "Name", Default = false, Pointer = "PlayerESP_Name", callback = function(State) Window.VisualPreview.Components.Title["Text"].Visible = State end})
                --
                EspSection:Toggle({Name = "Bounding Box", Default = false, Pointer = "PlayerESP_Box", callback = function(State) Window.VisualPreview.Components.Box["Box"].Visible = State end})
                --
                EspSection:Toggle({Name = "Bounding Box Fill", Default = false, Pointer = "PlayerESP_BoxFill", callback = function(State) Window.VisualPreview.Components.Box["Fill"].Visible = State end})
                --
                EspSection:Toggle({Name = "Health Bar", Default = false, Pointer = "PlayerESP_HealthBar", callback = function(State) Window.VisualPreview.Components.HealthBar["Box"].Visible = State end})
                --
                EspSection:Toggle({Name = "Health Number", Default = false, Pointer = "PlayerESP_HealthNumber", callback = function(State) Window.VisualPreview.Components.HealthBar["Value"].Visible = State end})
                --
                EspSection:Toggle({Name = "Weapon", Default = false, Pointer = "PlayerESP_Weapon", callback = function(State) Window.VisualPreview.Components.Tool["Text"].Visible = State end})
                --
                EspSection:Toggle({Name = "Distance", Default = false, Pointer = "PlayerESP_Distance", callback = function(State) Window.VisualPreview.Components.Distance["Text"].Visible = State end})
                --
                EspSection:Toggle({Name = "Flags", Default = false, Pointer = "PlayerESP_Flag", callback = function(State) Window.VisualPreview.Components.Flags["Text"].Visible = State end})
                --
            end
            --
        end
        --
        local VisualsPage = Window:Page({Name = "Visuals"}) do 
            --
            local RendersSection = VisualsPage:Section({Name = "Renders", Side = "Right"}) do
                --
                Temp = RendersSection:Toggle({Name = "Aim Assist", Default = true, Pointer = "VisualsFOV_AimAssist"})
                Temp:Colorpicker({Info = "Aim Assist FOV Outline", Default = Color3.fromRGB(56, 200, 200), Alpha = 0.75, Pointer = "VisualsFOV_AimAssist_Outline_Color"})
                Temp:Colorpicker({Info = "Aim Assist FOV", Default = Color3.fromRGB(55, 175, 165), Alpha = 0.65, Pointer = "VisualsFOV_AimAssist_Color"})
                --
                Temp = RendersSection:Toggle({Name = "Aim Assist Deadzone", Default = true, Pointer = "VisualsFOV_Deadzone"})
                Temp:Colorpicker({Info = "Aim Assist FOV Outline", Default = Color3.fromRGB(10, 15, 20), Alpha = 0.75, Pointer = "VisualsFOV_Deadzone_Outline_Color"})
                Temp:Colorpicker({Info = "Aim Assist FOV", Default = Color3.fromRGB(5, 12, 15), Alpha = 0.65, Pointer = "VisualsFOV_Deadzone_Color"})
                --
            end
            --
        end
        --
        local PlayersPage = Window:Page({Name = "Players"}) do
            local PlayerList = PlayersPage:PlayerList({}) 

            local SelectedSection = PlayersPage:Section({Name = "Selected Player", Side = "Left"}) do
                --
                SelectedSection:Button({Name = "Spectate / View", Pointer = "PlayerListSelectedPlayerView", Callback = function() 
                    if PlayerList:GetSelection()[1] ~= nil then
                        Workspace.Camera.CameraSubject = Players[tostring(PlayerList:GetSelection()[1])].Character:FindFirstChildOfClass("Humanoid")
                    end
                end})
                --
                SelectedSection:Button({Name = "Unspectate / Unview", Pointer = "PlayerListSelectedPlayerUnview", Callback = function()
                    Workspace.Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                end})
                --
                SelectedSection:Button({Name = "Teleport Hit", Pointer = "TpHIT"})
            end
        end
        --
        local SettingsPage = Window:Page({Name = "Settings"}) do
            local ConfigSection = SettingsPage:Section({Name = "Configuration", side = "Left"}) do
                ConfigSection:Toggle({Name = "Custom Menu Name", Flag = "ConfigMenu_CustomName", Default = false, Callback = function(State)
                    if State and Flags.ConfigMenu_Name and Flags["ConfigMenu_Name"]:Get() then
                        Window:SetName(("%s - %s - (%s)"):format(Flags["ConfigMenu_Name"]:Get(), Eternity.Account.Username, game.PlaceId)) 
                    else
                        Window:SetName(("%s - %s - (%s)"):format("Eternity", Eternity.Account.Username, game.PlaceId))
                    end
                end})
                ConfigSection:TextBox({Flag = "ConfigMenu_Name", Default = "Eternity", Max = 50, PlaceHolder = "Menu Name", Callback = function(State)
                    if Flags["ConfigMenu_CustomName"]:Get() then
                        Window:SetName(("%s - %s - (%s)"):format(State, Eternity.Account.Username, game.PlaceId))
                    end
                end})
            end
            --
            local MenuSection = SettingsPage:Section({Name = "Menu", Side = "Left"}) do
                --
                MenuSection:Keybind({Pointer = "Menu_Key", Name = "UI Key", Mode = "Toggle", Default = Enum.KeyCode.Home, Callback = function(State) Window.uibind = State end})
                --
                MenuSection:Toggle({Pointer = "Menu_Watermark", Name = "Watermark", Callback = function(State) Window.watermark:Update("Visible", State) end})
                --
                MenuSection:Toggle({Pointer = "Menu_KeybindList", Name = "Keybind List", Callback = function(State) Window.keybindslist:Update("Visible", State) end})
                --
                MenuSection:Button({Name = "Unload", Callback = function() Window:Unload() Eternity:Unload() end})
                --
            end
            --
            local ThemeSection = SettingsPage:Section({Name = "Theme", Side = "Right"}) do
                --ThemeSection:Dropdown({Name = "Theme", Flag = "ConfigTheme_Theme", Default = "Default", Max = 8, Options = Utility:GetTableIndexes(Themes, true)})
                --ThemeSection:Button({Name = "Load", Callback = function() Library:LoadTheme(Flags.ConfigTheme_Theme:Get()) end})
                ThemeSection:Colorpicker({Name = "Accent", Flag = "ConfigTheme_Accent", Default = Color3.fromRGB(93, 62, 152), Callback = function(Color) Library:UpdateColor("Accent", Color) end})
                ThemeSection:Colorpicker({Name = "Light Contrast", Flag = "ConfigTheme_LightContrast", Default = Color3.fromRGB(30, 30, 30), Callback = function(Color) Library:UpdateColor("LightContrast", Color) end})
                ThemeSection:Colorpicker({Name = "Dark Contrast", Flag = "ConfigTheme_DarkContrast", Default = Color3.fromRGB(20, 20, 20), Callback = function(Color) Library:UpdateColor("DarkContrast", Color) end})
                ThemeSection:Colorpicker({Name = "Outline", Flag = "ConfigTheme_Outline", Default = Color3.fromRGB(0, 0, 0), Callback = function(Color) Library:UpdateColor("Outline", Color) end})
                ThemeSection:Colorpicker({Name = "Inline", Flag = "ConfigTheme_Inline", Default = Color3.fromRGB(50, 50, 50), Callback = function(Color) Library:UpdateColor("Inline", Color) end})
                ThemeSection:Colorpicker({Name = "Light Text", Flag = "ConfigTheme_LightText", Default = Color3.fromRGB(255, 255, 255), Callback = function(Color) Library:UpdateColor("TextColor", Color) end})
                ThemeSection:Colorpicker({Name = "Dark Text", Flag = "ConfigTheme_DarkText", Default = Color3.fromRGB(175, 175, 175), Callback = function(Color) Library:UpdateColor("TextDark", Color) end})
                ThemeSection:Colorpicker({Name = "Text Outline", Flag = "ConfigTheme_TextBorder", Default = Color3.fromRGB(0, 0, 0), Callback = function(Color) Library:UpdateColor("TextBorder", Color) end})
                ThemeSection:Colorpicker({Name = "Cursor Outline", Flag = "ConfigTheme_CursorOutline", Default = Color3.fromRGB(10, 10, 10), Callback = function(Color) Library:UpdateColor("CursorOutline", Color) end})
                --ThemeSection:Dropdown({Name = "Accent Effect", Flag = "ConfigTheme_AccentEffect", Default = "None", Options = {"None", "Rainbow", "Shift", "Reverse Shift"}, Callback = function(State) if State == "None" then Library:UpdateColor("Accent", Flags["ConfigTheme_Accent"]:Get()) end end})
                --ThemeSection:Slider({Name = "Effect Length", Flag = "ConfigTheme_EffectLength", Default = 40, Maximum = 360, Minimum = 1, Decimals = 1})
            end
            --
            local ServerSection = SettingsPage:Section({Name = "Server", Side = "Right"}) do
                --
                ServerSection:Button({Name = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end})
                --
                ServerSection:Button({Name = "Copy JobId", Callback = function() setclipboard(game.JobId) end})
                --
                ServerSection:Button({Name = "Copy PlaceId", Callback = function() setclipboard(game.PlaceId) end})
                --
                ServerSection:Button({Name = "Copy Join Script", Callback = function() setclipboard(([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s")]]):format(game.PlaceId, game.JobId)) end})
                --
            end
            --
        end
        --
    end
    --
    Temp = nil
    --
    Window.wminfo = ("[%s]  -  [Account = $ACC [$UID],  Build = $BUILD,  Ping = $PING,  FPS = $FPS]"):format("Eternity"):gsub("$BUILD", "Developer"):gsub("$ACC", Eternity.Account.Username):gsub("$UID", Eternity.Account.UserID)
    --
    Window.uibind = Enum.KeyCode.Home
    Window:Initialize()
    --
    Eternity.Locals.Window = Window
end

Eternity.Connections.Main = RunService.RenderStepped:Connect(function()
    --
    local AimAssist = (Flags["LegitAimAssist_Enabled"]:Get() == true)
    --
    if (AimAssist and Flags["LegitAimAssist_ReadjustmentKey"]:Active() and not Eternity.Locals.Window.isVisible) then
        Eternity:GetAimAssistTarget()
        Eternity:AimAssist()
    else
        Eternity.Locals.PossibleTarget = nil
        Eternity.Locals.Target = nil
    end
    --
    if AimAssist then
        Eternity:UpdateFieldOfView()
    end
    --
    if (Flags["LegitTriggerbot_Enabled"]:Get() and Flags["LegitTriggerbot_ReadjustmentKey"]:Active() and not Eternity.Locals.Window.isVisible) then
        Eternity:GetTriggerBotTarget()
        Eternity:TriggerBot()
    else
        Eternity.Locals.TriggerTarget = nil
    end
    --
    Visuals:Update()
    --
end)
Eternity.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(Player)
    Eternity:PlayerAdded(Player)
end)
for Index, Player in pairs(Eternity:GetPlayers()) do
    Eternity:PlayerAdded(Player)
end
