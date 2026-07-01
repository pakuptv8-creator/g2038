local handles = T(Player, "PackageHandlers")
local LuaTimer = T(Lib, "LuaTimer")

function handles:swapStart(packet)
  if not Me:isCanShowOneInteractionWnd("pokemonSwap", packet.targetId) then
    return
  end
  local entity = World.CurWorld:getEntity(packet.targetId)
  if entity and entity:isValid() then
    UI:closeWnd("pokemonSwapApply")
    UI:openWnd("pokemonSwap", packet.targetId)
  end
end

function handles:showApplySwap(packet)
  UI:openWnd("pokemonSwapApply", "ask", packet.targetId)
end

function handles:quitSwap(packet)
  if UI:isOpen("pokemonSwapApply") or UI:isOpen("pokemonSwap") then
    local tipMap = {
      [Define.SWAP_END_CODE.CANCEL] = "gui.swap.tip.cancel",
      [Define.SWAP_END_CODE.FULL] = "gui.swap.tip.full",
      [Define.SWAP_END_CODE.REFUSE] = "gui.swap.tip.refuse",
      [Define.SWAP_END_CODE.ERROR] = "gui.swap.tip.error"
    }
    if packet.code ~= Define.SWAP_END_CODE.SUCCESS then
      local target = World.CurWorld:getEntity(packet.targetId)
      if target and target:isValid() then
        Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText(tipMap[packet.code]), target.name or target.nickName or ""), 60)
      end
    end
  end
  if UI:isOpen("pokemonSwapApply") then
    Me.swapLockMap = Me.swapLockMap or {}
    Me.swapLockMap[packet.targetId] = os.time()
    LuaTimer:schedule(function()
      Me.swapLockMap[packet.targetId] = nil
    end, World.cfg.swapLimitTime * 1000)
    UI:closeWnd("pokemonSwapApply")
  end
  if UI:isOpen("pokemonSwap") then
    UI:closeWnd("pokemonSwap")
  end
  if UI:isOpen("pokemonPacket") then
    UI:closeWnd("pokemonPacket")
  end
end

function handles:swapResult(packet)
  if packet.objId ~= 0 then
    Me:getPokemon(packet.objId, function(pokemon)
      UI:openWnd("pokemonSwapResult", pokemon)
    end)
  else
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.swap.end.no.pokemon"), 60)
  end
end
