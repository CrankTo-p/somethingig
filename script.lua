-- ========================================
-- CONFIGURATION
-- ========================================
getgenv().Config = {
    Invite = "informant.wtf",
    Version = "0.0",
}

getgenv().luaguardvars = {
    DiscordName = "zikiouh#0000",
}

-- ========================================
-- SERVICES
-- ========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ========================================
-- PLAYER REFERENCES
-- ========================================
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local gui = LocalPlayer:WaitForChild("PlayerGui")

-- ========================================
-- CHARACTER REFERENCES
-- ========================================
local player = LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- ========================================
-- WORKSPACE REFERENCES
-- ========================================
local ocean = workspace.Map.Ocean
local Projectiles = workspace:FindFirstChild("Projectiles")

-- ========================================
-- NETWORK REFERENCES
-- ========================================
local Network = game.ReplicatedStorage.Network.Running
local ValChange = game.ReplicatedStorage.Network.HamonCharge

-- ========================================
-- STATE VARIABLES
-- ========================================
local activeCooldowns = {}
local originalNames = {}
local findings = {}
local ESPTable = {}
local valuableHighlights = {}
local hitboxParts = {}
local standParts = {}

local standVisibilityRunning = false
local espActive = false
local valuableEspActive = false
local hitboxVisibilityActive = false
local standNoClipActive = false
local Noclipping = false
local Clip = true

-- ========================================
-- MOVEMENT VARIABLES
-- ========================================
local walkspeedCheat = false
local walkspeedRunning = false
local currentWalkspeed = 16

local jumppowerCheat = false
local jumppowerRunning = false
local currentJumppower = 50

local infiniteJumpEnabled = false
local infiniteJumpConnection = nil

-- ========================================
-- ESP SETTINGS
-- ========================================
local Settings = {
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    TracerThickness = 1,
    BoxThickness = 1,
    TracerOrigin = "Bottom",
    FollowMouse = false,
    Tracers = true
}

local TeamSettings = {
    Enabled = false,
    AllyColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0)
}

-- ========================================
-- CONNECTIONS STORAGE
-- ========================================
local connections = {
    players = {},
    projectiles = {},
    stands = {},
    fingers = {},
    character = nil,
    toolAdded = nil,
    tools = {},
    landmines = {},
    projectileAdded = nil,
    landmineAdded = nil,
    icicles = {},
    icicleAdded = nil,
    standsAdded = nil,
    standDescendantAdded = nil,
    espAdded = nil,
    espRemoved = nil,
    espUpdate = nil,
    hitboxAddedWorkspace = nil,
    hitboxAddedFX = nil,
    valuablesAdded = nil,
}

local standConnections = {}
-- ========================================
-- INVENTORY LOCATIONS
-- ========================================
local inventoryLocations = {
    player:FindFirstChild("Backpack"),
    player.Character
}

-- ========================================
-- UI LIBRARY INITIALIZATION
-- ========================================
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CrankTo-p/Informantsadasdsad/refs/heads/main/informant.wtf%20Lib%20Source.lua"))()
library:init()

local Window = library.NewWindow({
    title = "JJBAD Paid Script",
    size = UDim2.new(0, 525, 0, 650)
})

-- ========================================
-- TABS
-- ========================================
local tabs = {
    MainTab = Window:AddTab("Main"),
    ESPTab = Window:AddTab("Esp"),
    Settings = library:CreateSettingsTab(Window),
}

-- ========================================
-- SECTIONS
-- ========================================
local sections = {
    Combat = tabs.MainTab:AddSection("Combat", 1),
    Misc = tabs.MainTab:AddSection("Misc", 2),
    Visual = tabs.ESPTab:AddSection("Visual", 2),
    ESPSection = tabs.ESPTab:AddSection("ESP", 1),
}

-- ========================================
-- COMBAT SECTION
-- ========================================

sections.Combat:AddToggle({
    enabled = true,
    text = "Remove Projectile Touch",
    flag = "Toggle_ProjectileTouch",
    risky = false,
    callback = function(state)
        if state then
            local function handleInstance(instance)
                local function removeTouch(descendant)
                    if descendant:IsA("TouchTransmitter") then descendant:Destroy() end
                end
                for _, d in ipairs(instance:GetDescendants()) do removeTouch(d) end
                return instance.DescendantAdded:Connect(removeTouch)
            end

            if Projectiles then
                local function handleProjectile(projectile)
                    table.insert(connections.projectiles, handleInstance(projectile))
                end
                connections.projectileAdded = Projectiles.ChildAdded:Connect(handleProjectile)
                for _, proj in ipairs(Projectiles:GetChildren()) do handleProjectile(proj) end
            end

            local function monitorStands()
                local standsFolder = workspace:FindFirstChild("Stands")
                if standsFolder then
                    local function processStandChild(child)
                        if child:IsA("BasePart") then
                            table.insert(connections.stands, handleInstance(child))
                        end
                    end
                    
                    local function handleFinger(finger)
                        table.insert(connections.fingers, handleInstance(finger))
                    end
                    
                    for _, stand in ipairs(standsFolder:GetChildren()) do
                        for _, child in ipairs(stand:GetDescendants()) do
                            processStandChild(child)
                            if child.Name == "Finger" then handleFinger(child) end
                        end
                        stand.ChildAdded:Connect(function(child)
                            if child.Name == "Finger" then handleFinger(child) end
                        end)
                    end
                    
                    connections.standDescendantAdded = standsFolder.DescendantAdded:Connect(function(child)
                        processStandChild(child)
                    end)
                end
            end
            
            monitorStands()
            connections.standsAdded = workspace.ChildAdded:Connect(function(child)
                if child.Name == "Stands" then monitorStands() end
            end)

            local function genericHandler(pattern, storage)
                return function(child)
                    if string.find(child.Name:lower(), pattern) then
                        table.insert(storage, handleInstance(child))
                    end
                end
            end

            connections.landmineAdded = workspace.ChildAdded:Connect(genericHandler("landmine", connections.landmines))
            connections.icicleAdded = workspace.ChildAdded:Connect(genericHandler("icicle", connections.icicles))
            for _, child in ipairs(workspace:GetChildren()) do
                genericHandler("landmine", connections.landmines)(child)
                genericHandler("icicle", connections.icicles)(child)
            end
        else
            if connections.projectileAdded then connections.projectileAdded:Disconnect() end
            if connections.landmineAdded then connections.landmineAdded:Disconnect() end
            if connections.icicleAdded then connections.icicleAdded:Disconnect() end
            if connections.standsAdded then connections.standsAdded:Disconnect() end
            if connections.standDescendantAdded then connections.standDescendantAdded:Disconnect() end
            
            for _, tbl in ipairs({connections.projectiles, connections.landmines, connections.icicles, connections.stands, connections.fingers}) do
                for _, conn in ipairs(tbl) do conn:Disconnect() end
                tbl = {}
            end
        end
    end
})

