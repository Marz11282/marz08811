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

--[MARZ0881] Load required libraries
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")

--============================================================--
-- MARZ0881 CONFIGURATION
--============================================================--
local CONFIG = {
    -- Detection settings
    DetectionTypes = {
        "Highlight",
        "SelectionBox",
        "Beam",
        "ParticleEmitter"
    },
    -- Cooldown between alerts (seconds)
    CooldownSeconds = 1.5,
    -- Notification duration (seconds)
    NotificationDuration = 3,
    -- Alert sound volume
    SoundVolume = 4,
    -- Sound ID (lightning alert tone)
    SoundId = "rbxassetid://9120346630", -- changed to a clear short beep
}

--============================================================--
-- MARZ0881 RADAR STATE
--============================================================--
local Radar = {
    Enabled = false,
    LastAlertTime = 0,
    AlertCount = 0,
    LogEnabled = false,
    SoundMuted = false,
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

-- Toggle: Enable Radar
RadarTab:CreateToggle({
    Name = "⚡ Bật Marz0881 Radar",
    CurrentValue = false,
    Callback = function(value)
        Radar.Enabled = value
    end,
})

-- Information paragraph
RadarTab:CreateParagraph({
    Title = "📌 Hướng dẫn Radar Lightning",
    Content = [[
Hệ thống Marz0881 Radar Lightning theo dõi các tín hiệu điện từ trong môi trường.
Khi phát hiện hiệu ứng báo hiệu (Highlight, Beam, ParticleEmitter,...),
bạn sẽ nhận được cảnh báo ngay lập tức cùng âm thanh đặc trưng.

⚡ Tín hiệu phát hiện sẽ được xử lý nhanh, không gây trễ.
⚡ Chế độ chống spam đảm bảo bạn không bị làm phiền.
⚡ Hệ thống chỉ hoạt động trên thiết bị của bạn, riêng tư tuyệt đối.

Developed by Marz0881 – All Rights Reserved.
]]
})

-- Tab: Private Radar (local-only features)
local PrivateTab = MainWindow:CreateTab("⚡ Marz0881 Private Radar")

-- Toggle: Enable logging of alerts
local LogToggle = PrivateTab:CreateToggle({
    Name = "📊 Ghi nhận số lần cảnh báo",
    CurrentValue = false,
    Callback = function(value)
        Radar.LogEnabled = value
        if not value then
            -- Reset count when logging off? No, keep count.
        end
    end,
})

-- Label: Show alert count
local CountLabel = PrivateTab:CreateParagraph({
    Title = "📈 Thống kê cảnh báo",
    Content = "Số lần phát hiện tín hiệu: 0",
})

-- Toggle: Mute alert sound
PrivateTab:CreateToggle({
    Name = "🔇 Tắt âm thanh cảnh báo",
    CurrentValue = false,
    Callback = function(value)
        Radar.SoundMuted = value
    end,
})

-- Additional info about Private Radar
PrivateTab:CreateParagraph({
    Title = "🔒 Chế độ riêng tư Marz0881",
    Content = [[
Tất cả tính năng trong tab này chỉ ảnh hưởng đến bạn (client-side).
Người chơi khác trong server sẽ không nhận được cảnh báo,
không thấy UI, và không bị tác động bởi radar của bạn.
]]
})

--============================================================--
-- MARZ0881 SOUND SYSTEM
--============================================================--
local AlertSound = Instance.new("Sound")
AlertSound.SoundId = CONFIG.SoundId
AlertSound.Volume = CONFIG.SoundVolume
AlertSound.Parent = SoundService
-- Preload sound (optional but good)

--============================================================--
-- MARZ0881 NOTIFICATION SYSTEM
--============================================================--
local function SendAlert(message)
    -- Cooldown check
    local now = os.clock()
    if now - Radar.LastAlertTime < CONFIG.CooldownSeconds then
        return
    end
    Radar.LastAlertTime = now

    -- Play sound if not muted
    if not Radar.SoundMuted then
        AlertSound:Play()
    end

    -- Update statistics if logging enabled
    if Radar.LogEnabled then
        Radar.AlertCount = Radar.AlertCount + 1
        CountLabel:SetContent("Số lần phát hiện tín hiệu: " .. Radar.AlertCount)
    end

    -- Send notification with Marz0881 branding
    Rayfield:Notify({
        Title = "⚡ Marz0881 Radar",
        Content = message or "Phát hiện tín hiệu sét!",
        Duration = CONFIG.NotificationDuration,
    })
end

--============================================================--
-- MARZ0881 DETECTION ENGINE (Event-driven)
--============================================================--
local function OnDescendantAdded(child)
    -- Skip if radar disabled
    if not Radar.Enabled then
        return
    end

    -- Check if the child matches any of the detection types
    for _, typeName in ipairs(CONFIG.DetectionTypes) do
        if child:IsA(typeName) then
            -- Immediately trigger alert without artificial delay
            SendAlert("Phát hiện hiệu ứng báo hiệu trên cây! (Marz0881)")
            break
        end
    end
end

-- Connect to workspace descendant events
Workspace.DescendantAdded:Connect(OnDescendantAdded)

--============================================================--
-- MARZ0881 INITIALIZATION COMPLETE
--============================================================--
print("⚡ Marz0881 Radar Lightning loaded successfully.")
