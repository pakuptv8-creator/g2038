local WinModMapAds = M
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WinModMapAds:init()
  WinBase.init(self, "ModMapAds.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.ModAds
  self.reqAdsKey = "ModMapAds_ads"
  ModAsyncProxy:regDelegateRequest(self.reqAdsKey, AsyncProcess.GetModImageUrlByType, Event.EVENT_MOD_RESPONSE_ADS_IMAGE)
end

function WinModMapAds:initUI()
  self.imgImage = self:child("ModMapAds-Image")
  self.btnClose = self:child("ModMapAds-Close")
end

function WinModMapAds:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.imgImage, UIEvent.EventWindowClick, function()
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.ModAds)
    Interface.onAppActionTrigger(24)
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_ADS_IMAGE, function(data)
    self:onResponseAdsImage(data)
  end)
end

function WinModMapAds:subscribeEvent()
end

function WinModMapAds:initView()
end

function WinModMapAds:onHide()
  UI:closeWnd("modMapAds")
end

function WinModMapAds:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("modMapAds")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinModMapAds:onOpen()
  if World.cfg.openCraft == false then
    self:onHide()
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.common.not_release"))
  end
  ModReportProxy:openUIReport(self.reportName)
  self:initView()
  self:subscribeEvent()
  self:tryRequestAdsImage()
end

function WinModMapAds:tryRequestAdsImage()
  if self.hasInitAdsImage then
    return
  end
  ModAsyncProxy:request(self.reqAdsKey, Define.Mod.ImageUrlTypeKey.ADS)
end

function WinModMapAds:onResponseAdsImage(data)
  if self.hasInitAdsImage then
    return
  end
  local picUrl = data or ""
  self.imgImage:SetImageUrl(picUrl)
  self.hasInitAdsImage = true
end

function WinModMapAds:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModReportProxy:closeUIReport(self.reportName)
end

return WinModMapAds
