local floor = math.floor
local widget_base = require("ui.widget.widget_base")
local WidgetRolePage2 = Lib.derive(widget_base)
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WidgetRolePage2:init(data)
  widget_base.init(self, "RolePage2.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:initView(data)
end

function WidgetRolePage2:initUI()
  self.lytLine = self:child("RolePage2-Line")
  self.lytContentContainer = self:child("RolePage2-ContentContainer")
  self.imgFunction = self:child("RolePage2-Function")
  self.imgShapeTxtBg = self:child("RolePage2-ShapeTxtBg")
  self.txtShape = self:child("RolePage2-ShapeTxt")
  self.btnSubBtn = self:child("RolePage2-SubBtn")
  self.btnAddBtn = self:child("RolePage2-AddBtn")
  self._contentGridView = GridViewHelper.new({
    name = "colorGridView",
    xCellNum = 6,
    yDis = 16,
    xDis = 17,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    moveAble = true,
    widgetWidth = 38,
    widgetHeight = 38,
    widgetJson = "ColorItem.json",
    widgetName = "colorItem",
    gvParent = self.lytContentContainer,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
end

local function float_equal(x, v)
  local epsilon = 0.01
  return x > v - epsilon and x < v + epsilon
end

function WidgetRolePage2:initEvent()
  self:subscribe(self.btnSubBtn, UIEvent.EventButtonClick, function()
    if self.lockScaleChange then
      return
    end
    if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
      local shapeScale = floor(Me:getGiantScale() * 100) / 100
      if shapeScale <= World.cfg.dramaSetting.giantSetting.minShapeScale then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.shape.scale.is.min"))
        return
      end
    else
      local shapeScale = floor(Me:getShapeScale() * 100) / 100
      if shapeScale <= World.cfg.shapeScaleSetting.min then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.shape.scale.is.min"))
        return
      end
    end
    Me:sendPacket({
      pid = "changeShapeScale",
      action = "sub"
    })
    self.lockScaleChange = true
  end)
  self:subscribe(self.btnAddBtn, UIEvent.EventButtonClick, function()
    if self.lockScaleChange then
      return
    end
    if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
      local shapeScale = floor(Me:getGiantScale() * 10) / 10
      if shapeScale >= World.cfg.dramaSetting.giantSetting.maxShapeScale then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.shape.scale.is.max"))
        return
      end
    else
      local shapeScale = floor(Me:getShapeScale() * 10) / 10
      if shapeScale >= World.cfg.shapeScaleSetting.max then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.shape.scale.is.max"))
        return
      end
    end
    Me:sendPacket({
      pid = "changeShapeScale",
      action = "add"
    })
    self.lockScaleChange = true
  end)
  Lib.subscribeEvent(Event.EVENT_SHAPE_SCALE_UPDATE, function()
    self:updateCurShapeScale()
    self.lockScaleChange = nil
  end)
end

function WidgetRolePage2:updateCurShapeScale()
  if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    local shapeScale = Me:getGiantScale()
    self.txtShape:SetText(shapeScale)
  else
    local shapeScale = Me:getShapeScale()
    self.txtShape:SetText(shapeScale)
  end
end

function WidgetRolePage2:initView(data)
  if data.list and next(data.list) ~= nil then
    for _, v in pairs(data.list) do
      table.sort(v.member, function(a, b)
        if a.priority == b.priority then
          return a.id < b.id
        else
          return a.priority < b.priority
        end
      end)
      self._contentGridView:setData(v.member, -1, nil, true, true)
      break
    end
  end
  self:updateCurShapeScale()
end

function WidgetRolePage2:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetRolePage2
