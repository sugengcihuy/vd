_G.FriendColor = Color3.fromRGB(0, 255, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.SCPColor = Color3.fromRGB(170, 0, 255)
_G.GenColor = Color3.fromRGB(255, 220, 0)
_G.AimPart = "Torso"
_G.BaseOffset = 0.45
_G.SurvivorOffset = 0.50 -- Presisi tengah dada (tidak meleset saat bergerak)
_G.UniversalOffset = 1.25 -- Tinggi dada/kepala
_G.VeilOffset = 0.60
_G.WeaponModelName = "Twist of Fate"
_G.AutoAimSmoothness = 0.25
_G.FiringSmoothness = 0.95
_G.AutoAimFOV = 250
_G.AutoAimMode = "OnADS"
_G.WallCheck = false
_G.VeilWallCheck = false
_G.ShowFOVCircle = false
_G.AutoPrediction = false
_G.ShowGenerators = false
_G.AutoSkillCheck = false
_G.ModeTerang = false
_G.FullbrightBrightness = 2.0
_G.CameraFOV = 70.0
_G.AutoParry = false
_G.ParryMaxDistance = 11
_G.MaxFacingAngleDot = 0.20
_G.MinWeaponSwingSpeed = 8.0
_G.ParryDaggerInGameCooldown = 60.0

local Keybinds = {
    ESP = Enum.KeyCode.Z,
    ShowFriends = Enum.KeyCode.C,
    ShowEnemies = Enum.KeyCode.X,
    AutoAim = Enum.KeyCode.V,
    VeilAim = Enum.KeyCode.B,
    UniversalAim = Enum.KeyCode.N,
    ShowGenerators = Enum.KeyCode.G,
    AutoSkillCheck = Enum.KeyCode.H,
    ModeTerang = Enum.KeyCode.J,
    AutoParry = Enum.KeyCode.K,
    WallCheck = Enum.KeyCode.L,
}

local ESPEnabled = false
local ShowFriends = false
local ShowEnemies = false
local AutoAimEnabled = false
local VeilAimEnabled = false
local UniversalAimEnabled = false 
local UIVisible = true
local ScriptRunning = true
local HasAppliedModeTerang = false
local LastParryTime = 0
local CurrentParryCooldownDuration = 60.0
local TriggeredAnimCache = {}
local isLMBPressed = false
local lmbHoldStartTime = 0
local VeilLockedTarget = nil
local VeilLockedPart = nil
local isMobileM2Held = false
local isMobileLMBHeld = false
local isMobileADSHeld = false
local MobileControlsConns = {}

local RangedBlacklistAnimIds = {
    -- Killer 1
    ["125224839697689"] = true,
    -- Killer 2
    ["126497551689502"] = true, -- WipeMachete
    ["76744850905644"] = true,
    ["74532620598483"] = true,
    -- Killer 3
    ["126626340093785"] = true, -- WipeMachete
    ["117886494230451"] = true, -- corrupt
    -- Killer 4 (Veil Spear)
    ["75258958842388"] = true,  -- takeoutspear1
    ["92098503722633"] = true,  -- spearlunge1
    ["138045669415653"] = true, -- spearlunge1op
    ["93136435416899"] = true,  -- spearthrow1
    ["84093948968516"] = true,  -- spearlunge2
    ["86266790353635"] = true,  -- spearthrow2
    ["119752564209631"] = true, -- WipeMachete
    -- Killer 5 (Mask Slasher)
    ["92125118598365"] = true,
    ["117187218825161"] = true, -- Tony
    ["79935565590141"] = true,  -- Richard
    ["92362656727126"] = true,  -- Cobra
    ["109402730355822"] = true,  -- Alex
    -- Killer 6 (Alchemist / Flask)
    ["121108316060822"] = true, -- flaskcharge
    ["99210996402874"] = true,  -- flaskthrow
    ["137795837089724"] = true, -- WipeMachete
    -- Killer 7 (Killer Lompat)
    ["109928123357793"] = true, -- Skill Lompat
    ["73681849513551"] = true,  -- WipeMachete
    ["102055678391920"] = true, -- StunAnimation
    ["98163597193511"] = true,  -- Dash Animation
    -- General / Misc / Vaults & Actions
    ["134758728973154"] = true, -- Skill Topeng
    ["111223305405046"] = true, -- Hook Animation / Dash Start
    ["102746205979822"] = true, -- Carry Animation
    ["82666958311998"] = true,  -- lempar botol
    -- Captured Vaults & Actions
    ["72908958549833"] = true,  -- Survivor Vault
    ["126081405469607"] = true, -- Fast Vault
    ["136962284480779"] = true, -- Vault End
    ["107600098059627"] = true, -- Vault Slide
    ["115156433745401"] = true, -- Unhooking
    ["118019257172845"] = true, -- Sliding 1
    ["126751859125353"] = true, -- Sliding 2
    ["135181748009911"] = true, -- Break Pallet 1
    ["135403091566760"] = true, -- Break Pallet 2
    ["82600868380136"] = true,  -- Healing
    ["109133187196613"] = true, -- Dagger Parry 1
    ["127096285501517"] = true, -- Dagger Parry 2
    ["89185525343404"] = true,  -- Slowdown Injured
    ["85030641905220"] = true,  -- Killer Skill
}

local KnownAttackAnimIds = {
    -- Killer 2
    ["117042998468241"] = true, -- lungehold
    ["133963973694098"] = true, -- attack
    -- Killer 3
    ["78432063483146"] = true,  -- attack
    ["118907603246885"] = true, -- lungehold
    ["80411309607666"] = true,  -- slash
    -- Killer 4
    ["122812055447896"] = true, -- lungehold
    ["78935059863801"] = true,  -- attack
    -- Killer 5
    ["138720291317243"] = true, -- attacktony
    ["111920872708571"] = true, -- attack
    ["105374834496520"] = true, -- lungehold
    ["115244153053858"] = true, -- lungeholdcobra
    ["130593238885843"] = true, -- attackcobra
    ["117070354890871"] = true, -- lungeholdalex
    ["106871536134254"] = true, -- attackalex
    -- Killer 6
    ["135002183282873"] = true, -- lungehold
    ["121216847022485"] = true, -- attack
    -- Killer 7 (Killer Lompat)
    ["74968262036854"] = true,  -- attack
    ["113255068724446"] = true, -- lungehold
    -- Misc / Defaults
    ["133002120549396"] = true,
    ["129784271201071"] = true,
    ["124706657239027"] = true,
    ["132817836308238"] = true,
    ["104682704142865"] = true,
}

local RangedBlacklistKeywords = {
    "throw", "spear", "trap", "flask", "bottle", "chemical", "acid", "potion",
    "grab", "jambak", "corrupt", "lakemist", "pursuit", "maskon", "leap", "inject", "corpse",
    "vault", "climb", "window", "pallet", "interact", "stun", "emote", "search", "kick", "repair", "unhook", "pickup", "carry"
}

local function ContainsRangedKeyword(str)
    if not str or str == "" then return false end
    local lowerStr = string.lower(str)
    for _, kw in ipairs(RangedBlacklistKeywords) do
        if string.find(lowerStr, kw) then
            return true
        end
    end
    return false
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager")
local StatsService = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Connections = {}
local ActiveHighlights = {}
local GenHighlights = {}
local KnownSCPs = {}
local SCPConnections = {}
local CurrentTarget = nil
local LockedTarget = nil
local LockedPart = nil
local WindowInstance = nil

local lmbHoldStartTime = 0
local isLMBPressed = false

-- WindUI Library Loader
local WindUI = nil
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUI then
    pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
    end)
end

-- cleanup logic
_G.SugengVDCleanup = function()
    ScriptRunning = false
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
    for target, hl in pairs(ActiveHighlights) do pcall(function() hl:Destroy() end) end
    for gen, hl in pairs(GenHighlights) do pcall(function() hl:Destroy() end) end
    ActiveHighlights = {}
    GenHighlights = {}
    pcall(function() Holder:Destroy() end)
    pcall(function() local gui = game.CoreGui:FindFirstChild("ESPGui"); if gui then gui:Destroy() end end)
    pcall(function() local gui = game.CoreGui:FindFirstChild("CrosshairGui"); if gui then gui:Destroy() end end)
    if WindowInstance and WindowInstance.Destroy then
        pcall(function() WindowInstance:Destroy() end)
    end
    if ClearMobileControlHooks then
        pcall(ClearMobileControlHooks)
    end
    pcall(function()
        if Camera then Camera.FieldOfView = 70.0 end
    end)
    print("Cleanup Completed")
end

local function GetPlayerRole(player)
    if not player then return "NONE" end
    if player.Team then
        local teamName = string.lower(player.Team.Name)
        if string.find(teamName, "killer") or string.find(teamName, "monster") or string.find(teamName, "slasher") or string.find(teamName, "zombie") or string.find(teamName, "infected") then
            return "KILLER"
        elseif string.find(teamName, "survivor") then
            return "SURVIVOR"
        elseif string.find(teamName, "spectator") or string.find(teamName, "lobby") or string.find(teamName, "waiting") then
            return "SPECTATOR"
        end
    end
    
    if player.Character then
        local char = player.Character
        if char:GetAttribute("IsZombie") == true or char:GetAttribute("Infected") == true or char:GetAttribute("CorpseCreated0492") == true or char:GetAttribute("IsInfected") == true or char:GetAttribute("IsKiller") == true then
            return "KILLER"
        end
        local weaponKeywords = {"weapon", "spear", "hidden", "knife", "blade", "staff", "sword", "scythe", "axe", "hammer", "saw", "club", "bat", "machete", "dagger", "chainsaw", "claw", "pipe", "sickle", "cleaver", "katana"}
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Model") or child:IsA("Tool") then
                local cName = string.lower(child.Name)
                for _, kw in ipairs(weaponKeywords) do
                    if string.find(cName, kw) then return "KILLER" end
                end
            end
        end
    end
    return "SURVIVOR"
end

local function CleanLightingEffects()
    if not ScriptRunning or not _G.ModeTerang then return end
    pcall(function()
        for _, child in pairs(Lighting:GetChildren()) do
            local cType = child.ClassName
            local cName = string.lower(child.Name)
            local isSkyOrSun = (cType == "Sky" or cType == "SunRaysEffect" or cType == "Clouds" or 
                                string.find(cName, "sky") or string.find(cName, "sunray") or string.find(cName, "sun_ray"))
            if not isSkyOrSun then
                pcall(function() child:Destroy() end)
            end
        end
    end)
end

