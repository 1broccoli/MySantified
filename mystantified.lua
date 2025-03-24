-- Initialize MySanctifiedDB
MySanctifiedDB = MySanctifiedDB or {}

local frame = CreateFrame("Frame", "GearCountFrame", UIParent, "BackdropTemplate")
frame:SetSize(130, 40)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetFrameStrata("HIGH")
frame:Hide()
-- Create the text variable at the top
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER")
text:SetText("Loading...")

-- Create the texture variable at the top
local texture = frame:CreateTexture(nil, "OVERLAY")
texture:SetPoint("LEFT", text, "RIGHT", 10, 0)
texture:SetSize(32, 32)

-- Create the rank text variable at the top
local rankText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rankText:SetPoint("BOTTOMLEFT", texture, "BOTTOMLEFT", 0, 0)
rankText:SetTextColor(1, 1, 1, 1)

local function UpdateSealOfTheDawnTexture()
    local buffName, _, _, count
    for i = 1, 40 do
        buffName, _, _, count = UnitBuff("player", i)
        if not buffName then break end
        if buffName == "Seal of the Dawn" then
            if (buffName:find("Damage")) then
                texture:SetTexture("Interface\\AddOns\\MySanctified\\dps.png")
            elseif (buffName:find("Healing")) then
                texture:SetTexture("Interface\\AddOns\\MySanctified\\healing.png")
            elseif (buffName:find("Threat")) then
                texture:SetTexture("Interface\\AddOns\\MySanctified\\tank.png")
            end
            rankText:SetText(count or "")
            texture:Show()
            rankText:Show()
            return
        end
    end
    texture:Hide()
    rankText:Hide()
end

local function UpdateGearCount()
    local G = _G
    local sanctifiedCount = 0
    local setItemCount = 0
    
    local setPatterns = {
        "Battlegear of Undead Purification %(2/3%)",
        "Battlegear of Undead Purification %(3/3%)",
        "Battlegear of Undead Slaying %(2/3%)",
        "Battlegear of Undead Slaying %(3/3%)",
        "Battlegear of Undead Warding %(2/3%)",
        "Battlegear of Undead Warding %(3/3%)",
        "Garb of the Undead Cleansing %(2/3%)",
        "Garb of the Undead Cleansing %(3/3%)",
        "Garb of the Undead Purifier %(2/3%)",
        "Garb of the Undead Purifier %(3/3%)",
        "Garb of the Undead Slayer %(2/3%)",
        "Garb of the Undead Slayer %(3/3%)",
        "Garb of the Undead Warder %(2/3%)",
        "Garb of the Undead Warder %(3/3%)",
        "Undead Cleanser's Armor %(2/3%)",
        "Undead Cleanser's Armor %(3/3%)",
        "Undead Purifier's Armor %(2/3%)",
        "Undead Purifier's Armor %(3/3%)",
        "Undead Slayer's Armor %(2/3%)",
        "Undead Slayer's Armor %(3/3%)",
        "Undead Warder's Armor %(2/3%)",
        "Undead Warder's Armor %(3/3%)",
        "Regalia of Undead Cleansing %(2/3%)",
        "Regalia of Undead Cleansing %(3/3%)",
        "Regalia of Undead Purification %(2/3%)",
        "Regalia of Undead Purification %(3/3%)",
        "Regalia of Undead Warding %(2/3%)",
        "Regalia of Undead Warding %(3/3%)"
    }
    
    for slot = 0, 16 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local tooltip = CreateFrame("GameTooltip", "SanctifiedScanner" .. slot, nil, "GameTooltipTemplate")
            tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
            tooltip:SetInventoryItem("player", slot)
            
            local foundSetItem = false  
            local foundSanctifiedText = false  
            
            for lineIndex = 1, tooltip:NumLines() do
                local lineText = G["SanctifiedScanner" .. slot .. "TextLeft" .. lineIndex]:GetText()
                if lineText then
                    for _, pattern in ipairs(setPatterns) do
                        if lineText:match(pattern) then
                            setItemCount = setItemCount + 1
                            foundSetItem = true
                            break
                        end
                    end
                end
                if foundSetItem then
                    break
                end
            end
            
            if not foundSetItem then
                for lineIndex = 1, tooltip:NumLines() do
                    local lineText = G["SanctifiedScanner" .. slot .. "TextLeft" .. lineIndex]:GetText()
                    if lineText and lineText:lower():find("sanctified") then
                        foundSanctifiedText = true
                        break
                    end
                end
            end
            
            if foundSetItem or foundSanctifiedText then
                sanctifiedCount = sanctifiedCount + 1
            end
            
            tooltip:Hide()
        end
    end
    
    if setItemCount >= 2 then
        sanctifiedCount = sanctifiedCount + 2
    end
    
    local textColor
    if sanctifiedCount == 0 then
        textColor = "FFFFFFFF"   
    elseif sanctifiedCount >= 1 and sanctifiedCount <= 8 then
        textColor = "FF00FF00"  
    else
        textColor = "FFFF0000"   
    end
    
    text:SetText(string.format("|cFF34FDF0Total Sanctified:|r |c%s%d|r", textColor, sanctifiedCount))
end

-- Create the settings frame
local settingsFrame = CreateFrame("Frame", "SettingsFrame", UIParent, "BackdropTemplate")
settingsFrame:SetSize(200, 140)
settingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Centered initially
settingsFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
settingsFrame:SetBackdropColor(0, 0, 0, 0.8)
settingsFrame:SetBackdropBorderColor(0, 0, 0)
settingsFrame:Hide() -- Hide the frame initially

-- Make the settings frame movable
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", settingsFrame.StartMoving)
settingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
settingsFrame:SetClampedToScreen(true)

-- Title text for the settings frame
local settingsTitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
settingsTitle:SetPoint("TOP", settingsFrame, "TOP", 0, -10)
settingsTitle:SetText("|cFF00FF00Settings|r") -- Green color

-- Close button for the settings frame
local closeButton = CreateFrame("Button", nil, settingsFrame)
closeButton:SetSize(24, 24)
closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -5, -5)
closeButton:SetNormalTexture("Interface\\AddOns\\MySanctified\\close.png")
closeButton:SetScript("OnClick", function()
    settingsFrame:Hide()
end)
closeButton:SetScript("OnEnter", function(self)
    self:GetNormalTexture():SetVertexColor(1, 0, 0) -- Red color on highlight
end)
closeButton:SetScript("OnLeave", function(self)
    self:GetNormalTexture():SetVertexColor(1, 1, 1) -- Reset color
end)

-- Scale slider
local scaleSlider = CreateFrame("Slider", "ScaleSlider", settingsFrame, "OptionsSliderTemplate")
scaleSlider:SetWidth(180)
scaleSlider:SetHeight(16)
scaleSlider:SetPoint("TOP", settingsTitle, "BOTTOM", 0, -30)
scaleSlider:SetMinMaxValues(0.5, 2)
scaleSlider:SetValueStep(0.1)
scaleSlider:SetValue(1)
_G[scaleSlider:GetName() .. 'Low']:SetText('1')
_G[scaleSlider:GetName() .. 'High']:SetText('100')
_G[scaleSlider:GetName() .. 'Text']:SetText('Text Scale')
scaleSlider:SetScript("OnValueChanged", function(self, value)
    text:SetScale(value)
    MySanctifiedDB.textScale = value
    frame:SetSize(200 * value, 50 * value) -- Adjust frame size with text scale
end)

-- Alpha slider
local alphaSlider = CreateFrame("Slider", "AlphaSlider", settingsFrame, "OptionsSliderTemplate")
alphaSlider:SetWidth(180)
alphaSlider:SetHeight(16)
alphaSlider:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -20)
alphaSlider:SetMinMaxValues(0, 1)
alphaSlider:SetValueStep(0.1)
alphaSlider:SetValue(1)
_G[alphaSlider:GetName() .. 'Low']:SetText('0')
_G[alphaSlider:GetName() .. 'High']:SetText('100')
_G[alphaSlider:GetName() .. 'Text']:SetText('Text Alpha')
alphaSlider:SetScript("OnValueChanged", function(self, value)
    local r, g, b = text:GetTextColor()
    text:SetTextColor(r, g, b, value)
    MySanctifiedDB.textAlpha = value
end)

frame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        if settingsFrame:IsShown() then
            settingsFrame:Hide()
        else
            settingsFrame:Show()
        end
    end
end)

local function SaveFramePosition()
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    MySanctifiedDB = MySanctifiedDB or {}
    MySanctifiedDB.point = point
    MySanctifiedDB.relativePoint = relativePoint
    MySanctifiedDB.xOfs = xOfs
    MySanctifiedDB.yOfs = yOfs
    MySanctifiedDB.textScale = MySanctifiedDB.textScale or 1
    MySanctifiedDB.textAlpha = MySanctifiedDB.textAlpha or 1
end

local function LoadFramePosition()
    if MySanctifiedDB then
        frame:SetPoint(MySanctifiedDB.point, UIParent, MySanctifiedDB.relativePoint, MySanctifiedDB.xOfs, MySanctifiedDB.yOfs)
        text:SetScale(MySanctifiedDB.textScale)
        scaleSlider:SetValue(MySanctifiedDB.textScale)
        frame:SetSize(200 * MySanctifiedDB.textScale, 50 * MySanctifiedDB.textScale) -- Adjust frame size with text scale
        text:SetTextColor(1, 1, 1, MySanctifiedDB.textAlpha)
        alphaSlider:SetValue(MySanctifiedDB.textAlpha)
    else
        frame:SetPoint("CENTER")
    end
end

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveFramePosition()
    UpdateGearCount()
end)

frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MySanctified" then
        LoadFramePosition()
        UpdateGearCount() -- Update gear count when addon is loaded
    elseif event == "UNIT_AURA" and arg1 == "player" then
        UpdateSealOfTheDawnTexture()
        UpdateGearCount()
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateGearCount()
    else
        UpdateGearCount()
    end
end)

if CharacterFrame then
    CharacterFrame:HookScript("OnShow", function()
        frame:Show() -- Show the frame when the Character Frame is shown
    end)

    CharacterFrame:HookScript("OnHide", function()
        frame:Hide() -- Hide the frame when the Character Frame is hidden
    end)
end

-- Call UpdateGearCount immediately after creating the frame to update the text
UpdateGearCount()