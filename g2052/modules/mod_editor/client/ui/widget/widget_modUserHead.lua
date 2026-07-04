local widget_base = require("ui.widget.widget_base")
local WidgetModUserHead = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModUserHead:init()
  widget_base.init(self, "ModUserHead.json")
  self:initUI()
  self:initEvent()
  self.valid = true
end

function WidgetModUserHead:initUI()
  self.imgIcon = self:child("ModUserHead-Icon")
  self.imgFrame = self:child("ModUserHead-Frame")
end

function WidgetModUserHead:initEvent()
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetModUserHead:onDestroy()
  self.valid = false
end

function WidgetModUserHead:reload(params)
  self.data = params
  if params.iconPath then
    self.imgIcon:SetImage(params.headPath)
  elseif params.headUrl then
    self.imgIcon:SetImageUrl(params.headUrl)
  elseif params.userId or params.authorId then
    AsyncProcess.GetAuthorInfo(function(resp, isSuccess)
      if not self.valid then
        return
      end
      if not isSuccess then
        print("WidgetModUserHead GetAuthorInfo Error: ", resp.code)
        return
      end
      if not resp or not resp.data then
        return
      end
      local data = resp.data
      if data.headPic and #data.headPic > 0 then
        self.imgIcon:SetImageUrl(data.headPic)
      end
    end, params.userId, params.authorId)
  end
  if not params.forbidJumpUI and (params.userId or params.authorId) then
    function self.fun()
      ModAsyncProxy:requestOpenAuthorInfoUI(params.userId, params.authorId)
    end
  end
  if params.cb then
    self.fun = params.cb
  end
end

return WidgetModUserHead
