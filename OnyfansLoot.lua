OnyFansLoot = AceLibrary("AceAddon-2.0"):new("AceHook-2.1")
local self = OnyFansLoot

if not OfLoot then
    OfLoot = {}
end

OnyfansGameTooltip = CreateFrame("Frame","OnyfansGameToolTip",GameTooltip)
OnyfansGameTooltip:SetScript("OnShow", function (self)
    if GameTooltip then
        if not GameTooltip.itemLink then return end
        local lbl = getglobal("GameTooltipTextLeft1")
        if lbl then
            local tLine = lbl:GetText()
            tLine = string.lower(tLine)
            AddLootListToToolTip(GameTooltip,tLine)
        end
    end
end)

local function SetItemRefHook(link,name,button)
    if (link and name and ItemRefTooltip) then
        if (strsub(link, 1, 6) ~= "Player") then
            if (ItemRefTooltip:IsVisible()) then
                if (not DressUpFrame:IsVisible()) then
                    local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(link)
                    AddLootListToToolTip(ItemRefTooltip, string.lower(itemName))
                end
                ItemRefTooltip.isDisplayDone = nil
            end
        end
    end
end
self:SecureHook("SetItemRef",SetItemRefHook)

function AddLootListToToolTip(Tooltip, itemName)
    local numEntries = DoesTableContain(OfLoot,itemName)
    if itemName and numEntries > 0 and IsAltKeyDown() then
        for i = 1, numEntries,1 do
            Tooltip:AddLine(i .. ":" .. OfLoot[itemName][i],1,0,0)
        end
        Tooltip:Show()
    elseif itemName == "broken boar tusk" and IsAltKeyDown() then
        Tooltip:AddLine("1: Goblin Loot" ,1,0,0)
        Tooltip:Show()
    end
end

self:SecureHook(GameTooltip, "SetLootItem", function(this, slot)
        local itemLink = ItemLinkToItemString(GetLootSlotLink(slot))
        local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemLink)
            if itemName then
                AddLootListToToolTip(GameTooltip, string.lower(itemName))
            end
    end)

function DoesTableContain(table, contains)
    local numEntries = 0
    if not table then return end
    if not contains then return end
    for k, v in pairs(table) do
        if k == contains then 
            for _, list in ipairs(v) do
                numEntries = numEntries + 1
            end
        end
    end
    return numEntries
end

function ItemLinkToItemString(ItemLink)
    if not ItemLink then return end
    local il, _, ItemString = strfind(ItemLink, "^|%x+|H(.+)|h%[.+%]")
    return il and ItemString or ItemLink
end

-- local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(tLine)
-- local _, _, itemLink = string.find(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)")