local function ApplyModeTerangInGame()
    if not ScriptRunning or not _G.ModeTerang then return end
    pcall(function()
        local targetBrightness = _G.FullbrightBrightness or 2.0
        if Lighting.Brightness ~= targetBrightness then Lighting.Brightness = targetBrightness end
        if Lighting.ClockTime ~= 14 then Lighting.ClockTime = 14 end
        if Lighting.FogEnd ~= 100000 then Lighting.FogEnd = 100000 end
        if Lighting.GlobalShadows ~= false then Lighting.GlobalShadows = false end
        if Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then Lighting.Ambient = Color3.fromRGB(255, 255, 255) end
        if Lighting.OutdoorAmbient ~= Color3.fromRGB(255, 255, 255) then Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) end
    end)
end

-- lightning clean
local modeTerangHeartbeatConn = RunService.Heartbeat:Connect(function()
    if ScriptRunning and _G.ModeTerang then
        ApplyModeTerangInGame()
    end
end)
table.insert(Connections, modeTerangHeartbeatConn)

-- Camera FOV Real-time Enforcement
local cameraFovConn = RunService.RenderStepped:Connect(function()
    if ScriptRunning then
        local targetFOV = _G.CameraFOV or 70.0
        if Camera and Camera.FieldOfView ~= targetFOV then
            Camera.FieldOfView = targetFOV
        end
    end
end)
table.insert(Connections, cameraFovConn)

-- delete lightning
local lightingChildConn = Lighting.ChildAdded:Connect(function()
    if ScriptRunning and _G.ModeTerang then
        task.wait()
        CleanLightingEffects()
    end
end)
table.insert(Connections, lightingChildConn)

-- cooldown parry
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local pFolder = items and items:FindFirstChild("Parrying Dagger")

    if pFolder then
        local resultRemote = pFolder:FindFirstChild("parryResult")
        if resultRemote and resultRemote:IsA("RemoteEvent") then
            local rConn = resultRemote.OnClientEvent:Connect(function(success, cooldown)
                local cdVal = tonumber(cooldown) or (success and 60.0 or 0.0)
                CooldownEndTime = tick() + cdVal
                print("[parry] Success: " .. tostring(success) .. " | Cooldown Sisa: " .. string.format("%.1f", cdVal) .. "s")
            end)
            table.insert(Connections, rConn)
        end
    end
end)



local function IsLocalPlayerBusy()
    local myChar = LocalPlayer.Character
    if not myChar then return true end

    if LocalPlayer:GetAttribute("IsDead") == true or 
       myChar:GetAttribute("IsCarried") == true or 
       myChar:GetAttribute("IsHooked") == true or 
       myChar:GetAttribute("IsDowned") == true or
       myChar:GetAttribute("Disabled") == true or
       myChar:GetAttribute("Dying") == true then
        return true
    end

    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then
        return true
    end

    -- 🛡️ PENGECEKAN ATRIBUT VAULT / PALLET SURVIVOR
    if myChar:GetAttribute("isvaulting") == true or 
       myChar:GetAttribute("isVaulting") == true or 
       myChar:GetAttribute("isDroppingPallet") == true or
       myChar:GetAttribute("isSliding") == true or
       myChar:GetAttribute("isRepairing") == true then
        return true
    end

    local checkInterractable = myChar:FindFirstChild("CheckInterractable")
    if checkInterractable then
        if checkInterractable:GetAttribute("isVaulting") == true or 
           checkInterractable:GetAttribute("isDroppingPallet") == true or 
           checkInterractable:GetAttribute("isvaulting") == true or
           checkInterractable:GetAttribute("isSliding") == true then
            return true
        end
    end

    -- 🛡️ PENGECEKAN ANIMASI SURVIVOR TANPA BATASAN PRIORITY (Memeriksa Semua Frame Vault/Pallet/Slide)
    local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum)
    if animator then
        local isBusyAnim = false
        pcall(function()
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local animName = string.lower(track.Animation and track.Animation.Name or "")
                local rawId = track.Animation and track.Animation.AnimationId or ""
                local numId = string.match(rawId, "%d+") or ""

                -- ID Animasi Vault / Pallet / Slide Survivor
                if numId == "72908958549833" or numId == "126081405469607" or numId == "136962284480779" or 
                   numId == "107600098059627" or numId == "118019257172845" or numId == "126751859125353" then
                    isBusyAnim = true
                    return
                end

                if (string.find(animName, "vault") or string.find(animName, "pallet") or string.find(animName, "slide") or string.find(animName, "drop")) and 
                   not string.find(animName, "idle") and not string.find(animName, "hold") and 
                   not string.find(animName, "run") and not string.find(animName, "walk") then
                    isBusyAnim = true
                    return
                end
            end
        end)
        if isBusyAnim then return true end
    end

    return false
end

local function IsKillerBusy(killerChar)
    if not killerChar then return true end

    local khum = killerChar:FindFirstChildOfClass("Humanoid")
    if khum then
        local state = khum:GetState()
        if state == Enum.HumanoidStateType.Climbing or
           state == Enum.HumanoidStateType.FallingDown or
           state == Enum.HumanoidStateType.Freefall or
           state == Enum.HumanoidStateType.Jumping or
           state == Enum.HumanoidStateType.PlatformStanding or
           state == Enum.HumanoidStateType.Physics then
            return true
        end
    end

    if killerChar:GetAttribute("isvaulting") == true or
       killerChar:GetAttribute("isVaulting") == true or
       killerChar:GetAttribute("isBreakingPallet") == true or
       killerChar:GetAttribute("isBreakingGen") == true or
       killerChar:GetAttribute("IsCarrying") == true or
       killerChar:GetAttribute("Immobile") == true or
       killerChar:GetAttribute("LakeMist") == true or
       (killerChar:GetAttribute("CarriedSurvivorId") and killerChar:GetAttribute("CarriedSurvivorId") ~= 0) then
        return true
    end

    return false
end

local function IsKillerPlayingRangedSound(killerChar)
    if not killerChar then return false end
    for _, desc in pairs(killerChar:GetDescendants()) do
        if desc:IsA("Sound") and desc.IsPlaying then
            if ContainsRangedKeyword(desc.Name) then return true, desc.Name end
        end
    end
    return false, nil
end

local function GetServerPing()
    local ping = 0.035
    pcall(function()
        local stats = StatsService:FindFirstChild("Network")
        local serverStats = stats and stats:FindFirstChild("ServerStatsItem")
        local pingStat = serverStats and serverStats:FindFirstChild("Data Ping")
        if pingStat then
            ping = pingStat:GetValue() / 1000
        end
    end)
    return ping
end

local function IsKillerCharacter(char, player)
    if not char then return false end

    -- 🛑 RULE 1: JIKA SATU TIM DENGAN LOCALPLAYER -> FIX TEMAN SE-TIM (ABAIKAN TOTAL!)
    if player and LocalPlayer.Team and player.Team then
        if player.Team == LocalPlayer.Team then
            return false
        end
    end

    -- RULE 2: Cek Nama Tim Opponent
    if player and player.Team then
        local teamName = string.lower(player.Team.Name)
        if string.find(teamName, "killer") or string.find(teamName, "monster") or string.find(teamName, "slasher") or string.find(teamName, "beast") then
            return true
        end
    end

    -- RULE 3: Atribut Spesifik Killer
    if char:GetAttribute("IsKiller") == true or (player and player:GetAttribute("IsKiller") == true) or char:GetAttribute("Role") == "Killer" then
        return true
    end

    -- RULE 4: Nama Model / Character Killer
    local charName = string.lower(char.Name)
    if string.find(charName, "jason") or string.find(charName, "veil") or string.find(charName, "killer") or string.find(charName, "slasher") or string.find(charName, "monster") then
        return true
    end

    -- RULE 5: Folder Induk di Workspace
    if char.Parent and (string.lower(char.Parent.Name) == "killers" or string.lower(char.Parent.Name) == "killer") then
        return true
    end

    -- RULE 6: Fallback Player Beda Tim
    if player and player ~= LocalPlayer then
        if LocalPlayer.Team and player.Team and player.Team ~= LocalPlayer.Team then
            return true
        end
    end

    return false
end

local function FindKillerForParry()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    if not myHRP then return nil, nil, math.huge, nil, nil end

    local nearestChar, nearestName, nearestDist, nearestKHRP = nil, nil, math.huge, nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local kHRP = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            
            if hum and hum.Health > 0 and kHRP then
                if IsKillerCharacter(char, player) then
                    local dist = (myHRP.Position - kHRP.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestChar = char
                        nearestName = player.Name
                        nearestKHRP = kHRP
                    end
                end
            end
        end
    end

    if nearestChar then return nearestChar, nearestName, nearestDist, nearestKHRP, myHRP end
    return nil, nil, math.huge, nil, nil
end

local function CalculateDynamicTriggerDistance(kHRP)
    local baseDist = _G.ParryMaxDistance or 12.5
    if not kHRP then return baseDist end
    local velocity = kHRP.AssemblyLinearVelocity or kHRP.Velocity or Vector3.new(0,0,0)
    local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local pingBuffer = (_G.AutoPrediction and GetServerPing() or 0.035) * speed
    return baseDist + math.clamp((speed * 0.12) + pingBuffer, 0, 2.0)
end

local function FaceKillerInstant(kHRP)
    if not kHRP then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHRP then
        pcall(function()
            local targetPos = Vector3.new(kHRP.Position.X, myHRP.Position.Y, kHRP.Position.Z)
            myHRP.CFrame = CFrame.new(myHRP.Position, targetPos)
            if hum then
                hum.AutoRotate = false
                task.delay(0.18, function()
                    if hum and hum.Parent then
                        hum.AutoRotate = true
                    end
                end)
            end
        end)
    end
end

local function IsKillerFacingLocalPlayer(kHRP, myHRP)
    if not kHRP or not myHRP then return true end
    local dist = (myHRP.Position - kHRP.Position).Magnitude
    local lookVector = kHRP.CFrame.LookVector
    local dirToMe = (myHRP.Position - kHRP.Position).Unit

    if dist <= 6.5 then
        return lookVector:Dot(dirToMe) >= -0.35
    end

    return lookVector:Dot(dirToMe) >= 0.45
end

local CooldownEndTime = 0
local parryResultConnected = false

local function SetupParryResultListener()
    if parryResultConnected then return end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    local pFolder = items and items:FindFirstChild("Parrying Dagger")
    local resultRemote = pFolder and (pFolder:FindFirstChild("parryResult") or pFolder:FindFirstChild("ParryResult"))

    if resultRemote and resultRemote:IsA("RemoteEvent") then
        parryResultConnected = true
        local conn = resultRemote.OnClientEvent:Connect(function(success, serverCooldown)
            local cdVal = tonumber(serverCooldown) or 3.0
            CooldownEndTime = tick() + cdVal
            print(string.format("[AutoParry V12] 📬 Server Parry Result: Success=%s | Cooldown=%.1fs", tostring(success), cdVal))
        end)
        table.insert(Connections, conn)
    end
end

local function GetDaggerModelInCharacter()
    local char = LocalPlayer.Character
    if not char then return false end

    for _, child in pairs(char:GetChildren()) do
        local nameLower = string.lower(child.Name)
        if nameLower == "parrying dagger" or string.find(nameLower, "dagger") or string.find(nameLower, "sakuya") or child:FindFirstChild("parrying dagger") then
            return true
        end
        for _, subChild in pairs(child:GetChildren()) do
            local subNameLower = string.lower(subChild.Name)
            if string.find(subNameLower, "dagger") or string.find(subNameLower, "sakuya") or subNameLower == "sword" or subNameLower == "main" or subNameLower == "parrying dagger" then
                return true
            end
        end
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    if items and items:FindFirstChild("Parrying Dagger") then
        return true
    end

    return true
end

local function TriggerOfficialParry(reason, distance, kHRP)
    local now = tick()
    if now < CooldownEndTime then return end

    CooldownEndTime = now + 2.5
    TriggeredAnimCache = {}

    FaceKillerInstant(kHRP)

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local items = remotes and remotes:FindFirstChild("Items")
        local pFolder = items and items:FindFirstChild("Parrying Dagger")

        if pFolder then
            local parryRemote = pFolder:FindFirstChild("parry")
            if parryRemote and parryRemote:IsA("RemoteEvent") then
                parryRemote:FireServer()
            end
        end
    end)

    task.spawn(function()
        if not UserInputService.TouchEnabled and VirtualInputManager then
            pcall(function()
                local mPos = UserInputService:GetMouseLocation()
                VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 1, true, game, 1)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(mPos.X, mPos.Y, 1, false, game, 1)
            end)
        end
        -- Trigger tombol Gui-mob di Mobile (Survivor-mob.Control['Gui-mob'])
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local sMob = pGui and pGui:FindFirstChild("Survivor-mob")
            if sMob then
                local ctrl = sMob:FindFirstChild("Control") or sMob:FindFirstChild("Controls")
                local dBtn = ctrl and (ctrl:FindFirstChild("Gui-mob") or ctrl:FindFirstChild("gui-mob"))
                if not dBtn then
                    for _, d in ipairs(sMob:GetDescendants()) do
                        if (d:IsA("GuiButton") or d:IsA("ImageButton") or d:IsA("TextButton")) and string.lower(d.Name) == "gui-mob" then
                            dBtn = d
                            break
                        end
                    end
                end
                if dBtn then
                    if firesignal then
                        firesignal(dBtn.MouseButton1Down)
                        firesignal(dBtn.Activated)
                        firesignal(dBtn.MouseButton1Up)
                    elseif dBtn.MouseButton1Click then
                        dBtn.MouseButton1Click:Fire()
                    end
                end
            end
        end)
    end)
