print('Starting...')
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SleepWatch"
obj.version = "0.4"
obj.author = "Daniel Lashua <daniel@inklog.net>"
obj.homepage = "https://github.com/dlashua/hammerspoon-mqtt-sleepwatcher"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Set Defaults
obj.power = 'on'
obj.screensaver = 'off'
obj.screens = 'on'
obj.active = 'on'

obj.mqtt_host = 'none'
obj.mqtt_user = 'none'
obj.mqtt_pass = 'none'
obj.mqtt_port = 'none'
obj.mqtt_topic = 'none'

obj.mqtt_certFile = 'none'
obj.mqtt_certPath = 'none'

obj.notifications = false
obj.debug = false

obj.idle_time = 180
obj.idle_interval = 60

function obj:mqtt_publish(topic, message)
  if self.mqtt_host == 'none' then
    error('mqtt_host is required')
    return
  end

  command = 'mosquitto_pub -r -h ' .. self.mqtt_host

  if self.mqtt_user ~= 'none' then
    command = command .. ' -u ' .. self.mqtt_user .. ' -P "' .. self.mqtt_pass .. '"'
  end

  if self.mqtt_certFile ~= 'none' then
    command = command .. ' --cafile ' .. self.mqtt_certFile
  elseif self.mqtt_certPath ~= 'none' then
    command = command .. ' --capath ' .. self.mqtt_certPath
  end

  if self.mqtt_port ~= 'none' then
    command = command .. ' -p ' .. self.mqtt_port
  end

  command = command .. ' -t ' .. topic .. ' -m "' .. message .. '"'

  if self.debug then
    command = command .. ' -d '
    print('Command: ' .. command)
  end

  -- redirect STDERR to STDOUT
  command = command .. '2>&1'

  rout, rstatus, rtype, rrc = hs.execute(command, true)
  if self.debug then
    print('rstatus: ' .. tostring(rstatus))
    print('rtype: ' .. rtype)
    print('rrc: ' .. rrc)
    print('rout:\n' .. rout)
  end

  if rrc ~= 0 then
    error('error code ' .. rrc .. ' in system command: ' .. command)
  elseif string.match(rout, 'error') then
    -- Wrong password looks like:
    -- Client mosq-yak5yv9AHmnenXvKnE sending CONNECT
    -- Client mosq-yak5yv9AHmnenXvKnE received CONNACK (5)
    -- Connection error: Connection Refused: not authorised.
    -- Client mosq-yak5yv9AHmnenXvKnE sending DISCONNECT
    error('error output: ' .. rout .. ' in system command: ' .. command)
  end
end

function obj:postall()
  if self.mqtt_topic == 'none' then
    error('mqtt_topic is required')
    return
  end

  print('power ' .. self.power)
  self:mqtt_publish(self.mqtt_topic .. '/power', self.power)
  print('screensaver ' .. self.screensaver)
  self:mqtt_publish(self.mqtt_topic .. '/screensaver', self.screensaver)
  print('screens ' .. self.screens)
  self:mqtt_publish(self.mqtt_topic .. '/screens', self.screens)
  print('active ' .. self.active)
  self:mqtt_publish(self.mqtt_topic .. '/active', self.active)
  print(' ')
end

function obj:idleWatch()
    if (hs.host.idleTime() > self.idle_time) then
      if self.notifications then
        hs.notify.show("System Inactive", "", "")
      end
      self.active = 'off'
    else
      self.active = 'on'
    end

    if self.debug then
      print('watch idle_interval: ' .. self.idle_interval .. ' idle_time: ' .. self.idle_time ..  ' idle: ' .. hs.host.idleTime())
    end

    self:postall()
end

function obj:sleepWatch(eventType)
      if (eventType == hs.caffeinate.watcher.systemDidWake) then
        if self.notifications then
            hs.notify.show("System Wake!", "", "")
        end
        self.power = 'on'
      elseif (eventType == hs.caffeinate.watcher.systemWillSleep) then
        if self.notifications then
            hs.notify.show("System Sleep", "", "")
        end
        self.power = 'off'
        self.screensaver = 'off'
        self.screens = 'off'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.systemWillPowerOff) then
        if self.notifications then
            hs.notify.show("System Power Off", "", "")
        end
        self.power = 'off'
        self.screensaver = 'off'
        self.screens = 'off'
        self.active = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensaverDidStart) then
        if self.notifications then
            hs.notify.show("Screensaver On", "", "")
        end
        self.screensaver = 'on'
        self.screens = 'off'
        self.power = 'on'
      elseif (eventType == hs.caffeinate.watcher.screensaverDidStop) then
        if self.notifications then
            hs.notify.show("Screensaver Off", "", "")
        end
        self.screensaver = 'off'
        self.screens = 'on'
        self.power = 'on'
      elseif (eventType == hs.caffeinate.watcher.screensDidLock) then
        if self.notifications then
            hs.notify.show("Screens Locked", "", "")
        end
        self.screens = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensDidSleep) then
        if self.notifications then
            hs.notify.show("Screens Sleep", "", "")
        end
        self.screens = 'off'
      elseif (eventType == hs.caffeinate.watcher.screensDidUnlock) then
        if self.notifications then
            hs.notify.show("Screens Unlocked", "", "")
        end
        self.screens = 'on'
      elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
        if self.notifications then
            hs.notify.show("Screens Wake", "", "")
        end
        self.screens = 'on'
      end

      self:postall()
end


function obj:start()
  self:postall()
  -- https://github.com/Hammerspoon/hammerspoon/issues/1942#issuecomment-430450705
  -- stops working after some time, this would suggest garbage collection
  myWatcher = hs.caffeinate.watcher.new(function(eventType) self:sleepWatch(eventType) end)
  myTimer = hs.timer.new(self.idle_interval,function () self:idleWatch() end, true)

  myWatcher:start()
  myTimer:start()
  print('Started')
end

return obj
