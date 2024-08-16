function IsTableEmpty (table)
    local isEmpty = true
    if type(table) == "table" then 
        for _, _ in pairs(table) do
            isEmpty = false
        end
    end
    return isEmpty
end

function ItemLinkToItemString(ItemLink)
    if not ItemLink then return end
    local il, _, ItemString = strfind(ItemLink, "^|%x+|H(.+)|h%[.+%]")
    return il and ItemString or ItemLink
end

function DoesTableContain(table, contains)
    local isContained = false
    if table and contains and type(table) == 'table' then
        for k, v in pairs(table) do
            if k == contains then
                isContained = true
                break
            end
        end
    end
    return isContained
end

function GetNumEntries(table, contains)
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

function NumTableEntries(table)
    local numEntries = 0
    if table and type(table) == "table" then 
        for k, v in pairs(table) do
            numEntries = numEntries + 1
        end
    end
    return numEntries
end

--pfUI.api.strsplit
function StrSplit(delimiter, subject)
    if not subject then return nil end
    local delimiter, fields = delimiter or ":", {}
    local pattern = string.format("([^%s]+)", delimiter)
    string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
    return unpack(fields)
end

function GetListVersion(table)
    local localListVersion = 0
    if not IsTableEmpty(table) and  GetNumEntries(table, "version") ~= 0 then
        localListVersion = table["version"][1]
    end
    return localListVersion
end

function GetGuildRank(playerUnitId)
    local guildName, guildRank, rankIndex  = GetGuildInfo(playerUnitId)
    return guildRank
end

function IsAllowedToHaveList() -- Tier 1's have lists so nevermind. Not quite as simple as making it rank limited. Maybe come back to this later. 1  = GM, 2 = Twitch Mod, 3 = Foot Model, 4 = Tier 2
    local allowed = false
    for i = 1,4 do
        if GetGuildRank("player") == GuildControlGetRankName(i) then
            allowed = true
            break
        end
    end
    return allowed
end
function GetLocalAddonVersion()
    --Update announcing code taken from pfUI
    local major, minor, fix = StrSplit(".", tostring(GetAddOnMetadata("OnyFansLoot", "Version")))
    local localVersion  = tonumber(major*10000 + minor*100 + fix)
    return localVersion
end

function IsRaidSetToMasterLoot()
    local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod() -- raidID doesn't work. PartyID = 0 if player is master, 1-4 if master in party. nil if not in party or not used
    local isMaster = false
    if lootmethod and lootmethod == "master" then
        isMaster = true
    end
    return isMaster
end

function IsPlayerMasterLooter()
    local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod() -- raidID doesn't work. PartyID = 0 if player is master, 1-4 if master in party. nil if not in party or not used
    local isMaster = false
    if masterlooterPartyID and masterlooterPartyID == 0 then
        isMaster = true
    end
    return isMaster
end

function IsAssistant()
    local index = GetRaidIndex(OnyFansLoot.playerName)
    local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(index)
    local IsAssistant = false
    -- 2 = raid leader, 1 = assistant, 0 normal
    if rank > 0 then
        IsAssistant =true
    end
    return IsAssistant
end

function GetRaidIndex(unitName)
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

function IsAllowedToAnnounceLoot()
    local isAllowed = false
    if IsRaidSetToMasterLoot() and IsPlayerMasterLooter() and UnitIsDead("target") == 1 then
        isAllowed = true
    end
    return isAllowed
end

function IsEmptyString(string)
    local isEmpty = false
    if string == nil or string == '' then
        isEmpty = true
    end
    return isEmpty
end