local WinModMapInfo = M
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WinModMapInfo:init()
  WinBase.init(self, "ModMapInfo.json")
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.ModDetail
  self.reqMapLikeKey = "ModMapInfo_Like"
  ModAsyncProxy:regDelegateRequest(self.reqMapLikeKey, AsyncProcess.SetModLike, Event.EVENT_MOD_RESPONSE_MAP_LIKE)
  self.reqAddExperienceKey = "ModMapInfo_AddExperience"
  ModAsyncProxy:regDelegateRequest(self.reqAddExperienceKey, AsyncProcess.AddModExperience, Event.EVENT_MOD_RESPONSE_ADD_EXPERIENCE)
  self:initEvent()
end

function WinModMapInfo:initUI()
  self.imgBg = self:child("ModMapInfo-Bg")
  self.lytL = self:child("ModMapInfo-L")
  self.lytMap = self:child("ModMapInfo-Map")
  self.txtMapName = self:child("ModMapInfo-Map-Name")
  self.btnMapReport = self:child("ModMapInfo-Map-Report")
  self.imgMapOverview = self:child("ModMapInfo-Map-Overview")
  self.lytMapEntrance = self:child("ModMapInfo-Map-Entrance")
  self.btnMapEntranceBtn = self:child("ModMapInfo-Map-Entrance-Btn")
  self.btnMapEntranceBtn:SetText(Lang:toText("g2052.gui.mod_map.play"))
  self.lytR = self:child("ModMapInfo-R")
  self.btnClose = self:child("ModMapInfo-Close")
  self.imgLike = self:child("ModMapInfo-Like-Icon")
  self.txtLike = self:child("ModMapInfo-Like-Num")
  self.btnLike = self:child("ModMapInfo-Like-Btn")
  self.gvR = UIMgr:new_widget("grid_view")
  self.gvR:SetMoveAble(false)
  self.gvR:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytR:AddChildWindow(self.gvR)
  self.gvR:InitConfig(0, 0, 1)
  self.lytMapPost = UIMgr:new_widget("modMapPost")
  self.gvR:AddItem(self.lytMapPost)
  self.lytMapPost:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinModMapInfo:initEvent()
  self:subscribe(self.btnMapReport, UIEvent.EventButtonClick, function()
    UI:openWnd("modMapReport", self.data.gameId)
  end)
  self:subscribe(self.btnMapEntranceBtn, UIEvent.EventButtonClick, function()
    local localGameId = Lib.getGameId()
    print("----------local localGameId == " .. tostring(localGameId))
    print("----------gameId            == " .. tostring(self.data.gameId))
    if self.data.gameId == localGameId then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.mod_play_same"))
      return
    end
    local gameType = self.data.parentGameId .. "*" .. self.data.gameId
    ModAsyncProxy:request(self.reqAddExperienceKey, self.data.gameId)
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.ModPlay)
    CGame.instance:resetGameAddr(Me.platformUserId, gameType, "", "", "")
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnLike, UIEvent.EventButtonClick, function()
    local negation = (not self.data.userLikeType or self.data.userLikeType == 0) and 1 or 0
    local reportKey = negation == 1 and World.cfg.modUIInfo.modBtnNameMappings.ModLike or World.cfg.modUIInfo.modBtnNameMappings.ModLikeCancel
    ModReportProxy:btnClickReport(reportKey)
    ModAsyncProxy:request(self.reqMapLikeKey, self.data.gameId, negation == 1)
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_LIKE, function(data)
    if data.gameId and data.gameId == self.data.gameId then
      self.data.likeNumber = data.gameLikeNumber
      self.data.userLikeType = data.userLikeType
      self:updateLikeBtnStatus()
      self.lytMapPost:invoke("onModLikeChanged")
    end
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_ADD_EXPERIENCE, function(data)
    if not data.gameId or data.gameId == self.data.gameId then
    end
  end)
end

function WinModMapInfo:subscribeEvent()
end

function WinModMapInfo:initView()
  self.data.likeNumber = self.data.likeNumber or 0
  self.lytMapPost:invoke("reload", self.data)
  self.imgMapOverview:SetImageUrl(self.data.gameCoverPic)
  self.txtMapName:SetText(Lib.standardizeModTitle(self.data.gameName))
  self:updateLikeBtnStatus()
end

function WinModMapInfo:onHide()
  UI:closeWnd("modMapInfo")
end

function WinModMapInfo:onShow(isShow, data, from)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("modMapInfo", data, from)
    else
      self:reloadUI(data, from)
    end
  else
    self:onHide()
  end
end

function WinModMapInfo:onOpen(data, from)
  self:reloadUI(data, from)
  self._allEvent = {}
  self:subscribeEvent()
end

function WinModMapInfo:reloadUI(data, from)
  ModReportProxy:openUIReport(self.reportName)
  if from ~= nil then
    self.from = from
    ModReportProxy:mapDetailFromReport(from)
  end
  self.data = data
  if not self.data then
    self:onHide()
    return
  end
  self:initView()
end

function WinModMapInfo:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModReportProxy:closeUIReport(self.reportName)
  self.lytMapPost:invoke("release")
end

local LikeImg = "set:g2052_mod.json image:icon_0_like"
local UnlikeImg = "set:g2052_mod.json image:icon_0_like01"

function WinModMapInfo:updateLikeBtnStatus()
  local img = self.data.userLikeType == 1 and LikeImg or UnlikeImg
  self.txtLike:SetText(Lib.simplifyNumber2Str(self.data.likeNumber or 100))
  self.imgLike:SetImage(img)
end

return WinModMapInfo
