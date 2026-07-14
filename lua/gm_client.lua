local GMItem = GM:createGMItem()

local nextObjectID = 0x70000100

-- [GUI EXPLORER]
local guiWindows = {
    "limitedTimeDrawNew", "likes", "illustration", "guideLibrary", "graphic",
    "gameMain", "g2042Transaction", "g2042StarProgress", "g2042SignIn",
    "g2042Shop", "g2042GoldExchange", "friend", "fragmentPool",
    "fragmentLottery", "editRegionTool", "decorationHouse", "decorationEdit",
    "dance", "dailyGoldCoinTurntable", "commonDialogS", "commonDialogC",
    "commonDialog", "centerTip", "cardPreviewPhoto", "cardDeletePhoto",
    "cardAutograph", "card", "buyConfirm", "turntableRewardDialog", 
    "transitions", "tradeDialogTip", "syntheticReward", "synthetic", 
    "signInRewardDialog", "shopDialog", "rideTips", "recommendShop", 
    "previewPalette", "pokemonWorldTips", "phone", "petStarTips", 
    "petSellBoard", "petSell", "petHeadInfo", "petHatchingDialog", 
    "petEvolveDialog", "petEggBuyConfirm", "petBag", "petAtlas2D", 
    "petAtlas", "palette", "openApplicationJumpAnimation", 
    "obtainRewardDialog", "npcDialog", "littleAtlas", "buyBuiltinGame", 
    "bulletScreen", "builtinGameReward", "builtinGameRemain", "builtinGame", 
    "bubbleTextBox", "bottomTip", "blackboardText", "blackboard", "actionControl",
    "toolbar", "takePhotos", "skillPokemonUsePreview", "skillEffectDetailTip",
    "pokemonWake", "pokemonTransitionMap", "pokemonTelegraph", "pokemonTaskDetail",
    "pokemonTask", "pokemonSwapResult", "pokemonSwapApply", "pokemonSwap",
    "pokemonSpecialDialog", "pokemonSelect", "pokemonRotaryTable", "pokemonRotaryResult",
    "pokemonRequestTeamDialog", "pokemonRequestPkDialog", "pokemonReplace",
    "pokemonRename", "pokemonRelease", "pokemonRegularGift", "pokemonRecovery",
    "pokemonPvP", "pokemonPopupUpgrade", "pokemonPlayerDialog", "pokemonPacket",
    "pokemonOthersPlayer", "pokemonOpenScreen", "pokemonMain", "pokemonLuckyWish",
    "pokemonLuckyTenTake", "pokemonLuckyProbability", "pokemonLuckyPool",
    "pokemonLuckyOnceTake", "pokemonLuckyExtra", "pokemonLuckyEgg", "pokemonLuckyDetails",
    "pokemonLearnSkill", "pokemonLeaderboardReward", "pokemonLeaderboardReceive",
    "pokemonLeaderboard", "pokemonItemDetail", "pokemonGuideComplete", "pokemonGuide",
    "pokemonGloryHall", "pokemonGloryDialog", "pokemonGiftBag", "pokemonEvolutionShow",
    "pokemonEvolution", "pokemonCommonTip", "pokemonCommonDialog", "pokemonCellMove",
    "pokemonCaptureRelease", "pokemonCapture", "pokemonBlockInputEvents",
    "pokemonBlessRemove", "pokemonBlessing", "pokemonBigMap", "pokemonBagStudySkill",
    "pokemonBag", "pokemon_three_select_one", "pokemon_starUp_popup", "pokemon_Shop",
    "pokemon_recharge_award", "pokemon_gold_exchange", "pokemon_base_interactionUI",
    "petsBook", "mutatePopup", "minimap", "guide_go_to_shop", "get_item_tip",
    "followPetPrivilegeTip", "dailyLottery", "cutscene", "cameraEdit",
    "buyGiftTip", "bookDetails", "battle_select_target", "battle_results",
    "battle_pre_animation", "battle_pokemon", "battle_main", "battle_effect_tip",
    "battle_dialog"
}
for _, guiName in ipairs(guiWindows) do
    GMItem["Все_GUI/" .. guiName] = function() UI:openWnd(guiName) end
end

-------------------------------------------------------------------------------
-- [SHOP & PROMOTIONS]
-------------------------------------------------------------------------------
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local allRegularGifts = RegularGiftConfig:getAllConfig()

local tabNames = { [1] = "Daily", [2] = "Weekly", [3] = "Monthly" }
for _, gift in ipairs(allRegularGifts) do
    local folder = string.format("^AAFF55SHOP/%s", tabNames[gift.tabId] or "Other")
    local contentStr = ""
    for _, itemId in ipairs(gift.giftContent) do
        local cfg = RegularGiftItemConfig:getConfigById(tonumber(itemId))
        if cfg then contentStr = contentStr .. string.format("%sx%d ", cfg.itemName, cfg.itemCount) end
    end

    local btnName = string.format("%s (%d GC) [%s]", Lang:toText(gift.giftName), gift.finalPrice, contentStr)
    GMItem[folder .. "/" .. btnName] = function()
        Me:sendPacket({ pid = "requestBugRegularGift", itemId = gift.id, buyCount = 1 })
    end
