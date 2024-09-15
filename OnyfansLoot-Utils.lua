if OnyFansLoot.util then return end
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

util.IsAllowedToImport = function (self)
    local allowed = false
    for i,v in ipairs(OnyFansLoot.allowedGuildRanks) do
        if self:GetGuildRank("player") == GuildControlGetRankName(v) then
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

function util:IsListItem(itemName)
    return self:DoesTableContainKey(OfLoot, itemName)
end

function util:IsPlayerListItem(itemName)
    return self:DoesTableContainKey(OfLoot, itemName) and self:DoesTableContainKey(OfLoot[itemName], string.lower(OnyFansLoot.playerName))
end

util.AddToListDrops = function (self,itemName, raidKey, itemToPersonTable)
    if itemName and itemToPersonTable and self:DoesTableContainKey(OfLoot, itemName) then
        local playerName = itemToPersonTable[itemName]
        playerName = string.lower(playerName)
        if self:DoesTableContainKey(OfLoot[itemName], playerName) then
            if not self:DoesTableContainKey(OfDrops, raidKey) then
                OfDrops[raidKey] = {}
            end
            table.insert(OfDrops[raidKey], itemToPersonTable)
            self:AddToListExclusions(itemName,playerName)
        end
    end
end

util.AddToDrops = function (self,raidKey, itemToPersonTable, quality)
    if quality and itemToPersonTable and raidKey and quality >= OnyFansLoot.minQualityToLogLoot then
        if not self:DoesTableContainKey(Drops, raidKey) then
            Drops[raidKey] = {}
        end
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
    local itemBlackList = OnyFansLoot.blackList
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
            if string.lower(ImportedTable[i][j]) == 'locked' then
                ImportedTable[i][j] = ""
            end
        end
        if string.lower(ImportedTable[i][lootStartsAt]) == string.lower(ImportedTable[i][lootStartsAt + 2]) then -- if -1 and 1 are the same then remove the 1. (since 1 gets upgraded to -1)
            ImportedTable[i][lootStartsAt + 2] = ""
        end
    end
end

function util:GetInvalidGuildMemberNames()
    local invalidNames = "Mispselled player names, or not on guild roster: \n\n"
    local invalidNamesDummy = "Mispselled player names, or not on guild roster: \n\n"
    local invalidNamesFooter = "\n\n Please fix player name mispellings in source list and reimport\n\n---------------------------------------------------------------------------------\n"
    local listsStartAt = 2
    for i = listsStartAt, table.getn(ImportedTable) do
        local playerName = string.lower(ImportedTable[i][1])
        if not self:IsValidPlayerName(playerName) then
            invalidNames = invalidNames .. playerName .. "\n"
        end
    end
    if invalidNames == invalidNamesDummy then invalidNames = nil else invalidNames = invalidNames .. invalidNamesFooter end
    return invalidNames
end

function util:GetInvalidItemNames()
    local lootStartsAt = 7
    local listsStartAt = 2
    local invalidItems = "---------------------------------------------------------------------------------\nThese items are spelled incorrectly or are not on active raids loot list\n\nInvalid Item Names:\n\n"
    local invalidItemsDummy = "---------------------------------------------------------------------------------\nThese items are spelled incorrectly or are not on active raids loot list\n\nInvalid Item Names:\n\n"
    local invalidItemsFooter =  "\n\n These items are deleted from the list. If you want them to stay fix their spellings in the source list and reimport\n" .. 
                                        "Once you are satisfied, stage the list with the /of stage command\n\n---------------------------------------------------------------------------------\n"
    for i = listsStartAt, table.getn(ImportedTable) do
        for j = lootStartsAt, table.getn(ImportedTable[i]) do
            if not self:IsEmptyString(ImportedTable[i][j]) and not self:IsValidItemName(string.lower(ImportedTable[i][j])) then
                invalidItems = invalidItems .. ImportedTable[i][1] .. ": " .. ImportedTable[i][j] .. "\n"
                ImportedTable[i][j] = ""
            end
        end
    end
    if invalidItems == invalidItemsDummy then invalidItems = nil else invalidItems = invalidItems .. invalidItemsFooter end
    return invalidItems
