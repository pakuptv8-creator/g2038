local class = require("common.3rd.middleclass.middleclass")
local guiMgr = L("guiMgr", GUIManager:Instance())
local winMgr = L("winMgr", CEGUIWindowManager:getSingleton())
local Window = class("Window")

function Window:initialize(layout, name, resGroup, ...)
  self.handlers = {}
  self.root = guiMgr:getRootWindow()
  self.object = guiMgr:loadLayoutFile(layout .. ".layout", resGroup or "layouts")
  if not self.object then
    Lib.logError("layout not found  ", layout)
    return
  end
  self.object:setName(name)
  local ok, ret = pcall(Window.loadScript, self, layout)
  Lib.logDebug("ok and ret = ", ok, ret)
  if not ok then
  end
  assert(ok, ret)
  if type(rawget(self, "onInit")) == "function" then
    self:onInit()
  end
  self.root:addChild(self.object)
end

function Window:destroy()
end

function Window:loadScript(name)
  local path, chunk
  local gamePath = Root.Instance():getGamePath():gsub("\\", "/")
  path, chunk = loadLua(name, gamePath .. "asset/gui/lua_scripts/?.lua")
  assert(path, "cannot find lua script '" .. name)
  local env = setmetatable({self = self, M = self}, {
    __index = _G
  })
  local ret, errmsg = load(chunk, "@" .. path, "bt", env)
  Lib.logDebug("loadScript ret and errmsg = ", ret, errmsg)
  assert(ret, errmsg)()
end

function Window:subscribeEvent(object, eventName, handler)
  guiMgr:subscribeEvent(object, eventName)
  self.handlers[eventName] = handler
end

function Window:unsubscribeEvent(object, eventName)
  guiMgr:unsubscribeEvent(object, eventName)
  self.handlers[eventName] = nil
end

function Window:getProperty(key)
  return self.object:getProperty(key)
end

function Window:setProperty(key, value)
  self.object:setProperty(key, value)
end

function Window:getName()
  return self.object:getName()
end

function Window:getType()
  return self.object:getType()
end

function Window:getID()
  return self.object:getID()
end

function Window:isAlive()
  return self.object and winMgr:isAlive(self.object)
end

function Window:getChildByName(name)
  return self.object:getChildByName(name)
end

return Window
