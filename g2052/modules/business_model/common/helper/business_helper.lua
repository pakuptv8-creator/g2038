local BusinessHelper = T(Lib, "BusinessHelper")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local helpers = {
  [Define.PRODUCT_TYPE.PRIVILEGE] = require("common.product.product_privilege")
}

function BusinessHelper:init()
  self.isClickPrivilege = false
  self.allPlayerPrivilegeInfo = {}
end

function BusinessHelper:updateAllPlayerPrivilegeInfo(platformUserId, data)
  self.allPlayerPrivilegeInfo[platformUserId] = data
  if not World.isClient then
    WorldServer.BroadcastPacket({
      pid = "UpdateAllPlayerPrivilegeInfo",
      params = {platformUserId = platformUserId, data = data}
    })
  end
end

function BusinessHelper:getPlayerPrivilegeInfo(platformUserId, type)
  if type == Define.PRIVILEGE_TYPE.DISASTER then
    local player = Me
    if not World.isClient then
      player = Game.GetPlayerByUserId(platformUserId)
    end
    if player and player:isValid() then
      local subscribeVipStage = player:getSubscribeVipStage()
      if subscribeVipStage == Define.SubscribeVIPStage.Height then
        local subscribe_vipSetting = World.cfg.subscribe_vipSetting
        if subscribe_vipSetting.heightVipDisaster then
          return true
        end
      end
    end
  end
  if type then
    if self.allPlayerPrivilegeInfo[platformUserId] then
      return self.allPlayerPrivilegeInfo[platformUserId][type]
    end
    return
  else
    return self.allPlayerPrivilegeInfo[platformUserId]
  end
end

function BusinessHelper:getProductCfg(productType, needFun)
  if not helpers[productType] then
    return
  end
  return helpers[productType]:getCfg(needFun)
end

function BusinessHelper:checkWhetherCanBuy(params)
  if not params.productType or params.productType and not helpers[params.productType] then
    return
  end
  return helpers[params.productType]:checkWhetherCanBuy(params)
end

function BusinessHelper:queryWhetherHave(player, params)
  if not params.productType or params.productType and not helpers[params.productType] then
    return
  end
  return helpers[params.productType]:getHaveStatus(player, params)
end

if World.isClient then
  function BusinessHelper:onClientBuy(params)
    if not params.productType or params.productType and not helpers[params.productType] then
      return
    end
    Plugins.CallTargetPluginFunc("report", "report", "shop_buy_pass_1", {
      pass_item = params.id
    })
    helpers[params.productType]:onClientBuy(params)
  end
  
  function BusinessHelper:syncBuySuccess(params)
    if not params.productType or params.productType and not helpers[params.productType] then
      return
    end
    helpers[params.productType]:syncBuySuccess(params)
  end
  
  function BusinessHelper:setAllPlayerPrivilegeInfo(info)
    self.allPlayerPrivilegeInfo = info
  end
  
  function BusinessHelper:updatePrivilegeClickState(val)
    self.isClickPrivilege = val
    Lib.emitEvent(Event.EVENT_UPDATE_BUSINESS_RED)
  end
  
  function BusinessHelper:getMainShopRedShowState()
    local isDayFirstLogin = Me:getIsDayFirstLogin()
    if not isDayFirstLogin then
      return false
    end
    if self.isClickPrivilege then
      return false
    else
      local privilegeInfo = Me:getPrivilegeInfo()
      if not privilegeInfo[Define.PRIVILEGE_TYPE.DISASTER] then
        return true
      else
        local allGoodsCfgs = BusinessGoodsConfig:getAllCfgs()
        for key, info in pairs(allGoodsCfgs) do
          local canUse = Me:checkBusinessItemUnlock(info.goodsType, info.itemId)
          if not canUse then
            return true
          end
        end
      end
    end
    return false
  end
  
  function BusinessHelper:getPrivilegeRedShowState()
    if self:getMainShopRedShowState() then
      local privilegeInfo = Me:getPrivilegeInfo()
      if privilegeInfo[Define.PRIVILEGE_TYPE.DISASTER] then
        return false
      else
        return true
      end
    else
      return false
    end
  end
else
  function BusinessHelper:onRequestBuy(player, params)
    if not params.productType or params.productType and not helpers[params.productType] then
      return
    end
    helpers[params.productType]:onBuy(player, params)
  end
  
  function BusinessHelper:syncAllPlayerPrivilegeInfo(player)
    player:sendPacket({
      pid = "SyncAllPlayerPrivilegeInfo",
      info = self.allPlayerPrivilegeInfo
    })
  end
end
BusinessHelper:init()
return BusinessHelper