end

-- [LIMITED TIME ACTIVITIES]
GMItem["^AAFF55SHOP/Toggle_All_Activities"] = function()
    -- LimitedTimeActivityGameMgr hack is already active in common
    print("Activities are forced visible via LimitedTimeActivityGameMgr hook.")
end

-------------------------------------------------------------------------------
-- [SPAM & CRASH]
-------------------------------------------------------------------------------
GMItem["^FF0000Spam/Chat_Spam"] = GM:inputStr(function(self, msg)
    if msg == "1" then self.stopSpam = true return true end
    self.stopSpam = false
    World.Timer(1, function()
        if self.stopSpam then return false end
        Me:sendPacket({ pid = "ChatMessage", msg = "&$[9900DD]$"..msg.."$ [S=vip_nameplate_10_plus.json]", type = 1 })
        return true
    end)
    return true
end)

GMItem["^FF0000КРАШ/^FFAA00Сервер Краш"] = function()
    local total = 0
    World.Timer(1, function()
        for i = 1, 50000 do Me:sendPacket({pid = "testPacket", counter = total + i}) end
        total = total + 50000
        return total < 1000000
    end)
end

-------------------------------------------------------------------------------
-- [ECONOMY & TICKETS]
-------------------------------------------------------------------------------
GMItem["^FF0000RealHacks/GcubeAdd_1M"] = function() PlayerWallet:setMoneyCount("gDiamonds", 1000000) end
GMItem["^FF0000RealHacks/GoldAdd_1M"] = function() PlayerWallet:setMoneyCount("gold", 1000000) end
GMItem["^FF0000RealHacks/Unlock_All_Lottery"] = function(self) self:deltaLotteryTimes(1000) end
GMItem["^FF0000RealHacks/Add_All_Tickets"] = function(self)
    for i=1,4 do self:addUpgradeCard(i, 999999) end
end

-------------------------------------------------------------------------------
-- [MOVEMENT & PHYSICS]
-------------------------------------------------------------------------------
GMItem["^00FF00NormalHacks/Fly_NoClip"] = function(self)
    self.flyM = not self.flyM; self:setFlyMode(self.flyM and 1 or 0)
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not self.flyM)
end
GMItem["^00FF00NormalHacks/Set_Speed"] = GM:inputStr(function(self, v) Me:setProp("moveSpeed", tonumber(v) or 1) end)
GMItem["^00FF00NormalHacks/Reach_Distance"] = GM:inputStr(function(self, v) Blockman.Instance():setReachDistance(tonumber(v) or 5) end)
GMItem["^00FF00NormalHacks/Infinite_Jump"] = function() World.Timer(1, function() Blockman.Instance():control():jump(); return true end) end
GMItem["^00FF00NormalHacks/Suicide"] = function(self) self:onDead({from = self, cause = "GM_SUICIDE"}) end

-------------------------------------------------------------------------------
-- [ULTRA HACKS]
-------------------------------------------------------------------------------
GMItem["^FFFF00ULTRA_HACKS/Solo_2vs2_Spoof"] = function()
    World.Solo2vs2 = not World.Solo2vs2
    print("Solo 2vs2 Spoof (Double Coins): " .. tostring(World.Solo2vs2))
end

GMItem["^FFFF00ULTRA_HACKS/Instant_Win_Battle"] = function() Me:sendPacket({pid = "BattleResult", result = 1}) end

