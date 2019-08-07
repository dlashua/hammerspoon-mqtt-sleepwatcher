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
