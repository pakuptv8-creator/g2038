local widget_base = require("ui.widget.widget_base")
local WidgetModMapInfoDiscuss = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModDiscussBase = Lib.class("ModDiscussBase")

function ModDiscussBase:ctor(params)
  self:init(params)
end

function ModDiscussBase:reset()
  self.pageNo = -1
  self.totalPage = 0
  self.isLastPage = false
  self.itemData = {}
  self.fakeData = {}
end

function ModDiscussBase:init(params)
  self.req = params.req
  self.view = params.view
  self.reqKey = params.reqKey
  self.event = params.event
  self.pageSize = Define.ModCommentItemOnceNum
  self.clUnRegEvent = Lib.subscribeEvent(self.event, function(data)
    self:onResponse(data)
  end)
  ModAsyncProxy:regDelegateRequest(self.reqKey, self.req, self.event)
  self:reset()
end

function ModDiscussBase:release()
  if self.clUnRegEvent then
    self.clUnRegEvent()
    self.clUnRegEvent = nil
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqKey)
end

function ModDiscussBase:reloadDiscuss()
  self:reset()
  self.view:clear()
  self:nextPage()
end

function ModDiscussBase:setMapData(mapData)
  self.mapData = mapData
end

function ModDiscussBase:nextPage()
  if not self.mapData then
    return
  end
  ModAsyncProxy:request(self.reqKey, self.mapData.gameId, self.pageNo + 1, self.pageSize)
end

function ModDiscussBase:onResponse(data)
  self.respData = data
  self.pageNo = data.pageNo
  self.totalPage = data.totalPage
  self:addItems(self:adpData(data.data or {}))
end

function ModDiscussBase:adpData(data)
  return data
end

function ModDiscussBase:addItems(data)
  for _, v in pairs(data) do
    table.insert(self.itemData, v)
  end
  self.view:addDiscussItemBatch(data)
end

function ModDiscussBase:onMeAddDiscuss(params)
  self:reloadDiscuss()
end

local ModDiscussComment = Lib.class("ModDiscussComment", ModDiscussBase)

function ModDiscussComment:reloadDiscuss()
  self:reset()
  self.view:clear()
  self:requestTopComment()
end

function ModDiscussComment:requestTopComment()
  if not self.mapData then
    return
  end
  if not self.reqTopCommentKey then
    self.reqTopCommentKey = "DiscussComment_TopComment"
    self.clUnRegTopCommentEvent = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_TOP_COMMENT, function(data)
      self:onResponseTopComment(data)
    end)
    ModAsyncProxy:regDelegateRequest(self.reqTopCommentKey, AsyncProcess.GetModTopComment, Event.EVENT_MOD_RESPONSE_TOP_COMMENT)
  end
  ModAsyncProxy:request(self.reqTopCommentKey, self.mapData.gameId)
end

function ModDiscussComment:onResponseTopComment(data)
  self.topCommentData = data
  self:addItems(self:adpData(data or {}))
  self:nextPage()
end

function ModDiscussComment:release()
  ModDiscussBase.release(self)
  if self.clUnRegTopCommentEvent then
    self.clUnRegTopCommentEvent()
    self.clUnRegTopCommentEvent = nil
  end
end

local ModDiscussLike = Lib.class("ModDiscussLike", ModDiscussBase)
local ModDiscussExperience = Lib.class("ModDiscussExperience", ModDiscussBase)
local ModDiscussFact = {
  cfg = {
    [1] = {
      class = ModDiscussComment,
      req = AsyncProcess.GetModCommentList,
      reqKey = "Discuss_GetModComment",
      event = Event.EVENT_MOD_RESPONSE_DISCUSS_COMMENT
    },
    [2] = {
      class = ModDiscussLike,
      req = AsyncProcess.GetModLikeList,
      reqKey = "Discuss_GetModLike",
      event = Event.EVENT_MOD_RESPONSE_DISCUSS_LIKE
    },
    [3] = {
      class = ModDiscussExperience,
      req = AsyncProcess.GetModPlayList,
      reqKey = "Discuss_GetModPlay",
      event = Event.EVENT_MOD_RESPONSE_DISCUSS_EXPERIENCE
    }
  },
  getDiscussLogic = function(self, typ, params)
    local config = self.cfg[typ]
    for k, v in pairs(config) do
      if k ~= "class" then
        params[k] = v
      end
    end
    return config.class.new(params)
  end
}

function WidgetModMapInfoDiscuss:init()
  widget_base.init(self, "ModMapInfoDiscuss.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMapInfoDiscuss:initUI()
  self.imgBg = self:child("ModMapInfoDiscuss-Bg")
  self.lytContent = self:child("ModMapInfoDiscuss-Content")
  self.gvDiscuss = UIMgr:new_widget("grid_view")
  self.gvDiscuss:SetMoveAble(true)
  self.gvDiscuss:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytContent:AddChildWindow(self.gvDiscuss)
  self.gvDiscuss:InitConfig(0, 0, 1)
end

function WidgetModMapInfoDiscuss:initEvent()
  self:subscribe(self.gvDiscuss, UIEvent.EventScrollMoveChange, function()
    local offset = self.gvDiscuss:GetScrollOffset()
    local minOffset = self.gvDiscuss:GetMinScrollOffset()
    if offset < minOffset then
      self.logic:nextPage()
    end
  end)
end

function WidgetModMapInfoDiscuss:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.logic then
    self.logic:release()
  end
end

function WidgetModMapInfoDiscuss:onMeAddDiscuss()
  if not self.logic then
    return
  end
  self.logic:onMeAddDiscuss()
end

function WidgetModMapInfoDiscuss:reload(data, type)
  self.discussType = type
  self.data = data
  if not self.data or not self.discussType then
    return
  end
  if not self.logic then
    self.logic = ModDiscussFact:getDiscussLogic(type, {view = self})
  end
  self.logic:setMapData(data)
  self.logic:reloadDiscuss()
end

function WidgetModMapInfoDiscuss:updateAllDiscuss()
  if not self.logic then
    return
  end
  self.logic:reloadDiscuss()
end

function WidgetModMapInfoDiscuss:nextPage()
  if not self.logic then
    return
  end
  self.logic:nextPage()
end

function WidgetModMapInfoDiscuss:addDiscussItemBatch(data)
  for _, v in pairs(data or {}) do
    self:addDiscussItem(v)
  end
end

function WidgetModMapInfoDiscuss:addDiscussItem(info)
  local data = info
  if not self.discussItems then
    self.discussItems = {}
  end
  local widget = UIMgr:new_widget("modMapInfoDiscussItem")
  widget:invoke("reload", data)
  self.gvDiscuss:AddItem(widget)
  local top = #self.discussItems + 1
  self.discussItems[top] = widget
end

function WidgetModMapInfoDiscuss:clear()
  self.gvDiscuss:RemoveAllItems()
  self.discussItems = {}
  self.gvDiscuss:ResetPos()
  Lib.log("------------WidgetModMapInfoDiscuss:clear")
end

function WidgetModMapInfoDiscuss:release()
  self:clear()
end

return WidgetModMapInfoDiscuss
