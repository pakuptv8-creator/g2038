local WinPartsHangPointEditor = M
local InteractEventConfig = T(Config, "InteractEventConfig")
local InteractEventReadMeConfig = T(Config, "InteractEventReadMeConfig")
local PART_SP_COUNT = 8
local PART_TRIGGER_COUNT = 8

function WinPartsHangPointEditor:init()
  WinBase.init(self, "partsHangPointEditor.json")
  self._allEvent = {}
  self.curSelectPart = nil
  self.spItem = {}
  self.spParam = {}
  self.trigger = {}
  self.isShowFuncList = false
  self.selectFunc = ""
  self.funcListItem = {}
  self.funcType = ""
  self.tipEffect = ""
  self.tipEffectOffset = ""
  self.ClickInteractionEffectNode = {}
  self:initUI()
  self:initEvent()
end

function WinPartsHangPointEditor:initUI()
  self.txtPartsHangPointEditorCurPartTitle = self:child("partsHangPointEditor-curPartTitle")
  self.txtPartsHangPointEditorCurPartType = self:child("partsHangPointEditor-curPartType")
  self.txtPartsHangPointEditorCurPartCfg = self:child("partsHangPointEditor-curPartCfg")
  self.lytPartsHangPointEditorTriggerBg = self:child("partsHangPointEditor-triggerBg")
  self.txtPartsHangPointEditorTriggerTitle = self:child("partsHangPointEditor-triggerTitle")
  self.btnPartsHangPointEditorClickTrigger = self:child("partsHangPointEditor-clickTrigger")
  self.imgPartsHangPointEditorClickSelectImg = self:child("partsHangPointEditor-clickSelectImg")
  self.txtPartsHangPointEditorClickTriggerDec = self:child("partsHangPointEditor-clickTriggerDec")
  self.btnPartsHangPointEditorCollisionTrigger = self:child("partsHangPointEditor-collisionTrigger")
  self.imgPartsHangPointEditorCollisionSelectImg = self:child("partsHangPointEditor-collisionSelectImg")
  self.txtPartsHangPointEditorCollisionTriggerDec = self:child("partsHangPointEditor-collisionTriggerDec")
  self.btnPartsHangPointEditorCollisionEndTrigger = self:child("partsHangPointEditor-collisionEndTrigger")
  self.imgPartsHangPointEditorCollisionEndSelectImg = self:child("partsHangPointEditor-collisionEndSelectImg")
  self.txtPartsHangPointEditorCollisionEndTriggerDec = self:child("partsHangPointEditor-collisionEndTriggerDec")
  self.btnPartsHangPointEditorUITrigger = self:child("partsHangPointEditor-UITrigger")
  self.imgPartsHangPointEditorUISelectImg = self:child("partsHangPointEditor-UISelectImg")
  self.btnPartsHangPointEditorPartCollideStartTrigger = self:child("partsHangPointEditor-partCollideStartTrigger")
  self.imgPartsHangPointEditorPartCollideStartSelectImg = self:child("partsHangPointEditor-partCollideStartSelectImg")
  self.btnPartsHangPointEditorPartCollideStopTrigger = self:child("partsHangPointEditor-partCollideStopTrigger")
  self.imgPartsHangPointEditorPartCollideStopSelectImg = self:child("partsHangPointEditor-partCollideStopSelectImg")
  self.btnPartsHangPointEditorGameTimeTrigger = self:child("partsHangPointEditor-gameTimeTrigger")
  self.imgPartsHangPointEditorGameTimeSelectImg = self:child("partsHangPointEditor-gameTimeSelectImg")
  self.btnPartsHangPointEditorPartCreateTrigger = self:child("partsHangPointEditor-partCreateTrigger")
  self.imgPartsHangPointEditorPartCreateSelectImg = self:child("partsHangPointEditor-partCreateSelectImg")
  self.lytPartsHangPointEditorSpSetting = self:child("partsHangPointEditor-spSetting")
  self.txtPartsHangPointEditorSPTitle = self:child("partsHangPointEditor-s_pTitle")
  self.lytPartsHangPointEditorSp1 = self:child("partsHangPointEditor-sp1")
  self.lytPartsHangPointEditorSp2 = self:child("partsHangPointEditor-sp2")
  self.lytPartsHangPointEditorSp3 = self:child("partsHangPointEditor-sp3")
  self.lytPartsHangPointEditorSp4 = self:child("partsHangPointEditor-sp4")
  self.lytPartsHangPointEditorSp5 = self:child("partsHangPointEditor-sp5")
  self.lytPartsHangPointEditorSp6 = self:child("partsHangPointEditor-sp6")
  self.lytPartsHangPointEditorSp7 = self:child("partsHangPointEditor-sp7")
  self.lytPartsHangPointEditorSp8 = self:child("partsHangPointEditor-sp8")
  self.lytPartsHangPointEditorFuncLyt = self:child("partsHangPointEditor-funcLyt")
  self.txtPartsHangPointEditorFuncTitle = self:child("partsHangPointEditor-funcTitle")
  self.btnPartsHangPointEditorFuncListBtn = self:child("partsHangPointEditor-funcListBtn")
  self.lytPartsHangPointEditorFuncListBg = self:child("partsHangPointEditor-funcListBg")
  self.lytPartsHangPointEditorFuncList = self:child("partsHangPointEditor-funcList")
  self.funcListGridView = UIMgr:new_widget("grid_view")
  self.funcListGridView:InitConfig(0, -7, 1)
  self.funcListGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPartsHangPointEditorFuncList:AddChildWindow(self.funcListGridView)
  self.lytPartsHangPointEditorFuncListBg:SetVisible(false)
  self.btnPartsHangPointEditorCloseBtn = self:child("partsHangPointEditor-closeBtn")
  self.btnPartsHangPointEditorSaveBtn = self:child("partsHangPointEditor-saveBtn")
  self.btnPartsHangPointServerFuncBtn = self:child("partsHangPointEditor-serverFuncBtn")
  self.btnPartsHangPointClientFuncBtn = self:child("partsHangPointEditor-clientFuncBtn")
  self.imgPartsHangPointServerFuncSelected = self:child("partsHangPointEditor-serverFuncSelected")
  self.imgPartsHangPointClientFuncSelected = self:child("partsHangPointEditor-clientFuncSelected")
  self.editPartsHangPointEditorTipEffectInput = self:child("partsHangPointEditor-tipEffectInput")
  self.editPartsHangPointEditorTipEffectOffsetInput = self:child("partsHangPointEditor-tipEffectOffsetInput")
  self.btnPartsHangPointEditorPosXAddBtn = self:child("partsHangPointEditor-tipEffectPosXAddBtn")
  self.btnPartsHangPointEditorPosYAddBtn = self:child("partsHangPointEditor-tipEffectPosYAddBtn")
  self.btnPartsHangPointEditorPosZAddBtn = self:child("partsHangPointEditor-tipEffectPosZAddBtn")
  self.btnPartsHangPointEditorPosXSubBtn = self:child("partsHangPointEditor-tipEffectPosXSubBtn")
  self.btnPartsHangPointEditorPosYSubBtn = self:child("partsHangPointEditor-tipEffectPosYSubBtn")
  self.btnPartsHangPointEditorPosZSubBtn = self:child("partsHangPointEditor-tipEffectPosZSubBtn")
  self.imgPartsHangPointEditorClickSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorCollisionSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorCollisionEndSelectImg:SetVisible(false)
  for i = 1, PART_TRIGGER_COUNT do
    self.trigger[i] = false
  end
