local PropsConfig = T(Config, "PropsConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.handbagsInfo = {
  false,
  false,
  true,
  true,
  {},
  false
}
ValueDef.inUseProp = {
  false,
  false,
  true,
  true,
  nil,
  false
}
ValueDef.unLockProp = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.billboardState = {
  false,
  true,
  true,
  true,
  false,
  false
}
ValueDef.billboardInfo = {
  false,
  true,
  true,
  true,
  "HELLO",
  false
}
ValueDef.billboardColor = {
  false,
  true,
  true,
  true,
  nil,
  false
}
ValueDef.shopCarName = {
  false,
  true,
  true,
  true,
  "",
  false
}
ValueDef.shopCarNameColor = {
  false,
  true,
  true,
  true,
  nil,
  false
}
ValueDef.gunBulletCount = {
  false,
  true,
  true,
  false,
  {},
  false
}
ValueDef.shopBasketInfo = {
  false,
  false,
  true,
  true,
  {},
  false
}

function Entity:setGunBulletCount(info)
  if self.setValue then
    self:setValue("gunBulletCount", info)
  end
end

function Entity:getGunBulletCount()
  return self:getValue("gunBulletCount")
end

function Entity:setShopBasketInfo(info)
  self:setValue("shopBasketInfo", info)
end

function Entity:getShopBasketInfo()
  return self:getValue("shopBasketInfo")
end

function Entity:addOneBasketInfo(basketId)
  local shopBasketInfo = self:getShopBasketInfo()
  if not shopBasketInfo[basketId] then
    shopBasketInfo[basketId] = {
      parts = {},
      ids = {}
    }
    self:setShopBasketInfo(shopBasketInfo)
  end
end

function Entity:removeOneBasketInfo(basketId)
  local shopBasketInfo = self:getShopBasketInfo()
  if shopBasketInfo[basketId] then
    shopBasketInfo[basketId] = nil
    self:setShopBasketInfo(shopBasketInfo)
  end
end

function Entity:unlockProp(id)
  if self:isUnlockProp(id) then
    return
  end
  local cfg = PropsConfig:getCfgById(id)
  if not cfg then
    return
  end
  if cfg.unlockType == Define.Prop.UnlockType.Unlock or cfg.UnlockType == Define.Prop.UnlockType.CanNotUnlock then
    return
  end
  local data = self:getAllUnlockPropId()
  data[id] = true
  self:setValue("unLockProp", data)
end

function Entity:isUnlockProp(id)
  local cfg = PropsConfig:getCfgById(id)
  if not cfg then
    return false
  end
  if cfg.unlockType == Define.Prop.UnlockType.Unlock then
    return true
  end
  if cfg.unlockType == Define.Prop.UnlockType.CanUnlock then
    local data = self:getAllUnlockPropId()
    return data[id] == true
  end
  return false
end

function Entity:getAllUnlockPropId()
  return self:getValue("unLockProp")
end

function Entity:getPropUnlockedByType(type)
  local allCfg = PropsConfig:getAllCfgs()
  local data = {}
  for _, v in pairs(allCfg) do
    if self:isUnlockProp(v.id) and (type == 0 or v.type == type) then
      table.insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.order < b.order
  end)
  return data
end

function Entity:getGiftUnlockedByType(type)
  local allCfg = PropsConfig:getAllCfgs()
  local data = {}
  for _, v in pairs(allCfg) do
    if self:isUnlockProp(v.id) and (type == 0 or v.type == type) and v.canGive then
      local temp = Lib.copy(v)
      temp.isNew = 0
      temp.isHave = false
      table.insert(data, temp)
    end
  end
  table.sort(data, function(a, b)
    return a.order < b.order
  end)
  return data
end

function Entity:getHandbagsInfo()
  return self:getValue("handbagsInfo")
end

function Entity:removeHandItemDataById(itemId)
  local handItemInfo = self:getValue("handbagsInfo")
  local curIndex = -1
  for i, info in pairs(handItemInfo) do
    if info.itemId == itemId then
      curIndex = i
    end
  end
  if 0 < curIndex then
    table.remove(handItemInfo, curIndex)
    self:setHandbagsInfo(handItemInfo)
    self:removeOneBasketInfo(itemId)
  end
