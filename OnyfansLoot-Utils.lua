if OnyFansLoot.util then return end
OnyFansLoot.minQualityToLogLoot = 3
local util = {}


util.IsTableEmpty = function (self,table)
    local isEmpty = true
    if type(table) == "table" then 
        for _, _ in pairs(table) do
            isEmpty = false
        end
    end
    return isEmpty
end

util.ItemLinkToItemString = function (self,ItemLink)
    if not ItemLink then return end
    local il, _, ItemString = strfind(ItemLink, "^|%x+|H(.+)|h%[.+%]")
    return il and ItemString or ItemLink
end

util.DoesTableContainKey = function (self,table, contains)
    return table[contains] ~= nil
end

util.GetNumEntries = function (self,table, contains)
    local numEntries = 0
    if not table then return end
    if not contains then return end
    for k, v in pairs(table) do
        if k == contains then 
            for _, list in ipairs(v) do
                numEntries = numEntries + 1
            end
        end
    end
    return numEntries
end

util.NumTableEntries = function (self,table)
    local numEntries = 0
    if table and type(table) == "table" then 
        for k, v in pairs(table) do
            numEntries = numEntries + 1
        end
    end
    return numEntries
end

--pfUI.api.strsplit
util.StrSplit = function (self,delimiter, subject)
    if not subject then return nil end
    local delimiter, fields = delimiter or ":", {}
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
    return unpack(fields)
end

util.GetListVersion  = function (self,table)
    local localListVersion = 0
    if not self:IsTableEmpty(table) and  self:GetNumEntries(table, "version") ~= 0 then
        localListVersion = table["version"][1]
    end
    return localListVersion
end

util.GetGuildRank = function (self,playerUnitId)
    local guildName, guildRank, rankIndex  = GetGuildInfo(playerUnitId)
    return guildRank
end

util.IsAllowedToHaveList = function (self) -- Tier 1's have lists so nevermind. Not quite as simple as making it rank limited. Maybe come back to this later. 1  = GM, 2 = Twitch Mod, 3 = Foot Model, 4 = Tier 2
    local allowed = false
    for i = 1,4 do
        if self:GetGuildRank("player") == GuildControlGetRankName(i) then
            allowed = true
            break
        end
    end
    return allowed
end
util.GetLocalAddonVersion = function (self)
    --Update announcing code taken from pfUI
    local major, minor, fix = self:StrSplit(".", tostring(GetAddOnMetadata("OnyFansLoot", "Version")))
    local localVersion  = tonumber(major*10000 + minor*100 + fix)
    return localVersion
end

util.IsRaidSetToMasterLoot = function (self)
    local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod() -- raidID doesn't work. PartyID = 0 if player is master, 1-4 if master in party. nil if not in party or not used
    local isMaster = false
    if lootmethod and lootmethod == "master" then
        isMaster = true
    end
    return isMaster
end

util.IsPlayerMasterLooter = function (self)
    local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod() -- raidID doesn't work. PartyID = 0 if player is master, 1-4 if master in party. nil if not in party or not used
    local isMaster = false
    if masterlooterPartyID and masterlooterPartyID == 0 then
        isMaster = true
    end
    return isMaster
end

util.IsAssistant = function (self)
    local index = self:GetRaidIndex(OnyFansLoot.playerName)
    local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(index)
    local IsAssistant = false
    -- 2 = raid leader, 1 = assistant, 0 normal
    if rank > 0 then
        IsAssistant =true
    end
    return IsAssistant
end

util.GetRaidIndex = function (self,unitName)
    local raidIndex = 0
    if UnitInRaid("player") == 1 then
        for i = 1, GetNumRaidMembers() do
            if UnitName("raid"..i) == unitName then
                raidIndex = i
            end
        end
    end
    return raidIndex
end

util.IsAllowedToAnnounceLoot = function (self)
    local isAllowed = false
    if self:IsRaidSetToMasterLoot() and self:IsPlayerMasterLooter() then
        isAllowed = true
    end
    return isAllowed
end

util.IsEmptyString = function (self,string)
    local isEmpty = false
    if string == nil or string == '' then
        isEmpty = true
    end
    return isEmpty
end

util.GetNameItemLinkFromLootMsg = function (self,lootMsg)
    local regex = "(.-) receives? loot: (.-)%."
    local name, itemLink = string.match(lootMsg, regex)
    name = name ~= "You" and name or OnyFansLoot.playerName
    return name, itemLink
end

util.GetItemLinkParts = function (self,itemLink)
    local regex = "|cff(.-)|H(item:.-)|h%[(.-)%]|h|r"
    local hexColor, itemString, itemName = string.match(itemLink, regex)
    return hexColor, itemString, itemName
end

