getgenv().Config = {
    Invite = "informant.wtf",
    Version = "0.0",
}

getgenv().luaguardvars = {
    DiscordName = "zikiouh#0000",
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local gui = LocalPlayer:WaitForChild("PlayerGui")

local player = LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local ocean = workspace.Map and workspace.Map:FindFirstChild("Ocean")
local Projectiles = workspace:FindFirstChild("Projectiles")

local Network = game.ReplicatedStorage:FindFirstChild("Network") and game.ReplicatedStorage.Network:FindFirstChild("Running")
local ValChange = game.ReplicatedStorage:FindFirstChild("Network") and game.ReplicatedStorage.Network:FindFirstChild("HamonCharge")

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

local walkspeedCheat = false
local walkspeedRunning = false
local currentWalkspeed = 16

local jumppowerCheat = false
local jumppowerRunning = false
local currentJumppower = 50

local infiniteJumpEnabled = false
local infiniteJumpConnection = nil

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

local inventoryLocations = {
    player:FindFirstChild("Backpack"),
    player.Character
}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CrankTo-p/Informantsadasdsad/refs/heads/main/informant.wtf%20Lib%20Source.lua"))()
library:init()

pcall(function()
    game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

local Window = library.NewWindow({
    title = "JJBAD Paid Script",
    size = UDim2.new(0, 525, 0, 650)
})

local tabs = {
    MainTab = Window:AddTab("Main"),
    ESPTab = Window:AddTab("Esp"),
    Settings = library:CreateSettingsTab(Window),
}

local sections = {
    Combat = tabs.MainTab:AddSection("Combat", 1),
    Misc = tabs.MainTab:AddSection("Misc", 2),
    Visual = tabs.ESPTab:AddSection("Visual", 2),
    ESPSection = tabs.ESPTab:AddSection("ESP", 1),
}

local originalLighting = {}

sections.Visual:AddToggle({
    enabled = true,
    text = "Fullbright",
    flag = "Fullbright_Toggle",
    risky = false,
    callback = function(state)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            if state then
                originalLighting.Brightness = Lighting.Brightness
                originalLighting.ClockTime = Lighting.ClockTime
                originalLighting.FogEnd = Lighting.FogEnd
                originalLighting.GlobalShadows = Lighting.GlobalShadows
                originalLighting.Ambient = Lighting.Ambient
                originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                for _, fx in ipairs(Lighting:GetChildren()) do
                    if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                        pcall(function() fx.Enabled = false end)
                    end
                end
            else
                if originalLighting.Brightness then Lighting.Brightness = originalLighting.Brightness end
                if originalLighting.ClockTime then Lighting.ClockTime = originalLighting.ClockTime end
                if originalLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = originalLighting.GlobalShadows end
                if originalLighting.Ambient then Lighting.Ambient = originalLighting.Ambient end
                if originalLighting.OutdoorAmbient then Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient end
                for _, fx in ipairs(Lighting:GetChildren()) do
                    if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                        pcall(function() fx.Enabled = true end)
                    end
                end
            end
        end)
    end
})

local originalFog = {}

sections.Visual:AddToggle({
    enabled = true,
    text = "No Fog",
    flag = "NoFog_Toggle",
    risky = false,
    callback = function(state)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            if state then
                originalFog.FogEnd = Lighting.FogEnd
                originalFog.FogStart = Lighting.FogStart
                originalFog.FogColor = Lighting.FogColor
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
            else
                if originalFog.FogEnd then Lighting.FogEnd = originalFog.FogEnd end
                if originalFog.FogStart then Lighting.FogStart = originalFog.FogStart end
                if originalFog.FogColor then Lighting.FogColor = originalFog.FogColor end
            end
        end)
    end
})

local function safeFireServer(remote, ...)
    if not remote then return end
    local args = table.pack(...)
    local ok, err = pcall(function()
        remote:FireServer(table.unpack(args, 1, args.n))
    end)
    if not ok then
        warn("FireServer failed: " .. tostring(err))
    end
end

local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getPlayerStand()
    local standsFolder = workspace:FindFirstChild("Stands")
    return standsFolder and standsFolder:FindFirstChild(player.Name)
end

sections.Combat:AddToggle({
    enabled = true,
    text = "Remove Projectile Touch",
    flag = "Toggle_ProjectileTouch",
    risky = false,
    callback = function(state)
        if state then
            local function handleInstance(instance)
                if not instance or not instance.Parent then return end
                local function removeTouch(descendant)
                    if descendant and descendant:IsA("TouchTransmitter") then
                        pcall(function() descendant:Destroy() end)
                    end
                end
                local ok, err = pcall(function()
                    for _, d in ipairs(instance:GetDescendants()) do removeTouch(d) end
                end)
                if not ok then warn("handleInstance descendants error: " .. tostring(err)) end
                local conn
                ok, conn = pcall(function()
                    return instance.DescendantAdded:Connect(removeTouch)
                end)
                if ok then return conn end
            end

            if Projectiles then
                local function handleProjectile(projectile)
                    if not projectile then return end
                    local conn = handleInstance(projectile)
                    if conn then table.insert(connections.projectiles, conn) end
                end
                pcall(function()
                    connections.projectileAdded = Projectiles.ChildAdded:Connect(handleProjectile)
                    for _, proj in ipairs(Projectiles:GetChildren()) do handleProjectile(proj) end
                end)
            end

            local function monitorStands()
                local standsFolder = workspace:FindFirstChild("Stands")
                if not standsFolder then return end

                local function processStandChild(child)
                    if child and child:IsA("BasePart") then
                        local conn = handleInstance(child)
                        if conn then table.insert(connections.stands, conn) end
                    end
                end

                local function handleFinger(finger)
                    if not finger then return end
                    local conn = handleInstance(finger)
                    if conn then table.insert(connections.fingers, conn) end
                end

                pcall(function()
                    for _, stand in ipairs(standsFolder:GetChildren()) do
                        for _, child in ipairs(stand:GetDescendants()) do
                            processStandChild(child)
                            if child.Name == "Finger" then handleFinger(child) end
                        end
                        stand.ChildAdded:Connect(function(child)
                            if child and child.Name == "Finger" then handleFinger(child) end
                        end)
                    end
                    connections.standDescendantAdded = standsFolder.DescendantAdded:Connect(processStandChild)
                end)
            end

            monitorStands()
            pcall(function()
                connections.standsAdded = workspace.ChildAdded:Connect(function(child)
                    if child and child.Name == "Stands" then monitorStands() end
                end)
            end)

            local function genericHandler(pattern, storage)
                return function(child)
                    if child and string.find(child.Name:lower(), pattern) then
                        local conn = handleInstance(child)
                        if conn then table.insert(storage, conn) end
                    end
                end
            end

            pcall(function()
                connections.landmineAdded = workspace.ChildAdded:Connect(genericHandler("landmine", connections.landmines))
                connections.icicleAdded = workspace.ChildAdded:Connect(genericHandler("icicle", connections.icicles))
                for _, child in ipairs(workspace:GetChildren()) do
                    genericHandler("landmine", connections.landmines)(child)
                    genericHandler("icicle", connections.icicles)(child)
                end
            end)
        else
            pcall(function()
                if connections.projectileAdded then connections.projectileAdded:Disconnect() end
                if connections.landmineAdded then connections.landmineAdded:Disconnect() end
                if connections.icicleAdded then connections.icicleAdded:Disconnect() end
                if connections.standsAdded then connections.standsAdded:Disconnect() end
                if connections.standDescendantAdded then connections.standDescendantAdded:Disconnect() end

                for _, tbl in ipairs({connections.projectiles, connections.landmines, connections.icicles, connections.stands, connections.fingers}) do
                    for _, conn in ipairs(tbl) do
                        if conn then pcall(function() conn:Disconnect() end) end
                    end
                    for i = #tbl, 1, -1 do tbl[i] = nil end
                end
            end)
        end
    end
})

