-- // Marz0881 - PURE LIGHTNING ALARM (FIXED V2) //
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
local isCooldown = false

-- Tạo âm thanh cảnh báo
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://9118823101"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

-- Hàm lấy cây của người chơi
local function GetPlayerTrees()
    local trees = {}
    local character = LP.Character
    if not character then return trees end

    for _, v in ipairs(WS:GetDescendants()) do
        if v:IsA("Model") and v.Name:find("Tree") or v.Name:find("Cay") then
            -- Kiểm tra xem cây có gần người chơi không (trong phạm vi 50 studs)
            local distance = (v.PrimaryPart and v.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude
            if distance < 50 then
                table.insert(trees, v)
            end
        end
    end
    return trees
end

-- Hàm cảnh báo có đếm số lần
local function triggerWarning(msg, count)
   local now = os.clock()
   if now - lastAlert < 0.8 or isCooldown then return end
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
         isCooldown = false
         print("⚡ Marz0881 Ra-đa đã được kích hoạt. Đang quét cây của bạn...")
      end
   end,
})

T1:CreateParagraph({
   Title = "📌 Hướng Dẫn Ra-đa Sét", 
   Content = "Ra-đa sẽ tự động đếm 5 lần báo hiệu trên CÂY CỦA BẠN.\nLần 4 hãy hái nhé!\nKhông trồng cùng người khác để tránh xung đột."
})

-- **QUÉT ĐỊNH KỲ BẰNG HEARTBEAT**
RunService.Heartbeat:Connect(function()
   if not AlertToggle then return end

   local playerTrees = GetPlayerTrees()
   if #playerTrees == 0 then 
      -- Nếu không có cây nào gần, reset bộ đếm
      AlertCounter = 0
      AlertLog = {}
      return 
   end

   local found = false
   for _, child in ipairs(WS:GetDescendants()) do
      if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
         -- Kiểm tra hiệu ứng này có nằm trên cây của người chơi không
         local isOnPlayerTree = false
         for _, tree in ipairs(playerTrees) do
            if child.Parent and child.Parent == tree then
               isOnPlayerTree = true
               break
            end
         end
         if isOnPlayerTree then
            if not AlertLog[child] then
               AlertLog[child] = true
               AlertCounter = AlertCounter + 1
               found = true

               triggerWarning("⚡ Phát hiện tín hiệu sét!", AlertCounter)

               if AlertCounter >= 5 then
                  print("✅ Đã ghi nhận 5 tín hiệu báo sét. Chờ chu kỳ tiếp theo...")
                  AlertCounter = 0
                  AlertLog = {}
                  isCooldown = true
                  task.wait(5) -- Cooldown 5 giây tránh báo liên tục
                  isCooldown = false
               end
               break
            end
         end
      end
   end

   -- Nếu không tìm thấy hiệu ứng mới trong 10 giây, reset bộ đếm
   if not found and #playerTrees > 0 then
      task.wait(10)
      AlertCounter = 0
      AlertLog = {}
   end
end)
