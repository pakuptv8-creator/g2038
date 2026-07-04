local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local FacePhotoHelper = T(Lib, "FacePhotoHelper")

function Entity.ValueFunc:isWeekFirstLogin(value)
  if self.isMainPlayer then
    FacePhotoHelper:checkOpenFaceWnd()
  end
end