sections.Combat:AddSeparator({ text = "Movement Hacks" })

sections.Combat:AddToggle({
    enabled = true,
    text = "Walkspeed",
    flag = "Walkspeed_Toggle",
    callback = function(value)
        walkspeedCheat = value
        if value then
            walkspeedRunning = true
            task.spawn(function()
                while walkspeedRunning do
                    local hum = getHumanoid()
                    if hum and walkspeedCheat then
                        pcall(function() hum.WalkSpeed = currentWalkspeed end)
                    end
                    task.wait(0.1)
                end
            end)
        else
            walkspeedRunning = false
            local hum = getHumanoid()
            if hum then pcall(function() hum.WalkSpeed = 16 end) end
        end
    end
})

sections.Combat:AddSlider({
    text = "Walkspeed",
    flag = "Walkspeed_Value",
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
            task.spawn(function()
                while jumppowerRunning do
                    local hum = getHumanoid()
                    if hum and jumppowerCheat then
                        pcall(function() hum.JumpPower = currentJumppower end)
                    end
                    task.wait(0.1)
                end
            end)
        else
            jumppowerRunning = false
            local hum = getHumanoid()
            if hum then pcall(function() hum.JumpPower = 50 end) end
        end
    end
})

sections.Combat:AddSlider({
    text = "JumpPower",
    flag = "Jumppower_Value",
    value = 50,
    min = 50,
    max = 200,
    callback = function(v)
        currentJumppower = v
    end
})

local standSpeedCheat = false
local standSpeedRunning = false
local currentStandSpeed = 1

sections.Combat:AddSeparator({ text = "Stand Speed" })

sections.Combat:AddToggle({
    enabled = true,
    text = "Stand Speed",
    flag = "StandSpeed_Toggle",
    callback = function(value)
        standSpeedCheat = value
        if value then
            standSpeedRunning = true
            task.spawn(function()
                while standSpeedRunning do
                    if standSpeedCheat then
                        pcall(function()
                            local standsFolder = workspace:FindFirstChild("Stands")
                            local playerStand = standsFolder and standsFolder:FindFirstChild(player.Name)
                            if playerStand then
                                local hrp = playerStand:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local bv = hrp:FindFirstChildWhichIsA("BodyVelocity")
                                    if bv then
                                        local mag = bv.Velocity.Magnitude
                                        if mag > 0.1 then
                                            bv.Velocity = bv.Velocity.Unit * (mag * currentStandSpeed)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    task.wait()
                end
            end)
        else
            standSpeedRunning = false
        end
    end
})

sections.Combat:AddSlider({
    text = "Stand Speed Multiplier",
    flag = "StandSpeed_Value",
    value = 1,
    min = 1,
    max = 10,
    increment = 0.1,
    callback = function(v)
        currentStandSpeed = v
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Infinite Jump",
    flag = "InfiniteJump_Toggle",
    callback = function(state)
        infiniteJumpEnabled = state
        if state then
            pcall(function()
                infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    if not infiniteJumpEnabled then return end
                    local char = getCharacter()
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                            pcall(function() hum:ChangeState("Jumping") end)
                        end
                    end
                end)
            end)
        else
            if infiniteJumpConnection then
                pcall(function() infiniteJumpConnection:Disconnect() end)
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
            local cam = workspace.CurrentCamera

            local function updateVelocity()
                local r = getRoot()
                local hum = getHumanoid()
                if not r or not hum then return end
                local ok, err = pcall(function()
                    local cf = cam.CFrame
                    local speed = walkspeedCheat and currentWalkspeed or 16
                    local moveDir = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
                    local relative = cf:VectorToWorldSpace(moveDir)
                    local gravity = hum:GetState() == Enum.HumanoidStateType.Freefall and 0.8 or 1
                    if hum:GetState() ~= Enum.HumanoidStateType.Running then
                        r.Velocity = Vector3.new(
                            relative.X * speed * 2,
                            r.Velocity.Y * gravity,
                            relative.Z * speed * 2
                        )
                    end
                end)
                if not ok then warn("AirControl velocity error: " .. tostring(err)) end
            end

            pcall(function()
                conn = RunService.Heartbeat:Connect(updateVelocity)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local keys = {
                            [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
                            [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
                            [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
                            [Enum.KeyCode.D] = Vector3.new(1, 0, 0)
                        }
                        local hum = getHumanoid()
                        if keys[input.KeyCode] and hum then
                            moveVector = hum.MoveDirection + keys[input.KeyCode]
                        end
                    end
                end)

                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                end)

                getgenv().AirControlConnection = conn
            end)
        else
            if getgenv().AirControlConnection then
                pcall(function() getgenv().AirControlConnection:Disconnect() end)
                getgenv().AirControlConnection = nil
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
                if not part or not part:IsA("BasePart") then return end
                pcall(function()
                    standParts[part] = standParts[part] or part.CanCollide
                    part.CanCollide = false
                end)
            end

            local function handleStand(stand)
                if not stand then return end
                pcall(function()
                    for _, child in ipairs(stand:GetDescendants()) do
                        processPart(child)
                        if child:IsA("Accessory") then
                            for _, ap in ipairs(child:GetDescendants()) do processPart(ap) end
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
                            if part.Parent == nil then standParts[part] = nil end
                        end
                    end)
                end)
            end

            pcall(function()
                RunService.Heartbeat:Connect(function()
                    if not standNoClipActive then return end
                    local playerStand = getPlayerStand()
                    if playerStand then
                        for part in pairs(standParts) do
                            if part and part.Parent then
                                pcall(function() part.CanCollide = false end)
                            end
                        end
                        if not standConnections.descendantAdded then
                            handleStand(playerStand)
                        end
                    end
                end)
            end)
        else
            pcall(function()
                for part, canCollide in pairs(standParts) do
                    if part and part.Parent then
                        pcall(function() part.CanCollide = canCollide end)
                    end
                end
                for _, connection in pairs(standConnections) do
                    if connection then pcall(function() connection:Disconnect() end) end
                end
                standParts = {}
                standConnections = {}
            end)
        end
    end
})

