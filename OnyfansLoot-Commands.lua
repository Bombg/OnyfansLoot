local util = OnyFansLoot.util

SLASH_OF1 = "/of"
SlashCmdList["OF"] = function(msg)
    local regex = "(%a+) ?(.*)"
    local msg1, msg2 = string.match(msg, regex)
    local data = "Improper input or doesn't exist"
    if msg1 and msg1 == "export" then
        if msg2 and tonumber(msg2) ~= nil and tonumber(msg2) <= 5 then
            local lastKeys = util:GetLastNKeys(5, Drops)
            if util:DoesTableContainKey(OfDrops, lastKeys[tonumber(msg2)]) or util:DoesTableContainKey(Drops, lastKeys[tonumber(msg2)]) then
                data = util:ExportLootTablesAsString(lastKeys[tonumber(msg2)])
            end
        elseif msg2 and  util:DoesTableContainKey(OfDrops, msg2) or util:DoesTableContainKey(Drops, lastKeys[tonumber(msg2)])then
            data = util:ExportLootTablesAsString(msg2)
        end 
        ExportFrameEditBox1:SetFont("Fonts\\FRIZQT__.TTF", "12")
        ExportFrameEditBox1Left:Hide()
        ExportFrameEditBox1Middle:Hide()
        ExportFrameEditBox1Right:Hide()
        ExportFrameEditBox1:SetText(data)
        ShowUIPanel(ExportFrame, 1)
    end
end 