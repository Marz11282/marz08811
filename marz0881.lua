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
-- [MARZ0881] Detection Engine
--============================================================--
local LIGHTNING_HINT_PATTERNS = {
    "lightning", "set", "sét", "bolt", "electric", "charge",
    "thunder", "sấm", "chớp", "sét", "báo hiệu", "warning",
    "danger", "alarm", "signal"
}

local CONTEXT_HINT_PATTERNS = {
    "farm", "nông trại", "nong trai", "tree", "cay", "cây",
    "crop", "plant", "hatch", "thu hoach"
}

local FALLBACK_CLASSES = {
    Highlight = true,
    SelectionBox = true,
    Beam = true,
    ParticleEmitter = true,
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

local function containsAny(text, patterns)
    local lowerText = string.lower(text)
    for _, pattern in ipairs(patterns) do
        if string.find(lowerText, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function isFallbackLightningClass(instance)
    return FALLBACK_CLASSES[instance.ClassName] == true
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

local function validateFallbackSignal(instance)
    if not isFallbackLightningClass(instance) then
        return false
    end

    local pathText = instance:GetFullName() .. " " .. instance.ClassName
    local nameHint = containsAny(pathText, LIGHTNING_HINT_PATTERNS)
    local contextHint = containsAny(pathText, CONTEXT_HINT_PATTERNS)
    local attrHint = hasLightningAttributes(instance)

    local score = 2
    if nameHint then score = score + 3 end
    if contextHint then score = score + 1 end
    if attrHint then score = score + 2 end

    return score >= 4
end

local function isPreLightningAttribute(attrName, attrValue)
    local text = tostring(attrName) .. " " .. tostring(attrValue)
    return containsAny(text, LIGHTNING_HINT_PATTERNS)
end

--============================================================--
-- [MARZ0881] Debug & Attribute Tracking
--============================================================--
local connectedAttributeSignals = {}
local connectionMap = {}
local lastKnownAttributes = {}

local function debugLog(category, message)
    if not DebugMode then return end
    warn("[Marz0881 Debug] " .. category .. "\n" .. message)
end

local function shouldLogDescendantAdded(child)
    if DEBUG_INTEREST_CLASSES[child.ClassName] then
        return true
    end
    if containsAny(child:GetFullName(), DEBUG_INTEREST_PATTERNS) then
        return true
    end
    if next(child:GetAttributes()) ~= nil then
        return true
    end
    return false
end

local function shouldLogAttribute(instance, attrName, newValue)
    if containsAny(instance:GetFullName(), DEBUG_INTEREST_PATTERNS) then
        return true
    end
    local text = tostring(attrName) .. " " .. tostring(newValue)
    if containsAny(text, DEBUG_INTEREST_PATTERNS) then
        return true
    end
    if containsAny(instance.ClassName, DEBUG_INTEREST_PATTERNS) then
        return true
    end
    return false
end

local function connectAttributeListener(instance)
    if connectedAttributeSignals[instance] then return end
    connectedAttributeSignals[instance] = true

    lastKnownAttributes[instance] = instance:GetAttributes()

    local connection
    connection = instance.AttributeChanged:Connect(function(attrName)
        local oldValue = lastKnownAttributes[instance] and lastKnownAttributes[instance][attrName]
        local newValue = instance:GetAttribute(attrName)
        lastKnownAttributes[instance][attrName] = newValue

        if DebugMode then
            if shouldLogAttribute(instance, attrName, newValue) then
                debugLog("Attribute Changed", string.format(
                    "Time: %.3f\nPath: %s\nAttribute: %s\nOld: %s\nNew: %s",
                    os.clock(),
                    instance:GetFullName(),
                    tostring(attrName),
                    tostring(oldValue),
                    tostring(newValue)
                ))
            end
        end

        if not AlertToggle then return end

        if isPreLightningAttribute(attrName, newValue) then
            triggerWarning("⚡ Tín hiệu Lightning chuẩn bị xuất hiện trên cây!\nHãy chuẩn bị phản ứng.")
        end
    end)

    connectionMap[instance] = connection

    instance.Destroying:Connect(function()
        if connectionMap[instance] then
            connectionMap[instance]:Disconnect()
            connectionMap[instance] = nil
            connectedAttributeSignals[instance] = nil
            lastKnownAttributes[instance] = nil
        end
    end)
end

-- Attach to existing descendants
task.defer(function()
    for _, desc in ipairs(WS:GetDescendants()) do
        connectAttributeListener(desc)
    end
end)

-- Handle new descendants
WS.DescendantAdded:Connect(function(child)
    connectAttributeListener(child)

    if DebugMode then
        if shouldLogDescendantAdded(child) then
            local attrs = child:GetAttributes()
            local attrInfo = ""
            for key, value in pairs(attrs) do
                attrInfo = attrInfo .. "\n  " .. tostring(key) .. " = " .. tostring(value)
            end
            debugLog("Possible Pre-Lightning Signal", string.format(
                "Time: %.3f\nPath: %s\nClass: %s%s",
                os.clock(),
                child:GetFullName(),
                child.ClassName,
                attrInfo
            ))
        end
    end

    if not AlertToggle then return end

    -- Fallback detection for effect classes
    if isFallbackLightningClass(child) and validateFallbackSignal(child) then
        triggerWarning("⚡ Tín hiệu Lightning được phát hiện!\nHãy chuẩn bị phản ứng.")
    end
end)

-- Initial scan for existing pre-lightning attributes
local function initialScanForPreLightning()
    if not AlertToggle then return end

    task.defer(function()
        for _, desc in ipairs(WS:GetDescendants()) do
            if not AlertToggle then break end
            local attrs = desc:GetAttributes()
            for attrName, attrValue in pairs(attrs) do
                local text = tostring(attrName) .. " " .. tostring(attrValue)
                if containsAny(text, LIGHTNING_HINT_PATTERNS) then
                    local loweredValue = string.lower(tostring(attrValue))
                    local isActiveWarning = not (
                        string.find(loweredValue, "normal", 1, true) or
                        string.find(loweredValue, "idle", 1, true) or
                        string.find(loweredValue, "false", 1, true) or
                        string.find(loweredValue, "none", 1, true) or
                        string.find(loweredValue, "off", 1, true) or
                        string.find(loweredValue, "0", 1, true)
                    )
                    if isActiveWarning then
                        triggerWarning("⚡ Tín hiệu Lightning chuẩn bị (tồn tại từ trước).")
                        return
                    end
                end
            end
        end
    end)
end

--============================================================--
-- [MARZ0881] UI
--============================================================--
T1:CreateToggle({
    Name = "⚡ Bật Marz0881 Radar",
    CurrentValue = false,
    Callback = function(v)
        AlertToggle = v
        if v then
            initialScanForPreLightning()
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
    end,
})

counterParagraph = T2:CreateParagraph({
    Title = "📊 Alert Counter",
    Content = "Số lần cảnh báo: 0"
})
