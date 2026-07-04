local Player = _ENV.Player

function Player:showBiddingOpenEditor(blockId, screenShot)
  local editorData = {
    blockId = blockId,
    screenShot = screenShot or {
      pos = {
        x = 0,
        y = 35,
        z = 0
      },
      yaw = 15,
      pitch = 0
    }
  }
  Lib.logDebug("editorData === ", editorData)
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.tendering.tips",
    desc = "g2052.gui.tendering.is_go_editor",
    confirmCallback = function()
      UI:closeWnd("car")
      Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true, 40)
      Plugins.CallTargetPluginFunc("inner_mobile_editor", "enterEditorMode", editorData)
    end,
    cancelCallback = function()
    end
  })
end
