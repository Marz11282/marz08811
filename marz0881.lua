-- // MARZ STORM - LIGHTNING RADAR PRO //  
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()  
local WS = game:GetService("Workspace")  
local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local LP = Players.LocalPlayer  

-- Khởi tạo cửa sổ chính  
local Win = Rayfield:CreateWindow({  
   Name = "⚡ Marz Storm - Ra-đa Sét",  
   LoadingTitle = "Đang khởi tạo Ra-đa...",  
   KeySystem = false  
})  

local T1 = Win:CreateTab("⚡ Radar Tiên Tri")  

-- Biến trạng thái  
local AlertToggle = false  
local lastAlert = 0  
local AlertCounter = 0  
local AlertLog = {}  
local isCooldown = false  

-- Âm thanh độc quyền (sử dụng âm thanh Roblox, có thể thay bằng ID khác)  
local alertSound = Instance.new("Sound")  
alertSound.SoundId = "rbxassetid://9126403453"  -- ID âm thanh báo động mới  
alertSound.Volume = 5  
alertSound.Parent = game:GetService("SoundService")  

-- Hàm cảnh báo thông minh  
local function triggerWarning(msg, count)  
   local now = os.clock()  
   if now - lastAlert < 0.9 or isCooldown then return end  
   lastAlert = now  

   alertSound:Play()  

   local alertMsg = msg or "⚠️ Phát hiện tín hiệu sét trên cây!"  
   if count then  
      alertMsg = alertMsg .. " (Tín hiệu " .. count .. "/5)"  
   end  

   Rayfield:Notify({  
      Title = "⚡ CẢNH BÁO SÉT!",  
      Content = alertMsg,  
      Duration = 3  
   })  
end  

-- Giao diện người dùng  
T1:CreateToggle({  
   Name = "🔮 Kích hoạt Ra-đa Tiên Tri",  
   CurrentValue = false,  
   Callback = function(v)   
      AlertToggle = v  
      if v then   
         AlertCounter = 0  
         AlertLog = {}  
         isCooldown = false  
         print("⚡ Marz Storm: Ra-đa đã sẵn sàng!")  
      end  
   end,  
})  

T1:CreateParagraph({  
   Title = "📖 Hướng dẫn sử dụng",   
   Content = "Marz Storm sẽ theo dõi tín hiệu sét trên cây của bạn.\nKhi phát hiện, hệ thống sẽ báo TỔNG CỘNG 5 LẦN.\nLưu ý: Lần thứ 4 là thời điểm VÀNG để thu hoạch!\n⚠️ Không trồng chung với người khác để tránh nhiễu tín hiệu."  
})  

-- Hàm lấy tất cả cây trong nông trại của người chơi  
local function GetPlayerTrees()  
    local trees = {}  
    local character = LP.Character  
    if not character then return trees end  

    for _, v in ipairs(WS:GetDescendants()) do  
        if v:IsA("Model") and v:FindFirstChild("Handle") then  
            -- Kiểm tra cây có gần nhân vật không (trong phạm vi 100 studs)  
            local distance = (v:GetPivot().Position - character:GetPivot().Position).Magnitude  
            if distance < 100 then  
                table.insert(trees, v)  
            end  
        end  
    end  
    return trees  
end  

-- Hệ thống quét tín hiệu (tối ưu với Heartbeat)  
RunService.Heartbeat:Connect(function()  
   if not AlertToggle then return end  

   local playerTrees = GetPlayerTrees()  
   if #playerTrees == 0 then   
      -- Nếu không có cây, reset trạng thái  
      AlertCounter = 0  
      AlertLog = {}  
      return   
   end  

   local found = false  
   for _, child in ipairs(WS:GetDescendants()) do  
      -- Phát hiện các hiệu ứng có liên quan đến sét  
      if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") or child:IsA("Smoke") or child:IsA("Fire") then  
         -- Kiểm tra hiệu ứng có thuộc cây của người chơi không  
         local isOnPlayerTree = false  
         for _, tree in ipairs(playerTrees) do  
            if child.Parent and (child.Parent == tree or child.Parent:IsDescendantOf(tree)) then  
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
                  print("✅ Marz Storm: Đã thu thập đủ 5 tín hiệu. Chờ chu kỳ mới.")  
                  AlertCounter = 0  
                  AlertLog = {}  
                  isCooldown = true  
                  task.wait(5)  
                  isCooldown = false  
               end  
               break  
            end  
         end  
      end  
   end  

   -- Tự động reset nếu không có tín hiệu mới  
   if not found and #playerTrees > 0 then  
      task.wait(8)  
      AlertCounter = 0  
      AlertLog = {}  
   end  
end)  

-- Thông báo khởi động  
print("⚡ Marz Storm - Hệ thống Ra-đa Tiên Tri đã tải thành công!")
