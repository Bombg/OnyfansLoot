local OfLootDrops = CreateFrame("Frame")

OfLootDrops:RegisterEvent("CHAT_MSG_LOOT")
OfLootDrops:RegisterEvent("CHAT_MSG_SYSTEM")
OfLootDrops:SetScript("OnEvent", function ()
    local chatMsg = arg1
    local lineId = arg2 -- If this is unique across clients I can probably use this to my advantage
    if IsInRaid() and event == "CHAT_MSG_LOOT" then
        local regex = "(%a-) receive"
        if string.find(chatMsg, regex) then
            local playerName, itemLink = GetNameItemLinkFromLootMsg(chatMsg)
            local hexColor, itemString, itemName = GetItemLinkParts(itemLink)
            local itemId, enchantId, suffixId, uniqueId = GetItemStringParts(itemString)
            itemName = string.lower(itemName)
            local raidKey = GetRaidKey()
            local itemToPersonTable  = {}
            itemToPersonTable[itemName] = string.lower(playerName)
            AddToListDrops(itemName, raidKey, itemToPersonTable)
            AddToDrops(raidKey, itemToPersonTable)
        end
    end
    if event == "CHAT_MSG_SYSTEM" then
        local message = arg1
        if IsMsgRaidItemTrade(message) then
            local regex ="(.-) trades item (.-) to (.*)."
            local raidKey = GetRaidKey()
            local giver, item, receiver = string.match(message, regex)
            giver = string.lower(giver)
            item = string.lower(item)
            receiver = string.lower(receiver)
            local hasDropped, dropIndex = HasThisLootDroppedThisRaid(raidKey, item, giver)
            if hasDropped then
                OfDrops[raidKey][dropIndex][item] = receiver
            end
        end
    end
end)