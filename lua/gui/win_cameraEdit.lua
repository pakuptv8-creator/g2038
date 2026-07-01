local lfs = require("lfs")
local editVis = 0
local normalVis = 3
local freeVis = 4
local showDebugDraw = true
local curSelNodeIdx = 0
local SLAXML = require("common.xml.slaxml")
local dataList = {}
local allTime = 0
local spdLevel = 2
local spdName = {
  "\231\188\147\230\133\162",
  "\230\173\163\229\184\184",
  "\229\191\171\233\128\159",
  "\230\158\129\229\191\171"
}
local spdValList = {
  0.01,
  0.2,
  1,
  2
}
DebugDraw.addEntry("cameraEdit", function()
  if not showDebugDraw then
    return
  end
  local debugDraw = DebugDraw.instance
  for i, drawPos in pairs(dataList) do
    if drawPos.time then
      local l1 = {
        {
          x = drawPos.begin.x,
          y = drawPos.begin.y,
          z = drawPos.begin.z
        },
        {
          x = drawPos.over.x,
          y = drawPos.over.y,
          z = drawPos.over.z
        }
      }
      debugDraw:drawSphere(l1[1], 0.3, curSelNodeIdx == i and 4278190335 or 65535)
      debugDraw:drawSphere(l1[2], 0.3, curSelNodeIdx == i and 4278190335 or 65535)
      debugDraw:drawLine(l1[1], l1[2], curSelNodeIdx == i and 4278190335 or 65535)
    end
  end
end)
local M = _ENV.M

