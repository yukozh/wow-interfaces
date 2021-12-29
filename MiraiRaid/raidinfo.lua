local _, ADDONSELF = ...

-- Generate raid info
ADDONSELF.generateRaidInfo = function()
	if not IsInRaid() then
		return "您没有在一个团队中，无法为您导出任何信息"
	end

	local ret = ""
	for i = 1, 40 do
		local name, _, partyIndex, _, class, _, _, _, _, role = GetRaidRosterInfo(i)
		if name == nil or string.len(name) == 0 then
			break
		end

		local roleStr = "NONE"
		if role ~= nil then
			roleStr = role
		end
		ret = ret..name.."="..partyIndex..","..class..","..roleStr.."\r\n"
	end

	return ret
end