sections.Combat:AddSeparator({
    text = "Movement Hacks"
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Walkspeed",
    flag = "Walkspeed_Toggle",
    callback = function(value)
        walkspeedCheat = value
        if value then
            walkspeedRunning = true
            spawn(function()
                while walkspeedRunning do
                    if humanoid and walkspeedCheat then
                        humanoid.WalkSpeed = currentWalkspeed
                    end
                    task.wait(0.1)
                end
            end)
        else
            walkspeedRunning = false
            humanoid.WalkSpeed = 16
        end
    end
})

sections.Combat:AddSlider({
    text = "Walkspeed", 
    flag = 'Walkspeed_Value', 
    value = 16,
    min = 16, 
    max = 200,
    callback = function(v)
        currentWalkspeed = v
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Jumppower",
    flag = "Jumppower_Toggle",
    callback = function(value)
        jumppowerCheat = value
        if value then
            jumppowerRunning = true
            spawn(function()
                while jumppowerRunning do
                    if humanoid and jumppowerCheat then
                        humanoid.JumpPower = currentJumppower
                    end
                    task.wait(0.1)
                end
            end)
        else
            jumppowerRunning = false
            humanoid.JumpPower = 50
        end
    end
})

sections.Combat:AddSlider({
    text = "JumpPower", 
    flag = 'Jumppower_Value', 
    value = 50,
    min = 50, 
    max = 200,
    callback = function(v)
        currentJumppower = v
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Infinite Jump",
    flag = "InfiniteJump_Toggle",
    callback = function(state)
        infiniteJumpEnabled = state
        if state then
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if player.Character and infiniteJumpEnabled then
                    local currentHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if currentHumanoid and currentHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                        currentHumanoid:ChangeState("Jumping")
                    end
                end
            end)
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Complete Character Control",
    flag = "AirControl_Toggle",
    callback = function(state)
        if state then
            local conn
            local moveVector = Vector3.new()
            local camera = workspace.CurrentCamera
            
            local function updateVelocity()
                if not player.Character then return end
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if root and humanoid then
                    local cf = camera.CFrame
                    local speed = walkspeedCheat and currentWalkspeed or 16
                    
                    local moveDir = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
                    local relative = cf:VectorToWorldSpace(moveDir)
                    local gravity = humanoid:GetState() == Enum.HumanoidStateType.Freefall and 0.8 or 1
                    
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
                        root.Velocity = Vector3.new(
                            relative.X * speed * 2,
                            root.Velocity.Y * gravity,
                            relative.Z * speed * 2
                        )
                    end
                end
            end

            conn = RunService.Heartbeat:Connect(updateVelocity)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keys = {
                        [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
                        [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
                        [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
                        [Enum.KeyCode.D] = Vector3.new(1, 0, 0)
                    }
                    
                    if keys[input.KeyCode] then
                        moveVector = humanoid.MoveDirection + keys[input.KeyCode]
                    end
                end
            end)

            player.CharacterAdded:Connect(function()
                task.wait(0.5)
                if player.Character then
                    local newRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local newHum = player.Character:FindFirstChildOfClass("Humanoid")
                    
                    if newRoot and newHum then
                        root = newRoot
                        humanoid = newHum
                    end
                end
            end)

            getgenv().AirControlConnection = conn
        else
            if getgenv().AirControlConnection then
                getgenv().AirControlConnection:Disconnect()
            end
        end
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Stand NoClip",
    flag = "StandNoClip_Toggle",
    callback = function(state)
        standNoClipActive = state
        if state then
            local function processPart(part)
                if part:IsA("BasePart") then
                    standParts[part] = standParts[part] or part.CanCollide
                    part.CanCollide = false
                end
            end

            local function handleStand(stand)
                for _, child in ipairs(stand:GetDescendants()) do
                    processPart(child)
                    if child:IsA("Accessory") then
                        for _, accessoryPart in ipairs(child:GetDescendants()) do
                            processPart(accessoryPart)
                        end
                    end
                end

                standConnections.descendantAdded = stand.DescendantAdded:Connect(function(child)
                    processPart(child)
                    if child:IsA("Accessory") then
                        standConnections[child] = child.DescendantAdded:Connect(processPart)
                    end
                end)

                standConnections.destroying = stand.Destroying:Connect(function()
                    for part in pairs(standParts) do
                        if part.Parent == nil then
                            standParts[part] = nil
                        end
                    end
                end)
            end

            local heartbeatConnection = RunService.Heartbeat:Connect(function()
                if not standNoClipActive then return end
                local standsFolder = workspace:FindFirstChild("Stands")
                local playerStand = standsFolder and standsFolder:FindFirstChild(player.Name)
                if playerStand then
                    for part in pairs(standParts) do
                        if part.Parent then
                            part.CanCollide = false
                        end
                    end
                    if not standConnections.descendantAdded then
                        handleStand(playerStand)
                    end
                end
            end)
        else
            for part, canCollide in pairs(standParts) do
                if part.Parent then
                    part.CanCollide = canCollide
                end
            end
            for _, connection in pairs(standConnections) do
                connection:Disconnect()
            end
            standParts = {}
            standConnections = {}
        end
    end
})
-- ========================================
-- MISC SECTION
-- ========================================

local StaminaLoop
local ToChange = character.Stamina

sections.Misc:AddToggle({
    enabled = true,
    text = 'Infinite Stamina',
    flag = 'InfiniteStamina',
    tooltip = 'Toggle infinite stamina',
    risky = true,
    callback = function(state)
        if state then
            StaminaLoop = RunService.Heartbeat:Connect(function()
                task.wait(0.1)
                ValChange:FireServer(ToChange, 1000000)
            end)
        else
            if StaminaLoop then
                StaminaLoop:Disconnect()
                StaminaLoop = nil
            end
        end
    end
})

local CombatConn = nil
local TimerConn = nil

sections.Misc:AddToggle({
    enabled = true,
    text = 'No Combat Tag',
    flag = 'NoCombatTag',
    tooltip = 'Removes combat tag instantly',
    risky = true,
    callback = function(state)
        if state then
            CombatConn = LocalPlayer.ChildAdded:Connect(function(child)
                if child.Name == 'CombatTag' then
                    local Timer = child:WaitForChild('Timer')
                    ValChange:FireServer(Timer, 0)
                    TimerConn = Timer.Changed:Connect(function(v)
                        if v ~= 0 then
                            ValChange:FireServer(Timer, 0)
                        end
                    end)
                end
            end)
            if LocalPlayer:FindFirstChild('CombatTag') then
                local Timer = LocalPlayer.CombatTag:WaitForChild('Timer')
                ValChange:FireServer(Timer, 0)
                TimerConn = Timer.Changed:Connect(function(v)
                    if v ~= 0 then
                        ValChange:FireServer(Timer, 0)
                    end
                end)
            end
        else
            if CombatConn then
                CombatConn:Disconnect()
                CombatConn = nil
            end
            if TimerConn then
                TimerConn:Disconnect()
                TimerConn = nil
            end
        end
    end
})

sections.Misc:AddToggle({
    enabled = true,
    text = "NoFall",
    flag = "Nofall_Toggle",
    tooltip = "Prevents fall damage by velocity manipulation",
    risky = false,
    callback = function(state)
        if state then
            task.spawn(function()
                if root:CanSetNetworkOwnership() then
                    root:SetNetworkOwner(player)
                end

                local running = true
                getgenv().NofallRunning = running

                while running and task.wait() do
                    if not library.flags.Nofall_Toggle then break end
                    if not root or not root.Parent then
                        character = player.CharacterAdded:Wait()
                        root = character:WaitForChild("HumanoidRootPart")
                    end

                    if root.AssemblyLinearVelocity.Y < -50 then
                        local vel = root.AssemblyLinearVelocity
                        root.Velocity = Vector3.new(vel.X, math.max(vel.Y, -64.9), vel.Z)
                    end
                end
                getgenv().NofallRunning = false
            end)
        else
            if getgenv().NofallRunning then
                getgenv().NofallRunning = false
            end
        end
    end
})
local DiscStandName = ""

sections.Misc:AddBox({
    enabled = true,
    focused = false,
    text = "Stand Name",
    input = "Chariot Requiem",
    flag = "Disc_Stand_Input",
    callback = function(v)
        DiscStandName = v
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Set Disc",
    flag = "Disc_Set",
    tooltip = "Set's a disc's stand and exp values",
    risky = false,
    confirm = false,
    callback = function()
        if DiscStandName == "" then
            library:SendNotification("Please enter a stand name!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local Disc = character:FindFirstChildOfClass('Tool')
        if Disc and Disc:FindFirstChild('DiscType') then
            ValChange:FireServer(Disc.StolenAttributes.StolenStand, DiscStandName)
            ValChange:FireServer(Disc.StolenAttributes.StolenStandExp, 10000000000)
            ValChange:FireServer(Disc.DiscType, 'Stand')
            ValChange:FireServer(Disc.CommandType, 'None')
            library:SendNotification("Disc set to: " .. DiscStandName, 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("No disc equipped!", 3, Color3.new(1, 0, 0))
        end
    end
})
local StolenStyleName
sections.Misc:AddBox({
    enabled = true,
    focused = false,
    text = "Style_Name",
    input = "Vampire",
    flag = "Disc_Style_Input",
    callback = function(v)
        StolenStyleName = v
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Set Disc Style",
    flag = "Disc_Set_Style",
    tooltip = "Set's a disc's style and exp values",
    risky = false,
    confirm = false,
    callback = function()
        if StolenStyleName == "" then
            library:SendNotification("Please enter a stand name!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local Disc = character:FindFirstChildOfClass('Tool')
        if Disc and Disc:FindFirstChild('DiscType') then
            ValChange:FireServer(Disc.StolenAttributes.StolenStyleBool, true)
            ValChange:FireServer(Disc.StolenAttributes.StolenStyleExp, 10000000000)
            ValChange:FireServer(Disc.DiscType, StolenStyleName)

            ValChange:FireServer(Disc.CommandType, 'None')
            library:SendNotification("Disc set to: " .. StolenStyleName, 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("No disc equipped!", 3, Color3.new(1, 0, 0))
        end
    end
})
sections.Misc:AddButton({
    enabled = true,
    text = "Set Yen",
    flag = "Yen_Set",
    tooltip = "Set's a Yen Tool In the Character to 15000",
    risky = false,
    confirm = false,
    callback = function()
        local Yen = character:FindFirstChildOfClass('Tool')
        if Yen and Yen:FindFirstChild('YenAmount') then
            ValChange:FireServer(Yen.YenAmount, 15000)
        else
            library:SendNotification("No Yen equipped!", 3, Color3.new(1, 0, 0))
        end
    end
})
sections.Misc:AddToggle({
    enabled = true,
    text = "Stand Visibility",
    flag = "ToggleSV",
    risky = false,
    callback = function(state)
        standVisibilityRunning = state
        if state then
            connections.standLoop = task.spawn(function()
                while standVisibilityRunning and task.wait(1) do
                    for _, Stand in pairs(workspace.Stands:GetChildren()) do
                        for _, Part in ipairs(Stand:GetDescendants()) do
                            if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" and not Stand:FindFirstChild("Deactivated") then
                                Part.Transparency = 0
                            end
                        end
                    end
                end
            end)
        else
            if connections.standLoop then
                task.cancel(connections.standLoop)
            end
        end
    end
})
local JoinConn
local streamerModeActive = false
local nameConnection = nil
local leaderboardConnection = nil
local originalClothes = {}
local originalColors = {}

sections.Misc:AddToggle({
    enabled = true,
    text = "Streamer Mode",
    flag = "StreamerMode_Toggle",
    tooltip = "Hides leaderboard and changes name display",
    risky = false,
    callback = function(state)
        streamerModeActive = state
        
        if state then
            local leaderboard = game:GetService("CoreGui"):FindFirstChild("PlayerList")
            if leaderboard then
                leaderboard.Enabled = false
                
                leaderboardConnection = leaderboard:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if streamerModeActive then
                        leaderboard.Enabled = false
                    end
                end)
            end
            
            local mainGui = gui:FindFirstChild("MAINNGUI")
            if mainGui and mainGui:FindFirstChild("Information") then
                local nameLabel = mainGui.Information:FindFirstChild("Name")
                if nameLabel then
                    nameLabel.Text = "Zikiouh"
                    
                    nameConnection = nameLabel:GetPropertyChangedSignal("Text"):Connect(function()
                        if streamerModeActive and nameLabel.Text ~= "Zikiouh" then
                            nameLabel.Text = "Zikiouh"
                        end
                    end)
                end
            end
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local char = plr.Character
                    originalClothes[plr] = {}
                    originalColors[plr] = {}
                    
                    for _, item in pairs(char:GetChildren()) do
                        if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                            table.insert(originalClothes[plr], item:Clone())
                            item:Destroy()
                        end
                    end
                    
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            originalColors[plr][part] = part.Color
                            part.Color = Color3.fromRGB(163, 162, 165)
                        end
                    end
                end
            end
            
            connections.streamerCharAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    if streamerModeActive and plr ~= player then
                        task.wait(0.5)
                        for _, item in pairs(char:GetChildren()) do
                            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                                item:Destroy()
                            end
                        end
                        
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.Color = Color3.fromRGB(163, 162, 165)
                            end
                        end
                    end
                end)
            end)
            
            library:SendNotification("Streamer Mode enabled!", 3, Color3.new(0, 1, 0))
        else
            local leaderboard = game:GetService("CoreGui"):FindFirstChild("PlayerList")
            if leaderboard then
                leaderboard.Enabled = true
            end
            
            if leaderboardConnection then
                leaderboardConnection:Disconnect()
                leaderboardConnection = nil
            end
            
            if nameConnection then
                nameConnection:Disconnect()
                nameConnection = nil
            end
            
            if connections.streamerCharAdded then
                connections.streamerCharAdded:Disconnect()
                connections.streamerCharAdded = nil
            end
            
            local mainGui = gui:FindFirstChild("MAINNGUI")
            if mainGui and mainGui:FindFirstChild("Information") then
                local nameLabel = mainGui.Information:FindFirstChild("Name")
                if nameLabel then
                    nameLabel.Text = player.Name
                end
            end
            
            for plr, clothes in pairs(originalClothes) do
                if plr.Character then
                    for _, item in pairs(clothes) do
                        item:Clone().Parent = plr.Character
                    end
                end
            end
            
            for plr, colors in pairs(originalColors) do
                if plr.Character then
                    for part, color in pairs(colors) do
                        if part and part.Parent then
                            part.Color = color
                        end
                    end
                end
            end
            
            originalClothes = {}
            originalColors = {}
            
            library:SendNotification("Streamer Mode disabled!", 3, Color3.new(1, 1, 0))
        end
    end
})
sections.Misc:AddToggle({
    enabled = true,
    text = 'Join Notifications',
    flag = 'JoinNotifications',
    tooltip = 'Show notification when players join',
    risky = false,
    callback = function(state)
        if state then
            JoinConn = Players.PlayerAdded:Connect(function(player)
                library:SendNotification(player.Name .. ' has joined the game', 5, Color3.new(1, 0, 0))
            end)
        else
            if JoinConn then
                JoinConn:Disconnect()
                JoinConn = nil
            end
        end
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Scan Inventories",
    flag = "Scan_Button",
    tooltip = "Check for tracked items in all inventories",
    risky = false,
    confirm = false,
    callback = function()
        findings = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            for _, inventory in ipairs(inventoryLocations) do
                if inventory then
                    for _, itemName in ipairs(getgenv().TrackedItems) do
                        local item = inventory:FindFirstChild(itemName)
                        if item and item:IsA("Tool") then
                            table.insert(findings, {
                                player = player.Name,
                                item = itemName,
                            })
                        end
                    end
                end
            end
        end
        
        if #findings > 0 then
            for _, data in ipairs(findings) do
                library:SendNotification(
                    `{data.player} has "{data.item}"`,
                    5,
                    Color3.new(0.2, 1, 0.2)
                )
            end
        else
            library:SendNotification("No tracked items found", 5, Color3.new(1, 0.2, 0.2))
        end
    end
})

sections.Misc:AddBox({
    enabled = true,
    focused = false,
    text = "Add Item to Track",
    input = "Item Name",
    flag = "Add_Item_Input",
    risky = false,
    callback = function(input)
        if not table.find(getgenv().TrackedItems, input) then
            table.insert(getgenv().TrackedItems, input)
            library:SendNotification(
                `Added '{input}' to tracked items`,
                3,
                Color3.new(1, 1, 0.5)
            )
        end
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Infinite Yield",
    flag = "Infinite_Yield",
    tooltip = "Yk Opens ify",
    risky = false,
    confirm = false,
    callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Project Rain",
    flag = "Project_Rain",
    tooltip = "Yk Opens Project Rain",
    risky = false,
    confirm = false,
    callback = function()
        script_key="qWyXqniLELdFaWAcgOABpsglqFSxDWWE"
        parental_controls = true
        language = "english"
        script_id = "3d78a35719e8950ce3cc15442cdf7067"
        if isfile(string.format("%s-cache.lua",script_id)) then 
            pcall(delfile,string.format("%s-cache.lua",script_id))
        end
        getgenv().language=language=="english"and""or language
        getgenv().parental_controls=parental_controls
        local a=game:HttpGet("https://api.luarmor.net/files/v3/loaders/"..script_id..".lua")
        pcall(loadstring(a))
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Bloodlines Script",
    flag = "Bloodlines_Script",
    tooltip = "Yk Opens IAmJamal10 Script",
    risky = false,
    confirm = false,
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IAmJamal10/Bloodlines/main/ScriptOP"))()
    end
})

-- ========================================
-- ESP SECTION
-- ========================================

local hitboxTransparency = 0.96

sections.ESPSection:AddSlider({
    text = "Hitbox Transparency", 
    flag = 'Transparency_Slider', 
    suffix = "", 
    value = 0.000,
    min = 0, 
    max = 1,
    increment = 0.01,
    callback = function(v) 
        hitboxTransparency = v
    end
})
local HeightSlid = 1.473
local heightConnection = nil

sections.Combat:AddSlider({
    text = "Height Slider", 
    flag = 'Height', 
    suffix = "CM", 
    value = 1.473,
    min = 0.15, 
    max = 5,
    increment = 0.001,
    callback = function(v) 
        HeightSlid = v
        
        if not character or not character:FindFirstChild("Humanoid") then
            library:SendNotification("Character not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local hum = character.Humanoid
        
        local baseHeight = 1.473
        local baseDepth = 1.133
        local baseWidth = 1.133
        local baseHead = 1.133
        
        local heightRatio = v / baseHeight
        
        local newDepth = baseDepth * heightRatio
        local newWidth = baseWidth * heightRatio
        local newHead = baseHead * heightRatio
        
        if hum:FindFirstChild("BodyHeightScale") then
            ValChange:FireServer(hum.BodyHeightScale, v)
            
            if heightConnection then
                heightConnection:Disconnect()
            end
            
            heightConnection = hum.BodyHeightScale.Changed:Connect(function(value)
                if math.abs(value - HeightSlid) > 0.001 then
                    ValChange:FireServer(hum.BodyHeightScale, HeightSlid)
                    
                    local ratio = HeightSlid / baseHeight
                    ValChange:FireServer(hum.BodyDepthScale, baseDepth * ratio)
                    ValChange:FireServer(hum.BodyWidthScale, baseWidth * ratio)
                    ValChange:FireServer(hum.HeadScale, baseHead * ratio)
                end
            end)
        end
        
        if hum:FindFirstChild("BodyDepthScale") then
            ValChange:FireServer(hum.BodyDepthScale, newDepth)
        end
        
        if hum:FindFirstChild("BodyWidthScale") then
            ValChange:FireServer(hum.BodyWidthScale, newWidth)
        end
        
        if hum:FindFirstChild("HeadScale") then
            ValChange:FireServer(hum.HeadScale, newHead)
        end
    end
})

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    if humanoid:FindFirstChild("BodyHeightScale") then
        ValChange:FireServer(humanoid.BodyHeightScale, HeightSlid)
        
        local baseHeight = 1.473
        local baseDepth = 1.133
        local baseWidth = 1.133
        local baseHead = 1.133
        
        local ratio = HeightSlid / baseHeight
        
        ValChange:FireServer(humanoid.BodyDepthScale, baseDepth * ratio)
        ValChange:FireServer(humanoid.BodyWidthScale, baseWidth * ratio)
        ValChange:FireServer(humanoid.HeadScale, baseHead * ratio)
        
        if heightConnection then
            heightConnection:Disconnect()
        end
        
        heightConnection = humanoid.BodyHeightScale.Changed:Connect(function(value)
            if math.abs(value - HeightSlid) > 0.001 then
                ValChange:FireServer(humanoid.BodyHeightScale, HeightSlid)
                
                local ratio = HeightSlid / baseHeight
                ValChange:FireServer(humanoid.BodyDepthScale, baseDepth * ratio)
                ValChange:FireServer(humanoid.BodyWidthScale, baseWidth * ratio)
                ValChange:FireServer(humanoid.HeadScale, baseHead * ratio)
            end
        end)
    end
end)
sections.ESPSection:AddToggle({
    enabled = true,
    text = "Hitbox Visibility",
    flag = "HitboxButton",
    risky = false,
    confirm = false,
    callback = function()
        hitboxVisibilityActive = not hitboxVisibilityActive
        
        if hitboxVisibilityActive then
            local function styleHitbox(obj)
                if obj.Name == "Hitbox" and obj:IsA("BasePart") then
                    hitboxParts[obj] = {
                        Transparency = obj.Transparency,
                        Color = obj.Color,
                        Material = obj.Material
                    }
                    obj.Transparency = hitboxTransparency
                    obj.Color = Color3.new(1, 0, 0)
                    obj.Material = Enum.Material.Neon
                end
            end

            connections.hitboxAddedWorkspace = workspace.ChildAdded:Connect(function(child)
                if child.Name == "Hitbox" then
                    styleHitbox(child)
                end
            end)

            connections.hitboxAddedFX = (workspace:FindFirstChild("FX") or Instance.new("Folder")).ChildAdded:Connect(styleHitbox)

            for _, child in pairs(workspace:GetChildren()) do
                if child.Name == "Hitbox" then
                    styleHitbox(child)
                end
            end

            local fx = workspace:FindFirstChild("FX")
            if fx then
                for _, child in pairs(fx:GetChildren()) do
                    styleHitbox(child)
                end
            end
        else
            for part, properties in pairs(hitboxParts) do
                if part:IsDescendantOf(workspace) then
                    part.Transparency = properties.Transparency
                    part.Color = properties.Color
                    part.Material = properties.Material
                end
            end
            hitboxParts = {}
            
            if connections.hitboxAddedWorkspace then
                connections.hitboxAddedWorkspace:Disconnect()
            end
            if connections.hitboxAddedFX then
                connections.hitboxAddedFX:Disconnect()
            end
        end
    end
})
-- ========================================
-- CHARACTER RESPAWN HANDLER
-- ========================================

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    ToChange = newChar.Stamina
    
    if walkspeedCheat then
        humanoid.WalkSpeed = currentWalkspeed
    end
    if jumppowerCheat then
        humanoid.JumpPower = currentJumppower
    end
    if infiniteJumpEnabled and not infiniteJumpConnection then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if player.Character then
                local currentHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if currentHumanoid and currentHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    currentHumanoid:ChangeState("Jumping")
                end
            end
        end)
    end
end)

