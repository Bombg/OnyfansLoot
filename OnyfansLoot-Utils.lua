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

function util:IsItemBlackListed(itemName)
    local itemBlackList = {
        "idol of the sun","idol of war","blue qiraji resonating crystal","idol of life","idol of death","idol of rebirth",
        "idol of strife","green qiraji resonating crystal","idol of night","large brilliant shard","idol of the sage", "yellow qiraji resonating crystal"
    }
    local isBlacklisted = false
    for i, v in ipairs(itemBlackList) do
        if string.lower(itemName) == string.lower(v) then
            isBlacklisted = true
            break
        end
    end
    return isBlacklisted
end

function util:ExportLootTablesAsString(key)
    local exportString = key .. "\n\n"
    if self:DoesTableContainKey(OfDrops, key) then
        exportString = exportString .. "List Drops:\n\n"

        for i, v in ipairs(OfDrops[key]) do
            for k, val in pairs(v) do
                exportString = exportString .. self:TitleCase(k) .. " - " .. self:TitleCase(val) .. "\n"
            end
        end
    end
    exportString = exportString .. "\n\n"
    if self:DoesTableContainKey(Drops, key) then
        exportString = exportString .. "All Drops:\n\n"
        for i, v in ipairs(Drops[key]) do
            for k, val in pairs(v) do
                if not self:IsItemBlackListed(string.lower(k)) then
                    exportString = exportString .. self:TitleCase(k) .. " - " .. self:TitleCase(val) .. "\n"
                end
            end
        end 
    end
    return exportString
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

-- Taken from https://github.com/laytya/WowLuaVanilla which took it from SuperMacro
function util:OnVerticalScroll(scrollFrame)
	local offset = scrollFrame:GetVerticalScroll();
	local scrollbar = getglobal(scrollFrame:GetName().."ScrollBar");

	scrollbar:SetValue(offset);
	local min, max = scrollbar:GetMinMaxValues();
	local display = false;
	if ( offset == 0 ) then
        getglobal(scrollbar:GetName().."ScrollUpButton"):Disable();
	else
        getglobal(scrollbar:GetName().."ScrollUpButton"):Enable();
        display = true;
	end
	if ((scrollbar:GetValue() - max) == 0) then
        getglobal(scrollbar:GetName().."ScrollDownButton"):Disable();
	else
        getglobal(scrollbar:GetName().."ScrollDownButton"):Enable();
        display = true;
	end
	if ( display ) then
		scrollbar:Show();
	else
		scrollbar:Hide();
	end
end

function util:ParseCsv(text, parent)
    local csvTable = {}
    for line in string.gfind(text, '([^\n]+)') do
        table.insert(csvTable, util:lineFromCSV(line))
    end
    ImportedTable = csvTable
    parent:Hide()
    self:CleanImportedTable()
    self:ValidateImportedTable()
end

function util:CleanImportedTable()
    local lootStartsAt = 7
    local notHeader = 2
    for i = notHeader, table.getn(ImportedTable) do
        for j = lootStartsAt, table.getn(ImportedTable[i]) do
            ImportedTable[i][j] = string.trim(ImportedTable[i][j])
            ImportedTable[i][j] = string.gsub(ImportedTable[i][j],"%[","")
            ImportedTable[i][j] = string.gsub(ImportedTable[i][j],"%]","")
        end
        if ImportedTable[i][lootStartsAt] == ImportedTable[i][lootStartsAt + 2] then
            ImportedTable[i][lootStartsAt + 2] = ""
        end
    end
end

function util:ValidateImportedTable()
    local lootStartsAt = 7
    local listsStartAt = 2
    local invalidItems = "These items are spelled incorrectly or are not on active raids loot list\nInvalid Item Names:\n\n"
    local invalidItemsDummy = "These items are spelled incorrectly or are not on active raids loot list\nInvalid Item Names:\n\n"
    for i = listsStartAt, table.getn(ImportedTable) do
        for j = lootStartsAt, table.getn(ImportedTable[i]) do
            if not self:IsEmptyString(ImportedTable[i][j]) and not self:IsValidItemName(string.lower(ImportedTable[i][j])) then
                invalidItems = invalidItems .. ImportedTable[i][1] .. ": " .. ImportedTable[i][j] .. "\n"
                ImportedTable[i][j] = ""
            end
        end
    end
    if invalidItems ~= invalidItemsDummy then
        invalidItems = invalidItems .. "\n\n These items are deleted from the list. If you want them to stay fix their spellings in the source list and reimport\n" .. 
                                        "Once you are satisfied, stage the list with the /of stage command"
        self:ShowExportFrame(invalidItems)
    else
        DEFAULT_CHAT_FRAME:AddMessage("No invalid names found")
    end
    