end

function util:GetInvalidDates()
    local listsStartAt = 2
    local lootLiveDateInd = 3
    local oneTwoLiveDateInd = 4
    local invalidDates = "\nThese dates are not in the correct mm/dd format. Please fix them and reimport\n\n"
    local invalidDatesDummy = "\nThese dates are not in the correct mm/dd format. Please fix them and reimport\n\n"
    for i = listsStartAt, table.getn(ImportedTable) do
        local lootLiveDate = not self:IsEmptyString(ImportedTable[i][lootLiveDateInd]) and ImportedTable[i][lootLiveDateInd] or "06/11" -- Making empty string a valid date so it's ignored
        local oneTwoLiveDate = not self:IsEmptyString(ImportedTable[i][oneTwoLiveDateInd]) and ImportedTable[i][oneTwoLiveDateInd] or "06/11"
        invalidDates = not self:IsValidInputDate(lootLiveDate) and invalidDates .. lootLiveDate or invalidDates
        invalidDates = not self:IsValidInputDate(oneTwoLiveDate) and invalidDates .. oneTwoLiveDate or invalidDates
    end
    if invalidDates == invalidDatesDummy then invalidDates = nil  end
    return invalidDates
end

function util:ValidateImportedTable()
    local finalText = " "
    local invalidNames = self:GetInvalidGuildMemberNames()
    local invalidItems = self:GetInvalidItemNames()
    local invalidDates = self:GetInvalidDates()

    finalText = invalidItems and finalText .. invalidItems  or finalText
    finalText = invalidNames and finalText .. invalidNames  or finalText
    finalText = invalidDates and finalText .. invalidDates or finalText
    
    if finalText ~= " " then
        self:ShowExportFrame(finalText)
    else
        DEFAULT_CHAT_FRAME:AddMessage("No invalid items,names, or dates found in import. Congrats!")
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

function util:Dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. self:Dump(v) .. ','
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
    local raidRegex = {'^MC','^BWL', '^AQ40', '^ES', '^NAX'} 
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
                if modifier then
                    local playerName = self:GetStagedPlayerName(itemName,i)
                    StagedOfLoot[itemName][playerName] = modifier
                end
            end
        end
    end
end

function util:GetStagedPlayerName(itemName, i)
    local numLootSlots = 10
    local nameLoc = 1
    local playerName = string.lower(ImportedTable[i][nameLoc])
    if  StagedOfLoot[itemName][playerName] ~= nil then
        for k = 2, numLootSlots do
            playerName = playerName .. " "
            if  StagedOfLoot[itemName][playerName] == nil then
                break
            end
        end
    end
    return playerName
end

function util:GetLootModifier(i,j)
    local AttendanceModifierLoc = 5
    local lootStartsAt = 7
    local lootLivePos = 3
    local oneTwoLivePos = 4
    local modifier = nil
    if not self:IsEmptyString(ImportedTable[i][AttendanceModifierLoc])  then
        modifier = 0
        if j == lootStartsAt then
            modifier = tonumber(ImportedTable[i][AttendanceModifierLoc]) + 1 -- +1 because people's #1 goes from 1 to -1, skipping 0
        else
            modifier = tonumber(ImportedTable[i][AttendanceModifierLoc])
        end
        modifier = modifier + j  - lootStartsAt
    else
        modifier = j  - lootStartsAt
    end
    if j >= lootStartsAt and j <= lootStartsAt + 3 and not util:IsInputDatePassed(ImportedTable[i][oneTwoLivePos]) or not util:IsInputDatePassed(ImportedTable[i][lootLivePos]) then
        modifier = nil
    end
    return modifier
end

