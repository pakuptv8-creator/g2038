local widget_base = require("ui.widget.widget_base")
local WidgetAnnouncementItem = Lib.derive(widget_base)

function WidgetAnnouncementItem:init()
  widget_base.init(self, "AnnouncementItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetAnnouncementItem:initUI()
  self.lytContentPanel = self:child("AnnouncementItem-contentPanel")
  self.imgBg = self:child("AnnouncementItem-Bg")
  self.imgContentIcon = self:child("AnnouncementItem-ContentIcon")
  self.imgTagIcon = self:child("AnnouncementItem-TagIcon")
  self.txtTagText = self:child("AnnouncementItem-TagText")
  self.txtDescText = self:child("AnnouncementItem-DescText")
  self.btnGotoBtn = self:child("AnnouncementItem-GotoBtn")
  self.txtGotoText = self:child("AnnouncementItem-GotoText")
  self.txtTitleText = self:child("AnnouncementItem-TitleText")
  self.txtGotoText:SetText(Lang:toText("g2052.gui.tendering.sign.go_land"))
  self.contentSpacing = 0
  self.txtDescText:SetTextLineExtraSpace(self.contentSpacing)
end

local function firstToLower(str)
  return (str:gsub("^%u", string.lower))
end

function WidgetAnnouncementItem:initEvent()
  self:subscribe(self.btnGotoBtn, UIEvent.EventButtonClick, function()
    if self.data.uiName ~= "" then
      UI:openWnd(firstToLower(self.data.uiName))
      UI:closeWnd("announcementSlide")
    elseif self.data.mapPos ~= "" then
      local mapInfo = Lib.splitString(self.data.mapPos, "#")
      local params = {
        map = mapInfo[1] or World.cfg.defaultMap,
        pos = Lib.v3(tonumber(mapInfo[2] or 0), tonumber(mapInfo[3] or 0), tonumber(mapInfo[4] or 0))
      }
      Me:sendPacket({
        pid = "clientInitiatesTransfer",
        params = params
      })
      UI:closeWnd("announcementSlide")
    end
  end)
end

function WidgetAnnouncementItem:initAnnouncementItemData(data)
  self.data = data
  if data.title ~= "" then
    self.txtTitleText:SetText(Lang:toText(data.title))
    self.txtTitleText:SetVisible(true)
  else
    self.txtTitleText:SetVisible(false)
  end
  if data.desc ~= "" then
    self.txtDescText:SetText(Lang:toText(data.desc))
    self.txtDescText:SetVisible(true)
  else
    self.txtDescText:SetVisible(false)
  end
  self.imgContentIcon:SetImage(data.icon)
  if data.tagType == 1 then
    self.txtTagText:SetText(Lang:toText("g2052.gui.announcement.activity"))
    self.imgTagIcon:SetVisible(true)
    self.imgTagIcon:SetImage("set:g2052_announcement.json image:img_0_announcement01")
  elseif data.tagType == 2 then
    self.txtTagText:SetText(Lang:toText("g2052.gui.announcement.new"))
    self.imgTagIcon:SetVisible(true)
    self.imgTagIcon:SetImage("set:g2052_announcement.json image:img_0_announcement02")
  else
    self.imgTagIcon:SetVisible(false)
  end
  if data.mapPos ~= "" or data.uiName ~= "" then
    self.btnGotoBtn:SetVisible(true)
  else
    self.btnGotoBtn:SetVisible(false)
  end
  self:autoItemSize()
end

function WidgetAnnouncementItem:autoItemSize()
  local itemHeight = 377
  if self.txtDescText:IsVisible() then
    local msg = Lang:toText(self.data.desc)
    local onlineHeight = 27
    local strW = self.txtDescText:GetFont():GetStringWidth(msg)
    local uiW = self.txtDescText:GetWidth()[2]
    local descHeight = 0
    if strW > uiW then
      local offsetLine = math.ceil(strW / uiW)
      local curHeight = onlineHeight + (offsetLine - 1) * (onlineHeight + self.contentSpacing)
      descHeight = curHeight
    else
      descHeight = onlineHeight
    end
    itemHeight = itemHeight + descHeight + 12
    local nStrFun = string.gmatch(msg, "\n")
    local nNum = 0
    for key in nStrFun, nil, nil do
      nNum = nNum + 1
    end
    itemHeight = itemHeight + nNum * onlineHeight
  end
  if self.btnGotoBtn:IsVisible() then
    itemHeight = itemHeight + 46 + 5
  end
  self._root:SetHeight({0, itemHeight})
end

function WidgetAnnouncementItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetAnnouncementItem
