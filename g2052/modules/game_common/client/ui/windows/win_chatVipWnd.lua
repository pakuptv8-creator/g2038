local WinChatVipWnd = M

function WinChatVipWnd:init()
  WinBase.init(self, "ChatVipWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinChatVipWnd:initUI()
  self.lytColorPanel = self:child("ChatVipWnd-ColorPanel")
  self.gvColorList = UIMgr:new_widget("grid_view")
  self.lytColorPanel:AddChildWindow(self.gvColorList)
  self.gvColorList:SethScorllMoveAble(false)
  self.gvColorList:SetvScorllMoveAble(true)
  self.gvColorList:SetArea({0, 0}, {0, 10}, {1, 0}, {1, -10})
  self.gvColorList:InitConfig(0, 0, 1)
  self.colorCells = {}
  self.gvColorList:InitConfig(10, 10, 5)
  self:updateColorListShow()
end

function WinChatVipWnd:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinChatVipWnd:subscribeEvent()
end

function WinChatVipWnd:initView()
  self.curContentColor = Me:getTextVipColor()
  self:updateCurSelectColor(self.curContentColor)
end

function WinChatVipWnd:updateColorListShow()
  local data = World.cfg.ChatVipColor
  if data and type(data) == "table" then
    for index, value in ipairs(data or {}) do
      if not self.colorCells[index] then
        local cell = UIMgr:new_widget("chatVipItem")
        cell:invoke("updateInfo", value)
        cell:invoke("updateColorSelectState", false)
        cell:invoke("setClickBackFunc", function(color)
          self:updateCurSelectColor(color)
          Me:setTextVipColor(color)
          self:onHide()
        end)
        self.gvColorList:AddItem(cell)
        self.colorCells[index] = cell
      end
    end
  end
end

function WinChatVipWnd:updateCurSelectColor(color)
  local data = World.cfg.ChatVipColor
  for index, value in ipairs(data or {}) do
    if self.colorCells[index] then
      if value == color then
        self.colorCells[index]:invoke("updateColorSelectState", true)
      else
        self.colorCells[index]:invoke("updateColorSelectState", false)
      end
    end
  end
  self.curContentColor = color
end

function WinChatVipWnd:onHide()
  UI:closeWnd("chatVipWnd")
end

function WinChatVipWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("chatVipWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinChatVipWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinChatVipWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  UI:getWnd("chatMini"):resetExtraIconShow()
end

return WinChatVipWnd
