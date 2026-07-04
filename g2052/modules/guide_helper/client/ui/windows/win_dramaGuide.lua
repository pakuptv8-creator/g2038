local WinDramaGuide = M

local function fetchImg(png, program)
  local img = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "")
  img:SetImage(png)
  img:setProgram(program)
  img:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  img:SetAlwaysOnTop(true)
  return img
end

function WinDramaGuide:init()
  WinBase.init(self, "DramaGuide.json")
  self._allEvent = {}
  self.guideStep = 1
  self.guideCondition = {}
  self:initUI()
  self:initEvent()
end

function WinDramaGuide:initUI()
  self.lytFinger = self:child("DramaGuide-Finger")
  self.lytTipsPanel = self:child("DramaGuide-TipsPanel")
  self.txtTipsText = self:child("DramaGuide-TipsText")
  self.mask = self:child("DramaGuide-MaskImage")
end

function WinDramaGuide:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.isGuideActive then
      self:nextStep()
    end
  end)
end

function WinDramaGuide:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GUIDE_ACTIVE_CONDITION, function(condition)
    self:updateCondition(condition)
  end)
end

function WinDramaGuide:initView()
end

function WinDramaGuide:initGuide(winName)
  self.guideCfg = World.cfg.guideHelper.guideCfg and World.cfg.guideHelper.guideCfg[winName]
  self:initStep(1)
end

function WinDramaGuide:initStep(step)
  self.guideStep = step
  if self.guideStep > #self.guideCfg then
    self:guideFinish()
  else
    self.isGuideActive = self:checkCondition()
    if self.isGuideActive then
      self:showGuide()
    else
      self:setMask({
        0,
        0,
        0,
        0
      })
      self.lytFinger:SetVisible(false)
    end
  end
end

function WinDramaGuide:nextStep()
  if self.guideCfg then
    self:initStep(self.guideStep + 1)
  end
end

function WinDramaGuide:showGuide()
  if self.guideCfg then
    local cfg = self.guideCfg[self.guideStep]
    if cfg then
      local highLightNodeCfg = cfg.highLightNode
      if highLightNodeCfg then
        local highLightNode = UI:findChild(highLightNodeCfg.parent .. "/" .. highLightNodeCfg.node, highLightNodeCfg.index)
        if highLightNode then
          local area = highLightNode:GetRenderArea()
          local size = highLightNode:GetPixelSize()
          self:setMask(area)
          local fingerNodeCfg = highLightNodeCfg.fingerNode
          if fingerNodeCfg then
            local fingerNode = highLightNode:child(fingerNodeCfg.node)
            if fingerNode then
              area = fingerNode:GetRenderArea()
              size = fingerNode:GetPixelSize()
            end
          end
          self:setFinger(area[3] - size.x / 2, area[4] - size.y / 2, cfg.tips and cfg.tips.tipsPos or nil, cfg.tips and cfg.tips.lang or nil)
        else
          self:nextStep()
        end
      end
    end
  end
end

function WinDramaGuide:setMask(area, posx, posy, radius)
  self:setRectangleMask(self.mask, area)
end

function WinDramaGuide:setRectangleMask(node, area)
  local maskName = "{0D2D61DC-8DF6-47A0-BA88-892C66979CFB}"
  local img = node:child(maskName)
  if not img then
    img = fetchImg("empty.png", "RECTANGLEMASK")
    img:SetTouchable(false)
    node:AddChildWindow(img, maskName)
  end
  local size = img:GetPixelSize()
  img:material():iSize(size.x, size.y)
  img:material():iColor(0, 0, 0, 0.5)
  img:material():iTopleft(area[1], area[2], 0, 0)
  img:material():iBottomright(area[3], area[4], 0, 0)
end

function WinDramaGuide:setFinger(posX, posY, tipsHAlign, lang)
  self.lytFinger:SetVisible(true)
  self.lytFinger:SetXPosition({0, posX})
  self.lytFinger:SetYPosition({0, posY})
  if tipsHAlign then
    local cfg = World.cfg.guideHelper.tipsPos and World.cfg.guideHelper.tipsPos[tipsHAlign]
    if cfg then
      self.lytTipsPanel:SetVisible(true)
      self.lytTipsPanel:SetHorizontalAlignment(cfg.HAlign)
      self.lytTipsPanel:SetXPosition(cfg.x)
      if lang then
        local strW = self.txtTipsText:GetFont():GetStringWidth(Lang:toText(lang))
        self.txtTipsText:SetText(Lang:toText(lang))
        self.lytTipsPanel:SetWidth({
          0,
          strW + 60
        })
      end
    else
      self.lytTipsPanel:SetVisible(false)
    end
  end
end

function WinDramaGuide:guideFinish()
  Me:addGuideData(self.winName)
  self:onHide()
end

function WinDramaGuide:updateCondition(condition)
  if not condition then
    return
  end
  self.guideCondition[condition] = true
  if self:checkCondition() and not self.isGuideActive then
    self.isGuideActive = true
    self:showGuide()
  end
end

function WinDramaGuide:checkCondition()
  if self.guideCfg then
    local cfg = self.guideCfg[self.guideStep]
    if cfg then
      if cfg.activeCondition then
        return self.guideCondition[cfg.activeCondition]
      else
        return true
      end
    end
  end
  return false
end

function WinDramaGuide:clearCondition()
  self.guideCondition = {}
end

function WinDramaGuide:onHide()
  UI:closeWnd("dramaGuide")
end

function WinDramaGuide:onOpen(winName)
  self.winName = winName
  self:initGuide(winName)
  self:initView()
  self:subscribeEvent()
end

function WinDramaGuide:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:clearCondition()
  local childCount = self.mask:GetChildCount()
  if 0 < childCount then
    self.mask:RemoveChildWindow1(self.mask:GetChildByIndex(0))
  end
end

return WinDramaGuide
