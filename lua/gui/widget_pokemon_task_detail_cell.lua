local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local PokemonTaskConfig = T(Config, "PokemonTaskConfig")

function M:init()
  widget_base.init(self, "pokemon_task_detail_cell.json")
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
  self.btnTaskDetail = self:child("pokemon_task_detail_cell-BtnDetail")
  self.stDesc = self:child("pokemon_task_detail_cell-TextDetail")
  self.siComplete = self:child("pokemon_task_detail_cell-CompleteIcon")
  self.siComplete:SetVisible(false)
end

function M:initEvent()
end

function M:initItem(data)
end

function M:initViewDataWithoutAdapter(id, type, target, map, pos, finished)
  self.id = id
  self.type = type
  self.target = target
  self.map = map
  Lib.logDebug("map = ", self.map)
  self.pos = pos
  Lib.logDebug("pos = ", Lib.v2s(self.pos))
  Lib.logDebug("initViewDataWithoutAdapter finished = ", finished)
  self.finished = finished
  local desc = self:getDesc(self.type, tonumber(self.target[1]), self.target[2])
  self.stDesc:SetText(desc)
  Lib.logDebug("self.btnTaskDetail = ", self.btnTaskDetail)
  if self.finished == 1 then
    Lib.logDebug("set enable = false")
    self.siComplete:SetVisible(true)
    self.btnTaskDetail:SetEnabled(false)
    self._root:SetTouchable(false)
  elseif self.finished == 0 then
    Lib.logDebug("")
    Lib.logDebug("set enable = true")
    self.siComplete:SetVisible(false)
    self.btnTaskDetail:SetEnabled(true)
    self._root:SetTouchable(true)
  end
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    Lib.logDebug("click root telegraph")
    if self.finished == 0 and self.map and self.pos then
      Me:sendPacket({
        pid = "TelegraphToTask",
        map = self.map,
        pos = self.pos
      })
      UI:closeWnd("pokemonTaskDetail")
      UI:closeWnd("pokemonTask")
    end
  end)
end

function M:getDesc(type, id, count)
  Lib.logDebug("getDesc type, id, count = ", type, id, count)
  local desc = ""
  if type == Define.TASK_TYPE.NPC_BATTLE then
    if id == 0 then
      desc = Lang:toText("gui.task.npc.any") .. "    " .. count .. Lang:toText("gui.task.count.2")
    else
      desc = Lang:toText("npc_" .. id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.2")
    end
  elseif type == Define.TASK_TYPE.POKEMON_CAPTURE then
    if id == 0 then
      desc = Lang:toText("gui.task.pokemon.any") .. "    " .. count .. Lang:toText("gui.task.count.1")
    else
      desc = Lang:toText(id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.1")
    end
  elseif type == Define.TASK_TYPE.POKEMON_BATTLE then
    if id == 0 then
      desc = Lang:toText("gui.task.pokemon.any") .. "    " .. count .. Lang:toText("gui.task.count.2")
    else
      desc = Lang:toText(id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.2")
    end
  elseif type == Define.TASK_TYPE.PVP_GYM then
    desc = Lang:toText("gui.task.gym.pvp") .. "    " .. count .. Lang:toText("gui.task.count.2")
  elseif type == Define.TASK_TYPE.POKEMON_UPGRADE_STAR then
    if id == 0 then
      desc = Lang:toText("gui.task.pokemon.any") .. "    " .. count .. Lang:toText("gui.task.count.1")
    else
      desc = Lang:toText(id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.1")
    end
  elseif type == Define.TASK_TYPE.SHOP_PURCHASE then
    if id == 0 then
      desc = Lang:toText("gui.task.purchase.any") .. "    " .. count .. Lang:toText("gui.task.count.2")
    else
      desc = Lang:toText(id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.2")
    end
  elseif type == Define.TASK_TYPE.ITEM_USE then
    if id == 0 then
      desc = Lang:toText("gui.task.use.any") .. "    " .. count .. Lang:toText("gui.task.count.2")
    else
      desc = Lang:toText(id .. "_name") .. "    " .. count .. Lang:toText("gui.task.count.2")
    end
  elseif type == Define.TASK_TYPE.PVP_BATTLE then
    desc = Lang:toText("gui.task.pvp") .. "    " .. count .. Lang:toText("gui.task.count.2")
  end
  Lib.logDebug("desc = ", desc)
  return desc
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
