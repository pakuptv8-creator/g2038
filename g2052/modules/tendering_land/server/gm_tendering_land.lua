local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\230\139\155\230\160\135/\233\155\149\229\131\143"] = function(self)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  TenderingAwardManager:updateMayorStatueInfo(1, "test")
end
GMItem["\230\139\155\230\160\135/\229\189\147\229\137\141\229\140\186ID"] = function(self)
  local roomGameConfig = Server.CurServer:getConfig()
  local regionId = roomGameConfig:getRegionId()
  print("--regionId--", regionId)
end
GMItem["\230\139\155\230\160\135/\232\175\183\230\177\130\229\165\150\229\138\177"] = function(self)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  TenderingAwardManager:requestWebSeasonResult()
  TenderingAwardManager:requestWebSocialAward()
end
GMItem["\230\139\155\230\160\135/\232\175\183\230\177\130\233\128\154\232\191\135\229\156\176\229\157\151"] = function(self)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  TenderingAwardManager:requestWebPassBlockIdList(self.platformUserId)
end
GMItem["\230\139\155\230\160\135/\232\190\147\229\135\186\229\140\186\229\143\183"] = function(self)
  local roomGameConfig = Server.CurServer:getConfig()
  local regionId = roomGameConfig:getRegionId()
  Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, regionId)
end
GMItem["\230\139\155\230\160\135/\230\136\145\230\152\175\229\184\130\233\149\191"] = function(self)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  local data = {
    honoraryMayor = {
      userId = self.platformUserId,
      nickName = self.name,
      sex = self:data("main").sex,
      createTime = 1,
      id = 1,
      picUrl = "",
      score = 1,
      season = 1,
      title = "test",
      updateTime = 2
    },
    honoraryMayorCounts = {
      [1] = {
        count = 1,
        userId = self.platformUserId
      }
    }
  }
  TenderingAwardManager:updateSocialHonorList(data)
end
GMItem["\230\139\155\230\160\135/\230\136\145\228\188\159\229\164\167\229\184\130\233\149\191"] = function(self)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  local data = {
    honoraryMayor = {
      userId = self.platformUserId,
      nickName = self.name,
      sex = self:data("main").sex,
      createTime = 1,
      id = 1,
      picUrl = "",
      score = 1,
      season = 1,
      title = "test",
      updateTime = 2
    },
    honoraryMayorCounts = {
      [1] = {
        count = World.cfg.tenderAwardSetting.bigMayorCount + 2,
        userId = self.platformUserId
      }
    }
  }
  TenderingAwardManager:updateSocialHonorList(data)
end
GMItem["\230\139\155\230\160\135/\232\190\147\229\133\165\228\184\173\230\160\135\229\156\176\229\157\151"] = GM:inputStr(function(self, value)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  local initData = Lib.copy(TenderingAwardManager.buildAwardData)
  local data = {
    userId = self.platformUserId,
    nickName = self.name,
    sex = self:data("main").sex,
    blockId = value,
    id = 1,
    picUrl = "",
    mapId = 1,
    season = 1,
    title = "test",
    updateTime = 2,
    likeNumber = 1,
    distrRegion = "",
    blockSeason = 1
  }
  for key, val in pairs(initData) do
    if val.blockId == value then
      initData[key] = data
      TenderingAwardManager:updateBuildHonorList(initData)
      return
    end
  end
  table.insert(initData, data)
  TenderingAwardManager:updateBuildHonorList(initData)
end)
GMItem["\230\139\155\230\160\135/\232\190\147\229\133\165\229\143\130\228\184\142\229\156\176\229\157\151"] = GM:inputStr(function(self, value)
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  local roomGameConfig = Server.CurServer:getConfig()
  local regionId = roomGameConfig:getRegionId()
  TenderingAwardManager:updateTakeTenderingAward({value}, self.platformUserId, regionId)
end)
GMItem["\230\139\155\230\160\135/\230\184\133\231\169\186\229\143\130\228\184\142\229\156\176\229\157\151"] = function(self)
  self:setTakeInLandCloth({})
  self:setTakeInLandPet({})
end
