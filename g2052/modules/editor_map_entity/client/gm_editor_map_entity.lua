local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\229\156\176\229\155\190\231\188\150\232\190\145/sceneUI"] = function()
  if Me.editor_map_entity then
    Me:setFlyMode(0)
    Me.editor_map_entity = false
    UI:closeWnd("editor_map_entity_ui")
  else
    Me:setFlyMode(1)
    Me.editor_map_entity = true
    UI:openWnd("editor_map_entity_ui")
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end
end
GMItem["\229\156\176\229\155\190\231\188\150\232\190\145/entity"] = function()
  if Me.editor_map_entity then
    Me:setFlyMode(0)
    Me.editor_map_entity = false
    UI:closeWnd("editor_map_entity_list_ui")
  else
    Me:setFlyMode(1)
    Me.editor_map_entity = true
    UI:openWnd("editor_map_entity_list_ui")
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end
end
