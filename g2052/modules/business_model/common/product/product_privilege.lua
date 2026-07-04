local base = require("common.product.product_base")
local ProductPrivilege = Lib.class("ProductPrivilege", base)
local PrivilegeConfig = T(Config, "PrivilegeConfig")

local function pushTip(player, tip)
  if World.isClient then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tip)
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, tip)
  end
end

function ProductPrivilege:getCfg(needFun)
  if needFun then
    return PrivilegeConfig
  end
  return PrivilegeConfig:getAllCfgs()
end

function ProductPrivilege:checkWhetherCanBuy(player, params)
  local isHave = self:getHaveStatus(player, params)
  if isHave then
    pushTip(player, "gui.do.not.repeat.purchase")
    return false, Define.BUY_FAILURE_TYPE.HAVE
  end
  local isEnough = self:verifyMoney(player, params)
  if not isEnough then
    self:pushTip(player, "gui.insufficient.funds")
    return false, Define.BUY_FAILURE_TYPE.MONEY
  end
  return true
end

function ProductPrivilege:getHaveStatus(player, params)
  local privilegeInfo = player:getPrivilegeInfo()
  if params.type then
    if privilegeInfo[params.type] then
      return true
    end
  else
    local cfg = PrivilegeConfig:getCfgByType(params.type)
    if cfg and privilegeInfo[cfg.id] then
      return true
    end
  end
  return false
end

if World.isClient then
  function ProductPrivilege:syncBuySuccess(params)
    UI:getWnd("commonDialog"):onShow(true, {
      title = "gui.buy.succeed",
      
      desc = Lang:toText({
        "gui.buy.succeed.dec",
        params.name
      }),
      centerCallback = function()
      end
    })
  end
else
  function ProductPrivilege:onBuySuccess(player, params)
    assert(params.id, Lib.v2s(params))
    
    local privilegeInfo = player:getPrivilegeInfo()
    privilegeInfo[params.type] = os.time()
    player:setPrivilegeInfo(privilegeInfo)
    player:sendPacket({
      pid = "SyncBuySuccess",
      params = params
    })
    Plugins.CallTargetPluginFunc("report", "report", "shop_buy_pass_2", {
      pass_item = params.id
    }, player)
    if params.type == Define.PRIVILEGE_TYPE.DISASTER then
      Plugins.CallTargetPluginFunc("report", "report", "shop_disaster_buy", nil, player)
    end
  end
end
return ProductPrivilege