end

-- DATABASE ANIMASI SERANGAN M1 & M2 TERVERIFIKASI (STRICT WHITELIST)
local KnownAttackAnimIds = {
    -- 🪓 JASON ATTACKS (Bacok M1 & M2)
    ["110355011987939"] = true, [110355011987939] = true, -- Jason Bacok M1
    ["139369275981139"] = true, [139369275981139] = true, -- Jason Bacok Heavy M2
    
    -- 🗡️ VEIL ATTACKS (Nyucuk M1 Melee & Dash)
    ["122812055447896"] = true, [122812055447896] = true, -- Veil Nyucuk / Melee 1
    ["78935059863801"]  = true, [78935059863801]  = true, -- Veil Nyucuk / Melee 2

    -- 👻 THE HIDDEN DASH ATTACKS (Verified From Log)
    ["98163597193511"] = true, [98163597193511] = true, -- The Hidden Dash Skill 1
    ["73681849513551"] = true, [73681849513551] = true, -- The Hidden Dash Skill 2

    -- 🎭 THE MASKED / DUCK CHAINSAW DASH ATTACKS (Verified From Log)
    ["85030641905220"]  = true, [85030641905220]  = true, -- The Masked High Speed Dash (40.0 studs/s)
    ["91021650846272"]  = true, [91021650846272]  = true, -- The Masked Chainsaw Dash
    ["106871536134254"] = true, [106871536134254] = true,

    -- 👹 KILLERS LAINNYA (Terverifikasi)
    ["77210283630654"]  = true, ["78432063483146"]  = true, ["118907603246885"] = true,
    ["80411309607666"]  = true, ["138720291317243"] = true, ["111920872708571"] = true,
    ["105374834496520"] = true, ["115244153053858"] = true, ["130593238885843"] = true,
    ["117070354890871"] = true, ["135002183282873"] = true, ["121216847022485"] = true, 
    ["74968262036854"]  = true, ["113255068724446"] = true, ["133002120549396"] = true, 
    ["129784271201071"] = true, ["124706657239027"] = true, ["132817836308238"] = true, 
    ["117042998468241"] = true, ["133963973694098"] = true,
}

local LungeHoldAnimIds = {
    ["98163597193511"] = true, [98163597193511] = true, -- The Hidden Dash
    ["73681849513551"] = true, [73681849513551] = true, -- The Hidden Dash
    ["85030641905220"] = true, [85030641905220] = true, -- The Masked Dash
    ["117042998468241"] = true, [117042998468241] = true,
    ["118907603246885"] = true, [118907603246885] = true,
    ["122812055447896"] = true, [122812055447896] = true,
    ["105374834496520"] = true, [105374834496520] = true,
    ["115244153053858"] = true, [115244153053858] = true,
    ["117070354890871"] = true, [117070354890871] = true,
    ["135002183282873"] = true, [135002183282873] = true,
    ["113255068724446"] = true, [113255068724446] = true,
}

-- DATABASE ANIMASI BLACKLIST TERVERIFIKASI (VAULT & NON-ATTACK)
local BlacklistAnimIds = {
    -- 🛑 KILLER VAULTING (VERIFIED FROM LIVE LOG: 108211560927158)
    ["108211560927158"] = true, [108211560927158] = true, -- Killer Window Vault (1.50s)
    ["112633191985365"] = true, [112633191985365] = true, -- Killer Standard Vault
    ["119367394383893"] = true, [119367394383893] = true, -- Killer Walk/Chase Core (3.20s)
    ["134595759785108"] = true, [134595759785108] = true, -- Killer Idle Core (4.00s)
    ["111223305405046"] = true, [111223305405046] = true,
    ["102746205979822"] = true, [102746205979822] = true,
    ["131775987732809"] = true, [131775987732809] = true,
    ["110466971021611"] = true, [110466971021611] = true,

    -- 🛑 VEIL GANTI SENJATA & STANCE MODE
    ["96744338559260"]  = true, [96744338559260]  = true, -- Veil Ganti Senjata / Swap
    ["75258958842388"]  = true, [75258958842388]  = true, -- Veil Ganti Senjata / Stance
    ["92098503722633"]  = true, [92098503722633]  = true, -- Veil Stance Tombak
    ["109257644640676"] = true, [109257644640676] = true, -- Veil Spear Stance Mode (4.0s)
    ["138045669415653"] = true, [138045669415653] = true, -- Veil Lempar Tombak
    ["93136435416899"]  = true, [93136435416899]  = true, -- Veil Spear Charge
    ["139928639611415"] = true, [139928639611415] = true, -- Veil Ability Buff

    -- 🛑 JASON SKILL SPESIAL (Unparryable)
    ["125224839697689"] = true, [125224839697689] = true, -- Jason Special Skill
}

local function IsAnimBlacklisted(rawAnimId, animNumId)
    if BlacklistAnimIds[animNumId] or BlacklistAnimIds[tonumber(animNumId)] then
        return true
    end
    local strRaw = tostring(rawAnimId)
    for idKey, _ in pairs(BlacklistAnimIds) do
        if string.find(strRaw, tostring(idKey)) then
            return true
        end
    end
    return false
end

local AttackKeywords = {"attack", "slash", "swing", "hit", "lunge", "strike", "cut", "chop", "m1", "m2", "heavy", "light", "stab", "punch", "kill", "bacok", "nyucuk", "cleave"}
local LungeKeywords = {"lungehold", "prepare", "charge", "heavy_hold", "hold_attack"}
local NonAttackKeywords = {"vault", "pallet", "repair", "swap", "stance", "emote", "dance", "taunt", "break", "gen", "carry", "pickup", "drop", "hook", "stun", "blind", "climb", "jump", "window", "interact", "action", "clamber", "vaulting"}

local function ClassifyTrack(track, killerChar)
    if not track or not track.Animation then return false, false, "0" end

    local rawAnimId = track.Animation.AnimationId or ""
    local animNumId = string.match(rawAnimId, "%d+") or "0"
    local animName = string.lower(track.Animation.Name or "")

    -- 🛑 1. MULTI-TYPE BLACKLIST CHECK (Blocking Vault ID 108211560927158 100%)
    if IsAnimBlacklisted(rawAnimId, animNumId) then
        return false, false, animNumId
    end

    -- 🛑 2. NON-ATTACK KEYWORD CHECK
    for _, kw in ipairs(NonAttackKeywords) do
        if string.find(animName, kw) then
            return false, false, animNumId
        end
    end

    -- 🟢 3. STRICT WHITELIST CHECK
    local isKnown = (KnownAttackAnimIds[animNumId] == true or KnownAttackAnimIds[tonumber(animNumId)] == true)
    local isLungeHold = (LungeHoldAnimIds[animNumId] == true or LungeHoldAnimIds[tonumber(animNumId)] == true)

    for _, kw in ipairs(LungeKeywords) do
        if string.find(animName, kw) then
            isLungeHold = true
            break
        end
    end

    if isKnown then
        return true, isLungeHold, animNumId
    end

    -- 🛑 4. JIKA KILLER SEDANG BUSY -> ABAIKAN ANIMASI UNKNOWN
    if killerChar and IsKillerBusy(killerChar) then
        return false, false, animNumId
    end

    -- 🟡 5. CLASSIFIER UNTUK ANIMASI UNKNOWN
    local isAttackName = false
    for _, kw in ipairs(AttackKeywords) do
        if string.find(animName, kw) then
            isAttackName = true
            break
        end
    end

    if not isAttackName then
        return false, false, animNumId
    end

    local isMeleeLength = (track.Length > 0.05 and track.Length <= 2.2) or (track.Length == 0)
    if isAttackName and isMeleeLength and not track.Looped then
        return true, isLungeHold, animNumId
    end

    return false, false, animNumId
end

local function ProcessKillerPlayingTracks(killerChar, kHRP, dist)
    if tick() < CooldownEndTime then return end
    if not ScriptRunning or not _G.AutoParry or IsLocalPlayerBusy() or IsKillerBusy(killerChar) or not GetDaggerModelInCharacter() then return end

    local hum = killerChar:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local isAttack, isLungeHold, animId = ClassifyTrack(track, killerChar)
        if isAttack then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
            if myHRP and IsKillerFacingLocalPlayer(kHRP, myHRP) then
                local maxDist = CalculateDynamicTriggerDistance(kHRP)
                local allowedDist = isLungeHold and 8.0 or maxDist

                if dist <= allowedDist then
                    local reasonText = isLungeHold and ("LungeHold Polled Strike (" .. animId .. ")") or ("Polled Body Strike (" .. animId .. ")")
                    TriggerOfficialParry(reasonText, dist, kHRP)
                    break
                end
            end
        end
    end
