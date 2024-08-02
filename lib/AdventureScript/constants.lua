local CONSTANTS = {}

CONSTANTS.licensePlate = 'ADVTOURS'

-- Colours
CONSTANTS.colours = {
    yellow = {
        r = 204,
        g = 132,
        b = 0
    },
    pink = {
        r = 252,
        g = 134,
        b = 255
    },
    white = {
        r = 255,
        g = 255,
        b = 255
    }
}

-- Vehicle Mods: Referenced from https://pastebin.com/QzEAn02v
local mods = {
    SPOILERS = 0,
    FRONT_BUMPER = 1,
    REAR_BUMPER = 2,
    SIDE_SKIRT = 3,
    EXHAUST = 4,
    FRAME = 5,
    GRILLE = 6,
    HOOD = 7,
    FENDER = 8,
    RIGHT_FENDER = 9,
    ROOF = 10,
    ENGINE = 11,
    BRAKES = 12,
    TRANSMISSION = 13,
    HORNS = 14,
    SUSPENSION = 15,
    ARMOR = 16,
    UNK17 = 17,
    TURBO = 18,
    UNK19 = 19,
    TIRE_SMOKE = 20,
    UNK21 = 21,
    XENON_HEADLIGHTS = 22,
    FRONT_WHEELS = 23,
    BACK_WHEELS = 24,
    PLATEHOLDER = 25,
    VANITY_PLATES = 26,
    TRIM = 27,
    ORNAMENTS = 28,
    DASHBOARD = 29,
    DIAL = 30,
    DOOR_SPEAKER = 31,
    SEATS = 32,
    STEERINGWHEEL = 33,
    SHIFTER_LEAVERS = 34,
    PLAQUES = 35,
    SPEAKERS = 36,
    TRUNK = 37,
    HYDRULICS = 38,
    ENGINE_BLOCK = 39,
    AIR_FILTER = 40,
    STRUTS = 41,
    ARCH_COVER = 42,
    AERIALS = 43,
    TRIM2 = 44,
    TANK = 45,
    WINDOWS = 46,
    UNK47 = 47,
    LIVERY = 48
}
CONSTANTS.vehicleMods = mods
-- These mods will be applied to all spawned vehicles as their highest possible value
CONSTANTS.defaultVehicleMods = {mods.TANK, mods.ARCH_COVER, mods.ARMOR, mods.TRUNK, mods.BRAKES, mods.STRUTS,
                                mods.TRANSMISSION, mods.TRIM, mods.AERIALS, mods.AIR_FILTER, mods.ENGINE_BLOCK,
                                mods.ENGINE, mods.GRILLE, mods.SIDE_SKIRT, mods.REAR_BUMPER, mods.FRONT_BUMPER}

-- Chat messages
CONSTANTS.tourRules = {'TOUR BUS RULES:', 'No killing other passengers', 'No setting waypoints',
                       'No shooting out of the bus windows'}
CONSTANTS.welcomeMessage =
    'Welcome to the tour! We have many fun activities planned. Please remain seated while we pick up more passengers.'
CONSTANTS.callToActionMessage = 'Would anyone else like to join the tour?'
CONSTANTS.thankYouMessage = 'Thank you all so much for joining the tour!'

return CONSTANTS
