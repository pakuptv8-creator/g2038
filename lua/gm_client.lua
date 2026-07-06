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
-- [1. SPAM & CRASH]
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

GMItem["^FF0000Spam/UltraSpam_Timer1"] = GM:inputStr(function(self, msg)
    World.Timer(1, function() Me:sendPacket({pid = "ChatMessage", msg = msg, type = 1}); return true end)
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
-- [2. REAL HACKS (Economy)]
-------------------------------------------------------------------------------
GMItem["^FF0000RealHacks/GcubeAdd_1M"] = function() PlayerWallet:setMoneyCount("gDiamonds", 1000000) end
GMItem["^FF0000RealHacks/GoldAdd_1M"] = function() PlayerWallet:setMoneyCount("gold", 1000000) end
GMItem["^FF0000RealHacks/Unlock_All_Lottery"] = function(self) self:deltaLotteryTimes(1000) end
GMItem["^FF0000RealHacks/Add_All_Tickets"] = function(self)
    for i=1,4 do self:addUpgradeCard(i, 999999) end
end

-------------------------------------------------------------------------------
-- [3. NORMAL HACKS (Movement & World)]
-------------------------------------------------------------------------------
GMItem["^00FF00NormalHacks/Fly_NoClip"] = function(self)
    self.flyM = not self.flyM; self:setFlyMode(self.flyM and 1 or 0)
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not self.flyM)
end
GMItem["^00FF00NormalHacks/Swim_Hack"] = function(self) self.swM = not self.swM; self:setForceSwimMode(self.swM) end
GMItem["^00FF00NormalHacks/Climb_Hack"] = function(self) self:setForceClimbMode(true, 1, 0) end
GMItem["^00FF00NormalHacks/Set_Speed"] = GM:inputStr(function(self, v) Me:setProp("moveSpeed", tonumber(v) or 1) end)
GMItem["^00FF00NormalHacks/Set_Jump"] = GM:inputStr(function(self, v) Me:setProp("jumpSpeed", tonumber(v) or 1) end)
GMItem["^00FF00NormalHacks/Reach_Distance"] = GM:inputStr(function(self, v) Blockman.Instance():setReachDistance(tonumber(v) or 5) end)
GMItem["^00FF00NormalHacks/Infinite_Jump"] = function() World.Timer(1, function() Blockman.Instance():control():jump(); return true end) end
GMItem["^00FF00NormalHacks/Suicide"] = function(self) self:onDead({from = self, cause = "GM_SUICIDE"}) end
GMItem["^00FF00NormalHacks/ChangeActor"] = GM:inputStr(function(self, v) self:changeActor(v) end)
GMItem["^00FF00NormalHacks/ChangeNickName"] = GM:inputStr(function(self, v) self:setShowName(v) end)
GMItem["^00FF00NormalHacks/Emoji_Spam"] = GM:inputStr(function(self, id) Me:sendPacket({pid = "PlayAnimoji", actionId = id}) end)

-------------------------------------------------------------------------------
-- [4. ULTRA HACKS (Grinding & Battle)]
-------------------------------------------------------------------------------
GMItem["^FFFF00ULTRA_HACKS/Instant_Win_Battle"] = function() Me:sendPacket({pid = "BattleResult", result = 1}) end
GMItem["^FFFF00ULTRA_HACKS/Mutation_Orb_Spam"] = function() for i=1,100 do Me:sendPacket({pid="GetTaskReward", taskid=24}) end end
GMItem["^FFFF00ULTRA_HACKS/Force_Jump_Button"] = function() UI:openWnd("actionControl") end
GMItem["^FFFF00ULTRA_HACKS/Set_Max_FPS_999"] = function() CGame.Instance():SetMaxFps(999) end
GMItem["^FFFF00ULTRA_HACKS/Toggle_Invisibility"] = function(self) self.inv = not self.inv; Me:setActorHide(self.inv) end
GMItem["^FFFF00ULTRA_HACKS/Teleport_To_Target"] = function() local t=Me:getLockEntity(); if t then Me:setPosition(t:getPosition()) end end

