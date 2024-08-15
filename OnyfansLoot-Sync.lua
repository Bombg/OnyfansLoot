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



OnyFansLoot:RegisterComm(OnyFansLoot.listSharePrefix,function (prefix, message, distribution, sender)
    local success, data = OnyFansLoot:Deserialize(message)
    if success and GetListVersion(OfLoot) < GetListVersion(data) then
        local entries = NumTableEntries(data)
        if entries == data['version'][3] then
            print(sender .. "Sent you OF loot list Version: " .. GetListVersion(data))
            OfLoot =  data
        end
    end
end)

function SendLootList(sharee)
    local prio = "BULK"
    local prefix = "ofloot"
    OfLoot["version"][3] = NumTableEntries(OfLoot)
    local text = OnyFansLoot:Serialize(OfLoot)
    local target = nil
    print("Sharing OF loot list with needy bitch " .. sharee)
    local destination ="GUILD" --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
    OnyFansLoot:SendCommMessage(prefix, text, destination, target)
end

OfSync:RegisterEvent("GUILD_ROSTER_UPDATE")
OfSync:RegisterEvent("CHAT_MSG_ADDON")
OfSync:SetScript("OnEvent", function ()
    if event == "GUILD_ROSTER_UPDATE"  and (time() - OnyFansLoot.lastBroadcast) > versionRebroadcastTime then
        OnyFansLoot.lastBroadcast = time()
        local listVersion = GetListVersion(OfLoot)
        local addonVersion = GetLocalAddonVersion()
        SendAddonMessage(OnyFansLoot.listVersionBroadcastPrefix, "LIST_VERSION:" .. listVersion, "GUILD")
        SendAddonMessage(OnyFansLoot.addonVersionBroadcastPrefix, "VERSION:" .. addonVersion, "GUILD")
    elseif event == "CHAT_MSG_ADDON" then
        local prefix = arg1
        local message = arg2
        local distributionType = arg3  --"PARTY", "RAID", "GUILD", "BATTLEGROUND"
        local sender = arg4
        local localListVersion = GetListVersion(OfLoot)
        local addonVersion = GetLocalAddonVersion()
        if prefix and prefix == OnyFansLoot.listVersionBroadcastPrefix then
            local _,broadcastedListVersion = StrSplit(":",message)
            if tonumber(broadcastedListVersion) > localListVersion then
                SendAddonMessage(OnyFansLoot.listAskPrefix, "ASK:" .. broadcastedListVersion .. ":" .. sender, "GUILD")
            end
        elseif prefix and prefix == OnyFansLoot.listAskPrefix then
            local _,askVersion, requestFrom = StrSplit(":",message)
            if localListVersion == tonumber(askVersion) and requestFrom == OnyFansLoot.playerName then
                SendLootList(sender)
            end
        elseif prefix and prefix == OnyFansLoot.addonVersionBroadcastPrefix then
            local _,broadcastedAddonVersion = StrSplit(":",message)
            if tonumber(broadcastedAddonVersion) > addonVersion then
                DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000[OnyFansLoot]|r New version available! Check OnyFans Discord")
            end
        end
    end
end)

