# Future Plans: Custom FiveM Assets and Server Hub

This repo is currently a working FiveM resource named `adventure_tours`.
The long-term direction is to grow it into the hub for a whole custom local
FiveM server project: scripts, custom vehicles, maps, props, server config
notes, and the repeatable workflow for making new GTA V-style assets in
Blender.

The first custom asset target is a custom tour bus based on the existing GTA V
bus: start with Rockstar's bus shape, make a small amount of new geometry in
Blender, export it back into GTA/FiveM format, and stream it into the local
server as an add-on vehicle.

## North Star

Build this project in small, reversible steps:

1. Keep the current tour resource working.
2. Learn the GTA V asset pipeline with one vehicle.
3. Add the custom bus as a new model name, not as a replacement for `bus`.
4. Once the workflow is proven, reorganize the repo into a server hub.
5. Only then start making larger custom asset packs.

The best first win is not a perfect vehicle. The best first win is spawning
`adventure_bus` in-game and driving it around, even if the first version is
just the normal bus with one obvious edited panel.

## Current Repo Shape

Right now the repo is laid out like one FiveM resource:

```text
adventure-script/
  fxmanifest.lua
  client/
  server/
  config/
  html/
  types/
  README.md
```

That is fine for the current stage. The existing resource already handles:

- spawning the tour bus
- adventurifying vehicles with colors/mods/liveries
- tour stops and activity vehicle spawning
- NUI menu and keybinds
- client/server tour session behavior

The current bus model is controlled by `busType` and is limited to:

- `bus`
- `tourbus`

Future code can add `adventure_bus` as another option once the model streams
correctly.

## Recommended Project Strategy

Do not put custom model files directly into the existing script resource unless
the experiment is tiny. GTA asset files get large and have their own manifest
rules. Keep asset streaming in its own resource.

Recommended resources once the project grows:

```text
resources/
  [adventure]/
    adventure_tours/          # existing Lua/NUI tour tool
  [adventure-assets]/
    adventure_vehicles/       # custom streamed vehicles
    adventure_props/          # later: custom props
    adventure_maps/           # later: ymaps/ytyps/interiors
```

This repo can eventually become the parent hub:

```text
adventure-script/
  server.cfg.example
  FUTURE_PLANS.md
  resources/
    [adventure]/
      adventure_tours/
    [adventure-assets]/
      adventure_vehicles/
  tools/
  docs/
```

Do that migration later, after the first custom bus works. For now, keep the
existing layout so the current server setup does not break.

## Toolchain To Install

The usual GTA V/FiveM asset workflow uses these tools:

| Tool | Why it matters |
| --- | --- |
| Blender | Model editing and new geometry. |
| Sollumz Blender extension | Imports/exports GTA V drawable assets and CodeWalker XML. |
| CodeWalker | Explore GTA V assets, export models/textures, inspect the result, and package files. |
| Texture tool for `.dds` | GTA assets commonly use `.dds` textures. NVIDIA Texture Tools Exporter is a common choice. |
| FiveM local server | Final test environment. |

Primary docs worth bookmarking:

- FiveM 3D asset beginner series: https://docs.fivem.net/docs/assets-manual/beginner-series/part-1/
- Exporting/importing GTA assets: https://docs.fivem.net/docs/assets-manual/beginner-series/part-2/
- Creating assets in Blender: https://docs.fivem.net/docs/assets-manual/beginner-series/part-3/
- Resource manifest reference: https://docs.fivem.net/docs/scripting-reference/resource-manifest/
- Sollumz releases: https://github.com/Sollumz/Sollumz/releases

## Important Mental Model

FiveM does not stream a raw `.blend` file.

The rough chain is:

```text
GTA V asset
  -> CodeWalker export
  -> Blender/Sollumz import
  -> edit geometry/materials/textures
  -> Sollumz/CodeWalker export
  -> FiveM resource stream files
  -> fxmanifest.lua declares metadata files
  -> server ensures the resource
  -> Lua spawns model by name
```

For vehicles, the important files are usually:

| File type | Purpose |
| --- | --- |
| `.yft` | Vehicle model/drawable. |
| `_hi.yft` | Higher detail vehicle model, when used. |
| `.ytd` | Texture dictionary. |
| `vehicles.meta` | Defines vehicle model name, handling ID, layout, audio, seats, flags, and game behavior. |
| `carvariations.meta` | Paint/livery/light/extras variation data. |
| `carcols.meta` | Mod kits, liveries, lights, and color-related data. |
| `handling.meta` | Physics and driving behavior. |
| `vehiclelayouts.meta` | Seat/door/entry layouts, only needed if not reusing an existing layout. |

For the first bus, reuse as much of the existing GTA bus behavior as possible.
The goal is visual editing, not inventing vehicle physics from scratch.

## First Milestone: Custom Tour Bus

Target model name:

