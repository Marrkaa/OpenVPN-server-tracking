local FunctionService = require("api/FunctionService")

local Service = FunctionService:new()

function Service:GET_TYPE_clients()
	local server_name = self.path_parameters.server_name
	local ubus = require("ubus")

	if not server_name then
		return self:ResponseError("server_name parameter required")
	end

	local conn = ubus.connect()
	if not conn then
		return self:ResponseError("Failed to connect to ubus")
	end

	local result = conn:call("openvpn." .. server_name, "get_clients", {})
	conn:close()

	if result and result.success then
		return self:ResponseOK(result)
	else
		return self:ResponseError(result and result.error or "Failed to get clients")
	end
end

return Service
