local _, ADDONSELF = ...


local RegEvent = ADDONSELF.regevent
local lootMap = ADDONSELF.loot

RegEvent("ADDON_LOADED", function()
    if not MiraiLedgerDatabase then
        MiraiLedgerDatabase = {}
    end
end)

local db = {
    ledgerItemsChangedCallback = {}
}

function db:RegisterChangeCallback(cb)
    table.insert( self.ledgerItemsChangedCallback, cb )
end

function db:OnLedgerItemsChange()
    for _, cb in pairs(self.ledgerItemsChangedCallback) do
        cb()
    end
end

local function GetConfig()
    if not MiraiLedgerDatabase["config"] then
        MiraiLedgerDatabase["config"] = {}
    end

    return MiraiLedgerDatabase["config"]
end

function db:SetConfig(key, v)
    local config = GetConfig()
    config[key] = v
end

function db:GetConfigOrDefault(key, def)
    local config = GetConfig()

    if config[key] == nil then
        config[key] = def
    end

    return config[key]
end

local MAX_LEDGER_COUNT = 1

function db:SetCurrentLedger(idx)
    MiraiLedgerDatabase["current"] = idx
end

function db:NewLedger()
    if not MiraiLedgerDatabase["ledgers"] then
        MiraiLedgerDatabase["ledgers"] = {}
    end

    local ledgers = MiraiLedgerDatabase["ledgers"]
    table.insert( ledgers, {
        ["time"] = time(),
        ["items"] = {},
    } )

    while(#ledgers > MAX_LEDGER_COUNT) do
        table.remove(ledgers, 1)
    end

    self:SetCurrentLedger(#ledgers)
    self:OnLedgerItemsChange()
end

function db:GetCurrentLedger()
    if not MiraiLedgerDatabase["ledgers"] then
        self:NewLedger()
    end

    local cur = MiraiLedgerDatabase["current"]

    return MiraiLedgerDatabase["ledgers"][cur]
end

-- TODO should global const
local TYPE_CREDIT = "CREDIT"
local TYPE_DEBIT  = "DEBIT"
local DETAIL_TYPE_ITEM = "ITEM"
local DETAIL_TYPE_CUSTOM = "CUSTOM"

local COST_TYPE_GOLD = "GOLD"
local COST_TYPE_PROFIT_PERCENT = "PROFIT_PERCENT"
local COST_TYPE_MUL_AVG = "MUL_AVG"

-- function db:GetCurrentEarning()
--     local ledger = self:GetCurrentLedger()

--     local revenue = 0
--     local expense = 0

--     for _, item in pairs(ledger["items"]) do
--         if item["type"] == TYPE_CREDIT then
--             revenue = revenue + (item["cost"] or 0)
--         elseif item["type"] == TYPE_DEBIT then
--             expense = expense + (item["cost"] or 0)
--         end
--     end

--     return revenue * 10000, expense * 10000
-- end

function db:AddEntry(type, detail, beneficiary, cost, costtype, paid)
    local ledger = self:GetCurrentLedger()

    -- Handle loot category
    local displayName = detail["displayname"]
    local item = detail.item
    if displayName then
        local category = lootMap[displayName]
        if category then
            detail["category"] = category
        end
    elseif item then
        local name = GetItemInfo(item)
        local category = lootMap[name]
        if category then
            detail["category"] = category
        end
    end

    table.insert(ledger["items"], {
        -- id = #ledger["items"] + 1,
        type = type,
        detail = detail or {},
        beneficiary = beneficiary or "",
        cost = cost or 0,
        costtype = costtype or "GOLD",
        paid = paid or 0,
    })

    self:OnLedgerItemsChange()
end

function db:RemoveEntry(idx)
    local ledger = self:GetCurrentLedger()
    table.remove(ledger["items"], idx)

    self:OnLedgerItemsChange()
end

function db:AddCredit(reason, beneficiary, cost)
    self:AddEntry(TYPE_CREDIT, {
        ["displayname"] = reason
    }, beneficiary, cost)
end

function db:AddDebit(reason, beneficiary, cost, costtype)
    self:AddEntry(TYPE_DEBIT, {
        ["displayname"] = reason
    }, beneficiary, cost, costtype)
end

local function GetFilteritemsSet(s)
    local set = {}

    s = string.gsub(s,"(#.[^\n]*\n)", "")

    for _, line in ipairs({strsplit("\n", s)}) do
        line = strtrim(line, " \t\r\n[]")
        set[line] = true

        local itemName = GetItemInfo(line)

        if itemName then
            set[itemName] = true
        end

    end

    -- kael'thas 7 weapons
    for _, line in pairs({
        30311,
        30312,
        30313,
        30314,
        30316,
        30317,
        30318,
        30319,
        30320,
    }) do
        local itemName = GetItemInfo(line)

        if itemName then
            set[itemName] = true
        end
    end

    return set
end

function db:AddOrUpdateLoot(item, count, beneficiary, cost, paid, isoutstanding)
    local itemName, itemLink, itemRarity, _, _, _, _, itemStackCount = GetItemInfo(item)

    local ledger = self:GetCurrentLedger()
    for _, entry in pairs(ledger["items"]) do
        if entry.detail then
            local update = false
            
            if entry.detail.item == itemLink and entry.paid == 0 and entry.detail.count == count then
                entry.paid = paid
                update = true
            end

            if entry.detail.item == itemLink and entry.cost == 0 and entry.detail.count == count then
                entry.beneficiary = beneficiary
                entry.cost = cost
                entry.outstanding= isoutstanding
                update = true
            end

            if update then
                self:OnLedgerItemsChange()
            end
        end
    end

    self:AddLoot(item, count, beneficiary, cost, paid, true)
end

function db:AddLoot(item, count, beneficiary, cost, paid, force)
    local itemName, itemLink, itemRarity, _, _, _, _, itemStackCount = GetItemInfo(item)
    itemStackCount = itemStackCount or 0

    local filter = self:GetConfigOrDefault("filterlevel", LE_ITEM_QUALITY_RARE)

    if not itemLink then
        return
    end

    if force then
        self:AddEntry(TYPE_CREDIT, {
            item = itemLink,
            type = DETAIL_TYPE_ITEM,
            count = count or 1,
        }, beneficiary, cost, nil, paid)
    elseif itemRarity >= filter then

        local s = GetFilteritemsSet(self:GetConfigOrDefault("filteritems", ""))

        if s[itemName] then
            return
        end

        -- TODO bad smell code
        local ledger = self:GetCurrentLedger()
        for _, entry in pairs(ledger["items"]) do
            if entry.detail then
                if entry.detail.item == itemLink and entry.beneficiary == beneficiary and entry.cost == 0 and entry.paid == 0 and itemStackCount > 1 then
                    entry.detail.count = entry.detail.count + (count or 1)
                    self:OnLedgerItemsChange()
                    return
                end
            end
        end

        self:AddEntry(TYPE_CREDIT, {
            item = itemLink,
            type = DETAIL_TYPE_ITEM,
            count = count or 1,
        }, beneficiary, cost, nil, paid)
    end
end

ADDONSELF.db = db
