local PartPrinterHelper = T(Lib, "PartPrinterHelper")

function PartPrinterHelper:init()
  self.printerPartList = {}
end

function PartPrinterHelper:updatePrinterState(player, type, part, params, fromFunc)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  if fromFunc == "onPrinterInteract" then
    if self.printerPartList[partID] then
      return
    else
      self:createOnePrintingPaper(player, part, params)
    end
  elseif fromFunc == "onPrintPaperInteract" then
    self:printingPaperClick(player, type, part, params)
  end
end

function PartPrinterHelper:createOnePrintingPaper(player, part, params)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  self.printerPartList[partID] = {
    params = params,
    state = Define.PRINTER_STATE.notPrinter,
    moveTime = tonumber(params[4]),
    paperName = params[1],
    printerBgm = params[5]
  }
  local content1 = Lib.splitString(params[2], "#")
  local startOffset = {
    startOffsetX = tonumber(content1[1]) or 0,
    startOffsetY = tonumber(content1[2]) or 0,
    startOffsetZ = tonumber(content1[3]) or 0
  }
  local content2 = Lib.splitString(params[3], "#")
  local endOffset = {
    endOffsetX = tonumber(content2[1]) or 0,
    endOffsetY = tonumber(content2[2]) or 0,
    endOffsetZ = tonumber(content2[3]) or 0
  }
  local printPos = part:getPosition()
  self.printerPartList[partID].bornPos = printPos + Lib.v3(startOffset.startOffsetX, startOffset.startOffsetY, startOffset.startOffsetZ)
  self.printerPartList[partID].stayPos = printPos + Lib.v3(endOffset.endOffsetX, endOffset.endOffsetY, endOffset.endOffsetZ)
  self.printerPartList[partID].distancePos = self.printerPartList[partID].stayPos - self.printerPartList[partID].bornPos
  local paperPart = player:addItemPartToWorld(params[1], nil, nil, nil, true)
  if paperPart then
    paperPart:setPosition(self.printerPartList[partID].bornPos)
    self.printerPartList[partID].paperPart = paperPart
    self.printerPartList[partID].paperID = paperPart:getInstanceID()
    self:startMovePrintingPaper(partID)
  end
end

function PartPrinterHelper:startMovePrintingPaper(partID)
  if not self.printerPartList[partID] then
    return
  end
  self.printerPartList[partID].state = Define.PRINTER_STATE.inPrinter
  local paperPart = self.printerPartList[partID].paperPart
  if not paperPart or not paperPart:isValid() then
    return
  end
  self:updateClientPrinterState(partID, Define.PRINTER_STATE.inPrinter)
  local nodes = {}
  Lib.getInstanceAllChild(paperPart, nodes, Define.ABILITY.AABB)
  local distance = self.printerPartList[partID].distancePos
  local time = self.printerPartList[partID].moveTime
  local scene = paperPart:getScene()
  local offset = distance / time
  local count = 0
  self.printerPartList[partID].paperMoveTimer = World.Timer(1, function()
    for _, v in pairs(nodes or {}) do
      if not v or not v:isValid() then
        return
      end
    end
    count = count + 1
    scene.move(nodes, offset, true)
    if count == time then
      self.printerPartList[partID].paperMoveTimer = nil
      self.printerPartList[partID].state = Define.PRINTER_STATE.endPrinter
      self:updateClientPrinterState(partID, Define.PRINTER_STATE.endPrinter)
      return
    end
    return true
  end)
end

function PartPrinterHelper:printingPaperClick(player, type, paperPart, params)
  if not paperPart or not paperPart:isValid() then
    return
  end
  local paperID = paperPart:getInstanceID()
  for partID, printInfo in pairs(self.printerPartList) do
    if printInfo.paperPart and printInfo.paperPart:isValid() then
      local curPaperId = printInfo.paperPart:getInstanceID()
      if paperID == curPaperId and printInfo.state == Define.PRINTER_STATE.endPrinter then
        self:removeOnePrinterInteract(partID)
        player:onPickProp(type, paperPart, params)
        return
      end
    end
  end
end

function PartPrinterHelper:removePartInteractState(part)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  self:removeOnePrinterInteract(partID)
end

function PartPrinterHelper:removeOnePrinterInteract(partID)
  local printInfo = self.printerPartList[partID]
  if not printInfo then
    return
  end
  self:updateClientPrinterState(partID, Define.PRINTER_STATE.notPrinter)
  if printInfo.paperPart and printInfo.paperPart:isValid() then
    printInfo.paperPart:destroy()
  end
  if printInfo.paperMoveTimer then
    printInfo.paperMoveTimer()
  end
  self.printerPartList[partID] = nil
end

function PartPrinterHelper:updateClientPrinterState(partID, state)
  if self.printerPartList[partID] then
    local part = Instance.getByInstanceId(partID)
    if not part or not part:isValid() then
      return
    end
    WorldServer.BroadcastPacket({
      pid = "SCPushPrinterInteractState",
      partID = partID,
      paperID = self.printerPartList[partID].paperID or 0,
      state = state,
      printerBgm = self.printerPartList[partID].printerBgm or "",
      partPos = part:getPosition()
    })
  end
end

function PartPrinterHelper:loginSyncPrinterState(player)
  local dataList = {}
  for partID, printInfo in pairs(self.printerPartList) do
    local temp = {
      partID = partID,
      paperID = printInfo.paperID or 0,
      state = printInfo.state,
      printerBgm = printInfo.printerBgm or ""
    }
    table.insert(dataList, temp)
  end
  local packet = {
    pid = "SyncPrinterInteractState",
    dataList = dataList
  }
  player:sendPacket(packet)
end
