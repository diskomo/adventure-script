---@meta
--- IDE-only type definitions. Loaded via workspace.library — not part of fxmanifest.

---@class BrandColour
---@field r number
---@field g number
---@field b number

---@class BrandingConfig
---@field scriptVersion string
---@field licensePlate string
---@field colours table<string, BrandColour>
---@field tourRules string[]
---@field welcomeMessage string
---@field callToActionMessage string
---@field thankYouMessage string
---@field invitePromptMessage string
---@field inviteAcceptedMessage string
---@field inviteDeclinedMessage string
---@field joinedTourMessage string
---@field leftTourMessage string
---@field kickedFromTourMessage string
---@field tourEndedMessage string
---@field gatherToBusMessage string
---@field gatherToStopMessage string
---@field inviteMaxDistance number
---@field awayDistance number
---@field tourGuideOutfit table
---@field tourGuideOutfitColours table<string, table>
---@field actions table[]

---@type BrandingConfig
Branding = nil

---@type table[]
TourStops = nil

---@type table
ControlHints = nil

---@type table<string, boolean>
DefaultVehicleOptions = nil

---@type integer[]
DefaultVehicleMods = nil

---@type table<string, integer>
VehicleMods = nil

---@type fun(key: string): BrandColour
GetBrandColour = nil

---@class AdventureTours
---@field Notify fun(description: string, ntype?: 'success' | 'error' | 'warning' | 'inform')
---@field Get fun(key: string): any
---@field Set fun(key: string, value: any)
---@field AfterAction fun(opts?: { pushState?: boolean })
---@field BuildNuiState fun(): table
---@field PushNuiState fun()
---@field PushMiniMenuOverlay fun()
---@field SendNuiInit fun()
---@field UpdateControlsOverlay fun()
---@field HideControlsOverlay fun()
---@field UpdateL3MenuOverlay fun()
---@field OpenL3Menu fun()
---@field CloseL3Menu fun()
---@field ToggleL3Menu fun()
---@field HideL3MenuOverlay fun()
---@field UpdateMiniMenuFocus fun()
---@field OpenMainMenu fun()
---@field CloseMenu fun()
---@field ToggleMainMenu fun()
---@field ResetSpawnOptions fun()
---@field CopyDefaultOptions fun(options?: table): table
---@field CopyModOverrides fun(mods?: table<integer, integer>): table<integer, integer>
---@field SetSpawnVehicle fun(modelName: string, options?: table, modOverrides?: table): boolean
---@field MakeAdventureVehicle fun(veh: integer)
---@field SpawnAdventureToursBus fun()
---@field DeleteSpawnedVehicles fun()
---@field DeleteVehiclesInArea fun(radius?: number)
---@field AdventurifyCurrentVehicle fun()
---@field SetSpoilerOnCurrentVehicle fun(value: integer)
---@field TrackSpawnedVehicle fun(vehicle: integer)
---@field PushSpawnUndoBatch fun(vehicles: integer[])
---@field GetSpawnUndoCount fun(): integer
---@field ClearSpawnUndoStack fun()
---@field UndoLastSpawn fun(): boolean
---@field LoadModel fun(hash: string | integer): boolean
---@field LoadAnimDict fun(dict: string): boolean
---@field DeleteEntitySafe fun(entity: integer)
---@field RotationToDirection fun(rotation: vector3): vector3
---@field GetGroundZ fun(x: number, y: number, fallbackZ: number): number
---@field TeleportPedOrVehicle fun(coords: vector3)
---@field GetModelDimensions fun(model: string | integer): { x: number, y: number, z: number }
---@field InitializeGridSpawn fun()
---@field CleanupGridSpawn fun()
---@field HandleGridSpawn fun()
---@field CancelGuideAction fun()
---@field PlayGuideAction fun(actionId: string, variants?: string[])
---@field ApplyTourGuideOutfit fun(ensureModel?: boolean)
---@field RemoveGuideWeapons fun()
---@field SetSuperdriveEnabled fun(enabled: boolean)
---@field InitializeGuideDefaults fun()
---@field TeleportPlayerToTourStop fun(tourStop: table, locationIndex?: integer)
---@field GoToNextTourStop fun()
---@field GoToPreviousTourStop fun()
---@field GoToTourLocation fun(locationName: string): boolean
---@field CycleLocationForCurrentStop fun(direction?: integer): string?
---@field CycleSpawnVehicleForCurrentStop fun(direction?: integer): string?
---@field JumpToFirstVehicleForCurrentStop fun(): string?
---@field CanUseL3Menu fun(): boolean
---@field GetL3MenuVariant fun(): 'bus' | 'foot'
---@field IsDrivingBus fun(): boolean
---@field DeleteTourBus fun()
---@field InitializeStopRainbowModes fun()
---@field GetStopRainbowMode fun(stopIndex: integer): boolean
---@field SetStopRainbowMode fun(stopIndex: integer, enabled: boolean): boolean
---@field ToggleStopRainbowMode fun(stopIndex: integer): boolean?
---@field GetStopRainbowModesForNui fun(): table<integer, boolean>
---@field StartTour fun()
---@field StopTour fun(): boolean
---@field ResetStop fun()
---@field IsFollowingTour fun(): boolean
---@field IsTourGuide fun(): boolean
---@field TransferGuide fun(targetId: integer)
---@field SetFollowing fun(following: boolean)
---@field SetReady fun(ready: boolean)
---@field RequestHelp fun(helpType: string|nil)
---@field VoteNextStop fun(voted: boolean)
---@field StartElection fun(candidateId: integer)
---@field CastElectionVote fun(yes: boolean)
---@field GatherPassengers fun(mode: 'bus' | 'stop')
---@field RefreshPassengerData fun()
---@field PublishTourSessionStart fun()
---@field PublishTourSync fun()
---@field PublishTourSessionEnd fun()
---@field PollGamepadShortcuts fun()

---@type AdventureTours
AdventureTours = nil
