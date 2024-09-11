local OfLootMaster = CreateFrame("Frame")
local lootedTargetsTime = {}
local util = OnyFansLoot.util


OfLootMaster:RegisterEvent("LOOT_OPENED")
OfLootMaster:SetScript("OnEvent", function ()
    
    if event == "LOOT_OPENED" then
        local unitName = UnitName("target") or "container"
        if unitName  and not util:DoesTableContainKey(lootedTargetsTime, unitName) then
            lootedTargetsTime[unitName] = 0
        end
        if util:IsAllowedToAnnounceLoot() then
            local lootDropString = ""
            local blueDropstring = ""
            local listDrops = ""
            local isEpic = false
            for i = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
                if lootName and rarity and rarity >= OnyFansLoot.minRarityForAnnouncement and not util:IsItemBlackListed(string.lower(lootName)) then
                    lootDropString = lootDropString .. GetLootSlotLink(i) .. " "
                    isEpic = true
                elseif lootName and rarity and rarity >= OnyFansLoot.minRarityToGroupWith and not util:IsItemBlackListed(string.lower(lootName)) then
                    blueDropstring = blueDropstring .. GetLootSlotLink(i) .. " "
                end
                if unitName and lootName and util:IsListItem(string.lower(lootName)) and (time() - lootedTargetsTime[unitName]) > OnyFansLoot.timeBetweenLootBroadcast and util:IsInRaid() then
                    listDrops = listDrops .. GetLootSlotLink(i)
                    ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.listDropPrefix,GetLootSlotLink(i),"GUILD")
                end
            end
            lootDropString = isEpic and lootDropString .. blueDropstring or lootDropString
            if unitName and not util:IsEmptyString(lootDropString) and (time() - lootedTargetsTime[unitName]) > OnyFansLoot.timeBetweenLootBroadcast and util:IsInRaid()  then
                lootedTargetsTime[unitName] = time()
                SendChatMessage( lootDropString,"RAID")
                if not util:IsEmptyString(listDrops) then
                    DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000List Drops|r: " .. listDrops)
                end
            end
        end
    end
end)