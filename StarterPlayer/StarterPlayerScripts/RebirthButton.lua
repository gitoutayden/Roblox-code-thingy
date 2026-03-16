--[[
	RebirthButton.lua
	Location: StarterPlayer > StarterPlayerScripts
	Fires RebirthEvent when the player has enough Power.
	Hook this to a GUI button: button.Activated:Connect(function() RebirthEvent:FireServer() end)
	Or use this script to drive a visible rebirth button's state (can require, enable, show cost).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local player = Players.LocalPlayer

local BASE_REBIRTH_COST = 100

local function getRebirthRequirement(rebirthsValue: number): number
	return BASE_REBIRTH_COST * (rebirthsValue + 1)
end

-- Call this when player clicks "Rebirth" (e.g. from a TextButton)
local function tryRebirth()
	RebirthEvent:FireServer()
end

-- Export for GUI: get current requirement and whether player can rebirth
local function getRebirthInfo()
	local player = Players.LocalPlayer
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return 0, false end

	local power = leaderstats:FindFirstChild("Power")
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not power or not rebirths then return 0, false end

	local required = getRebirthRequirement(rebirths.Value)
	return required, power.Value >= required
end

-- Example: bind to a button named "RebirthButton" in StarterGui
local function bindRebirthButton()
	local gui = player:WaitForChild("PlayerGui")
	local screen = gui:FindFirstChild("MainGui") or gui:GetChildren()[1]
	if not screen then return end

	local button = screen:FindFirstChild("RebirthButton")
	if button and button:IsA("GuiButton") then
		button.Activated:Connect(tryRebirth)
		-- Optional: update button text with cost
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local rebirths = leaderstats:FindFirstChild("Rebirths")
			if rebirths then
				local function updateLabel()
					local req, canDo = getRebirthInfo()
					local label = button:FindFirstChild("Label") or button
					if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
						label.Text = canDo and ("Rebirth! (" .. req .. ")") or ("Need " .. req .. " Power")
					end
				end
				rebirths.Changed:Connect(updateLabel)
				player.leaderstats.Power.Changed:Connect(updateLabel)
				updateLabel()
			end
		end
	end
end

task.defer(bindRebirthButton)