sections.Misc:AddToggle({
    enabled = true,
    text = "Infinite Stamina",
    flag = "InfiniteStamina_Toggle",
    tooltip = "Auto-keeps stamina at 500",
    risky = true,
    callback = function(state)
        if state then
            local function hookStamina(char)
                if not char then return end
                local stam = char:FindFirstChild("Stamina")
                if not stam then
                    task.spawn(function()
                        stam = char:WaitForChild("Stamina", 5)
                        if stam and library.flags.InfiniteStamina_Toggle then
                            safeFireServer(ValChange, stam, 500)
                            if getgenv().StaminaConn then pcall(function() getgenv().StaminaConn:Disconnect() end) end
                            getgenv().StaminaConn = stam.Changed:Connect(function(val)
                                if library.flags.InfiniteStamina_Toggle and val < 500 then
                                    safeFireServer(ValChange, stam, 500)
                                end
                            end)
                        end
                    end)
                    return
                end
                safeFireServer(ValChange, stam, 500)
                if getgenv().StaminaConn then pcall(function() getgenv().StaminaConn:Disconnect() end) end
                getgenv().StaminaConn = stam.Changed:Connect(function(val)
                    if library.flags.InfiniteStamina_Toggle and val < 500 then
                        safeFireServer(ValChange, stam, 500)
                    end
                end)
            end

            hookStamina(getCharacter())
            if getgenv().StaminaCharConn then pcall(function() getgenv().StaminaCharConn:Disconnect() end) end
            getgenv().StaminaCharConn = player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if library.flags.InfiniteStamina_Toggle then
                    hookStamina(char)
                end
            end)
            library:SendNotification("Infinite Stamina enabled!", 3, Color3.new(0, 1, 0))
        else
            if getgenv().StaminaConn then pcall(function() getgenv().StaminaConn:Disconnect() end); getgenv().StaminaConn = nil end
            if getgenv().StaminaCharConn then pcall(function() getgenv().StaminaCharConn:Disconnect() end); getgenv().StaminaCharConn = nil end
            library:SendNotification("Infinite Stamina disabled!", 3, Color3.new(1, 1, 0))
        end
    end
})

sections.Misc:AddToggle({
    enabled = true,
    text = "No Combat Tag",
    flag = "NoCombatTag_Toggle",
    tooltip = "Constantly clears combat tag timer",
    risky = true,
    callback = function(state)
        if state then
            if getgenv().CombatTagConn then pcall(function() getgenv().CombatTagConn:Disconnect() end) end
            if getgenv().CombatTagTimerConn then pcall(function() getgenv().CombatTagTimerConn:Disconnect() end) end

            local function hookCombatTag()
                local combatTag = LocalPlayer:FindFirstChild("CombatTag")
                if combatTag then
                    local Timer = combatTag:FindFirstChild("Timer") or combatTag:WaitForChild("Timer", 2)
                    if Timer then
                        safeFireServer(ValChange, Timer, 0)
                        if getgenv().CombatTagTimerConn then pcall(function() getgenv().CombatTagTimerConn:Disconnect() end) end
                        getgenv().CombatTagTimerConn = Timer.Changed:Connect(function(val)
                            if library.flags.NoCombatTag_Toggle and val > 0 then
                                safeFireServer(ValChange, Timer, 0)
                            end
                        end)
                    end
                end
            end

            hookCombatTag()
            getgenv().CombatTagConn = LocalPlayer.ChildAdded:Connect(function(child)
                if child.Name == "CombatTag" and library.flags.NoCombatTag_Toggle then
                    task.wait(0.05)
                    hookCombatTag()
                end
            end)
            library:SendNotification("No Combat Tag enabled!", 3, Color3.new(0, 1, 0))
        else
            if getgenv().CombatTagConn then pcall(function() getgenv().CombatTagConn:Disconnect() end); getgenv().CombatTagConn = nil end
            if getgenv().CombatTagTimerConn then pcall(function() getgenv().CombatTagTimerConn:Disconnect() end); getgenv().CombatTagTimerConn = nil end
            library:SendNotification("No Combat Tag disabled!", 3, Color3.new(1, 1, 0))
        end
    end
})

local infiniteDmgConns = {}
local currentStandDamage = 100

sections.Combat:AddSeparator({ text = "Stand Damage" })

sections.Combat:AddSlider({
    text = "Stand Damage Value",
    flag = "StandDamage_Value",
    value = 100,
    min = 10,
    max = 1000,
    increment = 1,
    callback = function(v)
        currentStandDamage = v
    end
})

