local singleton = {
  static = {}
}

function singleton:included(class)
  class.static._new = class.static.new
  
  function class.static.new()
    error("Use " .. class.name .. ":instance() instead of :new()")
  end
end

function singleton.static:instance(...)
  self._instance = self._instance or self._new(self, ...)
  return self._instance
end

function singleton.static:clear_instance()
  self._instance = nil
end

return singleton
