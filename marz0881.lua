-- // MARZ0881 RADAR LIGHTNING //  
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()  
local WS = game:GetService("Workspace")  
local Players = game:GetService("Players")  
local LP = Players.LocalPlayer  

local Win = Rayfield:CreateWindow({  
   Name = "⚡ Marz0881 Radar Lightning",  
   LoadingTitle = "Đang khởi tạo Radar...",  
   KeySystem = false  
})  

local T1 = Win:CreateTab("⚡ Radar Lightning")  

local AlertToggle = false  
local lastAlert = 0  

T1:CreateToggle({  
   Name = "Bật Radar Cảnh Báo Sét",  
   CurrentValue = false,  
   Callback = function(v) AlertToggle = v end,  
})  

T1:CreateParagraph({  
    Title = "📖 Hướng Dẫn Radar Lightning",   
    Content = "Radar sẽ tự động phát hiện tín hiệu sét trên cây của bạn.\nKhi phát hiện, sẽ có 5 lần cảnh báo.\nLần thứ 4 là thời điểm vàng để thu hoạch!\n⚠️ Không trồng chung với người khác để tránh nhiễu tín hiệu."  
})  

-- Sound Pre-load  
local alertSound = Instance.new("Sound")  
alertSound.SoundId = "rbxassetid://9126403453"  
alertSound.Volume = 4  
alertSound.Parent = game:GetService("SoundService")  

local function triggerWarning(msg)  
   local now = os.clock()  
   if now - lastAlert < 1.5 then return end  
   lastAlert = now  
   
   alertSound:Play()  
   Rayfield:Notify({  
      Title = "⚡ CẢNH BÁO SÉT!",  
      Content = msg or "Phát hiện tín hiệu sét trên cây của bạn!",  
      Duration = 3  
   })  
end  

-- CẢNH BÁO TÍCH ĐIỆN TẠI NÔNG TRẠI  
WS.DescendantAdded:Connect(function(child)  
   if not AlertToggle then return end  
   if child:IsA("Highlight") or child:IsA("SelectionBox") or child:IsA("Beam") or child:IsA("ParticleEmitter") then  
      triggerWarning("Phát hiện hiệu ứng báo hiệu trên cây!")  
   end  
end)
