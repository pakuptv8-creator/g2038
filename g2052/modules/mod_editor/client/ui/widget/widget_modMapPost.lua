local widget_base = require("ui.widget.widget_base")
local WidgetModMapPost = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")
local DiscussTab = {
  [1] = {
    lang = "g2052.gui.mod_discuss.tab.discuss",
    widget = "modMapInfoDiscuss",
    reportKey = World.cfg.modUIInfo.modBtnNameMappings.ModDiscussTab,
    number = 1
  },
  [2] = {
    lang = "g2052.gui.mod_discuss.tab.like",
    widget = "modMapInfoDiscuss",
    reportKey = World.cfg.modUIInfo.modBtnNameMappings.ModLikeTab,
    number = 1
  },
  [3] = {
    lang = "g2052.gui.mod_discuss.tab.explore",
    widget = "modMapInfoDiscuss",
    reportKey = World.cfg.modUIInfo.modBtnNameMappings.ModExperienceTab,
    number = 1
  }
}
local CurDiscussTabIndex = 1
local DefaultDiscussTabIndex = 1

function WidgetModMapPost:init()
  widget_base.init(self, "ModMapPost.json")
  self:initUI()
  self._allEvent = {}
  self:initEvent()
  self.reqRelayKey = "ModMapPost_Relay"
  ModAsyncProxy:regDelegateRequest(self.reqRelayKey, AsyncProcess.AddModMapRelay, Event.EVENT_MOD_RESPONSE_MAP_ADD_RELAY)
end

function WidgetModMapPost:initUI()
  self.imgBg = self:child("ModMapPost-Bg")
  self.lytT = self:child("ModMapPost-T")
  self.lytAuthorHead = self:child("ModMapPost-Author-Head")
  self.lytAuthorHeadWidget = UIMgr:new_widget("modUserHead")
  self.lytAuthorHead:AddChildWindow(self.lytAuthorHeadWidget)
  self.lytAuthorHeadWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.txtIssueTime = self:child("ModMapPost-Issue-Time")
  self.txtAuthorName = self:child("ModMapPost-Author-Name")
  self.btnFollow = self:child("ModMapPost-Follow")
  self.lytM = self:child("ModMapPost-M")
  self.imgMBg = self:child("ModMapPost-M-Bg")
  self.lytB = self:child("ModMapPost-B")
  self.lytDiscussTabs = self:child("ModMapPost-Discuss-Tabs")
  self.lytDiscuss = self:child("ModMapPost-Discuss")
  self.lytAuthorWords = self:child("ModMapPost-Author-Words")
  self.gvAuthorWords = UIMgr:new_widget("grid_view")
  self.lytAuthorWords:AddChildWindow(self.gvAuthorWords)
  self.gvAuthorWords:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.authorWordsWidget = UIMgr:new_widget("modMapPostAuthorWords")
  self.gvAuthorWords:AddItem(self.authorWordsWidget)
  self:initDiscussTabs()
  self.lytRelay = self:child("ModMapPost-Relay")
  self.relayWidget = UIMgr:new_widget("modMapDiscussRelay")
  self.lytRelay:AddChildWindow(self.relayWidget)
  self.relayWidget:invoke("reload", function(input)
    self:onInputConfirm(input)
  end)
  self.relayWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WidgetModMapPost:onInputConfirm(input)
  Lib.logDebug("--onInputConfirm : " .. input)
  local gameId = self.data.gameId
  ModAsyncProxy:request(self.reqRelayKey, gameId, input)
  self.relayWidget:invoke("clear")
end

function WidgetModMapPost:initDiscussTabs()
  self.discussTabList = {}
  for index, info in pairs(DiscussTab) do
    local widgetName = info.widget
    local widget = UIMgr:new_widget(widgetName)
    widget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    self.lytDiscuss:AddChildWindow(widget)
    widget:SetVisible(false)
    self.discussTabList[index] = widget
  end
  self.gvDiscussTab = GridViewHelper.new({
    name = "gvDiscussTab",
    xCellNum = 3,
    yDis = 0,
    xDis = 2,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    widgetWidth = 229,
    widgetHeight = 42,
    widgetJson = "ModMapInfoDiscussTabItem.json",
    widgetName = "modMapInfoDiscussTabItem",
    gvParent = self.lytDiscussTabs,
    cellSelectedCb = function(data, dx, dy, index)
      self:onDiscussTabBtnClick(index)
    end
  })
  self.gvDiscussTab:setData(DiscussTab, 1, nil, true)
  self.gvDiscussTabContent = self.gvDiscussTab:getGridView()
end

