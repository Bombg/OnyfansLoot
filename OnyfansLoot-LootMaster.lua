local OfLootMaster = CreateFrame("Frame")
local minRarityForAnnouncement = 4
local timeBetweenLootBroadcast = 180
local lootedTargetsTime = {}


OfLootMaster:RegisterEvent("LOOT_OPENED")
OfLootMaster:SetScript("OnEvent", function ()
    
    if event == "LOOT_OPENED" then
        local unitName = UnitName("target")
        if not DoesTableContain(lootedTargetsTime, unitName) then
            lootedTargetsTime[unitName] = 0
        end
        if IsAllowedToAnnounceLoot() then
            local lootDropString = ""
            for i = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
                if rarity >= minRarityForAnnouncement then
                    lootDropString = lootDropString .. GetLootSlotLink(i) .. " "
                end
            end
            if not IsEmptyString(lootDropString) and (time() - lootedTargetsTime[unitName]) > timeBetweenLootBroadcast and GetNumRaidMembers() > 0  then
                lootedTargetsTime[unitName] = time()
                SendChatMessage( lootDropString,"RAID")
            end
            
        end
    end
end)