local WinG2052AdvertisementMain = M
local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local AdvertisementPoolConfig = T(Config, "AdvertisementPoolConfig")
local LuaTimer = T(Lib, "LuaTimer")

function WinG2052AdvertisementMain:init()
  WinBase.init(self, "G2052AdvertisementMain.json")
  self._allEvent = {}
  self.slots = {}
  self.drawList = nil
  self.isPlaying = false
  self.rewardTimer = nil
  self.isWndValid = true
  self.isAllGain = false
  self.callbackPopReward = nil
  self:initUI()
  self:initEvent()
end

function WinG2052AdvertisementMain:initUI()
  self.lytAdvertisementMain = self:child("AdvertisementMain")
  self.imgAdvertisementMainImgMask = self:child("AdvertisementMain-ImgMask")
  self.lytAdvertisementMainContent = self:child("AdvertisementMain-Content")
  self.imgAdvertisementMainImgBg = self:child("AdvertisementMain-ImgBg")
  self.btnAdvertisementMainBtnClose = self:child("AdvertisementMain-BtnClose")
  self.txtAdvertisementMainTxtTitle = self:child("AdvertisementMain-TxtTitle")
  self.txtAdvertisementMainTxtTip = self:child("AdvertisementMain-TxtTip")
  self.lytAdvertisementMainItem1 = self:child("AdvertisementMain-Item1")
  self.imgAdvertisementMainImgLockState1 = self:child("AdvertisementMain-ImgLockState1")
  self.imgAdvertisementMainImgVideo1 = self:child("AdvertisementMain-ImgVideo1")
  self.btnAdvertisementMainBtnWatch1 = self:child("AdvertisementMain-BtnWatch1")
  self.imgAdvertisementMainImgUnlockState1 = self:child("AdvertisementMain-ImgUnlockState1")
  self.imgAdvertisementMainImgItemIcon1 = self:child("AdvertisementMain-ImgItemIcon1")
  self.txtAdvertisementMainTxtItemCount1 = self:child("AdvertisementMain-TxtItemCount1")
  self.lytAdvertisementMainItem2 = self:child("AdvertisementMain-Item2")
  self.imgAdvertisementMainImgLockState2 = self:child("AdvertisementMain-ImgLockState2")
  self.imgAdvertisementMainImgVideo2 = self:child("AdvertisementMain-ImgVideo2")
  self.btnAdvertisementMainBtnWatch2 = self:child("AdvertisementMain-BtnWatch2")
  self.imgAdvertisementMainImgUnlockState2 = self:child("AdvertisementMain-ImgUnlockState2")
  self.imgAdvertisementMainImgItemIcon2 = self:child("AdvertisementMain-ImgItemIcon2")
  self.txtAdvertisementMainTxtItemCount2 = self:child("AdvertisementMain-TxtItemCount2")
  self.lytAdvertisementMainItem3 = self:child("AdvertisementMain-Item3")
  self.imgAdvertisementMainImgLockState3 = self:child("AdvertisementMain-ImgLockState3")
  self.imgAdvertisementMainImgVideo3 = self:child("AdvertisementMain-ImgVideo3")
  self.btnAdvertisementMainBtnWatch3 = self:child("AdvertisementMain-BtnWatch3")
  self.imgAdvertisementMainImgUnlockState3 = self:child("AdvertisementMain-ImgUnlockState3")
  self.imgAdvertisementMainImgItemIcon3 = self:child("AdvertisementMain-ImgItemIcon3")
  self.txtAdvertisementMainTxtItemCount3 = self:child("AdvertisementMain-TxtItemCount3")
  self.btnAdvertisementMainBtnRefresh = self:child("AdvertisementMain-BtnRefresh")
  self.txtAdvertisementMainTxtDrawCount = self:child("AdvertisementMain-TxtDrawCount")
  self.imgAdvertisementMainImgRefreshVideo = self:child("AdvertisementMain-ImgRefreshVideo")
  self.imgAdvertisementMainImgRefreshBg = self:child("AdvertisementMain-ImgRefreshBg")
  for i = 1, 3 do
    local imgLockState, imgUnlockState, imgItemIcon, txtItemCount, imgVideo
    if i == 1 then
      imgLockState = self.imgAdvertisementMainImgLockState1
      imgUnlockState = self.imgAdvertisementMainImgUnlockState1
      imgItemIcon = self.imgAdvertisementMainImgItemIcon1
      txtItemCount = self.txtAdvertisementMainTxtItemCount1
      imgVideo = self.imgAdvertisementMainImgVideo1
    elseif i == 2 then
      imgLockState = self.imgAdvertisementMainImgLockState2
      imgUnlockState = self.imgAdvertisementMainImgUnlockState2
      imgItemIcon = self.imgAdvertisementMainImgItemIcon2
      txtItemCount = self.txtAdvertisementMainTxtItemCount2
      imgVideo = self.imgAdvertisementMainImgVideo2
    elseif i == 3 then
      imgLockState = self.imgAdvertisementMainImgLockState3
      imgUnlockState = self.imgAdvertisementMainImgUnlockState3
      imgItemIcon = self.imgAdvertisementMainImgItemIcon3
      txtItemCount = self.txtAdvertisementMainTxtItemCount3
      imgVideo = self.imgAdvertisementMainImgVideo3
    end
    self.slots[#self.slots + 1] = {
      id = nil,
      index = i,
      isLock = false,
      imgItemIcon = imgItemIcon,
      txtItemCount = txtItemCount,
      imgLockState = imgLockState,
      imgUnlockState = imgUnlockState,
      imgVideo = imgVideo
    }
  end
