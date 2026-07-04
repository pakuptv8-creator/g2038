local widget_base = require("ui.widget.widget_base")
local WidgetModMapInfoDiscussItem = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ReqSetCommentLikeKey = "ModMapInfoDiscussItem_SetCommentLike"
ModAsyncProxy:regDelegateRequest(ReqSetCommentLikeKey, AsyncProcess.SetModCommentLike, Event.EVENT_MOD_RESPONSE_COMMENT_LIKE)

function WidgetModMapInfoDiscussItem:init()
  widget_base.init(self, "ModMapInfoDiscussItem.json")
  self:initUI()
  self._allEvent = {}
  self:initEvent()
end

function WidgetModMapInfoDiscussItem:initUI()
  self.imgBg = self:child("ModMapInfoDiscussItem-Bg")
  self.lytHead = self:child("ModMapInfoDiscussItem-Head")
  self.headWidget = UIMgr:new_widget("modUserHead")
  self.lytHead:AddChildWindow(self.headWidget)
  self.headWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.txtName = self:child("ModMapInfoDiscussItem-Name")
  self.txtWords = self:child("ModMapInfoDiscussItem-Words")
  self.txtTime = self:child("ModMapInfoDiscussItem-Time")
  self.lytLike = self:child("ModMapInfoDiscussItem-Like")
  self.btnLike = self:child("ModMapInfoDiscussItem-Like-Btn")
  self.txtLikeNum = self:child("ModMapInfoDiscussItem-Like-Num")
  self.lytContent = self:child("ModMapInfoDiscussItem-Content")
  self.standardWidth = self.txtWords:GetWidth()[2]
  self.standardHigh = self.txtWords:GetFont():GetFontHeight()
  self.oriWordsHigh = self.txtWords:GetHeight()[2]
  self.oriRootHigh = self:root():GetHeight()[2]
end

function WidgetModMapInfoDiscussItem:initEvent()
  self:subscribe(self.btnLike, UIEvent.EventButtonClick, function()
    self:reqSetCommentLike()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_COMMENT_LIKE, function(data)
    self:onResponseSetCommentLike(data)
  end)
end

function WidgetModMapInfoDiscussItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetModMapInfoDiscussItem:reqSetCommentLike()
  local negation = self.data.userCommentLike == 0 and 1 or 0
  ModAsyncProxy:request(ReqSetCommentLikeKey, self.data.gameId, self.data.id, negation == 1)
end

function WidgetModMapInfoDiscussItem:onResponseSetCommentLike(data)
  if not data.commentId or data.commentId ~= self.data.id then
    return
  end
  self.data.likeNumber = data.commentLikeNumber
  self.data.userCommentLike = data.userLikeType
  self:updateLikeBtnStatus()
end

function WidgetModMapInfoDiscussItem:reload(data)
  self.data = data
  if not self.data then
    return
  end
  local standardWidth = self.standardWidth
  local standardHigh = self.standardHigh
  local str = data.content or ""
  local userId = data.userId
  local nickName = data.nickName
  local lineNum = Lib.getTextLineNum(str, self.txtWords, standardWidth)
  if 1 < lineNum then
    local extraLine = lineNum - 1
    local extraHigh = extraLine * standardHigh
    local oriWordsHigh = self.oriWordsHigh
    self.txtWords:SetHeight({
      0,
      oriWordsHigh + extraHigh
    })
    local oriRootHigh = self.oriRootHigh
    self:root():SetHeight({
      0,
      oriRootHigh + extraHigh
    })
  end
  self.txtWords:SetText(str)
  self.txtWords:SetVisible(str ~= "")
  self.txtName:SetText(nickName)
  self:updateLikeBtnStatus()
  self.headWidget:invoke("reload", {userId = userId})
end

local LikeImg = "set:g2052_mod.json image:icon_0_like"
local UnlikeImg = "set:g2052_mod.json image:icon_0_like01"

function WidgetModMapInfoDiscussItem:updateLikeBtnStatus()
  self.lytLike:SetVisible(self.data.userCommentLike ~= nil)
  local img = self.data.userCommentLike == 1 and LikeImg or UnlikeImg
  self.txtLikeNum:SetText(Lib.simplifyNumber2Str(self.data.likeNumber or 0))
  self.btnLike:SetPushedImage(img)
  self.btnLike:SetNormalImage(img)
end

return WidgetModMapInfoDiscussItem
