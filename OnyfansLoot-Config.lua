OnyFansLoot.minQualityToLogLoot = 3 -- For loot logging for the /of export command
OnyFansLoot.lastLootmsgCleanTime = 3 --  Anything => lastLootMsgCleanTime is removed from lastLootmsgTab
OnyFansLoot.timeBetweenListDateChecks = 3600 -- For checking if someone's 1/2 or whole list is active but they are not showing on tooltips
OnyFansLoot.lastListDateCheck = time() - OnyFansLoot.timeBetweenListDateChecks + 15 -- Creating a short delay before the list check notification, so it's not lost on log in
OnyFansLoot.versionRebroadcastTime = 180 -- Time in seconds between broadcasting version number
OnyFansLoot.timeBetweenLootBroadcast = 180 -- Time in seconds before loot master will send a raid message of the loot drops off the same unit name
OnyFansLoot.minRarityForAnnouncement = 4 -- Min rarity loot needs to be before it will be announced in raid chat by loot master
OnyFansLoot.minRarityToGroupWith = OnyFansLoot.minRarityForAnnouncement - 1 -- If there's loot on a unit under minRarityForAnnouncement, but still want to announce it (and not on blacklist) useful for recipes

-- Prefixes for addon messages
OnyFansLoot.itemDropPrefix  = "ofitem" -- used for broadcasting item drops to people outside of range to recieve the notice in chat
OnyFansLoot.itemCorrectionPrefix = "ofitemcorrection" -- used show raid item trades if out of range or if you didn't recieve the message for some reason
OnyFansLoot.listVersionBroadcastPrefix = "oflootlist" -- brodcasting loot version
OnyFansLoot.listSharePrefix = "ofloot" -- used when sending list to another person
OnyFansLoot.listAskPrefix = "oflootask" -- used when asking for a speicific list from speicific person
OnyFansLoot.addonVersionBroadcastPrefix = "ofversion" -- Broadcasting addon version
OnyFansLoot.exclusionListPrefix = "ofexclusion" -- Broadcasting exclusion list version
OnyFansLoot.exclusionSharePrefix = "ofexclusionshare" -- when sharing exclusion list with someon
OnyFansLoot.exlusionAskPrefix = "ofexlusionask" -- When asking for an exclusion list from someone
OnyFansLoot.listDropPrefix = "oflistdrop" -- for brodcasting when a list itemd rops

-- For blacklisting items from loot logging and export
OnyFansLoot.blackList = {
    "idol of the sun","idol of war","blue qiraji resonating crystal","idol of life","idol of death","idol of rebirth",
    "idol of strife","green qiraji resonating crystal","idol of night","large brilliant shard","idol of the sage", "yellow qiraji resonating crystal",
    "fiery core", "lava core", "book: gift of the wild","elementium ore", "nexus crystal", "tome of frost ward v", "hydralick armor","grimoire: demon portal",
    "seven of warlords", "wand of allistarj", "aegis of stormwind", "band of the hierophant", "sulfuron ingot"
}

-- Known alts. Lists are shared with alts of people that have a list
OnyFansLoot.altList = {['xiaobao']='misopaste',['mirgan']='rimgan',['ninsham']='ninjerk',['kyoden']='kyoto',['chawe']='magicfella',['xhelios']='heliosx',
                    ['navree']='navee',['buhritoh']='hambaga',['ankho']='mouchi',['epythet']='epygon',['axh']='axz',['magumba']='notmagumba', ['epy']='epygon',["aoeemo"]="omee", ["shego"]="violace",
                    ["misohunts"]="misopaste",["koodah"]="fathercuda", ["clothcow"]="lovebucket", ["dieyou"]="dieme", ["kabru"]="hambaga", ["needheals"]="luden", ["sneakyqueefy"]="kyoto",
                    ["epyzoic"]="epygon", ["navii"]="navee", ["soondubu"]="misopaste", ["scratcher"]="kaiden",["soraya"] = "gloryhunter", ["seance"] = "gloryhunter",}


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
    OnyFansLoot.lastLootmsgTab = {}
end