local PlayableScript = L("PlayableScript", {})
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local LuaTimer = T(Lib, "LuaTimer")
local SpriteBallConfig = T(Config, "SpriteBallConfig")
local nextObjectID = 1610612736
local world = World.CurWorld
PlayableScript.param = {
  curBattlePetName = "",
  BallTarget = 0,
  CatchSuccess = false,
  BallID = 0,
  ThrowBallObjId = -1,
  ThrowBallObjId2 = -1
}
local ball, pokemon

local function entitySpawnBall(cfgName, actor, pos, yaw, pitch, callBack)
  Lib.logDebug("entitySpawnBall", cfgName, nextObjectID)
  Game.EntitySpawn(Me, {
    objID = nextObjectID,
    cfgName = cfgName,
    actorName = actor or "g2038_ball_01.actor",
    pos = pos,
    rotationYaw = yaw,
    rotationPitch = pitch,
    name = Me.name,
    curHp = 1,
    rideOnId = 0
  }, callBack)
  nextObjectID = nextObjectID + 1
  return nextObjectID - 1
end

function PlayableScript.getThrowBallObj()
  local objectId = PlayableScript.param.ThrowBallObjId
  local object = world:getObject(objectId)
  if not object and objectId ~= -1 then
    Lib.logError("getThrowBallObj not object", objectId)
  end
  return object
end

function PlayableScript.getThrowBallObj2()
  local objectId = PlayableScript.param.ThrowBallObjId2
  local object = world:getObject(objectId)
  return object
end

function PlayableScript.getBallTarget()
  local ballTarget = PlayableScript.param.BallTarget
  local pet = world:getObject(ballTarget)
  return pet
end

function PlayableScript.getBallPokemon()
  local pet = PlayableScript.getBallTarget()
  if not pet then
    return
  end
  PokemonManager:getPokemon(pet:getPokemonId(), function(result)
    pokemon = result
  end)
end

function PlayableScript.show_throw_ball_text()
  local wnd = UI:getWnd("cutscene")
  local message = string.format(Lang:getMessage("novice_guide_1"), Lang:getMessage(PlayableScript.param.curBattlePetName))
  if Me:getMyTeamMateId() and PlayableScript.getThrowBallObj2() then
    message = PlayableScript.double_throw_ball_text()
  end
  if Me.battleFieldInfo.npcId then
  end
  if Me.battleFieldInfo and Me.battleFieldInfo.mode == Define.BATTLE_MODE.PVP then
    local curEnemyNameList = Me.battleFieldInfo.curEnemyNameList
    if #curEnemyNameList == 1 or PlayableScript.param.ThrowBallObjId2 == -1 then
      local obj = PlayableScript.getThrowBallObj() or Me
      local curBattlePetName = obj and obj:getValue("curBattlePetName") or PlayableScript.param.curBattlePetName
      message = string.format(Lang:getMessage("novice_guide_1"), Lang:getMessage(curBattlePetName))
    else
      message = PlayableScript.double_throw_ball_text()
    end
  end
  wnd:showSubtitle(message)
  LuaTimer:schedule(function()
    local wnd = UI:getWnd("cutscene")
    wnd:hideSubtitle()
  end, 1500)
  Lib.logDebug("show_throw_ball_text")
end

function PlayableScript.double_throw_ball_text()
  local obj = PlayableScript.getThrowBallObj() or Me
  local obj2 = PlayableScript.getThrowBallObj2() or Me
  local curBattlePetName = obj and obj:getValue("curBattlePetName") or "nil"
  local curBattlePetName2 = obj2 and obj2:getValue("curBattlePetName") or "nil"
  return string.format(Lang:getMessage("novice_guide_2"), Lang:getMessage(curBattlePetName), Lang:getMessage(curBattlePetName2))
end

function PlayableScript.throw_ball()
  local animationName = "g2038_throw_01"
  local config = SpriteBallConfig:getSpriteBallConfig(PlayableScript.param.BallID)
  if config then
    animationName = config.throwAnim
  end
  local obj = PlayableScript.getThrowBallObj() or Me
  World.Timer(2, function()
    obj:updateUpperAction(animationName, -1)
  end)
  local obj2 = PlayableScript.getThrowBallObj2()
  if obj2 then
    config = SpriteBallConfig:getSpriteBallConfig(obj2:getValue("curBattlePetBallId"))
    animationName = config and config.throwAnim or animationName
    obj2:updateUpperAction(animationName, -1)
  end
  Lib.logDebug("PlayableScript.throw ball", obj and obj:isValid() and obj.name, obj2 and obj2:isValid() and obj2.name, animationName)
