# Roblox Anime Click-Power Simulator — Placement Instructions

## Folder structure (in Roblox Studio)

Create these **services/folders** and place **scripts** as follows. Scripts are provided as `.lua` files; in Studio you create **Script**, **LocalScript**, or **ModuleScript** and paste the matching code.

---

## 1. ReplicatedStorage

| Item | Type | Name | Notes |
|------|------|------|--------|
| ModuleScript | ModuleScript | **PetData** | Paste contents of `ReplicatedStorage/PetData.lua`. Anime pet names and multipliers. |

**RemoteEvents:** The game creates these at runtime via `CreateRemoteEvents.lua`. If you prefer to create them manually:

- **AddPower** (RemoteEvent)
- **RebirthEvent** (RemoteEvent)
- **OpenEgg** (RemoteEvent)

---

## 2. ServerScriptService

| Script | Type | Name | Paste from |
|--------|------|------|------------|
| 1 | Script | **CreateRemoteEvents** | `ServerScriptService/CreateRemoteEvents.lua` |
| 2 | Script | **Leaderstats** | `ServerScriptService/Leaderstats.lua` |
| 3 | Script | **AddPowerHandler** | `ServerScriptService/AddPowerHandler.lua` |
| 4 | Script | **RebirthHandler** | `ServerScriptService/RebirthHandler.lua` |
| 5 | Script | **OpenEggHandler** | `ServerScriptService/OpenEggHandler.lua` |

**Order:** Ensure **CreateRemoteEvents** runs first (it can be the first script in ServerScriptService). The rest can run in any order.

---

## 3. StarterPlayer > StarterPlayerScripts

All of these are **LocalScripts**.

| Script | Type | Name | Paste from |
|--------|------|------|------------|
| 1 | LocalScript | **ClickHandler** | `StarterPlayerScripts/ClickHandler.lua` |
| 2 | LocalScript | **EggClickHandler** | `StarterPlayerScripts/EggClickHandler.lua` |
| 3 | LocalScript | **PowerGainEffect** | `StarterPlayerScripts/PowerGainEffect.lua` |
| 4 | LocalScript | **RebirthButton** | `StarterPlayerScripts/RebirthButton.lua` |

---

## 4. Workspace (Egg)

- Create a **Part** (or Model) named **Egg** or **StarterEgg**.
- Add a **ClickDetector** to that part so players can click to open the egg.
- `EggClickHandler` looks for `workspace:FindFirstChild("Egg")` or `workspace:FindFirstChild("StarterEgg")` and binds to its ClickDetector.

**Optional:** Use a GUI button instead; in that button’s `Activated` event, call:
```lua
game:GetService("ReplicatedStorage"):WaitForChild("OpenEgg"):FireServer("StarterEgg")
```

---

## 5. Anime particle effect (Power gain)

- In your **character** (or a part that spawns with the player), add a **ParticleEmitter**.
- Name it **PowerGain**.
- **PowerGainEffect** will call `Emit(5)` on it whenever Power increases.
- Suggested settings: short burst, small sparkles or stars, anime-style color (e.g. gold/blue). You can duplicate and tweak from a template in ReplicatedStorage.

---

## 6. Rebirth button (GUI)

- In **StarterGui**, create a ScreenGui (e.g. **MainGui**).
- Add a **TextButton** named **RebirthButton**.
- **RebirthButton.lua** will try to find it and bind `RebirthEvent:FireServer()` on click, and optionally update the text with the required Power and “Rebirth!” when possible.

---

## 7. Summary checklist

- [ ] ReplicatedStorage: **PetData** ModuleScript.
- [ ] ServerScriptService: **CreateRemoteEvents**, **Leaderstats**, **AddPowerHandler**, **RebirthHandler**, **OpenEggHandler**.
- [ ] StarterPlayerScripts: **ClickHandler**, **EggClickHandler**, **PowerGainEffect**, **RebirthButton** (all LocalScripts).
- [ ] Workspace: **Egg** part with **ClickDetector** (or GUI button that fires OpenEgg).
- [ ] Optional: **PowerGain** ParticleEmitter on character; **RebirthButton** in StarterGui.

---

## 8. Data flow

- **Click** → LocalScript **ClickHandler** fires **AddPower** → **AddPowerHandler** adds Power (with rebirth and pet multipliers).
- **Rebirth** → GUI calls **RebirthEvent:FireServer()** → **RebirthHandler** checks requirement, resets Power, adds Rebirths.
- **Egg** → Player clicks Egg (ClickDetector) → **EggClickHandler** fires **OpenEgg** with egg name → **OpenEggHandler** uses **PetData** to roll a pet and adds it to **player.Pets**.
- **Pets** → Stored in **player.Pets**; **AddPowerHandler** sums their **PowerMultiplier** and multiplies base gain.

All scripts are written so they wait for required children (e.g. `WaitForChild("AddPower")`) and are safe to load in any order after **CreateRemoteEvents**.
