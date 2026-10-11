-- =========================================================================
-- 📱 [VIOLENCE DISTRICT - MOBILE ON-SCREEN DATA SNIFFER & REMOTE SPY]
-- Khusus didesain untuk HP (Mobile Executor: Delta, Codex, Arceus, Fluxus, dll)
-- Dilengkapi GUI layar sentuh, Realtime Log Box, dan Tombol "COPY ALL LOGS"
-- =========================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil

-- Hapus GUI lama jika dijalankan ulang
pcall(function()
    if getgenv and getgenv().VD_MobileSnifferGui then
        getgenv().VD_MobileSnifferGui:Destroy()
    end
end)

local LogHistory = {}
local MaxLogLines = 200

local function GetTimestamp()
    local d = os.date("*t")
    return string.format("%02d:%02d:%02d", d.hour or 0, d.min or 0, d.sec or 0)
end

-- =========================================================================
-- 📱 1. PEMBUATAN GUI LAYAR SENTUH KHUSUS MOBILE
-- =========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_MobileSnifferGui"
ScreenGui.ResetOnSpawn = false
local parentGui = (CoreGui and pcall(function() ScreenGui.Parent = CoreGui end)) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parentGui

if getgenv then getgenv().VD_MobileSnifferGui = ScreenGui end

-- Helper Touch Draggable untuk Layar HP
local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Frame Utama (Ukuran Pas untuk Layar HP)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(56, 189, 248)
Stroke.Thickness = 1.5

-- Header Bar (Bisa Disentuh & Digeser di HP)
local Header = Instance.new("Frame", MainFrame)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
local HCorner = Instance.new("UICorner", Header)
HCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextColor3 = Color3.fromRGB(56, 189, 248)
Title.Text = "🔍 VD MOBILE SNIFFER (HOLD HEADER TO DRAG)"
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Pasang Touch Draggable ke Header
MakeDraggable(Header, MainFrame)

local isInspectorRunning = true

-- Tombol Minimize [-]
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 32, 0, 26)
MinBtn.Position = UDim2.new(1, -72, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 15
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "—"
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

-- Tombol Close [X]
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "✕"
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

-- Floating Mini Pill (Saat di-minimize agar tidak hilang di HP)
local MiniPill = Instance.new("TextButton", ScreenGui)
MiniPill.Name = "MiniPill"
MiniPill.Size = UDim2.new(0, 130, 0, 34)
MiniPill.Position = UDim2.new(0.5, -65, 0.02, 0)
MiniPill.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
MiniPill.Font = Enum.Font.GothamBold
MiniPill.TextSize = 11
MiniPill.TextColor3 = Color3.fromRGB(56, 189, 248)
MiniPill.Text = "🔍 BUKA LOGGER"
MiniPill.Visible = false
MiniPill.Active = true
local PillCorner = Instance.new("UICorner", MiniPill)
PillCorner.CornerRadius = UDim.new(0, 17)
local PillStroke = Instance.new("UIStroke", MiniPill)
PillStroke.Color = Color3.fromRGB(56, 189, 248)
PillStroke.Thickness = 1.4

-- Mini Pill juga bisa digeser di layar HP
MakeDraggable(MiniPill, MiniPill)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniPill.Visible = true
end)

MiniPill.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniPill.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    isInspectorRunning = false
    if getgenv then getgenv().VD_MobileSnifferGui = nil end
    ScreenGui:Destroy()
end)

-- Tombol Aksi Toolbar
local ActionsFrame = Instance.new("Frame", MainFrame)
ActionsFrame.Size = UDim2.new(1, -16, 0, 30)
ActionsFrame.Position = UDim2.new(0, 8, 0, 38)
ActionsFrame.BackgroundTransparency = 1

