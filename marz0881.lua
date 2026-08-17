-- // MARZ0881 RADAR LIGHTNING //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Win = Rayfield:CreateWindow({
   Name = "⚡ Marz0881 Radar Lightning",
   LoadingTitle = "Khởi tạo hệ thống Radar...",
   KeySystem = false
})

local T1 = Win:CreateTab("📡 Radar Quét Sét")

local AlertToggle = false
local lastAlert = 0

T1:CreateToggle({
   Name = "Bật Cảm Biến Radar",
   CurrentValue = false,
   Callback = function(v) AlertToggle = v end,
})

T1:CreateParagraph({
    Title = "📌 Hướng Dẫn Sử Dụng Radar", 
    Content = "⚡ Radar sẽ phát tín hiệu cảnh báo 5 lần. Hãy chuẩn bị thu hoạch ở lần thứ 4!\n⚠️ Lưu ý: Tuyệt đối không trồng cùng khu vực với người khác để tránh gây nhiễu và lỗi hệ thống radar."
})

-- Sound Pre-load
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://4522604245"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

local function triggerWarning(msg)
   local now = os.clock()
   if now - lastAlert < 1.5 then return end
   lastAlert = now
   
   alertSound:Play()
   Rayfield:Notify({
      Title = "📡 RADAR CẢNH BÁO!",
      Content = msg or "⚡ Phát hiện bức xạ sét trên cây!",
      Duration = 3
   })
end

-- CẢNH BÁO TÍCH ĐIỆN TẠI NÔNG TRẠI
WS.DescendantAdded:Connect(function(child)
   if not AlertToggle then return end
   
   -- Tối ưu hóa: Tránh xử lý dư thừa nếu radar đang trong thời gian cooldown
   if os.clock() - lastAlert < 1.5 then return end 
   
   if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
      -- Gọi cảnh báo NGAY LẬP TỨC để triệt tiêu độ trễ (delay)
      triggerWarning("⚡ Phát hiện bức xạ sét trên cây!")
      
      -- Giữ nguyên task.wait(0.05) theo yêu cầu bắt buộc của Main
      task.wait(0.05)
   end
end)
