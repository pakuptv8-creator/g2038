local widget_base = require("ui.widget.widget_base")
local WidgetPetSpeedUp = Lib.derive(widget_base)
local PetConfig = T(Config, "PetConfig")

function WidgetPetSpeedUp:init()
  widget_base.init(self, "PetSpeedUp.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPetSpeedUp:initUI()
  self.btnGameMainSpeedUpPet = self:child("GameMain-SpeedUpPet")
  self.lytGameMainLytCD = self:child("GameMain-lytPetSpeedUpCD")
  self.txtGameMainTxtPeSpeedUpCD = self:child("GameMain-txtPeSpeedUpCD")
  self.lytGameMainLytCD:SetVisible(false)
end

function WidgetPetSpeedUp:initEvent()
  self:subscribe(self.btnGameMainSpeedUpPet, UIEvent.EventButtonClick, function()
    if self.petSpeedUpWait then
      return
    end
    local objId_pet = Me:getCurCarryPetObjId()
    local pet = World.CurWorld:getObject(objId_pet)
    if not pet or not pet:isValid() then
      return
    end
    if Me.rideOnId ~= objId_pet then
      return
    end
    local petId = Me:getCurCarryPetId()
    local petData = Me:getPetData()[petId]
    if not petData then
      return
    end
    local cfgId = petData.cfgId
    local cfg = PetConfig:getCfgById(cfgId)
    if not cfg then
      return
    end
    self.petSpeedUpWait = true
    Me:sendPacket({pid = "petSpeedUp"}, function(ret)
      self.petSpeedUpWait = false
      if ret then
        self.lastPetSpeedUpStamp = os.time()
        if self.speedUpCDTimer then
          self.speedUpCDTimer()
          self.speedUpCDTimer = nil
        end
        self.lytGameMainLytCD:SetVisible(true)
        self.txtGameMainTxtPeSpeedUpCD:SetText(cfg.speedUpCD)
        self.speedUpCDTimer = World.Timer(20, function()
          local remain = cfg.speedUpCD - (os.time() - self.lastPetSpeedUpStamp)
          if remain <= 0 then
            self.speedUpCDTimer = nil
            self.lytGameMainLytCD:SetVisible(false)
            return false
          else
            self.txtGameMainTxtPeSpeedUpCD:SetText(remain)
            return true
          end
        end)
      end
    end)
  end)
end

function WidgetPetSpeedUp:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPetSpeedUp
