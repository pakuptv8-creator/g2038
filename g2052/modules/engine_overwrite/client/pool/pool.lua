local Pool = Lib.class("Pool")

function Pool:ctor(data)
  if not (data and data.creator) or not data.destFun then
    Lib.logError("pool params error, please recheck!!", Lib.v2s(data))
    return
  end
  self.creator = data.creator
  self.static_params = data.static_params
  self.destFun = data.destFun
  self.initCount = data.initCount or 0
  self.maxCount = data.maxCount or 1
  self.formatFun = data.formatFun
  self.objects = {}
  self.name = data.name or Lib.getCallTag()
  for i = 1, self.initCount do
    local object = self.creator(self.static_params)
    self:push(object)
  end
end

function Pool:dctor()
  for i = 1, #self.objects do
    self.destFun(self.objects[i])
  end
end

function Pool:get()
  local object
  if #self.objects == 0 then
    Lib.logDebug("pool get, new --------------")
    object = self.creator(self.static_params)
  else
    Lib.logDebug("pool get, reuse ---------")
    object = table.remove(self.objects, #self.objects)
  end
  return object
end

function Pool:push(object)
  if #self.objects >= self.maxCount then
    self.destFun(object)
    table.remove(self.objects, 1)
  else
    if self.formatFun then
      self.formatFun(object)
    end
    table.insert(self.objects, object)
    Lib.logDebug("push obj", #self.objects)
  end
end

return Pool
