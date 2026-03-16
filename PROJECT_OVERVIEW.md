# Roblox Anime Click-Power Simulator — Project Overview

This is an **Anime-themed click/power simulator** game for Roblox. If you're familiar with Lua but new to Roblox, this document explains the architecture, mechanics, and how the code fits together.

---

## Quick Summary

**Game Concept:** Players click to gain "Power", hatch anime-themed pets from eggs, use pets to unlock multipliers, and reset their progress through "Rebirths" to gain a permanent multiplier bonus.

**Tech Stack:** Roblox Lua (similar to standard Lua with Roblox-specific APIs), split into **server-side** (ServerScriptService) and **client-side** (LocalScripts) code.

---

## Roblox Basics (For Lua Devs)

### What is Roblox?
Roblox is an online platform where you build multiplayer games. Games run on **Roblox servers** (not your computer). You write Lua code, and Roblox executes it in real-time.

### Script Types

| Type | Runs Where | Purpose |
|------|-----------|---------|
| **Script** | Server | Runs on the Roblox server; trusted, handles logic & validation |
| **LocalScript** | Client (Player's PC) | Runs on the player's computer; handles UI, input, visuals |
| **ModuleScript** | Either (requires import) | Reusable Lua module; no dependencies on server/client |

### Key Services
Services are like APIs built into Roblox. Common ones:
- `Players` — Access player objects
- `UserInputService` — Detect keyboard/mouse input
- `ReplicatedStorage` — Shared storage between server and client
- `ServerScriptService` — Where server-side scripts run

### RemoteEvents
A **RemoteEvent** is a bridge between client and server. Think of it like writing to a shared message queue:
```lua
-- Client fires event to server
RemoteEvent:FireServer(data)

-- Server listens for event
RemoteEvent.OnServerEvent:Connect(function(player, data)
    -- handle it
end)
```

### Instances & Hierarchy
Roblox games are built from **Instances** (objects with `.Parent`, `.Name`, properties). You can navigate the hierarchy:
```lua
local player = game:GetService("Players"):FindFirstChild("PlayerName")
local stats = player:FindFirstChild("leaderstats")
```

---

## Folder Structure & File Purpose

### 📁 **ReplicatedStorage/** — Shared Assets

**PetData (ModuleScript)**
- Defines all available anime pets with their stats
- Contains lists of pets per egg type
- Rarity tiers (Common → Legendary) and their drop rates
- Each pet has: `Name`, `Rarity`, `PowerMultiplier`
- **Used by:** `OpenEggHandler` to roll/spawn pets
- **Format:** A Lua table that other scripts import with `require()`

### 📁 **ServerScriptService/** — Game Logic (Server-Side)

These scripts handle the core game mechanics and run on the Roblox server (trusted environment).

#### **CreateRemoteEvents.lua** ⭐ **(Run First!)**
- **What it does:** Creates three RemoteEvent bridges if they don't already exist
  - `AddPower` — Client fires this when clicking
  - `OpenEgg` — Client fires this when opening an egg
  - `RebirthEvent` — Client fires this when rebirthing
- **Why:** RemoteEvents must exist before other scripts try to use them
- **Order:** Must run *before* other scripts try to access these events

#### **Leaderstats.lua**
- **What it does:** Sets up the player's statistics folder when they join
- **Creates:**
  - `player.leaderstats.Power` (IntValue) — Current power points
  - `player.leaderstats.Rebirths` (IntValue) — Times player has rebirthed
  - `player.Pets` (Folder) — Stores hatched pets as child instances
- **Why:** Leaderstats are the standard Roblox way to track player data that shows on the leaderboard

#### **AddPowerHandler.lua**
- **What it does:** Listens to the `AddPower` event and grants power
- **Logic:**
  ```
  finalPower = BasePower × PetMultiplier
  BasePower = 1 + (Rebirths × 2)
  PetMultiplier = 1 + (sum of all pet power multipliers)
  ```
- **Flow:** Client clicks → fires `AddPower` → server adds power + particle effect reference
- **Example:** With 2 rebirths and one pet (+0.5 multiplier), a click gives: `(1 + 2×2) × (1 + 0.5) = 7.5 → 7` power

#### **RebirthHandler.lua**
- **What it does:** Resets Power to 0 and increments Rebirths when player has enough power
- **Cost Formula:** `100 × (Current Rebirths + 1)`
  - 1st rebirth: 100 power
  - 2nd rebirth: 200 power
  - 3rd rebirth: 300 power (etc.)
- **Flow:** Client clicks rebirth → server validates power → resets power, increments rebirths
- **Why:** Rebirths are permanent multiplier bonuses, so you reset to grind again

#### **OpenEggHandler.lua**
- **What it does:** Rolls a random pet from the egg and adds it to `player.Pets`
- **Flow:** Client clicks egg → fires `OpenEgg("StarterEgg")` → server rolls using `PetData`
- **Creates a pet instance:**
  ```
  player.Pets
    └─ [Pet Name]
         ├─ Name: StringValue = "Spirit Fox"
         ├─ Rarity: StringValue = "Common"
         └─ PowerMultiplier: NumberValue = 0.1
  ```
- **Note:** Uses `PetData.rollPet()` to randomly select a pet based on rarity weights

---

### 📁 **StarterPlayer/StarterPlayerScripts/** — Client-Side UI & Input

These LocalScripts run on each player's computer and handle input, visuals, and UI state.

#### **ClickHandler.lua**
- **What it does:** Detects mouse clicks and fires the `AddPower` event
- **Input:** Listens to `UserInputService.InputBegan` for `MouseButton1`
- **Action:** Fires `AddPower:FireServer()` on left-click
- **Use case:** Allows players to gain power by clicking anywhere (or add particle effects on click)

#### **EggClickHandler.lua**
- **What it does:** Binds to a physical egg object in the game world and fires `OpenEgg` when clicked
- **Setup:** Looks for a part in `workspace` named `"Egg"` or `"StarterEgg"`
  - That part should have a `ClickDetector` (Roblox component that detects clicks on 3D objects)
- **Action:** When clicked, fires `OpenEgg:FireServer("StarterEgg")`
- **Alternative:** Could be replaced with a GUI button that fires the same event

#### **PowerGainEffect.lua**
- **What it does:** Plays a "sparkle" particle effect when power increases
- **Trigger:** Watches `player.leaderstats.Power` for increases
- **Effect:** Calls `:Emit(5)` on a ParticleEmitter named `"PowerGain"` on the character's HumanoidRootPart
- **Setup:** You need to manually add a ParticleEmitter to the player character and name it `"PowerGain"`
- **Optional:** Could also play a sound effect from ReplicatedStorage

#### **RebirthButton.lua**
- **What it does:** Manages the rebirth GUI button state and fires rebirths
- **Setup:** Looks for a `TextButton` named `"RebirthButton"` in `StarterGui`
- **Action:** Connects button.Activated to fire `RebirthEvent:FireServer()`
- **Bonus:** Can update the button text to show the rebirth cost (e.g., "Need 300 Power")

---

## Data Flow & Game Mechanics

### 🖱️ **Clicking Power (Main Loop)**

```
Player clicks (ClickHandler detects)
    ↓
ClickHandler fires AddPower:FireServer()
    ↓
AddPowerHandler (server) receives event
    ↓
Calculates: Power = BasePower × PetMultiplier
    ↓
Updates player.leaderstats.Power
    ↓
PowerGainEffect (client) detects Power changed
    ↓
Emits 5 particles (sparkle effect)
```

### 🥚 **Opening Eggs**

```
Player clicks Egg part (EggClickHandler binds to ClickDetector)
    ↓
EggClickHandler fires OpenEgg:FireServer("StarterEgg")
    ↓
OpenEggHandler (server) receives event
    ↓
Uses PetData.rollPet("StarterEgg") to roll a random pet
    ↓
Creates pet instance under player.Pets with Name, Rarity, PowerMultiplier
    ↓
Next click will use this pet's multiplier in AddPowerHandler
```

### 🔄 **Rebirthing**

```
Player clicks Rebirth button (RebirthButton script binds)
    ↓
RebirthButton fires RebirthEvent:FireServer()
    ↓
RebirthHandler (server) receives event
    ↓
Checks: Does player have 100 × (Rebirths + 1) Power?
    ↓
If YES:
  - Set Power = 0
  - Increment Rebirths
  - Pets stay (persist rebirths & multipliers)
    ↓
If NO:
  - Ignore request (client doesn't hack)
```

---

## Key Design Patterns

### 1. **Server Authority** ✅
All game logic lives on the **server** (AddPowerHandler, RebirthHandler, OpenEggHandler). Clients just send fire events:
- **Why?** Clients can be hacked; servers are trusted.
- **Client's job:** Accept input, show visuals, fire events
- **Server's job:** Validate, update stats, send confirmations back

### 2. **Event-Driven** 📡
Communication uses RemoteEvents instead of polling:
- Client fires → Server listens → Server responds (optional)
- No need for continuous checks; events only fire when needed

### 3. **Folder Hierarchy for Organization** 📂
Data is stored in a hierarchy:
```lua
player
├─ leaderstats
│  ├─ Power
│  └─ Rebirths
└─ Pets
   ├─ Spirit Fox
   ├─ Shadow Blade
   └─ ...
```
Scripts navigate using `:FindFirstChild()` and `:WaitForChild()`

### 4. **ModuleScript for Shared Data** 📦
`PetData` is a ModuleScript so both server and client can `require()` it. It's the single source of truth for pet definitions.

---

## How Multipliers Work

**Power Gain Formula:**
```
FinalGain = BasePower × TotalMultiplier
BasePower = 1 + (Rebirths × 2)
TotalMultiplier = 1 + (sum of all pets' PowerMultiplier values)
```

**Example Progression:**

| Rebirths | Pets | Base | Multiplier | Per Click |
|----------|------|------|-----------|-----------|
| 0 | None | 1 | 1.0 | 1 |
| 0 | Spirit Fox (0.1) | 1 | 1.1 | 1 |
| 1 | Spirit Fox + Shadow Blade (0.25) | 3 | 1.35 | 4 |
| 2 | 3 pets (total 0.8) | 5 | 1.8 | 9 |

---

## Setup Checklist (From PLACEMENT_INSTRUCTIONS.md)

To put this game in Roblox Studio:

1. ✅ **ReplicatedStorage**
   - Add ModuleScript `PetData` (paste from [PetData.lua](ReplicatedStorage/PetData.lua))
   - Create RemoteEvents: `AddPower`, `RebirthEvent`, `OpenEgg` (or let CreateRemoteEvents.lua auto-create)

2. ✅ **ServerScriptService**
   - Add 5 Scripts (in order):
     1. `CreateRemoteEvents` (must run first)
     2. `Leaderstats`
     3. `AddPowerHandler`
     4. `RebirthHandler`
     5. `OpenEggHandler`

3. ✅ **StarterPlayer > StarterPlayerScripts**
   - Add 4 LocalScripts:
     1. `ClickHandler`
     2. `EggClickHandler`
     3. `PowerGainEffect`
     4. `RebirthButton`

4. ✅ **Workspace**
   - Create a Part named `"Egg"` with a ClickDetector

5. ✅ **StarterPlayer > StarterCharacterScripts** (character-specific)
   - Add ParticleEmitter to HumanoidRootPart, name it `"PowerGain"`

6. ✅ **StarterGui**
   - Create ScreenGui with TextButton named `"RebirthButton"`

---

## Common Roblox Gotchas

1. **Scripts run immediately, before game loads**
   - Use `WaitForChild()` to pause until instances exist

2. **Asynchronous execution**
   - Functions like `game:GetService()` and `WaitForChild()` are fast but not blocking by default.
   - Use coroutines or `task.wait()` to yield.

3. **Client vs. Server**
   - Never put game logic in client code (players can hack it)
   - Client code is only for input, UI, and visuals

4. **Instances are the building blocks**
   - Everything (values, folders, parts) is an Instance
   - Use `:FindFirstChild()`, `:GetChildren()`, Parent references

5. **Type hints** (optional but helpful)
   - This code uses Luau syntax: `function myFunc(x: string): number`
   - Roblox Studio supports type hints, which help catch bugs

---

## Expanding the Game

### Add a New Egg Type
1. Edit [PetData.lua](ReplicatedStorage/PetData.lua)
2. Add a new entry to `PetData.Eggs`:
   ```lua
   PetData.Eggs.PremiumEgg = {
       { Name = "Ultra Saiyan", Rarity = "Legendary", PowerMultiplier = 2.0 },
       -- ...more pets
   }
   ```
3. Have a GUI button fire: `OpenEgg:FireServer("PremiumEgg")`

### Add a New Stat
1. Edit [Leaderstats.lua](ServerScriptService/Leaderstats.lua) to create a new IntValue
2. Reference it in handler scripts (e.g., AddPowerHandler)

### Add Visual Effects
- Modify [PowerGainEffect.lua](StarterPlayer/StarterPlayerScripts/PowerGainEffect.lua) to play sounds or animations
- Adjust the ParticleEmitter properties in the editor

---

## File Summary Table

| File | Type | Runs On | Purpose |
|------|------|---------|---------|
| [PetData.lua](ReplicatedStorage/PetData.lua) | ModuleScript | Both | Pet definitions & roll logic |
| [CreateRemoteEvents.lua](ServerScriptService/CreateRemoteEvents.lua) | Script | Server | Create RemoteEvent bridges |
| [Leaderstats.lua](ServerScriptService/Leaderstats.lua) | Script | Server | Initialize player stats |
| [AddPowerHandler.lua](ServerScriptService/AddPowerHandler.lua) | Script | Server | Process power gains |
| [RebirthHandler.lua](ServerScriptService/RebirthHandler.lua) | Script | Server | Process rebirths |
| [OpenEggHandler.lua](ServerScriptService/OpenEggHandler.lua) | Script | Server | Hatch pets from eggs |
| [ClickHandler.lua](StarterPlayer/StarterPlayerScripts/ClickHandler.lua) | LocalScript | Client | Detect click input |
| [EggClickHandler.lua](StarterPlayer/StarterPlayerScripts/EggClickHandler.lua) | LocalScript | Client | Bind egg part clicks |
| [PowerGainEffect.lua](StarterPlayer/StarterPlayerScripts/PowerGainEffect.lua) | LocalScript | Client | Play particle effects |
| [RebirthButton.lua](StarterPlayer/StarterPlayerScripts/RebirthButton.lua) | LocalScript | Client | Manage rebirth button UI |

---

## Conclusion

This is a **classic idle/clicker game** with progression layers (clicking → pets → rebirths). The code separates concerns cleanly:
- **Server:** Validates and stores all data
- **Client:** Handles input and cosmetics
- **ModuleScript:** Shared data (pets)
- **RemoteEvents:** Client-server communication

The architecture is safe, scalable, and easy to extend. Good luck expanding it!
