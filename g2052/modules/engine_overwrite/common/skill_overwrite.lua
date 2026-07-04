local SkillBase = Skill.GetType("Base")
if SkillBase then
  function SkillBase:getContainerVar(from, needCheck)
    local curBulletCount = from:getGunBulletCount()
    
    if not curBulletCount[self.containerKey] then
      local container = self.container
      if not container then
        return
      end
      curBulletCount[self.containerKey] = {}
      curBulletCount[self.containerKey].capacity = container.initCapacity
      curBulletCount[self.containerKey].container = container
      from:setGunBulletCount(curBulletCount)
    end
    return curBulletCount[self.containerKey].capacity, curBulletCount[self.containerKey].container
  end
  
  function SkillBase:setCurrentCapacity(from, capacity)
    local curBulletCount = from:getGunBulletCount()
    if not curBulletCount[self.containerKey] then
      return
    end
    curBulletCount[self.containerKey].capacity = capacity
    from:setGunBulletCount(curBulletCount)
  end
end