-- ========================================
-- INITIALIZATION MESSAGE
-- ========================================
local SettingsFileName = "JJBADL_Settings.json"
local AutoExecFileName = "JJBADL_AutoExec.txt"

local function SaveSettings()
    local settingsToSave = {}
    
    for flag, value in pairs(library.flags) do
        settingsToSave[flag] = value
    end
    
    settingsToSave.CustomSettings = {
        WalkspeedValue = currentWalkspeed,
        JumppowerValue = currentJumppower,
        HitboxTransparency = hitboxTransparency,
        TrackedItems = getgenv().TrackedItems
    }
    
    local success, err = pcall(function()
        writefile(SettingsFileName, game:GetService("HttpService"):JSONEncode(settingsToSave))
    end)
    
    if success then
        library:SendNotification("Settings saved successfully!", 3, Color3.new(0, 1, 0))
    else
        warn("Failed to save settings: " .. tostring(err))
    end
end

local function LoadSettings()
    if not isfile(SettingsFileName) then
        return false
    end
    
    local success, result = pcall(function()
        local data = readfile(SettingsFileName)
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    
    if not success then
        warn("Failed to load settings: " .. tostring(result))
        return false
    end
    
    for flag, value in pairs(result) do
        if flag ~= "CustomSettings" and library.flags[flag] ~= nil then
            library.flags[flag] = value
        end
    end
    
    if result.CustomSettings then
        if result.CustomSettings.WalkspeedValue then
            currentWalkspeed = result.CustomSettings.WalkspeedValue
        end
        if result.CustomSettings.JumppowerValue then
            currentJumppower = result.CustomSettings.JumppowerValue
        end
        if result.CustomSettings.HitboxTransparency then
            hitboxTransparency = result.CustomSettings.HitboxTransparency
        end
        if result.CustomSettings.TrackedItems then
            getgenv().TrackedItems = result.CustomSettings.TrackedItems
        end
    end
    
    library:SendNotification("Settings loaded successfully!", 3, Color3.new(0, 1, 0))
    return true
end

local function EnableAutoExec()
    local scriptContent = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/CrankTo-p/somethingig/refs/heads/main/script.lua"))()
]]
    
    local success, err = pcall(function()
        writefile(AutoExecFileName, scriptContent)
    end)
    
    if success then
        library:SendNotification("Auto-execute enabled! Place this in your autoexec folder", 5, Color3.new(0, 1, 0))
    else
        warn("Failed to create auto-exec file: " .. tostring(err))
    end