end

local HookedAnimators = {}
local function AttachAnimationListener(animator, killerChar)
    if not animator or HookedAnimators[animator] then return end
    HookedAnimators[animator] = true

    local animConn = animator.AnimationPlayed:Connect(function(track)
        local now = tick()
        if now < CooldownEndTime then return end
        if not ScriptRunning or not _G.AutoParry or IsLocalPlayerBusy() then return end
        if not GetDaggerModelInCharacter() then return end

        local isAttack, isLungeHold, animId = ClassifyTrack(track, killerChar)
        if not isAttack then return end

        task.spawn(function()
            local startTime = tick()
            local maxMonitorDuration = isLungeHold and 0.45 or 0.25

            while tick() - startTime <= maxMonitorDuration do
                if tick() < CooldownEndTime then return end
                if not ScriptRunning or not _G.AutoParry or IsLocalPlayerBusy() then return end
                if not GetDaggerModelInCharacter() then return end

                local myChar = LocalPlayer.Character
                local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
                local kHRP = killerChar and (killerChar:FindFirstChild("HumanoidRootPart") or killerChar:FindFirstChild("Torso"))
                if not myHRP or not kHRP then return end

                if not IsKillerBusy(killerChar) and IsKillerFacingLocalPlayer(kHRP, myHRP) then
                    local maxDist = CalculateDynamicTriggerDistance(kHRP)
                    local dist = (myHRP.Position - kHRP.Position).Magnitude
                    local allowedDist = isLungeHold and 8.0 or maxDist

                    if dist <= allowedDist then
                        local reasonText = isLungeHold and ("LungeHold Strike (" .. animId .. ")") or ("Adaptive Body Strike (" .. animId .. ")")
                        TriggerOfficialParry(reasonText, dist, kHRP)
                        break
                    end
                end
                task.wait(0.015)
            end
        end)
    end)
    table.insert(Connections, animConn)
end

