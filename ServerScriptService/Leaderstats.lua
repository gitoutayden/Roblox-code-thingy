--[[
	Leaderstats.lua
	Location: ServerScriptService
	Creates Power and Rebirths IntValues for each player when they join.
]]

local Players = game:GetService("Players")

local function createLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local power = Instance.new("IntValue")
	power.Name = "Power"
	power.Value = 0
	power.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	-- Pets folder for hatched pets (used by pet system)
	local petsFolder = Instance.new("Folder")
	petsFolder.Name = "Pets"
	petsFolder.Parent = player
end

Players.PlayerAdded:Connect(createLeaderstats)

-- Handle players already in game (e.g. when script loads late)
for _, player in Players:GetPlayers() do
	createLeaderstats(player)
end
