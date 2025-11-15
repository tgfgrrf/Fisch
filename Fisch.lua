_G.Settings = {
    Farm = {
        Position = {},
        Mode = "Save Position",-- "Save Position","Freez"
        Enable = true,

        Cast = {
            Mode = "Perfect", -- Perfect,Random
            Enable = true
        },

        Shake = {
            Delay = 0.1,
            Enable = true
        },

        Reel = {
            Mode = "Fast[Risk]",-- Center, Large ,Safe 80,Fast[Risk]
            ReelBarprogress = 0.50,
            Enable = true
        },

        Rod = {
            FarmRod = "",
            ScyllaRod = "",
            MossjawRod = ""
        },
    },

    Boss = {
        SelectBoss = {},
        Mode = "With Farm",--with Farm ,Re Day
        Enable = false
    }
}

function ClickMiddle()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X/2,workspace.CurrentCamera.ViewportSize.Y/2,0,true,a,1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(workspace.CurrentCamera.ViewportSize.X/2,workspace.CurrentCamera.ViewportSize.Y/2,0,false,a,1)    
end 

function ClickCamera()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton1(Vector2.new(851, 158), game:GetService("Workspace").Camera.CFrame)
end
function Click()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
end

repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer
local plr = game.Players.LocalPlayer
repeat wait() until plr.Character
repeat wait() until plr.Character:FindFirstChild("HumanoidRootPart")
repeat wait() until plr.Character:FindFirstChild("Humanoid")
repeat wait() ClickMiddle() until game:GetService("Players").LocalPlayer.PlayerGui.loading.Enabled == false 

getgenv().Load = function()
    print("Loaded!")
	if readfile and writefile and isfile and isfolder then
		if not isfolder("Hypexz V2") then
			makefolder("Hypexz V2")
		end
		if not isfolder("Hypexz V2/Fisch/") then
			makefolder("Hypexz V2/Fisch/")
		end
		if not isfile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json") then
			writefile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json", game:GetService("HttpService"):JSONEncode(_G.Settings))
		else
			local Decode = game:GetService("HttpService"):JSONDecode(readfile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json"))
			for i,v in pairs(Decode) do
				_G.Settings[i] = v
			end
		end
	else
		return warn("Status : Undetected Executor")
	end
end

getgenv().SaveSetting = function()
    print("Save!")
	if readfile and writefile and isfile and isfolder then
		if not isfile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json") then
			getgenv().Load()
		else
			local Decode = game:GetService("HttpService"):JSONDecode(readfile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json"))
			local Array = {}
			for i,v in pairs(_G.Settings) do
				Array[i] = v
			end
			writefile("Hypexz V2/Fisch/US_" .. game.Players.LocalPlayer.Name .. ".json", game:GetService("HttpService"):JSONEncode(Array))
		end
	else
		return warn("Status : Undetected Executor")
	end
end

getgenv().Load()

local savedPosition = nil
if _G.Settings.Farm.Position then
	local sp = _G.Settings.Farm.Position
	if sp.X and sp.Y and sp.Z and sp.Yaw then
		local pos = Vector3.new(sp.X, sp.Y, sp.Z)
		local yawRad = math.rad(sp.Yaw)
		savedPosition = CFrame.new(pos) * CFrame.Angles(0, yawRad, 0)
	end
end

game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)


spawn(function()
    while wait(1) do
        local args = {
            [1] = false
        }

        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("afk"):FireServer(unpack(args))
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local PlayerName = LocalPlayer.Name

local function TP(...)
     local RealtargetPos = {...}
	local targetPos = RealtargetPos[1]
	local RealTarget
	if type(targetPos) == "vector" then
		RealTarget = CFrame.new(targetPos)
	elseif type(targetPos) == "userdata" then
		RealTarget = targetPos
	elseif type(targetPos) == "number" then
		RealTarget = CFrame.new(unpack(RealtargetPos))
	end

    if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health == 0 then if tween then tween:Cancel() end repeat wait() until game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health > 0; wait(0.2) end

    game.Players.LocalPlayer.Character["HumanoidRootPart"].CFrame = RealTarget
end

local autocast_running = false
local originalCastAsync = {}
local autoreel_running = false


local function GetProgressBarScale()
    local ok, result = pcall(function()
        local gui = PlayerGui
        if not gui then return nil end
        local reel = gui:FindFirstChild("reel")
        if not reel then return nil end
        local bar = reel:FindFirstChild("bar")
        if not bar then return nil end
        local progress = bar:FindFirstChild("progress")
        if not progress then return nil end
        local inner = progress:FindFirstChild("bar")
        if not inner then return nil end
        if inner.Size and inner.Size.X and type(inner.Size.X.Scale) == "number" then
            return inner.Size.X.Scale
        end
        return nil
    end)
    if ok then
        return result
    else
        return nil
    end
end

local function Reel()
    local RodState = workspace:WaitForChild("PlayerStats")[PlayerName].T[PlayerName].Stats.rod.Value
    local Mode = _G.Settings.Farm.Reel.Mode
    local BareelProgress = _G.Settings.Farm.Reel.ReelBarprogress
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local reel = playerGui:FindFirstChild("reel")
        if reel then
            local bar = reel:FindFirstChild("bar")
            if bar then
                local fish = bar:FindFirstChild("fish")
                local playerbar = bar:FindFirstChild("playerbar")
                
                if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                    if _G.Settings.Farm.Reel.Enable then
                        if Mode == "Center" then
                            pcall(function()
                                playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                            end)
                        elseif Mode == "Large" or Mode == "Safe 80" or Mode == "Fast[Risk]" then
                            playerbar.Size = UDim2.fromScale(1,1)
                            if Mode == "Safe 80" then
                                local prog = GetProgressBarScale()
                                if prog and prog >= 0.80 then
                                    pcall(function()
                                        ReplicatedStorage.events.reelfinished:FireServer(100, true)
                                        game:GetService("Players").LocalPlayer.Character:FindFirstChild(RodState).events.reset:FireServer()
                                    end)
                                end
                            elseif Mode == "Fast[Risk]" then
                                local prog = GetProgressBarScale()
                                if prog and prog >= tonumber(BareelProgress) then
                                    pcall(function()
                                        ReplicatedStorage.events.reelfinished:FireServer(100, true)
                                        game:GetService("Players").LocalPlayer.Character:FindFirstChild(RodState).events.reset:FireServer()
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local Ready = false

local function GetSelfDistance(Position)
    local RootPart = HumanoidRootPart
    return (RootPart.Position - Position).Magnitude
end
local function handleBossTarget(name, targetCFrame, distanceThreshold, platformStand)
    local distance = GetSelfDistance(targetCFrame.Position)
    if distance > distanceThreshold then
        game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
    end

    TP(targetCFrame)

    if platformStand then
        -- game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
    end

    if distance < distanceThreshold then
        Ready = true
    end
end

local function CheckBoss()
    local Zone = workspace.zones
    local fish = Zone:FindFirstChild("Fishing")
    local SelectedTable = _G.Settings.Boss.SelectBoss
    if type(SelectedTable) ~= "table" then return nil end

    local bossEventNames = {}
    for name in pairs(SelectedTable) do
        bossEventNames[name] = true
    end

    for _, obj in ipairs(workspace.zones.fishing:GetChildren()) do
        if obj:IsA("Part") then
            if bossEventNames[obj.Name] then
                return obj.Name --, "zone"
            end
        end
    end

    return nil 
end


local function CheckBoss2()
    local bossList = _G.Settings.Boss.SelectBoss
    local players = game:GetService("Players")

    if type(bossList) ~= "table" then return nil end

    -- Convert bossList keys to a lookup set for faster access
    local bossNames = {}
    for name in pairs(bossList) do
        bossNames[name] = true
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and not players:GetPlayerFromCharacter(obj) then
            if bossNames[obj.Name] then
                return obj.Name
            end
        end
    end

    return nil
    
end


task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            --[World 1]
            if _G.Settings.Farm.Enable
            then
                if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1") then
                        if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
                            game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
                        end
                        local BodyVelocity = Instance.new("BodyVelocity")
                        BodyVelocity.Name = "BodyVelocity1"
                        BodyVelocity.Parent =  game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                        BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "bobber" and v.Name ~= "handle" then
                        v.CanCollide = false    
                    end
                end
            else
                if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1"):Destroy();
                end
            end
        end)
    end)
end)


if not workspace:FindFirstChild("Platform") then
    local part = Instance.new("MeshPart")
    part.Name = "Platform" -- Changed to a more appropriate name
    part.Parent = game.Workspace
    part.Anchored = true
    part.Transparency = 0
    part.Size = Vector3.new(10, 0.5, 10)
end


-- spawn(function()
--     while task.wait() do 
--         pcall(function()
--             workspace:FindFirstChild("Platform").CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.X,game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Y -3.15,game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Z)
--         end)
--     end
-- end)



local function rememberPosition()
    spawn(function()
        local initialCFrame = HumanoidRootPart.CFrame
 
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = HumanoidRootPart
 
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.D = 100
        bodyGyro.P = 10000
        bodyGyro.CFrame = initialCFrame
        bodyGyro.Parent = HumanoidRootPart
 
        while AutoFreeze do
            HumanoidRootPart.CFrame = initialCFrame
            task.wait(0.01)
        end
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
        if bodyGyro then
            bodyGyro:Destroy()
        end
    end)
end

-- local function ChangRod(index)
--     local BackPack = LocalPlayer.Backpack:FindFirstChild(index)
--     local Chapack = Character:FindFirstChild(index)
--     if not BackPack and not Chapack then
--         local args = {
--             [1] = index
--         }

--         game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RF/Rod/Equip"):InvokeServer(index)
--     end
-- end



local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


local Window = Fluent:CreateWindow({
    Title = "Hypexz V2 " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 120,
    Size = UDim2.fromOffset(650, 530),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Hypexz provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Teleport = Window:AddTab{Title = "Teleport",Icon = "map"},
    Misc = Window:AddTab({Title = "Misc",Icon ="shop"}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}



local FarmSection = Tabs.Main:AddSection("Status")


local Status = Tabs.Main:AddParagraph({
    Title = "Status : N/A"
})



local FarmSection = Tabs.Main:AddSection("Main")



Tabs.Main:AddButton({
    Title = "Set Position Farm",
    Callback = function()
        Window:Dialog({
            Title = "Save Notify",
            Content = "Confirm For Save Position",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        if HumanoidRootPart then
                            savedPosition = HumanoidRootPart.CFrame
                            local pos = savedPosition.Position
                            local _, yRot, _ = savedPosition:ToEulerAnglesXYZ()
                            _G.Settings.Farm.Position = {
                                X = pos.X,
                                Y = pos.Y,
                                Z = pos.Z,
                                Yaw = math.deg(yRot)
                            }
                            getgenv().SaveSetting()
                            print("Save At : ",savedPosition)
                        end
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancle Succ")
                    end
                }
            }
        })
    end
})

local StartFarmTogle = Tabs.Main:AddToggle("StartFarmTogle", {Title = "Enable Farm", Default = _G.Settings.Farm.Enable })
StartFarmTogle:OnChanged(function(value)
    _G.Settings.Farm.Enable = value
    getgenv().SaveSetting()
end)

local BossFarmTogle = Tabs.Main:AddToggle("BossFarmTogle", {Title = "Enable Boss Farm", Default = _G.Settings.Boss.Enable })
BossFarmTogle:OnChanged(function(value)
   _G.Settings.Boss.Enable = value
    getgenv().SaveSetting()
end)


local function ChangRod(rodName)

    game:GetService("ReplicatedStorage").packages.Net["RF/Rod/Equip"]:InvokeServer(rodName)

    print("ChangRod ",rodName)
end

local function CheckInventory(itemName)
    local character = LocalPlayer.Character
    local backpack = LocalPLayer:FindFirstChild("Backpack")
    if not character and not backpack then return false end
    return true
end

local function ensureRod(rodName)
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    if not Backpack:FindFirstChild(rodName) and not Character:FindFirstChild(rodName) then
        print("Ensure : ",rodName)
        ChangRod(rodName)
    end
end

spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    local Humanoid = Character:WaitForChild("Humanoid")


    local WorldFolder = ReplicatedStorage:WaitForChild("world")
    local WeatherValue = WorldFolder:WaitForChild("weather").Value
    local CycleValue = WorldFolder:WaitForChild("cycle").Value
    local ZonesFolder = Workspace:WaitForChild("zones"):WaitForChild("fishing")


    local BOSS_TARGETS = {
        ["Elder Mossjaw"] = { cframe = CFrame.new(-4861.78271, -1793.96008, -10126.1406, 0.999018729, 9.09287579e-08, -0.0442892015, -9.21281185e-08, 1, -2.50390126e-08, 0.0442892015, 2.90947231e-08, 0.999018729), threshold = 10 },
        ["MossjawHunt"] = { cframe = CFrame.new(-4861.78271, -1793.96008, -10126.1406, 0.999018729, 9.09287579e-08, -0.0442892015, -9.21281185e-08, 1, -2.50390126e-08, 0.0442892015, 2.90947231e-08, 0.999018729), threshold = 10 },
        ["Forsaken Veil - Scylla"] = { cframe = CFrame.new(-2508.34229, -11224.4805, 6893.28467, -0.0316809788, -3.53211824e-08, -0.99949801, 2.09912301e-08, 1, -3.60042769e-08, 0.99949801, -2.21213448e-08, -0.0316809788), threshold = 10 },
        ["Megalodon Default"] = { offset = Vector3.new(0, 20, 0), zone = "Megalodon Default", threshold = 10, platformStand = true },
        ["Megalodon Ancient"] = { offset = Vector3.new(0, 20, 0), zone = "Megalodon Ancient", threshold = 10, platformStand = true },
        ["The Kraken Pool"] = { offset = Vector3.new(0, 70, 0), zone = "The Kraken Pool", threshold = 10, platformStand = true },
        ["Ancient Kraken Pool"] = { offset = Vector3.new(0, 70, 0), zone = "Ancient Kraken Pool", threshold = 10, platformStand = true },
        ["Orcas Pool"] = { offset = Vector3.new(0, 90, 0), zone = "Orcas Pool", threshold = 10, platformStand = true },
        ["Ancient Orcas Pool"] = { offset = Vector3.new(0, 90, 0), zone = "Ancient Orcas Pool", threshold = 10, platformStand = true },
        ["FischFright25"] = { offset = Vector3.new(0, 80, 0), zone = "FischFright25", threshold = 10, platformStand = true },
        ["Whales Pool"] = { offset = Vector3.new(0, 80, 0), zone = "Whales Pool", threshold = 10, platformStand = true },
        ["Colossal Blue Dragon"] = { offset = Vector3.new(0, -10, 0), zone = "Colossal Blue Dragon", threshold = 10, platformStand = true },
        ["Colossal Ethereal Dragon"] = { offset = Vector3.new(0, -10, 0), zone = "Colossal Ethereal Dragon", threshold = 10, platformStand = true },
        ["Colossal Ancient Dragon"] = { offset = Vector3.new(0, -10, 0), zone = "Colossal Ancient Dragon", threshold = 10, platformStand = true },
    }


    local function getBossTargetCFrame(info)
        if info.cframe then
            return info.cframe
        elseif info.zone then
            local zone = ZonesFolder:FindFirstChild(info.zone)
            if zone then
                return zone.CFrame * CFrame.new(info.offset or Vector3.zero)
            end
        end
        return nil
    end


    RunService.Heartbeat:Connect(function()
        if not _G.Settings.Farm.Enable then
            Ready = false
            return
        end

        xpcall(function()

            local ROD_SCYLLA = _G.Settings.Farm.Rod.ScyllaRod
            local ROD_MOSSJAW = _G.Settings.Farm.Rod.MossjawRod
            local ROD_MAIN = _G.Settings.Farm.Rod.FarmRod

            local Settings = _G.Settings
            local Farm = Settings.Farm
            local Boss = Settings.Boss
            local ModeFarm = Farm.Mode

            local Totem = Backpack:FindFirstChild("Sundial Totem")
            local EquippedTotem = Character:FindFirstChild("Sundial Totem")
            local BossSpawn = CheckBoss() or CheckBoss2()
            local BossInfo = BossSpawn and BOSS_TARGETS[BossSpawn]

            Ready = false
            
            if Boss.Enable then
                if BossSpawn and BossInfo then
                    if BossSpawn == "Forsaken Veil - Scylla" then
                        ensureRod(ROD_SCYLLA)
                    elseif BossSpawn == "Elder Mossjaw" or BossSpawn == "MossjawHunt" then
                        ensureRod(ROD_MOSSJAW)
                    else 
                        ensureRod(ROD_MAIN)
                    end

                    local targetCFrame = getBossTargetCFrame(BossInfo)
                    if targetCFrame then
                        Status:SetTitle("Status : Farm ", BossSpawn)
                        handleBossTarget(BossSpawn, targetCFrame, BossInfo.threshold, BossInfo.platformStand)
                        return
                    end
                end


                if Boss.Mode == "Re Day" then
                    Status:SetTitle("Status : Re Day Find Boss")
                    if not WeatherValue:match("Aurora") then
                        if EquippedTotem then
                            local currentCycle = CycleValue
                            if currentCycle == "Day" or currentCycle == "Night" then
                                task.wait(1)
                                ClickCamera()
                                repeat
                                    task.wait()
                                until not Settings.Farm.Enable
                                   or Boss.Mode ~= "Re Day"
                                   or CycleValue ~= currentCycle
                            end
                        else
                            Humanoid:EquipTool(Totem)
                        end
                    else
                        ensureRod(ROD_MAIN)
                        if ModeFarm == "Save Position" then
                            AutoFreeze = false
                            Status:SetTitle("Status : Position")
                            TP(savedPosition)
                        else
                            Status:SetTitle("Status : Non Position")
                            rememberPosition()
                            AutoFreeze = true
                        end
                        Ready = true
                    end
                else
                    ensureRod(ROD_MAIN)
                    if ModeFarm == "Save Position" then
                        AutoFreeze = false
                        Status:SetTitle("Status : Position")
                        TP(savedPosition)
                    else
                        Status:SetTitle("Status : Non Position")
                        rememberPosition()
                        AutoFreeze = true
                    end
                    Ready = true
                end
            else
                ensureRod(ROD_MAIN)
                if ModeFarm == "Save Position" then
                    AutoFreeze = false
                    Status:SetTitle("Status : Position")
                    TP(savedPosition)
                else
                    Status:SetTitle("Status : Non Position")
                    rememberPosition()
                    AutoFreeze = true
                end
                Ready = true
            end
        end, warn)
    end)
end)



spawn(function()
    while RunService.Heartbeat:Wait() do
        if not Ready then 
            continue 
        end
        
        local success, result = pcall(function()
            local playerStats = workspace.PlayerStats[PlayerName]
            local rodValue = playerStats.T[PlayerName].Stats.rod.Value
            local rodCharacter = Character:FindFirstChild(rodValue)
            local rodTool = LocalPlayer.Backpack:FindFirstChild(rodValue)
            local ShakeDelay = _G.Settings.Farm.Shake.Delay
            local CastMode = _G.Settings.Farm.Cast.Mode
            if not rodCharacter and rodTool then
                print("Equipping rod:", rodValue)
                Character.Humanoid:EquipTool(rodTool)
                rodCharacter = Character:WaitForChild(rodValue, 1)
            end
            if not rodCharacter then
                warn("Rod not found")
                return
            end
            local bobber = rodCharacter:FindFirstChild("bobber")
            local shakeUi = PlayerGui:FindFirstChild("shakeui")
            local reelUi = PlayerGui:FindFirstChild("reel")
            if not bobber then
                if not _G.Settings.Farm.Cast.Enable then return end
                local Resault
                if CastMode == "Perfect" then
                    Resault = 100
                elseif CastMode == "Random" then
                    Resault = math.random(70,100)
                else
                    Resault = 100
                end
                ReplicatedStorage.events.CancelEmote:FireServer()
                task.wait(0.5)
                if rodCharacter:FindFirstChild("events") then
                    rodCharacter.events.castAsync:InvokeServer(tonumber(Resault), 1)
                else
                    warn("castAsync event not found")
                end
            elseif shakeUi then
                if not _G.Settings.Farm.Shake.Enable then return end
                repeat RunService.Heartbeat:Wait()
                    local safezone = shakeUi:FindFirstChild("safezone")
                    local button = safezone and safezone:FindFirstChild("button")
                    if button then
                        GuiService.SelectedObject = button
                        if GuiService.SelectedObject == button then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                    reelUi = PlayerGui:WaitForChild("reel",tonumber(ShakeDelay))
                until reelUi or not Ready

            elseif reelUi and reelUi:FindFirstChild("bar") then
                if not _G.Settings.Farm.Reel.Enable then return end
                Reel()
            end
        end)
        
        if not success then
            warn("Error:", result)
        end
    end
end)


