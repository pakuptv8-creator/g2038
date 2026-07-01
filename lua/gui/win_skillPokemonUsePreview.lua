local SkillConfig = T(Config, "SkillConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local WinSkillPokemonUsePreview = M

function WinSkillPokemonUsePreview:init()
  WinBase.init(self, "SkillPokemonUsePreview.json")
  self:initUI()
  self:initEvent()
end

function WinSkillPokemonUsePreview:initUI()
  self.lytMask = self:child("SkillPokemonUsePreview-Mask")
  self.lytContentLyt = self:child("SkillPokemonUsePreview-ContentLyt")
  self.imgBG = self:child("SkillPokemonUsePreview-BG")
  self.imgTopBar = self:child("SkillPokemonUsePreview-TopBar")
  self.btnClose = self:child("SkillPokemonUsePreview-Close")
  self.txtTitle = self:child("SkillPokemonUsePreview-Title")
  self.imgPetsList = self:child("SkillPokemonUsePreview-petsList")
  self.gvPetList = UIMgr:new_widget("grid_view")
  self.imgPetsList:AddChildWindow(self.gvPetList)
  self.gvPetList:SetAutoColumnCount(false)
  self.gvPetList:SetItemAlignment(1)
  self.gvPetList:SetArea({0, 0}, {0, 13}, {1, 0}, {1, -26})
  self.gvPetList:InitConfig(31, 10, 4)
  self.adapter = UIMgr:new_adapter("pokemon_book", 128, 141)
  self.gvPetList:invoke("setAdapter", self.adapter)
end

function WinSkillPokemonUsePreview:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinSkillPokemonUsePreview:subscribeEvent()
end

function WinSkillPokemonUsePreview:initView()
  self.cfgsList = {}
  local skillCfg = SkillConfig:getConfigById(self.selectSkillId) or {}
  for _, cfgId in pairs(skillCfg.petsCanLearnList or {}) do
    local cfg = PokemonConfig:getConfigById(cfgId)
    table.insert(self.cfgsList, {
      cfg = cfg,
      select = false,
      lock = false,
      dontCreateStar = true
    })
  end
  table.sort(self.cfgsList, function(a, b)
    return a.cfg.bookId < b.cfg.bookId
  end)
  self.adapter:setData(self.cfgsList)
  self.adapter:setScrollOffset(0)
  self.txtTitle:SetText(Lang:toText(skillCfg.name) .. Lang:toText("ui_preview"))
end

function WinSkillPokemonUsePreview:onHide()
  UI:closeWnd("skillPokemonUsePreview")
end

function WinSkillPokemonUsePreview:onShow(selectSkillId)
  if not selectSkillId then
    self:onHide()
  end
  self.selectSkillId = selectSkillId
  UI:openWnd("skillPokemonUsePreview")
end

function WinSkillPokemonUsePreview:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function WinSkillPokemonUsePreview:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinSkillPokemonUsePreview
