local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\186\164\228\186\146/\229\138\168\228\189\156"] = GM:inputStr(function(self, value)
  local params = {action = value, time = -1}
  local actionTarget = Me
  local preBaseAction
  if actionTarget.getBaseAction then
    preBaseAction = actionTarget:getBaseAction()
  end
  actionTarget.actionEndTime = actionTarget:updateUpperAction(params.action, params.time) + World.Now()
  if preBaseAction then
    actionTarget:setBaseAction(preBaseAction)
  end
end)
GMItem["\228\186\164\228\186\146/\231\156\188\231\157\155\228\189\141\231\189\174"] = function(self)
  local debugDraw = DebugDraw.instance
  DebugDraw.addEntry("drawMesh", function()
    local eyePos = Me:getEyePos()
    debugDraw:drawSphere(eyePos, 0.02, 4278190335)
    local foot = Me:getPosition()
    debugDraw:drawSphere(foot, 0.02, 16711935)
    debugDraw:drawLine(foot, eyePos, 65535)
  end)
  debugDraw:setEnabled(true)
  debugDraw:setDrawMeshEnabled(true)
end
GMItem["\228\186\164\228\186\146/sceneFalse"] = function(self)
  local uiName = "policePicture"
  local pictureUIKey = uiName .. os.time()
  local pos = Me:getPosition()
  pos.y = pos.y + 3
  pos.x = pos.x + 1
  local rotate = {
    x = 0,
    y = 0,
    z = 0
  }
  local playerList = {
    [1] = {
      userId = Me.platformUserId,
      nameContent = Me:getNameContent(),
      nameColor = Me:getNameColor(),
      sex = Me:data("main").sex or 1,
      actorScale = 0.5,
      skinData = Me:data("skins") or {}
    }
  }
  World.cfg.isUseWorldWindow = false
  UI:openSceneWnd(pictureUIKey, uiName, 6.25, 3.4375, rotate, pos, playerList)
end
GMItem["\228\186\164\228\186\146/cyaw-self"] = function(self)
  self:setBodyYaw(150)
end
GMItem["\228\186\164\228\186\146/cyaw_car"] = function(self)
  if self.rideOnId > 0 then
    local target = World.CurWorld:getEntity(self.rideOnId)
    target:setBodyYaw(20)
  else
    self:setBodyYaw(150)
  end
end
GMItem["\228\186\164\228\186\146/\232\183\159\233\154\143UI"] = function(self)
  local partPop = UIMgr:new_widget("partSceneTips")
  local pos = Me:getPosition()
  pos.y = pos.y + 2
  pos.x = pos.x + 0
  local rotate = {
    x = 0,
    y = 0,
    z = 0
  }
  local removeFun = UILib.uiFollowInstance(partPop, pos, {
    anchor = {x = 0.5, y = 0.5},
    offset = Lib.v3(0, 0, 0),
    minScale = 0.1,
    maxScale = 1,
    autoScale = false,
    autoAddDeskop = true,
    showRange = 3,
    canAroundYaw = false
  })
end
GMItem["\228\186\164\228\186\146/\230\137\147\229\188\128\232\191\155\229\186\166\230\157\161UI"] = function(self)
  UI:openWnd("progressView", 60)
end
GMItem["ME/\230\137\147\229\188\128\231\148\187\230\157\191"] = function(self)
  UI:openWnd("palette")
end