end

function PlayableScript.catch_ball()
  local animationName = "g2038_catch_01"
  local config = SpriteBallConfig:getSpriteBallConfig(PlayableScript.param.BallID)
  if config then
    animationName = config.catchAnim
  end
  local obj = PlayableScript.getThrowBallObj() or Me
  obj:updateUpperAction(animationName, -1)
  Lib.logDebug("PlayableScript.catch_ball", animationName)
end

function PlayableScript.catch_stage_2_1()
  local pet = PlayableScript.getBallTarget()
  Blockman.instance:playEffectByPos("g2038_ball_catch.effect", Lib.v3add(pet:getPosition(), {
    x = 0,
    y = 0.4,
    z = 0
  }), 0, 1000)
end

function PlayableScript.catch_stage_2_2()
  local pet = PlayableScript.getBallTarget()
  pet:setEntityHide(true)
  local actorName
  local config = SpriteBallConfig:getSpriteBallConfig(PlayableScript.param.BallID)
  if config then
    actorName = config.ballActor
  end
  entitySpawnBall("myplugin/g2038_ball_01", actorName, pet:getPosition(), World.cfg.catchBallYaw or 180, 0, function(entity)
    ball = entity
  end)
  PlayableScript.getBallPokemon()
end

function PlayableScript.catch_c1()
  Lib.logDebug("PlayableScript.catch_c1")
  ball:updateUpperAction("catch1", -1)
end

function PlayableScript.catch_c2()
  Lib.logDebug("PlayableScript.catch_c2")
  ball:updateUpperAction("catch2", -1)
end

function PlayableScript.catch_c3()
  Lib.logDebug("PlayableScript.catch_c3")
  ball:updateUpperAction("catch3", -1)
end

function PlayableScript.catch_c4()
  Lib.logDebug("PlayableScript.catch_c4")
  ball:updateUpperAction("catch4", -1)
end

function PlayableScript.destroyBall()
  if ball then
    ball:destroy()
    ball = nil
  end
end

function PlayableScript.catch_success_1()
  if PlayableScript.param.CatchSuccess then
    PlayableScript.catch_c4()
  end
end

function PlayableScript.catch_success_2()
  Lib.logDebug("PlayableScript.catch_success_2")
  local wnd = UI:getWnd("battle_dialog")
  if wnd then
    wnd:showDialogText({
      text = string.format(Lang:getMessage("catch_success_1"), pokemon and pokemon:getName() or "nil")
    })
  end
end

function PlayableScript.catch_success_3()
  Lib.logDebug("PlayableScript.catch_success_3")
  PlayableScript.destroyBall()
  UI:closeWnd("battle_dialog")
end

function PlayableScript.catch_fail_1()
  local pet = PlayableScript.getBallTarget()
  pet:addEffect(pet:getEffectName(), "g2038_ball_failure.effect", true, {
    x = 0,
    y = 0.5,
    z = 0
  }, 0, {
    x = 1,
    y = 1,
    z = 1
  })
end

function PlayableScript.catch_fail_2()
  PlayableScript.destroyBall()
  local pet = PlayableScript.getBallTarget()
  pet:setEntityHide(false)
end

function PlayableScript.catch_fail_3()
  local wnd = UI:getWnd("battle_dialog")
  if wnd then
    wnd:showDialogText({
      text = string.format(Lang:getMessage("catch_fail"), pokemon and pokemon:getName() or "nil"),
      autoCloseTime = 1500
    })
  end
end

local function getBattleFieldPos(key)
  local battleFieldPos = World.CurMap.cfg.battleFieldPos or World.cfg.battleFieldPos
  return battleFieldPos[key]
end

