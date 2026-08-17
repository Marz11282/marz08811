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
local WS = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Win = Rayfield:CreateWindow({
    Name = "⚡ Marz0881 Radar Lightning",
    LoadingTitle = "Marz0881 Rada đang được khởi tạo",
    KeySystem = false
})

local T1 = Win:CreateTab("⚡ Marz0881 Lightning Radar")
local T2 = Win:CreateTab("⚡ Marz0881 Private Radar")

--============================================================--
-- [MARZ0881] Alert System
--============================================================--
local AlertToggle = false
local lastAlert = 0
local MuteSound = false
local DebugMode = false
local alertCounter = 0

-- Sound Pre-load
local alertSound = Instance.new("Sound")
alertSound.SoundId = "rbxassetid://9118823101"
alertSound.Volume = 4
alertSound.Parent = game:GetService("SoundService")

local counterParagraph

local function updateCounterUI()
    if counterParagraph and counterParagraph.Set then
        counterParagraph:Set("📊 Alert Counter", "Số lần cảnh báo: " .. alertCounter)
    end
end

local function triggerWarning(msg)
    local now = os.clock()
    if now - lastAlert < 1.5 then return end
    lastAlert = now

    if not MuteSound then
        alertSound:Play()
    end

    alertCounter = alertCounter + 1
    updateCounterUI()

    Rayfield:Notify({
        Title = "⚡ Marz0881 Radar",
        Content = msg or "⚡ Tín hiệu Lightning được phát hiện!\nHãy chuẩn bị phản ứng.",
        Duration = 3
    })
end

--============================================================--
-- [MARZ0881] Lightning Detection
--============================================================--
local FALLBACK_CLASSES = {
    Highlight = true,
    SelectionBox = true,
    Beam = true,
    ParticleEmitter = true,
}

local LIGHTNING_HINT_PATTERNS = {
    "lightning", "set", "sét", "bolt", "electric", "charge",
    "thunder", "sấm", "chớp", "sét", "báo hiệu", "warning",
    "danger", "alarm", "signal"
}

local CONTEXT_HINT_PATTERNS = {
    "farm", "nông trại", "nong trai", "tree", "cay", "cây",
    "crop", "plant", "hatch", "thu hoach"
}

local DEBUG_INTEREST_CLASSES = {
    Highlight = true,
    SelectionBox = true,
    Beam = true,
    ParticleEmitter = true,
    Sound = true,
    Explosion = true,
    PointLight = true,
    SpotLight = true,
    SurfaceLight = true,
    Sparkles = true,
}

local DEBUG_INTEREST_PATTERNS = {
    "lightning", "set", "sét", "bolt", "electric", "charge",
    "thunder", "sấm", "chớp", "sét", "báo hiệu", "warning",
    "danger", "alarm", "signal", "effect", "spark", "beam",
    "selection", "highlight", "particle", "farm", "tree", "cay",
    "cây", "nông trại", "plant", "crop"
}

local debugAttributeConnections = {}
local debugTrackedInstances = {}

local function isFallbackLightningClass(instance)
    return FALLBACK_CLASSES[instance.ClassName] == true
end

