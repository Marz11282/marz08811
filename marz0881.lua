-- // MARZ0881 RADAR LIGHTNING - CHUYỂN ĐỔI TỪ RAYFIELD SANG VIBE //

local Vibe = loadstring(game:HttpGet("https://raw.githubusercontent.com/vibe-ui/vibe/main/source.lua"))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Biến điều khiển radar và các chức năng mới
local AlertToggle = false
local lastAlert = 0
local logEnabled = false
local soundMuted = false
local alertCount = 0

-- Tạo cửa sổ UI với thương hiệu Marz0881
local Window = Vibe:CreateWindow({
    Title = "⚡ Marz0881 Radar Lightning",
    LoadingTitle = "Marz0881 Rada đang được khởi tạo",
    Size = UDim2.new(0, 500, 0, 400)
})

-- Tab chính: Lightning Radar
local TabMain = Window:CreateTab({
    Title = "⚡ Lightning Radar"
})

-- Toggle bật/tắt radar (giữ nguyên biến AlertToggle)
TabMain:CreateToggle({
    Text = "Bật Marz0881 Radar",
    Default = false,
    Callback = function(v)
        AlertToggle = v
    end
})

-- Hướng dẫn sử dụng, viết lại theo thương hiệu Marz0881
TabMain:CreateLabel({
    Text = [[
📌 Hướng Dẫn Radar Lightning
Radar theo dõi các hiệu ứng liên quan đến sét.
Khi phát hiện tín hiệu phù hợp, hệ thống sẽ thông báo.
Bạn sẽ nhận được cảnh báo mà không bị spam.
Công cụ thuộc hệ thống Marz0881.
]]
})

-- Tab cài đặt nâng cao (chức năng local, chỉ ảnh hưởng client)
local TabSettings = Window:CreateTab({
    Title = "⚡ Cài đặt nâng cao"
})

-- Toggle ghi log số lần cảnh báo (local)
local logToggle = TabSettings:CreateToggle({
    Text = "Chế độ ghi log cảnh báo",
    Default = false,
    Callback = function(v)
        logEnabled = v
    end
})

-- Label hiển thị số lần cảnh báo đã ghi nhận
local countLabel = TabSettings:CreateLabel({
    Text = "Số lần cảnh báo: 0"
})

-- Toggle tắt âm thanh cảnh báo (local)
TabSettings:CreateToggle({
    Text = "Tắt âm thanh cảnh báo",
    Default = false,
    Callback = function(v)
        soundMuted = v
    end
})

-- Sound cảnh báo (giữ nguyên SoundId và Volume)
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://9118823101"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

-- Hàm cảnh báo (giữ nguyên cơ chế chống spam và các giá trị)
local function triggerWarning(msg)
    local now = os.clock()
    if now - lastAlert < 1.5 then return end
    lastAlert = now

    -- Phát âm thanh nếu chưa tắt
    if not soundMuted then
        alertSound:Play()
    end

    -- Ghi log nếu bật
    if logEnabled then
        alertCount = alertCount + 1
        countLabel:SetText("Số lần cảnh báo: " .. alertCount)
    end

    -- Thông báo với thương hiệu Marz0881
    Vibe:Notify({
        Title = "⚡ Marz0881 Radar",
        Description = msg or "Phát hiện hiệu ứng báo hiệu trên cây!",
        Duration = 3
    })
end

-- Sự kiện phát hiện đối tượng (giữ nguyên toàn bộ điều kiện và task.wait)
WS.DescendantAdded:Connect(function(child)
    if not AlertToggle then return end
    if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
        task.wait(0.05)  -- giữ nguyên để bảo toàn hành vi gốc
        triggerWarning("Phát hiện hiệu ứng báo hiệu trên cây!")
    end
end)
