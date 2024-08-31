local OfLootMaster = CreateFrame("Frame")
local minRarityForAnnouncement = 0
local minRarityToGroupWith = minRarityForAnnouncement - 1
local timeBetweenLootBroadcast = 180
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
            local isEpic = false
            for i = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
                if lootName and rarity and rarity >= minRarityForAnnouncement and not util:IsItemBlackListed(string.lower(lootName)) then
                    lootDropString = lootDropString .. GetLootSlotLink(i) .. " "
                    isEpic = true
                elseif lootName and rarity and rarity >= minRarityToGroupWith and not util:IsItemBlackListed(string.lower(lootName)) then
                    blueDropstring = blueDropstring .. GetLootSlotLink(i) .. " "
                end
            end
            lootDropString = isEpic and lootDropString .. blueDropstring or lootDropString
            if unitName and not util:IsEmptyString(lootDropString) and (time() - lootedTargetsTime[unitName]) > timeBetweenLootBroadcast and util:IsInRaid()  then
                lootedTargetsTime[unitName] = time()
                SendChatMessage( lootDropString,"RAID")
            end
        end
    end
end)