util.GetItemStringParts = function (self,ItemString)
    local regex = "item:(%d+):(%d+):(%d+):(%d+)"
    local itemId, enchantId, suffixId, uniqueId = string.match(ItemString, regex)
    return itemId, enchantId, suffixId, uniqueId
end

util.IsInRaid = function (self)
    local isInRaid = false
    if GetNumRaidMembers() > 0 then
        isInRaid = true
    end
    return isInRaid
end

util.HasThisLootDroppedThisRaid = function (self,raidKey,item,giver, table)
    local hasDropped = false
    local index = nil
    if table and raidKey and self:DoesTableContainKey(table,raidKey) and item and giver then
        for i, v in ipairs(table[raidKey]) do
            for key, val in pairs(table[raidKey][i]) do
                if string.lower(key) == string.lower(item) and string.lower(giver) == string.lower(val) then
                    hasDropped = true
                    index = i
                end
            end
        end
    end
    return hasDropped, index
end

util.IsMsgRaidItemTrade = function (self,msg)
    local isRaidItemTrade = false
    local regex ="(.-) trades item (.-) to (.*)."
    if string.find(msg,regex) then
        isRaidItemTrade = true
    end
    return isRaidItemTrade
end

util.GetRaidKey = function (self)
    local raidDate = date("%m-%d-%y")
    local zoneName = GetRealZoneText()
    local raidKey = raidDate .. " " .. zoneName
    return raidKey
end

util.AddToListDrops = function (self,itemName, raidKey, itemToPersonTable)
    if self:DoesTableContainKey(OfLoot, itemName) then
        if not self:DoesTableContainKey(OfDrops, raidKey) then
            OfDrops[raidKey] = {}
        end
        table.insert(OfDrops[raidKey], itemToPersonTable)
    end
end

util.AddToDrops = function (self,raidKey, itemToPersonTable, quality)
    if not self:DoesTableContainKey(Drops, raidKey) then
        Drops[raidKey] = {}
    end
    if quality >= OnyFansLoot.minQualityToLogLoot then
        table.insert(Drops[raidKey], itemToPersonTable)
    end
    
end

function util:GetLastNKeys(n, nTable)
    local nKeys = {}
    if type(nTable) == "table" then
        for k, v in self:PairsByKeyDate(nTable) do  
            for i=n ,2, -1 do
                nKeys[i] = nKeys[i-1]
            end
            nKeys[1] = k
        end
    end
    return nKeys
end

function util:ExportLootTablesAsString(key)
    local string = key .. "\n\n"
    if self:DoesTableContainKey(OfDrops, key) then
        string = string .. "List Drops:\n\n"

        for i, v in ipairs(OfDrops[key]) do
            for k, val in pairs(v) do
                string = string .. self:TitleCase(k) .. " - " .. self:TitleCase(val) .. "\n"
            end
        end
    end
    string = string .. "\n\n"
    if self:DoesTableContainKey(Drops, key) then
        string = string .. "All Drops:\n\n"
        for i, v in ipairs(Drops[key]) do
            for k, val in pairs(v) do
                string = string .. self:TitleCase(k) .. " - " .. self:TitleCase(val) .. "\n"
            end
        end 
    end
    return string
end

function util:TitleCase(str)
    return string.gsub(str, "(%a)([%w_']*)", util.TitleCaseHelper)
end

function util.TitleCaseHelper(first, rest )
    return string.upper(first)..string.lower(rest)
end

function util:PairsByKeyDate (t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, util.SortLootTableByDate)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

function util:PairsByKeyDateReverse (t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, util.SortLootTableByDateReverse)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

function util.SortLootTableByDate(a, b)
    local regex ="(%d+)-(%d+)-(%d+)*-"
    local amonth, aday, ayear = string.match(a, regex)
    local bmonth, bday, byear = string.match(b, regex)
    local adateNum = ayear .. amonth .. aday
    local bdateNum = byear .. bmonth .. bday
    adateNum = tonumber(adateNum)
    bdateNum = tonumber(bdateNum)
    return adateNum < bdateNum
end
function util.SortLootTableByDateReverse(a, b)
    local regex ="(%d+)-(%d+)-(%d+)*-"
    local amonth, aday, ayear = string.match(a, regex)
    local bmonth, bday, byear = string.match(b, regex)
    local adateNum = ayear .. amonth .. aday
    local bdateNum = byear .. bmonth .. bday
    adateNum = tonumber(adateNum)
    bdateNum = tonumber(bdateNum)
    return adateNum > bdateNum
end

function util:ExportDropTableKeys(dropTable)
    local keyString = "Raid Dates: \n\n"
    if type(dropTable) == "table" then
        for k, v in self:PairsByKeyDateReverse(dropTable) do 
            keyString = keyString .. k .. "\n"
        end
    end
    return keyString
end

OnyFansLoot.util = util