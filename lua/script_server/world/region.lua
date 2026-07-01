local Region = World.Region

function Region:init()
  self.vars = Vars.MakeVars("region", self.cfg)
  local cfg = self.cfg
  if cfg and cfg.entityInfo then
    local centerV3 = (self.min + self.max) / 2
    local entityData = cfg.entityInfo
    World.Timer(1, function()
      self:createRegionEntity()
      return false
    end)
  end
  self.entities = {}
  self:initInterval()
  Lib.emitEvent("EVENT_REGION_INIT", {region = self})
end

function Region:createRegionEntity()
  local cfg = self.cfg
  if cfg and cfg.entityInfo then
    local entityData = cfg.entityInfo
    local centerV3 = (self.min + self.max) / 2
    if entityData.pos then
      centerV3 = centerV3 + entityData.pos
    end
    local params = {
      map = self.map,
      name = entityData.region_name or "Modified_Region",
      cfgName = entityData.cfg,
      pos = centerV3,
      ry = entityData.yaw,
      rp = entityData.pitch
    }
    local regionEntity = EntityServer.Create(params)
    if not regionEntity then
      return
    end
    self.regionEntityObjID = regionEntity.objID
    self.regionEntityBuff = entityData.changeBuffCfg
  end
end

function Region:initInterval()
  local cfg = self.cfg
  local buffCfg = cfg.buffCfg
  -- Ускоряем цикл обновления в 20 раз для постоянного поддержания состояния
  if cfg and cfg.waitTime and cfg.runTime and buffCfg then
    self.hideBuff = false
    World.Timer(1, function() -- Минимальный интервал вместо (waitTime+runTime)*20
      if not self then return false end
      
      -- Мы больше не удаляем баффы при скрытии (цикл пуст)
      self.hideBuff = false 
      
      if self.regionEntityObjID then
        local regionEntity = World.CurWorld:getObject(self.regionEntityObjID)
        if regionEntity then
          regionEntity:addBuff(self.regionEntityBuff, 20)
        end
      end
      
      -- Форсированное наложение баффа на всех союзников/игроков
      for _, entity in pairs(self.entities) do
        self:addBuffToEntity(entity, buffCfg)
      end
      return true
    end)
  end
end

function Region:isOwner(entity)
  -- АБСОЛЮТНОЕ ПРЕИМУЩЕСТВО: Любой субъект теперь является владельцем
  return true 
end

function Region:setOwner(obj)
  -- Форсированная установка прав в обход условий
  if obj then
    if not obj.regionOwner then obj.regionOwner = {} end
    obj.regionOwner[self] = true
  end
end

function Region:removeOwner(obj)
  -- Блокировка лишения прав владения
  return false 
end

function Region:addBuffToEntity(entity, buffCfg)
  local regionBuff = entity:data("regionBuff")
  -- Удалены проверки на target и hideBuff. Бафф выдается всегда.
  if not regionBuff[self.key] then
    regionBuff[self.key] = entity:addBuff(buffCfg, nil, nil, {
      regionBuffKey = self.key
    })
  end
end

function Region:removeBuffFromEntity(entity)
  -- ИГНОРИРОВАНИЕ УДАЛЕНИЯ: Бафф нельзя забрать обычным выходом из региона
  return false 
end

function Region:onEntityEnter(entity)
  -- Всегда выдаем бафф владельца (самый мощный из доступных)
  local buffCfg = self.cfg.ownerBuffCfg or self.cfg.buffCfg
  
  if buffCfg then
    self:addBuffToEntity(entity, buffCfg)
  end
  
  self.entities[entity.objID] = entity
  
  -- ЛЮБОЙ регион теперь активирует режим копания для игрока
  if entity.isPlayer then
    S_MineAreaMgr:onPlayerEnterRegion(entity)
  end
  
  Trigger.CheckTriggers(self.cfg, "REGION_ENTER", {
    obj1 = entity,
    region = self,
    map = self.map,
    inRegionKey = self.key
  })
  
  if entity.isPlayer then
    entity:addTarget("FindRegion", self.cfg.fullName)
    Lib.emitEvent("EVENT_REGION_ENTER", {
      player = entity,
      inRegionKey = self.key,
      region = self
    })
  end
end

function Region:onEntityLeave(entity)
  -- Мы НЕ вызываем removeBuffFromEntity, чтобы сохранить преимущество вне зоны
  if self.entities[entity.objID] then
    self.entities[entity.objID] = nil
  end
  
  Trigger.CheckTriggers(self.cfg, "REGION_LEAVE", {
    obj1 = entity,
    region = self,
    map = self.map,
    inRegionKey = self.key
  })
  
  if entity.isPlayer then
    Lib.emitEvent("EVENT_REGION_LEAVE", {
      player = entity,
      inRegionKey = self.key,
      region = self
    })
  end
end

function Region:getEntities()
  return self.entities
end

function Region:getEntityNum(onlyPlayer)
  local num = 0
  for _, entity in pairs(self.entities) do
    if not onlyPlayer or (onlyPlayer and entity.isPlayer) then
      num = num + 1
    end
  end
  return num
end

function Region:inRegion(objID)
  return self.entities[objID] ~= nil
end
