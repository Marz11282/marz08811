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

-- [MARZ0881] Detection Engine
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- [MARZ0881] Alert System
local Win = Rayfield:CreateWindow({
   Name = "⚡ Marz0881 Radar Lightning",
   LoadingTitle = "Marz0881 Rada đang được khởi tạo",
   KeySystem = false
})

local T1 = Win:CreateTab("⚡ Marz0881 Lightning Radar")

local AlertToggle = false
local lastAlert = 0

T1:CreateToggle({
   Name = "⚡ Bật Marz0881 Radar",
   CurrentValue = false,
   Callback = function(v) AlertToggle = v end,
})

T1:CreateParagraph({
    Title = "📌 Hướng Dẫn Ra-đa Sét",
    Content = "Ra-đa sẽ báo 4 lần, lần 3 hãy hái nhé!\nĐừng trồng cùng với người khác như vậy sẽ lỗi script."
})

-- Sound Pre-load
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://9118823101"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

-- [MARZ0881] Notification System
local function triggerWarning(msg)
   local now = os.clock()
   if now - lastAlert < 1.5 then return end
   lastAlert = now

   alertSound:Play()
   Rayfield:Notify({
      Title = "⚡ Marz0881 Radar",
      Content = msg or "⚡ Phát hiện tín hiệu sét! Hãy chuẩn bị!",
      Duration = 3
   })
end

-- CẢNH BÁO TÍCH ĐIỆN TẠI NÔNG TRẠI
WS.DescendantAdded:Connect(function(child)
   if not AlertToggle then return end
   if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then
      triggerWarning("⚡ Phát hiện tín hiệu sét! Hãy chuẩn bị!")
   end
end)

-- [MARZ0881] Debug Mode
local DebugMode = false
local DebugToggle = T1:CreateToggle({
   Name = "🔍 Lightning Debug Mode",
   CurrentValue = false,
   Callback = function(v) DebugMode = v end,
})

if DebugMode then
   local function logDebugInfo(object, changeType)
      local timestamp = os.clock()
      local objectPath = object:GetFullName()
      local objectClass = object.ClassName
      local objectAttributes = {}
      for _, attr in ipairs(object:GetAttributes()) do
         table.insert(objectAttributes, attr)
      end

      print(string.format("[DEBUG] Timestamp: %.3f, Object: %s, Class: %s, ChangeType: %s, Attributes: %s",
         timestamp, objectPath, objectClass, changeType, table.concat(objectAttributes, ", ")))
   end

   WS.DescendantAdded:Connect(function(child)
      if DebugMode then
         logDebugInfo(child, "Added")
      end
   end)

   WS.DescendantRemoving:Connect(function(child)
      if DebugMode then
         logDebugInfo(child, "Removed")
      end
   end)

   WS.DescendantChanged:Connect(function(child, property)
      if DebugMode then
         logDebugInfo(child, "Changed: " .. property)
      end
   end)
end
