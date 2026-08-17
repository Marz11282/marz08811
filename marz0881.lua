--============================================================--
--                 MARZ0881 RADAR LIGHTNING                   --
--============================================================--
-- Copyright © 2026 Marz0881
-- All Rights Reserved.
--
-- Official Marz0881 project.
-- Unauthorized redistribution, modification or rebranding
-- is not permitted without written permission from Marz0881.
--============================================================--

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--============================================================--
-- MARZ0881 CONFIGURATION
--============================================================--
local CONFIG = {
    -- Core detection classes (keep original)
    DetectionTypes = {
        "Highlight",
        "SelectionBox",
        "Beam",
        "ParticleEmitter"
    },
    -- Additional heuristic keywords for names/paths
    SuspiciousKeywords = {
        "Lightning", "Strike", "Thunder", "Storm", "Charge",
        "Electric", "Bolt", "Flash", "Warning", "Alarm"
    },
    CooldownSeconds = 1.5,
    NotificationDuration = 3,
    SoundVolume = 4,
    SoundId = "rbxassetid://9120346630",
    -- Max debug logs to keep in memory
    MaxDebugLogs = 50,
}

--============================================================--
-- MARZ0881 RADAR STATE
--============================================================--
local Radar = {
    Enabled = false,
    LastAlertTime = 0,
    AlertCount = 0,
    LogEnabled = false,      -- alert counter
    SoundMuted = false,
    DebugMode = false,       -- new debug toggle
    DebugLogs = {},          -- store recent debug logs
    DebugConnections = {},   -- store connections for cleanup
}

--============================================================--
-- MARZ0881 UI SYSTEM
--============================================================--
local MainWindow = Rayfield:CreateWindow({
    Name = "⚡ Marz0881 Radar Lightning",
    LoadingTitle = "Marz0881 Rada đang được khởi tạo",
    KeySystem = false,
})

-- Tab: Main Radar
local RadarTab = MainWindow:CreateTab("⚡ Marz0881 Lightning Radar")

RadarTab:CreateToggle({
    Name = "⚡ Bật Marz0881 Radar",
    CurrentValue = false,
    Callback = function(value)
        Radar.Enabled = value
        if value then
            -- Perform one-time scan for existing signals
            scanExistingSignals()
        end
    end,
})

RadarTab:CreateParagraph({
    Title = "📌 Hướng dẫn Radar Lightning",
    Content = [[
Hệ thống Marz0881 Radar Lightning theo dõi các tín hiệu điện từ trong môi trường.
Khi phát hiện hiệu ứng báo hiệu, bạn sẽ nhận được cảnh báo cùng âm thanh.

⚡ Phản hồi nhanh.
⚡ Chống spam cảnh báo.
⚡ Hoạt động local trên thiết bị của bạn.
⚡ Debug Mode giúp xác định tín hiệu chính xác.

Developed by Marz0881 – All Rights Reserved.
]]
})

-- Tab: Private Radar (local features)
local PrivateTab = MainWindow:CreateTab("⚡ Marz0881 Private Radar")

PrivateTab:CreateToggle({
    Name = "📊 Ghi nhận số lần cảnh báo",
    CurrentValue = false,
    Callback = function(value)
        Radar.LogEnabled = value
    end,
})

local CountLabel = PrivateTab:CreateParagraph({
    Title = "📈 Thống kê cảnh báo",
    Content = "Số lần phát hiện tín hiệu: 0",
})

PrivateTab:CreateToggle({
    Name = "🔇 Tắt âm thanh cảnh báo",
    CurrentValue = false,
    Callback = function(value)
        Radar.SoundMuted = value
    end,
})

-- New: Debug Mode Toggle
local DebugToggle = PrivateTab:CreateToggle({
    Name = "🔍 Lightning Debug Mode",
    CurrentValue = false,
    Callback = function(value)
        Radar.DebugMode = value
        if value then
            enableDebugMode()
        else
            disableDebugMode()
        end
    end,
})

-- Label to show recent debug logs (limited)
local DebugLogLabel = PrivateTab:CreateParagraph({
    Title = "📋 Debug Log (last 5 entries)",
    Content = "No debug logs yet.",
})

-- Update debug log label
local function updateDebugLogUI()
    local logs = Radar.DebugLogs
    local count = #logs
    if count == 0 then
        DebugLogLabel:SetContent("No debug logs yet.")
        return
    end
    local recent = {}
    for i = math.max(1, count - 4), count do
        table.insert(recent, logs[i])
    end
    DebugLogLabel:SetContent(table.concat(recent, "\n"))
end

--============================================================--
-- MARZ0881 SOUND SYSTEM
--============================================================--
local AlertSound = Instance.new("Sound")
AlertSound.SoundId = CONFIG.SoundId
AlertSound.Volume = CONFIG.SoundVolume
AlertSound.Parent = SoundService

--============================================================--
-- MARZ0881 NOTIFICATION SYSTEM
--============================================================--
local function SendAlert(message)
    local now = os.clock()
    if now - Radar.LastAlertTime < CONFIG.CooldownSeconds then
        return
    end
    Radar.LastAlertTime = now

    if not Radar.SoundMuted then
        AlertSound:Play()
    end

    if Radar.LogEnabled then
        Radar.AlertCount = Radar.AlertCount + 1
        CountLabel:SetContent("Số lần phát hiện tín hiệu: " .. Radar.AlertCount)
    end

    Rayfield:Notify({
        Title = "⚡ Marz0881 Radar",
        Content = message or "Phát hiện tín hiệu sét!",
        Duration = CONFIG.NotificationDuration,
    })
end

--============================================================--
-- MARZ0881 DETECTION ENGINE (Improved)
--============================================================--