sections.Combat:AddToggle({
    enabled = true,
    text = "Stand Damage Override",
    flag = "InfiniteDamage_Toggle",
    tooltip = "Forces stand Damage and BarragePercentage to slider value",
    risky = true,
    callback = function(state)
        if state then
            local function hookDamage(stand)
                if not stand then return end
                local attrs = stand:FindFirstChild("Attributes")
                if not attrs then return end

                local dmg = attrs:FindFirstChild("Damage")
                local barrage = attrs:FindFirstChild("BarragePercentage")
                local speed = attrs:FindFirstChild("Speed")

                if dmg then
                    safeFireServer(ValChange, dmg, currentStandDamage)
                    table.insert(infiniteDmgConns, dmg.Changed:Connect(function(v)
                        if library.flags.InfiniteDamage_Toggle and v ~= currentStandDamage then
                            safeFireServer(ValChange, dmg, currentStandDamage)
                        end
                    end))
                end
                if barrage then
                    safeFireServer(ValChange, barrage, 1)
                    table.insert(infiniteDmgConns, barrage.Changed:Connect(function(v)
                        if library.flags.InfiniteDamage_Toggle and v < 1 then
                            safeFireServer(ValChange, barrage, 1)
                        end
                    end))
                end
                if speed then
                    safeFireServer(ValChange, speed, 10)
                    table.insert(infiniteDmgConns, speed.Changed:Connect(function(v)
                        if library.flags.InfiniteDamage_Toggle and v < 10 then
                            safeFireServer(ValChange, speed, 10)
                        end
                    end))
                end
            end

            local playerStand = getPlayerStand()
            hookDamage(playerStand)

            pcall(function()
                table.insert(infiniteDmgConns, workspace.Stands.ChildAdded:Connect(function(child)
                    if child.Name == player.Name and library.flags.InfiniteDamage_Toggle then
                        task.wait(0.5)
                        hookDamage(child)
                    end
                end))
            end)

            library:SendNotification("Stand Damage Override enabled! (" .. currentStandDamage .. ")", 3, Color3.new(0, 1, 0))
        else
            for _, conn in ipairs(infiniteDmgConns) do
                pcall(function() conn:Disconnect() end)
            end
            infiniteDmgConns = {}
            library:SendNotification("Stand Damage Override disabled!", 3, Color3.new(1, 1, 0))
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
            getgenv().NofallRunning = true
            task.spawn(function()
                while getgenv().NofallRunning and library.flags.Nofall_Toggle do
                    local r = getRoot()
                    if not r then
                        pcall(function()
                            character = player.CharacterAdded:Wait()
                            task.wait(0.5)
                            r = character:WaitForChild("HumanoidRootPart")
                        end)
                    end
                    if r then
                        pcall(function()
                            if r.AssemblyLinearVelocity.Y < -50 then
                                local vel = r.AssemblyLinearVelocity
                                r.Velocity = Vector3.new(vel.X, math.max(vel.Y, -64.9), vel.Z)
                            end
                        end)
                    end
                    task.wait()
                end
                getgenv().NofallRunning = false
            end)
        else
            getgenv().NofallRunning = false
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
    tooltip = "Sets a disc's stand and exp values",
    risky = false,
    confirm = false,
    callback = function()
        if DiscStandName == "" then
            library:SendNotification("Please enter a stand name!", 3, Color3.new(1, 0, 0))
            return
        end
        local char = getCharacter()
        if not char then
            library:SendNotification("Character not found!", 3, Color3.new(1, 0, 0))
            return
        end
        local Disc = char:FindFirstChildOfClass("Tool")
        if Disc and Disc:FindFirstChild("DiscType") then
            local attrs = Disc:FindFirstChild("StolenAttributes")
            if attrs then
                safeFireServer(ValChange, attrs:FindFirstChild("StolenStand"), DiscStandName)
                safeFireServer(ValChange, attrs:FindFirstChild("StolenStandExp"), 10000000000)
            end
            safeFireServer(ValChange, Disc.DiscType, "Stand")
            safeFireServer(ValChange, Disc:FindFirstChild("CommandType"), "None")
            library:SendNotification("Disc set to: " .. DiscStandName, 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("No disc equipped!", 3, Color3.new(1, 0, 0))
        end
    end
})

local StolenStyleName = ""

sections.Misc:AddBox({
    enabled = true,
    focused = false,
    text = "Style Name",
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
    tooltip = "Sets a disc's style and exp values",
    risky = false,
    confirm = false,
    callback = function()
        if StolenStyleName == "" then
            library:SendNotification("Please enter a style name!", 3, Color3.new(1, 0, 0))
            return
        end
        local char = getCharacter()
        if not char then
            library:SendNotification("Character not found!", 3, Color3.new(1, 0, 0))
            return
        end
        local Disc = char:FindFirstChildOfClass("Tool")
        if Disc and Disc:FindFirstChild("DiscType") then
            local attrs = Disc:FindFirstChild("StolenAttributes")
            if attrs then
                safeFireServer(ValChange, attrs:FindFirstChild("StolenStyleBool"), true)
                safeFireServer(ValChange, attrs:FindFirstChild("StolenStyleExp"), 10000000000)
            end
            safeFireServer(ValChange, Disc.DiscType, StolenStyleName)
            safeFireServer(ValChange, Disc:FindFirstChild("CommandType"), "None")
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
    tooltip = "Sets a Yen Tool in the Character to 15000",
    risky = false,
    confirm = false,
    callback = function()
        local char = getCharacter()
        if not char then
            library:SendNotification("Character not found!", 3, Color3.new(1, 0, 0))
            return
        end
        local Yen = char:FindFirstChildOfClass("Tool")
        if Yen and Yen:FindFirstChild("YenAmount") then
            safeFireServer(ValChange, Yen.YenAmount, 15000)
            library:SendNotification("Yen set to 15000!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("No Yen tool equipped!", 3, Color3.new(1, 0, 0))
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
                    local standsFolder = workspace:FindFirstChild("Stands")
                    if standsFolder then
                        pcall(function()
                            for _, Stand in pairs(standsFolder:GetChildren()) do
                                for _, Part in ipairs(Stand:GetDescendants()) do
                                    if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" and not Stand:FindFirstChild("Deactivated") then
                                        Part.Transparency = 0
                                    end
                                end
                            end
                        end)
                    end
                end
            end)
        else
            if connections.standLoop then
                pcall(function() task.cancel(connections.standLoop) end)
                connections.standLoop = nil
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
            pcall(function()
                local leaderboard = game:GetService("CoreGui"):FindFirstChild("PlayerList")
                if leaderboard then
                    leaderboard.Enabled = false
                    leaderboardConnection = leaderboard:GetPropertyChangedSignal("Enabled"):Connect(function()
                        if streamerModeActive then leaderboard.Enabled = false end
                    end)
                end
            end)

            pcall(function()
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
            end)

            pcall(function()
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
            end)

            pcall(function()
                connections.streamerCharAdded = Players.PlayerAdded:Connect(function(plr)
                    plr.CharacterAdded:Connect(function(char)
                        if streamerModeActive and plr ~= player then
                            task.wait(0.5)
                            for _, item in pairs(char:GetChildren()) do
                                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                                    pcall(function() item:Destroy() end)
                                end
                            end
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    pcall(function() part.Color = Color3.fromRGB(163, 162, 165) end)
                                end
                            end
                        end
                    end)
                end)
            end)

            library:SendNotification("Streamer Mode enabled!", 3, Color3.new(0, 1, 0))
        else
            pcall(function()
                local leaderboard = game:GetService("CoreGui"):FindFirstChild("PlayerList")
                if leaderboard then leaderboard.Enabled = true end
            end)

            if leaderboardConnection then pcall(function() leaderboardConnection:Disconnect() end); leaderboardConnection = nil end
            if nameConnection then pcall(function() nameConnection:Disconnect() end); nameConnection = nil end
            if connections.streamerCharAdded then pcall(function() connections.streamerCharAdded:Disconnect() end); connections.streamerCharAdded = nil end

            pcall(function()
                local mainGui = gui:FindFirstChild("MAINNGUI")
                if mainGui and mainGui:FindFirstChild("Information") then
                    local nameLabel = mainGui.Information:FindFirstChild("Name")
                    if nameLabel then nameLabel.Text = player.Name end
                end
            end)

            pcall(function()
                for plr, clothes in pairs(originalClothes) do
                    if plr and plr.Character then
                        for _, item in pairs(clothes) do
                            pcall(function() item:Clone().Parent = plr.Character end)
                        end
                    end
                end
                for plr, colors in pairs(originalColors) do
                    if plr and plr.Character then
                        for part, color in pairs(colors) do
                            if part and part.Parent then
                                pcall(function() part.Color = color end)
                            end
                        end
                    end
                end
            end)

            originalClothes = {}
            originalColors = {}
            library:SendNotification("Streamer Mode disabled!", 3, Color3.new(1, 1, 0))
        end
    end
})

sections.Misc:AddToggle({
    enabled = true,
    text = "Join Notifications",
    flag = "JoinNotifications",
    tooltip = "Show notification when players join",
    risky = false,
    callback = function(state)
        if state then
            pcall(function()
                JoinConn = Players.PlayerAdded:Connect(function(p)
                    library:SendNotification(p.Name .. " has joined the game", 5, Color3.new(1, 0, 0))
                end)
            end)
        else
            if JoinConn then
                pcall(function() JoinConn:Disconnect() end)
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
        if not getgenv().TrackedItems or #getgenv().TrackedItems == 0 then
            library:SendNotification("No items being tracked!", 3, Color3.new(1, 1, 0))
            return
        end

        findings = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            for _, inventory in ipairs(inventoryLocations) do
                if inventory then
                    for _, itemName in ipairs(getgenv().TrackedItems) do
                        local ok, item = pcall(function()
                            return inventory:FindFirstChild(itemName)
                        end)
                        if ok and item and item:IsA("Tool") then
                            table.insert(findings, { player = p.Name, item = itemName })
                        end
                    end
                end
            end
        end

        if #findings > 0 then
            for _, data in ipairs(findings) do
                library:SendNotification(data.player .. ' has "' .. data.item .. '"', 5, Color3.new(0.2, 1, 0.2))
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
        if not input or input == "" or input == "Item Name" then
            library:SendNotification("Please enter a valid item name!", 3, Color3.new(1, 0, 0))
            return
        end
        if not getgenv().TrackedItems then getgenv().TrackedItems = {} end
        if not table.find(getgenv().TrackedItems, input) then
            table.insert(getgenv().TrackedItems, input)
            library:SendNotification("Added '" .. input .. "' to tracked items", 3, Color3.new(1, 1, 0.5))
        else
            library:SendNotification("'" .. input .. "' is already tracked!", 3, Color3.new(1, 1, 0))
        end
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Infinite Yield",
    flag = "Infinite_Yield",
    tooltip = "Opens Infinite Yield",
    risky = false,
    confirm = false,
    callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Project Rain",
    flag = "Project_Rain",
    tooltip = "Opens Project Rain",
    risky = false,
    confirm = false,
    callback = function()
        pcall(function()
            script_key = "qWyXqniLELdFaWAcgOABpsglqFSxDWWE"
            parental_controls = true
            language = "english"
            script_id = "3d78a35719e8950ce3cc15442cdf7067"
            if isfile(script_id .. "-cache.lua") then
                pcall(delfile, script_id .. "-cache.lua")
            end
            getgenv().language = language == "english" and "" or language
            getgenv().parental_controls = parental_controls
            local a = game:HttpGet("https://api.luarmor.net/files/v3/loaders/" .. script_id .. ".lua")
            pcall(loadstring(a))
        end)
    end
})

sections.Misc:AddButton({
    enabled = true,
    text = "Bloodlines Script",
    flag = "Bloodlines_Script",
    tooltip = "Opens IAmJamal10 Script",
    risky = false,
    confirm = false,
    callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/IAmJamal10/Bloodlines/main/ScriptOP"))()
        end)
    end
})