local function containsAny(text, patterns)
    local lowerText = string.lower(text)
    for _, pattern in ipairs(patterns) do
        if string.find(lowerText, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function hasLightningAttributes(instance)
    for key, value in pairs(instance:GetAttributes()) do
        local text = tostring(key) .. " " .. tostring(value)
        if containsAny(text, LIGHTNING_HINT_PATTERNS) then
            return true
        end
    end
    return false
end

local function validateLightningSignal(instance)
    -- Giữ fallback class gốc của Reno Main nhưng bắt buộc phải có tín hiệu phụ.
    if not isFallbackLightningClass(instance) then
        return false
    end

    local pathText = instance:GetFullName() .. " " .. instance.ClassName
    local nameHint = containsAny(pathText, LIGHTNING_HINT_PATTERNS)
    local contextHint = containsAny(pathText, CONTEXT_HINT_PATTERNS)
    local attrHint = hasLightningAttributes(instance)

    local score = 2
    if nameHint then
        score = score + 3
    end
    if contextHint then
        score = score + 1
    end
    if attrHint then
        score = score + 2
    end

    -- Ngưỡng an toàn: class gốc + (tín hiệu tên lightning) hoặc class gốc + tín hiệu attribute.
    return score >= 4
end

--============================================================--
-- [MARZ0881] Debug Mode
--============================================================--
local function debugLog(category, message)
    if not DebugMode then return end
    warn("[Marz0881 Debug] " .. category .. "\n" .. message)
end

local function shouldDebugTrackAttribute(instance)
    if DEBUG_INTEREST_CLASSES[instance.ClassName] then
        return true
    end
    local pathText = instance:GetFullName()
    return containsAny(pathText, DEBUG_INTEREST_PATTERNS)
end

local function connectDebugAttributeListener(instance)
    if not DebugMode then return end
    if debugTrackedInstances[instance] then return end
    if not shouldDebugTrackAttribute(instance) then return end

    local attrs = instance:GetAttributes()
    if next(attrs) == nil then return end

    debugTrackedInstances[instance] = true

    local connection
    connection = instance.AttributeChanged:Connect(function(attrName)
        local oldValue = attrs[attrName]
        local newValue = instance:GetAttribute(attrName)

        debugLog("Attribute Changed", string.format(
            "Path: %s\nAttribute: %s\nOld: %s\nNew: %s",
            instance:GetFullName(),
            tostring(attrName),
            tostring(oldValue),
            tostring(newValue)
        ))

        attrs[attrName] = newValue
    end)

    table.insert(debugAttributeConnections, connection)
end

local function debugDisconnectAll()
    for _, connection in ipairs(debugAttributeConnections) do
        connection:Disconnect()
    end
    debugAttributeConnections = {}
    debugTrackedInstances = {}
end

local function debugConnectExisting()
    if not DebugMode then return end
    for _, desc in ipairs(WS:GetDescendants()) do
        connectDebugAttributeListener(desc)
    end
end

local function debugHandleDescendantAdded(child)
    if not DebugMode then return end

    local attrs = child:GetAttributes()
    local hasAttributes = next(attrs) ~= nil
    local isInterestingClass = DEBUG_INTEREST_CLASSES[child.ClassName] == true
    local hasInterestingPath = containsAny(child:GetFullName(), DEBUG_INTEREST_PATTERNS)

    if isInterestingClass or hasInterestingPath or hasAttributes then
        local attrInfo = ""
        for key, value in pairs(attrs) do
            attrInfo = attrInfo .. "\n  " .. tostring(key) .. " = " .. tostring(value)
        end

        debugLog("Possible Lightning Signal", string.format(
            "Time: %.3f\nPath: %s\nClass: %s%s",
            os.clock(),
            child:GetFullName(),
            child.ClassName,
            attrInfo
        ))

        connectDebugAttributeListener(child)
    end
end

--============================================================--
-- [MARZ0881] Initial Scan
--============================================================--
local function initialScanForExistingSignals()
    if not AlertToggle then return end

    task.defer(function()
        for _, desc in ipairs(WS:GetDescendants()) do
            if not AlertToggle then break end

            if isFallbackLightningClass(desc) and validateLightningSignal(desc) then
                local isActive = (desc.Enabled ~= false)
                if isActive then
                    triggerWarning("⚡ Phát hiện tín hiệu Lightning đang hoạt động trước khi bật Radar!")
                    break
                end
            end
        end
    end)
end

--============================================================--
-- [MARZ0881] Main Detection Listener
--============================================================--
WS.DescendantAdded:Connect(function(child)
    debugHandleDescendantAdded(child)

    if not AlertToggle then return end
    if not isFallbackLightningClass(child) then return end

    if validateLightningSignal(child) then
        triggerWarning("⚡ Tín hiệu Lightning được phát hiện!\nHãy chuẩn bị phản ứng.")
    end
end)

--============================================================--
-- [MARZ0881] UI
--============================================================--
T1:CreateToggle({
    Name = "⚡ Bật Marz0881 Radar",
    CurrentValue = false,
    Callback = function(v)
        AlertToggle = v
        if v then
            initialScanForExistingSignals()
        end
    end,
})

T1:CreateParagraph({
    Title = "📌 Hướng Dẫn Marz0881 Radar",
    Content = "Marz0881 Radar sẽ báo 5 lần, lần 4 hãy hái nhé!\nĐừng trồng cùng với người khác như vậy sẽ lỗi script."
})

T2:CreateToggle({
    Name = "🔇 Tắt âm thanh cảnh báo",
    CurrentValue = false,
    Callback = function(v)
        MuteSound = v
    end,
})

T2:CreateToggle({
    Name = "🔍 Lightning Debug Mode",
    CurrentValue = false,
    Callback = function(v)
        DebugMode = v
        if v then
            debugConnectExisting()
        else
            debugDisconnectAll()
        end
    end,
})

counterParagraph = T2:CreateParagraph({
    Title = "📊 Alert Counter",
    Content = "Số lần cảnh báo: 0"
})
