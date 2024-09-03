local util = OnyFansLoot.util
local OfCheck = CreateFrame("Frame")
OnyFansLoot.timeBetweenListDateChecks = 3600
OnyFansLoot.lastListDateCheck = time() - OnyFansLoot.timeBetweenListDateChecks + 15

OfCheck:RegisterEvent("GUILD_ROSTER_UPDATE")
OfCheck:SetScript("OnEvent", function ()
    if event and event == "GUILD_ROSTER_UPDATE" then
        if time() - OnyFansLoot.lastListDateCheck > OnyFansLoot.timeBetweenListDateChecks then
            util:CheckForMissingToolTips()
            OnyFansLoot.lastListDateCheck = time()
        end
    end
end)