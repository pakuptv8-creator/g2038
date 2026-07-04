local ModReportProxy = T(Lib, "ModReportProxy")

local function CommonKeyTest(key)
  local ok = false
  local errorTyp = ""
  if not key then
    errorTyp = "nil"
  elseif type(key) ~= "string" then
    errorTyp = "is not string"
  elseif key == "" then
    errorTyp = "string empty"
  else
    ok = true
  end
  if not ok then
    print("===!!!Mod Report Key Error:" .. errorTyp)
    print(debug.traceback())
  end
  return ok
end

function ModReportProxy:openUIReport(key)
  if not CommonKeyTest(key) then
    return
  end
  self.delegateUiOpenTime[key] = os.time()
  Plugins.CallTargetPluginFunc("report", "report", "uiOpen", {name = key}, Me)
  Lib.logDebug("===OpenUIReport Success! name = " .. key)
end

function ModReportProxy:closeUIReport(key, time)
  if not CommonKeyTest(key) then
    return
  end
  if not time then
    if self.delegateUiOpenTime[key] == nil then
      return
    end
    time = os.time() - self.delegateUiOpenTime[key]
    self.delegateUiOpenTime[key] = nil
  end
  Plugins.CallTargetPluginFunc("report", "report", "uiClose", {name = key, time = time}, Me)
  Lib.logDebug("===CloseUIReport Success! name = " .. key .. " time = " .. time)
end

function ModReportProxy:btnClickReport(key)
  if not CommonKeyTest(key) then
    return
  end
  Lib.logDebug("===BtnClickReport Success! name = " .. key)
end

function ModReportProxy:relaySuccessReport()
  local key = World.cfg.modUIInfo.modRelayReportKey
  if not CommonKeyTest(key) then
    return
  end
  Lib.logDebug("===RelaySuccessReport Success! name = " .. key)
end

function ModReportProxy:mapDetailFromReport(key)
  if not CommonKeyTest(key) then
    return
  end
  Lib.logDebug("===MapDetailFromReport Success! name = " .. key)
end

function ModReportProxy:init()
  self.delegateUiOpenTime = {}
end

ModReportProxy:init()
return ModReportProxy