-- [GACHA GOD MODE]
GMItem["^FFFF00ULTRA_HACKS/Auto_Gacha_GOD_MODE"] = function(self)
    World.AutoGacha = not World.AutoGacha
    print("GACHA GOD MODE (1 TICK): " .. tostring(World.AutoGacha))
    World.Timer(1, function()
        if not World.AutoGacha then return false end
        Me:sendPacket({pid = "GetTaskReward", taskid = 24})
        local w1 = UI:getWnd("pokemonLuckyEgg")
        local w2 = UI:getWnd("pokemonLuckyTenTake")
        local w3 = UI:getWnd("pokemonLuckyOnceTake")
        if w2 and w2:isvisible() then
            local btn = w2:child("PokemonLuckyTenTake-againBtn")
            if btn then btn:CallHandler(UIEvent.EventButtonClick) end
        elseif w3 and w3:isvisible() then
            local btn = w3:child("PokemonLuckyOnceTake-confirmBtn")
            if btn then btn:CallHandler(UIEvent.EventButtonClick) end
        elseif w1 and w1:isvisible() then
            local btn = w1:child("PokemonLuckyEgg-takeBtn10")
            if btn then btn:CallHandler(UIEvent.EventButtonClick) end
        else
            UI:openWnd("pokemonLuckyEgg")
        end
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
                if p:getQuality()<=1 and not p:isLocked() and not inT(p:getObjId()) then table.insert(toS, p:getObjId()) end
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
        local function isF(id) for _,v in pairs(bPL) do if v==id then return true end end return false end
        Me:getPokemonList(pPL, function(pets)
            local leg = {}
            for _,p in pairs(pets) do if p:getQuality()==2 and not p:isLocked() and not isF(p:getObjId()) then table.insert(leg, p) end end
            if #leg==0 then return end
            table.sort(leg, function(a,b) return a:getWake()>b:getWake() end)
            local target = nil
            for _,p in ipairs(leg) do if p:getWake()<5 then target=p break end end
            if not target then return end
            local fodder = {}
            local costNum = T(Config, "PokemonConfig"):getWakeConfig(target:getWake()).wakeUpCost
            for _,p in pairs(pets) do
                if p:getObjId()~=target:getObjId() and p:getCfgId()==target:getCfgId() and p:getWake()==0 and not p:isLocked() and not isF(p:getObjId()) then
                    table.insert(fodder, p:getObjId())
                end
                if #fodder >= costNum then break end
            end
            if #fodder >= costNum then Me:sendPacket({pid="pokemonWakeUp", objId=target:getObjId(), costIds=fodder}) end
        end)
        return World.SmartAwaken
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Instant_Max_Level_Team"] = function()
    local bPL = Me:getValue("battlePetList") or {}
    local expI = Me:getItemsCfgByItemType(Define.ITEM_TYPE.EXP)
    local best = nil
    for n, c in pairs(expI) do if Me:getTrayItemCountByFullName(n)>0 then if not best or c.itemId>best.itemId then best=c end end end
    if not best then return end
    Me:getPokemonList(bPL, function(pets)
        for _,p in pairs(pets) do
            local maxL = T(Config, "PokemonConfig"):getStarConfig(p:getStar()).levelMax
            for i=1, (maxL-p:getLevel()) do Me:useExpItem({objId=p:getObjId(), fullName=best.fullName, type=Define.USE_EXP_ITEM_TYPE.ONCE_LEVEL}) end
        end
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Filter_Task_Claim"] = function()
    local targetIds = {1, 5, 8, 9, 13, 16, 17, 21, 24, 30, 40, 50, 60, 100}
    for _, id in ipairs(targetIds) do Me:sendPacket({pid = "GetTaskReward", taskid = id}) end
end

GMItem["^FFFF00ULTRA_HACKS/Catch_MasterBall_Wild"] = function()
    if Me:isInBattle() then
        for _, e in pairs(World.CurWorld:getAllEntity()) do
            if e:getCampId() ~= Me:getCampId() and not e.isPlayer then
                Me:battleAction(Define.BATTLE_ACTION.BALL, {itemId = 4, targetId = e.objID})
                break
            end
        end
    end
end

-------------------------------------------------------------------------------
-- [5. MUTATION HACKS (Slot 1)]
-------------------------------------------------------------------------------
local function getSlot1(cb)
    local bPL = Me:getValue("battlePetList") or {}
    if #bPL>0 then Me:getPokemonList({bPL[1]}, function(pets) if pets[1] then cb(pets[1]) end end)
    else print("Slot 1 is empty! Put a pet in your team.") end
end

GMItem["^FF55FFMUTATION/Slot1_Method1_Fast"] = function()
    getSlot1(function(p) Me:sendPacket({pid="mutatePokemon", objId=p:getObjId()}) end)
end

GMItem["^FF55FFMUTATION/Slot1_Method2_Spam"] = function()
    getSlot1(function(p) for i=1,30 do Me:sendPacket({pid="mutatePokemon", objId=p:getObjId()}) end end)
end

GMItem["^FF55FFMUTATION/Slot1_Method3_Ultimate"] = function()
    getSlot1(function(p)
        World.Timer(1, function()
            for i=1,50 do
                Me:sendPacket({pid="GetTaskReward", taskid=24})
                Me:sendPacket({pid="mutatePokemon", objId=p:getObjId()})
            end
            return true -- LOOP UNTIL STOP
        end)
    end)
end

-------------------------------------------------------------------------------
-- [6. RP HACKS (Free City)]
-------------------------------------------------------------------------------
GMItem["^55AAFFRP_HACKS/Unlock_All_VIP"] = function()
    Me:setValue("isVip", true); Me:setValue("vipLevel", 10); Me:setValue("subscribeGameState", true)
    if T(Lib, "SubscribeVipHelper") then
        local h = T(Lib, "SubscribeVipHelper")
        h.getSubscribeGameState = function() return true end
        h.getVipLevel = function() return 10 end
    end
    function Me:isVip() return true end; function Me:getVipLevel() return 10 end
end

GMItem["^55AAFFRP_HACKS/Character_Scale"] = GM:inputStr(function(s, v) Me:setActorScale(tonumber(v) or 1) end)
GMItem["^55AAFFRP_HACKS/Vehicle_Speed_X5"] = function()
    local t = (Me.rideOnId and Me.rideOnId~=0) and World.CurWorld:getEntity(Me.rideOnId) or Me
    t:setProp("moveSpeed", 2.0)
end
GMItem["^55AAFFRP_HACKS/Infinite_Interaction"] = function() World.cfg.clickPlayerDistance = 9999 end
GMItem["^55AAFFRP_HACKS/Teleport_To_Random_Player"] = function()
    for _,e in pairs(World.CurWorld:getAllEntity()) do if e.isPlayer and e.objID~=Me.objID then Me:setPosition(e:getPosition()); break end end
end

-------------------------------------------------------------------------------
-- [7. WORLD & MINING]
-------------------------------------------------------------------------------
GMItem["^AAFF00WORLD/Global_Mining_Enable"] = function()
    World.KeepMiningMode = true
    for _, r in pairs(World.CurWorld.regions) do C_MineAreaMgr:initMineArea(r.map, r.cfg.id, r.min, r.max) end
end
GMItem["^AAFF00WORLD/Ignore_Region_Rules"] = function() World.IgnoreRegionEffects = not World.IgnoreRegionEffects end
GMItem["^AAFF00WORLD/Teleport_to_Resources"] = function()
    for _, r in pairs(World.CurWorld.regions) do
        if r.cfg.type == "break" then Me:setPosition((r.min + r.max) / 2) break end
    end
end

-------------------------------------------------------------------------------
-- [8. ORIGINAL GM & SKILLS]
-------------------------------------------------------------------------------
GMItem["g2030过场动画/Создать NPC Игрока"] = function()
    Game.EntitySpawn(Me, { objID = nextObjectID, cfgName = "myplugin/player1", actorName = "boy.actor", pos = Me:getPosition(), name = Me.name, curHp = 1, rideOnId = 0, }, function(entity) entity.isMovieEntity = true; entity:updateHeadInfo() end)
    nextObjectID = nextObjectID + 1
end
GMItem["g2033/Пропустить Гайд"] = function() Me:skipGuide() end
GMItem["g2030/Телепорт в Небо"] = function() Me:setPosition(Lib.v3(Me:getPosition().x, 5000, Me:getPosition().z)) end
GMItem["g2030过场动画/Пропустить Катсцену"] = function() Lib.emitEvent(Event.EVENT_SKIP_CUTSCENE) end

GMItem["g2030测试/开始拍照"] = function() Me:startCameraMode() end
GMItem["g2030Bgm/Вкл BGM"] = function() Me:playGameBgm() end
GMItem["g2030Bgm/Выкл BGM"] = function() Me:stopGameBgm() end

for i=1, 20 do
    local sName = string.format("myplugin/player_skill_%02d", i)
    GMItem["g2030技能/Skill_"..i] = function() Skill.Cast(sName) end
end

GMItem["g2030技能/击退"] = function() Skill.Cast("myplugin/player_control_skill_beatback") end
GMItem["g2030技能/击飞"] = function() Skill.Cast("myplugin/player_control_skill_hitfly") end
GMItem["g2030技能/眩晕"] = function() Skill.Cast("myplugin/player_dizziness_skill") end

return GMItem
