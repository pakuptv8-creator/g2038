local WinModAuthorInfo = M
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WinModAuthorInfo:init()
  WinBase.init(self, "ModAuthorInfo.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.ModAuthor
  self.reqAuthorMapKey = "AuthorInfo_AuthorMap"
  ModAsyncProxy:regDelegateRequest(self.reqAuthorMapKey, AsyncProcess.GetAuthorMods, Event.EVENT_MOD_RESPONSE_AUTHOR_MAPS)
  self:initEvent()
end

function WinModAuthorInfo:initUI()
  self.imgBg = self:child("ModAuthorInfo-Bg")
  self.imgBgTop = self:child("ModAuthorInfo-Bg-Top")
  self.imgBgTopLeft = self:child("ModAuthorInfo-Bg-Top-Left")
  self.imgLine1 = self:child("ModAuthorInfo-Line1")
  self.btnClose = self:child("ModAuthorInfo-Close")
  self.lytContent = self:child("ModAuthorInfo-Content")
  self.imgContentBg = self:child("ModAuthorInfo-Content-Bg")
  self.lytL = self:child("ModAuthorInfo-L")
  self.lytLT = self:child("ModAuthorInfo-L-T")
  self.lytAuthorHead = self:child("ModAuthorInfo-Author-Head")
  self.lytAuthorHeadWidget = UIMgr:new_widget("modUserHead")
  self.lytAuthorHead:AddChildWindow(self.lytAuthorHeadWidget)
  self.lytAuthorHeadWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.txtAuthorName = self:child("ModAuthorInfo-Author-Name")
  self.txtAuthorId = self:child("ModAuthorInfo-Author-Id")
  self.btnAuthorIdCopy = self:child("ModAuthorInfo-Author-Id-Copy")
  self.lytAuthorLike = self:child("ModAuthorInfo-Author-Like")
  self.imgAuthorLikeIcon = self:child("ModAuthorInfo-Author-Like-Icon")
  self.txtAuthorLikeNum = self:child("ModAuthorInfo-Author-Like-Num")
  self.lytAuthorFollow = self:child("ModAuthorInfo-Author-Follow")
  self.imgAuthorFollowIcon = self:child("ModAuthorInfo-Author-Follow-Icon")
  self.txtAuthorFollowNum = self:child("ModAuthorInfo-Author-Follow-Num")
  self.lytMedal = self:child("ModAuthorInfo-Medal")
  self.btnAddFriend = self:child("ModAuthorInfo-AddFriend")
  self.imgAddFriendIcon = self:child("ModAuthorInfo-AddFriend-Icon")
  self.btnFollowBtn = self:child("ModAuthorInfo-Follow-Btn")
  self.lytAuthorWords = self:child("ModAuthorInfo-Author-Words")
  self.imgAuthorWordsBg = self:child("ModAuthorInfo-Author-Words-Bg")
  self.txtAuthorWordsText = self:child("ModAuthorInfo-Author-Words-Text")
  self.lytR = self:child("ModAuthorInfo-R")
  self.lytRContent = self:child("ModAuthorInfo-R-Content")
  self.gvMap = GridViewHelper.new({
    name = "gvMap",
    xCellNum = 3,
    yDis = 26,
    xDis = 49,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = true,
    widgetWidth = 195,
    widgetHeight = 239,
    widgetJson = "ModAuthorMapItem.json",
    widgetName = "modAuthorMapItem",
    gvParent = self.lytRContent,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
  self.gvMapWidget = self.gvMap:getGridView()
  self.gvMedal = GridViewHelper.new({
    name = "gvMedal",
    xCellNum = 99,
    yDis = 0,
    xDis = 5,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    hScorllMoveAble = true,
    widgetWidth = 137,
    widgetHeight = 25,
    widgetJson = "ModAuthorMedalItem.json",
    widgetName = "modAuthorMedalItem",
    gvParent = self.lytMedal,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
end

function WinModAuthorInfo:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_AUTHOR_MAPS, function(data)
    self:onResponseAuthorMap(data)
  end)
  self:subscribe(self.btnAuthorIdCopy, UIEvent.EventButtonClick, function()
    local userId = self:getUserId()
    if not userId then
      return
    end
    Blockman.instance:onSetClipboard(tostring(userId))
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.guid.mod_userId_copy"))
  end)
  self:subscribe(self.btnAddFriend, UIEvent.EventButtonClick, function()
    if not self.data or not self.data.userId then
      return
    end
    if not self:canAddFriend(self.data.userId, self.isMeFriend) then
      return
    end
    if self.lastOperatorFriendStamp and self.lastOperatorFriendStamp + 1 > os.time() then
      return
    end
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.AuthorAddFriend)
    self.lastOperatorFriendStamp = os.time()
    local operator = FriendManager.operationType.ADD_FRIEND
    AsyncProcess.FriendOperation(operator, self.data.userId)
  end)
  self:subscribe(self.btnFollowBtn, UIEvent.EventButtonClick, function()
    if self.lastOperatorFollowStamp and self.lastOperatorFollowStamp + 1 > os.time() then
      return
    end
    self.lastOperatorFollowStamp = os.time()
    if not self.curFollowStatus then
      ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.AuthorFollow)
      Me:addModFocusOnPlayer(self.data.teamId)
    else
      ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.AuthorFollowCancel)
      Me:removeModFocusOnPlayer(self.data.teamId)
    end
  end)
  self:subscribe(self.gvMapWidget, UIEvent.EventScrollMoveChange, function()
    local offset = self.gvMapWidget:GetScrollOffset()
    local minOffset = self.gvMapWidget:GetMinScrollOffset()
    if offset < minOffset then
      self:NextMapPage()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, function(targetId, followStatus)
    if targetId ~= self.data.teamId then
      return
    end
    if followStatus == 1 or followStatus == 3 then
      self:deltaFanNum(1)
      self:updateFollowBtnShow(targetId, true)
    else
      self:deltaFanNum(-1)
      self:updateFollowBtnShow(targetId, false)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_FRIEND_OPERATION_CLIENT, function(opType, userId)
    if not self.data or not self.data.userId then
      return
    end
    if userId ~= self.data.userId then
      return
    end
    self:updateFriendBtnShow(userId, opType == FriendManager.operationType.ADD_FRIEND)
  end)
end

function WinModAuthorInfo:updateFollowBtnShow(targetId, followStatus)
  if not self.data then
    return
  end
  if followStatus then
    self.btnFollowBtn:SetText(Lang:toText("g2052.gui.mod_follow.remove"))
  else
    self.btnFollowBtn:SetText(Lang:toText("g2052.gui.mod_follow.add"))
  end
  self.curFollowStatus = followStatus
  local userId = self:getUserId()
  local isMe = userId == Me.platformUserId
  self:setFollowBtnEnable(not isMe)
end

local FollowEnableImage = "set:g2052_mod.json image:btn_9_friend02"
local FollowUnEnableImage = "set:g2052_mod.json image:btn_9_friend03"

function WinModAuthorInfo:setFollowBtnEnable(enable)
  self.btnFollowBtn:SetEnabled(enable)
  local img = enable and FollowEnableImage or FollowUnEnableImage
  self.btnFollowBtn:SetNormalImage(img)
  self.btnFollowBtn:SetPushedImage(img)
end

function WinModAuthorInfo:canAddFriend(userId, isMeFriend)
  if isMeFriend then
    return false
  end
  if not self.data then
    return false
  end
  if self.data.isTeam ~= Define.Mod.TeamType.User then
    return false
  end
  local userID = self:getUserId()
  if Me.platformUserId == userID then
    return false
  end
  if self.data.isAddFriend ~= 1 then
    return false
  end
  return true
end

function WinModAuthorInfo:updateFriendBtnShow(userId, friendStatus)
  if not self.data then
    return
  end
  if userId ~= self.data.userId then
    return
  end
  self.isMeFriend = friendStatus
  if not self:canAddFriend(userId, friendStatus) then
    self.btnAddFriend:SetEnabled(false)
    return
  end
  self.btnAddFriend:SetEnabled(true)
end

function WinModAuthorInfo:subscribeEvent()
end

function WinModAuthorInfo:getUserId()
  if not self.data then
    return Me.platformUserId
  end
  local isPersonal = self.data.isTeam == Define.Mod.TeamType.User
  local userIdListEle_1 = self.data.userIdList and self.data.userIdList[1]
  if isPersonal then
    return self.data.userId or userIdListEle_1
  else
    return userIdListEle_1 or self.data.userId
  end
end

function WinModAuthorInfo:requestAuthorMaps(pageNo)
  local teamId = self.data.teamId
  local pageNo = pageNo or self.mapPageNo + 1
  local pageSize = Define.ModMapOnceNum
  ModAsyncProxy:request(self.reqAuthorMapKey, teamId, pageNo, pageSize)
end

function WinModAuthorInfo:onResponseAuthorMap(data)
  self.mapPageNo = data.pageNo
  for _, v in pairs(data.data or {}) do
    Lib.attachModItemInfo(v, World.cfg.modUIInfo.modItemFromPathMappings.ModAuthor)
    table.insert(self.mapData, v)
  end
  self.gvMap:setData(self.mapData, -1, nil, true)
end

function WinModAuthorInfo:initView()
  if not self.data then
    return
  end
  local data = self.data
  local userId = self:getUserId()
  self.txtAuthorId:SetText(userId or "")
  self.lytAuthorHeadWidget:invoke("reload", {
    headUrl = data.headPic
  })
  self.txtAuthorName:SetText(data.nickName or "")
  self.txtAuthorLikeNum:SetText(data.likeNumber or "")
  self.txtAuthorFollowNum:SetText(data.fanNumber or "")
  self.txtAuthorWordsText:SetText(data.details or "")
  self:updateFollowBtnShow(data.teamId, data.followStatus == Define.Mod.FollowType.Follow or data.followStatus == Define.Mod.FollowType.FollowEachOther)
  self:updateFriendBtnShow(data.userId, data.isTeam ~= Define.Mod.TeamType.User)
  self:reloadMapInfo()
end

function WinModAuthorInfo:deltaFanNum(n)
  self.data.fanNumber = self.data.fanNumber + n
  self.txtAuthorFollowNum:SetText(self.data.fanNumber or "")
end

function WinModAuthorInfo:reloadMapInfo()
  self.mapPageNo = -1
  self.mapData = {}
  if not self.data then
    return
  end
  local id = self.data.teamId
  self:requestAuthorMaps()
end

function WinModAuthorInfo:NextMapPage()
  self:requestAuthorMaps()
end

function WinModAuthorInfo:onHide()
  UI:closeWnd("modAuthorInfo")
end

function WinModAuthorInfo:onShow(isShow, data)
  if not data then
    return
  end
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("modAuthorInfo", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinModAuthorInfo:onOpen(data)
  self.data = data
  self:initView()
  self:subscribeEvent()
  ModReportProxy:openUIReport(self.reportName)
end

function WinModAuthorInfo:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModReportProxy:closeUIReport(self.reportName)
end

return WinModAuthorInfo
