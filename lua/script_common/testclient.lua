handle_call = false
handle_tick = false
clients = {}
C = {}
playerCount = 0
Root = {}

function Root.Instance()
  return Root
end

function Root:getGamePath()
  return ""
end

require("common.preload")
require("common.data_cache_container")
require("common.lib")
require("common.math.math")
require("script_common.define")
local misc = require("misc")
local client = require("client")
local cjson = require("cjson")
local waitCos = {}
local nowTime = 0
local tokens = Lib.read_json_file("testacc.json") or {
  {
    name = "test01",
    userId = 18512,
    token = "234976807743fee23d9bd5ca5f1a81e86f50df76"
  },
  {
    name = "test02",
    userId = 18528,
    token = "0049d4c96e116711b79c6231c48d058e0bfc8483"
  },
  {
    name = "test03",
    userId = 18544,
    token = "3bbcc6ef5522d408d75e128e8e6404fc0c2a19c4"
  },
  {
    name = "test04",
    userId = 18560,
    token = "65f504586fe1a8c98d73ef139c893edfc913fda7"
  }
}
local engineVersionConfig = Lib.read_json_file("Media/engineVersion.json")
local engineVersion = engineVersionConfig and engineVersionConfig.engineVersion or 80999
local clientIndex = {}
local clientMeta = {__index = clientIndex}

local function run(co, ...)
  local ok, msg = coroutine.resume(co, ...)
  if not ok then
    print("ERROR!", traceback(co, msg))
  end
end

local function sleep(time)
  local co, main = coroutine.running()
  assert(not main)
  time = math.floor(time)
  if time < 1 then
    time = 1
  end
  time = nowTime + time
  local tb = waitCos[time]
  if not tb then
    tb = {}
    waitCos[time] = tb
  end
  tb[#tb + 1] = co
  coroutine.yield()
end

local function randomArray(array, n)
  local arr = {}
  for _, _ in pairs(array) do
    table.insert(arr, #arr + 1)
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 7))
  local result = {}
  for i = 1, n do
    local temp = math.random(#arr)
    table.insert(result, array[temp])
    table.remove(arr, temp)
  end
  return result
end

local handlers = {}

function handle_call(funcName, ...)
  local _, main = coroutine.running()
  assert(main, "in coroutine!")
  local func = assert(handlers[funcName], funcName)
  local co = coroutine.create(func)
  run(co, ...)
end

function handle_tick(frameTime)
  nowTime = nowTime + 1
  local cos = waitCos[nowTime]
  if not cos then
    return
  end
  waitCos[nowTime] = nil
  for _, co in ipairs(cos) do
    run(co)
  end
end

function handlers.event(id, event)
  local cl = clients[id]
  if event == "ConnectSuc" then
    cl:doLogin()
  else
    cl:close()
  end
end

function handlers.packet(id, name, packet)
  local cl = assert(clients[id], id)
  local func = cl[name]
  if func then
    func(cl, packet)
  else
  end
end

function handlers.cmd(cmd)
  assert(load(cmd, "@(cmd)"))()
end

function handlers.start()
end

function clientIndex:sendPacket(packet)
  local data = misc.data_encode(packet)
  self.c:sendScriptPacket(data)
end

function clientIndex:S2CPacketScriptPacket(packet)
  local packet = misc.data_decode(packet.data)
  local func = self[packet.pid]
  if func then
    func(self, packet)
  end
end

function clientIndex:GameInfo(packet)
  print("GameInfo", self.id, packet.objID, packet.pid)
  playerCount = playerCount + 1
  self.pos = Lib.tov3(packet.pos)
  self.objID = packet.objID
  self:sendPacket({
    pid = "ClientReady"
  })
end

function clientIndex:doLogin()
  local id = self.id
  local tk = tokens[id] or {
    name = "test0" .. id,
    userId = id,
    token = ""
  }
  local clientInfo = {
    device = "blockman",
    user_id = tostring(tk.userId),
    os_version = "android 4.4.4",
    manufacturer = "sandbox",
    platform = "android",
    android_id = tostring(os.time()) .. tostring(tk.userId),
    session_num = 1,
    version_code = "1",
    package_name = "com.sandboxol.blockymods"
  }
  self.c:sendLogin(tk.name, 123456789, tk.userId, tk.token, "zh_CN", cjson.encode(clientInfo), engineVersion)
end

function clientIndex:S2CPacketCheckCSVersionResult(packet)
  if not packet.m_success then
    return
  end
  self:doLogin()
end

function clientIndex:S2CPacketLoginResult(packet)
end

function clientIndex:S2CPacketEntityMovement(packet)
end

function clientIndex:S2CPacketPlayerCtrlVer(packet)
  self.ctrlVer = packet.m_ctrlVer
end

function clientIndex:gotoTarget(pos)
  self.targetPos = pos
  while self.targetPos == pos do
    local dir = pos - self.pos
    local len = dir:len()
    if len <= 0.5 then
      self.pos = pos
      self.targetPos = nil
    else
      self.pos = self.pos + dir * (0.5 / len)
    end
    self.c:sendMovement(self.pos.x, self.pos.y, self.pos.z, 0, 0, 0, true, self.targetPos == pos, self.ctrlVer)
    sleep(250)
  end
end

local function toPos(client, pos, run)
  client.pos.x = pos.x
  client.pos.y = pos.y
  client.pos.z = pos.z
  client.c:sendMovement(pos.x, pos.y, pos.z, 0, 0, 0, true, run, client.ctrlVer)
end

function clientIndex:close()
  print("CloseClient", self.id)
  clients[self.id] = nil
  self.c:close()
  self.id = nil
end

function C:cc(count, serverIp)
  count = count or 1
  local index = 0
  while count > index do
    local c = client.create()
    local id = c:id()
    clients[id] = setmetatable({c = c, id = id}, clientMeta)
    c:connect(serverIp or "127.0.0.1", 19130)
    index = index + 1
    sleep(200)
  end
end

function C:move(cls)
  local temp = {}
  for _, c in pairs(cls or clients) do
    table.insert(temp, c)
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 7))
  for _, client in ipairs(temp) do
    local x = math.random(3)
    local z = math.random(3)
    local ax = math.random(6)
    local az = math.random(6)
    local pos = Lib.copy(client.pos)
    pos.x = pos.x + (3 < ax and x or -x)
    pos.z = pos.z + (3 < az and z or -z)
    client.targetPos = pos
    client.finish = false
  end
  local run = true
  while run do
    for index, client in ipairs(temp) do
      if not client.finish then
        local dir = client.targetPos - client.pos
        local len = dir:len()
        if len < 0.5 then
          client.finish = true
          toPos(client, client.targetPos, false)
        else
          local targetPos = client.pos + dir * (0.125 / len)
          toPos(client, targetPos, true)
        end
      else
        local finishCount = 0
        for _, client in ipairs(temp) do
          if client.finish then
            finishCount = finishCount + 1
          end
        end
        if finishCount == #temp then
          run = false
        end
      end
    end
    sleep(50)
  end
end

function C:randMove(times, pCount, time)
  if pCount and pCount > playerCount then
    pCount = playerCount
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 7))
  local count = 0
  while count < (times or 1) do
    local num = pCount or math.random(playerCount)
    local result = randomArray(clients, num)
    self:move(result)
    count = count + 1
    sleep(1000)
  end
end

function C:stepMove(steps, interval)
  steps = steps or 1
  interval = interval or 100
  for i = 1, steps do
    for _, c in pairs(clients) do
      local pos = c.pos
      if pos then
        pos = {
          x = pos.x + math.random() * 0.6 - 0.3,
          y = pos.y,
          z = pos.z + math.random() * 0.6 - 0.3
        }
        toPos(c, pos, i < steps)
      end
    end
  end
end

function C:runaway()
  for _, client in pairs(clients) do
    client:sendPacket({
      pid = "BattleAction",
      type = Define.BATTLE_ACTION.RUNAWAY
    })
  end
end

function C:skill(times, time, name)
  time = time and time * 1000 or 4000
  local packet = {
    pid = "CastSkill",
    name = name or "myplugin/player_skill_shizizhan"
  }
  local count = 0
  while count < (times or 1) do
    for _, client in pairs(clients) do
      local pos = client.pos
      packet.startPos = pos
      packet.targetPos = {
        x = pos.x + 1,
        y = pos.y,
        z = pos.z
      }
      packet.fromID = client.objID
      client:sendPacket(packet)
    end
    count = count + 1
    sleep(time)
  end
end

function C:randSkill(times, pCount, time, name)
  time = time and time * 1000 or 4000
  if pCount and pCount > playerCount then
    pCount = playerCount
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 7))
  local packet = {
    pid = "CastSkill",
    name = name or "myplugin/player_skill_shizizhan"
  }
  local count = 0
  while count < (times or 1) do
    local num = pCount or math.random(playerCount)
    local result = randomArray(clients, num)
    for _, client in pairs(result) do
      local pos = client.pos
      packet.startPos = pos
      packet.targetPos = {
        x = pos.x + 1,
        y = pos.y,
        z = pos.z
      }
      packet.fromID = client.objID
      client:sendPacket(packet)
    end
    count = count + 1
    sleep(time)
  end
end
