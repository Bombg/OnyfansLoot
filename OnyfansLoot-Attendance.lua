      local util = OnyFansLoot.util
      local onUpdateFrame= CreateFrame("Frame")
      onUpdateFrame:SetScript("OnUpdate", function()
        if GetTime() - OnyFansLoot.lastAttendanceCheck >= OnyFansLoot.attendanceCheckTick then
          OnyFansLoot.lastAttendanceCheck = GetTime()
          local raidKey = util:GetRaidKey()
          local zoneName = GetRealZoneText()
        end
      end)