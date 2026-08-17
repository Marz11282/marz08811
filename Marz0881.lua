-- // Marz0881 - PURE LIGHTNING ALARM (CẢI TIẾN) //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Win = Rayfield:CreateWindow({
   Name = "⚡ Marz0881 - Ra-đa Sét",
   LoadingTitle = "Đang khởi tạo Ra-đa...",
   KeySystem = false
})

local T1 = Win:CreateTab("⚡ Script dự đoán sét")

local AlertToggle = false
local lastAlert = 0
local AlertCounter = 0
local AlertLog = {}

-- Tạo âm thanh cảnh báo
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://9118823101"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

-- Hàm cảnh báo có đếm số lần
local function triggerWarning(msg, count)
   local now = os.clock()
   if now - lastAlert < 0.8 then return end
   lastAlert = now

   alertSound:Play()

   local alertMsg = msg or "Phát hiện hiệu ứng báo hiệu trên cây!"
   if count then
      alertMsg = alertMsg .. " (Lần " .. count .. "/5)"
   end

   Rayfield:Notify({
      Title = "🚨 BÁO ĐỘNG SÉT SẮP ĐÁNH!",
      Content = alertMsg,
      Duration = 3
   })
end

-- Bật/Tắt Radar
T1:CreateToggle({
   Name = "Bật Ra-đa Báo Sét",
   CurrentValue = false,
   Callback = function(v) 
      AlertToggle = v
      if v then 
         AlertCounter = 0
         AlertLog = {}
         print("⚡ Marz0881 Ra-đa đã được kích hoạt. Đang quét hiệu ứng sét...")
      end
   end,
})

T1:CreateParagraph({
   Title = "📌 Hướng Dẫn Ra-đa Sét", 
   Content = "Ra-đa sẽ tự động đếm 5 lần báo hiệu. Lần 4 hãy hái nhé!\nKhông trồng cùng người khác để tránh xung đột."
})

-- **QUÉT ĐỊNH KỲ BẰNG HEARTBEAT (GIẢM DELAY)**
RunService.Heartbeat:Connect(function()
   if not AlertToggle then return end

   local found = false
   for _, child in ipairs(WS:GetDescendants()) do
      if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
         if not AlertLog[child] then
            AlertLog[child] = true
            AlertCounter = AlertCounter + 1
            found = true

            triggerWarning("⚡ Phát hiện tín hiệu sét!", AlertCounter)

            if AlertCounter >= 5 then
               print("✅ Đã ghi nhận 5 tín hiệu báo sét. Chờ chu kỳ tiếp theo...")
               AlertCounter = 0
               AlertLog = {}
            end
            break
         end
      end
   end
end)
