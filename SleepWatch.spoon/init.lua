local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SleepWatch"
obj.version = "0.1"
obj.author = "Daniel Lashua <daniel@inklog.net>"
obj.homepage = "none"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Set Defaults
obj.power = 'on'
obj.screensaver = 'off'
obj.screens = 'on'
obj.active = 'on'

obj.mqtt_host = 'none'
obj.mqtt_user = 'none'
obj.mqtt_pass = 'none'
obj.mqtt_topic = 'none'

obj.idle_time = 180
obj.idle_interval = 60

function obj:mqtt_publish(topic, message)
  if self.mqtt_host == 'none' then
    error('mqtt_host is required')
    return
  end

  command = 'mosquitto_pub -r -h ' .. self.mqtt_host 

  if self.mqtt_user ~= 'none' then
    command = command .. ' -u ' .. self.mqtt_user .. ' -P ' .. self.mqtt_pass 
  end
    
  command = command .. ' -t ' .. topic .. ' -m "' .. message .. '"'

  rout, rstatus, rtype, rrc = hs.execute(command, true)
  if rrc ~= 0 then
    error('error code ' .. rrc .. ' in system command: ' .. command)
  end
end

function obj:postall()
  if self.mqtt_topic == 'none' then
    error('mqtt_topic is required')
    return
  end

  self:mqtt_publish(self.mqtt_topic .. '/power', self.power)
  self:mqtt_publish(self.mqtt_topic .. '/screensaver', self.screensaver)
  self:mqtt_publish(self.mqtt_topic .. '/screens', self.screens)
  self:mqtt_publish(self.mqtt_topic .. '/active', self.active)
end

function obj:idleWatch()
    if (hs.host.idleTime() > self.idle_time) then
        hs.notify.show("System Inactive", "", "")
        self.active = 'off'
    else
        self.active = 'on'
    end
    
    self:postall()
end

function obj:sleepWatch(eventType)
      if (eventType == hs.caffeinate.watcher.systemDidWake) then
        hs.notify.show("System Wake!", "", "")
        self.power = 'on'
      elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
        hs.notify.show("System Sleep", "", "")
        self.power = 'off'
        self.screensaver = 'off'
        self.screens = 'off'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.systemWillPowerOff) then
        hs.notify.show("System Power Off", "", "")
        self.power = 'off'
        self.screensaver = 'off'
        self.screens = 'off'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensavedDidStart) then
        hs.notify.show("Screensaver On", "", "")
        self.screensaver = 'on'
        self.power = 'on'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensaverDidStop) then
        hs.notify.show("Screensaver Off", "", "")
        self.screensaver = 'off'
        self.power = 'on'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensDidLock) then
        hs.notify.show("Screens Locked", "", "")
        self.screens = 'off'
        self.power = 'on'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensDidSleep) then
        hs.notify.show("Screens Sleep", "", "")
        self.screens = 'off'
        self.power = 'on'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensDidUnlock) then
        hs.notify.show("Screens Unlocked", "", "")
        self.screens = 'on'
        self.power = 'on'
        self.active = 'on'
      elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
        hs.notify.show("Screens Wake", "", "")
        self.screens = 'off'
        self.power = 'on'
        self.active = 'on'
      end

      self:postall()
end

function obj:start()
  self:postall()
  hs.caffeinate.watcher.new(function() self:sleepWatch() end):start()
  hs.timer.new(self.idle_interval,function () self:idleWatch() end, true):start()
end

return obj
