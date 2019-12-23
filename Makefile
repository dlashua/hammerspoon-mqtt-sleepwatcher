HS ?= $${HOME}/.hammerspoon

all: help

install: update
	brew install mosquitto
	touch $(HS)/init.lua
	cat init.lua >> $(HS)/init.lua
	$(warning Must edit $(HS)/init.lua to change defaults)

update:
	cp -r SleepWatch.spoon $(HS)/Spoons/

help:
	$(info Copy configs to $(HS))
	$(info make install adds to $(HS)/init.lua and copies spoon)
	$(info make update only copies spoon)
