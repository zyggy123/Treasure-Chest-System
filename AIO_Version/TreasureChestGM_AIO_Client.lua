local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MyHandlers = AIO.AddHandlers("TreasureChestGM", {})

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[TCS-GM]|r " .. msg)
end

local function SendChestCommand(cmd)
    -- Send directly to server via AIO network instead of chat
    AIO.Handle("TreasureChestGM", "ExecuteCommand", cmd)
end

--------------------------------------------------------------------------
-- Confirmation popups for destructive commands
--------------------------------------------------------------------------
StaticPopupDialogs["TCSGM_CONFIRM_CLEAR"] = {
    text = "Clear ALL treasure chest loot and gold?",
    button1 = "Clear",
    button2 = "Cancel",
    OnAccept = function() SendChestCommand("#chest clear") end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["TCSGM_CONFIRM_CLEANUP"] = {
    text = "Despawn ALL treasure chests from the world and database?",
    button1 = "Cleanup",
    button2 = "Cancel",
    OnAccept = function() SendChestCommand("#chest cleanup") end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

--------------------------------------------------------------------------
-- Main panel
--------------------------------------------------------------------------
local panel = CreateFrame("Frame", "TreasureChestGM_Panel", UIParent)
panel:SetSize(340, 420)
panel:SetPoint("CENTER")
panel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 11, top = 11, bottom = 11 },
})
panel:SetMovable(true)
panel:EnableMouse(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", panel.StartMoving)
panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
panel:SetClampedToScreen(true)
panel:SetFrameStrata("HIGH")
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", panel, "TOP", 0, -15)
title:SetText("Treasure Chest - GM Control")

local closeBtn = CreateFrame("Button", "TCSGM_CloseBtn", panel, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)

--------------------------------------------------------------------------
-- Helper: square icon quick-command button
--------------------------------------------------------------------------
local function CreateIconButton(parent, icon, tooltipText, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(36, 36)
    local ntex = btn:CreateTexture(nil, "ARTWORK")
    ntex:SetTexture(icon)
    ntex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    ntex:SetAllPoints(btn)
    btn:SetNormalTexture(ntex)

    local ptex = btn:CreateTexture(nil, "ARTWORK")
    ptex:SetTexture(icon)
    ptex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    ptex:SetAllPoints(btn)
    btn:SetPushedTexture(ptex)
    
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetAllPoints(btn)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tooltipText, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", onClick)
    return btn
end

-- Quick command row: Spawn / List / Cleanup / Hint
local iconRow = {}
local icons = {
    { icon = "Interface\\Icons\\INV_Box_01", tip = "Spawn chest at your location\n(#chest spawn)",
      onClick = function() SendChestCommand("#chest spawn") end },
    { icon = "Interface\\Icons\\INV_Misc_Book_09", tip = "List current chest loot & gold\n(#chest list)",
      onClick = function() SendChestCommand("#chest list") end },
    { icon = "Interface\\Icons\\Spell_Holy_DispelMagic", tip = "Despawn all chests from world + DB\n(#chest cleanup)",
      onClick = function() StaticPopup_Show("TCSGM_CONFIRM_CLEANUP") end },
    { icon = "Interface\\Icons\\INV_Misc_QuestionMark", tip = "Show the hint\n(#chest hint - works for everyone)",
      onClick = function() SendChestCommand("#chest hint") end },
}

for i, data in ipairs(icons) do
    local b = CreateIconButton(panel, data.icon, data.tip, data.onClick)
    if i == 1 then
        b:SetPoint("TOPLEFT", panel, "TOPLEFT", 40, -45)
    else
        b:SetPoint("LEFT", iconRow[i - 1], "RIGHT", 15, 0)
    end
    iconRow[i] = b
end

--------------------------------------------------------------------------
-- Section helpers
--------------------------------------------------------------------------
local function SectionLabel(text, x, y)
    local fs = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

local editBoxCounter = 0
local function CreateEditBox(width, anchor, xOff, yOff, numeric)
    editBoxCounter = editBoxCounter + 1
    local eb = CreateFrame("EditBox", "TCSGM_EditBox" .. editBoxCounter, panel, "InputBoxTemplate")
    eb:SetSize(width, 20)
    eb:SetPoint("TOPLEFT", panel, "TOPLEFT", xOff, yOff)
    eb:SetAutoFocus(false)
    if numeric then eb:SetNumeric(true) end
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return eb
end

--------------------------------------------------------------------------
-- Add Item section
--------------------------------------------------------------------------
local addLabel = SectionLabel("Add Item  (ID + Count)", 25, -110)

local itemIdBox = CreateEditBox(70, 0, 30, -130, true)
local itemCountBox = CreateEditBox(50, 0, 120, -130, true)
itemCountBox:SetText("1")

local addBtn = CreateFrame("Button", "TCSGM_AddBtn", panel, "UIPanelButtonTemplate")
addBtn:SetSize(70, 22)
addBtn:SetText("Add")
addBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 190, -129)
addBtn:SetScript("OnClick", function()
    local id = tonumber(itemIdBox:GetText())
    local count = tonumber(itemCountBox:GetText())
    if not id then
        Print("|cffff0000Invalid item ID.|r")
        return
    end
    count = count or 1
    SendChestCommand(string.format("#chest add %d %d", id, count))
end)

--------------------------------------------------------------------------
-- Gold section
--------------------------------------------------------------------------
local goldLabel = SectionLabel("Set Gold Reward", 25, -180)
local goldBox = CreateEditBox(90, 0, 30, -200, true)

local goldBtn = CreateFrame("Button", "TCSGM_GoldBtn", panel, "UIPanelButtonTemplate")
goldBtn:SetSize(90, 22)
goldBtn:SetText("Set Gold")
goldBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 140, -199)
goldBtn:SetScript("OnClick", function()
    local amount = tonumber(goldBox:GetText())
    if not amount or amount < 0 then
        Print("|cffff0000Invalid gold amount.|r")
        return
    end
    SendChestCommand(string.format("#chest gold %d", amount))
end)

