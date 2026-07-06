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
    "rename", "pokemonRelease", "pokemonRegularGift", "pokemonRecovery",
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

GMItem["^FF0000RealHacks/^FF0000GcubeAddl"] = function(self)
    PlayerWallet:setMoneyCount("gDiamonds", 1000000)
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

GMItem["^00FF00NormalHacks/00FF00SetSpeed"] = GM:inputStr(function(self, Grav)
Player.CurPlayer:setProp("moveSpeed", Grav)
end)

GMItem["^00FF00NormalHacks/00FF00SetJumpHeight"] = GM:inputStr(function(self, Grav1)
Player.CurPlayer:setProp("jumpSpeed", Grav1)
end)

GMItem["^FFFF00ULTRA_HACKS/Instant_Win_Battle"] = function(self)
    Me:sendPacket({pid = "BattleResult", result = 1})
end

GMItem["^FFFF00ULTRA_HACKS/Mutation_Orb_Spam"] = function(self)
    for i = 1, 50 do
        Me:sendPacket({
            pid = "GetTaskReward",
            taskid = 24
        })
    end
    print("Spammed Task 24 to trigger Mutation Orb rewards.")
end

GMItem["^FFFF00ULTRA_HACKS/Auto_Sell_Rare_Pets"] = function(self)
    -- Automatically sells all pets of EPIC (Blue) quality or lower.
    World.AutoSellPets = not World.AutoSellPets
    print("Auto-Sell Rare & Epic Pets: " .. tostring(World.AutoSellPets))
    if not World.AutoSellPets then return end

    World.Timer(40, function() -- Every 2 seconds
        if not World.AutoSellPets or Me:isInBattle() then return World.AutoSellPets end
        local packetPetList = Me:getValue("packetPetList") or {}
        local battlePetList = Me:getValue("battlePetList") or {}

        local function inTeam(objId)
            for _, id in pairs(battlePetList) do
                if id == objId then return true end
            end
            return false
        end

        Me:getPokemonList(packetPetList, function(pets)
            local toSell = {}
            for _, pet in pairs(pets) do
                -- Sell Quality 1 (Epic) and lower (0 = Rare/Common)
                if pet:getQuality() <= 1 and not pet:isLocked() and not inTeam(pet:getObjId()) then
                    table.insert(toSell, pet:getObjId())
                end
                if #toSell >= 10 then break end
            end
            if #toSell > 0 then
                print("AUTO-SELL: Releasing " .. #toSell .. " low-tier pets.")
                Me:sendPacket({
                    pid = "sellPokemon",
                    objIds = table.concat(toSell, ":")
                })
            end
        end)
        return World.AutoSellPets
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Auto_Gacha_Infinite"] = function(self)
    -- Continuous gacha loop: handles tickets/diamonds and opens Take 10
    World.AutoGacha = not World.AutoGacha
    print("Infinite Auto-Gacha: " .. tostring(World.AutoGacha))

    World.Timer(20, function()
        if not World.AutoGacha then return false end

        -- Try to ensure we have resources (Spam Task 24 for potential tickets/points)
        Me:sendPacket({ pid = "GetTaskReward", taskid = 24 })

        local eggWnd = UI:getWnd("pokemonLuckyEgg")
        local takeTenWnd = UI:getWnd("pokemonLuckyTenTake")

        if takeTenWnd and takeTenWnd:isvisible() then
            -- If results window is open, confirm to close it
            local btn = takeTenWnd:child("PokemonLuckyTenTake-confirmBtn")
            if btn then btn:CallHandler(UIEvent.EventButtonClick) end
        elseif eggWnd and eggWnd:isvisible() then
            -- Click Take 10 in the main egg window
            local btn = eggWnd:child("PokemonLuckyEgg-takeBtn10")
            if btn then btn:CallHandler(UIEvent.EventButtonClick) end
        else
            -- If window is not open, open it
            UI:openWnd("pokemonLuckyEgg")
        end
        return true
    end)
end

GMItem["^FFFF00ULTRA_HACKS/Smart_Auto_Awaken"] = function(self)
    World.SmartAwaken = not World.SmartAwaken
    print("Smart Auto-Awaken: " .. tostring(World.SmartAwaken))
    if not World.SmartAwaken then return end

    World.Timer(60, function()
        if not World.SmartAwaken or Me:isInBattle() then return World.SmartAwaken end

        local packetPetList = Me:getValue("packetPetList") or {}
        local battlePetList = Me:getValue("battlePetList") or {}
        local function isForbidden(objId)
            for _, id in pairs(battlePetList) do if id == objId then return true end end
            return false
        end

        Me:getPokemonList(packetPetList, function(pets)
            -- 1. Identify all Legendary pets (Quality 2)
            local legendaries = {}
            for _, pet in pairs(pets) do
                if pet:getQuality() == 2 and not pet:isLocked() and not isForbidden(pet:getObjId()) then
                    table.insert(legendaries, pet)
                end
            end

            if #legendaries == 0 then return end

            -- 2. Find the best candidate for awakening (highest wake level < Max)
            table.sort(legendaries, function(a, b) return a:getWake() > b:getWake() end)

            local targetPet = nil
            for _, pet in ipairs(legendaries) do
                if pet:getWake() < 5 then -- Assuming 5 is max wake
                    targetPet = pet
                    break
                end
            end

            if not targetPet then return end

            -- 3. Find fodder: exact copies with 0 wake level
            local fodder = {}
            local PokemonConfig = T(Config, "PokemonConfig")
            local wakeCfg = PokemonConfig:getWakeConfig(targetPet:getWake())
            local costNum = wakeCfg.wakeUpCost

            for _, pet in pairs(pets) do
                if pet:getObjId() ~= targetPet:getObjId() and
                   pet:getCfgId() == targetPet:getCfgId() and
                   pet:getWake() == 0 and
                   not pet:isLocked() and
                   not isForbidden(pet:getObjId()) then
                    table.insert(fodder, pet:getObjId())
                end
                if #fodder >= costNum then break end
            end

            if #fodder >= costNum then
                print("SMART AWAKEN: Upgrading " .. targetPet:getName() .. " (Wake " .. targetPet:getWake() .. ") using " .. #fodder .. " fodder copies.")
                Me:sendPacket({
                    pid = "pokemonWakeUp",
                    objId = targetPet:getObjId(),
                    costIds = fodder
                })
            end
        end)
        return World.SmartAwaken
    end)
end

GMItem["^55AAFFRP_HACKS/Unlock_All_VIP_RP"] = function(self)
    Me:setValue("isVip", true)
    Me:setValue("vipLevel", 10)
    Me:setValue("subscribeGameState", true)
    Me:setValue("soundMoonCard", true)

    if T(Lib, "SubscribeVipHelper") then
        local helper = T(Lib, "SubscribeVipHelper")
        helper.getSubscribeGameState = function() return true end
        helper.getVipLevel = function() return 10 end
    end

    function Me:isVip() return true end
    function Me:getVipLevel() return 10 end
    function Me:getSubscribeGameState() return true end

    print("RP VIP & Subscriptions UNLOCKED (Local).")
end

GMItem["^55AAFFRP_HACKS/Character_Scale"] = GM:inputStr(function(self, scale)
    local s = tonumber(scale) or 1.0
    Me:setActorScale(s)
    print("Growth Scale set to: " .. s)
end)

GMItem["^55AAFFRP_HACKS/Vehicle_Speed_X5"] = function(self)
    local target = Me
    if Me.rideOnId and Me.rideOnId ~= 0 then
        target = World.CurWorld:getEntity(Me.rideOnId) or Me
    end
    target:setProp("moveSpeed", 2.0)
    print("Movement speed BOOSTED!")
end

GMItem["^FFFF00ULTRA_HACKS/Instant_Max_Level_Team"] = function(self)
    local battlePetList = Me:getValue("battlePetList") or {}
    local expItems = Me:getItemsCfgByItemType(Define.ITEM_TYPE.EXP)
    local bestItem = nil
    for fullName, cfg in pairs(expItems) do
        if Me:getTrayItemCountByFullName(fullName) > 0 then
            if not bestItem or cfg.itemId > bestItem.itemId then
                bestItem = cfg
            end
        end
    end

    if not bestItem then return end

    local PokemonConfig = T(Config, "PokemonConfig")
    Me:getPokemonList(battlePetList, function(pets)
        for _, pet in pairs(pets) do
            local maxLevel = PokemonConfig:getStarConfig(pet:getStar()).levelMax
            local needed = maxLevel - pet:getLevel()
            if needed > 0 then
                for i = 1, needed do
                    Me:useExpItem({
                        objId = pet:getObjId(),
                        fullName = bestItem.fullName,
                        type = Define.USE_EXP_ITEM_TYPE.ONCE_LEVEL
                    })
                end
            end
        end
    end)
end

return GMItem
