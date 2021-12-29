local _, ADDONSELF = ...

-- Create Mirai Raid Frame
ADDONSELF.createMiraiRaid = function()
	if ADDONSELF.window ~= nil then
		ADDONSELF.window:Show()
		return
	end

	local window = CreateFrame("Frame", "MiraiRaidFrame", UIParent)
	-- window:Hide()

	window:SetFrameStrata("DIALOG")
	window:SetWidth(500)
	window:SetHeight(310)
	window:SetPoint("CENTER")
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetScript("OnShow", function()
		PlaySound(844) -- SOUNDKIT.IG_QUEST_LOG_OPEN
	end)
	window:SetScript("OnHide", function()
		PlaySound(845) -- SOUNDKIT.IG_QUEST_LOG_CLOSE
	end)
    ADDONSELF.window = window

	local titlebg = window:CreateTexture(nil, "BORDER")
	titlebg:SetTexture(251966) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background"
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

	local dialogbg = window:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetTexture(136548) --"Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1"
	dialogbg:SetPoint("TOPLEFT", 8, -12)
	dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
	dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

	local topleft = window:CreateTexture(nil, "BORDER")
	topleft:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	topleft:SetWidth(64)
	topleft:SetHeight(64)
	topleft:SetPoint("TOPLEFT")
	topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

	local topright = window:CreateTexture(nil, "BORDER")
	topright:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	topright:SetWidth(64)
	topright:SetHeight(64)
	topright:SetPoint("TOPRIGHT")
	topright:SetTexCoord(0.625, 0.75, 0, 1)

	local top = window:CreateTexture(nil, "BORDER")
	top:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	top:SetHeight(64)
	top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
	top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
	top:SetTexCoord(0.25, 0.369140625, 0, 1)

	local bottomleft = window:CreateTexture(nil, "BORDER")
	bottomleft:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottomleft:SetWidth(64)
	bottomleft:SetHeight(64)
	bottomleft:SetPoint("BOTTOMLEFT")
	bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

	local bottomright = window:CreateTexture(nil, "BORDER")
	bottomright:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottomright:SetWidth(64)
	bottomright:SetHeight(64)
	bottomright:SetPoint("BOTTOMRIGHT")
	bottomright:SetTexCoord(0.875, 1, 0, 1)

	local bottom = window:CreateTexture(nil, "BORDER")
	bottom:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	bottom:SetHeight(64)
	bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
	bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

	local left = window:CreateTexture(nil, "BORDER")
	left:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	left:SetWidth(64)
	left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
	left:SetTexCoord(0.001953125, 0.125, 0, 1)

	local right = window:CreateTexture(nil, "BORDER")
	right:SetTexture(251963) --"Interface\\PaperDollInfoFrame\\UI-GearManager-Border"
	right:SetWidth(64)
	right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
	right:SetTexCoord(0.1171875, 0.2421875, 0, 1)

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
	close:SetScript("OnClick", function()
		window:Hide()
	end)

	sessionLabel = CreateFrame("Button", nil, window)
	sessionLabel:SetNormalFontObject("GameFontNormalLeft")
	sessionLabel:SetHighlightFontObject("GameFontHighlightLeft")
	sessionLabel:SetPoint("TOPLEFT", titlebg, 6, -1)
	sessionLabel:SetPoint("BOTTOMRIGHT", titlebg, "BOTTOMRIGHT", -26, 1)
	sessionLabel:SetScript("OnHide", function()
		window:StopMovingOrSizing()
	end)
	sessionLabel:SetText("Mirai 团队信息导出器")

	local quickTips = "请将下字符串粘贴至报名帖设置中的导入成员中"
	sessionLabel:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -8, 8)
		GameTooltip:AddLine("Mirai 团队信息导出器")
		GameTooltip:AddLine(quickTips, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	sessionLabel:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	local scroll = CreateFrame("ScrollFrame", "MiraiRaidScroll", window, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -30, 8)

	local textArea = CreateFrame("EditBox", "MiraiRaidScrollText", scroll)
	textArea:SetTextColor(.5, .5, .5, 1)
	textArea:SetAutoFocus(false)
	textArea:SetMultiLine(true)
	textArea:SetFontObject(GameFontHighlight)
	textArea:SetMaxLetters(99999)
	textArea:EnableMouse(true)
	textArea:SetScript("OnEscapePressed", textArea.ClearFocus)
	textArea:SetWidth(450)
    ADDONSELF.textArea = textArea;

	scroll:SetScrollChild(textArea)

	window:Show()
end