local startY = 0
local rangeHeight = 0

local function checkAreaIndex(dy)
  local itemHeight = rangeHeight / 4
  if dy < startY + itemHeight then
    return 1
  end
  if dy < startY + itemHeight * 2 then
    return 2
  end
  if dy < startY + itemHeight * 3 then
    return 3
  end
  return 4
end

function M:init()
  WinBase.init(self, "PokemonCellMove.json", false)
  self.cur_index = 0
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.llMoveArea = self:child("PokemonCellMove-Move-Area")
  startY = self.llMoveArea:GetYPosition()[2]
  rangeHeight = self.llMoveArea:GetPixelSize().y
  self.cell = UIMgr:new_widget("pokemon_head_cell")
  self.cell:SetVerticalAlignment(0)
  self._root:AddChildWindow(self.cell)
  self.parentUI = UI:getWnd("pokemonPacket")
  self.itemList = self.parentUI.battleItems
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowTouchMove, function(window, dx, dy)
    self:battleItemTouchMove(window, dx, dy)
    if self.behaviorReport and type(self.behaviorReport) == "function" then
      self.behaviorReport()
      self.behaviorReport = nil
    end
  end)
  self:subscribe(self._root, UIEvent.EventWindowTouchUp, function()
    Me:playSoundByKey("pet_click")
    self:battleItemTouchUp()
  end)
end

function M:battleItemTouchMove(window, dx, dy)
  self.cell:SetVisible(true)
  self.cell:SetXPosition({
    0,
    dx - self.itemWidth / 2
  })
  self.cell:SetYPosition({
    0,
    dy - self.itemHeight / 2
  })
  local moveIndex = checkAreaIndex(dy)
  self:changeMoveIndex(moveIndex)
end

function M:battleItemTouchUp()
  self:onHide()
  if self.cur_index == 0 then
    return
  end
  local movePokemon_objId = self.pokemon_list[self.move_old_index]
  local changePokemon_objId = self.pokemon_list[self.cur_index]
  self.pokemon_list[self.move_old_index] = changePokemon_objId
  self.pokemon_list[self.cur_index] = movePokemon_objId
  Me:sendPacket({
    pid = "setBattleListFromClient",
    objIds = table.concat(self.pokemon_list, ":")
  }, function(result)
    if result.success then
    else
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.replace.fail"
      })
    end
  end)
  self:changeMoveIndex(0)
end

function M:changeMoveIndex(moveIndex)
  if self.cur_index == moveIndex or moveIndex > #self.pokemon_list then
    return
  end
  self.cur_index = moveIndex
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("pokemonCellMove")
end

function M:onShow(item, behaviorReport)
  local pokemon = item:invoke("getPokemon")
  if not pokemon then
    return
  end
  self.cur_objId = pokemon:getObjId()
  self.pokemon_list = Me:getValue("battlePetList")
  for index, odjId in pairs(self.pokemon_list) do
    if tostring(odjId) == tostring(self.cur_objId) then
      self.move_old_index = index
      break
    end
  end
  self.itemWidth = item:GetWidth()[2]
  self.itemHeight = item:GetHeight()[2]
  self.cell:SetArea({0, 0}, {0, 0}, {
    0,
    self.itemWidth
  }, {
    0,
    self.itemHeight
  })
  self.cell:invoke("updateInfo", pokemon)
  UI:openWnd("pokemonCellMove")
  self.cell:SetVisible(false)
  self.behaviorReport = behaviorReport
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
