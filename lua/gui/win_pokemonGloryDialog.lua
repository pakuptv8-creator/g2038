function M:init()
  WinBase.init(self, "PokemonGloryDialog.json", false)
  
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonGloryDialogMask = self:child("PokemonGloryDialog-Mask")
  self.lytPokemonGloryDialogBg = self:child("PokemonGloryDialog-Bg")
  self.txtPokemonGloryDialogTitle = self:child("PokemonGloryDialog-Title")
  self.btnPokemonGloryDialogClose = self:child("PokemonGloryDialog-Close")
  self.imgPokemonGloryDialogIcon = self:child("PokemonGloryDialog-Icon")
  self.txtPokemonGloryDialogTitleName = self:child("PokemonGloryDialog-TitleName")
  self.txtPokemonGloryDialogQuality = self:child("PokemonGloryDialog-Quality")
  self.txtPokemonGloryDialogDate = self:child("PokemonGloryDialog-Date")
  self.txtPokemonGloryDialogSource = self:child("PokemonGloryDialog-Source")
  self.btnPokemonGloryDialogAction = self:child("PokemonGloryDialog-Action")
  self.imgPokemonGloryDialogTips = self:child("PokemonGloryDialog-Tips")
  self.txtPokemonGloryDialogCatchTime = self:child("PokemonGloryDialog-CatchTime")
  self.txtPokemonGloryDialogCatchTime:SetText(Lang:toText("title_be_catched"))
  local strWidth = math.max(0, self.txtPokemonGloryDialogCatchTime:GetFont():GetStringWidth(Lang:toText("title_be_catched")) - 200)
  print("strWidth:", strWidth)
  self.imgPokemonGloryDialogTips:SetXPosition({
    0,
    -strWidth / 2 - 35
  })
  self.txtPokemonGloryDialogCatchTitle = self:child("PokemonGloryDialog-CatchTitle")
  self.txtPokemonGloryDialogCatchTitle:SetText(Lang:toText("title_catch_glory"))
  self.imgPokemonGloryDialogCatchBg = self:child("PokemonGloryDialog-CatchBg")
  self.lytPokemonGloryDialogCatchEffect = self:child("PokemonGloryDialog-Catch-Effect")
end

function M:initEvent()
  self:subscribe(self.btnPokemonGloryDialogClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("pokemonGloryDialog")
  end)
  self:subscribe(self.btnPokemonGloryDialogAction, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "SwitchCurSelGlory",
      id = self.id
    })
    UI:closeWnd("pokemonGloryDialog")
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("pokemonGloryDialog")
end

local function getBorderColor(r, g, b)
  return tostring(r / 255) .. " " .. tostring(g / 255) .. " " .. tostring(b / 255) .. " 1"
end

function M:onShow(data, isNew)
  Me.waitShowGlory = false
  self.id = data.id
  self.imgPokemonGloryDialogCatchBg:SetVisible(isNew)
  self.lytPokemonGloryDialogCatchEffect:SetVisible(isNew)
  self.txtPokemonGloryDialogCatchTime:SetVisible(false)
  self.txtPokemonGloryDialogTitle:SetText(Lang:toText(data.name))
  self.txtPokemonGloryDialogTitleName:SetText(Lang:toText(data.title))
  self.txtPokemonGloryDialogQuality:SetText(Lang:toText("title_quality") .. Lang:toText("quality_font_" .. data.rare))
  self.txtPokemonGloryDialogSource:SetText(Lang:toText("title_source") .. Lang:toText(data.info))
  self.imgPokemonGloryDialogIcon:SetImage(data.icon)
  local gloryInfo = Me:getGloryInfoById(data.id)
  if gloryInfo then
    local catchTime = gloryInfo.time
    self.txtPokemonGloryDialogDate:SetText(Lang:toText("title_last_time") .. Lib.getMonth(catchTime) .. "." .. Lib.getDayOfMonth(catchTime) .. "." .. Lib.getYear(catchTime))
    if gloryInfo.status == Define.GLORY_STATUS.GAIN then
      self.btnPokemonGloryDialogAction:SetVisible(true)
      if Me:getCurSelGlory() == data.id then
        self.btnPokemonGloryDialogAction:SetNormalImage("set:pokemon_pet_packet.json image:btn_9_universal_red")
        self.btnPokemonGloryDialogAction:SetPushedImage("set:pokemon_pet_packet.json image:btn_9_universal_red")
        self.btnPokemonGloryDialogAction:SetProperty("TextBorderColor", getBorderColor(186, 42, 22))
        self.btnPokemonGloryDialogAction:SetText(Lang:toText("btn_title_unequip"))
      else
        self.btnPokemonGloryDialogAction:SetNormalImage("set:pokemon_bag.json image:btn_9_universal_green")
        self.btnPokemonGloryDialogAction:SetPushedImage("set:pokemon_bag.json image:btn_9_universal_green")
        self.btnPokemonGloryDialogAction:SetProperty("TextBorderColor", getBorderColor(71, 105, 17))
        self.btnPokemonGloryDialogAction:SetText(Lang:toText("btn_title_equip"))
      end
      self.lytPokemonGloryDialogBg:SetArea({0, 0}, {0, 0}, {0, 676}, {0, 357})
    elseif gloryInfo.status == Define.GLORY_STATUS.LOST then
      self.btnPokemonGloryDialogAction:SetVisible(false)
      self.lytPokemonGloryDialogBg:SetArea({0, 0}, {0, 0}, {0, 676}, {0, 300})
      self.txtPokemonGloryDialogCatchTime:SetVisible(true)
    end
  else
    self.txtPokemonGloryDialogDate:SetText(Lang:toText("title_nerver_catch"))
    self.btnPokemonGloryDialogAction:SetVisible(false)
    self.lytPokemonGloryDialogBg:SetArea({0, 0}, {0, 0}, {0, 676}, {0, 300})
  end
  UI:openWnd("pokemonGloryDialog")
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