local FarmSection = Tabs.Main:AddSection("Setting Farm")

local Mfv = Tabs.Main:AddDropdown("Mfv", {
    Title = "Select Mode Farm",
    Values = {"Save Position","Freez"},
    Multi = false,
    Default = _G.Settings.Farm.Mode,
})

Mfv:OnChanged(function(Value)
    _G.Settings.Farm.Mode = Value
    getgenv().SaveSetting()
end)

local CMV = Tabs.Main:AddDropdown("CMV", {
    Title = "Select Mode Cast",
    Values = {"Perfect","Random"},
    Multi = false,
    Default = _G.Settings.Farm.Cast.Mode,
})

CMV:OnChanged(function(Value)
    _G.Settings.Farm.Cast.Mode = Value
    getgenv().SaveSetting()
end)

local SSDL = Tabs.Main:AddInput("SSDL", {
    Title = "Set Shake Delay",
    Default = _G.Settings.Farm.Shake["Delay"],
    Numeric = true, -- Only allows numbers
    Finished = true, -- Only calls callback when you press enter
    Callback = function(Value)
        _G.Settings.Farm.Shake["Delay"] = Value
        getgenv().SaveSetting()
    end
})

local SRBPDL = Tabs.Main:AddInput("SRBPDL", {
    Title = "Set Reel Barprogress[Fast Mode only]",
    Default = _G.Settings.Farm.Reel.ReelBarprogress,
    Numeric = true, -- Only allows numbers
    Finished = true, -- Only calls callback when you press enter
    Callback = function(Value)
        _G.Settings.Farm.Reel.ReelBarprogress = Value
        getgenv().SaveSetting()
    end
})



local RMV = Tabs.Main:AddDropdown("RMV", {
    Title = "Select Mode Reel",
    Values = {"Center","Large","Safe 80","Fast[Risk]"},
    Multi = false,
    Default = _G.Settings.Farm.Reel.Mode,
})

RMV:OnChanged(function(Value)
    _G.Settings.Farm.Reel.Mode = Value
    getgenv().SaveSetting()
end)

local FarmSection = Tabs.Main:AddSection("Boss")

bosslist = {
    "FischFright25",
    "Elder Mossjaw",
    "MossjawHunt",
    "Forsaken Veil - Scylla",
    "Megalodon Default",
    "Megalodon Ancient",
    "The Kraken Pool",
    "Ancient Kraken Pool",
    "Orcas Pool",
    "Whales Pool",
    "Ancient Orcas Pool",
    "Colossal Blue Dragon",
    "Colossal Ethereal Dragon",
    "Colossal Ancient Dragon"
}

local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
    Title = "Select Boss",
    Description = "Select Boss Farm",
    Values = bosslist,
    Multi = true,
    Default = _G.Settings.Boss.SelectBoss,
})


MultiDropdown:OnChanged(function(Value)
    _G.Settings.Boss.SelectBoss = Value
    getgenv().SaveSetting()
end)


local SelectModeFarmBoss = Tabs.Main:AddDropdown("SelectModeFarmBoss", {
    Title = "Select Mode Farm Boss",
    Description = "Select Mode Farm Boss",
    Values = {"With Farm","Re Day"},
    Multi = false,
    Default =  _G.Settings.Boss.Mode,
})


SelectModeFarmBoss:OnChanged(function(Value)
    _G.Settings.Boss.Mode = Value
    getgenv().SaveSetting()
end)


local FarmSection = Tabs.Main:AddSection("Enable Setting")

local EnableCastToggle = Tabs.Main:AddToggle("EnableCastToggle", {Title = "Enable Cast", Default = _G.Settings.Farm.Cast.Enable })

EnableCastToggle:OnChanged(function(value)
    _G.Settings.Farm.Cast.Enable = value
    getgenv().SaveSetting()
end)

local EnableShakeToggle = Tabs.Main:AddToggle("EnableShakeToggle", {Title = "Enable Shake", Default = _G.Settings.Farm.Shake.Enable })

