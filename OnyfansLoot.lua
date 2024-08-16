OnyFansLoot = AceLibrary("AceAddon-2.0"):new("AceHook-2.1")
OnyFansLoot.playerName = UnitName("player")


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
    local numEntries = GetNumEntries(OfLoot,itemName)
    local listVersion = GetListVersion(OfLoot)
    if numEntries and itemName and numEntries > 0 and IsAltKeyDown() then
        CheckVersionAddLine(listVersion,Tooltip)
        for i = 1, numEntries,1 do
            Tooltip:AddLine(i .. ":" .. OfLoot[itemName][i],1,0,0)
        end
        Tooltip:Show()
    elseif itemName == "broken boar tusk" and IsAltKeyDown() then
        Tooltip:AddLine("1: Goblin Loot" ,1,0,0)
        Tooltip:Show()
    elseif IsAltKeyDown() then
        CheckVersionAddLine(listVersion,Tooltip)
        Tooltip:AddLine("1: Free Roll" ,1,0,0)
        Tooltip:Show()
    end
end

function CheckVersionAddLine(listVersion, Tooltip)
    if listVersion > 0 then
        Tooltip:AddLine("List#" ..listVersion ..":" .. OfLoot["version"][2],1,0,0)
    else
        Tooltip:AddLine("No List Installed",1,0,0)
    end
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

OnyFansLoot:SecureHook(GameTooltip, "SetLootItem", function(this, slot)
        local itemLink = ItemLinkToItemString(GetLootSlotLink(slot))
        local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemLink)
            if itemName then
                AddLootListToToolTip(GameTooltip, string.lower(itemName))
            end
    end)


-- local itemName, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(tLine)
-- local _, _, itemLink = string.find(GameTooltip.itemLink, "(item:%d+:%d+:%d+:%d+)")
