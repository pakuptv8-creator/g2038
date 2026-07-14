local bm = Blockman.Instance()
local oldProcessClick = PlayerControl.processClick

function PlayerControl.processClick(hit, packet)
  print("-------------------processPlyerClick---------------")
  if not hit then
    return
  end
  Lib.emitEvent(Event.EVENT_TOUCH_SCREEN, GUISystem.instance:GetRootWindow())
  if UI:isOpen("pokemon_base_interactionUI") then
    UI:closeWnd("pokemon_base_interactionUI")
  end
  if hit.type == "BLOCK" and PlayerControl.checkClickChangeBlock(packet.blockPos) then
  elseif hit.type == "ENTITY" then
    Me:processClickEntity(hit, packet)
  else
    Skill.ClickCast(packet)
  end
end

local oldUpdateControl = PlayerControl.UpdateControl

function PlayerControl.UpdateControl(frame_time)
  if Me and Me:isValid() then
    Me:setProp("moveSpeed", 4.0)
    Me:setProp("jumpSpeed", 0.8)
    Me:setProp("stepHeight", 2.5)
    local bm = Blockman.Instance()
    bm:setReachDistance(999)

    -- ULTRA HACK: 2vs2 Solo Spoof (Fake Teammate)
    -- Disabled by default to allow normal encounters. Toggle via GM.
    if World.Solo2vs2 then
        Me:setValue("teamDate", {isCaptain = 1, teamMateID = 999999, teamID = 888888})
    else
        -- If spoof is off, we ensure team data is cleared to allow wild battles
        if Me:getValue("teamDate") and Me:getValue("teamDate").teamMateID == 999999 then
            Me:setValue("teamDate", nil)
        end
    end
  end

  local player = Player.CurPlayer
  local control = bm:control()
  if player:isJoinTeam() and not player:isTeamCaptain() then
    if control.enable then
      control.enable = false
    end
    if Blockman.Instance():viewEntity().objID == player.objID then
      local captainId = player:getMyTeamMateId()
      if captainId then
        local captain = World.CurWorld:getEntity(captainId)
        if captain and captain:isValid() then
          Blockman.instance:setViewEntity(captain)
        end
      end
    end
    return
  else
    control.enable = true
    Blockman.instance:setViewEntity(player)
  end
  oldUpdateControl(frame_time)
end
