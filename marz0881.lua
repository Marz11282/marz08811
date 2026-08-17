-- // MARZ0881 RADAR LIGHTNING //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Win = Rayfield:CreateWindow({
   Name = "⚡ Marz0881 Radar Lightning",
   LoadingTitle = "Đang khởi tạo Marz0881 Radar...",
   KeySystem = false
})

local T1 = Win:CreateTab("⚡ Radar Cảnh Báo Sét")

local AlertToggle = false
local lastAlert = 0

T1:CreateToggle({
   Name = "Bật Ra-đa Quét Sét",
   CurrentValue = false,
   Callback = function(v) AlertToggle = v end,
})

T1:CreateParagraph({
    Title = "📌 Hướng Dẫn Marz0881 Radar", 
    Content = "Radar sẽ cảnh báo 5 lần, đến lần thứ 4 hãy chuẩn bị hái!\n⚠️ Tuyệt đối không trồng cây cùng người khác để tránh gây lỗi radar."
})

-- Sound Pre-load
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://6114955312"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

local function triggerWarning(msg)
   local now = os.clock()
   if now - lastAlert < 1.5 then return end
   lastAlert = now
   
   alertSound:Play()
   Rayfield:Notify({
      Title = "🚨 CẢNH BÁO SÉT ĐÁNH!",
      Content = msg or "⚡ Phát hiện hiệu ứng sét trên cây!",
      Duration = 3
   })
end

-- CẢNH BÁO TÍCH ĐIỆN TẠI NÔNG TRẠI
WS.DescendantAdded:Connect(function(child)
   if not AlertToggle then return end
   
   -- Fix Delay: Chặn ngay lập tức hàng chục hiệu ứng sinh ra cùng lúc, triệt tiêu lag/khựng
   if os.clock() - lastAlert < 1.5 then return end 
   
   if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
      -- Giữ nguyên task.wait(0.05) như quy tắc bắt buộc để làm bộ đệm
      task.wait(0.05)
      
      -- Fix Thông Báo Sai: Kiểm tra lại xem hiệu ứng có thực sự tồn tại trên cây hay là chiêu thức rác đã bị xóa
      if not child:IsDescendantOf(WS) then return end
      
      triggerWarning("⚡ Phát hiện tín hiệu sét trên cây!")
   end
end)
