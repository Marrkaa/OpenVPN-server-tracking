local openvpn = require("openvpn_manager")

local status, err = openvpn.get_status("127.0.0.1", 7505)

if not status then
    print("ERROR: " .. (err or "unknown error"))
    os.exit(1)
end

print("Response length: " .. #status)
print("\nAll lines:")
for i, line in ipairs(status) do
    print(string.format("[%d] %s", i, line))
end

if openvpn.parse_status then
    print("\n=== Parsing clients ===")
    local clients = openvpn.parse_status(status)
    print("Found clients: " .. #clients)
    for i, client in ipairs(clients) do
        print(string.format("%d. %s (%s)", i, client.common_name, client.real_address))
    end
end