function util:IsInputDatePassed(inputDate) 
    local isPassed = true
    local maximumDifference = 800
    if self:IsValidInputDate(inputDate) then
        local inMonth, inDay = util:StrSplit("/", inputDate)
        if string.len(inDay) == 1 then
            inDay = "0" .. inDay
        end
        local inNumber = tonumber(inMonth .. inDay)
        local month = date("%m")
        local day = date("%d")
        local dNumber = tonumber(month .. day)
        if dNumber < inNumber or dNumber - inNumber > maximumDifference then -- taking into account when month is currently 12 but next month is 1. Dates still need to be cleared up in list once passed to avoid long term issues
            isPassed = false
        end
    end
    return isPassed
end

function util:IsValidInputDate(inputDate) -- mm/dd mm/d m/dd m/d
    local isValid = false
    if inputDate then
        local inMonth, inDay = util:StrSplit("/", inputDate)
        if inMonth and inDay then
            if tonumber(inMonth) < 13 and tonumber(inMonth) > 0 and tonumber(inDay) < 32 and tonumber(inDay) > 0 then
                isValid = true
            end
        end
    end
    return isValid
end

function util:GetSortedTableByValue(tab)
    local t = {}
    local usedKeys = {}
    for n in pairs(tab) do
        local min = 99999
        local minKey
        for k, v in pairs(tab) do
            if v  < min and usedKeys[k] == nil then
                min = v
                minKey = k
            end
        end
        if minKey then
            usedKeys[minKey] = true
            table.insert(t,minKey)
        end
        
    end
    return t
end

function util:PairsByModifier (t)
    local a = self:GetSortedTableByValue(t)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

function util:IsNameExcluded(playerName, itemName, excludedIndexes)
    local isExcluded = false
    local index
    if not ListExclusions and not playerName and not itemName and not excludedIndexes then return end
    for i = 1 , table.getn(ListExclusions) do
        if excludedIndexes[i] == nil and playerName == ListExclusions[i]["playerName"] and itemName == ListExclusions[i]["itemName"] then
            isExcluded = true
            index = i
        end
    end
    return isExcluded, index
end

function util:CreateItemList(lootTable, itemName)
    itemName = string.lower(itemName)
    local list = ""
    local listArr = {}
    local j = 1
    local excludeIndexes = {}
    for k, v in self:PairsByModifier(lootTable[itemName]) do
        local playerName = string.gsub(k," ", "")
        local isExcluded, index = self:IsNameExcluded(playerName, itemName,excludeIndexes)
        if index then excludeIndexes[index] = true end
        if not isExcluded then
            if k ~= "version" and util:DoesTableContainKey(listArr, v + 1) then
                listArr[v + 1] = listArr[v + 1] .. playerName ..  ", " -- +1 because v starts at 0
            else
                listArr[v + 1] = playerName .. ", "
            end
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

function util:IsValidPlayerName(playerName)
    local isValid = false
    if not playerName then return end
    if not OnyFansLoot.guildRoster then
        self:PopulateGuildRoster()
    end
    for i, v in ipairs(OnyFansLoot.guildRoster) do
        if string.lower(playerName) == string.lower(v) then
            isValid = true
            break
        end
    end
    return isValid
end

function util:PopulateGuildRoster()
    local turnOff = false
    if not OnyFansLoot.guildRoster then
        OnyFansLoot.guildRoster = {}
    end
    if not GetGuildRosterShowOffline() then
        SetGuildRosterShowOffline(true)
        turnOff = true
    end
    for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
        table.insert(OnyFansLoot.guildRoster, string.lower(name))
    end
    if turnOff then
        SetGuildRosterShowOffline(false)
    end
end

function GetMainName(playerName)
    local mainName
    if not playerName then return end
    playerName = string.lower(playerName)
    if OnyFansLoot.altList[playerName] ~= nil then
        mainName = OnyFansLoot.altList[playerName]
    end
    return mainName
