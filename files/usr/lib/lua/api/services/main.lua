#!/usr/bin/lua
local openvpn_ubus = require("openvpn_ubus")

local SERVER_NAME = "myserver"
local MGMT_HOST = "127.0.0.1"
local MGMT_PORT = 7505

openvpn_ubus.run(SERVER_NAME, MGMT_HOST, MGMT_PORT)