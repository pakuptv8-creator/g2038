local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\230\139\155\230\160\135/\229\136\155\229\187\186\229\145\138\231\164\186\231\137\140"] = function()
  local showPos = Me:getPosition()
  showPos.y = showPos.y + 2
  local signKey = Me.objID
  local uiParams = {
    width = 303,
    viewDistance = 8,
    rotate = {
      x = 0,
      y = 0,
      z = 0
    },
    position = showPos,
    mapId = World.CurMap.id,
    signKey = signKey
  }
  Plugins.CallTargetPluginFunc("tendering_land", "createTenderingSignUI", signKey, uiParams)
  local data = {
    signTitle = "\232\191\153\233\135\140\230\150\189\229\183\165\229\149\138",
    signState = "\230\150\189\229\183\165\228\184\173",
    signPlayer = Me.name,
    signUnit = "\229\187\186\232\174\190\229\177\128"
  }
  Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, Define.BIDDING_STATUS.BIDDING, data)
end
GMItem["\230\139\155\230\160\135/\230\155\180\230\150\176\229\145\138\231\164\186\231\137\140\228\189\141\231\189\174"] = function()
  local showPos = Me:getPosition()
  showPos.y = showPos.y + 2
  local signKey = Me.objID
  local uiParams = {
    width = 303,
    viewDistance = 8,
    rotate = {
      x = 0,
      y = 0,
      z = 0
    },
    position = showPos,
    mapId = World.CurMap.id,
    signKey = signKey
  }
  Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIParams", signKey, uiParams, "map001")
end
GMItem["\230\139\155\230\160\135/\229\145\138\231\164\186\231\137\140\229\134\133\229\174\185"] = function()
  local signKey = Me.objID
  local data = {
    signTitle = "\232\191\153\233\135\140\230\138\149\231\165\168\229\149\138",
    signState = "\230\138\149\231\165\168" .. os.time(),
    signPlayer = Me.name,
    signUnit = "\229\187\186\232\174\190\229\177\128"
  }
  Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, Define.BIDDING_STATUS.BIDDING, data)
end
GMItem["\230\139\155\230\160\135/\229\133\172\231\164\186\233\152\182\230\174\181\229\134\133\229\174\185"] = function()
  local signKey = Me.objID
  local data = {
    signTitle = "\232\191\153\233\135\140\230\138\149\231\165\168\229\149\138",
    signPlayer = Me.name,
    praiseNum = math.random(1, 1000)
  }
  Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, Define.BIDDING_STATUS.PUBLICITY, data)
end
GMItem["\230\139\155\230\160\135/\229\133\179\233\151\173\229\145\138\231\164\186\231\137\140"] = function()
  local signKey = Me.objID
  Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, Define.BIDDING_STATUS.NORMAL, {})
end
GMItem["\230\139\155\230\160\135/\233\130\174\231\174\177\231\149\140\233\157\162"] = function()
  UI:getWnd("tenderingAwardEmail"):onShow(true)
end
GMItem["\230\139\155\230\160\135//3dUI"] = function(self)
  local pos = Me:getPosition()
  pos.y = pos.y + 2
  pos.x = pos.x + 1
  local packet = {
    playerList = {
      [1] = {
        userId = Me.platformUserId,
        nameContent = Me:getNameContent(),
        nameColor = Me:getNameColor(),
        sex = Me:data("main").sex or 2,
        actorScale = World.cfg.photographSetting.actorScale,
        skinData = Me:data("skin")
      }
    },
    position = pos,
    rotate = {
      x = 0,
      y = 0,
      z = 0
    },
    width = 400,
    viewDistance = 20,
    partID = Me.objID
  }
  local uiName = "policePicture"
  local pictureUIKey = uiName .. packet.partID
  if not Plugins.CallTargetPluginFunc("scene_ui", "getSceneUI", pictureUIKey) then
    local default = {
      width = packet.width,
      viewDistance = packet.viewDistance,
      uiName = uiName,
      rotate = packet.rotate,
      position = packet.position,
      key = pictureUIKey
    }
    default.params = packet.playerList
    local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
    table.insert(uiCfgList, default)
    Plugins.CallTargetPluginFunc("scene_ui", "createSceneUI", default)
  else
    Plugins.CallTargetPluginFunc("scene_ui", "updateUIViewShow", pictureUIKey, packet.playerList)
  end
end
GMItem["\230\139\155\230\160\135/\232\155\139\232\155\139\229\177\139\228\188\160\233\128\129"] = function()
  Plugins.CallTargetPluginFunc("tendering_land", "openTenderSignWnd")
end
