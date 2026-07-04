local PetMgr = T(Lib, "PetMgr")

function PetMgr:initPetListData(player)
  local petData = player:getPetData()
  player:syncPetData(petData)
  World.Timer(20, function()
    if player and player:isValid() then
      local petId = player:getCurCarryPetId()
      if petId and petId ~= 0 then
        local res = player:createPetToWorld(petId)
        if not res then
          player:setCurCarryPetId(0)
        end
      end
    end
  end)
end

return PetMgr
