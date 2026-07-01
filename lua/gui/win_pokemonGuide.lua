local PokemonGuideConfig = T(Config, "PokemonGuideConfig")

function M:init()
  WinBase.init(self, "PokemonGuide.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.cfg = nil
  self.index = 1
  self.dialogWidgetLis = {}
  self.cancelMaskTouch = {}
  self.dialogWidgetList = {}
  self.rewardWidgetList = {}
end

function M:initWnd()
  self.ivMaskTop = self:child("PokemonGuide-Mask-Top")
  self.ivMaskBottom = self:child("PokemonGuide-Mask-Bottom")
  self.ivMaskLeft = self:child("PokemonGuide-Mask-Left")
  self.ivMaskRight = self:child("PokemonGuide-Mask-Right")
  self.ivMaskTop2 = self:child("PokemonGuide-Mask-Top2")
  self.ivMaskBottom2 = self:child("PokemonGuide-Mask-Bottom2")
  self.ivMaskCenter = self:child("PokemonGuide-Mask-Center")
  self.ivArrows = self:child("PokemonGuide-Arrows")
  self.ivArrows2 = self:child("PokemonGuide-Arrows2")
  self.btnSkip = self:child("PokemonGuide-Skip")
  self.llMaskContent = self:child("PokemonGuide-Mask-Comtent")
  self.llDetailContent = self:child("PokemonGuide-Detail-Content")
  self.btnSkip:SetVisible(false)
  self.tsSkipTxt = self:child("PokemonGuide-Skip-Txt")
  self:updateSkipTxt()
  self:setMaskColor({
    0,
    0,
    0,
    0.5
  })
end

function M:updateSkipTxt()
  self.tsSkipTxt:SetText(Lang:toText(self.llMaskContent:IsVisible() and "gui_skip_guide_btn" or "gui_lang_tip_title"))
end

function M:initEvent()
  self:subscribe(self.btnSkip, UIEvent.EventButtonClick, function()
  end)
  self.cancelMaskTouch[1] = self:subscribe(self.ivMaskTop, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[2] = self:subscribe(self.ivMaskBottom, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[3] = self:subscribe(self.ivMaskLeft, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[4] = self:subscribe(self.ivMaskRight, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[5] = self:subscribe(self.ivMaskTop2, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[6] = self:subscribe(self.ivMaskBottom2, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
  self.cancelMaskTouch[7] = self:subscribe(self.ivMaskCenter, UIEvent.EventWindowClick, function()
    self:maskTouch()
  end)
end

function M:maskTouch()
  if self.cfg ~= nil then
    if self.ivArrows:IsVisible() then
      self.ivArrows:SetEffectName("g2033_ui_yindao_guangquan.effect")
    end
    if self.ivArrows2:IsVisible() then
      self.ivArrows2:SetEffectName("g2033_ui_yindao_guangquan.effect")
    end
    if self.forceFingerTimer then
      self.forceFingerTimer()
    end
    self.forceFingerTimer = World.Timer(20, function()
      if self.cfg and self.cfg.arrows_img_1 and self.ivArrows:IsVisible() then
        self.ivArrows:SetEffectName(self.cfg.arrows_img_1)
      end
      if self.cfg and self.cfg.arrows_img_2 and self.ivArrows2:IsVisible() then
        self.ivArrows2:SetEffectName(self.cfg.arrows_img_2)
      end
    end)
  end
end

function M:setMaskColor(bgColor)
  self.ivMaskTop:SetBackgroundColor(bgColor)
  self.ivMaskBottom:SetBackgroundColor(bgColor)
  self.ivMaskLeft:SetBackgroundColor(bgColor)
  self.ivMaskRight:SetBackgroundColor(bgColor)
  self.ivMaskTop2:SetBackgroundColor(bgColor)
  self.ivMaskBottom2:SetBackgroundColor(bgColor)
  self.ivMaskCenter:SetBackgroundColor(bgColor)
end

function M:onShow(show, index)
  if show then
    Lib.logDebug("show guide index = ", index)
    self.cfg = PokemonGuideConfig:getGuideData(index)
    Lib.logDebug("self.cfg = ", Lib.v2s(self.cfg))
    if not self.cfg then
      self:hide()
      return
    end
    self:doOpen(index)
  else
    self:hide()
    Me:delGuideTarget()
    UI:closeWnd("pokemonGuide")
  end
end

function M:doOpen(index)
  UI:openWnd("pokemonGuide", true)
  if self.index ~= (index or 1) then
    for _, dialog in pairs(self.dialogWidgetList) do
      self:root():RemoveChildWindow1(dialog)
    end
    self.dialogWidgetList = {}
    for _, dialog in pairs(self.rewardWidgetList) do
      local parent = dialog:GetParent()
      if parent then
        parent:RemoveChildWindow1(dialog)
      end
    end
    self.rewardWidgetList = {}
  end
  self.index = index or 1
  self:show(true)
  self:onShowDetail()
end

function M:onShowDetail()
  local descList = Lib.split(self.cfg.desc, "#")
  local titleList = Lib.split(self.cfg.title, "#")
  if self.cfg.dialog_pos ~= "0" then
    local posList = Lib.split(self.cfg.dialog_pos, ",")
    for i, desc in pairs(descList) do
      local data = Lib.split(posList[i], "#")
      local pos = data and {
        tonumber(data[2] or "0"),
        tonumber(data[3] or "0"),
        tonumber(data[5] or "0"),
        tonumber(data[6] or "0")
      } or {
        0,
        0,
        0,
        0
      }
      local size = data and {
        tonumber(data[7] or "360"),
        tonumber(data[8] or "146")
      } or {360, 146}
      local alig = data and {
        tonumber(data[1] or "0"),
        tonumber(data[4] or "0")
      } or {0, 0}
      local dialog = UIMgr:new_widget("guideTipsDialog"):invoke("initView", titleList[i] or titleList[1], desc, pos, size, alig, self._root)
      table.insert(self.dialogWidgetList, dialog)
    end
  end
  if self.cfg.reward_index == 1 then
    local reward_title = self.cfg.reward_title
    local reward_desc = self.cfg.reward_desc
    if self.cfg.reward_pos ~= "" then
      local data = Lib.split(self.cfg.reward_pos, "#")
      local pos = data and {
        tonumber(data[2] or "0"),
        tonumber(data[3] or "0"),
        tonumber(data[5] or "0"),
        tonumber(data[6] or "0")
      } or {
        0,
        0,
        0,
        0
      }
      local size = data and {
        tonumber(data[7] or "360"),
        tonumber(data[8] or "146")
      } or {360, 146}
      local alig = data and {
        tonumber(data[1] or "0"),
        tonumber(data[4] or "0")
      } or {0, 0}
      local dialog = UIMgr:new_widget("guideRewardDialog"):invoke("initView", self.cfg.reward_title, self.cfg.reward_desc, pos, size, alig, self.cfg.reward_items, UI:getWnd("pokemonMain"):root())
      table.insert(self.rewardWidgetList, dialog)
    end
  elseif self.cfg.reward_index == 2 then
    Lib.logDebug("open guide complete")
    Lib.logDebug("self.cfg.reward_details = ", self.cfg.reward_details)
    UI:getWnd("pokemonGuideComplete"):onShow(self.cfg.reward_details, self.cfg.reward_items)
  end
  local scenePosList = Lib.split(self.cfg.scene_pos, "#")
  if #scenePosList == 3 then
    Me:setGuideTarget(Lib.v3(tonumber(scenePosList[1]), tonumber(scenePosList[2]), tonumber(scenePosList[3])), "plugin/myplugin/image/pkm_guide_arrow.png", 0.035)
  else
    Me:delGuideTarget()
  end
  self:setUiArea()
end

function M:setUiArea()
  Lib.logDebug("setUiArea")
  Lib.logDebug("self.cfg.lucency_area_1 = ", self.cfg.lucency_area_1)
  Lib.logDebug("self.cfg.lucency_area_2 = ", self.cfg.lucency_area_2)
  local ui1 = UI:findChild(self.cfg.lucency_area_1)
  local ui2 = UI:findChild(self.cfg.lucency_area_2)
  Lib.logDebug("ui1 = ", ui1)
  Lib.logDebug("ui2 = ", ui2)
  local area1 = ui1 and ui1:GetUnclippedOuterRect() or nil
  local area2 = ui2 and ui2:GetUnclippedOuterRect() or nil
  local arrowsArea = self:getLucencyAreaByString(self.cfg.arrows_area_1, area1)
  local arrowsArea2 = self:getLucencyAreaByString(self.cfg.arrows_area_2, area2)
  local lucArea1 = self:getPosInfoByUI(area1, self.cfg.lucency_area_1)
  local lucArea2 = self:getPosInfoByUI(area2, self.cfg.lucency_area_2)
  if lucArea1 == nil or lucArea2 == nil then
    return
  end
  if arrowsArea then
    self.ivArrows:SetVisible(true)
    self.ivArrows:SetArea({
      arrowsArea.pos_x_1,
      arrowsArea.pos_x_2
    }, {
      arrowsArea.pos_y_1,
      arrowsArea.pos_y_2
    }, {
      arrowsArea.size_x_1,
      arrowsArea.size_x_2
    }, {
      arrowsArea.size_y_1,
      arrowsArea.size_y_2
    })
    self.ivArrows:SetEffectName(self.cfg.arrows_img_1)
  else
    self.ivArrows:SetVisible(false)
  end
  if arrowsArea2 then
    self.ivArrows2:SetVisible(true)
    self.ivArrows2:SetArea({
      arrowsArea2.pos_x_1,
      arrowsArea2.pos_x_2
    }, {
      arrowsArea2.pos_y_1,
      arrowsArea2.pos_y_2
    }, {
      arrowsArea2.size_x_1,
      arrowsArea2.size_x_2
    }, {
      arrowsArea2.size_y_1,
      arrowsArea2.size_y_2
    })
    self.ivArrows2:SetEffectName(self.cfg.arrows_img_2)
  else
    self.ivArrows2:SetVisible(false)
  end
  self.ivMaskTop:SetArea({
    lucArea1.pos_x_1,
    lucArea1.pos_x_2
  }, {0, 0}, {
    lucArea1.size_x_1,
    lucArea1.size_x_2
  }, {
    lucArea1.pos_y_1,
    lucArea1.pos_y_2
  })
  self.ivMaskBottom:SetArea({
    lucArea1.pos_x_1,
    lucArea1.pos_x_2
  }, {
    lucArea1.pos_y_1 + lucArea1.size_y_1,
    lucArea1.pos_y_2 + lucArea1.size_y_2
  }, {
    lucArea1.size_x_1,
    lucArea1.size_x_2
  }, {
    1 - lucArea1.pos_y_1 - lucArea1.size_y_1,
    -lucArea1.pos_y_2 - lucArea1.size_y_2
  })
  self.ivMaskLeft:SetArea({0, 0}, {0, 0}, {
    lucArea1.pos_x_1,
    lucArea1.pos_x_2
  }, {1, 0})
  if tonumber(self.cfg.show_lucency_area_2) == 1 then
    self.ivMaskTop2:SetVisible(true)
    self.ivMaskBottom2:SetVisible(true)
    self.ivMaskCenter:SetVisible(true)
    self.ivMaskTop2:SetArea({
      lucArea2.pos_x_1,
      lucArea2.pos_x_2
    }, {0, 0}, {
      lucArea2.size_x_1,
      lucArea2.size_x_2
    }, {
      lucArea2.pos_y_1,
      lucArea2.pos_y_2
    })
    self.ivMaskBottom2:SetArea({
      lucArea2.pos_x_1,
      lucArea2.pos_x_2
    }, {
      lucArea2.pos_y_1 + lucArea2.size_y_1,
      lucArea2.pos_y_2 + lucArea2.size_y_2
    }, {
      lucArea2.size_x_1,
      lucArea2.size_x_2
    }, {
      1 - lucArea2.pos_y_1 - lucArea2.size_y_1,
      -lucArea2.pos_y_2 - lucArea2.size_y_2
    })
    self.ivMaskCenter:SetArea({
      lucArea1.pos_x_1 + lucArea1.size_x_1,
      lucArea1.pos_x_2 + lucArea1.size_x_2
    }, {0, 0}, {
      lucArea2.pos_x_1 - lucArea1.pos_x_1 - lucArea1.size_x_1,
      lucArea2.pos_x_2 - lucArea1.pos_x_2 - lucArea1.size_x_2
    }, {1, 0})
    self.ivMaskRight:SetArea({
      lucArea2.pos_x_1 + lucArea2.size_x_1,
      lucArea2.pos_x_2 + lucArea2.size_x_2
    }, {0, 0}, {
      1 - lucArea2.pos_x_1 - lucArea2.size_x_1,
      -lucArea2.pos_x_2 - lucArea2.size_x_2
    }, {1, 0})
  else
    self.ivArrows2:SetVisible(false)
    self.ivMaskTop2:SetVisible(false)
    self.ivMaskBottom2:SetVisible(false)
    self.ivMaskCenter:SetVisible(false)
    self.ivMaskRight:SetArea({
      lucArea1.pos_x_1 + lucArea1.size_x_1,
      lucArea1.pos_x_2 + lucArea1.size_x_2
    }, {0, 0}, {
      1 - lucArea1.pos_x_1 - lucArea1.size_x_1,
      -lucArea1.pos_x_2 - lucArea1.size_x_2
    }, {1, 0})
  end
  self:setMaskColor(self.cfg.trans_mask and {
    0,
    0,
    0,
    0
  } or {
    0,
    0,
    0,
    0.5
  })
end

function M:getPosInfoByUI(area, info)
  local data = {}
  if area then
    data.pos_x_1 = 0
    data.pos_x_2 = area[1]
    data.pos_y_1 = 0
    data.pos_y_2 = area[2]
    data.size_x_1 = 0
    data.size_x_2 = area[3] - area[1]
    data.size_y_1 = 0
    data.size_y_2 = area[4] - area[2]
  else
    data.pos_x_1 = 0
    data.pos_x_2 = 0
    data.pos_y_1 = 0
    data.pos_y_2 = 0
    data.size_x_1 = info == "none" and 1 or 0
    data.size_x_2 = 0
    data.size_y_1 = info == "none" and 1 or 0
    data.size_y_2 = 0
  end
  return data
end

function M:getLucencyAreaByString(arrow_area, ui_area)
  local area = Lib.split(arrow_area, "#")
  if #area < 8 then
    return nil
  end
  Lib.logDebug("ui_area = ", Lib.v2s(ui_area))
  if not ui_area then
    return nil
  end
  local data = {}
  data.pos_x_1 = ui_area and 0 or tonumber(area[1])
  data.pos_x_2 = ui_area and (ui_area[1] + ui_area[3]) / 2 or tonumber(area[2])
  data.pos_y_1 = ui_area and 0 or tonumber(area[3])
  data.pos_y_2 = ui_area and ui_area[2] or ui_area(area[4])
  data.size_x_1 = tonumber(area[5])
  data.size_x_2 = tonumber(area[6])
  data.size_y_1 = tonumber(area[7])
  data.size_y_2 = tonumber(area[8])
  return data
end

function M:onOpen()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
  UI:getWnd("pokemon_recharge_award"):onShow(false)
  UI:getWnd("pokemonGiftBag"):onShow(false)
  UI:getWnd("pokemonRegularGift"):onShow(false)
end

function M:onClose()
  for _, dialog in pairs(self.dialogWidgetList) do
    self:root():RemoveChildWindow1(dialog)
  end
  for _, dialog in pairs(self.rewardWidgetList) do
    local parent = dialog:GetParent()
    if parent then
      parent:RemoveChildWindow1(dialog)
    end
  end
  self.cfg = nil
  self.index = 1
  self.dialogWidgetLis = {}
  self.cancelMaskTouch = {}
  self.dialogWidgetList = {}
  self.rewardWidgetList = {}
end

function M:onDestroy()
end

return M