local function HookKillerAnimator(killerChar)
    if not killerChar or not ScriptRunning then return end
    
    local hum = killerChar:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        AttachAnimationListener(animator, killerChar)
    end
    
    for _, obj in ipairs(killerChar:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Tool") then
            local subAnim = obj:FindFirstChildOfClass("Animator") or (obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"))
            if subAnim then
                AttachAnimationListener(subAnim, killerChar)
            end
        end
    end
end

local autoParryConn = RunService.Heartbeat:Connect(function()
    if not ScriptRunning or not _G.AutoParry or IsLocalPlayerBusy() then return end
    SetupParryResultListener()
    local killerChar, killerName, dist, kHRP, myHRP = FindKillerForParry()
    if killerChar and dist <= (_G.ParryMaxDistance or 12.5) then
        HookKillerAnimator(killerChar)
        ProcessKillerPlayingTracks(killerChar, kHRP, dist)
    end
end)
table.insert(Connections, autoParryConn)

-- esp logic
local function RemoveESPFromTarget(target)
    if target and ActiveHighlights[target] then
        pcall(function() ActiveHighlights[target]:Destroy() end)
        ActiveHighlights[target] = nil
    end
end

local function ClearAllESPData()
    for target, _ in pairs(ActiveHighlights) do RemoveESPFromTarget(target) end
    for gen, hl in pairs(GenHighlights) do pcall(function() hl:Destroy() end) end
    ActiveHighlights, GenHighlights, KnownSCPs = {}, {}, {}
    for char, connTable in pairs(SCPConnections) do
        if connTable then for _, conn in pairs(connTable) do pcall(function() conn:Disconnect() end) end end
    end
    SCPConnections = {}
end

local function ClearSCPData(character)
    if not character then return end
    KnownSCPs[character] = nil
    RemoveESPFromTarget(character)
    if SCPConnections[character] then
        for _, conn in pairs(SCPConnections[character]) do pcall(function() conn:Disconnect() end) end
        SCPConnections[character] = nil
    end
end

local function GetAimPart(character)
    if not character then return nil end
    return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild(_G.AimPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

local function IsMoving(character, aimPart)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum and hum.MoveDirection.Magnitude > 0.1 then return true end
    if aimPart then
        local vel = aimPart.AssemblyLinearVelocity or aimPart.Velocity or Vector3.new(0,0,0)
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 0.1 then return true end
    end
    return false
end

local function IsSCP(character)
    if not character or not character:IsA("Model") or character == LocalPlayer.Character then return false end
    if character.Parent and (character.Parent.Name == "FakeCharacters" or character.Parent.Name == "Clones") then return false end
    
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then ClearSCPData(character); return false end
    if character:GetAttribute("IsDead") == true or character:GetAttribute("Dead") == true or character:GetAttribute("IsDowned") == true then
        ClearSCPData(character)
        return false
    end
    
    local aimPart = GetAimPart(character)
    if not aimPart then return false end
    
    local cName = string.lower(character.Name)
    local pName = character.Parent and string.lower(character.Parent.Name) or ""
    local isSCPName = string.find(cName, "scp") or string.find(pName, "scp") or 
                      string.find(cName, "zombie") or string.find(cName, "infected") or
                      string.find(cName, "ghoul") or string.find(cName, "minion") or
                      string.find(cName, "thrall") or string.find(cName, "revived") or
                      string.find(cName, "corpse") or string.find(cName, "049")

    if not isSCPName then return false end

    -- ESP zombie logic
    if not IsMoving(character, aimPart) then
        ClearSCPData(character)
        return false
    end

    KnownSCPs[character] = true
    if not SCPConnections[character] then
        SCPConnections[character] = {}
        table.insert(SCPConnections[character], hum.Died:Connect(function() ClearSCPData(character) end))
        table.insert(SCPConnections[character], hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then ClearSCPData(character) end
        end))
        table.insert(SCPConnections[character], character.AttributeChanged:Connect(function(attr)
            if attr == "CorpseCreated0492" or attr == "HighlightReadyAt" or attr == "IsDead" then
                if not IsSCP(character) then ClearSCPData(character) end
            end
        end))
        table.insert(SCPConnections[character], character.AncestryChanged:Connect(function(_, parent)
            if not parent then ClearSCPData(character) end
        end))
    end
    return true
end

local function IsEnemy(character)
    if not character or not character:IsA("Model") then return false, "NONE" end
    local player = Players:GetPlayerFromCharacter(character)
    if player == LocalPlayer or character == LocalPlayer.Character then return false, "NONE" end
    
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false, "NONE" end
    
    local myRole = GetPlayerRole(LocalPlayer)
    if myRole == "SPECTATOR" then return false, "SPECTATOR" end
    
    -- zombie char detect
    local isTargetZombie = character:GetAttribute("IsZombie") == true or 
                           character:GetAttribute("Infected") == true or 
                           character:GetAttribute("CorpseCreated0492") == true or 
                           character:GetAttribute("IsInfected") == true
    
    local targetRole = isTargetZombie and "KILLER" or (player and GetPlayerRole(player) or "NONE")
    
    if myRole == "SURVIVOR" or myRole == "NONE" then
        if IsSCP(character) or isTargetZombie then return true, "SCP" end
        if targetRole == "KILLER" then return true, "KILLER" end
        return false, "FRIEND_SURVIVOR"
    elseif myRole == "KILLER" then
        if IsSCP(character) or isTargetZombie then return false, "SCP_ALLY" end
        if targetRole == "SURVIVOR" or targetRole == "NONE" then return true, "SURVIVOR" end
    end
    return false, "NONE"
end

local function CreateHighlight(target, color)
    if not target then return end
    local existing = ActiveHighlights[target] or target:FindFirstChild("ESP_Highlight")
    if existing then
        if existing.FillColor ~= color then
            existing.FillColor = color
            existing.OutlineColor = color
        end
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = target
    highlight.FillColor = color
    highlight.FillTransparency = 1
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target
    ActiveHighlights[target] = highlight
end

local function RefreshGeneratorESP()
    if not ScriptRunning or not _G.ShowGenerators or GetPlayerRole(LocalPlayer) == "SPECTATOR" then
        for gen, hl in pairs(GenHighlights) do pcall(function() hl:Destroy() end) end
        GenHighlights = {}
        return
    end
    
    local validGens = {}
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            local dName = string.lower(descendant.Name)
            if descendant.Name == "Generator" or dName == "generator" or string.find(dName, "gen") then
                validGens[descendant] = true
                if not GenHighlights[descendant] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Gen_Highlight"
                    hl.Adornee = descendant
                    hl.FillColor = _G.GenColor
                    hl.FillTransparency = 1
                    hl.OutlineColor = _G.GenColor
                    hl.OutlineTransparency = 0.1
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = descendant
                    GenHighlights[descendant] = hl
                end
            end
        end
    end
    
    for gen, hl in pairs(GenHighlights) do
        if not validGens[gen] then pcall(function() hl:Destroy() end); GenHighlights[gen] = nil end
    end
end

local function RefreshAllESP()
    if not ScriptRunning or not ESPEnabled then ClearAllESPData(); return end
    local myRole = GetPlayerRole(LocalPlayer)
    if myRole == "SPECTATOR" then ClearAllESPData(); return end
    
    local amIKiller = (myRole == "KILLER")
    local validTargets = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local isEnemy = IsEnemy(char)
            if isEnemy and ShowEnemies then validTargets[char] = _G.EnemyColor
            elseif not isEnemy and ShowFriends then validTargets[char] = _G.FriendColor end
        end
    end
    
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and IsSCP(child) then
            if not amIKiller and ShowEnemies then validTargets[child] = _G.SCPColor
            elseif amIKiller and ShowFriends then validTargets[child] = _G.SCPColor end
        end
    end

    local scpContainers = {}
    if workspace:FindFirstChild("1") then table.insert(scpContainers, workspace["1"]) end
    if workspace:FindFirstChild("Map") then table.insert(scpContainers, workspace.Map) end

    for _, container in ipairs(scpContainers) do
        for _, descendant in ipairs(container:GetDescendants()) do
            if descendant:IsA("Model") and IsSCP(descendant) then
                if not amIKiller and ShowEnemies then validTargets[descendant] = _G.SCPColor
                elseif amIKiller and ShowFriends then validTargets[descendant] = _G.SCPColor end
            end
        end
    end
    
    for target, color in pairs(validTargets) do CreateHighlight(target, color) end
    for target, hl in pairs(ActiveHighlights) do
        if not validTargets[target] then RemoveESPFromTarget(target) end
    end
    RefreshGeneratorESP()
    ApplyModeTerangInGame()
end

task.spawn(function()
    while ScriptRunning do
        pcall(function()
            RefreshAllESP()
            if _G.ModeTerang then
                ApplyModeTerangInGame()
                CleanLightingEffects()
            end
        end)
        task.wait(1.5)
    end
end)

-- aimbot logic
local function FindEquippedTool()
    local character = LocalPlayer.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then return tool end
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then
                local cName = string.lower(child.Name)
                if string.find(cName, "twist") or string.find(cName, "fate") or string.find(cName, "spear") or 
                   string.find(cName, "weapon") or string.find(cName, "veil") or string.find(cName, "hidden") or 
                   string.find(cName, "blade") or string.find(cName, "scythe") or string.find(cName, "sword") or 
                   string.find(cName, "gun") or string.find(cName, "pistol") then
                    return child
                end
            end
        end
        for _, desc in pairs(character:GetDescendants()) do
            if desc:IsA("Tool") or (desc:IsA("Model") and desc.Parent == character) then
                local dName = string.lower(desc.Name)
                if string.find(dName, "twist") or string.find(dName, "fate") then
                    return desc
                end
            end
        end
    end
    return nil
end

local function IsValidStandingTarget(character)
    if not character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if character:GetAttribute("IsHooked") == true or character:GetAttribute("IsCarried") == true or character:GetAttribute("IsDowned") == true then
        return false
    end
    return true
end

local function IsTargetVisible(targetPart, character, ignoreWallCheck)
    if ignoreWallCheck then return true end
    if not _G.WallCheck then return true end
    local cameraPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = targetPos - cameraPos
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {LocalPlayer.Character, Holder}
    if character then table.insert(ignoreList, character) end
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true
    
    return workspace:Raycast(cameraPos, direction, raycastParams) == nil
end

local function GetTargetVelocity(character, part)
    if not character then return Vector3.new(0,0,0) end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum and hum.MoveDirection.Magnitude > 0.05 then return hum.MoveDirection * hum.WalkSpeed end
    if part then
        local vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.new(0,0,0)
        if vel.Magnitude > 0.1 then return vel end
    end
    return Vector3.new(0,0,0)
end

local function GetBestTarget(isVeilMode, ignoreFOV)
    local bestTarget, bestPart = nil, nil
    local bestScore = math.huge
    local cameraPos = Camera.CFrame.Position
    local amIKiller = (GetPlayerRole(LocalPlayer) == "KILLER")
    local candidates = {}
    
    -- Titik acuan bidikan (Pada Mobile / saat tombol ADS/M2 ditekan, gunakan titik tengah layar / crosshair)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local mousePos = UserInputService:GetMouseLocation()
    local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local aimReferencePoint = (isMobileDevice or isMobileADSHeld or isMobileM2Held) and screenCenter or mousePos
    
    if not amIKiller then
        local scpSearchList = {}
        for _, child in ipairs(workspace:GetChildren()) do table.insert(scpSearchList, child) end
        if workspace:FindFirstChild("1") then
            for _, descendant in ipairs(workspace["1"]:GetDescendants()) do
                if descendant:IsA("Model") then table.insert(scpSearchList, descendant) end
            end
        end
        if workspace:FindFirstChild("Map") then
            for _, descendant in ipairs(workspace.Map:GetDescendants()) do
                if descendant:IsA("Model") then table.insert(scpSearchList, descendant) end
            end
        end

        local scannedSCPs = {}
        for _, obj in ipairs(scpSearchList) do
            if obj:IsA("Model") and not scannedSCPs[obj] then
                scannedSCPs[obj] = true
                if IsSCP(obj) and IsValidStandingTarget(obj) then
                    local aimPart = GetAimPart(obj)
                    if aimPart then table.insert(candidates, {character = obj, part = aimPart}) end
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if IsEnemy(character) and IsValidStandingTarget(character) then
                local aimPart = GetAimPart(character)
                if aimPart then table.insert(candidates, {character = character, part = aimPart}) end
            end
        end
    end
    
    local ignoreWall = isVeilMode and (not _G.VeilWallCheck)
    for _, candidate in ipairs(candidates) do
        local aimPart = candidate.part
        local targetPos = aimPart.Position + Vector3.new(0, _G.BaseOffset or 0.45, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local screenVec = Vector2.new(screenPos.X, screenPos.Y)
            local mouseDist = (screenVec - aimReferencePoint).Magnitude
            
            local passesFOV = ignoreFOV or (mouseDist <= (_G.AutoAimFOV or 250))
            if passesFOV and IsTargetVisible(aimPart, candidate.character, ignoreWall) then
                local score = mouseDist + ((aimPart.Position - cameraPos).Magnitude * 0.25)
                if score < bestScore then
                    bestScore = score
                    bestTarget = candidate.character
                    bestPart = aimPart
                end
            end
        end
    end
    
    LockedTarget = bestTarget
    LockedPart = bestPart
    return bestTarget, bestPart
end

-- =========================================================================
-- 📱 MOBILE CONTROLS HOOK (THE HIDDEN M2 LEAP, KILLER DASH, WEAPON ADS)
-- =========================================================================
local function ClearMobileControlHooks()
    for _, conn in ipairs(MobileControlsConns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(MobileControlsConns)
    isMobileM2Held = false
    isMobileLMBHeld = false
    isMobileADSHeld = false
end

local function ResolveButton(parent, name)
    if not parent then return nil end
    local item = parent:FindFirstChild(name) or parent:FindFirstChild(string.lower(name)) or parent:FindFirstChild(string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2))
    if item then
        if item:IsA("GuiButton") or item:IsA("ImageButton") or item:IsA("TextButton") then
            return item
        end
        local child = item:FindFirstChildOfClass("ImageButton") or item:FindFirstChildOfClass("TextButton") or item:FindFirstChildOfClass("GuiButton")
        if child then return child end
    end
    for _, d in ipairs(parent:GetDescendants()) do
        if (d:IsA("GuiButton") or d:IsA("ImageButton") or d:IsA("TextButton")) and string.lower(d.Name) == string.lower(name) then
            return d
        end
    end
    return nil
end

local function HookButtonState(btn, onStateChange)
    if not btn or not (btn:IsA("GuiButton") or btn:IsA("ImageButton") or btn:IsA("TextButton")) then return end
    local down = btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onStateChange(true)
        end
    end)
    local up = btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onStateChange(false)
        end
    end)
    table.insert(MobileControlsConns, down)
    table.insert(MobileControlsConns, up)
end

local function HookMobileGui(gui)
    if not gui or not gui:IsA("ScreenGui") then return end
    local gNameLower = string.lower(gui.Name)
    
    -- 1. THE HIDDEN MOBILE (Hidden-mob.Controls.move2 -> Universal Aim)
    if string.find(gNameLower, "hidden") then
        local controls = gui:FindFirstChild("Controls") or gui:FindFirstChild("Control") or gui
        local move2Btn = ResolveButton(controls, "move2") or ResolveButton(controls, "m2")
        if move2Btn then
            HookButtonState(move2Btn, function(pressed) isMobileM2Held = pressed end)
        end
    end

    -- 2. SLASHER MOBILE (Slasher-mob.Controls.move1 -> Universal Aim | Slasher-mob.Controls.attack -> Veil Aim)
    if string.find(gNameLower, "slasher") then
        local controls = gui:FindFirstChild("Controls") or gui:FindFirstChild("Control") or gui
        local move1Btn = ResolveButton(controls, "move1") or ResolveButton(controls, "m1")
        if move1Btn then
            HookButtonState(move1Btn, function(pressed) isMobileM2Held = pressed end)
        end

        local atkBtn = ResolveButton(controls, "attack")
        if atkBtn then
            HookButtonState(atkBtn, function(pressed) isMobileLMBHeld = pressed end)
        end
    end

    -- 3. SURVIVOR MOBILE (Survivor-mob.Control['Gui-mob'] -> Twist of Fate Aim)
    if string.find(gNameLower, "survivor") or string.find(gNameLower, "gui-mob") then
        local controls = gui:FindFirstChild("Control") or gui:FindFirstChild("Controls") or gui
        local guiMobBtn = ResolveButton(controls, "Gui-mob") or ResolveButton(controls, "gui-mob") or ResolveButton(controls, "dagger")
        if guiMobBtn then
            HookButtonState(guiMobBtn, function(pressed) isMobileADSHeld = pressed end)
        end
    end
end

local function ScanAllPlayerGuis()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end
    for _, child in ipairs(pGui:GetChildren()) do
        HookMobileGui(child)
    end
end

task.spawn(function()
    local pGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if pGui then
        ScanAllPlayerGuis()
        local pGuiChildAdded = pGui.ChildAdded:Connect(function(child)
            task.wait(0.15)
            HookMobileGui(child)
        end)
        table.insert(Connections, pGuiChildAdded)

        local pGuiDescAdded = pGui.DescendantAdded:Connect(function(desc)
            if desc:IsA("GuiButton") or desc:IsA("ImageButton") or desc:IsA("TextButton") then
                local dName = string.lower(desc.Name)
                if dName == "gui-mob" or dName == "move2" or dName == "move1" or dName == "attack" or dName == "action" then
                    task.wait(0.15)
                    local rootScreen = desc:FindFirstAncestorOfClass("ScreenGui")
                    if rootScreen then HookMobileGui(rootScreen) end
                end
            end
        end)
        table.insert(Connections, pGuiDescAdded)
    end
end)

local charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.0)
    ClearMobileControlHooks()
    ScanAllPlayerGuis()
end)
table.insert(Connections, charAddedConn)

-- Self-healing Mobile Control Scanner (Setiap 2 detik memastikan kontrol mobile ter-hook jika masuk match dari lobby)
task.spawn(function()
    while ScriptRunning do
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then
                local hasMobGui = pGui:FindFirstChild("Survivor-mob") or pGui:FindFirstChild("Hidden-mob") or pGui:FindFirstChild("Slasher-mob")
                if hasMobGui and #MobileControlsConns == 0 then
                    ScanAllPlayerGuis()
                end
            end
        end)
        task.wait(2)
    end
end)

local touchSafetyConn = UserInputService.TouchEnded:Connect(function()
    task.defer(function()
        local touches = UserInputService:GetTouches()
        if #touches == 0 then
            isMobileLMBHeld = false
            isMobileM2Held = false
            isMobileADSHeld = false
        end
    end)
end)
table.insert(Connections, touchSafetyConn)

local function ProcessAutoAim(deltaTime)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    local isMyCharDisabled = char:GetAttribute("Knocked") == true or
                             char:GetAttribute("IsCarried") == true or char:GetAttribute("Carried") == true or
                             char:GetAttribute("IsHooked") == true or char:GetAttribute("Hooked") == true or char:GetAttribute("IsOnHook") == true or
                             char:GetAttribute("IsDowned") == true or char:GetAttribute("Downed") == true or
                             hum.PlatformStand or hum:GetState() == Enum.HumanoidStateType.PlatformStanding or
                             char:FindFirstChild("Downed") or char:FindFirstChild("Hooked")
                             
    if isMyCharDisabled then
        LockedTarget = nil
        LockedPart = nil
        VeilLockedTarget = nil
        VeilLockedPart = nil
        return
    end
    
    local isMobileDevice = UserInputService.TouchEnabled
    
    local isVeilAimActive = false
    local isUnivAimActive = false
    local isSurvivorAimActive = false
    
    if isMobileDevice then
        -- DI MOBILE: HANYA aktif saat tombol GUI terkait benar-benar ditahan!
        -- Menggeser layar kosong / joystick TIDAK AKAN PERNAH memicu aimbot!
        isVeilAimActive = isMobileLMBHeld
        isUnivAimActive = isMobileM2Held
        isSurvivorAimActive = isMobileADSHeld
    else
        -- DI PC: Menggunakan klik mouse (LMB untuk Veil, RMB untuk Universal & Survivor)
        local isLMBNow = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        local isRMBPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        isVeilAimActive = isLMBNow or isMobileLMBHeld
        isUnivAimActive = isRMBPressed or isMobileM2Held
        isSurvivorAimActive = isRMBPressed or isMobileADSHeld
    end
    
    local amIKiller = (GetPlayerRole(LocalPlayer) == "KILLER")
    local tool = FindEquippedTool()
    
    -- Tracking status Hold untuk Veil (menghitung charge speed tombak)
    if isVeilAimActive and not isLMBPressed then
        isLMBPressed = true
        lmbHoldStartTime = tick()
    elseif not isVeilAimActive and isLMBPressed then
        isLMBPressed = false
        VeilLockedTarget = nil
        VeilLockedPart = nil
    end
    
    local isVeilSpear = amIKiller or (tool and (string.find(string.lower(tool.Name), "spear") or string.find(string.lower(tool.Name), "veil")))
    
    -- 1. AIMBOT VEIL (Hold LMB di PC / Hold Slasher-mob.Controls.attack di Mobile)
    if VeilAimEnabled and isVeilSpear and isVeilAimActive then
        if not VeilLockedTarget or not VeilLockedPart or not IsValidStandingTarget(VeilLockedTarget) then
            local targetChar, targetPart = GetBestTarget(true, true)
            VeilLockedTarget = targetChar
            VeilLockedPart = targetPart
        end

        local targetChar, targetPart = VeilLockedTarget, VeilLockedPart
        if targetPart and targetChar then
            CurrentTarget = targetChar
            local cameraPos = Camera.CFrame.Position
            local distToTarget = (targetPart.Position - cameraPos).Magnitude
            
            local holdTime = tick() - lmbHoldStartTime
            local spearSpeed = math.clamp(135 + (holdTime * 65), 135, 200)
            local flightTime = distToTarget / spearSpeed
            local pingTime = _G.AutoPrediction and GetServerPing() or 0.035
            
            -- Perhitungan Kompensasi Ketinggian Gravitasi Fisika Asli (Roblox Gravity 196.2)
            -- Semakin jauh jarak musuh, kamera mendongak makin tinggi ke atas secara alami
            local gravityAcc = 196.2
            local dropCompensation = 0.5 * gravityAcc * math.pow(flightTime, 2)
            
            local autoOffset = _G.VeilOffset or 0.60
            local targetVelocity = GetTargetVelocity(targetChar, targetPart)
            
            local predictedPos = targetPart.Position + (targetVelocity * (flightTime + pingTime))
            local aimPos = predictedPos + Vector3.new(0, autoOffset + dropCompensation, 0)
            
            local targetCFrame = CFrame.new(cameraPos, aimPos)
            local smoothness = math.clamp(_G.FiringSmoothness or 0.95, 0.01, 1)
            local alpha = 1 - math.pow(1 - smoothness, deltaTime * 60)
            
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
            return
        end
    else
        VeilLockedTarget = nil
        VeilLockedPart = nil
    end
    
    -- 2. UNIVERSAL AIMBOT (Hold RMB di PC / Hold move2/move1 di Mobile)
    if UniversalAimEnabled and isUnivAimActive then
        local targetChar, targetPart = GetBestTarget(false, true)
        if targetPart then
            CurrentTarget = targetChar
            local cameraPos = Camera.CFrame.Position
            local distToTarget = (targetPart.Position - cameraPos).Magnitude
            
            local autoOffset = _G.UniversalOffset or 1.25
            local targetVelocity = GetTargetVelocity(targetChar, targetPart)
            local pingTime = _G.AutoPrediction and GetServerPing() or 0.035
            
            local bulletSpeed = 220
            local flightTime = distToTarget / bulletSpeed
            
            local predictedPos = targetPart.Position + (targetVelocity * (flightTime + pingTime))
            local aimPos = predictedPos + Vector3.new(0, autoOffset, 0)
            
            local targetCFrame = CFrame.new(cameraPos, aimPos)
            local smoothness = math.clamp(_G.FiringSmoothness or 0.95, 0.01, 1)
            local alpha = 1 - math.pow(1 - smoothness, deltaTime * 60)
            
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
            return
        end
    end

    -- 3. TWIST OF FATE (PISTOL) AIMBOT (Hold RMB di PC / Hold Gui-mob di Mobile)
    if AutoAimEnabled and tool and isSurvivorAimActive then
        local targetChar, targetPart = GetBestTarget(false, isMobileADSHeld)
        if targetPart then
            CurrentTarget = targetChar
            local cameraPos = Camera.CFrame.Position
            local distToTarget = (targetPart.Position - cameraPos).Magnitude
            
            local autoOffset = _G.SurvivorOffset or 0.50
            local targetVelocity = GetTargetVelocity(targetChar, targetPart)
            local pingTime = _G.AutoPrediction and GetServerPing() or 0.025
            
            -- Senjata Twist of Fate presisi tinggi (Bullet Speed 750 studs/s untuk hitscan/fast bullet)
            local bulletSpeed = 750
            local flightTime = distToTarget / bulletSpeed
            
            local predictedPos = targetPart.Position + (targetVelocity * (flightTime + (pingTime * 0.5)))
            local aimPos = predictedPos + Vector3.new(0, autoOffset, 0)
            
            local targetCFrame = CFrame.new(cameraPos, aimPos)
            local smoothness = math.clamp(_G.FiringSmoothness or 0.98, 0.01, 1)
            local alpha = 1 - math.pow(1 - smoothness, deltaTime * 60)
            
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
        end
    end
end

-- =========================================================================
-- 🎯 AUTO SKILLCHECK GREAT (GENERATOR AUTOMATION - ZERO LAG OPTIMIZED)
-- PC: Spacebar | Mobile: Survivor-mob.Control.action Button
-- =========================================================================
local lastHitTick = 0
local function TriggerPerfectHit()
    local now = tick()
    if now - lastHitTick < 0.22 then return end
    lastHitTick = now

    task.spawn(function()
        -- 1. Simulasi Spasi di PC
        if VirtualInputManager then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
        
        -- 2. Simulasi Tombol action di Mobile (Survivor-mob.Control.action)
        pcall(function()
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local sMob = pGui and pGui:FindFirstChild("Survivor-mob")
            if sMob then
                local ctrl = sMob:FindFirstChild("Control") or sMob:FindFirstChild("Controls")
                local actBtn = ctrl and (ctrl:FindFirstChild("action") or ctrl:FindFirstChild("Action"))
                if not actBtn then
                    for _, d in ipairs(sMob:GetDescendants()) do
                        if (d:IsA("GuiButton") or d:IsA("ImageButton") or d:IsA("TextButton")) and string.lower(d.Name) == "action" then
                            actBtn = d
                            break
                        end
                    end
                end
                if actBtn then
                    if firesignal then
                        firesignal(actBtn.MouseButton1Down)
                        firesignal(actBtn.Activated)
                        firesignal(actBtn.MouseButton1Up)
                    elseif actBtn.MouseButton1Click then
                        actBtn.MouseButton1Click:Fire()
                    end
                end
            end
        end)
    end)
end

local function ProcessAutoSkillCheck()
    if not ScriptRunning or not _G.AutoSkillCheck then return end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
    if not gui then
        for _, child in pairs(playerGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Enabled and string.find(string.lower(child.Name), "skill") then
                gui = child
                break
            end
        end
    end
    
    if gui and gui.Enabled then
        local check = gui:FindFirstChild("Check") or gui
        local line = check:FindFirstChild("Line") or gui:FindFirstChild("Line", true)
        local goal = check:FindFirstChild("Goal") or gui:FindFirstChild("Goal", true)
        
        if line and goal and line.Visible and goal.Visible then
            local now = tick()
            if now - lastHitTick >= 0.22 then
                local lineRot = line.Rotation % 360
                local goalRot = goal.Rotation % 360
                
                local targetAngle = (goalRot + 120) % 360
                local diff = math.abs((lineRot - targetAngle + 180) % 360 - 180)
                
                if diff <= 14 then
                    TriggerPerfectHit()
                end
            end
        end
    end
end

local aimRenderConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if ScriptRunning then
        pcall(function() ProcessAutoAim(deltaTime) end)
        pcall(function() ProcessAutoSkillCheck() end)
    end
end)
table.insert(Connections, aimRenderConnection)

-- croshair dot
local CrosshairGui, CrosshairDot = nil, nil
local function CreateCrosshairUI()
    if CrosshairGui then CrosshairGui:Destroy() end
    CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "CrosshairGui"
    CrosshairGui.Parent = game.CoreGui
    CrosshairGui.ResetOnSpawn = false
    
    CrosshairDot = Instance.new("Frame")
    CrosshairDot.Name = "Dot"
    CrosshairDot.Size = UDim2.new(0, 10, 0, 10)
    CrosshairDot.Position = UDim2.new(0.5, -5, 0.5, -5)
    CrosshairDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CrosshairDot.BorderSizePixel = 1
    CrosshairDot.BorderColor3 = Color3.fromRGB(255, 255, 255)
    CrosshairDot.ZIndex = 11
    CrosshairDot.Visible = false
    CrosshairDot.Parent = CrosshairGui
    
    local dotCorner = Instance.new("UICorner", CrosshairDot)
    dotCorner.CornerRadius = UDim.new(1, 0)
end
CreateCrosshairUI()

local crosshairConnection = RunService.RenderStepped:Connect(function()
    if not ScriptRunning or not CrosshairDot then return end
    
    local activeAim = AutoAimEnabled or VeilAimEnabled or UniversalAimEnabled
    if not activeAim then 
        CrosshairDot.Visible = false
        return 
    end
    
    CrosshairDot.Visible = true
    local isMobileDevice = UserInputService.TouchEnabled
    local isAiming = false
    if isMobileDevice then
        isAiming = isMobileLMBHeld or isMobileM2Held or isMobileADSHeld
    else
        isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or isMobileLMBHeld or isMobileM2Held or isMobileADSHeld
    end
    
    if isAiming and LockedPart then
        if IsSCP(LockedTarget) then
            CrosshairDot.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
        else
            CrosshairDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        CrosshairDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)
