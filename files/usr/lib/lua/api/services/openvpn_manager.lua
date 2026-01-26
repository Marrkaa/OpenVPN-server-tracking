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

function M.parse_status(status_lines)

	local clients = {}

	local header_found = false
	local in_clients_section = false

	for i, line in ipairs(status_lines) do
		-- print(string.format("[%d] %s", i, line))
		line = line:gsub("^%s+", ""):gsub("%s+$", "")
		if line:match("^OpenVPN CLIENT LIST") then
			in_clients_section = true
		end
		
		if in_clients_section and line:match("^Common Name") then
			header_found = true
		end
	end

	
	return clients, nil
end

return M