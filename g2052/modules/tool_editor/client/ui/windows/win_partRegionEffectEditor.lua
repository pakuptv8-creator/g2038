local WinPartRegionEffectEditor = M
local RegionEffectsConfig = T(Config, "RegionEffectsConfig")

function WinPartRegionEffectEditor:init()
  WinBase.init(self, "partRegionEffectEditor.json")
  self._allEvent = {}
  self.cfgId = 0
  self.curSelectPart = nil
  self.effect = ""
  self.posOffset = ""
  self.scale = ""
  self.rotate = ""
  self.lastEffectPos = nil
  self.isLockClickPart = false
  self.tempViewEntity = {}
  self.curAllEffect = {}
  self.curDelDataId = nil
  self.btnPartRegionEffectEditorDataBtn = {}
  self.imgPartRegionEffectEditorDataSelect = {}
  self.txtPartRegionEffectEditorDataId = {}
  self.selectContainId = 1
  self:initUI()
  self:initEvent()
end

function WinPartRegionEffectEditor:initUI()
  self.lytPartRegionEffectEditorSelectPart = self:child("partRegionEffectEditor-selectPart")
  self.txtPartRegionEffectEditorPartTitle = self:child("partRegionEffectEditor-partTitle")
  self.txtPartRegionEffectEditorPartId = self:child("partRegionEffectEditor-partId")
  self.txtPartRegionEffectEditorPartIdName = self:child("partRegionEffectEditor-partIdName")
  self.lytPartRegionEffectEditorConfig = self:child("partRegionEffectEditor-config")
  self.txtPartRegionEffectEditorConfigtitle = self:child("partRegionEffectEditor-configtitle")
  self.txtPartRegionEffectEditorEffect = self:child("partRegionEffectEditor-effect")
  self.editPartRegionEffectEditorEffectInput = self:child("partRegionEffectEditor-effectInput")
  self.txtPartRegionEffectEditorPos = self:child("partRegionEffectEditor-pos")
  self.editPartRegionEffectEditorPosInput = self:child("partRegionEffectEditor-posInput")
  self.txtPartRegionEffectEditorScale = self:child("partRegionEffectEditor-scale")
  self.editPartRegionEffectEditorScaleInput = self:child("partRegionEffectEditor-scaleInput")
  self.txtPartRegionEffectEditorYaw = self:child("partRegionEffectEditor-yaw")
  self.editPartRegionEffectEditorYawInput = self:child("partRegionEffectEditor-yawInput")
  self.btnPartRegionEffectEditorSaveBtn = self:child("partRegionEffectEditor-saveBtn")
  self.btnPartRegionEffectEditorCloseBtn = self:child("partRegionEffectEditor-closeBtn")
  self.btnPartRegionEffectEditorLockBtn = self:child("partRegionEffectEditor-lockBtn")
  self.btnPartRegionEffectEditorClearDateBtn = self:child("partRegionEffectEditor-clearDateBtn")
  self.btnPartRegionEffectEditorDelDateBtn = self:child("partRegionEffectEditor-delBtn")
  self.editPartRegionEffectEditorDelInput = self:child("partRegionEffectEditor-delInput")
  self.btnPartRegionEffectEditorPosXAddBtn = self:child("partRegionEffectEditor-posXAddBtn")
  self.btnPartRegionEffectEditorPosYAddBtn = self:child("partRegionEffectEditor-posYAddBtn")
  self.btnPartRegionEffectEditorPosZAddBtn = self:child("partRegionEffectEditor-posZAddBtn")
  self.btnPartRegionEffectEditorPosXSubBtn = self:child("partRegionEffectEditor-posXSubBtn")
  self.btnPartRegionEffectEditorPosYSubBtn = self:child("partRegionEffectEditor-posYSubBtn")
  self.btnPartRegionEffectEditorPosZSubBtn = self:child("partRegionEffectEditor-posZSubBtn")
  self.btnPartRegionEffectEditorScaleXAddBtn = self:child("partRegionEffectEditor-scaleXAddBtn")
  self.btnPartRegionEffectEditorScaleYAddBtn = self:child("partRegionEffectEditor-scaleYAddBtn")
  self.btnPartRegionEffectEditorScaleZAddBtn = self:child("partRegionEffectEditor-scaleZAddBtn")
  self.btnPartRegionEffectEditorScaleXSubBtn = self:child("partRegionEffectEditor-scaleXSubBtn")
  self.btnPartRegionEffectEditorScaleYSubBtn = self:child("partRegionEffectEditor-scaleYSubBtn")
  self.btnPartRegionEffectEditorScaleZSubBtn = self:child("partRegionEffectEditor-scaleZSubBtn")
  self.btnPartRegionEffectEditorYawXAddBtn = self:child("partRegionEffectEditor-yawXAddBtn")
  self.btnPartRegionEffectEditorYawYAddBtn = self:child("partRegionEffectEditor-yawYAddBtn")
  self.btnPartRegionEffectEditorYawZAddBtn = self:child("partRegionEffectEditor-yawZAddBtn")
  self.btnPartRegionEffectEditorYawXSubBtn = self:child("partRegionEffectEditor-yawXSubBtn")
  self.btnPartRegionEffectEditorYawYSubBtn = self:child("partRegionEffectEditor-yawYSubBtn")
  self.btnPartRegionEffectEditorYawZSubBtn = self:child("partRegionEffectEditor-yawZSubBtn")
  self.lytPartRegionEffectEditorPartList = self:child("partRegionEffectEditor-partList")
  self.btnPartRegionEffectEditorAddDataBtn = self:child("partRegionEffectEditor-addData")
  for i = 1, 4 do
    self.btnPartRegionEffectEditorDataBtn[i] = self:child("partRegionEffectEditor-data" .. i)
    self.imgPartRegionEffectEditorDataSelect[i] = self:child("partRegionEffectEditor-dataSelect" .. i)
    self.txtPartRegionEffectEditorDataId[i] = self:child("partRegionEffectEditor-dataId" .. i)
  end
