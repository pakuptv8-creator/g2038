local WinVoice_pack = M

function WinVoice_pack:init()
  WinBase.init(self, "voice_pack.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinVoice_pack:initUI()
  self.imgVoicePackBG = self:child("voice_pack-BG")
  self.lytVoicePackContent = self:child("voice_pack-Content")
  self.gvVoicePack = GridViewHelper.new({
    name = "gvVoicePack",
    xCellNum = 1,
    yDis = 0,
    xDis = 0,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = false,
    widgetWidth = 273,
    widgetHeight = 54,
    widgetJson = "voice_pack_item.json",
    widgetName = "voice_pack_item",
    gvParent = self.lytVoicePackContent,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
  self.voiceAdapter = self.gvVoicePack:getAdapter()
  self.voiceGridView = self.gvVoicePack:getGridView()
  self.voiceGridView:SetAutoColumnCount(false)
  self.voiceGridView:SetMoveAble(true)
  self.voiceGridView:SetvScorllMoveAble(true)
  self.voiceGridView:SethScorllMoveAble(false)
end

function WinVoice_pack:initEvent()
end

function WinVoice_pack:subscribeEvent()
end

function WinVoice_pack:initView()
  if not Me.voicePackData then
    self:onHide()
    return
  end
  self.voiceAdapter:clearItems()
  self.voiceGridView:ResetPos()
  local cfgs = Me.voicePackData:getVoiceCfgList()
  self.gvVoicePack:setData(cfgs)
end

function WinVoice_pack:onHide()
  UI:closeWnd("voice_pack")
end

function WinVoice_pack:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("voice_pack")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinVoice_pack:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinVoice_pack:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinVoice_pack
