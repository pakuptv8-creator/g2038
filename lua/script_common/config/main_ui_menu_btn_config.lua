local MainUiMenuBtnConfig = T(Config, "MainUiMenuBtnConfig")
local settings = {}

function MainUiMenuBtnConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/main_ui_menu_btn.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      is_open = tonumber(vConfig.n_is_open) or 0,
      button_name = vConfig.s_button_name or "",
      title_name = vConfig.s_title_name or "",
      normal_res = vConfig.s_normal_res or "",
      effect_name = vConfig.s_effect_name or "",
      call_func = vConfig.s_call_func or "",
      show_type = tonumber(vConfig.n_show_type) or 0,
      line_num = tonumber(vConfig.n_line_num) or 0,
      priority = tonumber(vConfig.n_priority) or 0,
      click_sound = vConfig.click_sound or ""
    }
    data.button_size = Lib.splitString(vConfig.s_button_size or "", "#")
    data.effect_scale = Lib.splitString(vConfig.s_effect_scale or "", "#")
    if data.is_open == 1 then
      table.insert(settings, data)
    end
  end
  table.sort(settings, function(a, b)
    return tonumber(a.priority) < tonumber(b.priority)
  end)
end

function MainUiMenuBtnConfig:getCfgById(id)
  for _, val in pairs(settings) do
    if val.id == id then
      return val
    end
  end
  return nil
end

function MainUiMenuBtnConfig:getAllCfg()
  return settings
end

function MainUiMenuBtnConfig:getAllCfgByShowType(show_type)
  local items = {}
  for _, val in pairs(settings) do
    if val.show_type == show_type then
      table.insert(items, val)
    end
  end
  return items
end

return MainUiMenuBtnConfig
