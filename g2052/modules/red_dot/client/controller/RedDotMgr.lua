local RedDotModel = require("client.model.RedDotModel")
local RedDotInfo = require("client.model.RedDotInfo")
local RedDotMgr = Lib.class("RedDotMgr")
local instance

function RedDotMgr:ctor()
  self.redDotModelDic = {}
  self.redDotInfoDic = {}
end

function RedDotMgr:getInstance()
  if instance == nil then
    instance = RedDotMgr.new()
  end
  return instance
end

function RedDotMgr:registerProfile(profile)
  self:registerWithObject(profile, nil, 0)
end

function RedDotMgr:registerWithObject(object, parent, defaultShow)
  if type(object) == "table" then
    local size_object = Lib.getTableSize(object)
    if size_object == #object then
      for _, obj in ipairs(object) do
        self:registerWithObject(obj, parent, defaultShow)
      end
    else
      for key, subObject in pairs(object) do
        local rdModel = self:fetchOrCreateModelWithKey(key, parent, defaultShow, false)
        self:registerWithObject(subObject, rdModel, defaultShow)
      end
    end
  elseif type(object) == "string" then
    self:fetchOrCreateModelWithKey(object, parent, defaultShow, true)
  end
end

function RedDotMgr:fetchOrCreateModelWithKey(key, parent, show, isLeaf)
  if not key or key == "" then
    return
  end
  if self.redDotModelDic[key] then
    return self.redDotModelDic[key]
  end
  local rdModel = RedDotModel.new()
  rdModel.key = key
  if isLeaf then
    rdModel.show = show
  else
  end
  if parent and rdModel.parent == nil then
    rdModel.parent = parent
    table.insert(parent.subDots, rdModel)
  end
  self.redDotModelDic[key] = rdModel
  return rdModel
end

function RedDotMgr:resetRedDotState(key, show)
  local rdModel = self.redDotModelDic[key]
  if not rdModel then
    return
  end
  if rdModel:hasSubDot() then
    return
  end
  rdModel.show = show
  self:refreshRedDotTreeForKey(key)
end

function RedDotMgr:refreshRedDotTreeForKey(key)
  local rdModel = self:refreshRedDotForKey(key)
  if rdModel and rdModel.parent then
    local parentModel = rdModel.parent
    self:refreshRedDotTreeForKey(parentModel.key)
  end
end

function RedDotMgr:refreshRedDotForKey(key)
  local rdModel = self.redDotModelDic[key]
  if not rdModel then
    return
  end
  local rdInfo = self.redDotInfoDic[key]
  local show = self:checkShowWithModel(rdModel)
  rdModel.show = show
  if rdInfo and rdInfo.execute then
    rdInfo:execute(show)
  end
  return rdModel
end

function RedDotMgr:checkShowWithModel(redDotModel)
  if redDotModel:hasSubDot() then
    local showAdd = 0
    for _, subDot in ipairs(redDotModel.subDots) do
      local show = self:checkShowWithModel(subDot)
      showAdd = showAdd + show
    end
    return showAdd
  else
    return redDotModel.show
  end
end

function RedDotMgr:registerDynamicWithKey(key, parentKey, defaultShow)
  if not key or key == "" then
    return
  end
  local rdModel = self.redDotModelDic[key]
  if rdModel then
    return
  end
  local rdModel_parent = self.redDotModelDic[parentKey]
  self:fetchOrCreateModelWithKey(key, rdModel_parent, defaultShow, true)
  self:refreshRedDotTreeForKey(key)
end

function RedDotMgr:isAlreadyRegistered(key)
  return self.redDotModelDic[key] ~= nil
end

function RedDotMgr:linkRedDotAction(key, handler)
  if not key or key == "" then
    return
  end
  if not handler or type(handler) ~= "function" then
    return
  end
  local rdInfo = RedDotInfo.new()
  rdInfo.key = key
  rdInfo.refreshBlock = handler
  self.redDotInfoDic[key] = rdInfo
  self:refreshRedDotForKey(key)
end

function RedDotMgr:unlinkRedDotAction(key)
  self.redDotInfoDic[key] = nil
end

function RedDotMgr:getRedDotShow(table)
  if not table.key then
    return
  end
  if self.redDotModelDic[table.key] then
    table.num = self.redDotModelDic[table.key].show
  end
end

return RedDotMgr
