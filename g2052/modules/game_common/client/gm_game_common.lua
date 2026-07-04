local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["game_common/\230\181\139\232\175\149\229\140\185\233\133\141\230\136\144\229\138\159"] = function()
  local data = {
    {
      userId = 18560,
      info = {}
    },
    {
      userId = 18544,
      info = {}
    },
    {
      userId = 18528,
      info = {}
    },
    {
      userId = 18512,
      info = {}
    }
  }
  Lib.emitEvent(Event.EVENT_MATCH_SUCCESS, data)
end
GMItem["game_common/\233\128\154\231\148\168UI"] = function()
  UI:getWnd("commonDialog"):onShow(true, {
    title = "\230\181\139\232\175\149\230\160\135\233\162\152",
    desc = "\230\181\139\232\175\149\230\143\143\232\191\176"
  })
end
GMItem["game_common/\233\149\156\229\164\180\231\167\187\229\138\168"] = function()
  Me:startCameraSmoothMovement(Me:getPosition(), Lib.v3(0, 100, 0), 60)
end
GMItem["game_common/\230\146\173\230\148\1903d\229\163\176\233\159\179"] = function()
  Me:play3dSoundByKey("penquan", Me:getPosition())
end
GMItem["game_common/\230\146\173\230\148\190\229\163\176\233\159\179"] = function()
  Me:playSoundByKey("test")
end
GMItem["game_common/\230\181\139\232\175\149\231\186\162\231\130\185"] = function()
  local RedDotConfig = T(Config, "RedDotConfig")
  Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewHair, 1)
end
GMItem["game_common/\229\143\150\230\182\136\231\186\162\231\130\185"] = function()
  local RedDotConfig = T(Config, "RedDotConfig")
  Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewHair, 0)
end
GMItem["game_common/\230\137\147\229\188\128\230\139\141\232\132\184\229\155\190"] = function()
  local FacePhotoHelper = T(Lib, "FacePhotoHelper")
  local resultCfg = FacePhotoHelper:getEffectFacePhotoCfg()
  FacePhotoHelper:openFacePhotoWnd(resultCfg)
end
GMItem["\229\156\176\229\155\190/client\230\159\165\232\175\162\233\155\182\228\187\182"] = GM:inputStr(function(self, value)
  local id = tonumber(value)
  local part = Instance.getByInstanceId(id)
  print("----part--client--", id, Lib.v2s(part))
end)
GMItem["game_common/\230\183\187\229\138\160\229\173\144actor"] = function()
  local slave = {
    actor = "g2052_bike_01.actor",
    parentPoint = {
      bone = "s_hand_r",
      position = Lib.v3(0, 0, 0),
      rotation = Lib.v3(0, 0, 0),
      scale = 1,
      propagateScaling = true,
      alignWorldYAxis = false,
      matchActorOrientation = false
    },
    childPoint = {
      bone = "s_hand_r",
      position = Lib.v3(0, 0, 0),
      rotation = Lib.v3(0, 0, 0),
      scale = 1,
      propagateScaling = true,
      alignWorldYAxis = false,
      matchActorOrientation = false
    }
  }
  Me:addChildActor("hand_r_bike", slave)
end
GMItem["ME/\232\183\179\232\181\183"] = function(self)
  self:recoverEntityProp("jumpSpeed")
  local curValue = tonumber(self:getEntityProp("jumpSpeed"))
  self:deltaEntityProp("jumpSpeed", -curValue + tonumber(3))
  Blockman.Instance():control():jump()
  self:recoverEntityProp("jumpSpeed")
end