end

local function DisableAutoExec()
    if isfile(AutoExecFileName) then
        local success, err = pcall(function()
            delfile(AutoExecFileName)
        end)
        
        if success then
            library:SendNotification("Auto-execute disabled!", 3, Color3.new(1, 1, 0))
        else
            warn("Failed to delete auto-exec file: " .. tostring(err))
        end
    end
end

sections.Settings = tabs.Settings:AddSection("Script Settings", 1)

sections.Settings:AddButton({
    enabled = true,
    text = "Save Settings",
    flag = "Save_Settings_Button",
    tooltip = "Save current settings to file",
    risky = false,
    confirm = false,
    callback = function()
        SaveSettings()
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "Load Settings",
    flag = "Load_Settings_Button",
    tooltip = "Load settings from file",
    risky = false,
    confirm = false,
    callback = function()
        if LoadSettings() then
            task.wait(0.5)
        else
            library:SendNotification("No saved settings found!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Settings:AddToggle({
    enabled = false,
    text = "Auto-Save Settings",
    flag = "Auto_Save_Toggle",
    tooltip = "Automatically save settings every 30 seconds",
    risky = false,
    callback = function(state)
        if state then
            task.spawn(function()
                while library.flags.Auto_Save_Toggle do
                    task.wait(30)
                    if library.flags.Auto_Save_Toggle then
                        SaveSettings()
                    end
                end
            end)
        end
    end
})

sections.Settings:AddSeparator({
    text = "Auto-Execute"
})

sections.Settings:AddButton({
    enabled = true,
    text = "Create Auto-Exec File",
    flag = "Create_AutoExec_Button",
    tooltip = "Creates auto-execute file (move to autoexec folder)",
    risky = false,
    confirm = true,
    callback = function()
        EnableAutoExec()
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "Remove Auto-Exec File",
    flag = "Remove_AutoExec_Button",
    tooltip = "Removes auto-execute file",
    risky = false,
    confirm = true,
    callback = function()
        DisableAutoExec()
    end
})

sections.Settings:AddText({
    enabled = true,
    text = "Note: Auto-exec file must be manually\nmoved to your executor's autoexec folder",
    flag = "AutoExec_Info"
})

sections.Settings:AddSeparator({
    text = "Config Management"
})

local ConfigName = ""

sections.Settings:AddBox({
    enabled = true,
    focused = false,
    text = "Config Name",
    input = "MyConfig",
    flag = "Config_Name_Input",
    callback = function(v)
        ConfigName = v
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "Save Config",
    flag = "Save_Config_Button",
    tooltip = "Save settings with custom name",
    risky = false,
    confirm = false,
    callback = function()
        if ConfigName == "" then
            library:SendNotification("Please enter a config name!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local settingsToSave = {}
        for flag, value in pairs(library.flags) do
            settingsToSave[flag] = value
        end
        
        settingsToSave.CustomSettings = {
            WalkspeedValue = currentWalkspeed,
            JumppowerValue = currentJumppower,
            HitboxTransparency = hitboxTransparency,
            TrackedItems = getgenv().TrackedItems
        }
        
        local fileName = "JJBADL_" .. ConfigName .. ".json"
        local success = pcall(function()
            writefile(fileName, game:GetService("HttpService"):JSONEncode(settingsToSave))
        end)
        
        if success then
            library:SendNotification("Config '" .. ConfigName .. "' saved!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Failed to save config!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "Load Config",
    flag = "Load_Config_Button",
    tooltip = "Load settings from custom config",
    risky = false,
    confirm = false,
    callback = function()
        if ConfigName == "" then
            library:SendNotification("Please enter a config name!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local fileName = "JJBADL_" .. ConfigName .. ".json"
        
        if not isfile(fileName) then
            library:SendNotification("Config not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local success, result = pcall(function()
            local data = readfile(fileName)
            return game:GetService("HttpService"):JSONDecode(data)
        end)
        
        if success then
            for flag, value in pairs(result) do
                if flag ~= "CustomSettings" and library.flags[flag] ~= nil then
                    library.flags[flag] = value
                end
            end
            
            if result.CustomSettings then
                if result.CustomSettings.WalkspeedValue then
                    currentWalkspeed = result.CustomSettings.WalkspeedValue
                end
                if result.CustomSettings.JumppowerValue then
                    currentJumppower = result.CustomSettings.JumppowerValue
                end
                if result.CustomSettings.HitboxTransparency then
                    hitboxTransparency = result.CustomSettings.HitboxTransparency
                end
                if result.CustomSettings.TrackedItems then
                    getgenv().TrackedItems = result.CustomSettings.TrackedItems
                end
            end
            
            library:SendNotification("Config '" .. ConfigName .. "' loaded!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Failed to load config!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "Delete Config",
    flag = "Delete_Config_Button",
    tooltip = "Delete a saved config",
    risky = false,
    confirm = true,
    callback = function()
        if ConfigName == "" then
            library:SendNotification("Please enter a config name!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local fileName = "JJBADL_" .. ConfigName .. ".json"
        
        if isfile(fileName) then
            local success = pcall(function()
                delfile(fileName)
            end)
            
            if success then
                library:SendNotification("Config '" .. ConfigName .. "' deleted!", 3, Color3.new(1, 1, 0))
            else
                library:SendNotification("Failed to delete config!", 3, Color3.new(1, 0, 0))
            end
        else
            library:SendNotification("Config not found!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Settings:AddButton({
    enabled = true,
    text = "List Configs",
    flag = "List_Configs_Button",
    tooltip = "Show all saved configs",
    risky = false,
    confirm = false,
    callback = function()
        local configs = {}
        
        if isfolder then
            local success, files = pcall(function()
                return listfiles(".")
            end)
            
            if success then
                for _, file in pairs(files) do
                    if string.match(file, "JJBADL_.*%.json") then
                        local configName = string.match(file, "JJBADL_(.*)%.json")
                        if configName and configName ~= "Settings" then
                            table.insert(configs, configName)
                        end
                    end
                end
            end
        end
        
        if #configs > 0 then
            library:SendNotification("Saved configs: " .. table.concat(configs, ", "), 5, Color3.new(0.5, 0.5, 1))
        else
            library:SendNotification("No saved configs found!", 3, Color3.new(1, 1, 0))
        end
    end
})

task.spawn(function()
    task.wait(1)
    
    if isfile(SettingsFileName) then
        LoadSettings()
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == library.ScreenGui.Name then
        if library.flags.Auto_Save_Toggle then
            SaveSettings()
        end
    end
end)

game.Players.LocalPlayer.OnTeleport:Connect(function()
    if library.flags.Auto_Save_Toggle then
        SaveSettings()
    end
end)
sections.Combat:AddButton({
    enabled = true,
    text = "Stand God Mode",
    flag = "Stand_God_Button",
    tooltip = "Sets stand damage protection to 0",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand and playerStand:FindFirstChild("DamageProtection") then
            ValChange:FireServer(playerStand.DamageProtection, 0)
            library:SendNotification("Stand God Mode activated!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand not found or no DamageProtection!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Combat:AddButton({
    enabled = true,
    text = "Infinite Remote Control Range",
    flag = "Infinite_RC_Button",
    tooltip = "Creates MirrorStandSeperator value for infinite range",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand then
            if playerStand:FindFirstChild("MirrorStandSeparator") then
                library:SendNotification("MirrorStandSeparator already exists!", 3, Color3.new(1, 1, 0))
                return
            end
            
            local intValue = Instance.new("IntValue")
            intValue.Name = "MirrorStandSeparator"
            intValue.Value = 0
            intValue.Parent = playerStand
            
            library:SendNotification("Infinite RC Range activated!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
        end
    end
})
sections.Combat:AddButton({
    enabled = true,
    text = "Make Stand Aerial",
    flag = "Stand_Aerial_Button",
    tooltip = "Creates SteamForm value for aerial movement",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand then
            if playerStand:FindFirstChild("SteamForm") then
                library:SendNotification("SteamForm already exists!", 3, Color3.new(1, 1, 0))
                return
            end
            
            local intValue = Instance.new("IntValue")
            intValue.Name = "SteamForm"
            intValue.Value = 0
            intValue.Parent = playerStand
            
            library:SendNotification("Stand is now Aerial!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Combat:AddButton({
    enabled = true,
    text = "Infinite Stand Speed",
    flag = "Infinite_Speed_Button",
    tooltip = "Sets stand speed multipliers to max",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand and playerStand:FindFirstChild("Attributes") then
            local atts = playerStand.Attributes

            local Electricity = Instance.new("NumberValue", atts)
            local Liquid = Instance.new("NumberValue", atts)
            local TowerSpeed = Instance.new("NumberValue", atts)
            Liquid.Value = 10000
            Electricity.Value = 10000
            TowerSpeed.Name = 'TowerSpeed'
            Electricity.Name = 'Electricity'
            Liquid.Name = 'Liquid'
            game.Lighting.Raining = true
            library:SendNotification("Stand speed maximized!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand or Attributes not found!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Combat:AddButton({
    enabled = true,
    text = "Remove Stand Debuffs",
    flag = "Remove_Debuffs_Button",
    tooltip = "Removes negative status effects from stand",
    risky = false,
    confirm = false,
    callback = function()
        local status = character:FindFirstChild("Status")
        if not status then
            library:SendNotification("Status not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local debuffs = {
            "ThreeFreezed", "Stun", "LesserStun", "Undernourished", 
            "LesserStunRunless", "Blinded", "TimeErase", "Dehydrated",
            "LifeShot", "ShrunkenSlowDebuff", "StandTRIPPED", "Ragdolled",
            "BookedHeavy", "Booked", "NoMovement", "Expelling", 
            "ElectricTransferring", "MindControlled", "Slipped", 
            "Charging", "BubbleEncased"
        }
        
        local removed = 0
        for _, debuff in pairs(debuffs) do
            if status:FindFirstChild(debuff) then
                status[debuff]:Destroy()
                removed = removed + 1
            end
        end
        
        if removed > 0 then
            library:SendNotification("Removed " .. removed .. " debuffs!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("No debuffs found!", 3, Color3.new(1, 1, 0))
        end
    end
})

sections.Combat:AddButton({
    enabled = true,
    text = "Freeze Stand Position",
    flag = "Freeze_Stand_Button",
    tooltip = "Locks stand in current position",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand and playerStand:FindFirstChild("HumanoidRootPart") then
            local root = playerStand.HumanoidRootPart
            
            if root:FindFirstChild("FreezePosition") then
                root.FreezePosition:Destroy()
                library:SendNotification("Stand position unfrozen!", 3, Color3.new(1, 1, 0))
            else
                local bodyPos = Instance.new("BodyPosition")
                bodyPos.Name = "FreezePosition"
                bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyPos.Position = root.Position
                bodyPos.Parent = root
                
                library:SendNotification("Stand position frozen!", 3, Color3.new(0, 1, 0))
            end
        else
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
        end
    end
})

sections.Combat:AddButton({
    enabled = true,
    text = "Teleport Stand to Player",
    flag = "TP_Stand_Button",
    tooltip = "Teleports stand to your position",
    risky = false,
    confirm = false,
    callback = function()
        local standsFolder = workspace:FindFirstChild("Stands")
        if not standsFolder then
            library:SendNotification("Stands folder not found!", 3, Color3.new(1, 0, 0))
            return
        end
        
        local playerStand = standsFolder:FindFirstChild(player.Name)
        if playerStand and playerStand:FindFirstChild("HumanoidRootPart") then
            playerStand.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
            library:SendNotification("Stand teleported to you!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
        end
    end
})
local ammoConnections = {}

sections.Combat:AddToggle({
    enabled = true,
    text = "Infinite Ammo",
    flag = "InfiniteAmmo_Toggle",
    callback = function(state)
        if state then
            local function handleTool(tool)
                if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                    local ammo = tool.Ammo
                    
                    ValChange:FireServer(ammo, 6)
                    
                    local ammoConn = ammo.Changed:Connect(function(value)
                        if library.flags.InfiniteAmmo_Toggle and value < 6 then
                            ValChange:FireServer(ammo, 6)
                        end
                    end)
                    
                    ammoConnections[tool] = ammoConn
                    
                    tool.AncestryChanged:Connect(function()
                        if not tool:IsDescendantOf(workspace) and ammoConnections[tool] then
                            ammoConnections[tool]:Disconnect()
                            ammoConnections[tool] = nil
                        end
                    end)
                end
            end
            
            for _, tool in pairs(character:GetChildren()) do
                handleTool(tool)
            end
            
            connections.infiniteAmmo = character.ChildAdded:Connect(function(child)
                handleTool(child)
            end)
        else
            if connections.infiniteAmmo then
                connections.infiniteAmmo:Disconnect()
                connections.infiniteAmmo = nil
            end
            
            for tool, conn in pairs(ammoConnections) do
                conn:Disconnect()
            end
            ammoConnections = {}
        end
    end
})
local moderatorIds = {
    1299387765, 2232457771, 2307801292, 1909757624, 3445752716,
    4550728214, 5680333301, 50203403, 1708981366, 399667054,
    1445187684, 61376390, 243776147, 987524554, 1402882528,
    734299965, 1237808459, 128503556
}

local modDetectorConnection = nil

sections.Misc:AddToggle({
    enabled = true,
    text = 'Moderator Detector',
    flag = 'ModDetector',
    tooltip = 'Notifies when a moderator joins',
    risky = false,
    callback = function(state)
        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                if table.find(moderatorIds, plr.UserId) then
                    library:SendNotification("⚠️ MODERATOR DETECTED: " .. plr.Name, 10, Color3.new(1, 0, 0))
                end
            end
            
            modDetectorConnection = Players.PlayerAdded:Connect(function(plr)
                if table.find(moderatorIds, plr.UserId) then
                    library:SendNotification("⚠️ MODERATOR JOINED: " .. plr.Name, 10, Color3.new(1, 0, 0))
                end
            end)
        else
            if modDetectorConnection then
                modDetectorConnection:Disconnect()
                modDetectorConnection = nil
            end
        end
    end
})

local modKickConnection = nil

sections.Misc:AddToggle({
    enabled = true,
    text = 'Moderator Detector Kick',
    flag = 'ModDetectorKick',
    tooltip = 'Automatically kicks you when a moderator is detected',
    risky = true,
    callback = function(state)
        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                if table.find(moderatorIds, plr.UserId) then
                    if LocalPlayer:FindFirstChild('CombatTag') then
                        local Timer = LocalPlayer.CombatTag:WaitForChild('Timer')
                        ValChange:FireServer(Timer, 0)
                        task.wait(0.5)
                    end
                    
                    LocalPlayer:Kick("⚠️ MODERATOR DETECTED: " .. plr.Name .. " - Auto-kicked for safety")
                    return
                end
            end
            
            modKickConnection = Players.PlayerAdded:Connect(function(plr)
                if table.find(moderatorIds, plr.UserId) then
                    library:SendNotification("⚠️ MODERATOR DETECTED - KICKING!", 3, Color3.new(1, 0, 0))
                    
                    if LocalPlayer:FindFirstChild('CombatTag') then
                        local Timer = LocalPlayer.CombatTag:WaitForChild('Timer')
                        ValChange:FireServer(Timer, 0)
                        task.wait(0.5)
                    end
                    
                    LocalPlayer:Kick("⚠️ MODERATOR DETECTED: " .. plr.Name .. " - Auto-kicked for safety")
                end
            end)
        else
            if modKickConnection then
                modKickConnection:Disconnect()
                modKickConnection = nil
            end
        end
    end
})
library:SendNotification("Made by Zik $20 dm me Zikiouh for full script", 5, Color3.new(1, 0, 0))
