local widget_base = require("ui.widget.widget_base")
local WidgetPlayerItem1 = Lib.derive(widget_base)

function WidgetPlayerItem1:init()
  widget_base.init(self, "PlayerItem1.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPlayerItem1:initUI()
  self.imgBg = self:child("PlayerItem1-Bg")
  self.imgIcon = self:child("PlayerItem1-Icon")
end

function WidgetPlayerItem1:initEvent()
end

function WidgetPlayerItem1:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetPlayerItem1:reload(userId)
  self.imgIcon:SetImage(World.cfg.defaultAvatar or "set:default_icon.json image:header_icon")
  local cache = UserInfoCache.GetCache(userId)
  if cache and cache.picUrl and #cache.picUrl > 0 then
    self.imgIcon:SetImageUrl(cache.picUrl)
  else
    AsyncProcess.GetUserDetail(userId, function(data)
      if not data then
        return
      end
      if data.picUrl and #data.picUrl > 0 then
        self.imgIcon:SetImageUrl(data.picUrl)
      else
        self.imgIcon:SetImage(World.cfg.defaultAvatar or "set:default_icon.json image:header_icon")
      end
    end)
  end
end

return WidgetPlayerItem1