local hitboxTransparency = 0.96

sections.ESPSection:AddSlider({
    text = "Hitbox Transparency",
    flag = "Transparency_Slider",
    suffix = "",
    value = 0.000,
    min = 0,
    max = 1,
    increment = 0.01,
    callback = function(v)
        hitboxTransparency = v
    end
})

local espCamera = workspace.CurrentCamera
local espMouse = player:GetMouse()
local black = Color3.fromRGB(0, 0, 0)
local espLibraries = {}

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0, 0)
    quad.PointB = Vector2.new(0, 0)
    quad.PointC = Vector2.new(0, 0)
    quad.PointD = Vector2.new(0, 0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewText(size, color)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = ""
    text.Size = size
    text.Color = color
    text.Outline = true
    text.Center = true
    text.Position = Vector2.new(0, 0)
    return text
end

local function SetVisibility(state, lib)
    for _, obj in pairs(lib) do
        pcall(function() obj.Visible = state end)
    end
end

local function RemoveESP(lib)
    for _, obj in pairs(lib) do
        pcall(function() obj:Remove() end)
    end
end

local function CreateESP(plr)
    local lib = {
        blacktracer = NewLine(Settings.TracerThickness * 2, black),
        tracer = NewLine(Settings.TracerThickness, Settings.TracerColor),
        black = NewQuad(Settings.BoxThickness * 2, black),
        box = NewQuad(Settings.BoxThickness, Settings.BoxColor),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black),
        standLabel = NewText(13, Color3.fromRGB(255, 215, 0)),
    }

    espLibraries[plr] = lib

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not library.flags.ESP_Toggle then
            SetVisibility(false, lib)
            return
        end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if char and hum and hrp and head and hum.Health > 0 then
            local humPos, onScreen = espCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local headPos = espCamera:WorldToViewportPoint(head.Position)
                local distY = math.clamp(
                    (Vector2.new(headPos.X, headPos.Y) - Vector2.new(humPos.X, humPos.Y)).Magnitude,
                    2, math.huge
                )

                local function SizeQuad(item)
                    pcall(function()
                        item.PointA = Vector2.new(humPos.X + distY, humPos.Y - distY * 2)
                        item.PointB = Vector2.new(humPos.X - distY, humPos.Y - distY * 2)
                        item.PointC = Vector2.new(humPos.X - distY, humPos.Y + distY * 2)
                        item.PointD = Vector2.new(humPos.X + distY, humPos.Y + distY * 2)
                    end)
                end

                SizeQuad(lib.box)
                SizeQuad(lib.black)

                pcall(function()
                    if Settings.Tracers then
                        local origin
                        if Settings.FollowMouse then
                            origin = Vector2.new(espMouse.X, espMouse.Y + 36)
                        elseif Settings.TracerOrigin == "Middle" then
                            origin = espCamera.ViewportSize * 0.5
                        else
                            origin = Vector2.new(espCamera.ViewportSize.X * 0.5, espCamera.ViewportSize.Y)
                        end
                        lib.tracer.From = origin
                        lib.blacktracer.From = origin
                        lib.tracer.To = Vector2.new(humPos.X, humPos.Y + distY * 2)
                        lib.blacktracer.To = Vector2.new(humPos.X, humPos.Y + distY * 2)
                    else
                        lib.tracer.From = Vector2.new(0, 0)
                        lib.blacktracer.From = Vector2.new(0, 0)
                        lib.tracer.To = Vector2.new(0, 0)
                        lib.blacktracer.To = Vector2.new(0, 0)
                    end
                end)

                pcall(function()
                    local barHeight = (Vector2.new(humPos.X - distY, humPos.Y - distY * 2) - Vector2.new(humPos.X - distY, humPos.Y + distY * 2)).Magnitude
                    local healthOffset = hum.Health / hum.MaxHealth * barHeight
                    lib.greenhealth.From = Vector2.new(humPos.X - distY - 4, humPos.Y + distY * 2)
                    lib.greenhealth.To = Vector2.new(humPos.X - distY - 4, humPos.Y + distY * 2 - healthOffset)
                    lib.healthbar.From = Vector2.new(humPos.X - distY - 4, humPos.Y + distY * 2)
                    lib.healthbar.To = Vector2.new(humPos.X - distY - 4, humPos.Y - distY * 2)
                    lib.greenhealth.Color = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(0, 255, 0), hum.Health / hum.MaxHealth)
                end)

                pcall(function()
                    local isStandUser = plr:FindFirstChild("StandUser") ~= nil
                    lib.standLabel.Text = isStandUser and "[Stand User]" or "[No Stand]"
                    lib.standLabel.Color = isStandUser and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 180, 180)
                    lib.standLabel.Position = Vector2.new(humPos.X, humPos.Y - distY * 2 - 16)
                    lib.standLabel.Visible = true
                end)

                pcall(function()
                    if TeamSettings.Enabled then
                        local col = plr.TeamColor == player.TeamColor and TeamSettings.AllyColor or TeamSettings.EnemyColor
                        lib.tracer.Color = col
                        lib.box.Color = col
                    else
                        lib.tracer.Color = Settings.TracerColor
                        lib.box.Color = Settings.BoxColor
                    end
                end)

                SetVisibility(true, lib)
                lib.standLabel.Visible = true
            else
                SetVisibility(false, lib)
            end
        else
            SetVisibility(false, lib)
            if not Players:FindFirstChild(plr.Name) then
                pcall(function() connection:Disconnect() end)
                RemoveESP(lib)
                espLibraries[plr] = nil
            end
        end
    end)