local CopyBtn = Instance.new("TextButton", ActionsFrame)
CopyBtn.Size = UDim2.new(0.38, 0, 1, 0)
CopyBtn.Position = UDim2.new(0, 0, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 10
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Text = "📋 COPY"
local CopyCorner = Instance.new("UICorner", CopyBtn)
CopyCorner.CornerRadius = UDim.new(0, 6)

local ScanBtn = Instance.new("TextButton", ActionsFrame)
ScanBtn.Size = UDim2.new(0.34, 0, 1, 0)
ScanBtn.Position = UDim2.new(0.40, 0, 0, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(14, 116, 144)
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextSize = 10
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Text = "🏃 SPRINT"
local ScanCorner = Instance.new("UICorner", ScanBtn)
ScanCorner.CornerRadius = UDim.new(0, 6)

local ClearBtn = Instance.new("TextButton", ActionsFrame)
ClearBtn.Size = UDim2.new(0.24, 0, 1, 0)
ClearBtn.Position = UDim2.new(0.76, 0, 0, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 10
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Text = "🗑️ CLEAR"
local ClearCorner = Instance.new("UICorner", ClearBtn)
ClearCorner.CornerRadius = UDim.new(0, 6)

-- Kotak Log Tampilan Layar (ScrollingFrame + TextBox agar bisa dipilih & dicopy manual di HP)
local LogScroll = Instance.new("ScrollingFrame", MainFrame)
LogScroll.Name = "LogScroll"
LogScroll.Size = UDim2.new(1, -16, 1, -78)
LogScroll.Position = UDim2.new(0, 8, 0, 72)
LogScroll.BackgroundColor3 = Color3.fromRGB(2, 6, 23)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 5
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LogCorner = Instance.new("UICorner", LogScroll)
LogCorner.CornerRadius = UDim.new(0, 6)

local LogBox = Instance.new("TextBox", LogScroll)
LogBox.Name = "LogBox"
LogBox.Size = UDim2.new(1, -8, 1, -8)
LogBox.Position = UDim2.new(0, 4, 0, 4)
LogBox.BackgroundTransparency = 1
LogBox.Font = Enum.Font.Code
LogBox.TextSize = 10
LogBox.TextColor3 = Color3.fromRGB(226, 232, 240)
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.ClearTextOnFocus = false
LogBox.MultiLine = true
LogBox.TextWrapped = true
LogBox.TextEditable = false
LogBox.AutomaticSize = Enum.AutomaticSize.Y
LogBox.Text = "=== [LOGGER INITIALIZED] ===\nMenunggu interaksi: Perbaiki Generator / SkillCheck..."

local function AppendLog(msg)
    local line = string.format("[%s] %s", GetTimestamp(), msg)
    table.insert(LogHistory, line)
    if #LogHistory > MaxLogLines then
        table.remove(LogHistory, 1)
    end
    LogBox.Text = table.concat(LogHistory, "\n")
    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(0, 999999)
    end)
    print(line)
end

-- Fungsi Salin Clipboard (Mendukung semua executor mobile + simpan ke workspace/vd_logs.txt)
CopyBtn.MouseButton1Click:Connect(function()
    local fullText = table.concat(LogHistory, "\n")
    if #LogHistory == 0 or fullText == "" then
        fullText = LogBox.Text
    end
    
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(fullText)
            copied = true
        elseif toclipboard then
            toclipboard(fullText)
            copied = true
        elseif syn and syn.write_clipboard then
            syn.write_clipboard(fullText)
            copied = true
        end
    end)
    
    -- Backup simpan file di folder executor (Delta/Codex workspace)
    pcall(function()
        if writefile then
            writefile("vd_logs.txt", fullText)
        end
    end)
    
    if copied then
        CopyBtn.Text = "✅ COPIED!"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(5, 150, 105)
        task.delay(1.5, function()
            CopyBtn.Text = "📋 COPY"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        end)
    else
        CopyBtn.Text = "⚠️ SELECT"
        LogBox.TextEditable = true
        LogBox:CaptureFocus()
        task.delay(2, function()
            LogBox.TextEditable = false
            CopyBtn.Text = "📋 COPY"
        end)
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    table.clear(LogHistory)
    LogBox.Text = string.format("=== [LOG DI-CLEAR: %s] ===\nSilakan lakukan aksi baru untuk ditest (Dagger / Veil / Gen / Sprint)...", GetTimestamp())
    ClearBtn.Text = "BERSIH! ✨"
    ClearBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    task.delay(1, function()
        ClearBtn.Text = "🗑️ CLEAR"
        ClearBtn.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
    end)
end)

-- =========================================================================
-- 🏃 2. PEMINDAIAN SPRINT & TOMBOL MOBILE (KENAPA ADA 2 TOMBOL LARI)
-- =========================================================================
local function ScanSprint()
    AppendLog("----- [SCANNING SPRINT & TOUCH BUTTONS] -----")
    local count = 0
    
    -- Cek ContextActionService
    pcall(function()
        local bound = ContextActionService:GetAllBoundActionInfo()
        for actName, info in pairs(bound) do
            local aLow = string.lower(tostring(actName))
            if string.find(aLow, "sprint") or string.find(aLow, "run") or string.find(aLow, "shift") or string.find(aLow, "walk") then
                count = count + 1
                AppendLog(string.format("🔘 ContextAction: '%s' | TouchButton: %s", tostring(actName), tostring(info.createTouchButton)))
            end
        end
    end)
    
    -- Cek Tombol di PlayerGui
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiButton") or desc:IsA("ImageButton") or desc:IsA("TextButton") then
                        local dName = string.lower(desc.Name)
                        if string.find(dName, "sprint") or string.find(dName, "run") or string.find(dName, "shift") or string.find(dName, "fast") then
                            count = count + 1
                            AppendLog(string.format("🔘 GUI Button: [%s] '%s' (Vis: %s) di %s", 
                                desc.ClassName, desc.Name, tostring(desc.Visible), gui.Name))
                        end
                    end
                end
            end
        end
    end
    
    if count == 0 then
        AppendLog("⚠️ Tidak ada tombol sprint khusus di GUI (Berarti tombol lari kedua dari Roblox Dynamic Thumbstick).")
    end
    AppendLog("---------------------------------------------")
end

ScanBtn.MouseButton1Click:Connect(ScanSprint)
task.defer(ScanSprint)

-- =========================================================================
-- 📡 3. REMOTE SPY LENGKAP (INCOMING & OUTGOING FIRESETVER HOOK)
-- =========================================================================
local function FormatArgs(...)
    local args = {...}
    local strList = {}
    for i, v in ipairs(args) do
        local valStr = tostring(v)
        if typeof(v) == "Instance" then
            valStr = string.format("%s (%s)", v.Name, v.ClassName)
        elseif type(v) == "table" then
            valStr = "{table}"
        end
        table.insert(strList, string.format("[%d]: %s", i, valStr))
    end
    return #strList > 0 and table.concat(strList, ", ") or "(none)"
end

-- 3A. Hook Outgoing FireServer (Jika executor mendukung hookmetamethod)
pcall(function()
    if hookmetamethod and getnamecallmethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "fireServer") and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
                local sName = string.lower(self.Name)
                local pName = self.Parent and string.lower(self.Parent.Name) or ""
                
                -- Filter hanya event penting (Generator, Heal, Killer, Dagger, Veil, dll)
                if string.find(sName, "gen") or string.find(sName, "skill") or string.find(sName, "check") or 
                   string.find(sName, "repair") or string.find(sName, "heal") or string.find(sName, "leap") or 
                   string.find(sName, "m2") or string.find(sName, "attack") or string.find(pName, "gen") or 
                   string.find(pName, "heal") or string.find(pName, "hidden") or string.find(sName, "parry") or
                   string.find(sName, "dagger") or string.find(sName, "spear") or string.find(sName, "veil") or
                   string.find(pName, "item") or string.find(pName, "killer") then
                    
                    local argsText = FormatArgs(...)
                    AppendLog(string.format("📤 [OUT] %s.%s | %s", self.Parent and self.Parent.Name or "Remotes", self.Name, argsText))
                end
            end
            return oldNamecall(self, ...)
        end)
        AppendLog("✅ Hook FireServer aktif! (Akan mencatat aksi saat Anda klik tombol)")
    end
