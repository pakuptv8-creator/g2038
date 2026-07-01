Define.ENTITY_TYPE = {PLAYER = 1, MONSTER = 2}
Define.ERROR_CODE = {
  SUCCESS = 0,
  TARGET_NIL = 1,
  TARGET_BUSY = 2,
  FORBID = 101,
  SWAP_BIND = 201,
  SWAPING = 202,
  IN_TEAM = 203,
  ONLY_CAP = 204
}
Define.BATTLE_MODE = {
  PVE = 1,
  PVP = 2,
  NPC = 3
}
Define.REGULAR_GIFT_TAB = {
  DayRegular = 1,
  WeekRegular = 2,
  MonthRegular = 3
}
Define.MEET_PKM_TYPE = {
  NO_MEET_PKM = 0,
  HIDE_PKM = 1,
  BRIGHT_PKM = 2,
  AREA_NPC_PKM = 3,
  INTERACTION_NPC_PKM = 4,
  INTERACTION_PVP_PLAYER = 5
}
Define.PRE_BATTLE_ANIMATION = {
  BLACK_AND_WHITE = 1,
  SHOW_BLOCK = 2,
  HIDE_BLOCK = 3,
  WARNING_SIGN = 4
}
Define.PRE_ANIMATION_TIME = {
  [Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE] = 0,
  [Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK] = 0,
  [Define.PRE_BATTLE_ANIMATION.HIDE_BLOCK] = 0,
  [Define.PRE_BATTLE_ANIMATION.WARNING_SIGN] = 0
}
Define.rechargeAwardType = {
  notRecharge = 0,
  Recharge = 1,
  superRecharge = 2
}
Define.BATTLE_ACTION = {
  NONE = 0,
  SKILL = 1,
  RUNAWAY = 2,
  RUNAWAY_ENEMY = 3,
  BALL = 4,
  REPLACE = 5,
  ITEM = 6,
  FEATURE = 7,
  DEBUFF = 8,
  REPLACE_ENEMY = 9,
  REPLACE_HOST = 10
}
Define.CAMP = {
  CAMP_NONE = 0,
  CAMP_A = 1,
  CAMP_B = 2
}
Define.EXTRA_PRIORITY = {
  VALUE1 = 1000000,
  VALUE2 = 100000,
  VALUE3 = 10000
}
Define.SCENE_TYPE = {BATTLE = 1, NOT_BATTLE = 2}
Define.READY_TYPE = {
  COMMON = 1,
  COMMAND = 2,
  CATCH = 3
}
Define.BAG_TYPE = {
  BALL = 1,
  CURE = 2,
  OTHER = 3,
  SKILL = 4
}
Define.USE_TARGET = {
  PLAYER = 1,
  PET = 2,
  WILD = 3
}
Define.BATTLE_TARGET = {
  SELF = 1,
  OUR = 2,
  ENEMY = 3
}
Define.POKEMON_ATTR_TYPE = {
  Hp = 1,
  Speed = 2,
  PAtk = 3,
  PDef = 4,
  SAtk = 5,
  SDef = 6
}
Define.NPC_ACTION_TYPE = {
  NONE = 0,
  RECOVERY = 1,
  DONOTHING = 2,
  ENTERBATTLE = 3,
  SELECTPOKEMON = 4,
  TELEGRAPH = 5
}
Define.DIALOG_REASON = {
  NONE = 0,
  NORMAL = 1,
  WRONGPREORDER = 2,
  TEAM = 3,
  CHALLENGED = 4,
  LACKOFPOWER = 5,
  RACENOTMATCH = 6,
  WRONGPOSTORDER = 7
}
Define.TASK_TYPE = {
  NONE = 0,
  NPC_BATTLE = 1,
  POKEMON_CAPTURE = 2,
  POKEMON_BATTLE = 3,
  PVP_GYM = 4,
  POKEMON_UPGRADE_STAR = 5,
  SHOP_PURCHASE = 6,
  ITEM_USE = 7,
  PVP_BATTLE = 8
}
Define.UI_TYPE = {
  NONE = 0,
  BAG = 1,
  PACK = 2,
  SHOP = 3
}
Define.ITEM_TYPE = {
  BALL = 1,
  CURE = 2,
  OTHER = 3,
  SKILL = 4,
  EXP = 5,
  WASH = 6,
  Bless = 7,
  SPRAY = 8,
  EggTicket = 9
}
Define.SKILL_ABNORMAL_BUFF = {
  [1] = "myplugin/skill_fire_damage_buff_1",
  [2] = "myplugin/skill_poisoning_buff_1",
  [3] = "myplugin/skill_wet_damage_buff",
  [4] = "myplugin/skill_sleep_damage_buff",
  [5] = "myplugin/skill_paralysis_damage_buff",
  [6] = "myplugin/skill_chaos_damage_buff"
}
Define.SKILL_ABNORMAL_IMMUNE = {
  ["myplugin/skill_fire_damage_buff_1"] = "skill_fire_immune_buff",
  ["myplugin/skill_poisoning_buff_1"] = "skill_poisoning_immune_buff",
  ["myplugin/skill_wet_damage_buff"] = "skill_wet_immune_buff",
  ["myplugin/skill_sleep_damage_buff"] = "skill_sleep_immune_buff",
  ["myplugin/skill_paralysis_damage_buff"] = "skill_paralysis_immune_buff",
  ["myplugin/skill_chaos_damage_buff"] = "skill_chaos_immune_buff"
}
Define.SKILL_ATTRIBUTE_BUFF = {
  [1] = "myplugin/skill_physical_attack_buff",
  [2] = "myplugin/skill_spell_attack_buff",
  [3] = "myplugin/skill_speed_buff",
  [4] = "myplugin/skill_physical_def_buff",
  [5] = "myplugin/skill_spell_def_buff",
  [6] = "myplugin/skill_accuracy_bonus_buff",
  [7] = "myplugin/skill_power_bonus_buff",
  [8] = "myplugin/skill_damage_bonus_buff",
  [9] = "myplugin/skill_life_bonus_buff",
  [10] = "myplugin/skill_fire_immune_buff",
  [11] = "myplugin/skill_poisoning_immune_buff",
  [12] = "myplugin/skill_wet_immune_buff",
  [13] = "myplugin/skill_sleep_immune_buff",
  [14] = "myplugin/skill_paralysis_immune_buff",
  [15] = "myplugin/skill_chaos_immune_buff"
}
Define.ChatMsgType = {
  common = 1,
  family = 2,
  private = 3
}
Define.ChatPlayerType = {
  vip = 1,
  svip = 2,
  server = 3
}
Define.USE_EXP_ITEM_TYPE = {ONCE_ITEM = 1, ONCE_LEVEL = 2}
Define.CURE_TYPE = {
  HP = 1,
  LIFE = 2,
  DBUFF = 3,
  PP = 4
}
Define.CURE_PP_TYPE = {ONCE = 1, ALL = 2}
Define.SHOP_TAB_TYPE = {
  PREFERENTIAL = 1,
  COMMON = 2,
  BALL = 3,
  CURE = 4,
  INTENSIFY = 5,
  SKILL = 6
}
Define.SHOP_TYPE = {ITEM = 1}
Define.SkillEffectTiming = {
  skillCast = 1,
  enterBattle = 2,
  damage = 3,
  finshSkillCast = 4,
  beAccuracy = 5,
  relife = 6,
  beHurt = 7
}
Define.SkillAbnormalType = {
  common = 0,
  dka = 1,
  burn = 2,
  damp = 3,
  palsy = 4,
  sleep = 5,
  chaos = 6
}
Define.SkillTriggerType = {
  add = 1,
  castSkill = 2,
  roundEnd = 3,
  skillDamage = 4,
  finshSkillCast = 5,
  onDead = 6
}
Define.EffectSkillType = {
  none = 0,
  chaos = 1,
  fanji = 2,
  fantan = 3,
  lianji = 4
}
Define.SHOP_BEHAVIOR_NAME = {
  [Define.SHOP_TAB_TYPE.PREFERENTIAL] = "limit",
  [Define.SHOP_TAB_TYPE.COMMON] = "common",
  [Define.SHOP_TAB_TYPE.BALL] = "pokeball",
  [Define.SHOP_TAB_TYPE.CURE] = "medicine",
  [Define.SHOP_TAB_TYPE.INTENSIFY] = "other",
  [Define.SHOP_TAB_TYPE.SKILL] = "skill"
}
Define.PLAYER_ACTION = {
  PK = 0,
  SWAP = 1,
  JOIN_TEAM = 2,
  LEAVEL_TEAM = 3
}
Define.GUIDE_INDEX = {
  SELECT_INIT_POKEMON = 1,
  FINISH_SELECT_POKEMON = 2,
  GOTO_FIRST_NPC = 3,
  FINISH_FIRST_NPC = 4,
  UPGRADE_POKEMON_OPEN_PACKET = 5,
  UPGRADE_POKEMON_SELECT_POKEMON = 6,
  UPGRADE_POKEMON_SELECT_UPGRADE = 7,
  UPGRADE_POKEMON_CONFIRM_UPGRADE = 8,
  UPGRADE_POKEMON_CLOSE_UPGRADE = 9,
  UPGRADE_POKEMON_CLOSE_PACKET = 10,
  FINISH_UPGRADE_POKEMON = 11,
  PURCHASE_UPGRADE_ITEM_OPEN_SHOP = 12,
  PURCHASE_UPGRADE_ITEM_SELECT_TAB = 13,
  PURCHASE_UPGRADE_ITEM_SELECT_CELL = 14,
  PURCHASE_UPGRADE_ITEM_OPEN_PURCHASE = 15,
  PURCHASE_UPGRADE_ITEM_CONFIRM_PURCHASE = 16,
  PURCHASE_UPGRADE_ITEM_CLOSE_SHOP = 17,
  FINISH_PURCHASE_UPGRADE_ITEM = 18,
  CAPTURE_POKEMON_GOTO = 19,
  CAPTURE_POKEMON_USE_BALL = 20,
  CAPTURE_POKEMON_CONFIRM_BALL = 21,
  CAPTURE_POKEMON_PUT_BALL = 22,
  FINISH_CAPTURE_POKEMON = 23,
  FILL_POKEMON_OPEN_PACKET = 24,
  FILL_POKEMON_SELECT_EMPTY = 25,
  FILL_POKEMON_SELECT_POKEMON = 26,
  FILL_POKEMON_SAVE_QUEUE = 27,
  FILL_POKEMON_CLOSE_PACKET = 28,
  FINISH_FILL_POKEMON = 29,
  GOTO_REFINE_NPC = 30,
  FINISH_REFINE_NPC = 31,
  REFINE_POKEMON_OPEN_PACKET = 32,
  REFINE_POKEMON_SELECT_GROW = 33,
  REFINE_POKEMON_OPEN_REFINE = 34,
  REFINE_POKEMON_CONFIRM_REFINE = 35,
  REFINE_POKEMON_CLOSE_REFINE = 36,
  REFINE_POKEMON_CLOSE_PACKET = 37,
  FINISH_REFINE_POKEMON = 38,
  GOTO_GYM_1_BOSS = 39,
  FINISH_GYM_1_BOSS = 40,
  TAKE_TEN_OPEN_LUCKY = 41,
  TAKE_TEN_CONFIRM = 42,
  TAKE_TEN_CLOSE = 43,
  TAKE_TEN_CLOSE_LUCKY = 44,
  FINISH_TAKE_TEN = 45,
  WAKE_POKEMON_OPEN_PACKET = 46,
  WAKE_POKEMON_SELECT_TAB = 47,
  WAKE_POKEMON_OPEN_WND = 48,
  WAKE_POKEMON_ADD_MATERIAL = 49,
  WAKE_POKEMON_SELECT_MATERIAL = 50,
  WAKE_POKEMON_CONFIRM_MATERIAL = 51,
  WAKE_POKEMON_CONFIRM_WAKE = 52,
  WAKE_POKEMON_CLOSE_WND = 53,
  WAKE_POKEMON_CLOSE_PACKET = 54,
  FINISH_WAKE_POKEMON = 55,
  GOTO_GYM_2_BOSS = 56,
  FINISH_GYM_2_BOSS = 57,
  GOTO_GYM_3_BOSS = 58,
  FINISH_GYM_3_BOSS = 59,
  GOTO_GYM_4_BOSS = 60,
  FINISH_GYM_4_BOSS = 61,
  GOTO_GYM_5_BOSS = 62,
  FINISH_GYM_5_BOSS = 63,
  OPEN_FOLLOW_PET = 64,
  CONFIRM_FOLLOW_PET = 65
}
Define.WEAK_GUIDA = {
  [Define.GUIDE_INDEX.GOTO_REFINE_NPC] = true,
  [Define.GUIDE_INDEX.FINISH_REFINE_NPC] = true,
  [Define.GUIDE_INDEX.GOTO_GYM_1_BOSS] = true,
  [Define.GUIDE_INDEX.FINISH_GYM_1_BOSS] = true,
  [Define.GUIDE_INDEX.GOTO_GYM_2_BOSS] = true,
  [Define.GUIDE_INDEX.FINISH_GYM_2_BOSS] = true,
  [Define.GUIDE_INDEX.GOTO_GYM_3_BOSS] = true,
  [Define.GUIDE_INDEX.FINISH_GYM_3_BOSS] = true,
  [Define.GUIDE_INDEX.GOTO_GYM_4_BOSS] = true,
  [Define.GUIDE_INDEX.FINISH_GYM_4_BOSS] = true,
  [Define.GUIDE_INDEX.GOTO_GYM_5_BOSS] = true,
  [Define.GUIDE_INDEX.FINISH_GYM_5_BOSS] = true
}
Define.MODULE_TYPE = {
  MAIN_PET = 1,
  MAIN_QUEUE = 2,
  MAIN_BOOK = 3,
  MAIN_BAG = 4,
  MAIN_SHOP = 5,
  BATTLE_BAG = 6,
  BATTLE_BALL = 7,
  BATTLE_PET = 8,
  BATTLE_RUNAWAY = 9,
  MAP_TRANSFER = 10,
  PET_REFINE = 11,
  BATTLE_AUTO = 12,
  BATTLE_NONCOMBAT = 13,
  MAIN_DAILY_TASK = 14,
  INTERACTION_UI_PK = 15,
  INTERACTION_UI_TEAM = 16,
  INTERACTION_UI_SWAP = 17,
  MAIN_LUCKY_EGG = 18,
  MAIN_REGULAR_GIFT = 19,
  MAIN_FIRST_RECHARGE = 20,
  MAIN_BLESS = 21,
  MAIN_LEADERBOARD = 22,
  MAIN_DAILY_LOTTERY = 23,
  GIFT_ON_LINE = 24,
  MAIN_GLORY_HALL = 25,
  MAIN_ROTARY_TABLE = 26,
  LIMIT_TIME_ACTIVITY = 27,
  MAIN_SUBSCRIBE = 28
}
Define.CommonTipType = {TOP = 1}
Define.TRIGGER_GIFT_TYPE = {GROW = 1, TIME = 2}
Define.TRIGGER_GIFT_ITEM_TYPE = {
  PET = 1,
  GOLD = 2,
  ITEM = 3
}
Define.TRIGGER_GIFT_ITEM_TYPE = {
  PET = 1,
  GOLD = 2,
  ITEM = 3
}
Define.GIFT_TRIGGER_CONDITION = {
  LV = 1,
  CAPTURE_FAIL = 2,
  TASK_FINISH = 3,
  TASK_IN = 4,
  PET_LIFT = 5,
  NPC_FINISH = 6,
  NPC_FAIL = 7,
  ON_LINE = 8,
  BUY_GIFT = 9,
  ORANGE_PET = 10,
  PET_LEVEL_UP = 11
}
Define.RANK_SUB_TYPE = {
  POWER = 1,
  WATER_GYM = 2,
  FIRE_GYM = 3,
  GRASS_GYM = 4,
  SUPER_GYM = 5,
  SPECIAL_GYM = 6,
  HONOR_GYM = 7
}
Define.FOLLOW_PET_STATUS = {
  UNPAY = 1,
  DISABLE = 2,
  USE = 3,
  UNUSE = 4
}
Define.RANK_LANG_TYPE = {
  ZH = 1,
  EN = 2,
  RU = 3,
  ES = 4,
  PT = 5,
  ID = 6
}
Define.POKEMON_RACE = {
  NONE = 0,
  NORMAL = 1,
  WATER = 2,
  FIRE = 3,
  GRASS = 4,
  SUPER = 5,
  SPECIAL = 6
}
Define.POKEMON_MAX_STAR = 6
Define.maxTimeStamp = 2147483647
Define.POKEMON_QUALITY = {
  EPIC = 1,
  LEGENDARY = 2,
  MYTHICAL = 3
}
Define.WORLD_TIP_TYPE = {
  CATCH = 1,
  INCUBATE = 2,
  WAKEUP = 3,
  UPGRADESTAT = 4,
  EVOLVE = 5,
  MUTATED = 6,
  WINPVP = 7
}
Define.GLORY_STATUS = {
  INIT = -1,
  LOST = 0,
  GAIN = 1
}
Define.SWAP_END_CODE = {
  SUCCESS = 0,
  CANCEL = 1,
  FULL = 2,
  REFUSE = 3,
  ERROR = 404
}
Define.PUT_CAPTURE_IN_PACKET_CODE = {SUCCESS = 0, FAIL = 404}
Define.COMMON_DIALOG_MODE = {NOBUTTON = 1, TWOBUTTON = 2}
Define.UI_RED_DOT_TYPE = {
  MAIN_LUCKY_EGG_RED = 1,
  LUCKY_EGG_TAB_RED = 2,
  LUCKY_EGG_TEN_BTN = 3,
  LUCKY_EGG_EXTRA_AWARD = 4,
  MAIN_REGULAR_GIFT_RED = 6,
  REGULAR_GIFT_BUY_BTN_RED = 7,
  MAIN_DAILY_LOTTERY_RED = 8,
  MAIN_DAILY_TASK_RED = 9,
  MAIN_SHOP_BTN_RED = 10,
  MAIN_FIRST_RECHARGE_RED = 11,
  MAIN_PET_BOOK_BTN_RED = 12,
  PET_BOOK_ITEM_RED = 13,
  MAIN_TEAM_RED = 14,
  TEAM_PET_CELL_RISE = 15,
  TEAM_RISE_TAB = 16,
  TEAM_RISE_BTN = 17,
  TEAM_RISE_SELECT = 18,
  TEAM_CELL_EMPTY = 19,
  MAIN_PET_RED = 20,
  PET_CAN_LEVEL_UP = 21,
  TEAM_UPGRADE_TAB = 22,
  TEAM_UPGRADE_BTN = 23,
  TEAM_PET_CELL_STAR_UP = 24,
  TEAM_STAR_UP_TAB = 25,
  TEAM_STAR_UP_BTN = 26,
  TEAM_STAR_UP_SELECT = 27,
  MAIN_BLESS_RED = 28,
  BLESS_PET_RED = 29,
  BLESS_ATTRIBUTE_RED = 30,
  REGULAR_GIFT_TAB_RED = 31,
  TEAM_RISE_CONFIRM = 32,
  LIMITED_TIME_ACTIVITY = 33,
  COMBINATION_GIFT = 34,
  SIGNAL_GIFT = 35,
  MAIN_SUBSCRIBE_RED = 36
}
Define.Menu_BTN_SHOW_TYPE = {
  TOP_RIGHT_MENU = 1,
  BOTTOM_RIGHT_MENU = 2,
  TOP_LEFT_MENU = 3
}
Define.Menu_BTN_NAME = {
  [1] = "PokemonMain-LuckyEgg",
  [2] = "PokemonMain-DailyLottery",
  [3] = "PokemonMain-RechargeGift",
  [4] = "PokemonMain-RegularGift",
  [5] = "PokemonMain-Activity",
  [6] = "PokemonMain-Pet",
  [7] = "PokemonMain-Book",
  [8] = "PokemonMain-Bag",
  [9] = "PokemonMain-Team",
  [10] = "PokemonMain-Leaderboard",
  [11] = "PokemonMain-Refine",
  [12] = "PokemonMain-Syn",
  [13] = "PokemonMain-GloryHall",
  [14] = "PokemonMain-RotaryTable",
  [15] = "PokemonMain-LimitTimeCombined",
  [16] = "PokemonMain-LimitTimeSignal",
  [17] = "PokemonMain-LimitTimeActivity"
}
Define.LuckyEggTabType = {
  flashTab = 1,
  eliteTab = 2,
  normalTab = 3
}
Define.RotaryTabType = {goldTab = 1, candyTab = 2}
Define.BuyingTips = {
  buy_finish = 0,
  not_get = 1,
  item_error = 2,
  buy_fail = 3,
  no_gDiamonds = 4,
  no_gold = 5
}
Define.HTTP_STATUS_CODE = {
  OK = 200,
  CREATED = 201,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOTFOUND = 404
}
Define.GAME_GIFT_UNIQUE_ID = 8
Define.newDesignEventKey = {
  STAR_UP = "pet_star_up",
  WAKE_UP = "pet_wake_up",
  LEVEL_UP = "pet_level_up",
  CANDY_USE = "pet_candy_use",
  QUALITY_GAIN = "pet_quality_gain",
  SHOP_DIAMOND_COST = "shop_diamond_cost",
  SHOP_COIN_COST = "shop_coin_cost",
  GOLD_EXCHANGE_COST = "gold_exchange_cost",
  ROTARY_TABLE_COST = "rotary_table_cost",
  REGULAR_GIFT_COST = "regular_gift_cost",
  LIMITED_GIFT_COST = "limited_gift_cost",
  GROW_GIFT_COST = "grow_gift_cost",
  LUCKY_EGG_DIAMOND_COST = "lucky_egg_diamond_cost",
  LUCKY_EGG_COIN_COST = "lucky_egg_coin_cost",
  FIRST_RECHARGE_RECEIVE = "first_recharge_receive"
}
Define.AdvertisingType = {Battle = 203801}
Define.AdvertisingAdsId = {
  Battle = "g2038_battle_mAd"
}
Define.GameCashCouponIcon = "set:g2038_cash_coupon_icon.json image:g2038_cash_coupon_icon_1"
