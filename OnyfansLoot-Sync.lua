local OfSync = CreateFrame("Frame")
local AceComm = LibStub:GetLibrary("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
AceComm:Embed(OnyFansLoot)
AceSerializer:Embed(OnyFansLoot)
OnyFansLoot.lastBroadcast = 0
OnyFansLoot.listVersionBroadcastPrefix = "oflootlist"
OnyFansLoot.listSharePrefix = "ofloot"
OnyFansLoot.listAskPrefix = "oflootask"
OnyFansLoot.addonVersionBroadcastPrefix = "ofversion"
local versionRebroadcastTime = 180
local lastAsk = 0
local versionWarned = false
local util = OnyFansLoot.util



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

function SendLootList(sharee)
    local prio = "BULK"
    local prefix = "ofloot"
    OfLoot["version"][3] = util:NumTableEntries(OfLoot)
    local text = OnyFansLoot:Serialize(OfLoot)
    local target = nil
    DEFAULT_CHAT_FRAME:AddMessage("Sharing OF loot list with needy bitch " .. sharee)
    local destination ="GUILD" --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
    OnyFansLoot:SendCommMessage(prefix, text, destination, target)
end

OfSync:RegisterEvent("GUILD_ROSTER_UPDATE")
OfSync:RegisterEvent("CHAT_MSG_ADDON")
OfSync:SetScript("OnEvent", function ()
    if event == "GUILD_ROSTER_UPDATE"  and (time() - OnyFansLoot.lastBroadcast) > versionRebroadcastTime then
        OnyFansLoot.lastBroadcast = time()
        local listVersion = util:GetListVersion(OfLoot)
        local addonVersion = util:GetLocalAddonVersion()
        SendAddonMessage(OnyFansLoot.listVersionBroadcastPrefix, "LIST_VERSION:" .. listVersion, "GUILD")
        SendAddonMessage(OnyFansLoot.addonVersionBroadcastPrefix, "VERSION:" .. addonVersion, "GUILD")
    elseif event == "CHAT_MSG_ADDON" then
        local prefix = arg1
        local message = arg2
        local distributionType = arg3  --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
        local sender = arg4
        local localListVersion = util:GetListVersion(OfLoot)
        local addonVersion = util:GetLocalAddonVersion()
        if prefix and prefix == OnyFansLoot.listVersionBroadcastPrefix then
            local _,broadcastedListVersion = util:StrSplit(":",message)
            if tonumber(broadcastedListVersion) > localListVersion and (time() - lastAsk) > versionRebroadcastTime then
                lastAsk = time()
                SendAddonMessage(OnyFansLoot.listAskPrefix, "ASK:" .. broadcastedListVersion .. ":" .. sender, "GUILD")
            end
        elseif prefix and prefix == OnyFansLoot.listAskPrefix then
            local _,askVersion, requestFrom = util:StrSplit(":",message)
            if localListVersion == tonumber(askVersion) and requestFrom == OnyFansLoot.playerName then
                SendLootList(sender)
            end
        elseif prefix and prefix == OnyFansLoot.addonVersionBroadcastPrefix then
            local _,broadcastedAddonVersion = util:StrSplit(":",message)
            if tonumber(broadcastedAddonVersion) > addonVersion and not versionWarned then
                DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[OnyFansLoot]|r New version available! Check OnyFans Discord")
                versionWarned = true
            end
        elseif prefix and prefix == OnyFansLoot.itemDropPrefix and OnyFansLoot.lastLootmsg ~= message then
            local _,playerName,itemId, raidKey = util:StrSplit(":",message)
            if playerName and itemId and raidKey then
                local itemName, _, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemId)
                if itemName and quality then
                    local itemToPersonTable  = {}
                    itemToPersonTable[itemName] = string.lower(playerName)
                    util:AddToListDrops(itemName, raidKey, itemToPersonTable)
                    util:AddToDrops(raidKey, itemToPersonTable, quality)
                end
            end
        end
    end
end)
