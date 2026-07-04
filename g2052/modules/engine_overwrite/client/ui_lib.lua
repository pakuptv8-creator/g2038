local GUIWindow = _ENV.GUIWindow
local _worksTextures = {}

function GUIWindow:setTimerGoing(start)
  local openTime = self:data("engine_open_time")
  if start then
    self:setData("engine_open_time", os.time())
  elseif openTime then
    self:setData("engine_open_time_length", os.time() - openTime)
    self:setData("engine_open_time", nil)
  end
end

function GUIWindow:getTotalOpenTime()
  local totalTime = self:data("engine_open_time_length") or 0
  local openTime = self:data("engine_open_time")
  if openTime then
    totalTime = os.time() - openTime
  end
  return totalTime
end

function UILib.uiFollowObject(ui, objID, params)
  params = params or {}
  local object = World.CurWorld:getObject(tonumber(objID))
  if not object or not object:isValid() then
    return
  end
  local autoScale = false
  local rateTime = 1
  local offset = Lib.v3(0, 0, 0)
  local anchor = params.anchor
  params.anchorX = anchor and anchor.x or 0.5
  params.anchorY = anchor and anchor.y or 0.5
  params.autoScale = params.autoScale or autoScale
  params.minScale = params.minScale or 0.5
  params.maxScale = params.maxScale or 1.5
  params.offset = params.offset and Lib.tov3(params.offset) or offset
  if params.autoAddDeskop == nil then
    params.autoAddDeskop = false
  end
  if params.canAroundYaw == nil then
    params.canAroundYaw = false
  end
  rateTime = params.rateTime or rateTime
  local autoAddDeskop = params.autoAddDeskop
  local desktop = GUISystem.instance:GetRootWindow()
  if autoAddDeskop then
    ui:SetLevel(100)
    desktop:AddChildWindow(ui)
  end
  Blockman.instance:createFollowObjectWindow(objID, ui, params)
  local stopTimer = World.Timer(rateTime, function()
    if not object:isValid() then
      Blockman.instance:removeFollowWindow(ui)
      return
    end
    if params.showRange then
      local MePos = Me:getPosition()
      if (Lib.v3(MePos.x, MePos.y, MePos.z) - object:getPosition()):len() > params.showRange then
        Blockman.instance:removeFollowWindow(ui)
        return
      end
    end
    return true
  end)
  return function()
    stopTimer()
    Blockman.instance:removeFollowWindow(ui)
  end
end

function UILib.uiFollowInstance(ui, pos, params)
  params = params or {}
  local autoScale = false
  local rateTime = 1
  local offset = Lib.v3(0, 0, 0)
  local anchor = params.anchor
  params.anchorX = anchor and anchor.x or 0.5
  params.anchorY = anchor and anchor.y or 0.5
  params.autoScale = params.autoScale or autoScale
  params.minScale = params.minScale or 0.5
  params.maxScale = params.maxScale or 1.5
  params.offset = params.offset and Lib.tov3(params.offset) or offset
  pos = pos + params.offset
  if params.autoAddDeskop == nil then
    params.autoAddDeskop = false
  end
  if params.canAroundYaw == nil then
    params.canAroundYaw = false
  end
  rateTime = params.rateTime or rateTime
  local autoAddDeskop = params.autoAddDeskop
  local desktop = GUISystem.instance:GetRootWindow()
  if autoAddDeskop then
    ui:SetLevel(100)
    desktop:AddChildWindow(ui)
  end
  Blockman.instance:createFollowPosWindow(pos, ui, params)
  return function()
    Blockman.instance:removeFollowWindow(ui)
  end
end

function UILib.headTopUIFollowObject(ui, objID)
  local object = World.CurWorld:getObject(tonumber(objID))
  if not object or not object:isValid() then
    return
  end
  local ui = UIMgr:new_widget("chatBubbleWnd")
  local chatBubbleSetting = World.cfg.chatSetting.chatBubbleSetting
  local showType = 2
  if showType == 1 then
    local params = {}
    local rateTime = 1
    params.anchorX = 0.5
    params.anchorY = 0
    params.autoScale = true
    params.minScale = chatBubbleSetting.minScale or 0.5
    params.maxScale = chatBubbleSetting.maxScale or 1
    params.offset = Lib.v3(0, 3, 0)
    params.autoAddDeskop = true
    params.canAroundYaw = false
    params.showRange = World.cfg.chatSetting.chatBubbleSetting.showRange or 10
    local autoAddDeskop = params.autoAddDeskop
    local desktop = GUISystem.instance:GetRootWindow()
    if autoAddDeskop then
      ui:SetLevel(100)
      desktop:AddChildWindow(ui)
    end
    Blockman.instance:createFollowObjectWindow(objID, ui, params)
    local stopTimer = World.Timer(rateTime, function()
      if not object or not object:isValid() then
        Blockman.instance:removeFollowWindow(ui)
        return
      end
      if params.showRange then
        local MePos = Me:getPosition()
        if (Lib.v3(MePos.x, MePos.y, MePos.z) - object:getPosition()):len() > params.showRange then
          Blockman.instance:removeFollowWindow(ui)
          object.headBubbleWnd = nil
          return
        end
      end
      return true
    end)
  elseif showType == 2 then
    local width = chatBubbleSetting.maxWidth
    local height = chatBubbleSetting.itemHeight * chatBubbleSetting.showNum
    local maxScale = chatBubbleSetting.maxScale
    local minScale = chatBubbleSetting.minScale
    local minDis = chatBubbleSetting.minDis
    local midDis = chatBubbleSetting.midDis
    local maxDis = chatBubbleSetting.maxDis
    local offsetPos = chatBubbleSetting.offsetPos
    UI:openGUIFollowWnd(objID, ui, width, height, maxScale, minScale, minDis, midDis, maxDis, offsetPos, {
      x = 0,
      y = 0,
      z = 0
    })
    local stopTimer = World.Timer(1, function()
      if not object or not object:isValid() then
        UI:closeGUIFollowWnd(objID)
        return
      end
      if chatBubbleSetting.showRange then
        local MePos = Me:getPosition()
        if (Lib.v3(MePos.x, MePos.y, MePos.z) - object:getPosition()):len() > chatBubbleSetting.showRange then
          UI:closeGUIFollowWnd(objID)
          object.headBubbleWnd = nil
          return
        end
      end
      return true
    end)
  end
  return ui
end

function UI:setViewTexture(key, view)
  print("---setViewTexture--")
  local texture = _worksTextures[key]
  if not texture then
    texture = Lib.derive(require("special.block_color_texture"))
    texture:initFromWin(key)
    texture:loadColorInfoFromUrl(key)
    _worksTextures[key] = texture
  end
  texture:show()
  view:SetImage(texture:getTextureName())
end
