local OfLootMaster = CreateFrame("Frame")
local minRarityForAnnouncement = 4
local minRarityToGroupWith = 3
local timeBetweenLootBroadcast = 180
local lootedTargetsTime = {}


OfLootMaster:RegisterEvent("LOOT_OPENED")
OfLootMaster:SetScript("OnEvent", function ()
    
    if event == "LOOT_OPENED" then
        local unitName = UnitName("target") or "container"
        if unitName  and not DoesTableContain(lootedTargetsTime, unitName) then
            lootedTargetsTime[unitName] = 0
        end
        if IsAllowedToAnnounceLoot() then
            local lootDropString = ""
            local blueDropstring = ""
            local isEpic = false
            for i = 1, GetNumLootItems() do
                local lootIcon, lootName, lootQuantity, rarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
                if rarity >= minRarityForAnnouncement then
                    lootDropString = lootDropString .. GetLootSlotLink(i) .. " "
                    isEpic = true
                elseif rarity >= minRarityToGroupWith then
                    blueDropstring = blueDropstring .. GetLootSlotLink(i) .. " "
                end
            end
            lootDropString = isEpic and lootDropString .. blueDropstring or lootDropString
            if unitName and not IsEmptyString(lootDropString) and (time() - lootedTargetsTime[unitName]) > timeBetweenLootBroadcast and IsInRaid()  then
                lootedTargetsTime[unitName] = time()
                SendChatMessage( lootDropString,"RAID")
            end
        end
    end
end)