local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local setting = require("common.setting")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")

function M:init()
  widget_base.init(self, "pokemon_task_cell.json")
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.data = nil
  self.status = nil
end

function M:initWnd()
  self.stBackBg = self:child("pokemon_task_cell-back-bg")
  self.stFrontBg = self:child("pokemon_task_cell-front-bg")
  self.ltItem = self:child("pokemon_task_cell-item-layout")
  self.stItemBg = self:child("pokemon_task_cell-item-bg")
  self.siItemIcon = self:child("pokemon_task_cell-item-icon")
  self.stItemCount = self:child("pokemon_task_cell-item-count")
  self.siItemMask = self:child("pokemon_task_cell-item-mask")
  self.siItemMask:SetVisible(false)
  self.stName = self:child("pokemon_task_cell-name")
  self.pbProgress = self:child("pokemon_task_cell-progress")
  self.stProgress = self:child("pokemon_task_cell-progress-text")
  self.ltFunc = self:child("pokemon_task_cell-ltFunc")
  self.stFuncText = self:child("pokemon_task_cell-TextFunc")
  self.stFuncText:SetText(Lang:toText("gui.task.telegraph"))
  self.siActiveRewardIcon = self:child("pokemon_task_cell-active-reward-icon")
  self.stActiveRewardCount = self:child("pokemon_task_cell-active-reward-count")
  self.siExpRewardIcon = self:child("pokemon_task_cell-exp-reward-icon")
  self.stExpRewardCount = self:child("pokemon_task_cell-exp-reward-count")
  self.siCompleteIcon = self:child("pokemon_task_cell-complete")
  self.siCompleteIcon:SetVisible(false)
  self.siLock = self:child("pokemon_task_cell-lock-bg")
  self.siLock:SetVisible(false)
  self.siLockIcon = self:child("pokemon_task_cell-lock-icon")
  self.stLockDesc = self:child("pokemon_task_cell-lock-desc")
end

function M:initEvent()
  self:subscribe(self.ltFunc, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.status.finished == 0 then
      if self.data.type == Define.TASK_TYPE.SHOP_PURCHASE then
        UI:getWnd("pokemon_Shop"):onShow(true)
      elseif self.data.type == Define.TASK_TYPE.ITEM_USE then
        UI:getWnd("pokemonBag"):onShow(true, Define.SCENE_TYPE.NOT_BATTLE)
      elseif self.data.type == Define.TASK_TYPE.POKEMON_UPGRADE_STAR then
        UI:getWnd("pokemonPacket"):onShow("battle")
      else
        UI:getWnd("pokemonTaskDetail"):onShow(self.data.id, self.status, dx, dy)
      end
    elseif self.status.finished == 1 and self.status.rewarded == 0 then
      Lib.logDebug("collect task reward")
      local area = self.siItemIcon:GetUnclippedOuterRect()
      local x = (area[1] + area[3]) / 2
      local y = (area[2] + area[4]) / 2
      Lib.emitEvent(Event.EVENT_TASK_POINT_POSITION, x, y)
      Me:sendPacket({
        pid = "GetTaskReward",
        taskid = self.data.id
      })
      self.ltFunc:SetTouchable(false)
    end
  end)
  self:subscribe(self.ltItem, UIEvent.EventWindowClick, function(window, dx, dy)
    UI:getWnd("pokemonItemDetail"):onShow(self.data.item_reward[1], dx, dy)
  end)
end

function M:initItem(data)
end

function M:updateStatus(status)
  self.status = status
  self:refreshStatus()
end

function M:initView(id, data, status)
  Lib.logDebug("pokemon_task_cell id = ", id)
  Lib.logDebug("pokemon_task_cell initView data = ", data)
  Lib.logDebug("pokemon_task_cell initView status = ", status)
  local id = id
  self.data = data
  if not self.redNode then
    self.receiveRedNode = UIRedDotMgr:createOneRedNodeSignal(self.data.id, self.ltFunc, 0, 0)
  end
  self.stName:SetText(Lang:toText(self.data.name))
  self.stActiveRewardCount:SetText(self.data.active_reward)
  self.stExpRewardCount:SetText(self.data.exp_reward)
  local cfg = setting:fetch("item", self.data.item_reward[1])
  if cfg then
    self.stItemBg:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
    self.siItemIcon:SetImage(cfg.icon)
    self.stItemCount:SetText("x" .. self.data.item_reward[2])
  end
  self:updateStatus(status)
end

function M:refreshStatus()
  if self.status then
    if self.status.finished == 1 then
      self.stProgress:SetText(#self.data.targets .. "/" .. #self.data.targets)
      self.pbProgress:SetProgress(1.0)
      if self.status.rewarded == 1 then
        self.ltFunc:SetVisible(false)
        self.siCompleteIcon:SetVisible(true)
        self.stBackBg:SetImage("set:pokemon_task.json image:img_9_finishbg")
        self.stFrontBg:SetImage("set:pokemon_task.json image:img_9_finishbg2")
        self.pbProgress:SetVisible(false)
        self.stProgress:SetVisible(false)
        self.receiveRedNode:SetVisible(false)
        self.stName:SetTextColor({
          0.8352941176470589,
          0.6039215686274509,
          0.4235294117647059,
          1
        })
        self.siItemMask:SetVisible(true)
        self.stActiveRewardCount:SetTextColor({
          0.8352941176470589,
          0.6039215686274509,
          0.4235294117647059,
          1
        })
        self.siActiveRewardIcon:SetImage("set:pokemon_task.json image:img_0_activeicon2")
        self.stExpRewardCount:SetTextColor({
          0.8352941176470589,
          0.6039215686274509,
          0.4235294117647059,
          1
        })
        self.siExpRewardIcon:SetImage("set:pokemon_task.json image:img_0_icon_exp2")
      elseif self.status.rewarded == 0 then
        self.stFuncText:SetVisible(false)
        self.ltFunc:SetBackImage("set:pokemon_battle.json image:btn_0_confirm_yes")
        self.receiveRedNode:SetVisible(true)
      end
    elseif self.status.finished == 0 then
      self.stFuncText:SetVisible(true)
      self.ltFunc:SetBackImage("set:pokemon_battle.json image:blue")
      self.receiveRedNode:SetVisible(false)
      local curProgress = 0
      for i = 1, #self.status.targets do
        local target = self.status.targets[i]
        Lib.logDebug("target = ", Lib.v2s(target))
        for j = 1, #self.data.targets do
          if self.data.targets[j][1] == self.status.targets[i][1] and tonumber(self.status.targets[i][2]) >= tonumber(self.data.targets[j][2]) then
            curProgress = curProgress + 1
          end
        end
      end
      Lib.logDebug("curProgress = ", curProgress)
      self.stProgress:SetText(curProgress .. "/" .. #self.data.targets)
      local progress = curProgress / #self.data.targets
      self.pbProgress:SetProgress(progress)
    end
  end
end

function M:onDataChanged(data)
  self:initItem(data)
end

function M:onDestroy()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
