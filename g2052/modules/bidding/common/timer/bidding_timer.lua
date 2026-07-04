local handlers = {}
World.Timer(20, function()
  local currTime = os.time()
  local removeKeys = {}
  for targetTime, funcs in pairs(handlers) do
    if targetTime <= currTime then
      table.insert(removeKeys, targetTime)
    end
  end
  table.sort(removeKeys)
  for i, targetTime in ipairs(removeKeys) do
    local funcs = handlers[targetTime]
    for j, func in pairs(funcs) do
      func()
    end
    handlers[targetTime] = nil
  end
  return true
end)
local BiddingTimer = T(Lib, "BiddingTimer")

function BiddingTimer:registerTimer(targetTime, func)
  if targetTime < os.time() then
    func()
    return function()
    end
  end
  handlers[targetTime] = handlers[targetTime] or {}
  table.insert(handlers[targetTime], func)
  local pos = #handlers[targetTime]
  return function()
    if not handlers[targetTime] then
      return
    end
    handlers[targetTime][pos] = nil
  end
end
