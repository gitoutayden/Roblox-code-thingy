--[[
	ClickHandler.lua
	Location: StarterPlayer > StarterPlayerScripts
	Fires AddPower to server on MouseButton1 click. Optional: spawn particle effect on click.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AddPower = ReplicatedStorage:WaitForChild("AddPower")

local lastClickTime = 0
local CLICK_COOLDOWN = 0.1 -- 100ms cooldown to prevent race conditions with rebirth
local isGUIElementPressed = false

-- Track when any GUI element is being pressed
local function trackGUIButtonStates()
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Recursively find and track all GUI buttons
	local function trackButton(obj)
		if obj:IsA("GuiButton") then
			obj.MouseButton1Down:Connect(function()
				isGUIElementPressed = true
			end)
			obj.MouseButton1Up:Connect(function()
				isGUIElementPressed = false
			end)
		end
		for _, child in obj:GetChildren() do
			trackButton(child)
		end
	end
	
	trackButton(playerGui)
end

task.defer(trackGUIButtonStates)

-- Optional: play click effect (e.g. at mouse position or on a GUI button)
-- You can add a ParticleEmitter to a part or ScreenGui and trigger it here.
local function onPowerClick()
	-- Don't allow clicks while GUI buttons are being pressed
	if isGUIElementPressed then
		return
	end
	
	local currentTime = tick()
	-- Debounce clicks to prevent race conditions with rebirth
	if currentTime - lastClickTime < CLICK_COOLDOWN then
		return
	end
	lastClickTime = currentTime
	AddPower:FireServer()
	-- Future: trigger anime particle effect (e.g. "PowerGainEffect" in ReplicatedStorage)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		onPowerClick()
	end
end)
