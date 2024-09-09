local ofConfigFrame = CreateFrame("Frame")

ofConfigFrame:RegisterEvent("VARIABLES_LOADED")
ofConfigFrame:SetScript("OnEvent", function ()
    if event == "VARIABLES_LOADED" then
        InititalizeDefaultValues()
    end
end)

function InititalizeDefaultValues()
    if not OfLoot then OfLoot = {} end
    if not OfDrops then OfDrops = {} end
    if not Drops then Drops = {} end
    if not ListExclusions then ListExclusions = {} end
    OnyFansLoot.raidInvite = false
    OnyFansLoot.invitedList = {}
end