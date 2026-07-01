local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  widget_base.init(self, "PokemonLuckyExtraItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPanel = self:child("PokemonLuckyExtraItem-Panel")
  self.imgBg = self:child("PokemonLuckyExtraItem-Bg")
  self.imgSelect = self:child("PokemonLuckyExtraItem-select")
  self.txtDescTxt = self:child("PokemonLuckyExtraItem-descTxt")
  self.lytGoodItem = self:child("PokemonLuckyExtraItem-goodItem")
  self.imgGoodItemBg = self:child("PokemonLuckyExtraItem-goodItemBg")
  self.imgGoodItemIcon = self:child("PokemonLuckyExtraItem-goodItemIcon")
  self.txtGoodItemTxt = self:child("PokemonLuckyExtraItem-goodItemTxt")
  self.imgGou = self:child("PokemonLuckyExtraItem-gou")
  self.lytGoodBlack = self:child("PokemonLuckyExtraItem-goodBlack")
  self.effectIcon = self:child("PokemonLuckyExtraItem-effectIcon")
  self.imgGoodFrame = self:child("PokemonLuckyExtraItem-goodFrame")
  self.imgPetItemBg = self:child("PokemonLuckyExtraItem-petItemBg")
end

function M:onDataChanged(itemData)
  self.itemData = itemData
  if itemData.pkm_id > 0 then
    local pkmInfo = PokemonConfig:getConfigById(itemData.pkm_id)
    self.imgGoodItemIcon:SetImage(pkmInfo.icon)
    local qualityFrame = PokemonConfig:getQualityFrame(itemData.pkm_id)
    self.imgGoodFrame:SetImage(qualityFrame)
    self.imgGoodFrame:SetVisible(true)
    self.txtGoodItemTxt:SetVisible(false)
    self.imgPetItemBg:SetVisible(true)
  else
    local cfg = setting:fetch("item", itemData.fullName)
    if cfg then
      self.imgGoodItemIcon:SetImage(cfg.icon)
    end
    self.txtGoodItemTxt:SetText("X" .. itemData.award_count)
    self.txtGoodItemTxt:SetVisible(true)
    self.imgGoodFrame:SetVisible(false)
    self.imgPetItemBg:SetVisible(false)
  end
  self:updateItemShow()
end

function M:updateItemShow(curExtraId)
  if curExtraId ~= nil then
    self.itemData.curExtraId = curExtraId
  end
  if self.itemData.curExtraId == self.itemData.id then
    self.imgSelect:SetVisible(true)
    self.imgBg:SetImage("set:pokemon_lucky_egg.json image:img_9_rewards_bg1")
    self.txtDescTxt:SetText(Lang:toText({
      "gui_lucky_egg_cumulative_extra2",
      self.itemData.take_count
    }))
  else
    self.imgSelect:SetVisible(false)
    self.imgBg:SetImage("set:pokemon_lucky_egg.json image:img_9_rewards_bg2")
    self.txtDescTxt:SetText(Lang:toText({
      "gui_lucky_egg_cumulative_extra1",
      self.itemData.take_count
    }))
  end
  local luckyEggExtra = Me:getLuckyEggExtra()
  if luckyEggExtra[self.itemData.id] then
    self.imgGou:SetVisible(true)
    self.lytGoodBlack:SetVisible(true)
    self.effectIcon:SetVisible(false)
  else
    self.imgGou:SetVisible(false)
    self.lytGoodBlack:SetVisible(false)
    local luckyEggInfo = Me:getLuckyEggInfo()
    local curCount = 0
    if luckyEggInfo[self.itemData.pool_id] then
      curCount = luckyEggInfo[self.itemData.pool_id].totalTakeCounts
    end
    if curCount >= self.itemData.take_count then
      self.effectIcon:SetVisible(true)
    else
      self.effectIcon:SetVisible(false)
    end
  end
end

function M:initEvent()
  self:subscribe(self.lytGoodItem, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.effectIcon:IsVisible() then
      if self.itemData then
        if self.itemData.pkm_id > 0 then
          local battlePetList = Me:getValue("packetPetList")
          if #battlePetList + 1 > World.cfg.maxBoxPetsCnt then
            UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
              if not ret then
                return
              end
              UI:getWnd("pokemonPacket"):onShow("packet")
            end)
            return
          end
        end
        local packet = {
          pid = "receiveLuckyEggExtraAward",
          extraId = self.itemData.id
        }
        Me:sendPacket(packet)
      end
    elseif self.itemData.pkm_id > 0 then
      UI:getWnd("pokemonLuckyDetails"):onShow(true, self.itemData.pkm_id, UI:getWnd("pokemonLuckyEgg").curSelectTab)
    else
      UI:getWnd("pokemonItemDetail"):onShow(self.itemData.fullName, dx, dy)
    end
  end)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