EnableShakeToggle:OnChanged(function(value)
    _G.Settings.Farm.Shake.Enable = value
    getgenv().SaveSetting()
end)

local EnableReelToggle = Tabs.Main:AddToggle("EnableReelToggle", {Title = "Enable Reel", Default = _G.Settings.Farm.Reel.Enable })

EnableReelToggle:OnChanged(function(value)
    _G.Settings.Farm.Reel.Enable = value
    getgenv().SaveSetting()
end)

local FarmSection = Tabs.Main:AddSection("Rod Setting")


local PathRod = workspace.PlayerStats[PlayerName].T[PlayerName].Rods
local RodNames = {}
local RodNameSet = {}

for _, v in pairs(PathRod:GetChildren()) do
    if not RodNameSet[v.Name] then
        table.insert(RodNames, v.Name)
        RodNameSet[v.Name] = true
    end
end

table.sort(RodNames, function(a, b)
    return a:lower() < b:lower()
end)

local SelectRodm = Tabs.Main:AddDropdown("SelectRodm", {
    Title = "Select Main Rod",
    Values = RodNames,
    Multi = false,
    Default = _G.Settings.Farm.Rod.FarmRod,
})

SelectRodm:OnChanged(function(value)
    _G.Settings.Farm.Rod.FarmRod = value
    getgenv().SaveSetting()
end)

local SelectRodsc = Tabs.Main:AddDropdown("SelectRodsc", {
    Title = "Select Scylla Rod",
    Values = RodNames,
    Multi = false,
    Default = _G.Settings.Farm.Rod.ScyllaRod,
})

SelectRodsc:OnChanged(function(value)
    _G.Settings.Farm.Rod.ScyllaRod = value
    getgenv().SaveSetting()
end)

local SelectRodmj = Tabs.Main:AddDropdown("SelectRodmj", {
    Title = "Select MossJaw Rod",
    Values = RodNames,
    Multi = false,
    Default = _G.Settings.Farm.Rod.MossjawRod,
})

SelectRodmj:OnChanged(function(value)
    _G.Settings.Farm.Rod.MossjawRod = value
    getgenv().SaveSetting()
end)


local extraTPs = {
    {Name = "Carrot Garden", Position = Vector3.new(3744, -1116, -1108)},
    {Name = "Crystal Cove", Position = Vector3.new(1364, -612, 2472)},
    {Name = "Underground Music Venue", Position = Vector3.new(2043, -645, 2471)},
    {Name = "Castaway Cliffs", Position = Vector3.new (655, 179, -1793)},
	{Name = "Luminescent Cavern", Position = Vector3.new (-1016, -337, -4071)},
	{Name = "Crimson Cavern", Position = Vector3.new (-1013, -340, -4891)},
    {Name = "Oscar's Locker", Position = Vector3.new (266, -387, 3407)},
	{Name = "The Boom Ball", Position = Vector3.new (-1296, -900, -3479)},
    {Name = "Lost Jungle", Position = Vector3.new (-2690, 149, -2051)}
}

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end

for _, tp in ipairs(extraTPs) do
    table.insert(tpNames, tp.Name)
end

table.sort(tpNames,function(a,b) return a:lower() < b:lower() end)

local teleport_running = false
local function StartTeleport()
    if teleport_running then return end
    teleport_running = true
    
    local hrp = Character.HumanoidRootPart
    local spot = tpFolder:FindFirstChild(selectedIsland)

    if not spot then
        for _, tp in ipairs(extraTPs) do
            if tp.Name == selectedIsland then
                spot = {CFrame = CFrame.new(tp.Position)}
                break
            end
        end
    end

    if hrp and spot then
        pcall(function() hrp.CFrame = spot.CFrame + Vector3.new(0,5,0) end)
    end
    task.wait()

teleport_running = false

end

local SelectTplocla = Tabs.Teleport:AddDropdown("", {
    Title = "Select Location",
    Values = tpNames,
    Multi = false,
    Default = 1,
})


SelectTplocla:OnChanged(function(Value)
    selectedIsland = Value
end)

Tabs.Teleport:AddButton({
    Title = "Teleport",
    Description = "",
    Callback = function()
        StartTeleport()
    end
})



SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("Hypexzv2ScriptHub")
SaveManager:SetFolder("Hypexzv2ScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Hypexz v2",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()