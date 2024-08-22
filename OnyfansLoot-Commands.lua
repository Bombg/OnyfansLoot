local util = OnyFansLoot.util

SLASH_OF1 = "/of"
SLASH_OF2 = "/onyfansloot"
SlashCmdList["OF"] = function(msg)
    local regex = "(%a+) ?(.*)"
    local msg1, msg2 = string.match(msg, regex)
    if msg1 and msg1 == "export" then
        local data = GetExportData(msg2)
        ExportFrameEditBox1:SetFont("Fonts\\FRIZQT__.TTF", "12")
        ExportFrameEditBox1Left:Hide()
        ExportFrameEditBox1Middle:Hide()
        ExportFrameEditBox1Right:Hide()
        ExportFrameEditBox1:SetText(data)
        ShowUIPanel(ExportFrame, 1)
    elseif util:IsEmptyString(msg1) or msg1 == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("OnyFansLoot usage:")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000help|r: brings up this text")
		DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000/of|r or |r|cff9482c9/onyfansloot|r { help |  export }")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export|r: exports the latest raid loot into a window to be copy pasted")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9n|r: where n is between 1 and 5, export one of the last five raids")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9help|r: bring up a list of raid {key}s")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9key|r: bring up drops for a specific raid key. Where key is one of the keys got from export help")
    end
end 

function GetExportData(msg2)
    local data = "Improper input or doesn't exist"
    local lastKeys = util:GetLastNKeys(5, Drops)
    if msg2 and tonumber(msg2) ~= nil and tonumber(msg2) <= 5 then
        if util:DoesTableContainKey(OfDrops, lastKeys[tonumber(msg2)]) or util:DoesTableContainKey(Drops, lastKeys[tonumber(msg2)]) then
            data = util:ExportLootTablesAsString(lastKeys[tonumber(msg2)])
        end
    elseif msg2 and msg2 == "help" then
        data = util:ExportDropTableKeys(Drops)
    elseif msg2 and  util:DoesTableContainKey(OfDrops, msg2) or util:DoesTableContainKey(Drops, msg2)then
        data = util:ExportLootTablesAsString(msg2)
    elseif util:IsEmptyString(msg2) and table.getn(lastKeys) > 0 then
        data = util:ExportLootTablesAsString(lastKeys[1])
    end 
    return data
end