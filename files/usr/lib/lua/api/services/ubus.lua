#!/usr/bin/lua
local ubus = require "ubus"
local uloop = require "uloop"
local count = 0

uloop.init()

local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

local methods = {
	counter = {
		get = {
			function(req, msg)
				conn:reply(req, {count = count})
			end, {}
		},
		add = {
			function(req, msg)
				count = msg.value
				conn:reply(req, {count = count})
			end, {value = ubus.INT32 }
		}
	}
}

conn:add(methods)
uloop.run()