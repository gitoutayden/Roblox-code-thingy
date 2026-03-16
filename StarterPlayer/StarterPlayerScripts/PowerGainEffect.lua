--[[
	PowerGainEffect.lua
	Location: StarterPlayer > StarterPlayerScripts
	Anime-style particle effect when Power increases (e.g. sparkles near character or on screen).
	Uses Power.Changed; optionally add a ParticleEmitter to HumanoidRootPart or a ScreenGui.
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local lastPower = 0

local function onLeaderstatsAdded(leaderstats)
	local power = leaderstats:FindFirstChild("Power")
	if not power then return end

	lastPower = power.Value
	power.Changed:Connect(function(newPower)
		if newPower <= lastPower then return end
		lastPower = newPower

		-- Spawn a short particle burst at character position
		local character = player.Character
		if not character then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		-- Use existing ParticleEmitter on root if you added one named "PowerGain"
		local emitter = root:FindFirstChild("PowerGain")
		if emitter and emitter:IsA("ParticleEmitter") then
			emitter:Emit(5)
		end

		-- Optional: play sound from ReplicatedStorage
		-- local sfx = ReplicatedStorage:FindFirstChild("PowerUpSound")
		-- if sfx and sfx:IsA("Sound") then sfx:Play() end
	end)
end

if player:FindFirstChild("leaderstats") then
	onLeaderstatsAdded(player.leaderstats)
else
	player:WaitForChild("leaderstats")
	onLeaderstatsAdded(player.leaderstats)
end
