function Lib.getTextLineNum(str, widget, lineWidth)
  local strArr = Lib.split(str, "\n")
  
  local lineNum = 0
  for _, s in pairs(strArr) do
    local w = widget:GetFont():GetStringWidth(s)
    local num = math.ceil(w / lineWidth)
    lineNum = lineNum + num
  end
  return lineNum
end

function Lib.simplifyNumber2Str(num, div, pattern, keep)
  div = div or 1000
  pattern = pattern or "k"
  keep = keep or 1
  if num < div then
    return tostring(num)
  end
  local n = num / div
  local ret = string.format("%." .. keep .. "f", n)
  return ret .. pattern
end

function Lib.standardizingInput(str, keep, cutPattern)
  local s = World.CurWorld:filterWord(str)
  if not keep then
    return s
  end
  local lastIndex = Lib.subStringGetTotalIndex(s)
  if keep < lastIndex then
    s = Lib.subStringUTF8(s, 1, keep)
    if cutPattern ~= nil then
      s = s .. cutPattern
    end
  end
  return s
end

function Lib.attachModItemInfo(data, from)
  data.attachInfo = {from = from}
end

function Lib.getGameId()
  return World.GameName
end

function Lib.getG2052MainGameId()
  return Define.G2052GameName
end

function Lib.isG2052Game()
  return Lib.getGameId() == Lib.getG2052MainGameId()
end

function Lib.isG2052ModEditor()
  local isMobileEditor = not Blockman.instance.singleGame and CGame.instance:getIsMobileEditor() and not CGame.instance:getIsEditor()
  return isMobileEditor
end

function Lib.isG2052Mod()
  local isMobileEditor = Lib.isG2052ModEditor()
  local isG2052 = Lib.isG2052Game()
  return not isG2052 and not isMobileEditor
end

function Lib.isG2052ModOrEditor()
  local isG2052Mod = Lib.isG2052Mod()
  local isG2052ModEditor = Lib.isG2052ModEditor()
  return isG2052Mod or isG2052ModEditor
end

function Lib.setModMapItemDefaultImage(w)
  local path = World.cfg.modMapDefaultImagePath or ""
  w:SetImage(path)
end

function Lib.standardizeModTitle(s)
  s = s or ""
  if s == "" then
    return s
  end
  local max = World.cfg.modTitleWordMax
  return string.sub(s, 1, max)
end
