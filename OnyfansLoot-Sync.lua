local OfSync = CreateFrame("Frame")
local AceComm = LibStub:GetLibrary("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
AceComm:Embed(OnyFansLoot)
AceSerializer:Embed(OnyFansLoot)
local util = OnyFansLoot.util
local sync = {}
local versionWarned = false
local lastBroadcast = 0
local lastLootListSent = 0
local lastExclusionListSent = 0
local lastLootListAsk = 0
local lastExclusionListAsk = 0

OnyFansLoot:RegisterComm(OnyFansLoot.exclusionSharePrefix,function (prefix, message, distribution, sender)
    local success, data = OnyFansLoot:Deserialize(message)
    if success  then
        local exLength, exVersion = util:GetExclusionInfo(ListExclusions)
        local imELenth, imEVersion = util:GetExclusionInfo(data)
        if imEVersion > exVersion  then
            DEFAULT_CHAT_FRAME:AddMessage(sender .. " Sent you exlustion list Version: " .. imEVersion .. " replacing list version: " .. exVersion)
            ListExclusions =  data
        elseif imEVersion == exVersion and imELenth > exLength then
            DEFAULT_CHAT_FRAME:AddMessage(sender .. "upraded your current exlusion list from " .. exLength .. " to " .. imELenth .. " items")
            ListExclusions =  data
        end
    end
end)


OnyFansLoot:RegisterComm(OnyFansLoot.listSharePrefix,function (prefix, message, distribution, sender)
    local success, data = OnyFansLoot:Deserialize(message)
    if success and util:GetListVersion(OfLoot) < util:GetListVersion(data) then
        local entries = util:NumTableEntries(data)
        if entries == data['version'][3] then
            DEFAULT_CHAT_FRAME:AddMessage(sender .. " Sent you OF loot list Version: " .. tostring(util:GetListVersion(data)) .. " Replacing list version: " .. tostring(util:GetListVersion(OfLoot)))
            OfLoot =  data
        end
    end
end)

function sync:SendLootList(sharee)
    local prio = "BULK"
    local prefix = "ofloot"
    OfLoot["version"][3] = util:NumTableEntries(OfLoot)
    local text = OnyFansLoot:Serialize(OfLoot)
    local target = nil
    DEFAULT_CHAT_FRAME:AddMessage("Sharing OF loot list with needy bitch " .. sharee)
    local destination ="GUILD" --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
    OnyFansLoot:SendCommMessage(prefix, text, destination, target)
end

function sync:SendExlusionList(sharee)
    local prio = "BULK"
    local prefix = OnyFansLoot.exclusionSharePrefix
    local text = OnyFansLoot:Serialize(ListExclusions)
    local target = nil
    DEFAULT_CHAT_FRAME:AddMessage("Sharing exclusion list with " .. sharee)
    local destination ="GUILD" --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
    OnyFansLoot:SendCommMessage(prefix, text, destination, target)
end

OfSync:RegisterEvent("GUILD_ROSTER_UPDATE")
OfSync:RegisterEvent("CHAT_MSG_ADDON")
OfSync:SetScript("OnEvent", function ()
    if event == "GUILD_ROSTER_UPDATE"  and (time() - lastBroadcast) > OnyFansLoot.rebroadcastTime then
        lastBroadcast = time()
        local listVersion = util:GetListVersion(OfLoot)
        local addonVersion = util:GetLocalAddonVersion()
        local exLength, exVersion = util:GetExclusionInfo(ListExclusions)
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.listVersionBroadcastPrefix, "LIST_VERSION:" .. listVersion, "GUILD")
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.addonVersionBroadcastPrefix, "VERSION:" .. addonVersion, "GUILD")
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.exclusionListPrefix,"EXCLUSION:" .. exLength .. ":" .. exVersion,"GUILD")
    elseif event == "CHAT_MSG_ADDON" then
        local prefix = arg1
        local message = arg2
        local distributionType = arg3  --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
        local sender = arg4
        if not prefix or not message or not sender then return end
        if prefix == OnyFansLoot.listVersionBroadcastPrefix then
            sync:AskForLootList(sender, message)
        elseif prefix == OnyFansLoot.listAskPrefix and util:IsOnList(string.lower(sender)) then
            sync:HandleLootList(sender, message)
        elseif prefix == OnyFansLoot.addonVersionBroadcastPrefix then
            sync:HandleVersionWarn(message)
        elseif prefix == OnyFansLoot.itemDropPrefix and util:IsInRaid() then
            sync:HandleItemDrop(message)
        elseif prefix == OnyFansLoot.itemCorrectionPrefix then
            sync:HandleItemCorrection(message)
        elseif prefix == OnyFansLoot.listDropPrefix then
            sync:NotifyListDrop(message)
        elseif prefix == OnyFansLoot.exclusionListPrefix then
            sync:AskForExclusionList(sender, message)
        elseif prefix == OnyFansLoot.exlusionAskPrefix and util:IsOnList(string.lower(sender)) then
            sync:HandleExclusionList(sender, message)
        end
    end
