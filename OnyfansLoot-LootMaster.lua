local OfLootMaster = CreateFrame("Frame")
local minRarityForAnnouncement = 4
local lastLootBroadcast = 0
local timeBetweenLootBroadcast = 180


OfLootMaster:RegisterEvent("LOOT_OPENED")
OfLootMaster:SetScript("OnEvent", function ()
    
    if event == "LOOT_OPENED" then
        if IsAllowedToAnnounceLoot() then
            local lootDropString = ""
            for i = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
                if rarity >= minRarityForAnnouncement then
                    lootDropString = lootDropString .. GetLootSlotLink(i) .. " "
                end
            end
            if not IsEmptyString(lootDropString) and (time() - lastLootBroadcast) > timeBetweenLootBroadcast  then
                lastLootBroadcast = time()
                SendChatMessage( lootDropString,"RAID")
            end
            
        end
    end
end)