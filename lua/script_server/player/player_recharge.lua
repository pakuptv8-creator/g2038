local function getPlayerRechargeAmount(userId, callback)
  AsyncProcess.GetSumRechargeGCube(userId, function(gcube)
    if type(gcube) ~= "number" then
      return
    end
    local player = Game.GetPlayerByUserId(userId)
    if not player then
      return
    end
    player:setRechargeSum(gcube)
    if callback then
      callback(gcube)
    end
  end)
end

function Player:onRechargeGCube()
  getPlayerRechargeAmount(self.platformUserId)
end
