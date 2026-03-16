--[[
	OpenEggHandler.lua
	Location: ServerScriptService
	Handles OpenEgg RemoteEvent: rolls a pet from PetData and adds it to player.Pets.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local OpenEgg = ReplicatedStorage:WaitForChild("OpenEgg")
local PetData = require(ReplicatedStorage:WaitForChild("PetData"))

OpenEgg.OnServerEvent:Connect(function(player: Player, eggName: string?)
	eggName = eggName or "StarterEgg"

	local petsFolder = player:FindFirstChild("Pets")
	if not petsFolder then return end

	local petInfo = PetData.rollPet(eggName)
	if not petInfo then return end

	-- Create pet instance under player.Pets
	local pet = Instance.new("Folder")
	pet.Name = petInfo.Name

	local nameValue = Instance.new("StringValue")
	nameValue.Name = "Name"
	nameValue.Value = petInfo.Name
	nameValue.Parent = pet

	local rarityValue = Instance.new("StringValue")
	rarityValue.Name = "Rarity"
	rarityValue.Value = petInfo.Rarity
	rarityValue.Parent = pet

	local multValue = Instance.new("NumberValue")
	multValue.Name = "PowerMultiplier"
	multValue.Value = petInfo.PowerMultiplier
	multValue.Parent = pet

	pet.Parent = petsFolder
end)
