local Player = _ENV.Player

function Player:clientSetProfession(professionId)
  UI:getWnd("professionWnd"):setCurProfessionId(professionId)
  UI:getWnd("professionWnd"):updatePlayerHeadViewShow()
  local packet = {
    pid = "CSUpdateProfession",
    professionId = professionId
  }
  self:sendPacket(packet)
end

function Player:requestAllPlayerCareer()
  self:sendPacket({
    pid = "RequestAllPlayerCareer"
  })
end

function Player:requestCallOneCareer(professionId)
  if self.phoneCallLastTime and os.time() - self.phoneCallLastTime < World.cfg.phoneProfession.callCD then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.phone.call_wait")
    return
  end
  self:sendPacket({
    pid = "RequestCallOneCareer",
    professionId = professionId
  })
  self.phoneCallLastTime = os.time()
end

function Player:updateCallSelfTopEffect(isShow)
  self:stopCallSelfTopEffect()
  if isShow then
    local effect = {
      effect = "g2052_phone_left.effect",
      pos = {
        x = 0,
        y = World.cfg.phoneProfession.topSelfEffectHeight,
        z = 0
      },
      yaw = 0,
      scale = World.cfg.phoneProfession.topSelfEffectScale,
      once = false
    }
    self.myTopCallEffect = self:showEffect(effect)
    self.myTopCallTimer = World.Timer(20 * World.cfg.phoneProfession.callSelfTopTime, function()
      self:stopCallSelfTopEffect()
    end)
  end
end

function Player:stopCallSelfTopEffect()
  if self.myTopCallEffect then
    self:delEffect(Me.myTopCallEffect)
    self.myTopCallEffect = nil
  end
  if self.myTopCallTimer then
    self.myTopCallTimer()
    self.myTopCallTimer = nil
  end
end