end

-- From https://github.com/trumpetx/ChatLootBidder
-- Convert from CSV string to table (converts a single line of a CSV file)
function util:lineFromCSV(s)
    s = s .. ','        -- ending comma
    local t = {}        -- table to collect fields
    local fieldstart = 1
    repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
        local a, c
        local i  = fieldstart
        repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
        until c ~= '"'    -- quote not followed by quote?
        if not i then error('unmatched "') end
        local f = string.sub(s, fieldstart+1, i-1)
        table.insert(t, (string.gsub(f, '""', '"')))
        fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
        local nexti = string.find(s, ',', fieldstart)
        table.insert(t, string.sub(s, fieldstart, nexti-1))
        fieldstart = nexti + 1
    end
    until fieldstart > string.len(s)
    return t
end

function Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. Dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
-- From https://github.com/trumpetx/ChatLootBidder
function util:AtlasLootLoaded()
    return (AtlasLoot_Data and AtlasLoot_Data["AtlasLootItems"]) ~= nil
end
function util:IsPartOfRaidLootTable(raidBossKey)
    local isValid = false
    local raidRegex = {'^MC','^BWL', '^AQ40', '^ES'} --  add '^NAX' at a later date
    for i, v in ipairs(raidRegex) do
        if string.find(raidBossKey, v) then
            isValid = true
            break
        end
    end
    return isValid
end

function util:IsValidItemName(inputName)
    -- MC, BWL, AQ40, ES, NAX
    local lootQueryIndex = 3
    local isValid = false
    if  self:AtlasLootLoaded() then
        for raidBossKey,raidBoss in AtlasLoot_Data["AtlasLootItems"] do
            if self:IsPartOfRaidLootTable(raidBossKey) then
                for i, v in ipairs(raidBoss) do
                    local quality, itemName = string.match(v[lootQueryIndex], '^=q(%d)=(.-)$')
                    if itemName and string.lower(itemName) == string.lower(inputName) then
                        isValid = true
                        break
                    end
                end
            end
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Cannot validate list without |cffFF0000AtlasLoot|r installed.")
    end
    return isValid
end

function util:ShowExportFrame(exportText)
    ExportFrameEditBox1:SetFont("Fonts\\FRIZQT__.TTF", "12")
    ExportFrameEditBox1Left:Hide()
    ExportFrameEditBox1Middle:Hide()
    ExportFrameEditBox1Right:Hide()
    ExportFrameEditBox1:SetText(exportText)
    ShowUIPanel(ExportFrame, 1)
end

function util:StageImportedList()
    OnyFansLoot.isStaged = true
    StagedOfLoot = {}
    local nameLoc = 1
    local lootStartsAt = 7
    local notHeader = 2
    local version = self:GetListVersion(OfLoot)
    StagedOfLoot["version"] = {}
    StagedOfLoot["version"][1] = version + 1
    StagedOfLoot["version"][2] = date("%m-%d-%y")
    for i = notHeader, table.getn(ImportedTable) do
        for j = lootStartsAt, table.getn(ImportedTable[i]) do
            if not self:IsEmptyString(ImportedTable[i][j]) then
                local itemName = string.lower(ImportedTable[i][j])
                if self:IsTableEmpty(StagedOfLoot[itemName]) then
                    StagedOfLoot[itemName] = {}
                end
                local modifier = self:GetLootModifier(i,j)
                StagedOfLoot[itemName][ImportedTable[i][nameLoc]] = modifier
            end
        end
    end
end

function util:GetLootModifier(i,j)
    local AttendanceModifierLoc = 5
    local lootStartsAt = 7
    local modifier = 0
    if not self:IsEmptyString(ImportedTable[i][AttendanceModifierLoc]) then
        if j == lootStartsAt then
            modifier = tonumber(ImportedTable[i][AttendanceModifierLoc]) + 1
        else
            modifier = tonumber(ImportedTable[i][AttendanceModifierLoc])
        end
    end
    modifier = modifier + j  - lootStartsAt
    return modifier
end

function util:CreateItemList(lootTable, itemName)
    local lowerName = string.lower(itemName)
    local list = ""
    local listArr = {}
    local j = 1
    for k, v in pairs(lootTable[lowerName]) do
        if k ~= "version" and util:DoesTableContainKey(listArr, v + 1) then
            listArr[v + 1] = listArr[v + 1] .. k ..  ", "
        else
            listArr[v + 1] = k .. ", "
        end
    end

    for i = 1, 20 do
        if not util:IsEmptyString(listArr[i]) then
            list = list .. tostring(j) .. ": " .. listArr[i] .. "\n"
            j = j + 1
        end
    end
    return list
end

OnyFansLoot.util = util