end

function WinPartRegionEffectEditor:initEvent()
  self:subscribe(self.btnPartRegionEffectEditorAddDataBtn, UIEvent.EventButtonClick, function()
    if not self.curSelectPart or not self.curSelectPart:isValid() then
      return
    end
    local cfgCount = RegionEffectsConfig:getCfgCount()
    self.cfgId = cfgCount + 1
    local tbCfg = RegionEffectsConfig:getCfgByPartId(self.curSelectPart:getInstanceID())
    local nextId = Lib.getTableSize(tbCfg) + 1
    if 4 < nextId then
      return
    end
    self.selectContainId = nextId
    if self.btnPartRegionEffectEditorDataBtn[nextId] then
      self.btnPartRegionEffectEditorDataBtn[nextId]:SetVisible(true)
      for i = 1, 4 do
        if i == nextId then
          self.imgPartRegionEffectEditorDataSelect[i]:SetVisible(true)
        else
          self.imgPartRegionEffectEditorDataSelect[i]:SetVisible(false)
        end
      end
      self.txtPartRegionEffectEditorDataId[nextId]:SetText(tostring(cfgCount + 1))
    end
    self.editPartRegionEffectEditorEffectInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorPosInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorScaleInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorYawInput:SetProperty("Text", "")
  end)
  for i = 1, 4 do
    self:subscribe(self.btnPartRegionEffectEditorDataBtn[i], UIEvent.EventButtonClick, function()
      if not self.curSelectPart or not self.curSelectPart:isValid() then
        return
      end
      local tbCfg = RegionEffectsConfig:getCfgByPartId(self.curSelectPart:getInstanceID())
      if Lib.getTableSize(tbCfg) < 1 then
        return
      end
      self.selectContainId = i
      if tbCfg and tbCfg[i] then
        for j = 1, 4 do
          if j == i then
            self.imgPartRegionEffectEditorDataSelect[j]:SetVisible(true)
          else
            self.imgPartRegionEffectEditorDataSelect[j]:SetVisible(false)
          end
        end
        local conf = tbCfg[i]
        self.cfgId = tbCfg[i].id
        if conf.effectName then
          self.editPartRegionEffectEditorEffectInput:SetProperty("Text", conf.effectName)
          self.effect = conf.effectName
        end
        if conf.pos then
          self.editPartRegionEffectEditorPosInput:SetProperty("Text", conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z)
          self.posOffset = conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z
        end
        if conf.scale then
          self.editPartRegionEffectEditorScaleInput:SetProperty("Text", conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z)
          self.scale = conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z
        end
        if conf.rotation then
          self.editPartRegionEffectEditorYawInput:SetProperty("Text", conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z)
          self.rotate = conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z
        end
      end
    end)
  end
  self:subscribe(self.btnPartRegionEffectEditorYawXAddBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotation\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local params = (data[1] or 0) + 0.1 .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorYawYAddBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotate\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) + 0.1 .. "#" .. (data[3] or 0)
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorYawZAddBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotate\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0) + 0.1
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorYawXSubBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotate\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local x = (data[1] or 0) - 0.1
    local params = x .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorYawYSubBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotate\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local y = (data[2] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. y .. "#" .. (data[3] or 0)
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorYawZSubBtn, UIEvent.EventButtonClick, function()
    if self.rotate == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165rotate\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.rotate or "", "#", true)
    local z = (data[3] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. z
    self:setConfigData(4, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosXAddBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local params = (data[1] or 0) + 0.1 .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosYAddBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) + 0.1 .. "#" .. (data[3] or 0)
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosZAddBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0) + 0.1
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosXSubBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local x = (data[1] or 0) - 0.1
    local params = x .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosYSubBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local y = (data[2] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. y .. "#" .. (data[3] or 0)
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorPosZSubBtn, UIEvent.EventButtonClick, function()
    if self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165pos\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.posOffset or "", "#", true)
    local z = (data[3] or 0) - 0.1
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. z
    self:setConfigData(2, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleXAddBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local params = (data[1] or 0) + 0.1 .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleYAddBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) + 0.1 .. "#" .. (data[3] or 0)
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleZAddBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0) + 0.1
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleXSubBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local x = (data[1] or 0) - 0.1
    if x < 0 then
      x = 0
    end
    local params = x .. "#" .. (data[2] or 0) .. "#" .. (data[3] or 0)
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleYSubBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local y = (data[2] or 0) - 0.1
    if y < 0 then
      y = 0
    end
    local params = (data[1] or 0) .. "#" .. y .. "#" .. (data[3] or 0)
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorScaleZSubBtn, UIEvent.EventButtonClick, function()
    if self.scale == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165scale\230\149\176\230\141\174\229\156\168\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    local data = Lib.splitString(self.scale or "", "#", true)
    local z = (data[3] or 0) - 0.1
    if z < 0 then
      z = 0
    end
    local params = (data[1] or 0) .. "#" .. (data[2] or 0) .. "#" .. z
    self:setConfigData(3, params)
  end)
  self:subscribe(self.btnPartRegionEffectEditorDelDateBtn, UIEvent.EventButtonClick, function()
    if not self.curDelDataId then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\232\190\147\229\133\165\232\166\129\229\136\160\233\153\164\231\154\132\233\133\141\231\189\174Id")
      return
    end
    local cfg = RegionEffectsConfig:getCfgById(self.curDelDataId)
    if cfg then
      local pos = cfg.pos
      if cfg.partID and cfg.partID ~= "" then
        local part = Instance.getByInstanceId(tonumber(cfg.partID))
        if part and part:isValid() then
          local partPos = part:getPosition()
          pos = Lib.v3(partPos.x + pos.x, partPos.y + pos.y, partPos.z + pos.z)
        end
      end
      Blockman.instance:delEffect(cfg.effectName, pos)
      RegionEffectsConfig:delCfgDate(self.curDelDataId)
      Me:sendPacket({
        pid = "rewriteRegionEffectsCfg"
      })
      for i, tempEntity in pairs(self.tempViewEntity) do
        if tempEntity and tempEntity:isValid() then
          tempEntity:destroy()
        end
      end
      World.Timer(10, function()
        self:clearData()
        self.tempViewEntity = {}
        self:initConfigDate()
      end)
    end
  end)
  self:subscribe(self.btnPartRegionEffectEditorClearDateBtn, UIEvent.EventButtonClick, function()
    self:clearData()
  end)
  self:subscribe(self.btnPartRegionEffectEditorLockBtn, UIEvent.EventButtonClick, function()
    if not self.isLockClickPart then
      self.isLockClickPart = true
      self.btnPartRegionEffectEditorLockBtn:SetText("\232\167\163\233\148\129")
    else
      self.isLockClickPart = false
      self.btnPartRegionEffectEditorLockBtn:SetText("\233\148\129\229\174\154")
    end
  end)
  self:subscribe(self.btnPartRegionEffectEditorSaveBtn, UIEvent.EventButtonClick, function()
    if self.effect == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\230\156\170\229\161\171\229\134\153\231\137\185\230\149\136\229\144\141")
      return
    end
    if not self.curSelectPart and self.posOffset == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\228\189\141\231\189\174\228\191\161\230\129\175")
      return
    end
    local partId = ""
    if self.curSelectPart and self.curSelectPart:isValid() then
      partId = self.curSelectPart:getInstanceID()
    end
    local tbData = {
      n_id = self.cfgId,
      s_partID = partId ~= "" and "#" .. partId .. "#" or "",
      s_effectName = self.effect,
      s_pos = self.posOffset,
      s_scale = self.scale,
      s_rotation = tostring(self.rotate)
    }
    RegionEffectsConfig:rewriteCfg(tbData)
    self.isSave = true
    Me:sendPacket({
      pid = "rewriteRegionEffectsCfg"
    })
  end)
  self:subscribe(self.btnPartRegionEffectEditorCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.editPartRegionEffectEditorDelInput, UIEvent.EventEditTextInput, function()
    local param = self.editPartRegionEffectEditorDelInput:GetPropertyString("Text", "")
    self.curDelDataId = tonumber(param)
    self:showDateInfo(self.curDelDataId)
    local posArr = Lib.splitString(self.posOffset or "", "#", true)
    local pos = Lib.v3(posArr[1] or 0, posArr[2] or 0, posArr[3] or 0)
    if self.curSelectPart and self.curSelectPart:isValid() then
      local partPos = self.curSelectPart:getPosition()
      pos = Lib.v3(partPos.x + pos.x, pos.y + partPos.y, pos.z + partPos.z)
    end
    Me:setPos(Lib.v3(pos.x, pos.y + 2, pos.z))
  end)
  self:subscribe(self.editPartRegionEffectEditorEffectInput, UIEvent.EventEditTextInput, function()
    local param = self.editPartRegionEffectEditorEffectInput:GetPropertyString("Text", "")
    self:setConfigData(1, param)
  end)
  self:subscribe(self.editPartRegionEffectEditorPosInput, UIEvent.EventEditTextInput, function()
    if self.effect == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\230\156\170\229\161\171\229\134\153\231\137\185\230\149\136\229\144\141")
      return
    end
    local param = self.editPartRegionEffectEditorPosInput:GetPropertyString("Text", "")
    self:setConfigData(2, param)
  end)
  self:subscribe(self.editPartRegionEffectEditorScaleInput, UIEvent.EventEditTextInput, function()
    if self.effect == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\230\156\170\229\161\171\229\134\153\231\137\185\230\149\136\229\144\141")
      return
    end
    local param = self.editPartRegionEffectEditorScaleInput:GetPropertyString("Text", "")
    self:setConfigData(3, param)
  end)
  self:subscribe(self.editPartRegionEffectEditorYawInput, UIEvent.EventEditTextInput, function()
    if self.effect == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\230\156\170\229\161\171\229\134\153\231\137\185\230\149\136\229\144\141")
      return
    end
    local param = self.editPartRegionEffectEditorYawInput:GetPropertyString("Text", "")
    self:setConfigData(4, param)
  end)