table.insert(Connections, crosshairConnection)

--  wind ui lib
local UIControls = {}

local function GetKeyCode(key)
    if typeof(key) == "EnumItem" then
        return key
    elseif type(key) == "string" then
        local cleanName = key:gsub("Enum.KeyCode.", "")
        if Enum.KeyCode[cleanName] then
            return Enum.KeyCode[cleanName]
        end
    end
    return nil
end

local function GetKeyName(key)
    if typeof(key) == "EnumItem" then
        return key.Name
    elseif type(key) == "string" then
        return key
    end
    return "None"
end

local function CreateUI()
    if not WindUI then
        warn("WindUI Library not loaded, falling back to basic execution")
        return {}
    end

    
    pcall(function()
        local hexBase = Color3.fromRGB(10, 77, 102)        -- #0a4d66 Utama
        local hexAccent = Color3.fromRGB(14, 104, 136)      -- Light Accent #0a4d66
        local hexDarkBg = Color3.fromRGB(6, 43, 58)        -- Background utama
        local hexContainer = Color3.fromRGB(8, 60, 80)     -- Container #0a4d66
        local hexCard = Color3.fromRGB(10, 77, 102)        -- Card #0a4d66
        local hexButton = Color3.fromRGB(13, 91, 120)      -- Button #0a4d66
        local hexOutline = Color3.fromRGB(18, 125, 160)    -- Outline

        if WindUI.AddTheme then
            WindUI:AddTheme({
                Name = "ToscaTheme",
                Accent = hexAccent,
                Outline = hexOutline,
                Background = hexDarkBg,
                Container = hexContainer,
                Card = hexCard,
                Button = hexButton,
                Toggle = hexAccent,
                Slider = hexAccent,
                Text = Color3.fromRGB(230, 247, 255),
                SubText = Color3.fromRGB(140, 200, 220),
                PlaceholderText = Color3.fromRGB(100, 170, 190),
            })
            WindUI:SetTheme("ToscaTheme")
        elseif WindUI.SetTheme then
            WindUI:SetTheme("Dark")
        end
    end)

    local Window = WindUI:CreateWindow({
        Title = "SysHub Premium",
        Icon = "shield-alert",
        Author = "Violance District",
        Folder = "SysHub VD",
        Size = UDim2.fromOffset(600, 540),
        MinSize = Vector2.new(500, 380),
        Transparent = true,
        Theme = "ToscaTheme",
        Accent = Color3.fromRGB(10, 77, 102), 
        Resizable = true,
        HideSearchBar = true,
    })

    WindowInstance = Window

    -- 📱 FLOATING MINI TOGGLE BUTTON (WINDUI BUILT-IN OPEN BUTTON)
    pcall(function()
        if Window and Window.EditOpenButton then
            Window:EditOpenButton({
                Title = "SysHub VD",
                Icon = "shield-alert",
                CornerRadius = UDim.new(0, 18),
                StrokeThickness = 1.5,
                Color = ColorSequence.new(Color3.fromRGB(10, 77, 102), Color3.fromRGB(6, 43, 58)),
                OnlyMobile = false,
                Enabled = true,
                Draggable = true
            })
        end
    end)

    -- close: HANYA hide window, JANGAN matikan script cheat saat di-close/di-minimize
    pcall(function()
        if Window.OnClose then
            if type(Window.OnClose) == "function" then
                Window.OnClose = function(...) end
            end
        end
    end)


    local MainTab = Window:Tab({
        Title = "SysHub VD",
        Icon = "shield",
    })

    -- combat
    local parrySection = MainTab:Section({ Title = "Combat & Auto Parry Engine" })

    UIControls.AutoParry = parrySection:Toggle({
        Title = "Auto Parrying Dagger [K]",
        Desc = "Deteksi 0ms serangan Killer & pemicu parry otomatis",
        Value = _G.AutoParry,
        Callback = function(state)
            _G.AutoParry = state
        end
    })

    UIControls.AutoPrediction = parrySection:Toggle({
        Title = "Auto Ping Prediction",
        Desc = "Prediksi posisi target berdasarkan latency ping server",
        Value = _G.AutoPrediction,
        Callback = function(state)
            _G.AutoPrediction = state
        end
    })

    if parrySection.Keybind then
        pcall(function()
            parrySection:Keybind({
                Title = "Auto Parry Keybind",
                Desc = "Shortcut tombol Auto Parry",
                Default = GetKeyName(Keybinds.AutoParry),
                Value = GetKeyName(Keybinds.AutoParry),
                Keybind = GetKeyName(Keybinds.AutoParry),
                Key = GetKeyName(Keybinds.AutoParry),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.AutoParry = code end
                end
            })
        end)
    end

    parrySection:Slider({
        Title = "Parry Distance (Studs)",
        Step = 0.5,
        Value = {
            Min = 8.0,
            Max = 20.0,
            Default = _G.ParryMaxDistance or 11.0,
        },
        Callback = function(value)
            _G.ParryMaxDistance = tonumber(value) or 11.0
        end
    })

    -- SECTION 2: VISUALS & ESP
    local espSection = MainTab:Section({ Title = "Visuals & ESP" })

    UIControls.ESPMaster = espSection:Toggle({
        Title = "ESP Master [Z]",
        Desc = "Aktifkan/Matikan seluruh fitur ESP",
        Value = ESPEnabled,
        Callback = function(state)
            ESPEnabled = state
            RefreshAllESP()
        end
    })
    if espSection.Keybind then
        pcall(function()
            espSection:Keybind({
                Title = "ESP Master Keybind",
                Desc = "Shortcut tombol ESP Master",
                Default = GetKeyName(Keybinds.ESP),
                Value = GetKeyName(Keybinds.ESP),
                Keybind = GetKeyName(Keybinds.ESP),
                Key = GetKeyName(Keybinds.ESP),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.ESP = code end
                end
            })
        end)
    end

    UIControls.ShowFriends = espSection:Toggle({
        Title = "Show Survivor [C]",
        Desc = "Tampilkan ESP untuk teman/survivor",
        Value = ShowFriends,
        Callback = function(state)
            ShowFriends = state
            RefreshAllESP()
        end
    })
    if espSection.Keybind then
        pcall(function()
            espSection:Keybind({
                Title = "Show Survivor Keybind",
                Desc = "Shortcut tombol Show Survivor",
                Default = GetKeyName(Keybinds.ShowFriends),
                Value = GetKeyName(Keybinds.ShowFriends),
                Keybind = GetKeyName(Keybinds.ShowFriends),
                Key = GetKeyName(Keybinds.ShowFriends),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.ShowFriends = code end
                end
            })
        end)
    end

    UIControls.ShowEnemies = espSection:Toggle({
        Title = "Show Killer & SCP [X]",
        Desc = "Tampilkan ESP untuk Killer dan SCP",
        Value = ShowEnemies,
        Callback = function(state)
            ShowEnemies = state
            RefreshAllESP()
        end
    })
    if espSection.Keybind then
        pcall(function()
            espSection:Keybind({
                Title = "Show Killer Keybind",
                Desc = "Shortcut tombol Show Killer & SCP",
                Default = GetKeyName(Keybinds.ShowEnemies),
                Value = GetKeyName(Keybinds.ShowEnemies),
                Keybind = GetKeyName(Keybinds.ShowEnemies),
                Key = GetKeyName(Keybinds.ShowEnemies),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.ShowEnemies = code end
                end
            })
        end)
    end

    UIControls.ShowGenerators = espSection:Toggle({
        Title = "ESP Generator [G]",
        Desc = "Tampilkan ESP lokasi Generator",
        Value = _G.ShowGenerators,
        Callback = function(state)
            _G.ShowGenerators = state
            RefreshGeneratorESP()
        end
    })
    if espSection.Keybind then
        pcall(function()
            espSection:Keybind({
                Title = "ESP Generator Keybind",
                Desc = "Shortcut tombol ESP Generator",
                Default = GetKeyName(Keybinds.ShowGenerators),
                Value = GetKeyName(Keybinds.ShowGenerators),
                Keybind = GetKeyName(Keybinds.ShowGenerators),
                Key = GetKeyName(Keybinds.ShowGenerators),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.ShowGenerators = code end
                end
            })
        end)
    end

    UIControls.ModeTerang = espSection:Toggle({
        Title = "Mode Terang / Fullbright [J]",
        Desc = "Menghilangkan kegelapan & efek lighting map",
        Value = _G.ModeTerang,
        Callback = function(state)
            _G.ModeTerang = state
            ApplyModeTerangInGame()
        end
    })

    espSection:Slider({
        Title = "Brightness Level Map",
        Desc = "Atur tingkat kecerahan cahaya map secara real-time",
        Step = 0.5,
        Value = {
            Min = 1.0,
            Max = 10.0,
            Default = _G.FullbrightBrightness or 2.0,
        },
        Callback = function(value)
            _G.FullbrightBrightness = tonumber(value) or 2.0
            if _G.ModeTerang then
                pcall(function()
                    Lighting.Brightness = _G.FullbrightBrightness
                    ApplyModeTerangInGame()
                end)
            end
        end
    })

    espSection:Slider({
        Title = "Camera FOV",
        Desc = "Atur sudut pandang luas kamera (Default: 70)",
        Step = 1.0,
        Value = {
            Min = 70.0,
            Max = 120.0,
            Default = _G.CameraFOV or 70.0,
        },
        Callback = function(value)
            _G.CameraFOV = tonumber(value) or 70.0
        end
    })

    if espSection.Keybind then
        pcall(function()
            espSection:Keybind({
                Title = "Mode Terang Keybind",
                Desc = "Shortcut tombol Mode Terang",
                Default = GetKeyName(Keybinds.ModeTerang),
                Value = GetKeyName(Keybinds.ModeTerang),
                Keybind = GetKeyName(Keybinds.ModeTerang),
                Key = GetKeyName(Keybinds.ModeTerang),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.ModeTerang = code end
                end
            })
        end)
    end

    -- SECTION 3: AIMBOT SETTINGS
    local aimSection = MainTab:Section({ Title = "Aimbot Settings" })

    UIControls.AutoAim = aimSection:Toggle({
        Title = "Aim Survivor (Twist of Fate) [V]",
        Desc = "Aimbot presisi tinggi untuk senjata Survivor",
        Value = AutoAimEnabled,
        Callback = function(state)
            AutoAimEnabled = state
        end
    })
    if aimSection.Keybind then
        pcall(function()
            aimSection:Keybind({
                Title = "Aim Survivor Keybind",
                Desc = "Shortcut tombol Aim Survivor",
                Default = GetKeyName(Keybinds.AutoAim),
                Value = GetKeyName(Keybinds.AutoAim),
                Keybind = GetKeyName(Keybinds.AutoAim),
                Key = GetKeyName(Keybinds.AutoAim),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.AutoAim = code end
                end
            })
        end)
    end

    UIControls.VeilAim = aimSection:Toggle({
        Title = "Veil Aim (Spear / Killer) [B]",
        Desc = "Aimbot prediksi lemparan tombak Veil",
        Value = VeilAimEnabled,
        Callback = function(state)
            VeilAimEnabled = state
        end
    })
    if aimSection.Keybind then
        pcall(function()
            aimSection:Keybind({
                Title = "Veil Aim Keybind",
                Desc = "Shortcut tombol Veil Aim",
                Default = GetKeyName(Keybinds.VeilAim),
                Value = GetKeyName(Keybinds.VeilAim),
                Keybind = GetKeyName(Keybinds.VeilAim),
                Key = GetKeyName(Keybinds.VeilAim),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.VeilAim = code end
                end
            })
        end)
    end

    UIControls.UniversalAim = aimSection:Toggle({
        Title = "Universal Aimbot [N]",
        Desc = "Aimbot universal untuk semua senjata",
        Value = UniversalAimEnabled,
        Callback = function(state)
            UniversalAimEnabled = state
        end
    })
    if aimSection.Keybind then
        pcall(function()
            aimSection:Keybind({
                Title = "Universal Aim Keybind",
                Desc = "Shortcut tombol Universal Aim",
                Default = GetKeyName(Keybinds.UniversalAim),
                Value = GetKeyName(Keybinds.UniversalAim),
                Keybind = GetKeyName(Keybinds.UniversalAim),
                Key = GetKeyName(Keybinds.UniversalAim),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.UniversalAim = code end
                end
            })
        end)
    end

    UIControls.WallCheck = aimSection:Toggle({
        Title = "Wall Check [L]",
        Desc = "Hanya mengunci target yang terlihat (tidak terhalang dinding)",
        Value = _G.WallCheck,
        Callback = function(state)
            _G.WallCheck = state
        end
    })
    if aimSection.Keybind then
        pcall(function()
            aimSection:Keybind({
                Title = "Wall Check Keybind",
                Desc = "Shortcut tombol Wall Check",
                Default = GetKeyName(Keybinds.WallCheck),
                Value = GetKeyName(Keybinds.WallCheck),
                Keybind = GetKeyName(Keybinds.WallCheck),
                Key = GetKeyName(Keybinds.WallCheck),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.WallCheck = code end
                end
            })
        end)
    end

    aimSection:Toggle({
        Title = "Auto Ping Prediction",
        Desc = "Prediksi posisi target berdasarkan latency ping server",
        Value = _G.AutoPrediction,
        Callback = function(state)
            _G.AutoPrediction = state
        end
    })

    aimSection:Slider({
        Title = "Survivor Aim Height Offset",
        Desc = "Offset vertikal bidikan Twist of Fate (Default: 0.50)",
        Step = 0.05,
        Value = {
            Min = 0.0,
            Max = 2.0,
            Default = _G.SurvivorOffset or 0.50,
        },
        Callback = function(value)
            _G.SurvivorOffset = tonumber(value) or 0.50
        end
    })

    aimSection:Slider({
        Title = "Universal Aim Height Offset",
        Desc = "Offset vertikal bidikan Universal Aim (Default: 1.25)",
        Step = 0.05,
        Value = {
            Min = 0.0,
            Max = 2.5,
            Default = _G.UniversalOffset or 1.25,
        },
        Callback = function(value)
            _G.UniversalOffset = tonumber(value) or 1.25
        end
    })

    aimSection:Slider({
        Title = "Veil Aim Height Offset",
        Desc = "Offset vertikal bidikan lemparan tombak Veil (Default: 0.60)",
        Step = 0.05,
        Value = {
            Min = 0.0,
            Max = 2.0,
            Default = _G.VeilOffset or 0.60,
        },
        Callback = function(value)
            _G.VeilOffset = tonumber(value) or 0.60
        end
    })

    aimSection:Slider({
        Title = "Base Aim Offset",
        Desc = "Offset dasar perhitungan target (Default: 0.45)",
        Step = 0.05,
        Value = {
            Min = 0.0,
            Max = 2.0,
            Default = _G.BaseOffset or 0.45,
        },
        Callback = function(value)
            _G.BaseOffset = tonumber(value) or 0.45
        end
    })

    aimSection:Slider({
        Title = "Firing Smoothness",
        Desc = "Kehalusan pergerakan kamera aimbot (Default: 0.95)",
        Step = 0.01,
        Value = {
            Min = 0.1,
            Max = 1.0,
            Default = _G.FiringSmoothness or 0.95,
        },
        Callback = function(value)
            _G.FiringSmoothness = tonumber(value) or 0.95
        end
    })

    -- SECTION 4: AUTOMATION & MECHANICS
    local skillSection = MainTab:Section({ Title = "Automation & Mechanics" })

    UIControls.AutoSkillCheck = skillSection:Toggle({
        Title = "Auto SkillCheck Great [H]",
        Desc = "Otomatis menyelesaikan Skillcheck Generator dengan hasil Great",
        Value = _G.AutoSkillCheck,
        Callback = function(state)
            _G.AutoSkillCheck = state
        end
    })
    if skillSection.Keybind then
        pcall(function()
            skillSection:Keybind({
                Title = "Auto SkillCheck Keybind",
                Desc = "Shortcut tombol Auto SkillCheck",
                Default = GetKeyName(Keybinds.AutoSkillCheck),
                Value = GetKeyName(Keybinds.AutoSkillCheck),
                Keybind = GetKeyName(Keybinds.AutoSkillCheck),
                Key = GetKeyName(Keybinds.AutoSkillCheck),
                Callback = function(key)
                    local code = GetKeyCode(key)
                    if code and typeof(code) == "EnumItem" then Keybinds.AutoSkillCheck = code end
                end
            })
        end)
    end



    local miscSection = MainTab:Section({ Title = "System & Unload" })
    miscSection:Button({
        Title = "Unload Script",
        Desc = "Matikan cheat dan bersihkan semua fitur",
        Callback = function()
            if _G.SugengVDCleanup then _G.SugengVDCleanup() end
        end
    })

    local function SafeSetToggle(control, state)
        if control then
            pcall(function()
                if control.SetValue then control:SetValue(state)
                elseif control.Set then control:Set(state)
                end
            end)
        end
    end

    local function UpdateAllIndicators()
        SafeSetToggle(UIControls.ESPMaster, ESPEnabled)
        SafeSetToggle(UIControls.ShowFriends, ShowFriends)
        SafeSetToggle(UIControls.ShowEnemies, ShowEnemies)
        SafeSetToggle(UIControls.AutoAim, AutoAimEnabled)
        SafeSetToggle(UIControls.VeilAim, VeilAimEnabled)
        SafeSetToggle(UIControls.UniversalAim, UniversalAimEnabled)
        SafeSetToggle(UIControls.ShowGenerators, _G.ShowGenerators)
        SafeSetToggle(UIControls.AutoSkillCheck, _G.AutoSkillCheck)
        SafeSetToggle(UIControls.ModeTerang, _G.ModeTerang)
        SafeSetToggle(UIControls.AutoParry, _G.AutoParry)
        SafeSetToggle(UIControls.WallCheck, _G.WallCheck)
            end

    local function ToggleUI()
        if not ScriptRunning then return end
        UIVisible = not UIVisible
        if Window then
            if Window.Toggle then
                pcall(function() Window:Toggle() end)
            elseif Window.IsOpen ~= nil then
                pcall(function()
                    if Window.IsOpen then Window:Close() else Window:Open() end
                end)
            end
        end
    end

    return { UpdateAll = UpdateAllIndicators, ToggleUI = ToggleUI }
