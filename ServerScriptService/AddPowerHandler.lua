--[[
	AddPowerHandler.lua
	Location: ServerScriptService
	Listens to AddPower RemoteEvent and grants Power based on Rebirths and pet multipliers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AddPower = ReplicatedStorage:WaitForChild("AddPower")

-- Get total power multiplier from all pets in player.Pets
local function getTotalPetMultiplier(player: Player): number
	local pets = player:FindFirstChild("Pets")
	if not pets then return 1 end

	local total = 1
	for _, pet in pets:GetChildren() do
		local mult = pet:FindFirstChild("PowerMultiplier")
		if mult and mult:IsA("NumberValue") then
			total = total + mult.Value
		end
	end
	return total
end

AddPower.OnServerEvent:Connect(function(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local power = leaderstats:FindFirstChild("Power")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not power or not rebirths then return end

	-- Base gain: 1 + (Rebirths * 2)
	local baseGain = 1 + (rebirths.Value * 2)
	local petMultiplier = getTotalPetMultiplier(player)
	local finalGain = math.floor(baseGain * petMultiplier)

	power.Value = power.Value + finalGain
end)
