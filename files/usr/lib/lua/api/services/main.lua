local openvpn = require("openvpn_manager")

local clients, err = openvpn.get_status("127.0.0.1", 7505)

if not clients then
    print("ERROR: " .. (err or "unknown error"))
    os.exit(1)
end

print("\n=== Parsing clients ===")
print("Found clients: " .. #clients)
for i, client in ipairs(clients) do
    print(string.format("%d. %-10s | %20s | RX: %8d | TX: %8d | %s", i, client.common_name,
    client.real_address, client.bytes_received, client.bytes_sent, client.connected_since))
end

local target = clients[1]
local success, err = openvpn.kill_client("127.0.0.1", 7505, target.common_name)
if success then
    print("Successfully killed client: " .. target.common_name)
else
    print("ERROR: " .. (err or "unknown error"))
    os.exit(1)
end

local clients_after, err = openvpn.get_status("127.0.0.1", 7505)
if not clients_after then
    print("ERROR: " .. (err or "unknown error"))
    os.exit(1)
end

print("\n=== Clients after kill ===")
print("Found clients: " .. #clients_after)
for i, client in ipairs(clients_after) do
    print(string.format("%d. %-10s | %20s | RX: %8d | TX: %8d | %s", i, client.common_name,
    client.real_address, client.bytes_received, client.bytes_sent, client.connected_since))
end