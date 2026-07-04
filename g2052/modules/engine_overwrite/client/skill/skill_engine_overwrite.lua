local delayAction = {}
local filStr = {
  "-",
  "_",
  "/"
}

local function filter(str, pos)
  for _, s in pairs(filStr) do
    if string.find(string.sub(str, 1, pos), s, pos, true) then
      return true
    end
  end
  return false
end

local function checkStr(str, pos)
  local ret, _pos = string.find(str, "[\\/]", pos or 1)
  if ret then
    if filter(str, _pos) then
      return checkStr(str, _pos + 1)
    else
      return false
    end
  end
  return true
end

local misc = require("misc")

local function getSkill(name)
  local player = Player.CurPlayer
  local cfg = Skill.Cfg(name)
  local from
  local tb = player:data("skill").skillMap and player:data("skill").skillMap[name] or {}
  local objID = tb and tb.objID
  if objID then
    from = World.CurWorld:getEntity(objID)
  else
    from = player
  end
  return cfg, from
end

function Skill.ClickCast(packet)
  local player = Player.CurPlayer
  for _, name in ipairs(player:data("skill").clickList or {}) do
    local cfg, from = getSkill(name)
    local key = "skill:" .. name
    local time = from:data("main").cd and from:data("main").cd[key] and from:data("main").cd[key] or 0
    local rest = time - World.Now()
    if 0 < rest then
      return false
    end
    if cfg and cfg.isClick and cfg:canCast(packet, from) then
      Skill.DoCast(cfg, packet, from)
      Lib.logDebug("Skill.ClickCast", name)
      if name ~= "myplugin/default_click" then
        local inUseItem = Me:getInUseProp()
        if not inUseItem or inUseItem.itemId then
        end
      end
      break
    end
  end
end

function Skill.CastByServer(packet)
  local cfg = Skill.Cfg(packet.name) or {}
  local from = World.CurWorld:getEntity(packet.fromID)
  if not from then
    return
  end
  if (not (from and from:isControl()) or packet.needPre) and cfg.fullName ~= "myplugin/default_click" then
    cfg:preCast(packet, from)
  end
  cfg:cast(packet, from)
  if cfg.fullName ~= "myplugin/default_click" then
    local actionTime = (from:getUpperActionTicks(cfg.castAction) or 10) - 1
    if 0 < actionTime and cfg.castAction ~= "" then
      if delayAction[packet.fromID] then
        delayAction[packet.fromID]()
        delayAction[packet.fromID] = nil
      end
      delayAction[packet.fromID] = World.Timer(actionTime, function()
        local InteractionHelper = T(Lib, "InteractionHelper")
        InteractionHelper:updateEntityActionShow(packet.fromID)
        return false
      end)
    end
  end
end

function Skill.DoCast(cfg, packet, from)
  if from and from.isPlayer and from:isWatch() then
    return
  end
  if cfg.debug then
    print("client Skill.DoCast -", from.name, cfg.fullName)
  end
  if cfg.fullName ~= "myplugin/default_click" then
    cfg:preCast(packet, from)
    if cfg.castAction and cfg.castAction ~= "" then
      local time = from:getUpperActionTicks(cfg.castAction) or -1
      if 0 < time then
        World.Timer(time, function()
          local InteractionHelper = T(Lib, "InteractionHelper")
          InteractionHelper:updateEntityActionShow(from.objID)
        end)
      end
    end
  end
  if Blockman.instance.singleGame then
    cfg:singleCast(packet, from)
  elseif packet.onlySelf then
    packet.name = cfg.fullName
    packet.fromID = from and from.objID
    Skill.CastByServer(packet)
  else
    packet.pid = "CastSkill"
    packet.name = cfg.fullName
    packet.fromID = from and from.objID
    assert(packet.name, "skill name is null")
    assert(cfg.fullName, "skill fullName is null")
    assert(packet.name == cfg.fullName, string.format("%s:%s", packet.name, cfg.fullName))
    assert(Skill.Cfg(packet.name) == cfg, "cfg !=")
    assert(checkStr(packet.name), string.format("Incorrect characters exist: %s", packet.name))
    local data = Player.CurPlayer:sendPacket(packet)
    local ok, _packet = pcall(misc.data_decode, data)
    if not ok then
      perror("handle_packets error!", self.name, _packet, #data, data:byte(1, 200))
    end
  end
  if cfg.diffuseVal and 0 < cfg.diffuseVal then
    FrontSight.Diffuse(cfg.diffuseVal, 1)
  end
  if cfg.cdTime then
    local key = "skill:" .. cfg.fullName
    if not from:data("main").cd then
      from:data("main").cd = {}
    end
    from:data("main").cd[key] = cfg.cdTime + World.Now()
  end
end