end

function WinPartRegionEffectEditor:initConfigDate()
  local function createTempEntity(pos, cfg)
    local manager = World.CurWorld:getSceneManager()
    
    local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
    local rotation = cfg.rotation or Lib.v3(0, 0, 0)
    local effectNode = EffectNode.Load(cfg.effectName)
    if effectNode then
      effectNode:start()
      effectNode:setWorldPosition(Lib.v3(pos.x, pos.y, pos.z))
      effectNode:setWorldScale(Lib.v3(cfg.scale.x, cfg.scale.y, cfg.scale.z))
      effectNode:setWorldRotation(rotation)
      scene:getRoot():addChild(effectNode)
      self.curAllEffect[cfg.id] = effectNode
    end
    self.tempViewEntity[cfg.id] = EntityClient.CreateClientEntity({
      cfgName = "myplugin/empty",
      pos = pos,
      name = "Id:" .. cfg.id
    })
  end
  
  local conf = RegionEffectsConfig:getAllConfigs()
  if conf then
    for i, date in pairs(conf) do
      if Me:data("main").PartRegionEffect[date.id] then
        local manager = World.CurWorld:getSceneManager()
        local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
        scene:getRoot():removeChild(Me:data("main").PartRegionEffect[date.id])
        Me:data("main").PartRegionEffect[date.id]:destroy()
        Me:data("main").PartRegionEffect[date.id] = nil
      end
      if date.partID and date.partID ~= "" then
        local part = Instance.getByInstanceId(date.partID)
        if part and part:isValid() then
          local partPos = part:getPosition()
          local pos = Lib.v3(date.pos.x + partPos.x, date.pos.y + partPos.y, date.pos.z + partPos.z)
          World.Timer(5, function()
            createTempEntity(pos, date)
          end)
        end
      else
        local pos = Lib.v3(date.pos.x, date.pos.y, date.pos.z)
        World.Timer(5, function()
          createTempEntity(pos, date)
        end)
      end
    end
  end
