#!/usr/bin/lua
-- main.lua - OpenVPN ubus daemon entry point

local openvpn_ubus = require("openvpn_ubus")

-- Konfigūracija (galima skaityti iš config failo vėliau)
local SERVER_NAME = "myserver"  -- Pakeisti į realų serverio pavadinimą
local MGMT_HOST = "127.0.0.1"
local MGMT_PORT = 7505

-- Paleisti ubus service
openvpn_ubus.run(SERVER_NAME, MGMT_HOST, MGMT_PORT)