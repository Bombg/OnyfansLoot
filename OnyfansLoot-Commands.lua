local util = OnyFansLoot.util

SLASH_OF1 = "/of"
SLASH_OF2 = "/onyfansloot"
SlashCmdList["OF"] = function(msg)
    local regex = "(%a+) ?(.*)"
    local msg1, msg2 = string.match(msg, regex)
    if msg1 and msg1 == "export" then
        local data = GetExportData(msg2)
        util:ShowExportFrame(data)
    elseif util:IsEmptyString(msg1) or msg1 == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("OnyFansLoot usage:")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000help|r: brings up this text")
		DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000/of|r or |r|cff9482c9/onyfansloot|r { help |  export }")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export|r: exports the latest raid loot into a window to be copy pasted")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9n|r: where n is between 1 and 5, export one of the last five raids")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9help|r: bring up a list of raid {key}s")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000export |r|cff9482c9key|r: bring up drops for a specific raid key. Where key is one of the keys got from export help")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000import |r: brings up a window to import from csv")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000stage |r: stages csv import so you can test it on tooltips before sharing it")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffFF0000commit |r: commit staged changes so its shared with everyone. Assuming higher list version")
    elseif msg1 and msg1 == "import" then
        if util:IsAllowedToImport() then
            local instructions = "************DELETE ALL THIS TEXT BEFORE PASTING IN YOUR CSV************\n\n" ..
                        "******************INSTRUCTIONS******************\n" ..
                        "DELETE ALL ITEMS WITH STRIKETHROUGH IN SOURCE LIST\n".. 
                        "STRIKETHROUGH IS NOT IMPORTED INTO CSV SO ANY IMPORT CANNOT TELL THE DIFFERENCE\n" ..
                        "IF A LIST ITEM IS MISSPELLED IT WILL NOT WORK\n\n"..
                        "THE LIST WILL BE CROSSED CHECKED WITH ATLASLOOT FOR MISSPELLINGS\n\n" .. 
                        "************DELETE ALL THIS TEXT BEFORE PASTING IN YOUR CSV************\n\n"
            ImportFrameHeaderString:SetText("CSV Import")
            ImportFrameText:SetText(instructions)
            ShowUIPanel(ImportFrame, 1)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Sorry you need to be an officer or GM to import")
        end
    elseif msg1 and msg1 == "stage" then
        if not util:IsTableEmpty(ImportedTable) then
            util:StageImportedList()
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Imported List Has Been Staged")
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Commit changes for them to take effect and be shared with others")
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Current Tooltips reflect staged list only")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: There is no imported list to stage")
        end
    elseif msg1 and msg1 == 'commit' then
        if OnyFansLoot.isStaged and not util:IsTableEmpty(StagedOfLoot) then
            OfLoot = StagedOfLoot
            OnyFansLoot.isStaged = false
            StagedOfLoot = {}
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Staged changes have been commited. Will share list assuming it has the highest version number")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffFF0000OnyFansLoot|r: Nothing currently staged to commit")
        end
        
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