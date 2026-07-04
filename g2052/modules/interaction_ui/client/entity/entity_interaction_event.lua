local interactionEventEngineHandler = interaction_event
local handles = {}
local toggleHeadUIVisible

function interaction_event(name, ...)
  interactionEventEngineHandler(name, ...)
  local func = handles[name]
  if not func then
    return
  end
  func(Me, ...)
end

function toggleHeadUIVisible(hide, objID, headUI)
  if not Me:data("main").displayInteractBtnHideUI then
    Me:data("main").displayInteractBtnHideUI = {}
  end
  if not Me:data("main").displayInteractBtnHideUI[objID] then
    Me:data("main").displayInteractBtnHideUI[objID] = {}
  end
  local dataHideUI = Me:data("main").displayInteractBtnHideUI
  if hide then
    for _, uiName in pairs(headUI or {}) do
      local wnd = UI:getWnd(uiName, true, "*head_" .. objID)
      if wnd then
        wnd:root():SetVisible(false)
        if not dataHideUI[objID][uiName] then
          dataHideUI[objID][uiName] = true
        end
      end
    end
  else
    for uiName, _ in pairs(dataHideUI[objID] or {}) do
      local wnd = UI:getWnd(uiName, true, "*head_" .. objID)
      if wnd then
        wnd:root():SetVisible(true)
      end
    end
    dataHideUI[objID] = nil
  end
end

function handles:ButtonDisplay(objID, context)
  local canHide, btn = context.canHide, context.btnCfg
  local checkCanHide, checkCanShow = btn.checkCanHide, btn.checkCanShow
  if btn.ridePosIndex then
    checkCanHide = {
      funcName = "checkRideOnIndex",
      index = btn.ridePosIndex
    }
  end
  if checkCanHide then
    canHide = Me:checkCond(checkCanHide, objID)
  elseif checkCanShow then
    canHide = not Me:checkCond(checkCanShow, objID)
  end
  if not canHide and Me.customCheckCond then
    local customCheckCanHide, customCheckCanShow = btn.customCheckCanHide, btn.customCheckCanShow
    if customCheckCanHide then
      canHide = Me:customCheckCond(customCheckCanHide, objID)
    elseif customCheckCanShow then
      canHide = not Me:customCheckCond(customCheckCanShow, objID)
    end
  end
  context.canHide = canHide
  if not canHide then
    local target = World.CurWorld:getObject(objID)
    if not target then
      return false
    end
    toggleHeadUIVisible(not context.btnCfg.shieldsInteractionHideUI and true, objID, target:cfg().interactionHideUI)
  end
end

function handles:ButtonSetClickAction(objID, context)
  local btnCfg, callbacks = context.btnCfg, context.innerCallbacks
  local nextCfgOnClick = btnCfg.nextCfgOnClick
  local hideOnClick = btnCfg.hideOnClick
  if nextCfgOnClick then
    callbacks[#callbacks + 1] = function()
      Me:updateObjectInteractionUI({
        objID = objID,
        show = true,
        cfgKey = nextCfgOnClick
      })
      if btnCfg.cameraFocusOnClick then
        Me:petCameraIn(objID, btnCfg.cameraAnimationTime or 1.0)
      end
    end
  elseif hideOnClick then
    callbacks[#callbacks + 1] = function()
      Me:updateObjectInteractionUI({objID = objID, show = false})
      if btnCfg.cameraAnimationTime then
        Me:petCameraOut(btnCfg.cameraAnimationTime or 1.0)
      end
    end
  end
  if btnCfg.shopCfg then
    callbacks[#callbacks + 1] = function()
      if btnCfg.shopCfg == "findInEntityCfg" then
        local obj = World.CurWorld:getEntity(objID)
        if obj and obj:cfg().shopCfg then
          Shop.Buy(obj:cfg().shopCfg, {attachID = objID})
        end
      else
        Shop.Buy(btnCfg.shopCfg, {attachID = objID})
      end
    end
  end
  if btnCfg.emitEvent then
    local key = btnCfg.emitEvent.key
    local args = btnCfg.emitEvent.args
    if Event[key] then
      callbacks[#callbacks + 1] = function()
        Lib.emitEvent(Event[key], table.unpack(args or {}))
      end
    end
  end
  if btnCfg.uiEvent then
    local uiName = btnCfg.uiEvent.uiName or ""
    local args = btnCfg.uiEvent.args
    callbacks[#callbacks + 1] = function()
      if UI:getWnd(uiName) then
        UI:openWnd(uiName, table.unpack(args or {}))
      end
    end
  end
end

function handles:NewButton(objID, context)
  local btnCfg = context.btnCfg
  if btnCfg.imageFunc and Me[btnCfg.imageFunc] then
    btnCfg.image = Me[btnCfg.imageFunc](Me, objID, btnCfg.ridePosIndex) or btnCfg.defaultImage or btnCfg.image
  end
end

function handles:hideInteractionUI(objID, context)
  toggleHeadUIVisible(false, objID)
end

function handles:onAddButtonEnd(objID, context)
  local obj = World.CurWorld:getEntity(objID)
  local key = objID
  if obj then
    key = obj:cfg()._name
  end
  local button = context.button
  button:SetName("interactionBtn_" .. key)
end
