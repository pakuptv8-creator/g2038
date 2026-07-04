local FacePhotoConfig = T(Config, "FacePhotoConfig")
local settings = {}

function FacePhotoConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/face_photo.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      typeId = tonumber(vConfig.n_typeId) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      faceImage = vConfig.s_faceImage or "",
      title = vConfig.s_title or "",
      desc = vConfig.s_desc or ""
    }
    data.goodsList = Lib.splitString(vConfig.s_goodsList or "", "#", true)
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.sortId < b.sortId
  end)
end

function FacePhotoConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgFacePhotoConfig, id:", id)
    return
  end
  return settings[id]
end

function FacePhotoConfig:getAllCfgs()
  return settings
end

FacePhotoConfig:init()
return FacePhotoConfig
