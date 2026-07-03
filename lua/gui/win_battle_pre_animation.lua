local LuaTimer = T(Lib, "LuaTimer")
local EFFECT_NAME_LIST = {
  [Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE] = "g2038_transition_1.effect",
  [Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK] = "g2038_transition_2.effect",
  [Define.PRE_BATTLE_ANIMATION.HIDE_BLOCK] = "g2038_transition_3.effect",
  [Define.PRE_BATTLE_ANIMATION.WARNING_SIGN] = "g2038_fightTips_1.effect"
}
local animationList = {
  [Define.MEET_PKM_TYPE.HIDE_PKM] = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  },
  [Define.MEET_PKM_TYPE.BRIGHT_PKM] = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  },
  [Define.MEET_PKM_TYPE.AREA_NPC_PKM] = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  },
  [Define.MEET_PKM_TYPE.INTERACTION_NPC_PKM] = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  },
  [Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER] = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  }
}
local M = _ENV.M

function M:init()
  WinBase.init(self, "battle_pre_animation.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytBattlePreView = self:child("battle_pre_view")
  self.lytBattlePreViewBg = self:child("battle_pre_view_bg")
  self.imgBattlePreViewEffect1 = self:child("battle_pre_view-effect1")
end

function M:initEvent()
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLOSE_PRE_BATTLE_ANIMATION, function()
    self:onHide()
  end)
end

function M:initView(animationInfo)
  self.curEffectId = 1
  if animationInfo then
    self.meetType = animationInfo.meetType
    self.rareID = animationInfo.rareID
    self:startUpdateTime()
  end
end

function M:startUpdateTime()
  Lib.emitEvent(Event.EVENT_FINISH_PRE_BATTLE_ANIMATION)
end

function M:showEffectWithId(curAnimation)
  if self.meetType == Define.MEET_PKM_TYPE.HIDE_PKM and curAnimation == Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE then
    self.warningPos = Me:getPosition()
    self.warningPos.y = self.warningPos.y
    local curRareId
    if self.rareID >= 5 then
      curRareId = 5
    else
      curRareId = self.rareID
    end
    Blockman.instance:playEffectByPos("g2038_fightTips_" .. curRareId .. ".effect", self.warningPos, 0, -1)
    Me:playSoundByKey("tips")
    self.imgBattlePreViewEffect1:SetVisible(true)
    self.imgBattlePreViewEffect1:UnprepareEffect()
    self.imgBattlePreViewEffect1:SetEffectName(EFFECT_NAME_LIST[curAnimation])
  else
    self.imgBattlePreViewEffect1:SetVisible(true)
    self.imgBattlePreViewEffect1:UnprepareEffect()
    self.imgBattlePreViewEffect1:SetEffectName(EFFECT_NAME_LIST[curAnimation])
  end
end

function M:showCloseAnimation()
  UI:closeWnd("pokemonEvolution")
  UI:closeWnd("battle_results")
  UI:closeWnd("battle_dialog")
  Me:startPlayBattleMove()
  self:onHide()
end

function M:onHide()
  UI:closeWnd("battle_pre_animation")
end

function M:onShow(isShow, animationInfo)
  if isShow then
    if not UI:isOpen(self) then
      Me:setBattlePreType(animationInfo.meetType)
      UI:openWnd("battle_pre_animation", animationInfo)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(animationInfo)
  self._allEvent = {}
  self:subscribeEvent()
  Me.disableControl = true
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
  self:initView(animationInfo)
end

function M:onClose()
  if not Me:isInBattle() then
    Me.disableControl = false
  end
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