local function getPosByIndex(index, isAir)
  if 4 <= index and index <= 6 then
    return getBattleFieldPos(isAir and "selfPetAirPos" or "selfPetPos")[index - 3]
  elseif 10 <= index and index <= 12 then
    return getBattleFieldPos(isAir and "enemyPetAirPos" or "enemyPetPos")[index - 9]
  end
  Lib.logError("getPosByIndex return nil", index)
  return nil
end

function PlayableScript.createPet()
  local master = PlayableScript.getThrowBallObj() or Me
  local objID = master:getValue("curBattlePetObjID")
  local pet = world:getObject(objID)
  if pet then
    pet:setEntityHide(false)
    local posInit = getPosByIndex(master:getBpIndex() + 3, true)
    pet:setPosition(posInit)
    local pos = getPosByIndex(master:getBpIndex() + 3)
    print("World.CurMap.cfg.battleFieldPos.dropTime:", World.CurMap.cfg.battleFieldPos.dropTime)
    pet:setForceMove(pos, tonumber(World.CurMap.cfg.battleFieldPos.dropTime or 1))
  end
  local master2 = PlayableScript.getThrowBallObj2()
  if master2 then
    local objID = master2:getValue("curBattlePetObjID")
    local pet = world:getObject(objID)
    if pet then
      pet:setEntityHide(false)
      local pos = getPosByIndex(master2:getBpIndex() + 3)
      print("World.CurMap.cfg.battleFieldPos.dropTime:", World.CurMap.cfg.battleFieldPos.dropTime)
      pet:setForceMove(pos, tonumber(World.CurMap.cfg.battleFieldPos.dropTime or 1))
    end
  end
  Lib.logDebug("PlayableScript.createPet", objID)
end

function PlayableScript.play_victory()
  Me:updateUpperAction("g2038_victory_01", -1)
  local teamMate = World.CurWorld:getEntity(Me:getMyTeamMateId() or Me:getMyHostTeamMateId() or -1)
  if teamMate then
    teamMate:updateUpperAction("g2038_victory_01", -1)
  end
end

function PlayableScript.play_fail()
  Me:updateUpperAction("g2038_fail_01", -1)
  local teamMate = World.CurWorld:getEntity(Me:getMyTeamMateId() or Me:getMyHostTeamMateId() or -1)
  if teamMate then
    teamMate:updateUpperAction("g2038_fail_01", -1)
  end
end

function PlayableScript.getCurEnemyPetName()
  if not Me.battleFieldInfo then
    return "nil"
  end
  return Me.battleFieldInfo.curEnemyNameList[1]
end

function PlayableScript.fight_show_subtitle()
  local wnd = UI:getWnd("cutscene")
  local message = string.format(Lang:getMessage("novice_guide_B_1"), Lang:getMessage(PlayableScript.getCurEnemyPetName()))
  if Me.battleFieldInfo then
    if Me.battleFieldInfo.npcId then
      message = string.format(Lang:getMessage("novice_guide_B_2"), Lang:getMessage(PlayableScript.getCurEnemyPetName()))
    end
    if Me.battleFieldInfo.mode == Define.BATTLE_MODE.PVP then
      local curEnemyNameList = Me.battleFieldInfo.curEnemyNameList
      if #curEnemyNameList == 1 then
        message = string.format(Lang:getMessage("novice_guide_B_2"), curEnemyNameList[1])
      else
        message = string.format(Lang:getMessage("novice_guide_B_3"), curEnemyNameList[1], curEnemyNameList[2])
      end
    end
  end
  wnd:showSubtitle(message)
  Lib.logDebug("fight_show_subtitle")
end

function PlayableScript.hide_subtitle()
  local wnd = UI:getWnd("cutscene")
  if wnd then
    wnd:hideSubtitle()
  end
end

function PlayableScript.reset_default_camera()
  local view
  local index = Me:getBpIndex()
  if index == 2 or index == 3 or index == 8 or index == 9 then
    view = World.cfg.defaultCameraView[2]
  else
    view = World.cfg.defaultCameraView[1]
  end
  local pos = Lib.v3(view.x, view.y, view.z)
  local yaw = view.yaw
  if Me:isReverseCamera() then
    pos = Lib.v3(-view.x, view.y, -view.z)
    yaw = yaw + 180
  end
  Me:changeCameraView(pos, yaw, view.pitch, 0, 0)
end

return PlayableScript
