# Adventure Tours (FiveM)

FiveM rebuild of the Stand Lua **Adventure Tours** host tool. Run guided communal tours: spawn a branded tour bus, travel the map, jump to preset activity stops, and grid-spawn activity vehicles for passengers.

Standalone resource — no ESX/QBCore dependency. Uses [ox_lib](https://github.com/overextended/ox_lib) for notifications; the menu is custom NUI.

---

## Run it locally (step by step)

This guide assumes **Windows** and a fresh machine. Follow it top to bottom.

### What you need first

- **GTA V** installed and the **FiveM client** installed ([download](https://fivem.net/)). You launch this to connect to your own server.
- **Git** ([download](https://git-scm.com/download/win)).
- About 15 minutes.

We'll use this folder layout (you can change the drive/paths, but keep them consistent):

```
C:\FXServer\
  server\         <- the FXServer binaries (the program that runs the server)
  server-data\    <- your server files: resources/ and server.cfg
  lua-addons\     <- (optional) editor type definitions for autocomplete
```

### Step 1 — Download the FXServer binaries

The server program is separate from the FiveM game client.

1. Open the [Windows server artifacts page](https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/).
2. Download a recent **recommended** build (the `.7z` / `.zip`).
3. Extract it into `C:\FXServer\server` (so `C:\FXServer\server\FXServer.exe` exists).

### Step 2 — Get the base server data

This provides the default system resources (chat, session manager, a spawn map, etc.) that a playable server needs.

```powershell
git clone https://github.com/citizenfx/cfx-server-data.git C:\FXServer\server-data
```

You should now have `C:\FXServer\server-data\resources\` containing folders like `[system]`, `[managers]`, `[gameplay]`.

### Step 3 — Get a license key (free)

1. Go to [keymaster.fivem.net](https://keymaster.fivem.net) and sign in.
2. Create a new server key (type: **other/none**).
3. Copy the key — you'll paste it into `server.cfg` in Step 6.

### Step 4 — Install ox_lib (required dependency)

1. Download the latest **built release** (not the source) from [ox_lib releases](https://github.com/overextended/ox_lib/releases) — the file named `ox_lib.zip`.
2. Extract it into `C:\FXServer\server-data\resources\ox_lib` (so `resources\ox_lib\fxmanifest.lua` exists).

> Don't use the "Download ZIP" green button on the repo — that's unbuilt source and the UI won't work. Use the **Releases** page.

### Step 5 — Install this resource

Put this repo into `resources` as a folder named **`adventure_tours`**.

- **Option A — copy:** copy this repository's contents into `C:\FXServer\server-data\resources\adventure_tours`.
- **Option B — symlink (best for editing):** keep the repo where it is and link it in, so edits are picked up live (run in an **elevated** PowerShell):

  ```powershell
  New-Item -ItemType Junction -Path "C:\FXServer\server-data\resources\adventure_tours" -Target "X:\adventure-script"
  ```

After this, `C:\FXServer\server-data\resources\adventure_tours\fxmanifest.lua` must exist.

> The folder **must** be named `adventure_tours` — FiveM uses the folder name for `ensure`, and it must match the config below.

### Step 6 — Configure server.cfg

Open `C:\FXServer\server-data\server.cfg` (create it if missing) and make sure it contains the following. The important parts are the two `ensure` lines at the bottom and your license key.

```cfg
# Where players connect
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

# OneSync is required by ox_lib (free for small servers)
set onesync on

# Default system resources (from cfx-server-data in Step 2 — needed for a playable session + chat)
ensure mapmanager
ensure spawnmanager
ensure sessionmanager
ensure baseevents
ensure hardcap
ensure chat
ensure playernames
ensure fivem

# Server info
sv_hostname "Adventure Tours Dev"
sv_maxclients 8

# Paste your key from keymaster.fivem.net
sv_licenseKey "YOUR_KEY_HERE"

# --- This resource and its dependency (order matters) ---
ensure ox_lib
ensure adventure_tours
```

`ox_lib` **must** be ensured before `adventure_tours`, and `set onesync on` is required or `ox_lib` will refuse to start.

### Step 7 — Start the server

Open a terminal, **change into the `server-data` folder first**, then start the server. The working directory matters: FiveM locates `resources/` (and writes `cache/`) relative to where the process is launched, _not_ relative to the `+exec` path.

```powershell
cd C:\FXServer\server-data
C:\FXServer\server\FXServer.exe +exec server.cfg
```

> If you launch from the wrong folder you'll see `Found 1 resources` and `Couldn't find resource ...` for everything, and a stray `cache/` folder will appear wherever you ran it. Always `cd` into `server-data` first.

A console window opens and streams startup logs. Watch for:

- `Started resource ox_lib`
- `Started resource adventure_tours`

If you see red `SCRIPT ERROR` lines during startup, jump to [Troubleshooting](#troubleshooting).

### Step 8 — Connect from the FiveM client

1. Launch **FiveM**.
2. Press **F8** to open the client console.
3. Type `connect 127.0.0.1` and press Enter.

Once in-game, open the tool with **F6** or by typing `/adventuretours` in the chat. You should get an "Adventure Tours loaded" notification on join.

---

## Debug it locally

### Reload code without restarting the server

This resource is plain `.lua` — there is no build step. After editing a file, run this in the **server console** (the FXServer window):

```
restart adventure_tours
```

Your changes take effect immediately. (If you used the symlink in Step 5, the files are read straight from the repo.)

### Where output goes

| Code location                  | Where its `print()` / errors show up   |
| ------------------------------ | -------------------------------------- |
| `server/main.lua`              | The **FXServer console window**        |
| `client/*.lua`, `config/*.lua` | The **F8 console** in the FiveM client |

Add `print('...')` anywhere to trace behavior, then `restart adventure_tours` and reproduce.

### Useful console commands

Run these in the FXServer console (or, with `client`-side effect, from F8):

| Command                                          | What it does                                                                        |
| ------------------------------------------------ | ----------------------------------------------------------------------------------- |
| `restart adventure_tours`                        | Reload this resource after an edit                                                  |
| `stop adventure_tours` / `start adventure_tours` | Stop / start it manually                                                            |
| `ensure adventure_tours`                         | Start it, or restart if already running                                             |
| `refresh`                                        | Rescan the `resources` folder (run after adding a **new** file to `fxmanifest.lua`) |

> After adding a brand-new `.lua` file to the manifest, run `refresh` then `restart adventure_tours`. Editing existing files only needs `restart`.

### Reading errors

- **Server-side** Lua errors and stack traces appear in the FXServer console.
- **Client-side** errors appear in the F8 console, prefixed with `SCRIPT ERROR:` and a stack trace pointing at the file and line.
- A missing file listed in `fxmanifest.lua`, or a syntax error, is reported at resource start — always scan the startup logs first.

### Editor setup (autocomplete for FiveM natives + ox_lib)

Use the [Lua Language Server](https://luals.github.io/) with [fivem-lls-addon](https://github.com/overextended/fivem-lls-addon):

1. Install the **`Lua`** extension (sumneko / LuaLS) in Cursor/VSCode.
2. Clone the addon into your addons folder:

   ```powershell
   git clone https://github.com/overextended/fivem-lls-addon.git C:\FXServer\lua-addons\fivem-lls-addon
   ```

3. Copy `.luarc.default.json` to `.luarc.json` and edit the paths for your machine:
   - `workspace.userThirdParty` → the **parent** addons folder (e.g. `C:/FXServer/lua-addons`), not the addon folder itself.
   - `workspace.library` → your `ox_lib` resource path (e.g. `C:/FXServer/server-data/resources/ox_lib`).
4. Reload the editor and accept the "third-party library" prompt.

`.luarc.json` is git-ignored (paths differ per machine); `.luarc.default.json` is the shared template.

### Troubleshooting

| Symptom                                          | Likely cause / fix                                                                                                                                                          |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Couldn't find resource adventure_tours`         | Folder isn't named `adventure_tours`, isn't inside `resources`, or `fxmanifest.lua` is missing.                                                                             |
| `ox_lib can't run: OneSync needs to be enabled`  | Add `set onesync on` to `server.cfg` (above the `ensure` lines).                                                                                                            |
| `Found 1 resources` / everything "couldn't find" | You launched from the wrong folder. `cd` into `server-data` first (see Step 7), then start the server.                                                                      |
| `attempt to index a nil value (global 'lib')`    | `ox_lib` isn't started before `adventure_tours`. Check the `ensure` order in `server.cfg` and that `resources\ox_lib` exists.                                               |
| Menu won't open on **F6**                        | The key may be unbound or conflicting. Type `/adventuretours` instead, or set the bind in **Settings → Key Bindings → FiveM**.                                              |
| A vehicle won't spawn / "not a vehicle" error    | That model isn't on your game build. See [Required vehicle models](#required-vehicle-models).                                                                               |
| Chat messages (Welcome/Rules/etc.) don't appear  | The `chat` resource isn't ensured in `server.cfg`.                                                                                                                          |
| Can't connect from the client                    | Server not started, wrong port, invalid/blank `sv_licenseKey`, or the FiveM client/Rockstar launcher isn't running.                                                         |
| Edits don't take effect                          | You didn't `restart adventure_tours`, or you copied files (Option A) instead of symlinking and edited the repo copy — edit the copy inside `resources`, or use the symlink. |

### Easiest alternative: txAdmin

If you'd rather use a web UI, run `C:\FXServer\server\FXServer.exe` with **no arguments**. This launches **txAdmin** at `http://localhost:40120`, which walks you through creating a server, entering the license key, and deploying a base server. You still drop `ox_lib` and `adventure_tours` into the data folder's `resources` and add the two `ensure` lines to the generated `server.cfg`.

---

## Usage

Open the menu with **F6** or `/adventuretours`.

### Hosting a tour

Only one **tour guide** exists per server at a time. The first player to join becomes guide automatically; if the guide disconnects, the longest-connected remaining player is promoted.

1. Hold the **modifier key** (gamepad **R3** / look-behind) and use shortcuts, or rebind keys in FiveM settings.
2. Spawn the tour bus.
3. Start the tour when ready — all other players follow automatically.
4. While driving the bus, double-tap **prev/next stop** shortcuts to cycle tour stops (teleports to the stop's first location and sets its default spawn vehicle).
5. At a destination, enable **spawn mode** and hold **left click / RT** while dragging to draw a grid of activity vehicles.
6. Use **cleanup** to remove spawned vehicles; **clear area** removes vehicles in a radius.

### Being a passenger

Everyone else on the server is a passenger automatically — no invites needed.

- **My Tour** — see current stop and guide, toggle follow mode, raise hand (ready), send help signals, vote for the next stop.
- **Guide** — view the current guide and start an election to nominate a replacement.
- **Animations** — play emotes like the guide.
- Toggle **Follow tour** off to explore independently without being teleported.

Guide-only keybinds (spawn bus, grid spawn, stop cycling, superdrive, etc.) are disabled for passengers.

### Default keybinds

All shortcuts require the modifier key held (gamepad: **R3**; keyboard: **Left Alt**). Rebind in **Settings → Key Bindings → FiveM**.

| Action                     | Default keyboard bind                            |
| -------------------------- | ------------------------------------------------ |
| Open menu                  | `F6`                                             |
| Spawn bus                  | `DOWN` + modifier                                |
| Next stop (double-tap)     | `PAGEUP` + modifier (or DPad Down x2 on gamepad) |
| Previous stop (double-tap) | `PAGEDOWN` + modifier (or DPad Up x2 on gamepad) |
| Toggle spawn mode          | `RIGHT` + modifier                               |
| Cleanup spawned vehicles   | `LEFT` + modifier                                |
| Clear area                 | `DELETE` + modifier                              |

Enable **Show controls** in the menu to display on-screen keybind hints while holding the modifier.

### Menu options

The menu is organised into tour stops and settings:

- **Tour stops** — each of the 12 stops opens a submenu to teleport to any of its locations and to set the active spawn vehicle.
- **Colours** — set the brand colour (yellow, pink, white) used when adventurifying vehicles.
- **Bus Type** — choose the public transport bus or the smaller Vinewood tour bus.
- **Actions** — play tour-guide animations and scenarios (hold camera, binoculars, yoga, etc.); **Cancel** stops the current action and clears props.
- **Vehicles** — **Adventurify** the current vehicle, or set a **Spoiler** index (-1 to remove).
- **Chat** — broadcast a preset message (Welcome, Rules, Invite, Thank you) to all players.
- **Show controls** — toggle on-screen keybind hints while holding the modifier.
- **Superdrive** — toggle fly mode (hold `A` to fly toward the camera; handbrake to hover and aim with the left stick).

## Tour content

All **12 tour stops**, **19 locations**, vehicle presets, branding, guide actions, and chat messages are ported from the original Stand script.

| Stop            | Locations                                  | Vehicles                          |
| --------------- | ------------------------------------------ | --------------------------------- |
| Motocross       | Redwood Lights Track                       | manchez2, verus, vagrant, blazer3 |
| River Ride      | Rapids                                     | seashark                          |
| Swamp Swim      | Zancudo River                              | sandking                          |
| Drift           | Docks, Dirt Turbines                       | drifttampa, futo2, elegy          |
| Skatepark       | Vespucci Halfpipe, Underpass Skatepark     | bmx, veto2, blazer3, mower        |
| Mountain Biking | Gorge Trail                                | scorcher                          |
| 4WD             | Chiliad Climb, Gordo Climb                 | hellion, everon                   |
| Drag Racing     | Drag Strip                                 | deveste, dominator3               |
| Downhill        | Chiliad South, Chiliad East                | veto, issi4                       |
| F1 Race         | Arena Rooftop, Raceway                     | openwheel2, formula2              |
| Aero            | Runway Desert, Runway LSX, Runway Mountain | alphaz1, thruster                 |
| Kart Offroad    | Dirt Track                                 | veto, scorcher                    |

## Required vehicle models

These GTA Online / DLC models must be available on your server (default GTA V build):

`bus`, `tourbus`, `manchez2`, `verus`, `vagrant`, `blazer3`, `seashark`, `sandking`, `drifttampa`, `futo2`, `elegy`, `bmx`, `veto2`, `mower`, `scorcher`, `hellion`, `everon`, `deveste`, `dominator3`, `veto`, `issi4`, `openwheel2`, `formula2`, `alphaz1`, `thruster`

If a model is missing, spawns for that activity will fail silently or show an error notification.

## Behavior notes

- **Superdrive** — while in the driver's seat, hold `A` (gamepad) / `X` (keyboard) to fly the vehicle in the camera direction. Acceleration eases in smoothly, and near the ground it won't dive into terrain when you're looking down. Hold the handbrake (`R1`/`Spacebar`) to stop and hover in midair — position is pinned but the left stick rotates the vehicle on pitch, yaw, and roll — and releasing it restores gravity so the vehicle drops. Ports the original Stand `superdrive` / `superhandbrake` commands.
- **randomLivery** is implemented (it was commented out in the original Stand script).
- **Drag Strip** and **Raceway** share the same coordinates in the source data.
- Chat messages (welcome, rules, invite, thank you) are broadcast to all players via the server (guide-only).
- Tour guide outfit is applied from the original `Stand/Outfits/tourguide.txt` component data.
- **One tour guide per server** — assigned automatically, transferable by the guide, or replaceable via passenger election vote.

## Version history

- **1.x.x** — original release: a host tool for the [Stand](https://stand.gg) mod menu on GTA Online. Discontinued after Rockstar's crackdown on GTA Online mod menus. The `1.0.0`–`1.8.0` tags remain in the git history.
- **2.x.x** — a years-later revival, rewritten from scratch as a standalone FiveM resource.

## Credits

Written by the Vanilla Panther (META IIII). Descended from [AdventureScript](https://github.com/diskomo/adventure-script) for Stand.gg.

## Version

2.0.0 — FiveM revival