end

function WinPartsHangPointEditor:clearData()
  self.curSelectPart = nil
  self.spItem = {}
  self.spParam = {}
  self.trigger = {}
  self.isShowFuncList = false
  self.selectFunc = ""
  self.funcListItem = {}
  self.funcType = ""
  self.tipEffect = ""
  self.tipEffectOffset = ""
  for _, v in pairs(self.ClickInteractionEffectNode) do
    if v and v:isValid() then
      v:destroy()
    end
  end
  self.ClickInteractionEffectNode = {}
end

function WinPartsHangPointEditor:initEvent()
  self:subscribe(self.editPartsHangPointEditorTipEffectInput, UIEvent.EventEditTextInput, function()
    local param = self.editPartsHangPointEditorTipEffectInput:GetPropertyString("Text", "")
    self.tipEffect = param
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.editPartsHangPointEditorTipEffectOffsetInput, UIEvent.EventEditTextInput, function()
    local param = self.editPartsHangPointEditorTipEffectOffsetInput:GetPropertyString("Text", "")
    self.tipEffectOffset = param
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosXAddBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local params = (data[1] or 0) + 0.1 .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosYAddBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) + 0.1 .. "#" .. (data[3] or 0)
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosZAddBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0) + 0.1
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosXSubBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local x = (data[1] or 0) - 0.1
    local params = x .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosYSubBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local y = (data[2] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. y .. "#" .. (data[3] or 0)
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorPosZSubBtn, UIEvent.EventButtonClick, function()
    local data = Lib.splitString(self.tipEffectOffset or "", "#", true)
    local z = (data[3] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. z
    self.tipEffectOffset = params
    self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
    self:showPartClickInteractionTip()
  end)
  self:subscribe(self.btnPartsHangPointEditorClickTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[1] then
      self.imgPartsHangPointEditorClickSelectImg:SetVisible(false)
      self.trigger[1] = false
    else
      self.imgPartsHangPointEditorClickSelectImg:SetVisible(true)
      self.trigger[1] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorCollisionTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[2] then
      self.imgPartsHangPointEditorCollisionSelectImg:SetVisible(false)
      self.trigger[2] = false
    else
      self.imgPartsHangPointEditorCollisionSelectImg:SetVisible(true)
      self.trigger[2] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorCollisionEndTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[3] then
      self.imgPartsHangPointEditorCollisionEndSelectImg:SetVisible(false)
      self.trigger[3] = false
    else
      self.imgPartsHangPointEditorCollisionEndSelectImg:SetVisible(true)
      self.trigger[3] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorUITrigger, UIEvent.EventButtonClick, function()
    if self.trigger[4] then
      self.imgPartsHangPointEditorUISelectImg:SetVisible(false)
      self.trigger[4] = false
    else
      self.imgPartsHangPointEditorUISelectImg:SetVisible(true)
      self.trigger[4] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorPartCollideStartTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[5] then
      self.imgPartsHangPointEditorPartCollideStartSelectImg:SetVisible(false)
      self.trigger[5] = false
    else
      self.imgPartsHangPointEditorPartCollideStartSelectImg:SetVisible(true)
      self.trigger[5] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorPartCollideStopTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[6] then
      self.imgPartsHangPointEditorPartCollideStopSelectImg:SetVisible(false)
      self.trigger[6] = false
    else
      self.imgPartsHangPointEditorPartCollideStopSelectImg:SetVisible(true)
      self.trigger[6] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorGameTimeTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[7] then
      self.imgPartsHangPointEditorGameTimeSelectImg:SetVisible(false)
      self.trigger[7] = false
    else
      self.imgPartsHangPointEditorGameTimeSelectImg:SetVisible(true)
      self.trigger[7] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorPartCreateTrigger, UIEvent.EventButtonClick, function()
    if self.trigger[8] then
      self.imgPartsHangPointEditorPartCreateSelectImg:SetVisible(false)
      self.trigger[8] = false
    else
      self.imgPartsHangPointEditorPartCreateSelectImg:SetVisible(true)
      self.trigger[8] = true
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorFuncListBtn, UIEvent.EventButtonClick, function()
    if self.isShowFuncList then
      self.lytPartsHangPointEditorFuncListBg:SetVisible(false)
      self.isShowFuncList = false
    else
      self.lytPartsHangPointEditorFuncListBg:SetVisible(true)
      self.isShowFuncList = true
      for i, item in pairs(self.spItem) do
        item:invoke("showHangPointPanel", false)
      end
    end
  end)
  self:subscribe(self.btnPartsHangPointEditorCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPartsHangPointServerFuncBtn, UIEvent.EventButtonClick, function()
    self:setFuncTypeState("server")
  end)
  self:subscribe(self.btnPartsHangPointClientFuncBtn, UIEvent.EventButtonClick, function()
    self:setFuncTypeState("client")
  end)
  self:subscribe(self.btnPartsHangPointEditorSaveBtn, UIEvent.EventButtonClick, function()
    if not self.curSelectPart or not self.curSelectPart:isValid() then
      return
    end
    local trigger = ""
    for i = 1, #self.trigger do
      if self.trigger[i] then
        if trigger == "" then
          trigger = i
        else
          trigger = trigger .. "#" .. i
        end
      end
    end
    local tbData = {
      s_key = self.curSelectPart.name,
      s_func = self.selectFunc,
      s_triggers = trigger,
      s_clickTipEffect = self.tipEffect,
      s_clickTipOffset = self.tipEffectOffset,
      s_sync = self.funcType,
      s_p1 = self.spParam[1] or "",
      s_p2 = self.spParam[2] or "",
      s_p3 = self.spParam[3] or "",
      s_p4 = self.spParam[4] or "",
      s_p5 = self.spParam[5] or "",
      s_p6 = self.spParam[6] or "",
      s_p7 = self.spParam[7] or "",
      s_p8 = self.spParam[8] or ""
    }
    InteractEventConfig:rewriteCfg(tbData)
    Me:sendPacket({
      pid = "rewriteInteractEventCfg"
    })
  end)
end

function WinPartsHangPointEditor:showPartClickInteractionTip()
  if not self.curSelectPart or not self.curSelectPart:isValid() then
    return
  end
  if not self.curPartClickInteractionTip then
    self.curPartClickInteractionTip = {}
  end
  local pos = self.curSelectPart.getPosition and self.curSelectPart:getPosition() or Lib.v3(0, 0, 0)
  local clickTipOffset = Lib.createV3ByString(self.tipEffectOffset)
  if clickTipOffset then
    local offset = Lib.correctMoveDistance(self.curSelectPart:getRotation(), clickTipOffset)
    pos = pos + offset
  end
  local effectName = self.tipEffect
  local scale = Lib.v3(1, 1, 1)
  local scene = self.curSelectPart:getScene()
  local partId = self.curSelectPart:getInstanceID()
  if effectName then
    if self.ClickInteractionEffectNode[partId] and self.ClickInteractionEffectNode[partId]:isValid() then
      self.ClickInteractionEffectNode[partId]:destroy()
    end
    local effectNode = EffectNode.Load(effectName)
    effectNode:start()
    effectNode:setWorldPosition(pos)
    effectNode:setWorldScale(scale)
    scene:getRoot():addChild(effectNode)
    self.ClickInteractionEffectNode[partId] = effectNode
  end
end

function WinPartsHangPointEditor:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PART_CLICK, function(part, from)
    if not part or not part:isValid() then
      return
    end
    if not (from and from:isValid()) or not from.isPlayer then
      return
    end
    if self.curSelectPart and self.curSelectPart:isValid() and self.curSelectPart:getInstanceID() == part:getInstanceID() then
      return
    end
    self:clearData()
    self.curSelectPart = part
    self:initView()
  end)
