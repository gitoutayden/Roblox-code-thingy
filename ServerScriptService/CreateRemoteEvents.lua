--[[
	CreateRemoteEvents.lua
	Location: ServerScriptService (run before other game logic)
	Creates RemoteEvents in ReplicatedStorage if they don't exist.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REMOTE_NAMES = { "AddPower", "RebirthEvent", "OpenEgg" }

for _, name in REMOTE_NAMES do
	if not ReplicatedStorage:FindFirstChild(name) then
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
	end
end
