local OfLootDrops = CreateFrame("Frame")
local util = OnyFansLoot.util
local drops = {}

OfLootDrops:RegisterEvent("CHAT_MSG_LOOT")
OfLootDrops:RegisterEvent("CHAT_MSG_SYSTEM")
OfLootDrops:SetScript("OnEvent", function ()
    local chatMsg = arg1
    local regex = "(%a-) receive"
    if util:IsInRaid() and event == "CHAT_MSG_LOOT" and string.find(chatMsg, regex) then
        local itemName, playerName, itemId = drops:GetReceiveMsgInfo(chatMsg)
        if not itemName or not playerName or not itemId or util:IsItemBlackListed(string.lower(itemName)) then return end
        local _, _, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemId)
        itemName = string.lower(itemName)
        local raidKey = util:GetRaidKey()
        local itemToPersonTable  = {}
        itemToPersonTable[itemName] = string.lower(playerName)
        util:AddToListDrops(itemName, raidKey, itemToPersonTable)
        util:AddToDrops(raidKey, itemToPersonTable, quality)
        drops:BroadcastLootDrop(quality, playerName, itemId, raidKey)
        drops:HandleItemDisenchant(itemName,chatMsg)
    end
    if event == "CHAT_MSG_SYSTEM" then
        local message = arg1
        if util:IsMsgRaidItemTrade(message) then
            local tradeRegex ="(.-) trades item (.-) to (.*)."
            local raidKey = util:GetRaidKey()
            local giver, item, receiver = string.match(message, tradeRegex)
            if giver and item and receiver then
                HandleItemTransition(giver, receiver, item, raidKey)
            end
        end
    end
end)

function HandleItemTransition(giver, receiver, item, raidKey)
    local hasListDropped, listDropIndex 
    local hasDropsList, dropsListIndex
    if giver and receiver and item and raidKey then
        giver = string.lower(giver)
        item = string.lower(item)
        receiver = string.lower(receiver)
        hasListDropped, listDropIndex = util:HasThisLootDroppedThisRaid(raidKey, item, giver, OfDrops)
        hasDropsList, dropsListIndex = util:HasThisLootDroppedThisRaid(raidKey, item, giver, Drops)
        if hasListDropped then
            OfDrops[raidKey][listDropIndex][item] = receiver
        end
        if hasDropsList then
            Drops[raidKey][dropsListIndex][item] = receiver
            util:FixExclusionList(giver, receiver, item)
        end
    end
    return hasListDropped, hasDropsList
end

function drops:GetReceiveMsgInfo(chatMsg)
    local playerName, itemLink = util:GetNameItemLinkFromLootMsg(chatMsg)
    local hexColor, itemString, itemName = util:GetItemLinkParts(itemLink)
    local itemId, enchantId, suffixId, uniqueId = util:GetItemStringParts(itemString)
    return itemName, playerName, itemId
end

function drops:BroadcastLootDrop(quality, playerName, itemId, raidKey)
    if quality and quality >= OnyFansLoot.minQualityToLogLoot then
        util:CleanLastLootMsgTab()
        OnyFansLoot.lastLootmsg =  "ITEM:" .. playerName .. ":" .. itemId .. ":" .. raidKey
        OnyFansLoot.lastLootmsgTab[OnyFansLoot.lastLootmsg] = GetTime()
        ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.itemDropPrefix, OnyFansLoot.lastLootmsg, "GUILD")
    end
end

function drops:HandleItemDisenchant(itemName, chatMsg)
    if util:IsDisenchantedRaidItem(itemName,chatMsg) and OnyFansLoot.lastDisenchantedItem then
        local _, _, itemNameFromLink = util:GetItemLinkParts(OnyFansLoot.lastDisenchantedItem)
        if itemNameFromLink then
            local receiver = "disenchant"
            itemNameFromLink = string.lower(itemNameFromLink)
            local listDrop, itemDrop = HandleItemTransition(string.lower(OnyFansLoot.playerName), receiver,itemNameFromLink,util:GetRaidKey())
            if listDrop or itemDrop then
                local itemCorrectionMessage = string.lower(OnyFansLoot.playerName) .. ":" .. receiver .. ":" .. itemNameFromLink
                ChatThrottleLib:SendAddonMessage("NORMAL",OnyFansLoot.itemCorrectionPrefix, itemCorrectionMessage, "GUILD")
            end
        end
    end
end

OnyFansLoot.drops = drops