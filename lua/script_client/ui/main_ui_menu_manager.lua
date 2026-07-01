local MainUIMenuManage = T(UIMgr, "MainUIMenuManage")
local MainUiMenuBtnConfig = T(Config, "MainUiMenuBtnConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local initMenuBtnSizeDis = {
  {
    84,
    84,
    15
  },
  {
    84,
    84,
    15
  },
  {
    46,
    46,
    10
  }
}

function MainUIMenuManage:init()
  self.menuBtnRoot = {}
  self.menuBtnList = {}
  self.initMenuSize = {}
end

function MainUIMenuManage:initOneShowTypeMenu(showType, parentNode, posX, posY)
  self.menuBtnRoot[showType] = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "menuBtnRoot" .. showType)
  self.menuBtnRoot[showType]:SetImage("")
  if showType == Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU then
    self.menuBtnRoot[showType]:SetVerticalAlignment(0)
    self.menuBtnRoot[showType]:SetHorizontalAlignment(2)
  elseif showType == Define.Menu_BTN_SHOW_TYPE.BOTTOM_RIGHT_MENU then
    self.menuBtnRoot[showType]:SetVerticalAlignment(2)
    self.menuBtnRoot[showType]:SetHorizontalAlignment(2)
  elseif showType == Define.Menu_BTN_SHOW_TYPE.TOP_LEFT_MENU then
    self.menuBtnRoot[showType]:SetVerticalAlignment(0)
    self.menuBtnRoot[showType]:SetHorizontalAlignment(0)
  end
  self.menuBtnRoot[showType]:SetArea({
    0,
    posX or 0
  }, {
    0,
    posY or 0
  }, {0, 1}, {0, 1})
  self.menuBtnRoot[showType]:SetTouchable(false)
  parentNode:AddChildWindow(self.menuBtnRoot[showType])
  self:initMenuBtnList(showType)
end

function MainUIMenuManage:updateOneShowTypeMenuPos(showType, posX, posY)
  if self.menuBtnRoot[showType] then
    self.menuBtnRoot[showType]:SetArea({
      0,
      posX or 0
    }, {
      0,
      posY or 0
    }, {0, 1}, {0, 1})
  end
end

function MainUIMenuManage:initMenuBtnList(showType)
  if not self.menuBtnList[showType] then
    self.menuBtnList[showType] = {}
  end
  local topRightCfg = MainUiMenuBtnConfig:getAllCfgByShowType(showType)
  for _, val in pairs(topRightCfg) do
    local btnNode = UIMgr:new_widget("pokemonMainMenu")
    if showType == Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU then
      btnNode:invoke("SetVerticalAlignment", 0)
      btnNode:invoke("SetHorizontalAlignment", 2)
    elseif showType == Define.Menu_BTN_SHOW_TYPE.BOTTOM_RIGHT_MENU then
      btnNode:invoke("SetVerticalAlignment", 2)
      btnNode:invoke("SetHorizontalAlignment", 2)
    elseif showType == Define.Menu_BTN_SHOW_TYPE.TOP_LEFT_MENU then
      btnNode:invoke("SetVerticalAlignment", 0)
      btnNode:invoke("SetHorizontalAlignment", 0)
    end
    btnNode:invoke("initBtnData", val)
    self.menuBtnRoot[showType]:AddChildWindow(btnNode, val.button_name)
    if not self.menuBtnList[showType][val.line_num] then
      self.menuBtnList[showType][val.line_num] = {}
    end
    if not self.initMenuSize[showType] then
      self.initMenuSize[showType] = {
        val.button_size[1] or initMenuBtnSizeDis[showType][1],
        val.button_size[2] or initMenuBtnSizeDis[showType][2],
        val.button_size[3] or initMenuBtnSizeDis[showType][3]
      }
    end
    local temp = {
      isVisible = false,
      btnNode = btnNode,
      priority = val.priority,
      line_num = val.line_num,
      id = val.id,
      button_name = val.button_name,
      btnWidth = val.button_size[1],
      btnHeight = val.button_size[2],
      btnDistance = val.button_size[3],
      colorState = "NORMAL"
    }
    btnNode:invoke("SetVisible", temp.isVisible)
    table.insert(self.menuBtnList[showType][val.line_num], temp)
  end
  self:updateMenuBtnPosShow(showType)
end

function MainUIMenuManage:updateMenuBtnPosShow(showType)
  for lineNum, list in pairs(self.menuBtnList[showType]) do
    table.sort(self.menuBtnList[showType][lineNum], function(a, b)
      return tonumber(a.priority) < tonumber(b.priority)
    end)
  end
  local addOrSubX = 1
  local addOrSubY = 1
  if showType == Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU then
    addOrSubX = -1
    addOrSubY = 1
  elseif showType == Define.Menu_BTN_SHOW_TYPE.BOTTOM_RIGHT_MENU then
    addOrSubX = -1
    addOrSubY = -1
  elseif showType == Define.Menu_BTN_SHOW_TYPE.TOP_LEFT_MENU then
    addOrSubX = 1
    addOrSubY = 1
  end
  local ratio = UIMgr.UIShowManage:getAdapterRatio()
  for lineNum, list in pairs(self.menuBtnList[showType]) do
    local curPosX = 0
    local curPosY = (lineNum - 1) * (self.initMenuSize[showType][2] + self.initMenuSize[showType][3])
    for k = 1, #list do
      if list[k].isVisible then
        list[k].btnNode:invoke("SetMenuBtnSize", list[k].btnWidth, list[k].btnHeight)
        list[k].btnNode:invoke("SetXPosition", {
          0,
          curPosX * addOrSubX * ratio
        })
        list[k].btnNode:invoke("SetYPosition", {
          0,
          curPosY * addOrSubY * ratio
        })
        curPosX = curPosX + self.initMenuSize[showType][1] + self.initMenuSize[showType][3]
      end
      list[k].btnNode:invoke("SetVisible", list[k].isVisible)
    end
  end
end

function MainUIMenuManage:setMenuBtnVisible(buttonName, visible, notUpdatePos)
  for showType, _ in pairs(self.menuBtnList) do
    local curType
    for lineNum, list in pairs(self.menuBtnList[showType]) do
      for k = 1, #list do
        if self.menuBtnList[showType][lineNum][k].button_name == buttonName then
          curType = showType
          self.menuBtnList[showType][lineNum][k].isVisible = visible
          self.menuBtnList[showType][lineNum][k].btnNode:invoke("SetVisible", visible)
        end
      end
    end
    if curType and not notUpdatePos then
      self:updateMenuBtnPosShow(curType)
    end
  end
end

function MainUIMenuManage:getMenuBtnByName(buttonName)
  for showType, _ in pairs(self.menuBtnList) do
    for lineNum, list in pairs(self.menuBtnList[showType]) do
      for k = 1, #list do
        if self.menuBtnList[showType][lineNum][k].button_name == buttonName then
          return self.menuBtnList[showType][lineNum][k].btnNode:invoke("getMenuBtnRoot")
        end
      end
    end
  end
  return nil
end

function MainUIMenuManage:setMenuBtnColorProgram(buttonName, colorState)
  for showType, _ in pairs(self.menuBtnList) do
    local curType
    for lineNum, list in pairs(self.menuBtnList[showType]) do
      for k = 1, #list do
        if self.menuBtnList[showType][lineNum][k].button_name == buttonName then
          self.menuBtnList[showType][lineNum][k].colorState = colorState
          self.menuBtnList[showType][lineNum][k].btnNode:invoke("setMenuBtnColorProgram", colorState)
        end
      end
    end
  end
end

function MainUIMenuManage:getMenuBtnColorProgram(buttonName)
  for showType, _ in pairs(self.menuBtnList) do
    local curType
    for lineNum, list in pairs(self.menuBtnList[showType]) do
      for k = 1, #list do
        if self.menuBtnList[showType][lineNum][k].button_name == buttonName then
          return self.menuBtnList[showType][lineNum][k].colorState
        end
      end
    end
  end
  return ""
end

function MainUIMenuManage.LuckyEggCallFunc()
  Me:gameBehaviorReport("egg_open", 1)
  if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY then
    Me:gotoNextGuide()
  else
    UI:getWnd("pokemonLuckyEgg"):onShow(true)
  end
end

function MainUIMenuManage.DailyLotteryCallFunc()
  UI:openWnd("dailyLottery")
  Me:gameBehaviorReport("LukeyPan_open", 1)
  UIRedDotMgr.isOpenedDailyLottery = true
  UIRedDotMgr:updateDailyLotteryRedShow()
end

function MainUIMenuManage.RechargeGiftCallFunc()
  UI:getWnd("pokemon_recharge_award"):onShow(true)
  Me:gameBehaviorReport("firstRecharge_open", 1)
end

function MainUIMenuManage.RegularGiftCallFunc()
  UI:getWnd("pokemonRegularGift"):onShow(true)
  Me:gameBehaviorReport("RegularGift_open", 1)
end

function MainUIMenuManage.ActivityCallFunc()
  UIRedDotMgr.isOpenedDailyTask = true
  UI:getWnd("pokemonTask"):onShow()
end

function MainUIMenuManage.PetCallFunc()
  Me:gameBehaviorReport("ui", "pet")
  UI:getWnd("pokemonPacket"):onShow("packet")
end

function MainUIMenuManage.BookCallFunc()
  Me:gameBehaviorReport("ui", "collection")
  UI:openWnd("petsBook")
end

function MainUIMenuManage.BagCallFunc()
  Me:gameBehaviorReport("ui", "backpack")
  UI:getWnd("pokemonBag"):onShow(true, Define.SCENE_TYPE.NOT_BATTLE)
end

function MainUIMenuManage.TeamCallFunc()
  Me:gameBehaviorReport("ui", "queue")
  if not Me:isGuideFinish() then
    local cur_guide_index = Me:getCurGuideIndex()
    if cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_OPEN_PACKET or cur_guide_index == Define.GUIDE_INDEX.FILL_POKEMON_OPEN_PACKET or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_PACKET then
      Me:gotoNextGuide()
    else
      UI:getWnd("pokemonPacket"):onShow("battle")
    end
  else
    UI:getWnd("pokemonPacket"):onShow("battle")
  end
end

function MainUIMenuManage.LeaderboardCallFunc()
  Lib.logDebug("open leaderboard")
  UI:getWnd("pokemonLeaderboard"):onShow(true)
end

function MainUIMenuManage.RefineCallFunc()
  Me:gameBehaviorReport("ui", "candy")
  if Me:isInPreBattleOrBattle() then
    return
  end
  UI:openWnd("pokemonBlessing")
end

function MainUIMenuManage.SynthesisCallFunc()
  Me:gameBehaviorReport("ui", "fuse")
end

function MainUIMenuManage:GloryHallCallFunc(buttonName)
  if self:getMenuBtnColorProgram(buttonName) == "GRAY" then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "main_tip_glory_hall_limit"
    }, function()
    end)
  elseif self:getMenuBtnColorProgram(buttonName) == "NORMAL" then
    UI:getWnd("pokemonGloryHall"):onShow(true)
  end
end

function MainUIMenuManage.RotaryTableCallFunc()
  UI:getWnd("pokemonRotaryTable"):onShow(true)
  Me:gameBehaviorReport("LuckyWheel_btn", 1)
end

function MainUIMenuManage:LimitTimeCombinedFunc(buttonName)
  Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeCombinedWnd")
end

function MainUIMenuManage:LimitTimeSignalFunc(buttonName)
  Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeSignalWnd")
end

function MainUIMenuManage:LimitTimeActivityFunc(buttonName)
  Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeActivityWnd")
end
