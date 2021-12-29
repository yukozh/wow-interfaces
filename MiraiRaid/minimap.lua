local _, ADDONSELF = ...
local _G = getfenv(0)
local MiraiRaid = {}
_G.MiraiRaid = MiraiRaid
local LibStub = _G.LibStub
local MiniMapButton = {}
MiraiRaid.MiniMapButton = MiniMapButton
local MRButton = LibStub("LibDBIcon-1.0")
local TT_H_1, TT_H_2 = "|cff00FF00【Mirai】团队信息|r", string.format("|cffFFFFFFv0.9.1|r")
if not LibStub:GetLibrary("LibDataBroker-1.1", true) then return end

-- Make an LDB object
local MiniMapLDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("MiraiRaid", {
	type = "launcher",
	text = "Mirai 团队信息",
	icon = "Interface\\Icons\\spell_holy_divinespirit",
	OnTooltipShow = function(tooltip)
		tooltip:AddDoubleLine(TT_H_1, TT_H_2);
		tooltip:AddLine("【Mirai】专业的公会管理平台 https://mwow.org");
	end,
	OnClick = function(self, button)
        print(123456)
		ADDONSELF.createMiraiRaid()
		ADDONSELF.textArea:SetText(ADDONSELF.generateRaidInfo())
	end,
})

MRButton:Register("MiraiRaid", MiniMapLDB, MiraiRaid.MiniMapButton);
MRButton:Show("MiraiRaid")