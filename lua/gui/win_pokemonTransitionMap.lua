function M:init()
  WinBase.init(self, "battle_pre_animation.json", false)
  
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.lytBattlePreView = self:child("battle_pre_view")
  self.lytBattlePreViewBg = self:child("battle_pre_view_bg")
  self.imgBattlePreViewEffect1 = self:child("battle_pre_view-effect1")
end

function M:initWnd()
end

function M:initEvent()
end

function M:onShow()
  UI:openWnd("pokemonTransitionMap")
end

function M:onHide()
  UI:closeWnd("pokemonTransitionMap")
end

function M:onOpen()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
  self.imgBattlePreViewEffect1:SetVisible(true)
  self.imgBattlePreViewEffect1:UnprepareEffect()
  self.imgBattlePreViewEffect1:SetEffectName("g2038_transition_2.effect")
end

function M:onClose()
end

return M
