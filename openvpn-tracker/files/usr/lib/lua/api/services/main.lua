#!/usr/bin/lua
package.path = package.path .. ";/usr/lib/lua/api/services/?.lua"

local uci = require("uci")
local ubus = require("ubus")
local uloop = require("uloop")
local openvpn_ubus = require("openvpn_ubus")

local function get_openvpn_servers()
	local cursor = uci.cursor()
	local servers = {}

	cursor:foreach("openvpn", "openvpn", function(s)
		if s.enable == "1" and s.mode == "server" then
			local mgmt_host = "127.0.0.1"
			local mgmt_port = 7505

			if s.extra then
				for _, extra in ipairs(s.extra) do
					local host, port = extra:match("management%s+(%S+)%s+(%d+)")
					if host and port then
						mgmt_host = host
                        local port_num = tonumber(port)
                        if port_num then
                            mgmt_port = port_num
                        end
						break
					end
				end
			end

			local server_name = s.name or s[".name"]

			table.insert(servers, {
				name = server_name,
				mgmt_host = mgmt_host,
				mgmt_port = mgmt_port
			})
		end
	end)

	cursor:close()
	return servers
end

local servers = get_openvpn_servers()

if #servers == 0 then
	print("No OpenVPN servers found in UCI config")
	os.exit(1)
end

uloop.init()
local conn = ubus.connect()
if not conn then
	error("Failed to connect to ubus")
end

for _, server in ipairs(servers) do
	local methods = openvpn_ubus.create_service(
		conn,
		server.name,
		server.mgmt_host,
		server.mgmt_port
	)
	conn:add(methods)
end

uloop.run()