end

function Entity:setHandItemInUseById(id, val)
  local handItemInfo = self:getValue("handbagsInfo")
  for i, info in pairs(handItemInfo) do
    if info.itemId == id then
      handItemInfo[i].inUse = val
    end
  end
  self:setHandbagsInfo(handItemInfo)
end

function Entity:setHandbagsInfo(info)
  self:setValue("handbagsInfo", info)
  local inUseProp
  for k, v in pairs(info) do
    if v.inUse == true then
      inUseProp = info[k]
      break
    end
  end
  self:setInUseProp(inUseProp)
  return nil
end

function Entity:addHandbagsInfo(itemId)
  if not itemId then
    return
  end
  local itemId = tonumber(itemId)
  local handItemInfo = self:getValue("handbagsInfo")
  for i, v in pairs(handItemInfo) do
    if v.itemId == itemId then
      return
    end
  end
  local data = {itemId = itemId}
  local len = #handItemInfo
  if len >= Define.Prop.MaxHandBagCount then
    if handItemInfo[1].inUse then
      self:removeHandItemBuff()
    end
    self:removeOneBasketInfo(handItemInfo[1].itemId)
    table.remove(handItemInfo, 1)
  end
  table.insert(handItemInfo, data)
  self:setHandbagsInfo(handItemInfo)
  return true
end

function Entity:getHandBagIndexByItemId(itemId)
  if not itemId then
    return
  end
  local itemId = tonumber(itemId)
  local handItemInfo = self:getValue("handbagsInfo")
  for i, v in pairs(handItemInfo) do
    if v.itemId == itemId then
      return i
    end
  end
  return nil
end

function Entity:getHandBagItemByItemId(itemId)
  if not itemId then
    return
  end
  local itemId = tonumber(itemId)
  local handItemInfo = self:getValue("handbagsInfo")
  for i, v in pairs(handItemInfo) do
    if v.itemId == itemId then
      return v
    end
  end
  return nil
end

function Entity:operationHandbagsInfo(itemId)
  if not itemId then
    return
  end
  local itemId = tonumber(itemId)
  local handItemInfo = self:getValue("handbagsInfo")
  local curIndex = -1
  for i, info in pairs(handItemInfo) do
    if info.itemId == itemId then
      curIndex = i
    end
  end
  local isRemove = true
  if 0 < curIndex then
    self:removeHandItem({itemId = itemId})
  else
    self:addHandbagsInfo(itemId)
    isRemove = false
  end
  return isRemove
end

function Entity:selectHandItem(index, buffIndex)
  local handItemInfo = self:getValue("handbagsInfo")
  for i, v in pairs(handItemInfo) do
    v.inUse = false
    v.useStamp = nil
    if i == index then
      v.inUse = true
      v.index = buffIndex or 1
      v.useStamp = os.time()
    end
  end
  self:setHandbagsInfo(handItemInfo)
end

function Entity:getInUseProp()
  return self:getValue("inUseProp")
end

function Entity:setInUseProp(v)
  self:setValue("inUseProp", v)
  if not World.isClient then
    self:tryTriggerItemUseEvent(v)
  end
end

function Entity:getBillboardState()
  return self:getValue("billboardState")
end

function Entity:setBillboardState(val)
  self:setValue("billboardState", val)
end

function Entity:getBillboardInfo()
  return self:getValue("billboardInfo")
end

function Entity:setBillboardInfo(val)
  self:setValue("billboardInfo", val)
end

function Entity:getBillboardColor()
  return self:getValue("billboardColor")
end

function Entity:setBillboardColor(billboardColor)
  self:setValue("billboardColor", billboardColor)
end

function Entity:getShopCarName()
  return self:getValue("shopCarName")
end

function Entity:setShopCarName(val)
  self:setValue("shopCarName", val)
end

function Entity:getShopCarNameColor()
  return self:getValue("shopCarNameColor")
end

function Entity:setShopCarNameColor(color)
  self:setValue("shopCarNameColor", color)
end
