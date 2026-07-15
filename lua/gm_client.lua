local GMItem = GM:createGMItem()

local nextObjectID = 0x70000100

-------------------------------------------------------------------------------
-- [FOLDER: Все_GUI]
-------------------------------------------------------------------------------
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
-- [FOLDER: ECONOMY]
-------------------------------------------------------------------------------
GMItem["^FFD700ECONOMY/Add_1M_GCubes"] = function() PlayerWallet:setMoneyCount("gDiamonds", 1000000) end
GMItem["^FFD700ECONOMY/Add_1M_Gold"] = function() PlayerWallet:setMoneyCount("gold", 1000000) end
GMItem["^FFD700ECONOMY/Unlock_Lottery"] = function(self) self:deltaLotteryTimes(1000) end
GMItem["^FFD700ECONOMY/Max_All_Tickets"] = function(self) for i=1,4 do self:addUpgradeCard(i, 99999999) end end

-------------------------------------------------------------------------------
-- [FOLDER: SHOP_DAILY / SHOP_WEEKLY / SHOP_MONTHLY]
-------------------------------------------------------------------------------
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local allGifts = RegularGiftConfig:getAllConfig()
local tabLabels = { [1] = "DAILY", [2] = "WEEKLY", [3] = "MONTHLY" }

for _, gift in ipairs(allGifts) do
    local label = tabLabels[gift.tabId] or "OTHER"
    local contents = ""
    for _, cid in ipairs(gift.giftContent) do
        local c = RegularGiftItemConfig:getConfigById(tonumber(cid))
        if c then contents = contents .. string.format("%sx%d ", Lang:toText(c.itemName), c.itemCount) end
    end
    local btn = string.format("^00FFCCSHOP_%s/%s (%d GC) [%s]", label, Lang:toText(gift.giftName), gift.finalPrice, contents)
    GMItem[btn] = function() Me:sendPacket({pid = "requestBugRegularGift", itemId = gift.id, buyCount = 1}) end
end

-------------------------------------------------------------------------------
-- [FOLDER: MOVEMENT]
-------------------------------------------------------------------------------
GMItem["^00FF00MOVE/Fly_NoClip"] = function(self)
    self.flyM = not self.flyM; self:setFlyMode(self.flyM and 1 or 0)
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(not self.flyM)
end
GMItem["^00FF00MOVE/Set_Speed"] = GM:inputStr(function(s, v) Me:setProp("moveSpeed", tonumber(v) or 1) end)
GMItem["^00FF00MOVE/Reach_Distance"] = GM:inputStr(function(s, v) Blockman.Instance():setReachDistance(tonumber(v) or 5) end)

-------------------------------------------------------------------------------
-- [FOLDER: AUTOMATION]
-------------------------------------------------------------------------------
GMItem["^FFFF00AUTO/Gacha_Burst_Direct"] = function()
    World.GachaBurst = not World.GachaBurst
    World.Timer(1, function()
        if not World.GachaBurst then return false end
        Me:sendPacket({pid="GetTaskReward", taskid=24})
        for t=1,3 do Me:sendPacket({pid="takeLuckyEggAward", tabType=t, takeType=1}) end
        local w2, w3 = UI:getWnd("pokemonLuckyTenTake"), UI:getWnd("pokemonLuckyOnceTake")
        if w2 and w2:isvisible() then w2:child("PokemonLuckyTenTake-confirmBtn"):CallHandler(UIEvent.EventButtonClick) end
        if w3 and w3:isvisible() then w3:child("PokemonLuckyOnceTake-confirmBtn"):CallHandler(UIEvent.EventButtonClick) end
        return true
    end)
end

GMItem["^FFFF00AUTO/Smart_Sell_Epic_Rare"] = function()
    World.AutoSell = not World.AutoSell
    World.Timer(40, function()
        if not World.AutoSell or Me:isInBattle() then return World.AutoSell end
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
        return World.AutoSell
    end)
end

GMItem["^FFFF00AUTO/Focus_Legend_Awaken"] = function()
    World.SmartAwaken = not World.SmartAwaken
    World.Timer(60, function()
        if not World.SmartAwaken or Me:isInBattle() then return World.SmartAwaken end
        local pPL, bPL = Me:getValue("packetPetList") or {}, Me:getValue("battlePetList") or {}
        local function isF(id) for _,v in pairs(bPL) do if v==id then return true end end return false end
        Me:getPokemonList(pPL, function(pets)
            local leg = {}
            for _,p in pairs(pets) do if p:getQuality() == 3 and not isF(p:getObjId()) then table.insert(leg, p) end end
            if #leg == 0 then return end
            table.sort(leg, function(a, b) return a:getWake() > b:getWake() end)
            local target = nil
            for _, p in ipairs(leg) do if p:getWake() < 5 then target = p break end end
            if not target then return end
            local fodder = {}
            local cost = T(Config, "PokemonConfig"):getWakeConfig(target:getWake()).wakeUpCost
            for _, p in pairs(pets) do
                if p:getObjId() ~= target:getObjId() and p:getCfgId() == target:getCfgId() and p:getWake() == 0 and not isF(p:getObjId()) then
                    table.insert(fodder, p:getObjId())
                end
                if #fodder >= cost then break end
            end
            if #fodder >= cost then Me:sendPacket({pid = "pokemonWakeUp", objId = target:getObjId(), costIds = fodder}) end
        end)
        return World.SmartAwaken
    end)
end

-------------------------------------------------------------------------------
-- [FOLDER: MUTATION]
-------------------------------------------------------------------------------
GMItem["^FF55FFMUTATE/Slot1_Ultimate_Loop"] = function()
    local bPL = Me:getValue("battlePetList") or {}
    if #bPL > 0 then
        Me:getPokemonList({bPL[1]}, function(pets)
            if pets and pets[1] then
                World.Timer(1, function()
                    for i=1,30 do Me:sendPacket({pid="GetTaskReward", taskid=24}); Me:sendPacket({pid="mutatePokemon", objId=pets[1]:getObjId()}) end
                    return true
                end)
            end
        end)
    end
end

-------------------------------------------------------------------------------
-- [FOLDER: DESTRUCT_V2]
-------------------------------------------------------------------------------
GMItem["^FF4500DESTRUCT/1_Global_Break_ON"] = function()
    World.CurMap.cfg.canBreak = true
    Me:setProp("breakTimeFactor", 0.0001)
    World.cfg.disableBreakBlockProgress = false
end
GMItem["^FF4500DESTRUCT/2_Force_Mine_Regions"] = function()
    for _, r in pairs(World.CurWorld.regions) do if C_MineAreaMgr then C_MineAreaMgr:onPlayerEnterRegion(Me, r.cfg) end end
end
GMItem["^FF4500DESTRUCT/3_Spawn_Oblit_Burst"] = function()
    local p = {x=0, y=0, z=0}
    for x=-10,10 do for z=-10,10 do for y=-5,10 do
        Me:sendPacket({pid="EditBlock", pos={x=p.x+x, y=p.y+y, z=p.z+z}, blockId=0})
        Me:sendPacket({pid="SetBlock", pos={x=p.x+x, y=p.y+y, z=p.z+z}, blockId=0})
    end end end
end
GMItem["^FF4500DESTRUCT/4_Physics_Destroyer"] = function()
    local scene = World.CurWorld:getSceneManager():getCurScene()
    scene:setEditorCanCollide(false)
end
GMItem["^FF4500DESTRUCT/5_Mass_Remove_Radius"] = GM:inputStr(function(s, v)
    local p = Me:curBlockPos()
    local r = tonumber(v) or 5
    for x=-r,r do for y=-r,r do for z=-r,r do
        if (x*x + y*y + z*z) <= r*r then Me:sendPacket({pid="RemoveBlock", pos={x=p.x+x, y=p.y+y, z=p.z+z}}) end
    end end end
end)
GMItem["^FF4500DESTRUCT/6_FillArea_Void"] = function()
    local p = Me:curBlockPos()
    Me:sendPacket({pid="FillArea", min={x=p.x-15, y=p.y-5, z=p.z-15}, max={x=p.x+15, y=p.y+15, z=p.z+15}, blockId=0})
end
GMItem["^FF4500DESTRUCT/7_Edit_Map_Override"] = function()
    World.gameCfg.editMap = true
    World.CurWorld:checkEditor(255)
end
GMItem["^FF4500DESTRUCT/8_Ghost_Blocks_Local"] = function()
    Blockman.Instance():setReachDistance(9999)
    World.Timer(1, function()
        local h = Blockman.Instance():getRaycastHit()
        if h and h.type == "BLOCK" then Me:sendPacket({pid="EditBlock", pos=h.blockPos, blockId=0}) end
        return true
    end)
end
GMItem["^FF4500DESTRUCT/9_Region_Protection_OFF"] = function()
    World.IgnoreRegionEffects = true
    Me.disableControl = false
end
GMItem["^FF4500DESTRUCT/10_Spawn_Total_Collapse"] = function()
    local p = {x=0, y=0, z=0}
    World.Timer(1, function()
        for i=1,100 do
            local rx, ry, rz = math.random(-20,20), math.random(-5,10), math.random(-20,20)
            Me:sendPacket({pid="EditBlock", pos={x=p.x+rx, y=p.y+ry, z=p.z+rz}, blockId=0})
        end
        return true
    end)
end

-------------------------------------------------------------------------------
-- [FOLDER: BATTLE_SPOOF]
-------------------------------------------------------------------------------
GMItem["^55AAFFSPOOF/Solo_2vs2_Reward_Hack"] = function()
    World.Solo2vs2 = not World.Solo2vs2
    print("Solo 2vs2 Spoof: " .. tostring(World.Solo2vs2))
end

-------------------------------------------------------------------------------
-- [FOLDER: RP_HACKS]
-------------------------------------------------------------------------------
GMItem["^00BFFFRP/Unlock_VIP_Local"] = function()
    Me:setValue("isVip", true); Me:setValue("vipLevel", 10); Me:setValue("subscribeGameState", true)
    function Me:isVip() return true end; function Me:getVipLevel() return 10 end
end
GMItem["^00BFFFRP/Character_Scale"] = GM:inputStr(function(s, v) Me:setActorScale(tonumber(v) or 1) end)

return GMItem
