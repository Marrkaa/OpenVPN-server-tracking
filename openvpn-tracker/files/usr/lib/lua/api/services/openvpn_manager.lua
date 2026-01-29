local socket = require("socket")

local M = {}

function M.connect(host, port)
	host = host or "127.0.0.1"
	port = port or 7505

	local tcp = socket.tcp()
	if not tcp then
		return nil, "Could not create a tcp socket "
	end

	tcp:settimeout(5)

	local ok, err = tcp:connect(host, port)
	if not ok then
		tcp:close()
		return nil, "Could not connect to host " .. (err or "unknown error")
	end

	local banner = tcp:receive("*l")

	return tcp, nil
end

function M.send_command(tcp, command)
	if not tcp then
		return nil, "Socket not open"
	end

	local ok, err = tcp:send(command .. "\n")
	if not ok then
		return nil, "Could not send command " .. (err or "unknown error")
	end

	local response = {}

	while true do 
		local line, err = tcp:receive("*l")
		if not line then
			if err == "timeout" then
				break
			end
			return nil, "Error while reading " .. (err or "unknown error")
		end

		table.insert(response, line)

		if line == "END" then
			break
		end

		if line:match("^SUCCESS:") or line:match("^ERROR") then
			break
		end
	end
	return response, nil
end

function M.get_status(host, port)
	local tcp, err = M.connect(host, port)
	if not tcp then
		return nil, err
	end

	local response, err = M.send_command(tcp, "status")

	tcp:close()

	if not response then
		return nil, err
	end

	local parsed = M.parse_status(response)
	return parsed, nil
end

function M.split(pString, pPattern)
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
		cap = pString:sub(last_end)
		table.insert(Table, cap)
	end
	return Table
 end

function M.parse_status(status_lines)

	local clients = {}

	local header_found = false
	local in_clients_section = false

	for i, line in ipairs(status_lines) do
		line = line:gsub("^%s+", ""):gsub("%s+$", "")
		if line:match("^OpenVPN CLIENT LIST") then
			in_clients_section = true
		elseif line:match("^ROUTING TABLE") then
			break
		end

		if in_clients_section and line:match("^Common Name") then
			header_found = true
		elseif in_clients_section and header_found then
			local parts = {}
			parts = M.split(line, ",")
			table.insert(clients, {
				common_name = parts[1],
				real_address = parts[2],
				bytes_received = parts[3],
				bytes_sent = parts[4],
				connected_since = parts[5]
			})
		end
	end

	return clients
end

function M.kill_client(host, port, common_name)
	local tcp, err = M.connect(host,port)
	if not tcp then
		return nil, err
	end
	local response, err = M.send_command(tcp, "kill " .. common_name)
	tcp:close()
	if not response then
		return nil, err
	end
	for _, line in ipairs(response) do
		if line:match("^SUCCESS:") then
			return true, nil
		elseif line:match("^ERROR:") then
			return nil, line:match("^ERROR: (.*)")
		end
	end
	return response, "Unknown response from OpenVPN"
end

return M