-- Helper: check if a string contains any keyword (case-insensitive)
local function containsKeyword(text, keywords)
    text = text:lower()
    for _, kw in ipairs(keywords) do
        if text:find(kw:lower()) then
            return true
        end
    end
    return false
end

-- Helper: check if an object is likely a lightning signal using heuristics
local function IsLightningSignal(obj)
    if not obj then return false end

    -- 1. Check if class matches detection types
    for _, typeName in ipairs(CONFIG.DetectionTypes) do
        if obj:IsA(typeName) then
            return true
        end
    end

    -- 2. Check name for suspicious keywords
    if containsKeyword(obj.Name, CONFIG.SuspiciousKeywords) then
        return true
    end

    -- 3. Check parent path for suspicious keywords
    local path = obj:GetFullName()
    if containsKeyword(path, CONFIG.SuspiciousKeywords) then
        return true
    end

    -- 4. Check attributes for suspicious keys
    local attrs = obj:GetAttributes()
    for key, _ in pairs(attrs) do
        if containsKeyword(key, CONFIG.SuspiciousKeywords) then
            return true
        end
    end

    -- 5. For ParticleEmitter/Beam, check if Enabled is true (they might be disabled normally)
    if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
        -- we can check Enabled property if exists, but it's often true by default
        -- we'll treat any instance as potential if it appears newly
        return true
    end

    return false
end

-- Core detection handler for new descendants
local function handleNewDescendant(child)
    if not Radar.Enabled then return end

    if IsLightningSignal(child) then
        -- Debug log if mode is on
        if Radar.DebugMode then
            local logMsg = string.format("[%s] Potential signal: %s (%s)",
                os.clock(), child:GetFullName(), child.ClassName)
            table.insert(Radar.DebugLogs, logMsg)
            if #Radar.DebugLogs > CONFIG.MaxDebugLogs then
                table.remove(Radar.DebugLogs, 1)
            end
            updateDebugLogUI()
            print(logMsg)
        end

        -- Trigger alert
        SendAlert("Phát hiện hiệu ứng báo hiệu trên cây! (Marz0881)")
    end
end

-- Scan for existing signals when radar is turned on
local function scanExistingSignals()
    if not Radar.Enabled then return end
    -- We'll iterate over all descendants of Workspace
    local candidates = {}
    for _, child in ipairs(Workspace:GetDescendants()) do
        if IsLightningSignal(child) then
            table.insert(candidates, child)
        end
    end
    if #candidates > 0 then
        -- Send a single alert for existing signals (with cooldown protection)
        SendAlert("Phát hiện tín hiệu sét đang tồn tại! (Marz0881)")
    end
end

-- Connect to Workspace events
Workspace.DescendantAdded:Connect(handleNewDescendant)

--============================================================--
-- MARZ0881 DEBUG MODE (Advanced logging)
--============================================================--

-- Store debug connections for cleanup
local debugConnections = {}

local function enableDebugMode()
    if Radar.DebugMode == false then return end
    -- Clear old connections
    disableDebugMode()

    -- 1. Log RemoteEvent fires
    local function hookRemoteEvent(remote)
        if remote:IsA("RemoteEvent") then
            local conn = remote.OnClientEvent:Connect(function(...)
                if not Radar.DebugMode then return end
                local args = {...}
                local argStr = table.concat(args, ", ")
                local logMsg = string.format("[%s] RemoteEvent fired: %s | Args: %s",
                    os.clock(), remote:GetFullName(), argStr)
                table.insert(Radar.DebugLogs, logMsg)
                if #Radar.DebugLogs > CONFIG.MaxDebugLogs then
                    table.remove(Radar.DebugLogs, 1)
                end
                updateDebugLogUI()
                print(logMsg)
            end)
            table.insert(debugConnections, conn)
        end
    end

    -- Hook all existing RemoteEvents in ReplicatedStorage and Workspace
    local function scanForRemotes(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                hookRemoteEvent(obj)
            end
        end
    end
    scanForRemotes(ReplicatedStorage)
    scanForRemotes(Workspace)
    -- Also listen for new RemoteEvents being added
    local function onNewRemote(child)
        if child:IsA("RemoteEvent") then
            hookRemoteEvent(child)
        end
    end
    ReplicatedStorage.ChildAdded:Connect(onNewRemote)
    Workspace.ChildAdded:Connect(onNewRemote)

    -- 2. Log property changes on ParticleEmitter/Beam (Enabled)
    local function watchProperty(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
            local conn = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                if not Radar.DebugMode then return end
                local logMsg = string.format("[%s] Property changed: %s.Enabled = %s",
                    os.clock(), obj:GetFullName(), tostring(obj.Enabled))
                table.insert(Radar.DebugLogs, logMsg)
                if #Radar.DebugLogs > CONFIG.MaxDebugLogs then
                    table.remove(Radar.DebugLogs, 1)
                end
                updateDebugLogUI()
                print(logMsg)
            end)
            table.insert(debugConnections, conn)
        end
    end

    -- Watch existing objects and new ones
    for _, obj in ipairs(Workspace:GetDescendants()) do
        watchProperty(obj)
    end
    Workspace.DescendantAdded:Connect(function(child)
        watchProperty(child)
    end)

    print("[Marz0881 Debug] Debug Mode enabled. Logging remote events and property changes.")
end

local function disableDebugMode()
    for _, conn in ipairs(debugConnections) do
        conn:Disconnect()
    end
    debugConnections = {}
    -- Clear debug logs if desired? We'll keep them.
end

--============================================================--
-- MARZ0881 INITIALIZATION
--============================================================--
print("⚡ Marz0881 Radar Lightning loaded successfully.")