end

UI = CreateUI()

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    local conn1 = player.CharacterAdded:Connect(function()
        task.wait(0.1)
        RefreshAllESP()
    end)
    table.insert(Connections, conn1)
    
    local conn2 = player.CharacterRemoving:Connect(function()
        RemoveESPFromTarget(player.Character)
    end)
    table.insert(Connections, conn2)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then SetupPlayer(player) end
end

local playerAddedConn = Players.PlayerAdded:Connect(SetupPlayer)
table.insert(Connections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    RemoveESPFromTarget(player.Character)
end)
table.insert(Connections, playerRemovingConn)

local wsDescConn = workspace.DescendantAdded:Connect(function(desc)
    if not ScriptRunning or not ESPEnabled then return end
    if desc:IsA("Model") then
        local name = string.lower(desc.Name)
        if string.find(name, "scp") or string.find(name, "zombie") or string.find(name, "infected") or string.find(name, "049-2") then
            task.wait(0.2)
            RefreshAllESP()
        end
    end
end)
table.insert(Connections, wsDescConn)

local keyInputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not ScriptRunning or gameProcessed then return end
    
    local code = input.KeyCode
    if not code or code == Enum.KeyCode.Unknown then return end
    
    if code == Enum.KeyCode.Delete then
        if _G.SugengVDCleanup then _G.SugengVDCleanup() end
        return
    elseif code == Enum.KeyCode.Zero or code == Enum.KeyCode.KeypadZero or code == Enum.KeyCode.Insert or code == Enum.KeyCode.RightShift or code == Enum.KeyCode.RightControl then 
        if UI and UI.ToggleUI then UI.ToggleUI() end 
        return
    elseif Keybinds.ESP and code == Keybinds.ESP then
        ESPEnabled = not ESPEnabled
        RefreshAllESP()
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.ShowFriends and code == Keybinds.ShowFriends then
        ShowFriends = not ShowFriends
        RefreshAllESP()
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.ShowEnemies and code == Keybinds.ShowEnemies then
        ShowEnemies = not ShowEnemies
        RefreshAllESP()
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.AutoAim and code == Keybinds.AutoAim then
        AutoAimEnabled = not AutoAimEnabled
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.VeilAim and code == Keybinds.VeilAim then
        VeilAimEnabled = not VeilAimEnabled
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.UniversalAim and code == Keybinds.UniversalAim then
        UniversalAimEnabled = not UniversalAimEnabled
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.ShowGenerators and code == Keybinds.ShowGenerators then
        _G.ShowGenerators = not _G.ShowGenerators
        RefreshGeneratorESP()
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.AutoSkillCheck and code == Keybinds.AutoSkillCheck then
        _G.AutoSkillCheck = not _G.AutoSkillCheck
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.ModeTerang and code == Keybinds.ModeTerang then
        _G.ModeTerang = not _G.ModeTerang
        ApplyModeTerangInGame()
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.AutoParry and code == Keybinds.AutoParry then
        _G.AutoParry = not _G.AutoParry
        if UI and UI.UpdateAll then UI.UpdateAll() end
    elseif Keybinds.WallCheck and code == Keybinds.WallCheck then
        _G.WallCheck = not _G.WallCheck
        if UI and UI.UpdateAll then UI.UpdateAll() end
    end
end)
table.insert(Connections, keyInputConn)