end)

-- 3B. Hook Incoming Server Events (OnClientEvent)
local hookedRemotes = {}
local function HookClientEvent(remote, category)
    if not remote or hookedRemotes[remote] then return end
    hookedRemotes[remote] = true
    
    if remote:IsA("RemoteEvent") then
        pcall(function()
            remote.OnClientEvent:Connect(function(...)
                local argsText = FormatArgs(...)
                AppendLog(string.format("📥 [IN <%s>] %s | %s", category, remote.Name, argsText))
            end)
        end)
    end
end

local function ScanAndHookRemotes()
    local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not RemotesFolder then return end
    
    for _, desc in ipairs(RemotesFolder:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            local pName = desc.Parent and string.lower(desc.Parent.Name) or ""
            local dName = string.lower(desc.Name)
            
            if string.find(pName, "gen") or string.find(dName, "gen") then
                HookClientEvent(desc, "GEN")
            elseif string.find(pName, "heal") or string.find(dName, "heal") then
                HookClientEvent(desc, "HEAL")
            elseif string.find(pName, "killer") or string.find(dName, "hidden") then
                HookClientEvent(desc, "KILLER")
            elseif string.find(pName, "attack") or string.find(dName, "attack") then
                HookClientEvent(desc, "ATK")
            elseif string.find(pName, "item") or string.find(dName, "dagger") or string.find(dName, "twist") then
                HookClientEvent(desc, "ITEM")
            end
        end
    end
end
ScanAndHookRemotes()

-- =========================================================================
-- 🎯 4. PEMANTAU SKILLCHECK GUI REALTIME DI LAYAR HP
-- =========================================================================
local pGui = LocalPlayer:WaitForChild("PlayerGui", 10)
local lastSCDump = 0

RunService.RenderStepped:Connect(function()
    if not isInspectorRunning or not pGui then return end
    
    local scGui = pGui:FindFirstChild("SkillCheckPromptGui")
    if not scGui then
        for _, child in pairs(pGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Enabled and string.find(string.lower(child.Name), "skill") then
                scGui = child
                break
            end
        end
    end
    
    if scGui and scGui.Enabled then
        local now = tick()
        if now - lastSCDump >= 2.5 then
            lastSCDump = now
            AppendLog(string.format("🎯 [SKILLCHECK VISIBLE] GUI: %s", scGui.Name))
            for _, obj in ipairs(scGui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local rotStr = obj.Rotation ~= 0 and string.format(" Rot: %.0f°", obj.Rotation) or ""
                    AppendLog(string.format("  ├── [%s] '%s'%s", obj.ClassName, obj.Name, rotStr))
                end
            end
        end
    end
end)

-- =========================================================================
-- 🗡️ 5. PEMANTAU ALAT & ANIMASI DI HP
-- =========================================================================
local function HookChar(char)
    if not char then return end
    char.ChildAdded:Connect(function(c)
        if not isInspectorRunning then return end
        if c:IsA("Tool") or c:IsA("Model") then
            AppendLog(string.format("🗡️ [EQUIPPED] '%s' (%s)", c.Name, c.ClassName))
        end
    end)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local anim = hum:WaitForChild("Animator", 5)
        if anim then
            anim.AnimationPlayed:Connect(function(tr)
                if not isInspectorRunning then return end
                local id = tr.Animation and tr.Animation.AnimationId or ""
                local cleanId = string.match(tostring(id), "%d+") or tostring(id)
                -- Hanya log jika bukan animasi jalan biasa
                if cleanId ~= "180435571" and cleanId ~= "180435792" and cleanId ~= "180436148" then
                    AppendLog(string.format("🎬 [ANIM] ID: %s", cleanId))
                end
            end)
        end
    end
end

if LocalPlayer.Character then HookChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookChar)

-- =========================================================================
-- ✋ 6. PEMANTAU PROXIMITY PROMPT & INTERAKSI GENERATOR DI HP
-- =========================================================================
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
    if not isInspectorRunning then return end
    if player == LocalPlayer then
        local pName = prompt.Parent and prompt.Parent.Name or "unknown"
        AppendLog(string.format("✋ [HOLD PROMPT] '%s' (%s) -> %s", tostring(prompt.ActionText), tostring(prompt.ObjectText), pName))
    end
end)
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if not isInspectorRunning then return end
    if player == LocalPlayer then
        local pName = prompt.Parent and prompt.Parent.Name or "unknown"
        AppendLog(string.format("✅ [TRIGGER PROMPT] '%s' (%s) -> %s", tostring(prompt.ActionText), tostring(prompt.ObjectText), pName))
    end
end)

-- Pemantau ketukan layar saat SkillCheck muncul di HP
UserInputService.InputBegan:Connect(function(input, gpe)
    if not isInspectorRunning then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
        if pGui then
            local scGui = pGui:FindFirstChild("SkillCheckPromptGui")
            if scGui and scGui.Enabled then
                AppendLog(string.format("👆 [TAP/KEY SAAT SKILLCHECK] Type: %s (GPE: %s)", tostring(input.UserInputType.Name), tostring(gpe)))
            end
        end
    end
end)

-- Dump awal daftar remote generator yang ada
local function DumpGeneratorRemotes()
    local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if RemotesFolder then
        local genFolder = RemotesFolder:FindFirstChild("Generator")
        if genFolder then
            AppendLog("📦 [LIST REMOTES.GENERATOR]:")
            for _, r in ipairs(genFolder:GetChildren()) do
                AppendLog(string.format("  ├── [%s] %s", r.ClassName, r.Name))
            end
        end
    end
end
task.defer(DumpGeneratorRemotes)

AppendLog("🚀 Siap! Perbaiki generator atau gunakan skill di HP, lalu tekan tombol [📋 COPY ALL LOGS].")
