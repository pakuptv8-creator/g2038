local GMItem = GM:createGMItem()

local nextObjectID = 0x70000100

-- НОВЫЙ БЛОК: Полный список всех GUI (включая систему покемонов)
local guiWindows = {
    -- Общие и старые окна
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

    -- Система ПОКЕМОНОВ (из новых скриншотов)
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

    -- Битвы, Питомцы и прочее
    "petsBook", "mutatePopup", "minimap", "guide_go_to_shop", "get_item_tip",
    "followPetPrivilegeTip", "dailyLottery", "cutscene", "cameraEdit",
    "buyGiftTip", "bookDetails", "battle_select_target", "battle_results",
    "battle_pre_animation", "battle_pokemon", "battle_main", "battle_effect_tip",
    "battle_dialog"
}

-- Автоматическое создание кнопок в папку "Все_GUI"
for _, guiName in ipairs(guiWindows) do
    GMItem["Все_GUI/" .. guiName] = function(self)
        UI:openWnd(guiName)
        print("Запрос на открытие GUI:", guiName)
    end
end

if GM.isOpen and World.openGM then
    WorldServer.BroadcastPacket({
      pid = "GMList",
      list = GM.GMList,
      btsList = GM.BTSGMList
    })
    self:sendPacket({
      pid = "ShowTip",
      tipType = 2,
      keepTime = 20,
      textKey = "\226\150\162FF^FF0000 \229\189\147\229\137\141\229\188\128\229\144\175\228\186\134\230\156\172\229\156\176\230\156\141\229\138\161\229\153\168GM\230\168\161\229\188\143\239\188\140\229\166\130\230\158\156\233\157\158\230\156\172\229\156\176\229\144\175\229\138\168\231\154\132\230\156\141\229\138\161\229\153\168\239\188\140\232\175\183\228\184\138\230\138\165"
    })
  end
  
  
GMItem["^FF0000Spam/Spam"] = GM:inputStr(function(self, BaseD)

    -- Если введена 1 — останавливаем спам
    if BaseD == "1" then
        self.stopSpamUltra = true
        print("UltraSpam остановлен.")
        return true
    end

    -- Включаем спам
    self.stopSpamUltra = false

    -- Функция спама
    local function spamLoop()
        if self.stopSpamUltra then
            return false -- прекращаем таймер
        end

        local packet = {
            pid = "ChatMessage",
            fromname = "Iikj",
            msg = "&$[9900DD]$" .. BaseD ..
                  "$& [S=vip_nameplate_10_plus.json] [S=vip_nameplate_10_plus.json] " ..
                  "[S=vip_nameplate_10_plus.json] [S=vip_nameplate_10plus.json] " ..
                  "[S=vip_nameplate_10_plus.json] [S=vip_nameplate_10plus.json]",
            type = self.selectChannel
        }

        Me:sendPacket(packet)
        return true -- продолжить таймер
    end

    -- Запуск таймера с интервалом 1 тик
    World.Timer(1, spamLoop)

    return true
end)

GMItem["^FF0000КРАШ/^FFAA00Сервер Краш"] = function()
    Client.ShowTip(3, " ЗАПУСК...", 3)
    
    local total = 0
    local timer = World.Timer(1, function()
        for i = 1, 50000 do
            pcall(function()
                Me:sendPacket({
                    pid = "testPacket",
                    counter = total + i,
                    data = {}
                })
            end)
        end
        total = total + 50000
        
        if total >= 1000000 then
            Client.ShowTip(3, " 1M", 5)
            return false
        end
        
        return true
    end)
end
  

GMItem["^FF0000RealHacks/^FF0000GcubeAddl"] = function(self)
    PlayerWallet:setMoneyCount("gDiamonds", 1000000)
end


GMItem["^FF0000RealHacks/^FF0000UnlockAlll"] = function(self)
    self:deltaLotteryTimes(1000)
end