end

function util:IsOnList(playerName)
    local isOnList = false
    local mainName = GetMainName(playerName)
    if not OfLoot or not playerName then return end
    playerName = mainName and string.lower(mainName) or string.lower(playerName)
    for k, v in pairs(OfLoot) do
        for key, val in pairs(v) do
            if playerName == string.lower(key) then
                isOnList = true
                break
            end
        end
    end
    return isOnList
end

function util:IsValueInTable(table, value)
    local isContained = false
    local key
    for k, v in pairs(table) do
        if v == value then
            isContained = true
            key = k
            break
        end
    end
    return isContained, key
end

function IsSpellInSpellBook(inputSpellName)
    local i = 1
    local spellName = " "
    local spellRank
    local isInBook = false
    while spellName do
        spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
        if spellName and string.lower(spellName) == string.lower(inputSpellName) then
            isInBook = true
        end
        i = i + 1
    end
    return isInBook
end

function util:IsDisenchantedRaidItem(itemName,chatMsg)
    local isDERaidItem = false
    local minDETime = 3
    local youGotString = "You receive"
    if OnyFansLoot.lastDisenchantTime and OnyFansLoot.lastDisenchantedItem and string.find(chatMsg, youGotString) then
        local timeSinceDESpell = GetTime() - OnyFansLoot.lastDisenchantTime
        if string.lower(itemName) == "nexus crystal" or string.lower(itemName) == "large brilliant shard" and timeSinceDESpell >= minDETime then
            isDERaidItem = true
        end
    end
    return isDERaidItem
end

function util:GetFirstUnstagedListItem(startFrom, playerNameRow)
    local oneTwoStartsAt = 9
    local startingIndex = oneTwoStartsAt - 1 + startFrom
    local listItem
    local goTo = startFrom < 3 and 10 or table.getn(ImportedTable[playerNameRow])
    for  i= startingIndex, goTo do
        if not util:IsEmptyString(ImportedTable[playerNameRow][i]) then
            listItem = ImportedTable[playerNameRow][i]
            break
        end
    end
    return listItem
end

function util:IsMemberListItem(itemName, memberName)
    return self:DoesTableContainKey(OfLoot, string.lower(itemName)) and self:DoesTableContainKey(OfLoot[string.lower(itemName)], string.lower(memberName))
end

function util:CheckForMissingToolTips()
    local listLiveIndex = 3
    local oneTwoLiveIndex = 4
    local playerNameIndex = 1
    local nag = false
    if ImportedTable and not util:IsTableEmpty(ImportedTable) then
        for i = 2, table.getn(ImportedTable) do
            if not util:IsEmptyString(ImportedTable[i][listLiveIndex]) and util:IsInputDatePassed(ImportedTable[i][listLiveIndex]) then
                local playerName = ImportedTable[i][playerNameIndex]
                local threePlusItem =  util:GetFirstUnstagedListItem(3, i)
                if playerName and threePlusItem and not util:IsMemberListItem(string.lower(threePlusItem), string.lower(playerName)) then
                    nag = true
                    DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: |cff9482c9" .. playerName .. "'s|r list is active but they are not on tooltips. Restage and Commit, or redo the complete import process.")
                end
            end
            if not util:IsEmptyString(ImportedTable[i][oneTwoLiveIndex]) and util:IsInputDatePassed(ImportedTable[i][oneTwoLiveIndex]) then
                local playerName = ImportedTable[i][playerNameIndex]
                local oneTwoItem =  util:GetFirstUnstagedListItem(1, i)
                if playerName and oneTwoItem and not util:IsMemberListItem(string.lower(oneTwoItem), string.lower(playerName)) then
                    nag = true
                    DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: |cff9482c9" .. playerName .. "'s|r one/two is active but not on tooltips. Restage and Commit, or redo the complete import process.")
                end
            end
        end
        if nag then
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: use the |cff9482c9of clear|r command if you don't want this nag anymore or If someone else is importing lists.")
        end
    end
