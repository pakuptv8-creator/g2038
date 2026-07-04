local WinProfessionRecommend = M
local ProfessionRecommendConfig = T(Config, "ProfessionRecommendConfig")
local PropsConfig = T(Config, "PropsConfig")
local PetConfig = T(Config, "PetConfig")
local CarConfig = T(Config, "CarConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local advancedCarCreateCd = World.cfg.advancedCarCreateCd or 10

function WinProfessionRecommend:init()
  WinBase.init(self, "ProfessionRecommend.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinProfessionRecommend:initUI()
  self.imgProfessionRecommendBg = self:child("ProfessionRecommend-bg")
  self.lytDataList = self:child("ProfessionRecommend-Interface-Data-List")
  self.btnProfessionRecommendClose = self:child("ProfessionRecommend-Close")
  self.txtProfessionRecommendInf = self:child("ProfessionRecommend-Inf")
  self.lytClose = self:child("ProfessionRecommend-ClosePanel")
  self:initAdapter()
end

function WinProfessionRecommend:initAdapter()
  self.xDis = 9
  local params = {
    xDis = self.xDis,
    yDis = 0,
    xCellNum = 1,
    widgetWidth = 88,
    widgetHeight = 88,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = false,
    vScorllMoveAble = false,
    autoColumnCount = true,
    widgetJson = "ProfessionRecommendItem.json",
    widgetName = "professionRecommendItem",
    gvParent = self.lytDataList,
    dataList = {},
    cellSelectedCb = function(data, dx, dy, index)
      self:selectItem(data)
    end
  }
  self.itemListView = GridViewHelper.new(params)
  self.itemGridView = self.itemListView:getGridView()
  self.listAdapter = self.itemListView:getAdapter()
  self.itemGridView:SetHorizontalAlignment(1)
  self.listInitW = self.lytDataList:GetWidth()[2]
  self.bgInitW = self.imgProfessionRecommendBg:GetWidth()[2]
  self.itemW = self.xDis + self.listInitW
end

function WinProfessionRecommend:initEvent()
  self:subscribe(self.btnProfessionRecommendClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("professionRecommend")
  end)
end

function WinProfessionRecommend:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_HAND_BAG_INFO, function()
    self:updateListView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_IN_USE_CAR, function(inUseCarInfo, objID)
    if objID ~= Me.objID then
      return
    end
    self:updateListView()
    Me:updateCarUseCD()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_CREATED, function()
    Me._nextCreateTime = os.time() + advancedCarCreateCd
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_APPEARANCE_INFO_UPDATE, function(shapeInfo)
    self:updateListView(shapeInfo)
  end)
end

function WinProfessionRecommend:initView()
  self:updateListView()
end

function WinProfessionRecommend:updateListView(shapeInfo)
  local recommendList = ProfessionRecommendConfig:getRecommendListById(Me:getProfessionId())
  if not recommendList or next(recommendList) == nil then
    return
  end
  local itemNum = #recommendList
  local widthChange = math.max(0, (itemNum - 1) * self.itemW)
  self.lytDataList:SetWidth({
    0,
    self.listInitW + widthChange
  })
  self.imgProfessionRecommendBg:SetWidth({
    0,
    self.bgInitW + widthChange
  })
  self.lytClose:SetWidth({
    0,
    self.bgInitW + widthChange
  })
  self.itemGridView:InitConfig(9, 0, itemNum)
  local data = self:transRecommendData(recommendList, shapeInfo)
  self.itemListView:setData(data, -1, nil, true)
end

function WinProfessionRecommend:transRecommendData(recommendList, shapeInfo)
  if not recommendList then
    return
  end
  local newList = {}
  for _, data in pairs(recommendList) do
    local newData
    if data.recommendType == Define.ProfessionRecommendType.Cloth then
      newData = AppearanceConfig:getCfgById(data.recommendId)
      if newData then
        newData.isHave = false
        local inf = shapeInfo or Me:getShapeInfo()
        if inf then
          for master, val in pairs(newData.parts) do
            if inf[master] == val then
              newData.isHave = true
              break
            end
          end
        end
      end
    elseif data.recommendType == Define.ProfessionRecommendType.Prop then
      newData = PropsConfig:getCfgById(data.recommendId)
      if newData then
        local handBagInfo = Me:getHandbagsInfo()
        newData.isHave = false
        for _, v in pairs(handBagInfo) do
          if newData.id == v.itemId then
            newData.isHave = true
            break
          end
        end
      end
    elseif data.recommendType == Define.ProfessionRecommendType.Vehicle then
      newData = CarConfig:getCfgById(data.recommendId)
      if newData then
        local inUseCar = Me:getInUseCar()
        newData.isHave = inUseCar and inUseCar.id == newData.id
      end
    elseif data.recommendType == Define.ProfessionRecommendType.Pet then
      newData = PetConfig:getCfgById(data.recommendId)
      if newData then
        local petData = Me:getPetDataByPetId(Me:getCurCarryPetId())
        newData.isHave = petData and petData.cfgId == newData.id
      end
    end
    if newData then
      newData.recommendType = data.recommendType
      newData.recommendId = data.recommendId
      table.insert(newList, newData)
    else
      print("!!!!!!!!!!!!!!!!!!,WinProfessionRecommend:transRecommendData error,no data,type,id:", data.recommendType, data.recommendId)
    end
  end
  return newList
end

function WinProfessionRecommend:selectItem(data)
  if not data then
    return
  end
  if data.recommendType == Define.ProfessionRecommendType.Cloth then
  elseif data.recommendType == Define.ProfessionRecommendType.Prop then
    local cfg = PropsConfig:getCfgById(data.id)
    if cfg then
      Me:selectPropLogic(cfg)
    end
  elseif data.recommendType == Define.ProfessionRecommendType.Vehicle then
    local cfg = CarConfig:getCfgById(data.id)
    if cfg then
      Me:selectCarLogic(cfg)
    end
  elseif data.recommendType == Define.ProfessionRecommendType.Pet then
  end
end

function WinProfessionRecommend:onHide()
  UI:closeWnd("professionRecommend")
end

function WinProfessionRecommend:onShow(isFromScene)
  if UI:isOpen(self) then
    self:updateListView()
    self:initTimer(isFromScene)
    return
  end
  UI:openWnd("professionRecommend", isFromScene)
end

function WinProfessionRecommend:onOpen(isFromScene)
  self:initView()
  self:subscribeEvent()
  self:initTimer(isFromScene)
end

function WinProfessionRecommend:initTimer(isFromScene)
  if self.countTimer then
    self.countTimer()
  end
  self.txtProfessionRecommendInf:SetText("")
  if isFromScene then
    self.remainTime = World.cfg.professionSetting.recommendWndTime or 3
    self.txtProfessionRecommendInf:SetText(Lang:toText({
      "g2052.gui.profession.recommend.time.count",
      self.remainTime
    }))
    self.countTimer = World.Timer(20, function()
      self.remainTime = self.remainTime - 1
      if self.remainTime <= 0 then
        self:onHide()
        return false
      else
        self.txtProfessionRecommendInf:SetText(Lang:toText({
          "g2052.gui.profession.recommend.time.count",
          self.remainTime
        }))
        return true
      end
    end)
  end
end

function WinProfessionRecommend:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.countTimer then
    self.countTimer()
  end
end

return WinProfessionRecommend
