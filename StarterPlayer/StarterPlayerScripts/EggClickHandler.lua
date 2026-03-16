--[[
	EggClickHandler.lua
	Location: StarterPlayer > StarterPlayerScripts
	When the player clicks the Egg part (or a GUI button for the egg), fires OpenEgg.
	Configure EGG_PART_NAME or use ProximityPrompt / ClickDetector if you prefer.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local OpenEgg = ReplicatedStorage:WaitForChild("OpenEgg")

-- Option A: Use a ClickDetector on the Egg part (this runs on client when clicked)
local function bindEggClickDetector()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Find egg in workspace (customize name/location as needed)
	local egg = workspace:FindFirstChild("Egg") or workspace:FindFirstChild("StarterEgg")
	if not egg then return end

	local clickDetector = egg:FindFirstChildOfClass("ClickDetector")
	if clickDetector then
		clickDetector.MouseClick:Connect(function()
			OpenEgg:FireServer("StarterEgg")
		end)
	end
end

-- If egg exists when character loads
local player = Players.LocalPlayer
if player.Character then
	bindEggClickDetector()
else
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		bindEggClickDetector()
	end)
end

-- Option B: Fire from a GUI button instead — in your Egg Button's Activated:
-- OpenEgg:FireServer("StarterEgg")
