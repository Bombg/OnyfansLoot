local util = OnyFansLoot.util
local OfCheck = CreateFrame("Frame")

OfCheck:RegisterEvent("GUILD_ROSTER_UPDATE")
OfCheck:SetScript("OnEvent", function ()
    if event and event == "GUILD_ROSTER_UPDATE" then
        if time() - OnyFansLoot.lastListDateCheck > OnyFansLoot.timeBetweenListDateChecks then
            util:CheckForMissingToolTips()
            OnyFansLoot.lastListDateCheck = time()
        end
        if OnyFansLoot.raidInvite then
            util:RaidInviteListMembers()
        end
    end
end)