end

sections.ESPSection:AddToggle({
    enabled = true,
    text = "Player ESP",
    flag = "ESP_Toggle",
    risky = false,
    callback = function(state)
        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and not espLibraries[plr] then
                    pcall(function() CreateESP(plr) end)
                end
            end
            connections.espAdded = Players.PlayerAdded:Connect(function(plr)
                pcall(function() CreateESP(plr) end)
            end)
            connections.espRemoved = Players.PlayerRemoving:Connect(function(plr)
                if espLibraries[plr] then
                    RemoveESP(espLibraries[plr])
                    espLibraries[plr] = nil
                end
            end)
        else
            if connections.espAdded then pcall(function() connections.espAdded:Disconnect() end); connections.espAdded = nil end
            if connections.espRemoved then pcall(function() connections.espRemoved:Disconnect() end); connections.espRemoved = nil end
            for plr, lib in pairs(espLibraries) do
                RemoveESP(lib)
                espLibraries[plr] = nil
            end
        end
    end
})

local toolESPLabels = {}
local toolESPConnection = nil

sections.ESPSection:AddToggle({
    enabled = true,
    text = "Tool ESP",
    flag = "ToolESP_Toggle",
    risky = false,
    callback = function(state)
        if state then
            toolESPConnection = RunService.RenderStepped:Connect(function()
                if not library.flags.ToolESP_Toggle then return end

                local seenTools = {}
                local charRoot = getRoot()

                pcall(function()
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Tool") and obj.Parent ~= nil and not obj.Parent:IsA("Backpack") and not obj.Parent:IsA("Model") then
                            local handle = obj:FindFirstChild("Handle")
                            if not handle then
                                for _, child in ipairs(obj:GetChildren()) do
                                    if child:IsA("BasePart") then handle = child break end
                                end
                            end
                            if not handle then continue end

                            local dist = charRoot and (charRoot.Position - handle.Position).Magnitude or math.huge
                            if dist > 1000 then
                                if toolESPLabels[obj] then
                                    pcall(function() toolESPLabels[obj].nameLabel:Remove() end)
                                    pcall(function() toolESPLabels[obj].distLabel:Remove() end)
                                    toolESPLabels[obj] = nil
                                end
                                continue
                            end

                            local pos, onScreen = espCamera:WorldToViewportPoint(handle.Position)
                            seenTools[obj] = true

                            if not toolESPLabels[obj] then
                                local nameLabel = NewText(14, Color3.fromRGB(255, 255, 255))
                                local distLabel = NewText(11, Color3.fromRGB(200, 200, 200))
                                toolESPLabels[obj] = { nameLabel = nameLabel, distLabel = distLabel }
                            end

                            local labels = toolESPLabels[obj]

                            if onScreen then
                                labels.nameLabel.Text = obj.Name
                                labels.nameLabel.Position = Vector2.new(pos.X, pos.Y - 10)
                                labels.nameLabel.Visible = true

                                labels.distLabel.Text = math.floor(dist) .. "m"
                                labels.distLabel.Position = Vector2.new(pos.X, pos.Y + 4)
                                labels.distLabel.Visible = true
                            else
                                labels.nameLabel.Visible = false
                                labels.distLabel.Visible = false
                            end
                        end
                    end
                end)

                for tool, labels in pairs(toolESPLabels) do
                    if not seenTools[tool] then
                        pcall(function() labels.nameLabel:Remove() end)
                        pcall(function() labels.distLabel:Remove() end)
                        toolESPLabels[tool] = nil
                    end
                end
            end)
        else
            if toolESPConnection then
                pcall(function() toolESPConnection:Disconnect() end)
                toolESPConnection = nil
            end
            for tool, labels in pairs(toolESPLabels) do
                pcall(function() labels.nameLabel:Remove() end)
                pcall(function() labels.distLabel:Remove() end)
            end
            toolESPLabels = {}
        end
    end
})

local HeightSlid = 1.473
local heightConnection = nil

sections.Combat:AddSlider({
    text = "Height Slider",
    flag = "Height",
    suffix = "CM",
    value = 1.473,
    min = 0.15,
    max = 5,
    increment = 0.001,
    callback = function(v)
        HeightSlid = v
        local char = getCharacter()
        if not char then
            library:SendNotification("Character not found!", 3, Color3.new(1, 0, 0))
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local baseHeight, baseDepth, baseWidth, baseHead = 1.473, 1.133, 1.133, 1.133
        local ratio = v / baseHeight

        pcall(function()
            if hum:FindFirstChild("BodyHeightScale") then
                safeFireServer(ValChange, hum.BodyHeightScale, v)
                if heightConnection then pcall(function() heightConnection:Disconnect() end) end
                heightConnection = hum.BodyHeightScale.Changed:Connect(function(value)
                    if math.abs(value - HeightSlid) > 0.001 then
                        local r = HeightSlid / baseHeight
                        safeFireServer(ValChange, hum.BodyHeightScale, HeightSlid)
                        safeFireServer(ValChange, hum.BodyDepthScale, baseDepth * r)
                        safeFireServer(ValChange, hum.BodyWidthScale, baseWidth * r)
                        safeFireServer(ValChange, hum.HeadScale, baseHead * r)
                    end
                end)
            end
            if hum:FindFirstChild("BodyDepthScale") then safeFireServer(ValChange, hum.BodyDepthScale, baseDepth * ratio) end
            if hum:FindFirstChild("BodyWidthScale") then safeFireServer(ValChange, hum.BodyWidthScale, baseWidth * ratio) end
            if hum:FindFirstChild("HeadScale") then safeFireServer(ValChange, hum.HeadScale, baseHead * ratio) end
        end)
    end
})

