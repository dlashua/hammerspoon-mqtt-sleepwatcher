# mqtt-sleepwatcher Spoon for HammerSpoon
## What is it?
This Spoon will report the state of your MacOS computer to MQTT. This includes if your Mac is powered on or not, if your keyboard/mouse is idle, if your screen is locked, and if your screensaver is active.

## Requirements
1. [Hammerspoon]
2. `mosquitto_pub` from the [Mosquitto] installation.

## Installing
1. Copy `SleepWatch.spoon` into the `Spoons` directory of your HammerSpoon config location (probably `~/.hammerspoon`)
2. Add Spoon startup code to your main Hammerspoon `init.lua`

## Spoon Startup Code
Your `init.lua` file can remain largely unchanged. Just add the Spoon startup code and configuration to it.

```lua
hs.loadSpoon('SleepWatch')
spoon.SleepWatch.mqtt_host = 'YOUR MQTT HOST'
spoon.SleepWatch.mqtt_user = 'YOUR MQTT USERNAME'
spoon.SleepWatch.mqtt_pass = 'YOUR MQTT PASSWORD'
spoon.SleepWatch.mqtt_topic = 'MQTT TOPIC TO PUBLISH ON'
spoon.SleepWatch:start()
```

### Port Selection
Change the port if you're not using the default port 1883 or 8883.  Required for CloudMQTT.
```lua
spoon.SleepWatch.mqtt_port = 'YOUR MQTT PORT'
```

### TLS support (add one of these lines to the above config example)
This will force a TLS connections and change the connection port to 8883.  MacOS keeps certificates in the keychain.  If you are using `brew` then the openssl makes these available in `/usr/local/etc/openssl/cert.pem`
```lua
spoon.SleepWatch.mqtt_certFile = 'CERT FILE'
```
or
```
spoon.SleepWatch.mqtt_certPath = 'CERT PATH'
```

## Home Assistant Configuration
I made this specifically to work with [Home Assistant], however, it'll work just as well with anything capable of subscribing to MQTT topics.

If you're using Home Assistant, your configuration will look something like this.

```yaml
binary_sensor:
   - platform: mqtt
     state_topic: "fanboy/power"
     name: fanboy_power
     payload_on: 'on'
     payload_off: 'off'
     force_update: true

   - platform: mqtt
     state_topic: "fanboy/screensaver"
     name: fanboy_screensaver
     payload_on: 'on'
     payload_off: 'off'
     force_update: true

   - platform: mqtt
     state_topic: "fanboy/screens"
     name: fanboy_screens
     payload_on: 'on'
     payload_off: 'off'
     force_update: true

   - platform: mqtt
     state_topic: "fanboy/active"
     name: fanboy_active
     payload_on: 'on'
     payload_off: 'off'
     force_update: true
```

## Usage
This code publishes `on` or `off` to 4 MQTT topics depending on the state of your Mac.

* `/topic/active`
    * Checks every 60 seconds (configurable with `spoon.SleepWatch.idle_interval`).
    * Reports `off` if your Mac has not been active in the last 180 seconds (configurable with `spoon.SleepWatch.idle_time`).
* `/topic/power`
    * Reports `off` when your Mac is shutting down.
    * Reports `on` in all other cases.
* `/topic/screensaver`
    * Reports `on` when your screensaver is running
* `/topic/screens`
    * reports `off` if your screens have turned off or are locked

## Help!
I'm not a `lua` programmer. So I'm sure lots of improvements can be made. Specifically, I'd love to not be dependent on `mosquitto_pub`. However, the nature of a [Hammerspoon] install, doesn't provide `luarocks` for package/library installation. So I'd need some way to install that requirement automatically or some other MQTT implementation that is lighter than [Mosquitto].

[Hammerspoon]: http://www.hammerspoon.org
[Mosquitto]: https://mosquitto.org/