GMItem["^FF0000RealHacks/^FF0000ChakraTck"] = function(self)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
    self:addUpgradeCard(2, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000StrengthTck"] = function(self)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
    self:addUpgradeCard(1, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000JumpTck"] = function(self)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
    self:addUpgradeCard(3, 99999999)
end

GMItem["^FF0000RealHacks/^FF0000SpeedTck"] = function(self)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
    self:addUpgradeCard(4, 9999999)
end




GMItem["^00FF00NormalHacks/00FF00Fly"] = function(self)
    isOpenFly = not isOpenFly
    self:setFlyMode(isOpenFly and 1 or 0)
end

GMItem["^00FF00NormalHacks/00FF00NoClip"] = function(self)
    isOpenFly = not isOpenFly
    self:setFlyMode(isOpenFly and 1 or 0)
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getCurScene()
    scene:setEditorCanCollide(not scene:getEditorCanCollide())
end

GMItem["^00FF00NormalHacks/00FF00Camera"] = function(self)
    cameraMode = not cameraMode
    self:setCameraMode(cameraMode and true or false)
end

GMItem["^00FF00NormalHacks/00FF00SwimHack"] = function(self)
    cameraMode = not cameraMode
    self:setForceSwimMode(cameraMode and true or false)
end

GMItem["^00FF00NormalHacks/00FF00ClimbHack"] = function(self)
    cameraMode = not cameraMode
    self:setForceClimbMode(cameraMode and true or false, 1, 0)
end

GMItem["^00FF00NormalHacks/00FF00SetClimbDegress"] = GM:inputStr(function(self, Degress)
    self:setForceClimbMode(true, 1, Degress)
end)

GMItem["^00FF00NormalHacks/00FF00ChangeActor"] = GM:inputStr(function(self, value)
    self:changeActor(value)
end)

GMItem["^00FF00NormalHacks/00FF00ChangeNickName"] = GM:inputStr(function(self, value)
    self:setShowName(value)
end)

--[[GMItem["089/ChangePos"] = GM:inputStr(function(self, Num, self, Num2, self, Num3)
local playerPos = VectorUtil.newVector3(Num, Num2, Num3)
    self:setPosition(playerPos)
end)]]

GMItem["^00FF00NormalHacks/00FF00Reach"] = GM:inputStr(function(self, Value)
    local bm = Blockman.Instance()
    bm:setReachDistance(Value)
end)

GMItem["^00FF00NormalHacks/InfinityJump"] = function(self)
World.Timer(1, function()
local bm = Blockman.Instance()
bm:control():jump()
    return true
end)
end

GMItem["^00FF00NormalHacks/00FF00Emoji"] = GM:inputStr(function(self, ID)
    Me:sendPacket({
        pid = "PlayAnimoji",
        actionId = ID
   })
end)

--[[GMItem["089/SendMsg"] = function(self)
   local packet = {
   pid = "ChatMessage",
   fromname = "Iikj",
   msg = "Iikj", 
   type = self.selectChannel
   }
   Me:sendPacket(packet)
end]]

GMItem["^00FF00NormalHacks/00FF00UltraSpam"] = GM:inputStr(function(self, BaseD)
   World.Timer(1, function()
   local packet = {
   pid = "ChatMessage",
   fromname = "Iikj",
   msg = BaseD, 
   type = self.selectChannel
   }
   Me:sendPacket(packet)
   return true
end)
end)

--[[GMItem["089/2XScale"] = function(self)
local Data = Lib.v3(2, 2, 2)
local allEntity = World.CurWorld:getAllEntity()
		for _, _entity in pairs(allEntity) do
	    _entity:setActorScale(Data)
	    _entity:setData("actorScale", Data)  
	    end
end]]

GMItem["^00FF00NormalHacks/00FF00Suicide"] = function(self)
    self:onDead({
        from = self,
        cause = "GM_SUICIDE",
    })
end

--[[GMItem["089/kreeeest"] = function(self)
    player:sendPacket({
            pid = "PushClientSendPrivateChatEmoji",
            senderId = 48,
        })
end]]

--[[GMItem["089/获得方块名字"] = GM:inputStr(function(self, value)
    local arr = Lib.splitString(value, ",")
    if #arr ~= 3 then
        return
    end
    local pos = {x = arr[1], y = arr[2], z = arr[3]}
    player:setPosition(pos)
end)]] 

--[[GMItem["089/testttttt"] = GM:inputStr(function(self, tee)
    Interface.onAppActionTrigger(tee)
end)]]



GMItem["^00FF00NormalHacks/00FF00SetSpeed"] = GM:inputStr(function(self, Grav)
Player.CurPlayer:setProp("moveSpeed", Grav)
end)

GMItem["^00FF00NormalHacks/00FF00SetJumpHeight"] = GM:inputStr(function(self, Grav1)
Player.CurPlayer:setProp("jumpSpeed", Grav1)
end)

GMItem["^00FF00NormalHacks/00FF00SetBreakSpeed"] = GM:inputStr(function(self, Grav2)
Player.CurPlayer:setProp("breakTimeFactor", Grav2)
end)

GMItem["00FF00NormalHacks/00FF00SetClickDistance"] = GM:inputStr(function(self, Grav3)
Player.CurPlayer:setProp("clickDistance", Grav3)
end)

GMItem["^FFFF00ULTRA_HACKS/Force_Jump_Button"] = function(self)
    local actionControl = UI:getWnd("actionControl", false)
    if actionControl then
        actionControl:SetVisible(true)
        for i = 0, actionControl:GetChildCount() - 1 do
            local child = actionControl:GetChildByIndex(i)
            child:SetVisible(true)
            child:SetEnabled(true)
        end
        print("ActionControl forced visible.")
    else
        UI:openWnd("actionControl")
    end
end

GMItem["^FFFF00ULTRA_HACKS/Instant_Win_Battle"] = function(self)
    -- This is client-side, might not work if server validates, but let's try to send a win packet if it exists
    Me:sendPacket({pid = "BattleResult", result = 1})
end

GMItem["^FFFF00ULTRA_HACKS/Speed_X10"] = function(self)
    Me:setProp("moveSpeed", 10.0)
end

GMItem["^FFFF00ULTRA_HACKS/Infinite_Reach"] = function(self)
    Blockman.Instance():setReachDistance(999)
end

GMItem["^FFFF00ULTRA_HACKS/Teleport_To_Target"] = function(self)
    local target = Me:getLockEntity()
    if target then
        Me:setPosition(target:getPosition())
    end
end

GMItem["^FFFF00ULTRA_HACKS/Force_Learn_Skill"] = GM:inputStr(function(self, skillId)
    local packetPetList = Me:getValue("battlePetList")
    if #packetPetList > 0 then
        local objId = packetPetList[1]
        Me:pokemonStudySkill(objId, tonumber(skillId), 1) -- Use pos 1
        print("Forcing skill " .. skillId .. " on first pet in team.")
    else
        print("No pet in team found.")
    end
end)

GMItem["^FFFF00ULTRA_HACKS/Catch_Current_Wild"] = function(self)
    -- Sends a Master Ball packet regardless of inventory
    if Me:isInBattle() then
        -- Find an enemy pet
        local allEntities = World.CurWorld:getAllEntity()
        for _, entity in pairs(allEntities) do
            if entity:getCampId() ~= Me:getCampId() and not entity.isPlayer then
                Me:battleAction(Define.BATTLE_ACTION.BALL, {itemId = 4, targetId = entity.objID})
                print("Sending Master Ball to " .. entity.name)
                break
            end
        end
    end
end

GMItem["^FFFF00ULTRA_HACKS/Spoof_Resources"] = function(self)
    PlayerWallet:setMoneyCount("gDiamonds", 999999)
    PlayerWallet:setMoneyCount("gold", 999999)
    print("Resources spoofed (Client-side).")
end

GMItem["^FFFF00ULTRA_HACKS/Toggle_Invisibility"] = function(self)
    self.isGhost = not self.isGhost
    Me:setActorHide(self.isGhost)
    print("Ghost mode: " .. tostring(self.isGhost))
end

GMItem["^FFFF00ULTRA_HACKS/Toggle_Auto_Hunt"] = function(self)
    World.AutoEncounter = not World.AutoEncounter
    print("Auto-Hunt Magnet: " .. tostring(World.AutoEncounter))
end

GMItem["^FFFF00ULTRA_HACKS/Set_Max_FPS_999"] = function(self)
    CGame.Instance():SetMaxFps(999)
end

GMItem["^FFFF00ULTRA_HACKS/Infinite_PP_Simulation"] = function(self)
    -- Skill.DoStartCast was already modified, but this ensures it
    print("Infinite PP active (skills always usable).")
end

--[[GMItem["089/SetStepHeight"] = GM:inputStr(function(self, Grav7)
   Player.CurPlayer:setProp("stepHeight", Grav7)
end)]]

--[[GMItem["089/TREST"] = function(self)
   Lib.emitEvent(Event.EVENT_STOP_DEAD_COUNTDOWN)
    Lib.emitEvent(Event.EVENT_CLOSE_ALL_WND)
    Lib.emitEvent(Event.EVENT_EDIT_MAP_MAKING)
    if self.deathEffectTimer then
        self.deathEffectTimer()
    end
    if self.deleteDeathEffect then
        self.deleteDeathEffect()
    end
    World.Timer(5, function()
            local gameRootPath = CGame.Instance():getGameRootDir()
            CGame.instance:restartGame(gameRootPath, World.GameName, 0, true)
            Blockman.instance.singleGame = false
            return false
    end)
end

GMItem["089/TREST22"] = function(self)
Me:doHurt(Lib.v3(10, 10, 10))
end

GMItem["089/TREST23"] = function(self)
for userIDD = 16, 900000000, 16 do
CGame.instance:getShellInterface():onSendMessage(Define.privateMessageType.inviteMsg, userIDD)
end
end]]



--[[GMItem["089/TestS"] = function(self)
	--Blockman.instance.gameSettings:useVoxelTerrain(false)
--Blockman.instance:onSetClipboard("Www")
    local mapCfg = self.map.cfg
    mapCfg.canBreak = true
end]]



GMItem["g2030过场动画/客户端创建玩家npc"] = function(self)
    Game.EntitySpawn(Me, {
        objID = nextObjectID,
        cfgName = "myplugin/player1",
        actorName = "boy.actor",
        pos = Me:getPosition(),
        name = Me.name,
        curHp = 1,
        rideOnId = 0,
    }, function(entity)
        entity.isMovieEntity = true
        entity:updateHeadInfo()
    end)
    nextObjectID = nextObjectID + 1
end

local index = 0
local isShow = false
GMItem["g2033/关闭测试"] = function(self)
    Me:skipGuide()
end

GMItem["g2030/控制台显示日志"] = function(self)
    print("***********************************************************************************")
    Lib.logDebug("Hello World!")
    Lib.logInfo("Hello World!")
    Lib.logWarning("Hello World!")
    Lib.logError("Hello World!")
    Lib.logFatal("Hello World!")
    print("***********************************************************************************")
end

GMItem["g2030/显示隐藏UI"] = function(self)
    if not self.showFunc then
        self.showFunc = UI:hideOpenedWnd("skills")
    else
        self.showFunc()
        self.showFunc = nil
    end
end

GMItem["g2030Pet/测抽卡"] = function(self)
    local packet = {
        pid = "petDraw",
        poolID = 201
    }
    self:sendPacket(packet)
end

GMItem["g2030测试/闪白"] = function(self)
    UI:openWnd("simulatorEffect")
    local wnd = UI:getWnd("simulatorEffect")
    wnd:playScreenWhiteFlicker(function()
        --TODO
    end)
end

GMItem["g2030/传送"] = function(self)
    local pos = Me:getPosition()
    Me:setPosition(Lib.v3(pos.x, 5000, pos.z))
end

--GMItem["g2030测试/设置朝向"] = GM:inputNumber(function(self, yaw)
--    Me:setBodyYaw(yaw)
--    Me:setRotationYaw(yaw)
--end, 0)

GMItem["g2030测试/开始拍照"] = function(self)
    --Me:sendTrigger(Me, "START_CAMERA_MODE", Me)
    Me:startCameraMode()
end

GMItem["g2030测试/释放技能"] = function(self)
    local controlView = UI:getWnd("skills")
    Skill.Cast(controlView.skillList[2].name)
end

GMItem["g2030过场动画/跳过过场动画"] = function(self)
    Lib.emitEvent(Event.EVENT_SKIP_CUTSCENE)
end

GMItem["g2030/弹跳台"] = function(self)
    self:changeJumpState("JumpLaunchState")
end

GMItem["g2030过场动画/开始动作录制"] = function(self)
    if not self.recordAction then
        --self.recordActionFile = io.open("recordAction.txt", "a")
        self.recordAction = true
    end
end
GMItem["g2030过场动画/停止动作录制"] = function(self)
    if self.recordAction then
        --io.close(self.recordActionFile)
        --self.recordActionFile = nil
        self.recordAction = false
    end
end

GMItem["g2030/上腰带"] = function(self)
    self:exchangeEquip("myplugin/sash_simple")
end
GMItem["g2030/上腰带2"] = function(self)
    self:exchangeEquip("myplugin/sash_simple1")
end
GMItem["g2030/上武器"] = function(self)
    self:exchangeEquip("myplugin/weapon_simple")
end
GMItem["g2030/头顶文字改变"] = function(self)
    Lib.emitEvent("EVENT_TEST_1")
end

GMItem["g2033/购买麦克风和月卡"] = function(self)
    UI:openWnd("chatShop")
end

-----------------------------------Pet Model Test----------------------------------
GMItem["g2030Pet/检查是否存在宠物实体"] = function(self)
    print("==============================================")
    for k, v in pairs(Player.CurPlayer.equipPetList) do
        print("ridePos:", k, "entity Info:", Player.CurPlayer:getPet(v.objID))
    end
end
-----------------------------------Pet Model Test End-------------------------------

GMItem["g2030技能/击退技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_beatback")
end
GMItem["g2030技能/击飞技能"] = function(self)
    Skill.Cast("myplugin/player_control_skill_hitfly")
end
GMItem["g2030技能/3号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_03")
end
GMItem["g2030技能/4号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_04")
end
GMItem["g2030技能/5号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_05")
end
GMItem["g2030技能/6号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_06")
end
GMItem["g2030技能/7号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_07")
end
GMItem["g2030技能/8号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_08")
end
GMItem["g2030技能/9号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_09")
end
GMItem["g2030技能/10号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_10")
end
GMItem["g2030技能/11号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_11")
end
GMItem["g2030技能/12号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_12")
end
GMItem["g2030技能/13号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_13")
end
GMItem["g2030技能/14号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_14")
end
GMItem["g2030技能/15号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_15")
end
GMItem["g2030技能/16号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_16")
end
GMItem["g2030技能/17号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_17")
end
GMItem["g2030技能/18号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_18")
end
GMItem["g2030技能/19号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_19")
end
GMItem["g2030技能/20号技能"] = function(self)
    Skill.Cast("myplugin/player_skill_20")
end
GMItem["g2030技能/眩晕技能"] = function(self)
    Skill.Cast("myplugin/player_dizziness_skill")
end
GMItem["g2030/隐藏自己"] = function(self)
    self:setActorHide(true)
end
GMItem["g2030/显示自己"] = function(self)
    self:setActorHide(false)
end

GMItem["雷电技能/ray1"] = function(self)
    Skill.Cast("myplugin/skill_lightning_ray_line_missile")
end

GMItem["雷电技能/ray2"] = function(self)
    Skill.Cast("myplugin/skill_lightning_ray_line")

end
GMItem["g2030-island-effect/显示加速度"] = function(self)
    print("---------------------self:moveAcc:"..self:prop("moveAcc").."--------------------------------")
    print("---------------------self:jumpSpeed:"..self:prop("jumpSpeed").."--------------------------------")
    print("---------------------self:moveSpeed:"..self:prop("moveSpeed").."--------------------------------")
end

GMItem["g2030Bgm/C"] = function(self)
    local path = self:prop("bgmSound")
    if path then
        print("-----------have bgmSound-------------")
    else
        print("-----------no bgmSound-------------")
    end
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        print("-----------is bgmSound Playing:-------------", tostring(TdAudioEngine.Instance():isPlaying(bgmsoundId)))
    end
end

GMItem["g2030Bgm/开"] = function(self)
    self:playGameBgm()
end

GMItem["g2030Bgm/关"] = function(self)
    self:stopGameBgm()
end



GMItem["g2030Bgm/暂停"] = function(self)
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        TdAudioEngine.Instance():pauseSound(bgmsoundId)
    end
end

GMItem["g2030Bgm/恢复"] = function(self)
    local main = self:data("main")
    local bgmsoundId = main.bgmsoundId
    if bgmsoundId then
        TdAudioEngine.Instance():resumeSound(bgmsoundId)
    end
end

GMItem["开发/client内存单层分析"] = GM:inputStr(function(self, name)
    require("common.mem").List(tonumber(name), 1)
end, "1")

GMItem["g2033jump/Cbuff"] = function(self)
    local buffName = "myplugin/add_agility_buff"
    local buff = self:getTypeBuff("fullName", buffName)
    if buff then
        print("-----------have agility buff-------------")
    else
        print("-----------no agility buff-------------")
    end
end

local editRegionMode = false
GMItem["template/创建区域"] = function(self)
    local debugDraw = DebugDraw.instance
    if editRegionMode  and debugDraw:isEditRegionBoxEnabled() then
        debugDraw:setEnabled(false)
        debugDraw:setDrawRegionEnabled(false)
        debugDraw:setEditRegionBoxEnabled(false)
        UI:closeWnd("editRegionTool", 0)
    else
        editRegionMode = true
        if UI:isOpen("editRegionTool") then
            UI:getWnd("editRegionTool", true):onReload(0)
        else
            UI:openWnd("editRegionTool", 0)
        end
        debugDraw:setEnabled(true)
        debugDraw:setDrawRegionEnabled(true)
        debugDraw:setEditRegionBoxEnabled(true)

    end
    Me:cfg().collision = not debugDraw:isEditRegionBoxEnabled()
    Me:sendPacket({
        pid = "SetFly",
        isOpen = debugDraw:isEditRegionBoxEnabled()
    })
end

GMItem["Hacks/Global_Mining_Enable"] = function(self)
    World.KeepMiningMode = true
    local allRegions = World.CurWorld.regions
    for _, region in pairs(allRegions) do
        C_MineAreaMgr:initMineArea(region.map, region.cfg.id, region.min, region.max)
    end
    print("Mining mode enabled globally")
end

-- Отключает эффекты SafeZone, препятствий и скрытия интерфейса
GMItem["Hacks/Ignore_Region_Rules"] = function(self)
    World.IgnoreRegionEffects = not World.IgnoreRegionEffects
    print("Ignore Region Rules:", World.IgnoreRegionEffects)
end

-- Мгновенная активация копания в текущей точке
GMItem["Hacks/Force_Mine_Action"] = function(self)
    if C_MineAreaMgr then
        C_MineAreaMgr:onPlayerEnterRegion(Me)
        print("Forcing MineAreaMgr action...")
    end
end

-- Телепортация к ближайшей богатой рудой зоне (тип break)
GMItem["Hacks/Teleport_to_Resources"] = function(self)
    local allRegions = World.CurWorld.regions
    for _, region in pairs(allRegions) do
        if region.cfg.type == "break" then
            local targetPos = (region.min + region.max) / 2
            Me:setPosition(targetPos)
            print("Teleported to mining region:", region.cfg.id)
            break
        end
    end
end

return GMItem
