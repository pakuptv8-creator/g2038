local handlers = {}
local RedDotMgr, RedDotConfig, RedDotView
if World.isClient then
  RedDotConfig = require("client.config.red_dot_config")
  RedDotView = require("client.ui.RedDotView")
  local rdMgr = require("client.controller.RedDotMgr")
  RedDotMgr = rdMgr:getInstance()
end

function handlers.registerProfile(profile)
  RedDotMgr:registerProfile(profile)
end

function handlers.resetRedDotState(key, show)
  RedDotMgr:resetRedDotState(key, show)
end

function handlers.registerDynamicWithKey(key, parentKey, defaultShow)
  RedDotMgr:registerDynamicWithKey(key, parentKey, defaultShow)
end

function handlers.linkRedDotAction(key, handler)
  RedDotMgr:linkRedDotAction(key, handler)
end

function handlers.unlinkRedDotAction(key)
  RedDotMgr:unlinkRedDotAction(key)
end

function handlers.allocateRedDotKey(level)
  return RedDotConfig:allocateKey(level)
end

function handlers.getRedDotShow(t)
  RedDotMgr:getRedDotShow(t)
end

function handlers.redDotBuild(node, rdKey, parentKey, params)
  params = params or {}
  local customImage = params.customImage or "set:g2042_main_interface.json image:img_0_red_dot"
  local offset = params.offset or {x = 0, y = 0}
  local isShowNumber = params.isShowNumber == nil and true or params.isShowNumber
  local font = params.font or "NF18"
  local imgSize = params.imgSize
  return RedDotView.builder(rdKey, parentKey):setCustomImage(customImage):setIsShowNumber(isShowNumber):setFontSize(font):setOffset(offset):setRedDotImgSize(imgSize):show(node)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
