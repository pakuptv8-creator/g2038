local EditorCommonUI = T(Lib, "EditorCommonUI")

function EditorCommonUI:init()
  Lib.subscribeEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, function(isShow, showTime)
    if isShow then
      UI:openWnd("mobileEditorClickMask", showTime)
    else
      UI:closeWnd("mobileEditorClickMask")
    end
  end)
end

function EditorCommonUI:playLoadingAnim(ui)
  ui:SetRotate(0)
  local curRotate = 0
  local rotateTimer = World.Timer(1, function()
    curRotate = (curRotate + 5) % 360
    ui:SetRotate(curRotate)
    return true
  end)
  return rotateTimer
end

EditorCommonUI:init()