end

function util:GetRaidRoster()
    local raidRoster
    if util:IsInRaid() then
        raidRoster = {}
        for i = 1, GetNumRaidMembers() do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
            if name then
                raidRoster[string.lower(name)] = 1
            end
        end
    end
    return raidRoster
end

function util:GetOnlineGuildMembers()
    local onlineGuildMembers = {}
    for i = 1, GetNumGuildMembers() do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)
        if name and online and online == 1 then
            onlineGuildMembers[string.lower(name)] = 1
        end
    end
    return onlineGuildMembers
end

function util:GetRaidInviteList()
    local raidRoster = util:GetRaidRoster()
    local onlineGuildRoster = util:GetOnlineGuildMembers()
    if not onlineGuildRoster or util:IsTableEmpty(onlineGuildRoster) then return end
    if not raidRoster then raidRoster = {} end
    local inviteList = {}
    for k, v in pairs(onlineGuildRoster) do
        if raidRoster[k] == nil and util:IsOnList(k) then
            inviteList[k] = 1
        end
    end
    return inviteList
end

function util:RaidInviteListMembers()
    local inviteList = util:GetRaidInviteList()
    if not OnyFansLoot.invitedList then OnyFansLoot.invitedList = {} end
    if inviteList and not util:IsTableEmpty(inviteList) then
        for k, v in pairs(inviteList) do
            if OnyFansLoot.invitedList[k] == nil then
                InviteByName(k)
                OnyFansLoot.invitedList[k] = 1
                if GetNumPartyMembers() > 0 and not util:IsInRaid() then ConvertToRaid() end
            end
        end
    end
end

function util:Adler32(str)
    local ModAdler = 65521
    local a = 1
    local b = 0
    for i = 1, string.len(str) do
        local c = string.sub(str, i, i)
        a = a + string.byte(c)
        a = math.mod(a,ModAdler)
        b = b + a
        b = math.mod(b,ModAdler)
    end
    b = bit.lshift(b,16)
    --local hex = string.format('%x', total)
    local total = b + a
    return total
end

function util:AddToListExclusions(itemName, playerName)
    if not itemName or not playerName then return end
    itemName = string.lower(itemName)
    playerName = string.lower(playerName)
    local hours, minutes = GetGameTime()
    local exclusionItem = {}
    exclusionItem.serverTime = hours .. ":" .. minutes
    exclusionItem.itemName = itemName
    exclusionItem.playerName = playerName
    table.insert(ListExclusions, exclusionItem)
    if not ListExclusions.version then ListExclusions.version = 1 end
end

function util:GetExclusionInfo(exclusionList)
    local exclusionVersion
    local listLength
    if not util:IsTableEmpty(exclusionList) then
        listLength = table.getn(exclusionList)
    end
    if exclusionList['version'] ~= nil then
        exclusionVersion = exclusionList['version']
    end
    if not listLength then listLength = 0 end
    if not exclusionVersion then exclusionVersion = 0 end
    return listLength, exclusionVersion
end

function util:FixExclusionList(giver, receiver, item)
    if not giver or not receiver or not item or not ListExclusions then return end
    giver = string.lower(giver)
    receiver = string.lower(receiver)
    item = string.lower(item)
    local exclN = table.getn(ListExclusions)
    for i = exclN, 1, -1 do
        if ListExclusions[i]["itemName"] == item and ListExclusions[i]["playerName"] == giver then
            ListExclusions[i]["playerName"] = receiver
            break
        end
    end
end

function util:CleanLastLootMsgTab()
    for k, v in pairs(OnyFansLoot.lastLootmsgTab) do
        if GetTime() - v >= OnyFansLoot.lastLootmsgCleanTime then
            OnyFansLoot.lastLootmsgTab[k] = nil
        end
    end
end

OnyFansLoot.util = util