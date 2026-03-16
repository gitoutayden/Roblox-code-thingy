--[[
	RebirthHandler.lua
	Location: ServerScriptService
	Handles RebirthEvent: resets Power to 0 and increases Rebirths when requirement is met.
	Requirement: 100 * (Rebirths + 1)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")

local BASE_REBIRTH_COST = 100

local function getRebirthRequirement(rebirthsValue: number): number
	return BASE_REBIRTH_COST * (rebirthsValue + 1)
end

RebirthEvent.OnServerEvent:Connect(function(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local power = leaderstats:FindFirstChild("Power")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not power or not rebirths then return end

	local required = getRebirthRequirement(rebirths.Value)
	if power.Value < required then return end

	power.Value = 0
	rebirths.Value = rebirths.Value + 1
	-- Optional: fire client to play rebirth VFX/sound
end)
