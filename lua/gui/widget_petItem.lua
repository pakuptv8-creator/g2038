local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "PetItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPetItemBG = self:child("PetItem-BG")
  self.imgPetItemIconBG = self:child("PetItem-IconBG")
  self.imgPetItemIconImg = self:child("PetItem-Icon")
  self.txtPetItemPetID = self:child("PetItem-PetID")
  self.txtPetItemPetName = self:child("PetItem-PetName")
  self.imgPetItemPetType = self:child("PetItem-PetType")
  self.imgPetItemSelectImg = self:child("PetItem-SelectImg")
end

function M:initEvent()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
