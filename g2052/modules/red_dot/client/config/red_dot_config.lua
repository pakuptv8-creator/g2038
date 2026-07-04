local RedDotConfig = T(Config, "RedDotConfig")
local prefix = "rd"
local allocatedKeys = {}

function RedDotConfig:allocateKey(level)
  if type(level) ~= "number" or level < 1 then
    return ""
  end
  local key = prefix
  for i = 1, level do
    if not allocatedKeys[i] then
      allocatedKeys[i] = 0
    end
    local idx = i == level and allocatedKeys[i] + 1 or allocatedKeys[i]
    if i == level then
      allocatedKeys[i] = allocatedKeys[i] + 1
    end
    key = key .. "_" .. idx
  end
  return key
end

RedDotConfig.RD_KEY = {
  AppearanceEntrance = RedDotConfig:allocateKey(1),
  VehicleEntrance = RedDotConfig:allocateKey(1),
  HouseEntrance = RedDotConfig:allocateKey(1),
  BagEntrance = RedDotConfig:allocateKey(1),
  ClothingTab = RedDotConfig:allocateKey(2),
  AccessoriesTab = RedDotConfig:allocateKey(2),
  BodyTab = RedDotConfig:allocateKey(2),
  ExpressionTab = RedDotConfig:allocateKey(2),
  BagAllTab = RedDotConfig:allocateKey(2),
  BagLifeTab = RedDotConfig:allocateKey(2),
  BagGamesTab = RedDotConfig:allocateKey(2),
  BagCareerTab = RedDotConfig:allocateKey(2),
  BagFoodTab = RedDotConfig:allocateKey(2),
  BagHasNewAll = RedDotConfig:allocateKey(3),
  BagHasNewLife = RedDotConfig:allocateKey(3),
  BagHasNewGames = RedDotConfig:allocateKey(3),
  BagHasNewCareer = RedDotConfig:allocateKey(3),
  BagHasNewFood = RedDotConfig:allocateKey(3),
  SuitsTab = RedDotConfig:allocateKey(3),
  TopsTab = RedDotConfig:allocateKey(3),
  PantsTab = RedDotConfig:allocateKey(3),
  TopsGirlTab = RedDotConfig:allocateKey(3),
  PantsGirlTab = RedDotConfig:allocateKey(3),
  ShoesTab = RedDotConfig:allocateKey(3),
  HasNewSuits = RedDotConfig:allocateKey(4),
  HasNewTops = RedDotConfig:allocateKey(4),
  HasNewPants = RedDotConfig:allocateKey(4),
  HasNewTopsGirl = RedDotConfig:allocateKey(4),
  HasNewPantsGirl = RedDotConfig:allocateKey(4),
  HasNewShoes = RedDotConfig:allocateKey(4),
  HatTab = RedDotConfig:allocateKey(3),
  HairTab = RedDotConfig:allocateKey(3),
  HeadTab = RedDotConfig:allocateKey(3),
  BagTab = RedDotConfig:allocateKey(3),
  WaistTab = RedDotConfig:allocateKey(3),
  HasNewHat = RedDotConfig:allocateKey(4),
  HasNewHair = RedDotConfig:allocateKey(4),
  HasNewHead = RedDotConfig:allocateKey(4),
  HasNewBag = RedDotConfig:allocateKey(4),
  HasNewWaist = RedDotConfig:allocateKey(4),
  HasNewColor = RedDotConfig:allocateKey(3),
  HasNewExpression = RedDotConfig:allocateKey(3),
  HasNewVehicle = RedDotConfig:allocateKey(2),
  HasNewHouse = RedDotConfig:allocateKey(2)
}
RedDotConfig.profile = {
  [RedDotConfig.RD_KEY.AppearanceEntrance] = {
    [RedDotConfig.RD_KEY.ClothingTab] = {
      [RedDotConfig.RD_KEY.SuitsTab] = {
        RedDotConfig.RD_KEY.HasNewSuits
      },
      [RedDotConfig.RD_KEY.TopsTab] = {
        RedDotConfig.RD_KEY.HasNewTops
      },
      [RedDotConfig.RD_KEY.PantsTab] = {
        RedDotConfig.RD_KEY.HasNewPants
      },
      [RedDotConfig.RD_KEY.TopsGirlTab] = {
        RedDotConfig.RD_KEY.HasNewTopsGirl
      },
      [RedDotConfig.RD_KEY.PantsGirlTab] = {
        RedDotConfig.RD_KEY.HasNewPantsGirl
      },
      [RedDotConfig.RD_KEY.ShoesTab] = {
        RedDotConfig.RD_KEY.HasNewShoes
      }
    },
    [RedDotConfig.RD_KEY.AccessoriesTab] = {
      [RedDotConfig.RD_KEY.HatTab] = {
        RedDotConfig.RD_KEY.HasNewHat
      },
      [RedDotConfig.RD_KEY.HairTab] = {
        RedDotConfig.RD_KEY.HasNewHair
      },
      [RedDotConfig.RD_KEY.HeadTab] = {
        RedDotConfig.RD_KEY.HasNewHead
      },
      [RedDotConfig.RD_KEY.BagTab] = {
        RedDotConfig.RD_KEY.HasNewBag
      },
      [RedDotConfig.RD_KEY.WaistTab] = {
        RedDotConfig.RD_KEY.HasNewWaist
      }
    }
  },
  [RedDotConfig.RD_KEY.VehicleEntrance] = {
    RedDotConfig.RD_KEY.HasNewVehicle
  },
  [RedDotConfig.RD_KEY.HouseEntrance] = {
    RedDotConfig.RD_KEY.HasNewHouse
  },
  [RedDotConfig.RD_KEY.BagEntrance] = {
    [RedDotConfig.RD_KEY.BagAllTab] = {
      RedDotConfig.RD_KEY.BagHasNewAll
    },
    [RedDotConfig.RD_KEY.BagLifeTab] = {
      RedDotConfig.RD_KEY.BagHasNewLife
    },
    [RedDotConfig.RD_KEY.BagGamesTab] = {
      RedDotConfig.RD_KEY.BagHasNewGames
    },
    [RedDotConfig.RD_KEY.BagCareerTab] = {
      RedDotConfig.RD_KEY.BagHasNewCareer
    },
    [RedDotConfig.RD_KEY.BagFoodTab] = {
      RedDotConfig.RD_KEY.BagHasNewFood
    }
  }
}
return RedDotConfig