```text
adventure_bus
```

Why use a new model name?

- It avoids replacing the base game `bus`.
- It lets the current `bus` and `tourbus` options keep working.
- It makes debugging clearer: if `adventure_bus` fails, the base bus still
  proves the script is okay.
- It allows the menu to offer all three choices later.

### Version 0.1 Goal

Make the smallest possible visible edit:

- export the existing GTA V bus
- import it into Blender
- add or alter one visible piece of geometry
- keep the original scale, origin, skeleton, doors, wheels, and collision as
  intact as possible
- export it as a new add-on model
- stream it in a new FiveM resource
- spawn it with a simple command
- only after that, wire it into the Adventure Tours menu

Good first geometry edits:

- a roof sign
- custom side fins/panels
- a simple bumper addition
- a decorative luggage rack
- a clean logo panel

Avoid for the first pass:

- changing wheel positions
- changing door positions
- changing seats
- changing collision
- changing vehicle layout
- changing the skeleton/bones
- making the bus much longer or wider

Those are doable later, but they multiply the number of systems that can break.

## Proposed Asset Resource

Create a separate resource later:

```text
adventure_vehicles/
  fxmanifest.lua
  stream/
    adventure_bus.yft
    adventure_bus_hi.yft
    adventure_bus.ytd
  data/
    vehicles.meta
    carvariations.meta
    carcols.meta
    handling.meta
```

Example `fxmanifest.lua` shape:

```lua
fx_version 'cerulean'
game 'gta5'

name 'adventure_vehicles'
author 'The Vanilla Panther (META IIII)'
description 'Custom streamed vehicles for Adventure Tours'
version '0.1.0'

files {
    'data/vehicles.meta',
    'data/carvariations.meta',
    'data/carcols.meta',
    'data/handling.meta',
}

data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
```

The `stream/` folder is special: FiveM automatically packs streamable assets in
that folder. Metadata files still need to be listed in `files` and connected
with `data_file`.

Server start order:

```cfg
ensure ox_lib
ensure adventure_vehicles
ensure adventure_tours
```

Load assets before scripts that try to spawn them.

## First Bus Workflow

Use this as the repeatable checklist.

### 1. Find and export the base bus

1. Open CodeWalker.
2. Make sure DLCs are enabled.
3. Search for the base `bus` model.
4. Export the model as CodeWalker XML.
5. Export/save the related textures.
6. Keep a clean untouched copy in a `source_exports/` folder outside the FiveM
   stream resource.

Suggested working folders:

```text
asset_workbench/
  bus_original_export/
  adventure_bus_blender/
  adventure_bus_exported/
```

Do not treat the workbench folder as the final streamed resource. It is messy
by nature.

### 2. Import into Blender

1. Install the matching Sollumz version for your Blender version.
2. Import the CodeWalker XML through the Sollumz tools.
3. Fix missing textures by pointing Sollumz/Blender to the saved texture folder.
4. Save the `.blend` as the working source file.

Suggested file:

```text
asset_workbench/adventure_bus_blender/adventure_bus_v001.blend
```

### 3. Make the tiniest obvious edit

For the first pass, make one simple mesh change and stop.

Rules for the first pass:

- keep scale unchanged
- keep origin unchanged
- keep object names understandable
- do not delete bones/skeleton data
- do not edit wheels/doors/seats yet
- use simple materials first
- prefer an existing material before inventing many new textures

### 4. Export from Blender

Use Sollumz export back to CodeWalker/GTA format. Export into a temporary
folder first, not directly into the FiveM resource.

After export, inspect it in CodeWalker before trying FiveM.

Check:

- model opens
- textures appear
- scale looks right
- wheels/doors are not wildly broken
- no obvious missing material errors

### 5. Create add-on vehicle metadata

Start by copying behavior from the existing bus as closely as possible, but
rename the model to `adventure_bus`.

Important values to keep consistent:

| Field | Recommendation |
| --- | --- |
| model name | `adventure_bus` |
| txd/texture dictionary | usually `adventure_bus` |
| handling ID | start from bus-like handling, then rename or reuse carefully |
| vehicle layout | reuse existing bus layout at first |
| audio name | reuse an existing bus audio value at first |
| manufacturer/game name | can be custom text later |

Do not tune handling until the model spawns and drives.

### 6. Stream it in FiveM

Copy only the final exported files into:

```text
adventure_vehicles/stream/
adventure_vehicles/data/
```

Add the metadata to `adventure_vehicles/fxmanifest.lua`.

Add to `server.cfg`:

```cfg
ensure adventure_vehicles
```

Then run in the server console:

```text
refresh
ensure adventure_vehicles
restart adventure_tours
```

### 7. Test with a simple spawn

Before touching the menu, add a temporary dev command or use an admin/spawn
tool to spawn:

```text
adventure_bus
```

Test checklist:

- model loads
- no red errors in FXServer console
- no red errors in F8 console
- player can enter the driver seat
- bus drives
- textures appear
- collisions are acceptable
- other players can see it if testing with multiple clients

### 8. Wire into Adventure Tours

Once `adventure_bus` spawns reliably, change the script/UI:

1. Allow `adventure_bus` as a valid `busType`.
2. Add it to the bus selector in the NUI.
3. Default to the stock `bus` until the custom bus is stable.
4. Add a fallback: if the custom model fails to load, notify and use `bus`.

Expected code areas:

- `client/core/state.lua`
- `client/nui/callbacks.lua`
- `client/nui/state.lua`
- `html/script.js`
- possibly `html/index.html`

## Debugging Checklist

If the bus does not spawn:

- Is `adventure_vehicles` ensured before `adventure_tours`?
- Is the model name exactly the same in the files and metadata?
- Does the resource start without manifest errors?
- Are the metadata files listed under both `files` and `data_file`?
- Is the `.ytd` texture dictionary name matching what the model expects?
- Does CodeWalker open the exported model correctly?
- Does F8 show `Failed to load model` or `not a vehicle`?
- Did you run `refresh` after adding a brand-new resource or manifest file?

If the bus spawns invisible:

- Check `.yft` and `.ytd` names.
- Check texture dictionary references.
- Open it in CodeWalker and confirm textures/materials.
- Try a very simple material/texture setup first.

If the bus spawns but doors/seats are broken:

- You may have broken or renamed bones.
- You may need a correct vehicle layout.
- Re-test from a smaller edit on top of the original bus export.

If the bus has strange physics:

- Start from stock bus handling.
- Avoid changing mass, center of mass, traction, or dimensions until visuals work.
- If the mesh size changed heavily, collision and handling may need a real pass.

## Repo Hygiene

Recommended rules:

- Commit source `.blend` files only if they are not enormous.
- Keep exported/generated files organized by resource.
- Do not mix temporary CodeWalker exports into production `stream/`.
- Keep model names lowercase with underscores.
- Keep a changelog for each custom asset.
- Keep one small test model around forever as a known-good example.

Possible future folders:

```text
docs/
  asset-pipeline.md
  vehicle-metadata-notes.md

asset_workbench/
  README.md
  adventure_bus/

resources/
  [adventure-assets]/
    adventure_vehicles/
```

Consider whether large binary files should live in Git. If this repo starts
getting heavy, use Git LFS or keep source art in a separate local archive.

## Legal and Sharing Notes

For local learning, exporting and modifying GTA V assets is the normal modding
workflow. Be careful about redistribution.

Practical rule:

- local private experiments are one thing
- uploading Rockstar-derived model files publicly is another thing
- original geometry/textures you make yourself are safer to share
- document what is original and what is derived

For the first custom bus, assume it is a private/local learning asset unless
you later replace the derived parts with original work.

## Later Project Ideas

After the custom bus works:

- custom liveries for tour themes
- custom props for tour stops
- custom map markers and staging areas
- a depot or visitor center map
- a proper garage/spawn menu for Adventure vehicles
- themed NPC passengers or guide outfits
- a persistent tour route editor
- screenshots/previews for each vehicle in the NUI
- server permissions for who can host tours

## Suggested Milestones

### Milestone 1: Learn the asset loop

- install CodeWalker, Blender, Sollumz, texture tooling
- export the stock bus
- import it into Blender
- export it back unchanged
- inspect it in CodeWalker

Done means: the unchanged round-trip bus opens correctly outside the game.

### Milestone 2: First visible edit

- add one visible mesh change
- export again
- inspect in CodeWalker

Done means: the edited bus opens correctly and the edit is visible.

### Milestone 3: Stream as `adventure_bus`

- create `adventure_vehicles`
- add stream files and metadata
- ensure the resource in `server.cfg`
- spawn `adventure_bus` manually

Done means: the custom bus can be spawned and driven in the local server.

### Milestone 4: Integrate with Adventure Tours

- add `adventure_bus` to the bus selection flow
- preserve `bus` and `tourbus`
- add fallback behavior
- update README with setup notes

Done means: the Adventure Tours menu can spawn the custom bus.

### Milestone 5: Turn repo into a hub

- move the existing resource under `resources/[adventure]/adventure_tours`
- keep `adventure_vehicles` under `resources/[adventure-assets]/`
- add `server.cfg.example`
- update local setup docs

Done means: a fresh local server can be rebuilt from the repo instructions.

## Next Concrete Step

Do Milestone 1 before editing any code.

The first hands-on session should be:

1. Install CodeWalker.
2. Install Blender.
3. Install Sollumz.
4. Export the stock GTA V bus with CodeWalker.
5. Import it into Blender.
6. Export it back unchanged.
7. Open that unchanged export in CodeWalker.

If that round trip works, the rest becomes much less mysterious.