player.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")

    pcall(function()
        if humanoid:FindFirstChild("BodyHeightScale") then
            local baseHeight, baseDepth, baseWidth, baseHead = 1.473, 1.133, 1.133, 1.133
            local ratio = HeightSlid / baseHeight

            safeFireServer(ValChange, humanoid.BodyHeightScale, HeightSlid)
            safeFireServer(ValChange, humanoid.BodyDepthScale, baseDepth * ratio)
            safeFireServer(ValChange, humanoid.BodyWidthScale, baseWidth * ratio)
            safeFireServer(ValChange, humanoid.HeadScale, baseHead * ratio)

            if heightConnection then pcall(function() heightConnection:Disconnect() end) end
            heightConnection = humanoid.BodyHeightScale.Changed:Connect(function(value)
                if math.abs(value - HeightSlid) > 0.001 then
                    local r = HeightSlid / baseHeight
                    safeFireServer(ValChange, humanoid.BodyHeightScale, HeightSlid)
                    safeFireServer(ValChange, humanoid.BodyDepthScale, baseDepth * r)
                    safeFireServer(ValChange, humanoid.BodyWidthScale, baseWidth * r)
                    safeFireServer(ValChange, humanoid.HeadScale, baseHead * r)
                end
            end)
        end
    end)
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
                if not obj or obj.Name ~= "Hitbox" or not obj:IsA("BasePart") then return end
                pcall(function()
                    hitboxParts[obj] = {
                        Transparency = obj.Transparency,
                        Color = obj.Color,
                        Material = obj.Material
                    }
                    obj.Transparency = hitboxTransparency
                    obj.Color = Color3.new(1, 0, 0)
                    obj.Material = Enum.Material.Neon
                end)
            end

            pcall(function()
                connections.hitboxAddedWorkspace = workspace.ChildAdded:Connect(function(child)
                    if child and child.Name == "Hitbox" then styleHitbox(child) end
                end)

                local fxFolder = workspace:FindFirstChild("FX") or Instance.new("Folder")
                connections.hitboxAddedFX = fxFolder.ChildAdded:Connect(styleHitbox)

                for _, child in pairs(workspace:GetChildren()) do
                    if child.Name == "Hitbox" then styleHitbox(child) end
                end

                local fx = workspace:FindFirstChild("FX")
                if fx then
                    for _, child in pairs(fx:GetChildren()) do styleHitbox(child) end
                end
            end)
        else
            pcall(function()
                for part, properties in pairs(hitboxParts) do
                    if part and part:IsDescendantOf(workspace) then
                        part.Transparency = properties.Transparency
                        part.Color = properties.Color
                        part.Material = properties.Material
                    end
                end
                hitboxParts = {}
                if connections.hitboxAddedWorkspace then connections.hitboxAddedWorkspace:Disconnect() end
                if connections.hitboxAddedFX then connections.hitboxAddedFX:Disconnect() end
            end)
        end
    end
})

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")

    pcall(function() inventoryLocations[2] = newChar end)

    if walkspeedCheat then pcall(function() humanoid.WalkSpeed = currentWalkspeed end) end
    if jumppowerCheat then pcall(function() humanoid.JumpPower = currentJumppower end) end

    if infiniteJumpEnabled and not infiniteJumpConnection then
        pcall(function()
            infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = getCharacter()
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                        pcall(function() hum:ChangeState("Jumping") end)
                    end
                end
            end)
        end)
    end
end)

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
        StandDamageValue = currentStandDamage,
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
    if not isfile(SettingsFileName) then return false end
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
        if result.CustomSettings.WalkspeedValue then currentWalkspeed = result.CustomSettings.WalkspeedValue end
        if result.CustomSettings.JumppowerValue then currentJumppower = result.CustomSettings.JumppowerValue end
        if result.CustomSettings.HitboxTransparency then hitboxTransparency = result.CustomSettings.HitboxTransparency end
        if result.CustomSettings.StandDamageValue then currentStandDamage = result.CustomSettings.StandDamageValue end
        if result.CustomSettings.TrackedItems then getgenv().TrackedItems = result.CustomSettings.TrackedItems end
    end
    library:SendNotification("Settings loaded successfully!", 3, Color3.new(0, 1, 0))
    return true
end

local function EnableAutoExec()
    local scriptContent = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/CrankTo-p/somethingig/refs/heads/main/script.lua"))()'
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
        if not LoadSettings() then
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

sections.Settings:AddSeparator({ text = "Auto-Execute" })

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

sections.Settings:AddSeparator({ text = "Config Management" })

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
            StandDamageValue = currentStandDamage,
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
                if result.CustomSettings.WalkspeedValue then currentWalkspeed = result.CustomSettings.WalkspeedValue end
                if result.CustomSettings.JumppowerValue then currentJumppower = result.CustomSettings.JumppowerValue end
                if result.CustomSettings.HitboxTransparency then hitboxTransparency = result.CustomSettings.HitboxTransparency end
                if result.CustomSettings.StandDamageValue then currentStandDamage = result.CustomSettings.StandDamageValue end
                if result.CustomSettings.TrackedItems then getgenv().TrackedItems = result.CustomSettings.TrackedItems end
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
            local success = pcall(function() delfile(fileName) end)
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
            local success, files = pcall(function() return listfiles(".") end)
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
    if isfile(SettingsFileName) then LoadSettings() end
end)

pcall(function()
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == library.ScreenGui.Name then
            if library.flags.Auto_Save_Toggle then SaveSettings() end
        end
    end)
end)

pcall(function()
    game.Players.LocalPlayer.OnTeleport:Connect(function()
        if library.flags.Auto_Save_Toggle then SaveSettings() end
    end)
end)