end

function WinPartRegionEffectEditor:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PART_CLICK, function(part, from)
    if self.isLockClickPart then
      return
    end
    if not part or not part:isValid() then
      return
    end
    if not (from and from:isValid()) or not from.isPlayer then
      return
    end
    if self.curSelectPart and self.curSelectPart:isValid() and self.curSelectPart:getInstanceID() == part:getInstanceID() then
      return
    end
    self:clearData()
    self.curSelectPart = part
    self:initView()
  end)
end

function WinPartRegionEffectEditor:showEffect(pos)
  local effectName = self.effect
  if effectName == "" then
    return
  end
  local newIndex = RegionEffectsConfig:getCfgCount() + 1
  if self.curSelectPart and self.curSelectPart:isValid() then
    local cfg = RegionEffectsConfig:getCfgByPartId(self.curSelectPart:getInstanceID())
    if cfg and cfg[self.selectContainId] then
      newIndex = cfg[self.selectContainId].id
    end
  end
  if self.curDelDataId then
    newIndex = self.curDelDataId
  end
  self.cfgId = newIndex
  if self.tempViewEntity[newIndex] and self.tempViewEntity[newIndex]:isValid() then
    self.tempViewEntity[newIndex]:destroy()
  end
  self.tempViewEntity[newIndex] = EntityClient.CreateClientEntity({
    cfgName = "myplugin/empty",
    pos = pos,
    name = "Id:" .. newIndex
  })
  if self.curAllEffect[newIndex] then
    local sceneManager = World.CurWorld:getSceneManager()
    local curScene = sceneManager:getOrCreateScene(Player.CurPlayer.map.obj)
    curScene:getRoot():removeChild(self.curAllEffect[newIndex])
    self.curAllEffect[newIndex]:destroy()
    self.curAllEffect[newIndex] = nil
  end
  World.Timer(10, function()
    local lastEffectPos = Lib.v3(pos.x, pos.y, pos.z)
    self.lastEffectPos = lastEffectPos
    local scaleArr = Lib.splitString(self.scale or "", "#", true)
    local scale = Lib.v3(scaleArr[1] or 1, scaleArr[2] or 1, scaleArr[3] or 1)
    local rotationArr = Lib.splitString(self.rotate or "", "#", true)
    local rotate = Lib.v3(rotationArr[1] or 0, rotationArr[2] or 0, rotationArr[3] or 0)
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
    local rotation = rotate or Lib.v3(0, 0, 0)
    local effectNode = EffectNode.Load(effectName)
    if effectNode then
      effectNode:start()
      effectNode:setWorldPosition(Lib.v3(pos.x, pos.y, pos.z))
      effectNode:setWorldScale(Lib.v3(scale.x, scale.y, scale.z))
      effectNode:setWorldRotation(rotation)
      scene:getRoot():addChild(effectNode)
      self.curAllEffect[newIndex] = effectNode
    end
  end)