end

function WinG2052AdvertisementMain:initEvent()
  self:subscribe(self.btnAdvertisementMainBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnAdvertisementMainBtnWatch1, UIEvent.EventButtonClick, function()
    if self.isPlaying or not self.isWndValid then
      return
    end
    if self.slots and self.slots[1] and self.slots[1].id then
      AdvertisementModuleHelper:doLockSlot(1, self.slots[1].id)
    end
  end)
  self:subscribe(self.btnAdvertisementMainBtnWatch2, UIEvent.EventButtonClick, function()
    if self.isPlaying or not self.isWndValid then
      return
    end
    if self.slots and self.slots[2] and self.slots[2].id then
      AdvertisementModuleHelper:doLockSlot(2, self.slots[2].id)
    end
  end)
  self:subscribe(self.btnAdvertisementMainBtnWatch3, UIEvent.EventButtonClick, function()
    if self.isPlaying or not self.isWndValid then
      return
    end
    if self.slots and self.slots[3] and self.slots[3].id then
      AdvertisementModuleHelper:doLockSlot(3, self.slots[3].id)
    end
  end)
  self:subscribe(self.btnAdvertisementMainBtnRefresh, UIEvent.EventButtonClick, function()
    if self.isPlaying or not self.isWndValid then
      return
    end
    AdvertisementModuleHelper:doDrawReward()
  end)
end

function WinG2052AdvertisementMain:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ADVERTISEMENT_MODULE_ON_DRAW_RESULT, function(stateCode, rewardIds)
    if not self.isWndValid then
      return
    end
    self:updateRefreshCount()
    if stateCode ~= 0 then
      if stateCode == 2 then
        self.isAllGain = true
        self.txtAdvertisementMainTxtTip:SetText(Lang:toText("g2052.gui.advertisement.win.content.reward.all.gain"))
      end
      return
    end
    if self.drawList and #self.drawList <= 1 then
      for i = 1, #rewardIds do
        local rewardCfg = AdvertisementPoolConfig:getCfgById(rewardIds[i])
        self:updateSlotData(i, rewardCfg, false, true)
      end
      UI:openWnd("g2052AdvertisementReward", rewardIds)
      return
    end
    if not self.rewardTimer then
      self.isPlaying = true
      
      function self.callbackPopReward()
        UI:openWnd("g2052AdvertisementReward", rewardIds)
      end
      
      local timer = 0
      local period = 200
      local duration = 3000
      local this = self
      local drawList = self.drawList
      local randList = {}
      
      local function intiRandList(tb)
        tb = tb or {}
        for i = 1, #drawList do
          tb[#tb + 1] = i
        end
        return tb
      end
      
      self.rewardTimer = LuaTimer:schedule(function()
        if timer >= duration or not this.isWndValid then
          this.isPlaying = false
          if this.rewardTimer then
            LuaTimer:cancel(this.rewardTimer)
            this.rewardTimer = nil
          end
          if this.isWndValid and this.slots then
            for i = 1, #rewardIds do
              local rewardCfg = AdvertisementPoolConfig:getCfgById(rewardIds[i])
              this:updateSlotData(i, rewardCfg, false, true)
            end
            if this.callbackPopReward then
              this.callbackPopReward()
              this.callbackPopReward = nil
            end
          end
          return
        end
        timer = timer + period
        local slots = this.slots
        if slots and 0 < #slots then
          for i = 1, #slots do
            local slot = slots[i]
            if not slot.isLock then
              local rewardCfg
              if not randList[i] or #randList[i] <= 0 then
                randList[i] = intiRandList(randList[i])
              end
              if #randList[i] == 1 then
                local id = randList[i][1]
                table.remove(randList[i], 1)
                rewardCfg = drawList[id]
              else
                local randIndex = math.random(1, #randList[i])
                local id = randList[i][randIndex]
                table.remove(randList[i], randIndex)
                rewardCfg = drawList[id]
              end
              this:updateSlotData(i, rewardCfg, false, false)
            end
          end
        end
      end, 0, period)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ADVERTISEMENT_MODULE_ON_LOCK_RESULT, function(stateCode, lockSlot, lockId)
    if stateCode ~= 0 then
      return
    end
    self:onLockSlotResult(lockSlot, lockId)
  end)
end

function WinG2052AdvertisementMain:onLockSlotResult(lockSlot, lockId)
  if not self.slots or not self.slots[lockSlot] then
    return
  end
  self.slots[lockSlot].id = lockId
  self.slots[lockSlot].isLock = true
  local isCanLockSlot = AdvertisementModuleHelper:checkCanLockSlot(Me)
  if isCanLockSlot then
    local rewardCfg = AdvertisementPoolConfig:getCfgById(lockId)
    self:updateSlotData(lockSlot, rewardCfg, true, isCanLockSlot)
  else
    local lockSlotData = Me:getLockSlotData()
    for i = 1, 3 do
      local rewardCfg
      if lockSlotData and lockSlotData[i] then
        local id = lockSlotData[i]
        rewardCfg = AdvertisementPoolConfig:getCfgById(id)
        self:updateSlotData(i, rewardCfg, true, isCanLockSlot)
      elseif self.slots and self.slots[i] and self.slots[i].id then
        local id = self.slots[i].id
        rewardCfg = AdvertisementPoolConfig:getCfgById(id)
        self:updateSlotData(i, rewardCfg, false, isCanLockSlot)
      else
        rewardCfg = nil
        self:updateSlotData(i, nil, false, isCanLockSlot)
      end
    end
  end
end

function WinG2052AdvertisementMain:updateRefreshCount()
  local drawCountData = Me:getDrawCountData()
  local drawCount = Define.ADVERTISEMENT_DAILY_DRAW_COUNT
  if drawCountData and drawCountData.count ~= nil then
    drawCount = drawCountData.count
  end
  local tip = Lang:toText("g2052.gui.advertisement.win.refresh.title") .. "(" .. tostring(drawCount) .. ")"
  self.txtAdvertisementMainTxtDrawCount:SetText(tip)
end

function WinG2052AdvertisementMain:initView()
  local drawList = AdvertisementModuleHelper:getDrawList(Me)
  if drawList and 0 < #drawList then
    self.isAllGain = false
  else
    self.isAllGain = true
    drawList = AdvertisementModuleHelper:getDrawList(Me, true)
  end
  self.drawList = drawList
  local rewardList
  local drawItemData = Me:getDrawItemData() or {}
  if drawItemData and 0 < #drawItemData then
    rewardList = {}
    for i = 1, #drawItemData do
      local id = drawItemData[i]
      local rewardCfg = AdvertisementPoolConfig:getCfgById(id)
      rewardList[#rewardList + 1] = rewardCfg
    end
  else
    rewardList = AdvertisementModuleHelper:drawReawrds(Me, drawList)
  end
  local lockSlotData = Me:getLockSlotData()
  local isCanLockSlot = AdvertisementModuleHelper:checkCanLockSlot(Me)
  for i = 1, 3 do
    local rewardCfg
    if lockSlotData and lockSlotData[i] then
      local id = lockSlotData[i]
      rewardCfg = AdvertisementPoolConfig:getCfgById(id)
      self:updateSlotData(i, rewardCfg, true, isCanLockSlot)
    elseif rewardList and rewardList[i] then
      rewardCfg = rewardList[i]
      self:updateSlotData(i, rewardCfg, false, isCanLockSlot)
    else
      local randIndex = math.random(1, #drawList)
      rewardCfg = drawList[randIndex] or drawList[1]
      self:updateSlotData(i, rewardCfg, false, isCanLockSlot)
    end
    if rewardCfg and rewardCfg.id then
      drawItemData[i] = rewardCfg.id
    end
  end
  Me:setDrawItemData(drawItemData)
  self:updateRefreshCount()
  self.txtAdvertisementMainTxtTitle:SetText(Lang:toText("g2052.gui.advertisement.win.title"))
  if not self.isAllGain then
    self.txtAdvertisementMainTxtTip:SetText(Lang:toText("g2052.gui.advertisement.win.content.normal"))
  else
    self.txtAdvertisementMainTxtTip:SetText(Lang:toText("g2052.gui.advertisement.win.content.reward.all.gain"))
  end
end

function WinG2052AdvertisementMain:updateSlotData(slotIndex, rewardConfig, isUnlock, isCanLockSlot)
  local slot = self.slots[slotIndex]
  slot.id = rewardConfig.id
  slot.isLock = isUnlock
  local itemCfg = Me:getBusinessItemCfg(rewardConfig.itemType, rewardConfig.itemId)
  local itemIcon = itemCfg and itemCfg.icon or nil
  local imgLockState = slot.imgLockState
  local imgUnlockState = slot.imgUnlockState
  local imgItemIcon = slot.imgItemIcon
  local txtItemCount = slot.txtItemCount
  local imgVideo = slot.imgVideo
  if imgLockState then
    imgLockState:SetVisible(not isUnlock)
  end
  if imgUnlockState then
    imgUnlockState:SetVisible(isUnlock)
  end
  if imgVideo and isCanLockSlot ~= nil then
    imgVideo:SetVisible(isCanLockSlot)
  end
  if imgItemIcon and itemIcon and itemIcon ~= "" then
    imgItemIcon:SetImage(itemIcon)
  end
  if txtItemCount then
    txtItemCount:SetText("x" .. tostring(rewardConfig.itemCount))
  end
end

function WinG2052AdvertisementMain:onHide()
  UI:closeWnd("g2052AdvertisementMain")
end

function WinG2052AdvertisementMain:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052AdvertisementMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052AdvertisementMain:onOpen()
  self.isPlaying = false
  self.isWndValid = true
  if self.rewardTimer then
    LuaTimer:cancel(self.rewardTimer)
    self.rewardTimer = nil
  end
  self:initView()
  self:subscribeEvent()
end

function WinG2052AdvertisementMain:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.rewardTimer then
    LuaTimer:cancel(self.rewardTimer)
    self.rewardTimer = nil
  end
  if self.callbackPopReward then
    self.callbackPopReward()
    self.callbackPopReward = nil
  end
  self.isPlaying = false
  self.isWndValid = false
  self.isAllGain = false
  self.drawList = nil
end

return WinG2052AdvertisementMain