sections.Combat:AddButton({
    enabled = true,
    text = "Stand God Mode",
    flag = "Stand_God_Button",
    tooltip = "Sets stand damage protection to 0",
    risky = false,
    confirm = false,
    callback = function()
        local playerStand = getPlayerStand()
        if playerStand and playerStand:FindFirstChild("DamageProtection") then
            safeFireServer(ValChange, playerStand.DamageProtection, 0)
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
    tooltip = "Creates MirrorStandSeparator value for infinite range",
    risky = false,
    confirm = false,
    callback = function()
        local playerStand = getPlayerStand()
        if not playerStand then
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
            return
        end
        if playerStand:FindFirstChild("MirrorStandSeparator") then
            library:SendNotification("MirrorStandSeparator already exists!", 3, Color3.new(1, 1, 0))
            return
        end
        pcall(function()
            local intValue = Instance.new("IntValue")
            intValue.Name = "MirrorStandSeparator"
            intValue.Value = 0
            intValue.Parent = playerStand
        end)
        library:SendNotification("Infinite RC Range activated!", 3, Color3.new(0, 1, 0))
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
        local playerStand = getPlayerStand()
        if not playerStand then
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
            return
        end
        if playerStand:FindFirstChild("SteamForm") then
            library:SendNotification("SteamForm already exists!", 3, Color3.new(1, 1, 0))
            return
        end
        pcall(function()
            local intValue = Instance.new("IntValue")
            intValue.Name = "SteamForm"
            intValue.Value = 0
            intValue.Parent = playerStand
        end)
        library:SendNotification("Stand is now Aerial!", 3, Color3.new(0, 1, 0))
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
        local playerStand = getPlayerStand()
        if not playerStand or not playerStand:FindFirstChild("Attributes") then
            library:SendNotification("Stand or Attributes not found!", 3, Color3.new(1, 0, 0))
            return
        end
        pcall(function()
            local atts = playerStand.Attributes
            local Electricity = Instance.new("NumberValue", atts)
            local Liquid = Instance.new("NumberValue", atts)
            local TowerSpeed = Instance.new("NumberValue", atts)
            Electricity.Name = "Electricity"
            Electricity.Value = 10000
            Liquid.Name = "Liquid"
            Liquid.Value = 10000
            TowerSpeed.Name = "TowerSpeed"
            if game.Lighting:FindFirstChild("Raining") then
                game.Lighting.Raining.Value = true
            end
        end)
        library:SendNotification("Stand speed maximized!", 3, Color3.new(0, 1, 0))
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
        local char = getCharacter()
        local status = char and char:FindFirstChild("Status")
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
            local item = status:FindFirstChild(debuff)
            if item then
                pcall(function() item:Destroy() end)
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
    tooltip = "Locks stand in current position (toggle)",
    risky = false,
    confirm = false,
    callback = function()
        local playerStand = getPlayerStand()
        if not playerStand or not playerStand:FindFirstChild("HumanoidRootPart") then
            library:SendNotification("Stand not found!", 3, Color3.new(1, 0, 0))
            return
        end
        local standRoot = playerStand.HumanoidRootPart
        pcall(function()
            if standRoot:FindFirstChild("FreezePosition") then
                standRoot.FreezePosition:Destroy()
                library:SendNotification("Stand position unfrozen!", 3, Color3.new(1, 1, 0))
            else
                local bodyPos = Instance.new("BodyPosition")
                bodyPos.Name = "FreezePosition"
                bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyPos.Position = standRoot.Position
                bodyPos.Parent = standRoot
                library:SendNotification("Stand position frozen!", 3, Color3.new(0, 1, 0))
            end
        end)
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
        local playerStand = getPlayerStand()
        local char = getCharacter()
        local charRoot = char and char:FindFirstChild("HumanoidRootPart")
        if playerStand and playerStand:FindFirstChild("HumanoidRootPart") and charRoot then
            pcall(function()
                playerStand.HumanoidRootPart.CFrame = charRoot.CFrame
            end)
            library:SendNotification("Stand teleported to you!", 3, Color3.new(0, 1, 0))
        else
            library:SendNotification("Stand or character root not found!", 3, Color3.new(1, 0, 0))
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
                if not tool or not tool:IsA("Tool") then return end
                local ammo = tool:FindFirstChild("Ammo")
                if not ammo then return end
                pcall(function()
                    safeFireServer(ValChange, ammo, 6)
                    local ammoConn = ammo.Changed:Connect(function(value)
                        if library.flags.InfiniteAmmo_Toggle and value < 6 then
                            safeFireServer(ValChange, ammo, 6)
                        end
                    end)
                    ammoConnections[tool] = ammoConn
                    tool.AncestryChanged:Connect(function()
                        if not tool:IsDescendantOf(workspace) and ammoConnections[tool] then
                            pcall(function() ammoConnections[tool]:Disconnect() end)
                            ammoConnections[tool] = nil
                        end
                    end)
                end)
            end

            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do handleTool(tool) end
                pcall(function()
                    connections.infiniteAmmo = char.ChildAdded:Connect(handleTool)
                end)
            end
        else
            if connections.infiniteAmmo then
                pcall(function() connections.infiniteAmmo:Disconnect() end)
                connections.infiniteAmmo = nil
            end
            for tool, conn in pairs(ammoConnections) do
                pcall(function() conn:Disconnect() end)
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
local timestopWalkConnection = nil

sections.Misc:AddToggle({
    enabled = true,
    text = "Walk in Timestop",
    flag = "TimestopWalk_Toggle",
    tooltip = "Allows movement while timestopped",
    risky = true,
    callback = function(state)
        if state then
            timestopWalkConnection = RunService.Heartbeat:Connect(function()
                if not library.flags.TimestopWalk_Toggle then return end
                local char = getCharacter()
                if not char then return end
                local status = char:FindFirstChild("Status")
                if not status then return end
                if not status:FindFirstChild("Timestop") then return end

                pcall(function()
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Anchored then
                            part.Anchored = false
                        end
                    end

                    local r = getRoot()
                    local hum = getHumanoid()
                    if r and hum then
                        if hum.WalkSpeed < 1 then
                            hum.WalkSpeed = walkspeedCheat and currentWalkspeed or 16
                        end
                        local bv = r:FindFirstChildWhichIsA("BodyVelocity")
                        if bv then
                            local currentVel = bv.Velocity
                            if currentVel.Magnitude < 0.5 and hum.MoveDirection.Magnitude > 0 then
                                bv.Velocity = hum.MoveDirection * (walkspeedCheat and currentWalkspeed or 16)
                            end
                        end
                    end
                end)
            end)
        else
            if timestopWalkConnection then
                pcall(function() timestopWalkConnection:Disconnect() end)
                timestopWalkConnection = nil
            end
        end
    end
})

sections.Misc:AddToggle({
    enabled = true,
    text = "Moderator Detector",
    flag = "ModDetector",
    tooltip = "Notifies when a moderator joins",
    risky = false,
    callback = function(state)
        if state then
            pcall(function()
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
            end)
        else
            if modDetectorConnection then
                pcall(function() modDetectorConnection:Disconnect() end)
                modDetectorConnection = nil
            end
        end
    end
})

local modKickConnection = nil

sections.Misc:AddToggle({
    enabled = true,
    text = "Moderator Detector Kick",
    flag = "ModDetectorKick",
    tooltip = "Automatically kicks you when a moderator is detected",
    risky = true,
    callback = function(state)
        if state then
            pcall(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if table.find(moderatorIds, plr.UserId) then
                        if LocalPlayer:FindFirstChild("CombatTag") then
                            local Timer = LocalPlayer.CombatTag:WaitForChild("Timer", 2)
                            if Timer then
                                safeFireServer(ValChange, Timer, 0)
                                task.wait(0.5)
                            end
                        end
                        LocalPlayer:Kick("⚠️ MODERATOR DETECTED: " .. plr.Name .. " - Auto-kicked for safety")
                        return
                    end
                end
                modKickConnection = Players.PlayerAdded:Connect(function(plr)
                    if table.find(moderatorIds, plr.UserId) then
                        library:SendNotification("⚠️ MODERATOR DETECTED - KICKING!", 3, Color3.new(1, 0, 0))
                        if LocalPlayer:FindFirstChild("CombatTag") then
                            local Timer = LocalPlayer.CombatTag:WaitForChild("Timer", 2)
                            if Timer then
                                safeFireServer(ValChange, Timer, 0)
                                task.wait(0.5)
                            end
                        end
                        LocalPlayer:Kick("⚠️ MODERATOR DETECTED: " .. plr.Name .. " - Auto-kicked for safety")
                    end
                end)
            end)
        else
            if modKickConnection then
                pcall(function() modKickConnection:Disconnect() end)
                modKickConnection = nil
            end
        end
    end
})

library:SendNotification("Made by Zik $20 dm me Zikiouh for full script", 5, Color3.new(1, 0, 0))
