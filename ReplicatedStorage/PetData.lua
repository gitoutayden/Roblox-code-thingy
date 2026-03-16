--[[
	PetData (ModuleScript)
	Location: ReplicatedStorage
	Anime-themed pet definitions: Name, Rarity, PowerMultiplier.
	Easy to expand with new pets and future anime abilities.
]]

local PetData = {}

-- Rarity order for display/sorting (higher = rarer)
PetData.Rarities = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
}

-- Pool of pets per egg type. Add more eggs by adding new keys.
PetData.Eggs = {
	StarterEgg = {
		{ Name = "Spirit Fox", Rarity = "Common", PowerMultiplier = 0.1 },
		{ Name = "Shadow Blade", Rarity = "Uncommon", PowerMultiplier = 0.25 },
		{ Name = "Mini Saiyan", Rarity = "Rare", PowerMultiplier = 0.5 },
		{ Name = "Flame Spirit", Rarity = "Common", PowerMultiplier = 0.1 },
		{ Name = "Ice Wolf", Rarity = "Uncommon", PowerMultiplier = 0.2 },
		{ Name = "Thunder Pup", Rarity = "Common", PowerMultiplier = 0.15 },
		{ Name = "Void Cat", Rarity = "Rare", PowerMultiplier = 0.45 },
		{ Name = "Celestial Dragon", Rarity = "Epic", PowerMultiplier = 0.75 },
		{ Name = "Phoenix Feather", Rarity = "Legendary", PowerMultiplier = 1.0 },
	},
}

-- Weights per rarity (higher = more likely). Used for random roll.
PetData.RarityWeights = {
	Common = 50,
	Uncommon = 30,
	Rare = 15,
	Epic = 4,
	Legendary = 1,
}

function PetData.getPetsForEgg(eggName: string): { { Name: string, Rarity: string, PowerMultiplier: number } }
	return PetData.Eggs[eggName] or PetData.Eggs.StarterEgg
end

function PetData.rollPet(eggName: string): { Name: string, Rarity: string, PowerMultiplier: number }?
	local pool = PetData.getPetsForEgg(eggName)
	if #pool == 0 then return nil end
	return pool[math.random(1, #pool)]
end

return PetData