--------------------------------------------------------------------------
-- Hint section
--------------------------------------------------------------------------
local hintLabel = SectionLabel("Set Hint Text", 25, -250)
local hintBox = CreateEditBox(230, 0, 30, -270, false)

local hintBtn = CreateFrame("Button", "TCSGM_HintBtn", panel, "UIPanelButtonTemplate")
hintBtn:SetSize(100, 22)
hintBtn:SetText("Save Hint")
hintBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 30, -295)
hintBtn:SetScript("OnClick", function()
    local text = hintBox:GetText()
    if not text or text == "" then
        Print("|cffff0000Hint text is empty.|r")
        return
    end
    SendChestCommand("#chest addhint " .. text)
    hintBox:SetText("")
    hintBox:ClearFocus()
end)

--------------------------------------------------------------------------
-- Clear section (destructive)
--------------------------------------------------------------------------
local clearBtn = CreateFrame("Button", "TCSGM_ClearBtn", panel, "UIPanelButtonTemplate")
clearBtn:SetSize(140, 26)
clearBtn:SetText("Clear All Loot")
clearBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -25, 20)
clearBtn:SetScript("OnClick", function()
    StaticPopup_Show("TCSGM_CONFIRM_CLEAR")
end)

--------------------------------------------------------------------------
-- Minimap Toggle Checkbox
--------------------------------------------------------------------------
local mmToggleCb = CreateFrame("CheckButton", "TCSGM_MinimapToggleCb", panel, "UICheckButtonTemplate")
mmToggleCb:SetSize(26, 26)
mmToggleCb:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 25, 20)
_G[mmToggleCb:GetName() .. "Text"]:SetText("Minimap Icon")
mmToggleCb:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    TreasureChestGM_DB.minimapHidden = not isChecked
    if TreasureChestGM_DB.minimapHidden then
        TreasureChestGM_MinimapButton:Hide()
    else
        TreasureChestGM_MinimapButton:Show()
    end
end)

--------------------------------------------------------------------------
-- Minimap button
--------------------------------------------------------------------------
TreasureChestGM_DB = TreasureChestGM_DB or {}
local minimapBtn = CreateFrame("Button", "TreasureChestGM_MinimapButton", Minimap)
minimapBtn:SetSize(31, 31)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)
minimapBtn:RegisterForClicks("LeftButtonUp")
minimapBtn:RegisterForDrag("LeftButton")

local mmIcon = minimapBtn:CreateTexture(nil, "BACKGROUND")
mmIcon:SetSize(20, 20)
mmIcon:SetTexture("Interface\\Icons\\INV_Box_01")
mmIcon:SetPoint("CENTER", 0, 0)

local mmOverlay = minimapBtn:CreateTexture(nil, "OVERLAY")
mmOverlay:SetSize(53, 53)
mmOverlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
mmOverlay:SetPoint("TOPLEFT", 0, 0)

local function UpdateMinimapPos()
    local angle = math.rad(TreasureChestGM_DB.minimapAngle or 200)
    local x, y = math.cos(angle) * 80, math.sin(angle) * 80
    minimapBtn:ClearAllPoints()
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

minimapBtn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        TreasureChestGM_DB.minimapAngle = math.deg(math.atan2(py - my, px - mx))
        UpdateMinimapPos()
    end)
end)
minimapBtn:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

minimapBtn:SetScript("OnClick", function()
    if panel:IsShown() then panel:Hide() else panel:Show() end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Treasure Chest GM Control")
    GameTooltip:AddLine("Click to toggle the quick command panel", 1, 1, 1)
    GameTooltip:AddLine("Drag to reposition this button", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Type /tcs minimap to hide this icon", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event)
    TreasureChestGM_DB.minimapAngle = TreasureChestGM_DB.minimapAngle or 200
    UpdateMinimapPos()
    if TreasureChestGM_DB.minimapHidden then
        minimapBtn:Hide()
        mmToggleCb:SetChecked(false)
    else
        mmToggleCb:SetChecked(true)
    end
end)

--------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------
SLASH_TREASURECHESTGM1 = "/tcs"
SLASH_TREASURECHESTGM2 = "/tcsgm"
SlashCmdList["TREASURECHESTGM"] = function(msg)
    if msg and msg:lower() == "minimap" then
        TreasureChestGM_DB.minimapHidden = not TreasureChestGM_DB.minimapHidden
        if TreasureChestGM_DB.minimapHidden then
            minimapBtn:Hide()
            mmToggleCb:SetChecked(false)
            Print("Minimap icon hidden. Type /tcs minimap to show it again.")
        else
            minimapBtn:Show()
            mmToggleCb:SetChecked(true)
            Print("Minimap icon shown.")
        end
    else
        if panel:IsShown() then panel:Hide() else panel:Show() end
    end
end

Print("loaded (AIO Version). Type /tcs to open the panel, or /tcs minimap to toggle the icon.")

-- Add handlers for server responses (if the server wants to send messages back)
function MyHandlers.PrintMessage(player, msg)
    Print(msg)
end
