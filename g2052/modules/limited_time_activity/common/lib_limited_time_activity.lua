local Lib = _ENV.Lib

function Lib.getTimeByArray(array)
  return os.time({
    year = array[1] or 0,
    month = array[2] or 0,
    day = array[3] or 0,
    hour = array[4] or 0,
    min = array[5] or 0,
    sec = array[6] or 0
  })
end

function Lib.getSecondsByArray(array)
  return (array[1] or 0) * Lib.getDaySeconds() + (array[2] or 0) * 3600 + (array[3] or 0) * 60 + (array[4] or 0)
end

function Lib.isActivitySameMonth(time1, time2)
  local date1 = os.date("*t", time1)
  local date2 = os.date("*t", time2)
  return date1.year == date2.year and date1.month == date2.month
end

function Lib.isActivitySameWeek(time1, time2)
  local startTime = Lib.getActivityWeekStartTime(time1)
  local endTime = Lib.getActivityWeekEndTime(time1)
  if time2 >= startTime and time2 <= endTime then
    return true
  else
    return false
  end
end

function Lib.getActivityWeekStartTime(time)
  local date = os.date("*t", time)
  local curTime = os.time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = 0
  })
  local startTime
  local oneDayTime = 86400
  if date.wday == 1 then
    startTime = curTime - oneDayTime * 6
  else
    startTime = curTime - oneDayTime * (date.wday - 2)
  end
  return startTime
end

function Lib.getActivityWeekEndTime(time)
  local date = os.date("*t", time)
  local curTime = os.time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = 0
  })
  local endTime
  local oneDayTime = 86400
  if date.wday == 1 then
    endTime = curTime + oneDayTime
  else
    endTime = curTime + oneDayTime * (9 - date.wday)
  end
  return endTime
end

function Lib.getDifferDayNum(timeNow, timeNext)
  local ret = 0
  if timeNow and timeNext then
    local now = os.date("*t", timeNow)
    local next = os.date("*t", timeNext)
    if now and next then
      local num1 = os.time({
        year = now.year,
        month = now.month,
        day = now.day
      })
      local num2 = os.time({
        year = next.year,
        month = next.month,
        day = next.day
      })
      if num1 and num2 then
        ret = (num2 - num1) / 86400
      end
    end
  end
  return math.floor(ret)
end
