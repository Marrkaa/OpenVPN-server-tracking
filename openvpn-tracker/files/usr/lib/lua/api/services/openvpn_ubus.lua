local ubus = require("ubus")
local uloop = require("uloop")
local openvpn = require("openvpn_manager")

local M = {}

function M.create_service(conn, server_name, mgmt_host, mgmt_port)
	local methods = {
		["openvpn." .. server_name] = {
			get_clients = {
				function(req, msg)
					local clients, err = openvpn.get_status(mgmt_host, mgmt_port)

					if not clients then
						conn:reply(req, {
							success = false,
							error = err or "Failed to get clients"
						})
						return
					end

					local result = {
						success = true,
						server_name = server_name,
						client_count = #clients,
						clients = {}
					}

					for i, client in ipairs(clients) do
						table.insert(result.clients, {
							common_name = client.common_name,
							real_address = client.real_address,
							bytes_received = tonumber(client.bytes_received) or 0,
							bytes_sent = tonumber(client.bytes_sent) or 0,
							connected_since = client.connected_since
						})
					end

					conn:reply(req, result)
				end,
				{}
			},

			kill_client = {
				function(req, msg)
					if not msg.common_name then
						conn:reply(req, {
							success = false,
							error = "common_name parameter required"
						})
						return
					end

					local success, err = openvpn.kill_client(mgmt_host, mgmt_port, msg.common_name)

					if success then
						conn:reply(req, {
							success = true,
							message = "Client " .. msg.common_name .. " disconnected"
						})
					else
						conn:reply(req, {
							success = false,
							error = err or "Failed to kill client"
						})
					end
				end,
				{ common_name = ubus.STRING }
			}
		}
	}

	return methods
end

function M.run(server_name, mgmt_host, mgmt_port)
	mgmt_host = mgmt_host or "127.0.0.1"
	mgmt_port = mgmt_port or 7505

	uloop.init()

	local conn = ubus.connect()
	if not conn then
		error("Failed to connect to ubus")
	end

	local methods = M.create_service(conn, server_name, mgmt_host, mgmt_port)
	conn:add(methods)

	print("OpenVPN ubus service started: openvpn." .. server_name)
	print("  Management: " .. mgmt_host .. ":" .. mgmt_port)
	print("  Methods: get_clients, kill_client")

	uloop.run()
end

return M