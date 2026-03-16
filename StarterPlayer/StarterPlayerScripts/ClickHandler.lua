--[[
	ClickHandler.lua
	Location: StarterPlayer > StarterPlayerScripts
	Fires AddPower to server on MouseButton1 click. Optional: spawn particle effect on click.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AddPower = ReplicatedStorage:WaitForChild("AddPower")

-- Optional: play click effect (e.g. at mouse position or on a GUI button)
-- You can add a ParticleEmitter to a part or ScreenGui and trigger it here.
local function onPowerClick()
	AddPower:FireServer()
	-- Future: trigger anime particle effect (e.g. "PowerGainEffect" in ReplicatedStorage)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		onPowerClick()
	end
end)