end)

function sync:HandleExclusionList(sender, message)
    local _, requestFrom = util:StrSplit(":",message)
    if OnyFansLoot.playerName == requestFrom and (time() - lastExclusionListSent) > OnyFansLoot.rebroadcastTime then
        lastExclusionListSent = time()
        sync:SendExlusionList(sender)
    end
end

function sync:AskForExclusionList(sender, message)
    local _,imELenth, imEVersion = util:StrSplit(":",message)
    local exLength, exVersion = util:GetExclusionInfo(ListExclusions)
    imELenth = tonumber(imELenth)
    imEVersion = tonumber(imEVersion)
    if imEVersion > exVersion or imEVersion == exVersion and imELenth > exLength and (time() - lastExclusionListAsk) > OnyFansLoot.rebroadcastTime then
        lastExclusionListAsk = time()
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.exlusionAskPrefix,"ASK:" .. sender,"GUILD")
    end
end

function sync:NotifyListDrop(message)
    local itemLink = message
    local hexColor, itemString, itemName = util:GetItemLinkParts(itemLink)
    if itemName and util:IsPlayerListItem(string.lower(itemName))  then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: " .. itemLink .. " Dropped. It's on your list")
    end
end

function sync:HandleItemCorrection(message)
    local giver, receiver, itemName = util:StrSplit(":",message)
    if giver and receiver and itemName then
        local hasList, hasDrop = HandleItemTransition(giver, receiver,itemName,util:GetRaidKey())
        if hasList or hasDrop then
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[OnyFansLoot]|r " .. itemName .. " went to  " .. receiver)
        end
    end
end

function sync:HandleItemDrop(message)
    util:CleanLastLootMsgTab()
    if OnyFansLoot.lastLootmsgTab[message] ~= nil then return end
    local _,playerName,itemId, raidKey = util:StrSplit(":",message)
    if playerName and itemId and raidKey and raidKey == util:GetRaidKey() then
        local itemName, _, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemId)
        if itemName and quality then
            local itemToPersonTable  = {}
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[OnyFansLoot]|r " .. playerName .. " received " .. itemName)
            OnyFansLoot.lastLootmsgTab[message] = GetTime()
            itemToPersonTable[itemName] = string.lower(playerName)
            util:AddToListDrops(itemName, raidKey, itemToPersonTable)
            util:AddToDrops(raidKey, itemToPersonTable, quality)
        end
    end
end

function sync:HandleVersionWarn(message)
    local _,broadcastedAddonVersion = util:StrSplit(":",message)
    local addonVersion = util:GetLocalAddonVersion()
    if tonumber(broadcastedAddonVersion) > addonVersion and not versionWarned then
        DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[OnyFansLoot]|r New version available! Check OnyFans Discord")
        versionWarned = true
    end
end

function sync:HandleLootList(sender, message)
    local _,askVersion, requestFrom = util:StrSplit(":",message)
    local localListVersion = util:GetListVersion(OfLoot)
    if localListVersion == tonumber(askVersion) and requestFrom == OnyFansLoot.playerName and (time() - lastLootListSent) > OnyFansLoot.rebroadcastTime then
        lastLootListSent = time()
        sync:SendLootList(sender)
    end
end

function sync:AskForLootList(sender, message)
    local _,broadcastedListVersion = util:StrSplit(":",message)
    local localListVersion = util:GetListVersion(OfLoot)
    if tonumber(broadcastedListVersion) > localListVersion and (time() - lastLootListAsk) > OnyFansLoot.rebroadcastTime then
        lastLootListAsk = time()
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.listAskPrefix, "ASK:" .. broadcastedListVersion .. ":" .. sender, "GUILD")
    end
end