function M:init()
  WinBase.init(self, "CameraEdit.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytCameraEditFrame = self:child("CameraEdit-frame")
  self.imgCameraEditLt = self:child("CameraEdit-lt")
  self.imgCameraEditLt0 = self:child("CameraEdit-lt_0")
  self.imgCameraEditRt = self:child("CameraEdit-rt")
  self.imgCameraEditRt0 = self:child("CameraEdit-rt_0")
  self.imgCameraEditLb = self:child("CameraEdit-lb")
  self.imgCameraEditLb0 = self:child("CameraEdit-lb_0")
  self.imgCameraEditRb = self:child("CameraEdit-rb")
  self.imgCameraEditRb0 = self:child("CameraEdit-rb_0")
  self.imgCameraEditCh = self:child("CameraEdit-ch")
  self.imgCameraEditCv = self:child("CameraEdit-cv")
  self.lytCameraEditCtrl = self:child("CameraEdit-ctrl")
  self.lytCameraEditTopPanel = self:child("CameraEdit-TopPanel")
  self.cameraEditCameraName = self:child("CameraEdit-CameraName")
  self.btnCameraEditCreateOrImport = self:child("CameraEdit-CreateOrImport")
  self.btnCameraEditCreateOrImport:SetText("\229\136\155\229\187\186/\229\138\160\232\189\189")
  self.btnExit = self:child("CameraEdit-CreateOrImport_11")
  self.btnExit:SetText("\233\128\128\229\135\186")
  self.lytCameraEditNodeListPanel = self:child("CameraEdit-NodeListPanel")
  self.txtCameraEditTitle1 = self:child("CameraEdit-title1")
  self.txtCameraEditTitle1:SetText("\233\149\156\229\164\180\232\138\130\231\130\185\229\186\143\229\136\151")
  self.btnCameraEditReviewList = self:child("CameraEdit-ReviewList")
  self.btnCameraEditReviewList:SetText("\228\191\157\229\173\152\229\185\182\233\162\132\232\167\136")
  self.lytCameraEditListPos = self:child("CameraEdit-ListPos")
  self.lstCameraEditListContent = self:child("CameraEdit-ListContent")
  self.lytCameraEditActionEditPanel = self:child("CameraEdit-ActionEditPanel")
  self.txtCameraEditTitle2 = self:child("CameraEdit-title2")
  self.txtCameraEditTitle2:SetText("\233\149\156\229\164\180\232\138\130\231\130\185")
  self.cameraEditBeginPointSet = self:child("CameraEdit-BeginPointSet")
  self.txttitle3 = self:child("title3")
  self.txttitle3:SetText("\229\188\128\229\167\139\233\149\156\229\164\180\228\189\141\231\189\174")
  self.btnCameraEditLockBP = self:child("CameraEdit-LockBP")
  self.btnCameraEditJumpBP = self:child("CameraEdit-JumpBP")
  self.btnCameraEditJumpBP:SetText("\231\167\187\229\138\168")
  self.cameraEditEndPointSet = self:child("CameraEdit-EndPointSet")
  self.txttitle4 = self:child("title4")
  self.txttitle4:SetText("\231\187\147\230\157\159\233\149\156\229\164\180\228\189\141\231\189\174\239\188\154")
  self.btnCameraEditLockEP = self:child("CameraEdit-LockEP")
  self.btnCameraEditJumpEP = self:child("CameraEdit-JumpEP")
  self.btnCameraEditJumpEP:SetText("\231\167\187\229\138\168")
  self.cameraEditBeginRotateSet = self:child("CameraEdit-BeginRotateSet")
  self.txttitle5 = self:child("title5")
  self.txttitle5:SetText("\229\188\128\229\167\139\233\149\156\229\164\180\230\156\157\229\144\145\239\188\154")
  self.btnCameraEditLockBR = self:child("CameraEdit-LockBR")
  self.btnCameraEditJumpBR = self:child("CameraEdit-JumpBR")
  self.btnCameraEditJumpBR:SetText("\232\189\172\229\144\145")
  self.cameraEditEndRotateSet = self:child("CameraEdit-EndRotateSet")
  self.txttitle6 = self:child("title6")
  self.txttitle6:SetText("\231\187\147\230\157\159\233\149\156\229\164\180\230\156\157\229\144\145\239\188\154")
  self.btnCameraEditLockER = self:child("CameraEdit-LockER")
  self.btnCameraEditJumpER = self:child("CameraEdit-JumpER")
  self.btnCameraEditJumpER:SetText("\232\189\172\229\144\145")
  self.cameraEditTimeSet = self:child("CameraEdit-TimeSet")
  self.txttitle8 = self:child("title8")
  self.txttitle8:SetText("\230\151\182\233\149\191\239\188\154")
  self.btnCameraEditReviewNode = self:child("CameraEdit-ReviewNode")
  self.btnCameraEditReviewNode:SetText("\233\162\132\232\167\136")
  self.btnCameraEditSaveNode = self:child("CameraEdit-SaveNode")
  self.btnCameraEditSaveNode:SetText("\228\191\157\229\173\152")
  self.btnAddNode = self:child("CameraEdit-AddNode")
  self.btnAddNode:SetText("\230\183\187\229\138\160")
  self.btnDelNode = self:child("CameraEdit-DelNode")
  self.btnDelNode:SetText("\229\136\160\233\153\164")
  self.txtAllTime = self:child("CameraEdit-AllTime")
  self.txtAllTime:SetText("\230\128\187\230\151\182\233\149\191\239\188\1540s")
  self.lytTips = self:child("CameraEdit-Tips")
  self.txtTipsInfo = self:child("CameraEdit-TipsTxt")
  self.btnTipsSure = self:child("CameraEdit-TipsSure")
  self.btnTipsSure:SetText("\231\161\174\229\174\154")
  self.btnTipsCancel = self:child("CameraEdit-TipsCancel")
  self.btnTipsCancel:SetText("\229\143\150\230\182\136")
  self.txtSpd = self:child("CameraEdit-SpdTxt")
  self.txtSpd:SetText("\230\173\163\229\184\184")
  self.btnAddSpd = self:child("CameraEdit-SpdAdd")
  self.btnAddSpd:SetText("+")
  self.btnLowSpd = self:child("CameraEdit-SpdLow")
  self.btnLowSpd:SetText("-")
end

function M:initEvent()
  self:subscribe(self.btnCameraEditCreateOrImport, UIEvent.EventButtonClick, function()
    if self.cameraEditCameraName:GetPropertyString("Text", "0") == "enter filename" then
      self:showTips("\232\175\183\232\190\147\229\133\165\230\150\135\228\187\182\229\144\141\239\188\129")
      return
    end
    if 0 < #dataList then
      self:showTips("\230\150\176\229\187\186\228\188\154\230\184\133\233\153\164\229\189\147\229\137\141\230\149\176\230\141\174\239\188\129", self.initActionData)
    else
      self:initActionData()
    end
  end)
  self:subscribe(self.btnExit, UIEvent.EventButtonClick, function()
    self:showTips("\230\156\170\228\191\157\229\173\152\230\149\176\230\141\174\229\176\134\228\184\162\229\164\177\239\188\129", self.onHide)
  end)
  self:subscribe(self.btnAddSpd, UIEvent.EventButtonClick, function()
    if spdLevel + 1 <= #spdValList then
      spdLevel = spdLevel + 1
      Me.camaraModeSpd = spdValList[spdLevel]
      self.txtSpd:SetText(spdName[spdLevel])
    end
  end)
  self:subscribe(self.btnLowSpd, UIEvent.EventButtonClick, function()
    if 1 <= spdLevel - 1 then
      spdLevel = spdLevel - 1
      Me.camaraModeSpd = spdValList[spdLevel]
      self.txtSpd:SetText(spdName[spdLevel])
    end
  end)
  self:subscribe(self.btnCameraEditReviewList, UIEvent.EventButtonClick, function()
    self:reviewList()
  end)
  self:subscribe(self.btnCameraEditJumpBP, UIEvent.EventButtonClick, function()
    self:jumpBeginEditPos()
  end)
  self:subscribe(self.btnCameraEditJumpEP, UIEvent.EventButtonClick, function()
    local bp = Lib.splitString(self.cameraEditEndPointSet:GetPropertyString("Text", "0"), ",")
    local pos = {
      x = bp[1],
      y = bp[2] - 1.62,
      z = bp[3]
    }
    Me:setPosition(pos)
  end)
  self:subscribe(self.btnCameraEditJumpBR, UIEvent.EventButtonClick, function()
    self:jumpBeginEditRotate()
  end)
  self:subscribe(self.btnCameraEditJumpER, UIEvent.EventButtonClick, function()
    local bp = Lib.splitString(self.cameraEditEndRotateSet:GetPropertyString("Text", "0"), ",")
    Me:changeCameraView(nil, bp[2], bp[1], 0, 0)
  end)
  self:subscribe(self.btnCameraEditLockBP, UIEvent.EventButtonClick, function()
    if self.isLockBP then
      self.isLockBP = false
      self.btnCameraEditLockBP:SetBackgroundColor({
        1,
        0,
        0,
        1
      })
      self.btnCameraEditLockBP:SetText("\232\135\170\231\148\177")
    else
      self.isLockBP = true
      self.btnCameraEditLockBP:SetBackgroundColor({
        0,
        0.5,
        0,
        1
      })
      self.btnCameraEditLockBP:SetText("\233\148\129\229\174\154")
    end
  end)
  self:subscribe(self.btnCameraEditLockEP, UIEvent.EventButtonClick, function()
    if self.isLockEP then
      self.isLockEP = false
      self.btnCameraEditLockEP:SetBackgroundColor({
        1,
        0,
        0,
        1
      })
      self.btnCameraEditLockEP:SetText("\232\135\170\231\148\177")
    else
      self.isLockEP = true
      self.btnCameraEditLockEP:SetBackgroundColor({
        0,
        0.5,
        0,
        1
      })
      self.btnCameraEditLockEP:SetText("\233\148\129\229\174\154")
    end
  end)
  self:subscribe(self.btnCameraEditLockBR, UIEvent.EventButtonClick, function()
    if self.isLockBR then
      self.isLockBR = false
      self.btnCameraEditLockBR:SetBackgroundColor({
        1,
        0,
        0,
        1
      })
      self.btnCameraEditLockBR:SetText("\232\135\170\231\148\177")
    else
      self.isLockBR = true
      self.btnCameraEditLockBR:SetBackgroundColor({
        0,
        0.5,
        0,
        1
      })
      self.btnCameraEditLockBR:SetText("\233\148\129\229\174\154")
    end
  end)
  self:subscribe(self.btnCameraEditLockER, UIEvent.EventButtonClick, function()
    if self.isLockER then
      self.isLockER = false
      self.btnCameraEditLockER:SetBackgroundColor({
        1,
        0,
        0,
        1
      })
      self.btnCameraEditLockER:SetText("\232\135\170\231\148\177")
    else
      self.isLockER = true
      self.btnCameraEditLockER:SetBackgroundColor({
        0,
        0.5,
        0,
        1
      })
      self.btnCameraEditLockER:SetText("\233\148\129\229\174\154")
    end
  end)
  self:subscribe(self.btnCameraEditReviewNode, UIEvent.EventButtonClick, function()
    self:reviewNode()
  end)
  self:subscribe(self.btnCameraEditSaveNode, UIEvent.EventButtonClick, function()
    self:saveNode()
  end)
  self:subscribe(self.btnAddNode, UIEvent.EventButtonClick, function()
    if self:addNode() then
      self:setTailNodeBeginPos()
    end
  end)
  self:subscribe(self.btnDelNode, UIEvent.EventButtonClick, function()
    self:delNode()
  end)
  self:subscribe(self.btnTipsSure, UIEvent.EventButtonClick, function()
    self.lytTips:SetVisible(false)
    if self.sureCb then
      self:sureCb(self.cbVar)
      self.sureCb = nil
      self.cbVar = nil
    end
  end)
  self:subscribe(self.btnTipsCancel, UIEvent.EventButtonClick, function()
    self.lytTips:SetVisible(false)
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = World.Timer(5, function()
    local pos = self.mainCamera:getPosition()
    pos.x = math.floor(pos.x * 100) / 100
    pos.y = math.floor(pos.y * 100) / 100
    pos.z = math.floor(pos.z * 100) / 100
    local _, _, r = self.mainCamera:getOrientation():toEulerAngle()
    local pitch = math.floor(Blockman.instance:getViewerPitch() * 100) / 100
    local yaw = math.floor(Blockman.instance:getViewerYaw() * 100) / 100
    local roll = math.floor(r * 100) / 100
    if not self.isLockBP then
      self.cameraEditBeginPointSet:SetText(tostring(pos.x .. "," .. pos.y .. "," .. pos.z))
    end
    if not self.isLockEP then
      self.cameraEditEndPointSet:SetText(tostring(pos.x .. "," .. pos.y .. "," .. pos.z))
    end
    if not self.isLockBR then
      self.cameraEditBeginRotateSet:SetText(tostring(pitch .. "," .. yaw .. "," .. roll))
    end
    if not self.isLockER then
      self.cameraEditEndRotateSet:SetText(tostring(pitch .. "," .. yaw .. "," .. roll))
    end
    return true
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent("EVENT_NODE_SEL", function(idx)
    if curSelNodeIdx ~= idx and dataList[curSelNodeIdx] and not dataList[curSelNodeIdx].time and (self.isLockBP or self.isLockEP or self.isLockBR or self.isLockER) then
      self:showTips("\229\189\147\229\137\141\232\138\130\231\130\185\229\176\154\230\156\170\228\191\157\229\173\152,\229\136\135\230\141\162\232\138\130\231\130\185\229\176\134\228\184\162\229\164\177\229\189\147\229\137\141\229\183\178\233\148\129\229\174\154\228\191\161\230\129\175\239\188\129", self.selNode, idx)
      return
    end
    self:selNode(idx)
  end)
end

function M:initView()
  self.mainCamera = Camera.getActiveCamera()
  self.lstCameraEditListContent:ClearAllItem()
  self.lytTips:SetVisible(false)
  self.lytCameraEditActionEditPanel:SetVisible(false)
  self:resetNodeEditState()
  self:listDataReset()
end

function M:showTips(info, sureCb, cbVar)
  self.sureCb = sureCb
  self.cbVar = cbVar
  self.lytTips:SetVisible(true)
  self.txtTipsInfo:SetText(info)
end

function M:resetNodeEditState()
  self.btnCameraEditLockBP:SetBackgroundColor({
    1,
    0,
    0,
    1
  })
  self.btnCameraEditLockBP:SetText("\232\135\170\231\148\177")
  self.btnCameraEditLockEP:SetBackgroundColor({
    1,
    0,
    0,
    1
  })
  self.btnCameraEditLockEP:SetText("\232\135\170\231\148\177")
  self.btnCameraEditLockBR:SetBackgroundColor({
    1,
    0,
    0,
    1
  })
  self.btnCameraEditLockBR:SetText("\232\135\170\231\148\177")
  self.btnCameraEditLockER:SetBackgroundColor({
    1,
    0,
    0,
    1
  })
  self.btnCameraEditLockER:SetText("\232\135\170\231\148\177")
  self.cameraEditTimeSet:SetText("1")
  self.isLockBP = false
  self.isLockEP = false
  self.isLockBR = false
  self.isLockER = false
end

function M:listDataReset()
  dataList = {}
  self.timeline = nil
end

function M:initActionData()
  dataList = {}
  self.lstCameraEditListContent:ClearAllItem()
  self.lytCameraEditActionEditPanel:SetVisible(true)
  self:resetNodeEditState()
  if self.timeLineFile then
    io.close(self.timeLineFile)
    self.timeLineFile = nil
  end
  self.filename = self.cameraEditCameraName:GetPropertyString("Text", "0")
  local path = string.format("%sresource/movie/%s/%s.xml", Root.Instance():getGamePath(), self.filename, self.filename)
  self.timeLineFile = io.open(path)
  if not self.timeLineFile then
    local rootPath = string.format("%sresource/movie/%s", Root.Instance():getGamePath(), self.filename)
    rootPath = string.gsub(rootPath, "/", "\\")
    lfs.mkdir(rootPath)
    self.timeLineFile = io.open(path, "w+")
    self:addNode()
  else
    self:initCameraTrackFile()
  end
end

function M:initCameraTrackFile()
  local path = string.format("%sresource/movie/%s/camera_track.xml", Root.Instance():getGamePath(), self.filename, self.filename)
  self.cameraTrackFile = io.open(path)
  if not self.cameraTrackFile then
    self:addNode()
  else
    local element = {
      name = "",
      attribute = {}
    }
    local parser = SLAXML:parser({
      startElement = function(name, nsURI, nsPrefix)
        element.name = name
      end,
      attribute = function(name, value, nsURI, nsPrefix)
        element.attribute[name] = value
      end,
      closeElement = function(name, nsURI)
        local newBegin = true
        if element.name == "CameraViewFrame" then
          local pos = Lib.splitString(element.attribute.pos, ",")
          local yaw = tonumber(element.attribute.yaw)
          local pitch = tonumber(element.attribute.pitch)
          local smooth = tonumber(element.attribute.smooth)
          if 0 < smooth then
            local node = dataList[#dataList]
            node.over.x = tonumber(pos[1])
            node.over.y = tonumber(pos[2])
            node.over.z = tonumber(pos[3])
            node.over.rp = pitch
            node.over.ry = yaw
            node.over.rr = 0
            node.time = smooth / 20
            self:addNode(true)
          else
            local node = {}
            node.begin = {}
            node.over = {}
            node.begin.x = pos[1]
            node.begin.y = pos[2]
            node.begin.z = pos[3]
            node.begin.rp = pitch
            node.begin.ry = yaw
            node.begin.rr = 0
            table.insert(dataList, node)
          end
        end
        element = {
          name = "",
          attribute = {}
        }
      end
    })
    parser:parse(self.cameraTrackFile:read("*all"), {stripWhitespace = true})
    io.close(self.cameraTrackFile)
    self.cameraTrackFile = nil
    self:calcAllTime()
  end
end

function M:saveNode()
  if not (self.isLockBP and self.isLockBR and self.isLockEP) or not self.isLockER then
    self:showTips("\230\156\137\229\143\130\230\149\176\230\156\170\233\148\129\229\174\154\239\188\129")
    return
  end
  local bp = Lib.splitString(self.cameraEditBeginPointSet:GetPropertyString("Text", "0"), ",")
  local ep = Lib.splitString(self.cameraEditEndPointSet:GetPropertyString("Text", "0"), ",")
  local br = Lib.splitString(self.cameraEditBeginRotateSet:GetPropertyString("Text", "0"), ",")
  local er = Lib.splitString(self.cameraEditEndRotateSet:GetPropertyString("Text", "0"), ",")
  if #bp ~= 3 or #ep ~= 3 or #br ~= 3 then
    print("DATA ERROR")
  end
  local node = {}
  node.begin = {}
  node.over = {}
  node.begin.x = bp[1]
  node.begin.y = bp[2]
  node.begin.z = bp[3]
  node.begin.rp = br[1]
  node.begin.ry = br[2]
  node.begin.rr = br[3]
  node.over.x = ep[1]
  node.over.y = ep[2]
  node.over.z = ep[3]
  node.over.rp = er[1]
  node.over.ry = er[2]
  node.over.rr = er[3]
  node.time = tonumber(self.cameraEditTimeSet:GetPropertyString("Text", "1"))
  dataList[curSelNodeIdx] = node
  self:calcAllTime()
end

function M:selNode(idx)
  for i = 0, self.lstCameraEditListContent:GetItemCount() - 1 do
    print("iselectNodeselectNodeselectNodeselectNode:", i)
    self.lstCameraEditListContent:GetItem(i):invoke("selectNode", false)
  end
  curSelNodeIdx = idx
  local curData = dataList[curSelNodeIdx]
  if curData and curData.time then
    self.btnCameraEditLockBP:SetBackgroundColor({
      0,
      0.5,
      0,
      1
    })
    self.btnCameraEditLockBP:SetText("\233\148\129\229\174\154")
    self.btnCameraEditLockEP:SetBackgroundColor({
      0,
      0.5,
      0,
      1
    })
    self.btnCameraEditLockEP:SetText("\233\148\129\229\174\154")
    self.btnCameraEditLockBR:SetBackgroundColor({
      0,
      0.5,
      0,
      1
    })
    self.btnCameraEditLockBR:SetText("\233\148\129\229\174\154")
    self.btnCameraEditLockER:SetBackgroundColor({
      0,
      0.5,
      0,
      1
    })
    self.btnCameraEditLockER:SetText("\233\148\129\229\174\154")
    self.cameraEditBeginPointSet:SetText(curData.begin.x .. "," .. curData.begin.y .. "," .. curData.begin.z)
    self.cameraEditEndPointSet:SetText(curData.over.x .. "," .. curData.over.y .. "," .. curData.over.z)
    self.cameraEditBeginRotateSet:SetText(curData.begin.rp .. "," .. curData.begin.ry .. "," .. curData.begin.rr)
    self.cameraEditEndRotateSet:SetText(curData.over.rp .. "," .. curData.over.ry .. "," .. curData.over.rr)
    self.cameraEditTimeSet:SetText(curData.time .. "")
    self.isLockBP = true
    self.isLockEP = true
    self.isLockBR = true
    self.isLockER = true
  else
    self:resetNodeEditState()
  end
  if curSelNodeIdx <= self.lstCameraEditListContent:GetItemCount() then
    self.lstCameraEditListContent:GetItem(curSelNodeIdx - 1):invoke("selectNode", true)
  end
end

function M:setTailNodeBeginPos()
  if dataList and dataList[curSelNodeIdx] and not dataList[curSelNodeIdx - 1] then
    perror("cant find last node \239\188\129")
    return
  end
  local lastSecNode = dataList[curSelNodeIdx - 1]
  self.isLockBP = true
  self.btnCameraEditLockBP:SetBackgroundColor({
    0,
    0.5,
    0,
    1
  })
  self.btnCameraEditLockBP:SetText("\233\148\129\229\174\154")
  self.isLockBR = true
  self.btnCameraEditLockBR:SetBackgroundColor({
    0,
    0.5,
    0,
    1
  })
  self.btnCameraEditLockBR:SetText("\233\148\129\229\174\154")
  self.cameraEditBeginPointSet:SetText(lastSecNode.over.x .. "," .. lastSecNode.over.y .. "," .. lastSecNode.over.z)
  self.cameraEditBeginRotateSet:SetText(lastSecNode.over.rp .. "," .. lastSecNode.over.ry .. "," .. lastSecNode.over.rr)
  self:jumpBeginEditPos()
  self:jumpBeginEditRotate()
end

function M:jumpBeginEditPos()
  local bp = Lib.splitString(self.cameraEditBeginPointSet:GetPropertyString("Text", "0"), ",")
  local pos = {
    x = bp[1],
    y = bp[2] - 1.62,
    z = bp[3]
  }
  Me:setPosition(pos)
end

function M:jumpBeginEditRotate()
  local bp = Lib.splitString(self.cameraEditBeginRotateSet:GetPropertyString("Text", "0"), ",")
  Me:changeCameraView(nil, bp[2], bp[1], 0, 0)
end

function M:addNode(dontInsert)
  if dataList and dataList[#dataList] and not dataList[#dataList].time then
    self:showTips("\229\176\190\232\138\130\231\130\185\229\176\154\230\156\170\233\148\129\229\174\154\239\188\129")
    return false
  end
  if self.lstCameraEditListContent:GetItemCount() > 0 then
    self.lstCameraEditListContent:GetItem(self.lstCameraEditListContent:GetItemCount() - 1):invoke("setTailShow", true)
  end
  local node = UIMgr:new_widget("cameraNode")
  node:invoke("initNormalNode", self.lstCameraEditListContent:GetItemCount() + 1)
  self.lstCameraEditListContent:AddItem(node, true, self.lstCameraEditListContent:GetItemCount() - 1)
  if not dontInsert then
    table.insert(dataList, {})
  end
  curSelNodeIdx = #dataList
  return true
end

function M:delNode()
  if self.lstCameraEditListContent:GetItemCount() < 2 then
    return
  end
  table.remove(dataList, self.lstCameraEditListContent:GetItemCount())
  if curSelNodeIdx == self.lstCameraEditListContent:GetItemCount() then
    curSelNodeIdx = self.lstCameraEditListContent:GetItemCount() - 1
  end
  self.lstCameraEditListContent:GetItem(self.lstCameraEditListContent:GetItemCount() - 2):invoke("setTailShow", false)
  self.lstCameraEditListContent:GetItem(self.lstCameraEditListContent:GetItemCount() - 2):invoke("selectNode", true)
  self.lstCameraEditListContent:DeleteItem(self.lstCameraEditListContent:GetItemCount() - 1)
  print("self.lstCameraEditListContent:GetItemCount()-1::", self.lstCameraEditListContent:GetItemCount())
end

function M:showOrHideDebugThing(isShow)
  self.lytCameraEditFrame:SetTouchable(not isShow)
  self.lytCameraEditCtrl:SetVisible(isShow)
end

function M:reviewNode()
  if not (self.isLockBP and self.isLockBR and self.isLockEP) or not self.isLockER then
    self:showTips("\230\156\137\229\143\130\230\149\176\230\156\170\233\148\129\229\174\154\239\188\129Slerp")
    return
  end
  self:saveNode()
  self:showOrHideDebugThing(false)
  local bp = {
    x = dataList[curSelNodeIdx].begin.x,
    y = dataList[curSelNodeIdx].begin.y,
    z = dataList[curSelNodeIdx].begin.z
  }
  local ep = {
    x = dataList[curSelNodeIdx].over.x,
    y = dataList[curSelNodeIdx].over.y,
    z = dataList[curSelNodeIdx].over.z
  }
  Blockman.instance:setPersonView(freeVis)
  Me:changeCameraView(bp, tonumber(dataList[curSelNodeIdx].begin.ry), tonumber(dataList[curSelNodeIdx].begin.rp), 0, 0)
  World.Timer(20, function()
    Me:changeCameraView(ep, tonumber(dataList[curSelNodeIdx].over.ry), tonumber(dataList[curSelNodeIdx].over.rp), 0, 20 * dataList[curSelNodeIdx].time)
    World.Timer(20 + 20 * dataList[curSelNodeIdx].time, function()
      Blockman.instance:setPersonView(editVis)
      self:showOrHideDebugThing(true)
    end)
  end)
end

function M:table2xmlAndWrite()
  if self.cameraTrackFile then
    io.close(self.cameraTrackFile)
    self.cameraTrackFile = nil
  end
  local path = string.format("%sresource/movie/%s/camera_track.xml", Root.Instance():getGamePath(), self.filename, self.filename)
  self.cameraTrackFile = io.open(path, "w+")
  local lastNode = dataList[#dataList]
  self.cameraTrackFile:write("<Track pos=\"" .. tostring(lastNode.over.x .. "," .. lastNode.over.y .. "," .. lastNode.over.z) .. "\" yaw=\"" .. lastNode.over.ry .. "\" pitch=\"" .. lastNode.over.rp .. "\"/>\n")
  self.cameraTrackFile:write("<CameraViewModeFrame viewMode=\"4\" smooth=\"15\" startTime=\"0\"/>\n")
  local startTime = 0
  for i, node in pairs(dataList) do
    startTime = startTime + 1
    self.cameraTrackFile:write("<CameraViewFrame pos=\"" .. tostring(node.begin.x .. "," .. node.begin.y .. "," .. node.begin.z) .. "\" yaw=\"" .. node.begin.ry .. "\" pitch=\"" .. node.begin.rp .. "\" distance=\"0\" smooth=\"0\" startTime=\"" .. startTime .. "\"/>\n")
    startTime = startTime + 1
    self.cameraTrackFile:write("<CameraViewFrame pos=\"" .. tostring(node.over.x .. "," .. node.over.y .. "," .. node.over.z) .. "\" yaw=\"" .. node.over.ry .. "\" pitch=\"" .. node.over.rp .. "\" distance=\"0\" smooth=\"" .. math.floor(node.time * 20) .. "\" startTime=\"" .. startTime .. "\"/>\n")
    startTime = -1 + startTime + node.time * 1000
  end
  io.close(self.cameraTrackFile)
  self.cameraTrackFile = nil
end

function M:delCameraViewModeFrame()
  if self.cameraTrackFile then
    io.close(self.cameraTrackFile)
    self.cameraTrackFile = nil
  end
  local path = string.format("%sresource/movie/%s/camera_track.xml", Root.Instance():getGamePath(), self.filename, self.filename)
  self.cameraTrackFile = io.open(path, "w+")
  local lastNode = dataList[#dataList]
  self.cameraTrackFile:write("<Track pos=\"" .. tostring(lastNode.over.x .. "," .. lastNode.over.y .. "," .. lastNode.over.z) .. "\" yaw=\"" .. lastNode.over.ry .. "\" pitch=\"" .. lastNode.over.rp .. "\"/>\n")
  local startTime = 0
  for i, node in pairs(dataList) do
    startTime = startTime + 1
    self.cameraTrackFile:write("<CameraViewFrame pos=\"" .. tostring(node.begin.x .. "," .. node.begin.y .. "," .. node.begin.z) .. "\" yaw=\"" .. node.begin.ry .. "\" pitch=\"" .. node.begin.rp .. "\" distance=\"0\" smooth=\"0\" startTime=\"" .. startTime .. "\"/>\n")
    startTime = startTime + 1
    self.cameraTrackFile:write("<CameraViewFrame pos=\"" .. tostring(node.over.x .. "," .. node.over.y .. "," .. node.over.z) .. "\" yaw=\"" .. node.over.ry .. "\" pitch=\"" .. node.over.rp .. "\" distance=\"0\" smooth=\"" .. math.floor(node.time * 20) .. "\" startTime=\"" .. startTime .. "\"/>\n")
    startTime = -1 + startTime + node.time * 1000
  end
  io.close(self.cameraTrackFile)
  self.cameraTrackFile = nil
end

function M:saveList()
  self:table2xmlAndWrite()
  local path = string.format("%sresource/movie/%s/%s.xml", Root.Instance():getGamePath(), self.filename, self.filename)
  self.timeLineFile = io.open(path, "r")
  self.timeLineFile:seek("set")
  local needLine = {}
  for line in self.timeLineFile:lines() do
    if not string.find(line, "TimeLine") and not string.find(line, "camera_track") then
      line = line .. "\n"
      print("line1:", line)
      table.insert(needLine, line)
    end
  end
  io.close(self.timeLineFile)
  self.timeLineFile = io.open(path, "w")
  self.timeLineFile:write("<TimeLine time=\"" .. math.floor(allTime * 1000) .. "\" keepViewMode=\"true\"/>\n")
  self.timeLineFile:write("<Track name=\"camera_track\" type=\"camera\"/>\n")
  for _, line in pairs(needLine) do
    self.timeLineFile:write(line)
  end
  io.close(self.timeLineFile)
  self.timeLineFile = nil
end

function M:reviewList()
  for _, node in pairs(dataList) do
    if not node.time then
      self:showTips("\229\173\152\229\156\168\231\169\186\232\138\130\231\130\185\239\188\129")
      return
    end
  end
  self:saveList()
  Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, self.filename)
  self:showOrHideDebugThing(false)
  World.Timer(60 + 20 * allTime, function()
    Blockman.instance:setPersonView(editVis)
    self:showOrHideDebugThing(true)
    self:delCameraViewModeFrame()
  end)
end

function M:calcAllTime()
  allTime = 0
  for _, node in pairs(dataList) do
    allTime = allTime + node.time
  end
  self.txtAllTime:SetText("\230\128\187\230\151\182\233\149\191\239\188\154" .. allTime .. "s")
end

function M:onHide()
  UI:closeWnd("cameraEdit")
  for _, name in pairs(World.cfg.mainUiList) do
    UI:openWnd(name)
  end
  UI:openWnd("toolbar")
  Me:setActorHide(false)
  Blockman.instance:setPersonView(normalVis)
  Me:setFlyMode(0)
  Me.cameraEditModeCtrl = false
  DebugDraw.instance:setEnabled(false)
  DebugDraw.instance:setCameraEditEnabled(false)
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("cameraEdit")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  for _, name in pairs(World.cfg.mainUiList) do
    UI:closeWnd(name)
  end
  UI:closeWnd("toolbar")
  Me:setActorHide(true)
  Me:setFlyMode(1)
  Me.cameraEditModeCtrl = true
  spdLevel = 2
  Me.camaraModeSpd = spdValList[spdLevel]
  self.txtSpd:SetText(spdName[spdLevel])
  Blockman.instance:setPersonView(editVis)
  DebugDraw.instance:setEnabled(true)
  DebugDraw.instance:setCameraEditEnabled(true)
  self.cameraEditCameraName:SetText("enter filename")
  self.showFunc = UI:hideOpenedWnd("cameraEdit")
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.showFunc then
    self.showFunc()
  end
end

return M