end

function WinPartRegionEffectEditor:showDateInfo(cfgId)
  local conf = RegionEffectsConfig:getCfgById(cfgId)
  if conf then
    self.cfgId = conf.id
    local part = Instance.getByInstanceId(conf.partID)
    if conf.partID ~= "" and part and part:isValid() then
      self.curSelectPart = part
      local partName = self.curSelectPart.name or ""
      local partId = self.curSelectPart:getInstanceID() or ""
      self.txtPartRegionEffectEditorPartId:SetText("partId:" .. partId)
      self.txtPartRegionEffectEditorPartIdName:SetText("partName:" .. partName)
    else
      self.curSelectPart = nil
      self.txtPartRegionEffectEditorPartId:SetText("")
      self.txtPartRegionEffectEditorPartIdName:SetText("")
    end
    if conf.effectName then
      self.editPartRegionEffectEditorEffectInput:SetProperty("Text", conf.effectName)
      self.effect = conf.effectName
    end
    if conf.pos then
      self.editPartRegionEffectEditorPosInput:SetProperty("Text", conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z)
      self.posOffset = conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z
    end
    if conf.scale then
      self.editPartRegionEffectEditorScaleInput:SetProperty("Text", conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z)
      self.scale = conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z
    end
    if conf.rotation then
      self.editPartRegionEffectEditorYawInput:SetProperty("Text", conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z)
      self.rotate = conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z
    end
  end
  return conf
end

function WinPartRegionEffectEditor:initView()
  if self.curSelectPart and self.curSelectPart:isValid() then
    local partName = self.curSelectPart.name or ""
    local partId = self.curSelectPart:getInstanceID() or ""
    self.txtPartRegionEffectEditorPartId:SetText("partId:" .. partId)
    self.txtPartRegionEffectEditorPartIdName:SetText("partName:" .. partName)
    local tbConf = RegionEffectsConfig:getCfgByPartId(self.curSelectPart:getInstanceID())
    if tbConf and tbConf[1] then
      if 1 <= Lib.getTableSize(tbConf) then
        self.lytPartRegionEffectEditorPartList:SetVisible(true)
        for i = 1, 4 do
          if tbConf[i] then
            self.btnPartRegionEffectEditorDataBtn[i]:SetVisible(true)
            self.txtPartRegionEffectEditorDataId[i]:SetText(tostring(tbConf[i].id))
            if i == 1 then
              self.imgPartRegionEffectEditorDataSelect[1]:SetVisible(true)
            end
          else
            self.btnPartRegionEffectEditorDataBtn[i]:SetVisible(false)
          end
        end
      else
        self.lytPartRegionEffectEditorPartList:SetVisible(false)
      end
      local conf = tbConf[1]
      self.cfgId = conf.id
      if conf.effectName then
        self.editPartRegionEffectEditorEffectInput:SetProperty("Text", conf.effectName)
        self.effect = conf.effectName
      end
      if conf.pos then
        self.editPartRegionEffectEditorPosInput:SetProperty("Text", conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z)
        self.posOffset = conf.pos.x .. "#" .. conf.pos.y .. "#" .. conf.pos.z
      end
      if conf.scale then
        self.editPartRegionEffectEditorScaleInput:SetProperty("Text", conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z)
        self.scale = conf.scale.x .. "#" .. conf.scale.y .. "#" .. conf.scale.z
      end
      if conf.rotation then
        self.editPartRegionEffectEditorYawInput:SetProperty("Text", conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z)
        self.rotate = conf.rotation.x .. "#" .. conf.rotation.y .. "#" .. conf.rotation.z
      end
    end
  else
    self.txtPartRegionEffectEditorPartId:SetText("")
    self.txtPartRegionEffectEditorPartIdName:SetText("")
    self.editPartRegionEffectEditorEffectInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorPosInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorScaleInput:SetProperty("Text", "")
    self.editPartRegionEffectEditorYawInput:SetProperty("Text", "")
  end
  self.editPartRegionEffectEditorDelInput:SetProperty("Text", "")
end