-- [GOD-MODE PACKET GACHA]
GMItem["^FFFF00ULTRA_HACKS/Packet_Gacha_BURST"] = function(self)
    World.PacketGacha = not World.PacketGacha
    World.Timer(1, function()
        if not World.PacketGacha then return false end
        Me:sendPacket({pid = "GetTaskReward", taskid = 24})
        for tab = 1, 3 do Me:sendPacket({pid = "takeLuckyEggAward", tabType = tab, takeType = 1}) end
        local w2, w3 = UI:getWnd("pokemonLuckyTenTake"), UI:getWnd("pokemonLuckyOnceTake")
        if w2 and w2:isvisible() then w2:child("PokemonLuckyTenTake-confirmBtn"):CallHandler(UIEvent.EventButtonClick) end
        if w3 and w3:isvisible() then w3:child("PokemonLuckyOnceTake-confirmBtn"):CallHandler(UIEvent.EventButtonClick) end
        return true
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Auto_Sell_Epic_And_Below"] = function(self)
    World.AutoSellPets = not World.AutoSellPets
    World.Timer(40, function()
        if not World.AutoSellPets or Me:isInBattle() then return World.AutoSellPets end
        local pPL, bPL = Me:getValue("packetPetList") or {}, Me:getValue("battlePetList") or {}
        local function inT(id) for _,v in pairs(bPL) do if v==id then return true end end return false end
        Me:getPokemonList(pPL, function(pets)
            local toS = {}
            for _,p in pairs(pets) do
                if p:getQuality() <= 2 and not p:isLocked() and not inT(p:getObjId()) then table.insert(toS, p:getObjId()) end
                if #toS >= 10 then break end
            end
            if #toS>0 then Me:sendPacket({pid="sellPokemon", objIds=table.concat(toS, ":")}) end
        end)
        return World.AutoSellPets
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Smart_Auto_Awaken_Legs"] = function(self)
    World.SmartAwaken = not World.SmartAwaken
    World.Timer(60, function()
        if not World.SmartAwaken or Me:isInBattle() then return World.SmartAwaken end
        local pPL, bPL = Me:getValue("packetPetList") or {}, Me:getValue("battlePetList") or {}
        local function isForbidden(id) for _,v in pairs(bPL) do if v==id then return true end end return false end
        Me:getPokemonList(pPL, function(pets)
            local leg = {}
            for _,p in pairs(pets) do if p:getQuality() == 3 and not isForbidden(p:getObjId()) then table.insert(leg, p) end end
            if #leg == 0 then return end
            table.sort(leg, function(a, b) return a:getWake() > b:getWake() end)
            local targetPet = nil
            for _, p in ipairs(leg) do if p:getWake() < 5 then targetPet = p break end end
            if not targetPet then return end
            local fodder = {}
            local costNum = T(Config, "PokemonConfig"):getWakeConfig(targetPet:getWake()).wakeUpCost
            for _, p in pairs(pets) do
                if p:getObjId() ~= targetPet:getObjId() and p:getCfgId() == targetPet:getCfgId() and
                   p:getWake() == 0 and not isForbidden(p:getObjId()) then
                    table.insert(fodder, p:getObjId())
                end
                if #fodder >= costNum then break end
            end
            if #fodder >= costNum then Me:sendPacket({pid = "pokemonWakeUp", objId = targetPet:getObjId(), costIds = fodder}) end
        end)
        return World.SmartAwaken
    end)
end

-------------------------------------------------------------------------------
-- [DESTRUCT & CHAOS]
-------------------------------------------------------------------------------
GMItem["^FF5500DESTRUCT/1_Map_Global_Breakable"] = function()
    World.CurMap.cfg.canBreak = true
    Me:setProp("breakTimeFactor", 0.0001)
    World.cfg.disableBreakBlockProgress = false
end

GMItem["^FF5500DESTRUCT/2_Join_All_Mine_Regions"] = function()
    for _, region in pairs(World.CurWorld.regions) do
        if C_MineAreaMgr then C_MineAreaMgr:onPlayerEnterRegion(Me, region.cfg) end
    end
end

GMItem["^FF5500DESTRUCT/3_Spawn_Obliterator"] = function()
    local spawn = {x=0, y=0, z=0}
    for x=-10, 10 do for z=-10, 10 do for y=-5, 10 do
        Me:sendPacket({pid="EditBlock", pos={x=spawn.x+x, y=spawn.y+y, z=spawn.z+z}, blockId=0})
        Me:sendPacket({pid="SetBlock", pos={x=spawn.x+x, y=spawn.y+y, z=spawn.z+z}, blockId=0})
    end end end
end

GMItem["^FF5500DESTRUCT/4_Physics_Destroyer"] = function()
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getCurScene()
    scene:setEditorCanCollide(false)
    print("LOCAL PHYSICS DISABLED.")
end

-------------------------------------------------------------------------------
-- [MUTATION HACKS]
-------------------------------------------------------------------------------
local function getSlot1(cb)
    local bPL = Me:getValue("battlePetList") or {}
    if #bPL>0 then Me:getPokemonList({bPL[1]}, function(pets) if pets and pets[1] then cb(pets[1]) end end) end
end
GMItem["^FF55FFMUTATION/Slot1_Ultimate_Loop"] = function()
    getSlot1(function(p)
        World.Timer(1, function()
            for i=1,30 do Me:sendPacket({pid="GetTaskReward", taskid=24}); Me:sendPacket({pid="mutatePokemon", objId=p:getObjId()}) end
            return true
        end)
    end)
end

-------------------------------------------------------------------------------
-- [RP HACKS]
-------------------------------------------------------------------------------
GMItem["^55AAFFRP_HACKS/Unlock_All_VIP"] = function()
    Me:setValue("isVip", true); Me:setValue("vipLevel", 10); Me:setValue("subscribeGameState", true)
    function Me:isVip() return true end; function Me:getVipLevel() return 10 end
end
GMItem["^55AAFFRP_HACKS/Character_Scale"] = GM:inputStr(function(s, v) Me:setActorScale(tonumber(v) or 1) end)

return GMItem