function WidgetModMapPost:initEvent()
  self:subscribe(self.btnFollow, UIEvent.EventButtonClick, function()
    if not self.curFollowStatus then
      ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.ModFollow)
      Me:addModFocusOnPlayer(self.data.authorInfo.teamId)
    else
      ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.ModFollowCancel)
      Me:removeModFocusOnPlayer(self.data.authorInfo.teamId)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, function(targetId, followStatus)
    if self.data.authorInfo.teamId ~= targetId then
      return
    end
    if followStatus == 1 or followStatus == 3 then
      self:updateFollowBtnShow(targetId, true)
    else
      self:updateFollowBtnShow(targetId, false)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_ADD_RELAY, function(data)
    self.discussTabList[Define.DiscussDefine.Discuss]:invoke("onMeAddDiscuss")
    self.data.discussNumber = self.data.discussNumber + 1
    self:updateDiscussTabTitle()
    ModReportProxy:relaySuccessReport()
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_ADD_EXPERIENCE, function(data)
    if data.gameId and data.gameId == self.data.gameId then
      local exNum = data.gameExperienceNumber
      self.data.experience = exNum
      self:updateDiscussTabTitle()
    end
  end)
end

function WidgetModMapPost:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqRelayKey)
end

function WidgetModMapPost:onDiscussTabBtnClick(index)
  self:switchTabUI(index)
end

function WidgetModMapPost:switchTabUI(index)
  if not index then
    return
  end
  if CurDiscussTabIndex then
    self.discussTabList[CurDiscussTabIndex]:SetVisible(false)
  end
  self.discussTabList[index]:SetVisible(true)
  self.discussTabList[index]:invoke("reload", self.data, index)
  CurDiscussTabIndex = index
end

function WidgetModMapPost:onModLikeChanged()
  self:updateDiscussTabTitle()
  if CurDiscussTabIndex ~= Define.DiscussDefine.Like then
    return
  end
  self.discussTabList[Define.DiscussDefine.Like]:invoke("onMeAddDiscuss")
end

function WidgetModMapPost:updateDiscussTabTitle()
  DiscussTab[1].number = self.data.discussNumber or 0
  DiscussTab[2].number = self.data.likeNumber or 0
  DiscussTab[3].number = self.data.experienceNumber or 0
  for i = 0, 2 do
    local item = self.gvDiscussTabContent:GetItem(i)
    if item then
      item:invoke("updateNumber", DiscussTab[i + 1].number)
    end
  end
end

function WidgetModMapPost:reloadDiscussTab()
  self:updateDiscussTabTitle()
  self.gvDiscussTab:setData(DiscussTab, -1, nil, true)
end

function WidgetModMapPost:reload(data)
  if not data then
    return
  end
  self.data = data
  self:reloadDiscussTab()
  self.gvDiscussTab:setClickByOrder(DefaultDiscussTabIndex)
  local authorId = self.data.authorId
  local authorInfo = self.data.authorInfo
  local gameName = self.data.gameName
  local gameDetail = self.data.gameDetail
  local createTime = self.data.createTime / 1000
  local gameDetailOtherInfo = self.data.gameDetailOtherInfo
  self.txtAuthorName:SetText(authorInfo.nickName or "")
  self.lytAuthorHeadWidget:invoke("reload", {authorId = authorId})
  self.authorWordsWidget:invoke("reload", {gameDetail = gameDetail, WordsInfo = gameDetailOtherInfo})
  local createTimeParse = os.date("%H:%M %y/%m/%d", createTime)
  self.txtIssueTime:SetText(createTimeParse .. "  update")
  self.lytAuthorHeadWidget:invoke("reload", {authorId = authorId})
  self.curFollowStatus = false
  Me:isMyModFocusOnPlayer(authorInfo.teamId)
end

function WidgetModMapPost:getUserId()
  if not self.data then
    return Me.platformUserId
  end
  local authorData = self.data.authorInfo
  local isPersonal = authorData.isTeam == Define.Mod.TeamType.User
  local userIdListEle_1 = authorData.userIdList and authorData.userIdList[1]
  if isPersonal then
    return authorData.userId or userIdListEle_1
  else
    return userIdListEle_1 or authorData.userId
  end
end

function WidgetModMapPost:updateFollowBtnShow(targetId, followStatus)
  if targetId ~= self.data.authorInfo.teamId then
    self:setFollowBtnEnable(false)
    return
  end
  if followStatus then
    self.btnFollow:SetText(Lang:toText("g2052.gui.mod_follow.remove"))
  else
    self.btnFollow:SetText(Lang:toText("g2052.gui.mod_follow.add"))
  end
  self.curFollowStatus = followStatus
  local userId = self:getUserId()
  local isMe = userId == Me.platformUserId
  self:setFollowBtnEnable(not isMe)
end

local FollowEnableImage = "set:g2052_mod.json image:btn_9_friend02"
local FollowUnEnableImage = "set:g2052_mod.json image:btn_9_friend03"

function WidgetModMapPost:setFollowBtnEnable(enable)
  self.btnFollow:SetEnabled(enable)
  local img = enable and FollowEnableImage or FollowUnEnableImage
  self.btnFollow:SetNormalImage(img)
  self.btnFollow:SetPushedImage(img)
end

function WidgetModMapPost:release()
  self.authorWordsWidget:invoke("release")
  for _, widget in pairs(self.discussTabList) do
    widget:invoke("release")
  end
  Lib.log("------------WidgetModMapPost:release")
end

return WidgetModMapPost