end

function WinPartsHangPointEditor:initView()
  local prop
  if self.curSelectPart then
    local partName = self.curSelectPart.name or ""
    local cfgName = self.curSelectPart.mesh or ""
    self.txtPartsHangPointEditorCurPartType:SetText("type:" .. partName)
    self.txtPartsHangPointEditorCurPartCfg:SetText("cfg:" .. cfgName)
    prop = InteractEventConfig:getCfgById(partName)
    if prop then
      self.tipEffect = prop.clickTipEffect
      self.tipEffectOffset = (prop.clickTipOffset.x or 0) .. "#" .. (prop.clickTipOffset.y or 0) .. "#" .. (prop.clickTipOffset.z or 0)
    end
    self:setFuncTypeState(prop and prop.sync or nil)
  else
    self.funcType = ""
    self.txtPartsHangPointEditorCurPartType:SetText("")
    self.txtPartsHangPointEditorCurPartCfg:SetText("")
    self:setFuncTypeState()
  end
  self:updateTriggerState(prop)
  self:setSpParam(prop)
  self:showFuncList(prop)
  self:initPartClickInteractionTip(prop)
end

function WinPartsHangPointEditor:initPartClickInteractionTip(prop)
  if not self.curSelectPart or not self.curSelectPart:isValid() then
    return
  end
  if not prop then
    return
  end
  self.tipEffect = prop.clickTipEffect
  local params = prop.clickTipOffset.x .. "#" .. prop.clickTipOffset.y .. "#" .. prop.clickTipOffset.z
  self.tipEffectOffset = tostring(params)
  self.editPartsHangPointEditorTipEffectInput:SetProperty("Text", prop.clickTipEffect or "")
  self.editPartsHangPointEditorTipEffectOffsetInput:SetProperty("Text", tostring(params))
  self:showPartClickInteractionTip()
end

function WinPartsHangPointEditor:setFuncTypeState(sync)
  if sync == "server" then
    self.imgPartsHangPointServerFuncSelected:SetVisible(true)
    self.imgPartsHangPointClientFuncSelected:SetVisible(false)
    self.funcType = "server"
  elseif sync == "client" then
    self.imgPartsHangPointServerFuncSelected:SetVisible(false)
    self.imgPartsHangPointClientFuncSelected:SetVisible(true)
    self.funcType = "client"
  else
    self.imgPartsHangPointServerFuncSelected:SetVisible(false)
    self.imgPartsHangPointClientFuncSelected:SetVisible(false)
    self.funcType = ""
  end
end

function WinPartsHangPointEditor:showFuncList(prop)
  self.funcListGridView:RemoveAllItems()
  self.selectFunc = prop and prop.func or ""
  local cfg = InteractEventReadMeConfig:getAllCfgs()
  for funcName, data in pairs(cfg) do
    local item = UIMgr:new_widget("partsHangPointFuncItem", function(func)
      self.selectFunc = func
      for funcN, dataItem in pairs(self.funcListItem) do
        if funcN ~= func then
          dataItem:invoke("setSelectState", false)
        end
      end
    end)
    if item then
      item:SetArea({0, 0}, {0, 0}, {0, 300}, {0, 35})
      self.funcListGridView:AddItem(item)
      local isSelect = false
      if prop and prop.func and prop.func == funcName then
        isSelect = true
      else
        isSelect = false
      end
      item:invoke("setData", data.func, data.dec, isSelect)
      self.funcListItem[funcName] = item
    else
      Lib.logDebug("Error\239\188\154item is nil when  UIMgr:new_widget(HangUpMapItem)")
    end
  end