function WinPartRegionEffectEditor:setConfigData(index, value)
  local param1 = self.editPartRegionEffectEditorEffectInput:GetPropertyString("Text", "")
  local param2 = self.editPartRegionEffectEditorPosInput:GetPropertyString("Text", "")
  local param3 = self.editPartRegionEffectEditorScaleInput:GetPropertyString("Text", "")
  local param4 = self.editPartRegionEffectEditorYawInput:GetPropertyString("Text", "")
  if index == 1 then
    self.effect = value
    param1 = value
  elseif index == 2 then
    self.posOffset = value
    param2 = value
  elseif index == 3 then
    self.scale = value
    param3 = value
  elseif index == 4 then
    param4 = value
    self.rotate = value
  end
  if param3 == "" then
    param3 = "1#1#1"
    self.scale = param3
  end
  if param4 == "" then
    param4 = "0#0#0"
    self.rotate = param4
  end
  local posArr = Lib.splitString(param2 or "", "#", true)
  local pos = Lib.v3(posArr[1] or 0, posArr[2] or 0, posArr[3] or 0)
  if self.curSelectPart and self.curSelectPart:isValid() then
    self.posOffset = pos.x .. "#" .. pos.y .. "#" .. pos.z
    param2 = self.posOffset
    local partPos = self.curSelectPart:getPosition()
    pos = Lib.v3(partPos.x + pos.x, pos.y + partPos.y, pos.z + partPos.z)
  else
    if param2 == "" then
      local mePos = Me:getPosition()
      pos = Lib.v3(mePos.x, mePos.y, mePos.z)
    end
    self.posOffset = pos.x .. "#" .. pos.y .. "#" .. pos.z
    param2 = self.posOffset
  end
  self.editPartRegionEffectEditorEffectInput:SetProperty("Text", tostring(param1))
  self.editPartRegionEffectEditorPosInput:SetProperty("Text", tostring(param2))
  self.editPartRegionEffectEditorScaleInput:SetProperty("Text", tostring(param3))
  self.editPartRegionEffectEditorYawInput:SetProperty("Text", tostring(param4))
  self:showEffect(pos)
end

function WinPartRegionEffectEditor:onHide()
  UI:closeWnd("partRegionEffectEditor")
end

function WinPartRegionEffectEditor:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("partRegionEffectEditor")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPartRegionEffectEditor:onOpen()
  self:initView()
  self:subscribeEvent()
  self:initConfigDate()
end

function WinPartRegionEffectEditor:clearData()
  if not self.isSave then
    if self.lastEffectPos and self.effect ~= "" then
      Blockman.instance:delEffect(self.effect, self.lastEffectPos)
    end
    local index = RegionEffectsConfig:getCfgCount() + 1
    if self.tempViewEntity[index] and self.tempViewEntity[index]:isValid() then
      self.tempViewEntity[index]:destroy()
    end
  end
  self.curSelectPart = nil
  self.effect = ""
  self.posOffset = ""
  self.scale = ""
  self.rotate = ""
  self.lastEffectPos = nil
  self.isLockClickPart = false
  self.curDelDataId = nil
  self.isSave = false
  self.selectContainId = 1
  self.lytPartRegionEffectEditorPartList:SetVisible(false)
  self.editPartRegionEffectEditorDelInput:SetProperty("Text", "")
  self.txtPartRegionEffectEditorPartId:SetText("")
  self.txtPartRegionEffectEditorPartIdName:SetText("")
  self.editPartRegionEffectEditorEffectInput:SetProperty("Text", "")
  self.editPartRegionEffectEditorPosInput:SetProperty("Text", "")
  self.editPartRegionEffectEditorScaleInput:SetProperty("Text", "")
  self.editPartRegionEffectEditorYawInput:SetProperty("Text", "")
end

function WinPartRegionEffectEditor:onClose()
  for i, tempEntity in pairs(self.tempViewEntity) do
    if tempEntity and tempEntity:isValid() then
      tempEntity:destroy()
    end
  end
  for i, effectNode in pairs(self.curAllEffect) do
    if effectNode then
      local sceneManager = World.CurWorld:getSceneManager()
      local curScene = sceneManager:getOrCreateScene(Player.CurPlayer.map.obj)
      curScene:getRoot():removeChild(effectNode)
      effectNode:destroy()
    end
  end
  self.curAllEffect = {}
  self.tempViewEntity = {}
  self.curDelDataId = nil
  self:clearData()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPartRegionEffectEditor
