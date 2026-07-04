local widget_base = require("ui.widget.widget_base")
local WidgetModMapPostAuthorWords = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModMapPostAuthorWords:init()
  widget_base.init(self, "ModMapPostAuthorWords.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMapPostAuthorWords:initUI()
  self.txtWords = self:child("ModMapPostAuthorWords-Words")
end

function WidgetModMapPostAuthorWords:initEvent()
end

local SPACE_X = 2
local SPACE_Y = 1
local WordSaveKey = {
  TOPIC = "authorWordTopicItems",
  AT = "authorWordATItems"
}
local WordCB = {
  [WordSaveKey.TOPIC] = function(self, index)
    Lib.logDebug("--------WordSaveKey.TOPIC cb-------- : " .. index)
    if not self.tagList or not self.tagList[index] then
      return
    end
    Lib.emitEvent(Event.EVENT_MOD_JUMP_TO_SEARCH, self.tagList[index])
    UI:closeWnd("modMapInfo")
  end,
  [WordSaveKey.AT] = function(self, index)
    Lib.logDebug("--------WordSaveKey.AT cb-------- : " .. index)
    if self.atUserList then
      local item = self.atUserList[index]
      ModAsyncProxy:requestOpenAuthorInfoUI(item.userId)
    end
  end
}

local function CaleDynaWord(self, pos, data, saveKey, standardWidth, nextLine)
  local travel = {
    pos = pos,
    spaceX = SPACE_X,
    spaceY = SPACE_Y,
    standardWidth = standardWidth
  }
  self[saveKey] = {}
  for _, info in pairs(data) do
    local top = #self[saveKey] + 1
    local widget = UIMgr:new_widget("modMapWordItem")
    self:root():AddChildWindow(widget)
    travel.str = info
    
    function travel.cb()
      WordCB[saveKey](self, top)
    end
    
    widget:invoke("reload", travel)
    self[saveKey][top] = widget
  end
  if nextLine and 0 < #self[saveKey] then
    local h = self[saveKey][1]:GetHeight()[2]
    pos.y = pos.y + h + SPACE_Y
  end
  return pos.y
end

function WidgetModMapPostAuthorWords:reload(params)
  if params.gameDetail then
    self.txtWords:SetText(params.gameDetail)
  end
  if params.WordsInfo then
    self.atUserList = params.WordsInfo.gameDetailUserList or {}
    self.atUserIdList = params.WordsInfo.gameDetailUserIdList or {}
    self.tagList = params.WordsInfo.gameDetailTagList or {}
    local standardWidth = self:root():GetWidth()[2]
    local standardHeight = self:root():GetHeight()[2]
    local wordsHigh = self.txtWords:GetFont():GetFontHeight()
    local lineNum = Lib.getTextLineNum(params.gameDetail, self.txtWords, standardWidth)
    local extraLine = lineNum - 1
    local extraHigh = extraLine * wordsHigh
    local wordsOriHigh = self.txtWords:GetHeight()[2]
    self.txtWords:SetHeight({
      0,
      wordsOriHigh + extraHigh
    })
    local highSum = extraHigh + wordsHigh + SPACE_Y
    local topics = {}
    for i = 1, #self.tagList do
      local topic = "#" .. self.tagList[i]
      table.insert(topics, topic)
    end
    highSum = CaleDynaWord(self, {x = 0, y = highSum}, topics, WordSaveKey.TOPIC, standardWidth, true)
    local friends = {}
    for i = 1, #self.atUserList do
      local friend = "@" .. self.atUserList[i].name or ""
      table.insert(friends, friend)
    end
    highSum = CaleDynaWord(self, {x = 0, y = highSum}, friends, WordSaveKey.AT, standardWidth, true)
    self:root():SetHeight({
      0,
      math.max(standardHeight, highSum)
    })
  end
end

function WidgetModMapPostAuthorWords:release()
  Lib.log("------------WidgetModMapPostAuthorWords:release")
  for _, saveKey in pairs(WordSaveKey) do
    for _, widget in pairs(self[saveKey] or {}) do
      GUIWindowManager.instance:DestroyGUIWindow(widget)
    end
    self[saveKey] = {}
  end
end

return WidgetModMapPostAuthorWords