end

local function removeAllChildWnd(win)
  local count = win:GetChildCount()
  for i = 1, count do
    local child = win:GetChildByIndex(0)
    win:RemoveChildWindow1(child)
  end
end

function WinPartsHangPointEditor:getSitPosition(initPos, offsetPosX, offsetPosY, offsetPosZ)
  local function getAngele(yaw)
    local angle = yaw / 180 * math.pi
    
    return math.floor(angle * 100000) / 100000
  end
  
  local yaw = getAngele(Me:getRotationYaw())
  local changeX = offsetPosX * math.cos(yaw) - offsetPosZ * math.sin(yaw)
  local changeZ = offsetPosZ * math.cos(yaw) + offsetPosX * math.sin(yaw)
  local pos = initPos
  pos.y = pos.y + offsetPosY
  pos.x = pos.x + changeX
  pos.z = pos.z + changeZ
  return pos
end

function WinPartsHangPointEditor:setSpParam(cfg)
  for i = 1, PART_SP_COUNT do
    if self["lytPartsHangPointEditorSp" .. i] then
      removeAllChildWnd(self["lytPartsHangPointEditorSp" .. i])
      local spItem = UIMgr:new_widget("partsHangPointItem", function(index, param)
        self.spParam[index] = param
        if self.curSelectPart then
          if self.selectFunc == "onFurnitureInteract" or self.selectFunc == "onSwingInteract" then
            local tbData = Lib.split(param, "#")
            if tbData[1] and tbData[2] and tbData[3] and tbData[4] then
              local pos = self.curSelectPart:getPosition()
              Me:playClientAction(tbData[1], -1)
              Me:setAlwaysAction(tbData[1])
              local newPos = self:getSitPosition(pos, tbData[2], tbData[3], tbData[4])
              Me:setPosition(newPos)
            end
            return
          end
          if not self.selectFunc or self.selectFunc == "" then
            Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\174\190\231\189\174\229\138\159\232\131\189\229\155\158\232\176\131")
            return
          end
          Me:sendPacket({
            pid = "tryInteract",
            param = self.spParam,
            trigger = self.trigger,
            partId = self.curSelectPart:getInstanceID(),
            fromID = Me.objID,
            func = self.selectFunc
          })
        end
      end, function(index)
        self.lytPartsHangPointEditorFuncListBg:SetVisible(false)
        self.isShowFuncList = false
        for i, item in pairs(self.spItem) do
          if index ~= i then
            item:invoke("showHangPointPanel", false)
          end
        end
      end)
      spItem:SetArea({0, 0}, {0, 0}, {0, 180}, {0, 30})
      self.spParam[i] = cfg and cfg.params and cfg.params[i] or ""
      spItem:invoke("setData", i, cfg and cfg.params and cfg.params[i])
      self.spItem[i] = spItem
      self["lytPartsHangPointEditorSp" .. i]:AddChildWindow(spItem)
    end
  end
