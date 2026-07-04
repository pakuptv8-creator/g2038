local GridViewHelper = Lib.class("GridViewHelper")

function GridViewHelper:ctor(data)
  self:initGv(data)
end

function GridViewHelper:initGv(data)
  self.gv = UIMgr:new_widget("grid_view")
  self.gv:SetName(data.name)
  self.gv:SetMoveAble(data.moveAble)
  self.gv:SetvScorllMoveAble(data.vScorllMoveAble)
  self.gv:SethScorllMoveAble(data.hScorllMoveAble)
  self.gv:InitConfig(data.xDis or 0, data.yDis or 0, data.xCellNum or 1)
  self.gv:SetArea(data.area[1], data.area[2], data.area[3], data.area[4])
  self.gv:SetAutoColumnCount(data.autoColumnCount)
  if data.itemAlignment then
    self.gv:SetItemAlignment(data.itemAlignment)
  end
  data.gvParent:AddChildWindow(self.gv)
  self.adapter = UIMgr:new_adapter("common", data.widgetWidth, data.widgetHeight, data.widgetName, data.widgetJson)
  self.gv:invoke("setAdapter", self.adapter)
  self.cellSelectedCb = data.cellSelectedCb
  self.dataList = {}
  if data.bottomCall then
    self.adapter:setBottomCall(data.bottomCall)
  end
end

function GridViewHelper:updateGridViewConfig(xDis, yDis, xCellNum)
  self.gv:InitConfig(xDis or 0, yDis or 0, xCellNum or 1)
end

function GridViewHelper:cellClickedCb(index, dx, dy, params)
  if self.curIndex == index and not self.enableRepeatClick then
    return false
  end
  if index > #self.dataList then
    return
  end
  if params and params.doNotChangeSelect == true then
    if self.dataList[index] and self.cellSelectedCb then
      self.cellSelectedCb(self.dataList[index].data, dx, dy, index, self.dataList[index].select)
    end
    return
  end
  self.preIndex = self.curIndex
  if self.preIndex and self.dataList[self.preIndex] and (not self.isInvertSelection or self.preIndex ~= index) then
    self.dataList[self.preIndex].select = false
  end
  self.curIndex = index
  if self.preIndex == nil then
    self.preIndex = self.curIndex
  end
  if self.isInvertSelection then
    self.dataList[self.curIndex].select = not self.dataList[self.curIndex].select
  else
    self.dataList[self.curIndex].select = true
  end
  self.adapter:setData(self.dataList)
  if self.dataList[index] and self.cellSelectedCb then
    self.cellSelectedCb(self.dataList[index].data, dx, dy, index, self.dataList[index].select)
  end
  return true
end

function GridViewHelper:setData(data, initTabIndex, eliminateCb, enableRepeatClick, isInvertSelection)
  local index = 1
  self.enableRepeatClick = enableRepeatClick or false
  self.isInvertSelection = isInvertSelection or false
  self.rawData = data
  self.dataList = {}
  if data and not Lib.table_is_empty(data) then
    if eliminateCb then
      for k, v in pairs(data) do
        if eliminateCb(v) then
          local cbIndex = index
          self.dataList[index] = {
            data = v,
            select = false,
            clickCb = function(_, dx, dy, params)
              if self.cellSelectedCb then
                self:cellClickedCb(cbIndex, dx, dy, params)
              end
            end,
            index = index
          }
          index = index + 1
        end
      end
    else
      for k, v in pairs(data) do
        local cbIndex = index
        self.dataList[index] = {
          data = v,
          select = false,
          clickCb = function(_, dx, dy, params)
            if self.cellClickedCb then
              self:cellClickedCb(cbIndex, dx, dy, params)
            end
          end,
          index = index
        }
        index = index + 1
      end
    end
  end
  Lib.logDebug("gridviewhelper setdata")
  self.adapter:setData(self.dataList)
  if initTabIndex == -1 then
    if self.curIndex ~= nil then
      self.curIndex = nil
    end
    if self.preIndex ~= nil then
      self.preIndex = nil
    end
    return
  end
  if initTabIndex and self.dataList[initTabIndex] then
    self.curIndex = nil
    self.preIndex = nil
    self:cellClickedCb(initTabIndex)
    return
  end
  if self.curIndex and self.dataList[initTabIndex] then
    self:cellClickedCb(self.curIndex)
    return
  end
  if self.dataList[1] then
    self:cellClickedCb(1)
  end
end

function GridViewHelper:setClickIndex(data)
  for i = 1, #self.dataList do
    if self.dataList[i].data == data then
      self:cellClickedCb(i)
      return
    end
  end
end

function GridViewHelper:setClickByOrder(order)
  if self.dataList[order] ~= nil then
    self:cellClickedCb(order)
    return
  end
end

function GridViewHelper:getGridView()
  return self.gv
end

function GridViewHelper:getAdapter()
  return self.adapter
end

function GridViewHelper:getRawData()
  return self.rawData
end

return GridViewHelper
