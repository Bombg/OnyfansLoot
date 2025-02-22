local util = OnyFansLoot.util


local function SetItemRefHook(link,name,button)
    if (link and name and ItemRefTooltip) then
        if (strsub(link, 1, 6) ~= "Player") then
            if (ItemRefTooltip:IsVisible()) then
                if (not DressUpFrame:IsVisible()) then
                    local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(link)
                    if itemName then
                        AddLootListToToolTip(ItemRefTooltip, string.lower(itemName)) 
                    end
                end
                ItemRefTooltip.isDisplayDone = nil
            end
        end
    end
end
OnyFansLoot:SecureHook("SetItemRef",SetItemRefHook)

function AddLootListToToolTip(Tooltip, itemName)
    local lootTable = OnyFansLoot.isStaged and StagedOfLoot or OfLoot
    local listVersion = OnyFansLoot.util:GetListVersion(lootTable)
    if OnyFansLoot.util:DoesTableContainKey(lootTable, string.lower(itemName)) and itemName  and IsAltKeyDown() then
        CheckVersionAddLine(listVersion,Tooltip, itemName)
        local list = OnyFansLoot.util:CreateItemList(lootTable, string.lower(itemName))
        if OnyFansLoot.util:IsEmptyString(list) then
            Tooltip:AddLine("1: Free Roll" ,1,0,0)
        else
            Tooltip:AddLine(OnyFansLoot.util:TitleCase(list),1,0,0)
        end
        Tooltip:Show()
    elseif itemName == "broken boar tusk" and IsAltKeyDown() then
        Tooltip:AddLine("1: Goblin Loot" ,1,0,0)
        Tooltip:Show()
    elseif IsAltKeyDown() then
        CheckVersionAddLine(listVersion,Tooltip, itemName)
        Tooltip:AddLine("1: Free Roll" ,1,0,0)
        Tooltip:Show()
    end
end

function CheckVersionAddLine(listVersion, Tooltip, itemName)
    local numExlusions = OnyFansLoot.util:GetNumOfExlusions(itemName)
    local listDate
    if OnyFansLoot.isStaged then
        Tooltip:AddLine("Staged: Uncommited changes",1,0,0)
    end
    if OfLoot["version"] == nil then
        listDate = date("%m-%d-%y")
    else
        listDate = OfLoot["version"][2]
    end
    local listTitle  = "|cffFF0000List#|r"
    local dateTitle = "|cffFF0000#Date#|r"
    local excludingTitle = "|cffFF0000#Excluding#|r"
    local namesFoot = "|cffFF0000#Names|r"
    local pListVersion = "|cff9482c9" .. listVersion .. "|r"
    local pDate = "|cff9482c9" .. listDate .. "|r"
    local pNumExclusions = "|cff9482c9" .. numExlusions .. "|r"
    if listVersion > 0 then
        Tooltip:AddLine(listTitle ..pListVersion ..dateTitle .. pDate .. excludingTitle .. pNumExclusions .. namesFoot) 
    else
        Tooltip:AddLine("No List Installed",1,0,0)
    end
end

OnyfansGameTooltip = CreateFrame("Frame","OnyfansGameToolTip",GameTooltip)
OnyfansGameTooltip:SetScript("OnShow", function (self)
    if GameTooltip and GameTooltip.itemLink then
        local itemString = OnyFansLoot.util:ItemLinkToItemString(GameTooltip.itemLink)
        if itemString then
            local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemString)
            if itemName then
                AddLootListToToolTip(GameTooltip, itemName)
            end
        end
    end
end)

OnyFansLoot:SecureHook(GameTooltip, "SetLootItem", function(this, slot)
        local itemString = OnyFansLoot.util:ItemLinkToItemString(GetLootSlotLink(slot))
        local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemString)
            if itemName then
                AddLootListToToolTip(GameTooltip, string.lower(itemName))
            end
    end)

if AtlasLoot then
    OnyFansLoot:SecureHook("AtlasLootItem_OnEnter", function()
        if this.itemID then
            local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(this.itemID)
            if itemName and AtlasLootTooltip then
                AddLootListToToolTip(AtlasLootTooltip, itemName)
            end
        end
    end)
end