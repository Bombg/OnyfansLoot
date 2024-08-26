local OfLootDrops = CreateFrame("Frame")
local util = OnyFansLoot.util
OnyFansLoot.itemDropPrefix  = "ofitem"

OfLootDrops:RegisterEvent("CHAT_MSG_LOOT")
OfLootDrops:RegisterEvent("CHAT_MSG_SYSTEM")
OfLootDrops:SetScript("OnEvent", function ()
    local chatMsg = arg1
    local lineId = arg2 -- If this is unique across clients I can probably use this to my advantage
    if util:IsInRaid() and event == "CHAT_MSG_LOOT" then
        local regex = "(%a-) receive"
        if string.find(chatMsg, regex) then
            local playerName, itemLink = util:GetNameItemLinkFromLootMsg(chatMsg)
            local hexColor, itemString, itemName = util:GetItemLinkParts(itemLink)
            local itemId, enchantId, suffixId, uniqueId = util:GetItemStringParts(itemString)
            if itemName and playerName and itemId then
                local _, _, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemId)
                itemName = string.lower(itemName)
                local raidKey = util:GetRaidKey()
                local itemToPersonTable  = {}
                if not util:IsItemBlackListed(string.lower(itemName)) then
                    itemToPersonTable[itemName] = string.lower(playerName)
                    util:AddToListDrops(itemName, raidKey, itemToPersonTable)
                    util:AddToDrops(raidKey, itemToPersonTable, quality)
                    if quality and quality >= OnyFansLoot.minQualityToLogLoot then
                        OnyFansLoot.lastLootmsg =  "ITEM:" .. playerName .. ":" .. itemId .. ":" .. raidKey
                        SendAddonMessage(OnyFansLoot.itemDropPrefix, OnyFansLoot.lastLootmsg, "GUILD")
                    end
                end
            end
        end
    end
    if event == "CHAT_MSG_SYSTEM" then
        local message = arg1
        if util:IsMsgRaidItemTrade(message) then
            local regex ="(.-) trades item (.-) to (.*)."
            local raidKey = util:GetRaidKey()
            local giver, item, receiver = string.match(message, regex)
            if giver and item and receiver then
                giver = string.lower(giver)
                item = string.lower(item)
                receiver = string.lower(receiver)
                local hasListDropped, listDropIndex = util:HasThisLootDroppedThisRaid(raidKey, item, giver, OfDrops)
                local hasDropsList, dropsListIndex = util:HasThisLootDroppedThisRaid(raidKey, item, giver, Drops)
                if hasListDropped then
                    OfDrops[raidKey][listDropIndex][item] = receiver
                elseif hasDropsList then
                    Drops[raidKey][dropsListIndex][item] = receiver
                end
            end
        end
    end
end)