end

function WinPartsHangPointEditor:updateTriggerState(cfg)
  self.imgPartsHangPointEditorClickSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorCollisionSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorCollisionEndSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorUISelectImg:SetVisible(false)
  self.imgPartsHangPointEditorPartCollideStartSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorPartCollideStopSelectImg:SetVisible(false)
  self.imgPartsHangPointEditorGameTimeSelectImg:SetVisible(false)
  for i = 1, PART_TRIGGER_COUNT do
    self.trigger[i] = false
  end
  if cfg then
    for i = 1, #(cfg.triggersData or {}) do
      if cfg.triggersData[i] == 1 then
        self.imgPartsHangPointEditorClickSelectImg:SetVisible(true)
        self.trigger[1] = true
      elseif cfg.triggersData[i] == 2 then
        self.imgPartsHangPointEditorCollisionSelectImg:SetVisible(true)
        self.trigger[2] = true
      elseif cfg.triggersData[i] == 3 then
        self.imgPartsHangPointEditorCollisionEndSelectImg:SetVisible(true)
        self.trigger[3] = true
      elseif cfg.triggersData[i] == 4 then
        self.imgPartsHangPointEditorUISelectImg:SetVisible(true)
        self.trigger[4] = true
      elseif cfg.triggersData[i] == 5 then
        self.imgPartsHangPointEditorPartCollideStartSelectImg:SetVisible(true)
        self.trigger[5] = true
      elseif cfg.triggersData[i] == 6 then
        self.imgPartsHangPointEditorPartCollideStopSelectImg:SetVisible(true)
        self.trigger[6] = true
      elseif cfg.triggersData[i] == 7 then
        self.imgPartsHangPointEditorGameTimeSelectImg:SetVisible(true)
        self.trigger[7] = true
      elseif cfg.triggersData[i] == 8 then
        self.imgPartsHangPointEditorPartCreateSelectImg:SetVisible(true)
        self.trigger[8] = true
      end
    end
  end
end

function WinPartsHangPointEditor:onHide()
  UI:closeWnd("partsHangPointEditor")
end

function WinPartsHangPointEditor:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("partsHangPointEditor")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPartsHangPointEditor:onOpen()
  self:initView()
  self:subscribeEvent()
  self:clearData()
end

function WinPartsHangPointEditor:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPartsHangPointEditor
