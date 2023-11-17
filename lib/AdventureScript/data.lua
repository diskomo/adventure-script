-- Vehicle mods reference from https://pastebin.com/QzEAn02v
local vehicleMods = {
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

local adventureData = {
    -- Official AdventureTours Bus Stops: teleport locations and vehicles
    tourStops = {{
        name = 'Skatepark',
        description = 'Ride the halfpipes',
        locations = {{
            name = 'Vespucci Halfpipe',
            id = 'skatepark1',
            coords = {
                x = -917.7622,
                y = -807.44653,
                z = 15.9212
            }
        }, {
            name = 'Underpass Skatepark',
            id = 'skatepark2',
            coords = {
                x = 725.3054,
                y = -1226.8306,
                z = 24.691328
            }
        }},
        vehicles = {{
            name = 'BMX',
            id = 'bmx'
        }, {
            name = 'Go-Kart',
            id = 'veto2',
            options = {
                f1Wheels = true
            }
        }, {
            name = 'Lawnmower',
            id = 'mower'
        }}
    }, {
        name = 'Offroad Racing',
        description = 'Race around the Redwood Lights motocross track using dirtbikes and quads, or try the kart track with go-karts!',
        locations = {{
            name = 'Redwood Lights Track',
            id = 'dirtrace',
            coords = {
                x = 1093.9911,
                y = 2108.692,
                z = 53.391186
            }
        }, {
            name = 'Kart Dirt Track',
            id = 'kartrace',
            coords = {
                x = 1882.3873,
                y = 3351.0962,
                z = 42.945
            }
        }},
        vehicles = {{
            name = 'Dirtbike',
            id = 'manchez2'
        }, {
            name = 'Quadbike',
            id = 'verus'
        }, {
            name = 'Go-Kart',
            id = 'veto',
            options = {
                livery = 1,
                randomColor = true
            }
        }, {
            name = 'Mountain Bike',
            id = 'scorcher'
        }, {
            name = 'UTV',
            id = 'outlaw'
        }, {
            name = 'Buggy',
            id = 'vagrant'
        }}
    }, {
        name = 'River Ride',
        description = 'Jetski down the rapids and find some fat F250s to swim through the river',
        locations = {{
            name = 'Rapids (-> Swamp Swim)',
            id = 'riverrapids',
            coords = {
                x = -47.31711,
                y = 3089.3042,
                z = 27.836765
            }
        }},
        vehicles = {{
            name = 'Jetski',
            id = 'seashark'
        }, {
            name = 'F250',
            id = 'sandking',
            options = {
                f1Wheels = true
            }
        }, {
            name = 'Dinghy',
            id = 'dinghy'
        }, {
            name = 'Mini-Sub',
            id = 'avisa'
        }, {
            name = 'Swamp Swim',
            id = 'swampswim',
            coords = {
                x = -1447.9856,
                y = 2571.5137,
                z = 3.9270356
            }
        }}
    }, {
        name = 'Drift',
        description = 'Drift around the dock carpark or the snaking dirt road by the wind farm',
        locations = {{
            name = 'Docks',
            id = 'drift1',
            coords = {
                x = 1266.2307,
                y = -3097.5962,
                z = 5.907445
            }
        }, {
            name = 'Dirt Turbines',
            id = 'drift2',
            coords = {
                x = 2188.031,
                y = 1594.5018,
                z = 80.5829
            }
        }},
        vehicles = {{
            name = 'AE86',
            id = 'futo2',
            options = {
                drift = true,
                f1Wheels = true,
                livery = 6
            }
        }, {
            name = 'Skyline',
            id = 'elegy',
            options = {
                drift = true
            },
            mods = {
                [vehicleMods.ARCH_COVER] = 4,
                [vehicleMods.EXHAUST] = 2,
                [vehicleMods.REAR_BUMPER] = -1,
                [vehicleMods.FRONT_BUMPER] = 2,
                [vehicleMods.PLATEHOLDER] = 1,
                [vehicleMods.WINDOWS] = 1
            }
        }}
    }, {
        name = 'Mountain',
        description = 'Mt Chiliad or Mt Gordo 4WD climbs and go-kart descent',
        locations = {{
            name = 'Chiliad Climb',
            id = 'chiliadclimb',
            coords = {
                x = -367.6046,
                y = 4916.092,
                z = 196.70187
            }
        }, {
            name = 'Rocky Descent',
            id = 'rockydescent',
            coords = {
                x = 505.47202,
                y = 5539.428,
                z = 778.25977
            }
        }, {
            name = 'Rally Descent',
            id = 'rallydescent',
            coords = {
                x = 642.8843,
                y = 5629.7363,
                z = 726.7645
            }
        }, {
            name = 'Bike Trail (-> Jetpack Bridge)',
            id = 'biketrail',
            coords = {
                x = -1139.7003,
                y = 4610.722,
                z = 146.11864
            }
        }, {
            name = 'Jetpack Bridge (-> Rocky Descent)',
            id = 'biketrail',
            coords = {
                x = -1139.7003,
                y = 4610.722,
                z = 146.11864
            }
        }, {
            name = 'Mt. Gordo',
            id = 'gordoclimb',
            coords = {
                x = 2920.821,
                y = 5310.7227,
                z = 96.14481
            }
        }},
        vehicles = {{
            name = 'Patrol',
            id = 'hellion',
            mods = {
                [vehicleMods.EXHAUST] = 2,
                [vehicleMods.FENDER] = 7
            }
        }, {
            name = 'Hilux',
            id = 'everon'
        }, {
            name = 'Mini (for descent)',
            id = 'issi4',
            options = {
                livery = 1
            },
            mods = {
                [vehicleMods.AERIALS] = -1,
                [vehicleMods.ARCH_COVER] = -1,
                [vehicleMods.TANK] = -1,
                [vehicleMods.FRONT_BUMPER] = 2,
                [vehicleMods.SIDE_SKIRT] = 1,
                [vehicleMods.EXHAUST] = 3,
                [vehicleMods.HOOD] = 6,
                [vehicleMods.FENDER] = 2,
                [vehicleMods.GRILLE] = 1
            }
        }, {
            name = 'Go-Kart (for descent)',
            id = 'veto',
            options = {
                livery = 9,
                randomColor = true
            }
        }}
    }, {
        name = 'F1 Race',
        description = 'Formula 1 racing events',
        locations = {{
            name = 'Arena Rooftop',
            id = 'f1ring',
            coords = {
                x = -311.61465,
                y = -1922.4286,
                z = 51.293106
            }
        }, {
            name = 'Raceway',
            id = 'raceway',
            coords = {
                x = 1178.46,
                y = 302.3174,
                z = 81.98781
            }
        }},
        vehicles = {{
            name = 'BR8',
            id = 'openwheel1',
            options = {
                livery = 1,
                randomColor = true
            }
        }, {
            name = 'DR1',
            id = 'openwheel2',
            options = {
                livery = 1,
                randomColor = true
            }
        }, {
            name = 'PR4',
            id = 'formula',
            options = {
                livery = 1
            }
        }, {
            name = 'R88',
            id = 'formula2',
            options = {
                livery = 1
            }
        }}
    }, {
        name = 'Aero',
        description = 'Take flight in some stunt planes or jetpacks!',
        locations = {{
            name = 'Runway Desert',
            id = 'runway1',
            coords = {
                x = 1063.3182,
                y = 3079.62,
                z = 41.166504
            }
        }, {
            name = 'Runway Tarmac',
            id = 'runway2',
            coords = {
                x = -1663.9249,
                y = -2944.1997,
                z = 13.944448
            }
        }, {
            name = 'Runway Dirt',
            id = 'runway3',
            coords = {
                x = 2128.0996,
                y = 4807.3364,
                z = 41.195976
            }
        }},
        vehicles = {{
            name = 'Stunt Plane',
            id = 'alphaz1'
        }, {
            name = 'Jetpack',
            id = 'thruster'
        }, {
            name = 'Pyro',
            id = 'pyro'
        }}
    }},
    licensePlate = 'ADVTOURS',
    brandColor = { -- official AdventureTours yellow
        r = 204,
        g = 132,
        b = 0
    },
    -- These mods will be applied to all spawned vehicles
    defaultMods = {vehicleMods.TANK, vehicleMods.ARCH_COVER, vehicleMods.ARMOR, vehicleMods.TRUNK, vehicleMods.BRAKES,
                   vehicleMods.STRUTS, vehicleMods.TRANSMISSION, vehicleMods.TRIM, vehicleMods.AERIALS,
                   vehicleMods.AIR_FILTER, vehicleMods.ENGINE_BLOCK, vehicleMods.ENGINE, vehicleMods.GRILLE,
                   vehicleMods.SIDE_SKIRT, vehicleMods.REAR_BUMPER, vehicleMods.FRONT_BUMPER},
    tourRules = {'TOUR BUS RULES:', 'No killing other passengers', 'No setting waypoints',
                 'No shooting out of the bus windows'},
    welcomeMessage = 'Welcome to the tour! We have many fun activities planned. Please remain seated while we pick up more passengers.',
    callToActionMessage = 'Would anyone else like to join the tour?',
    thankYouMessage = 'Thank you all so much for joining the tour!',
    boastMessage = 'I wrote my own lua script to do these tours',
    passengerCountMessage = function(passengerCount)
        return 'I have hosted over ' .. tostring(passengerCount) .. ' passengers so far!'
    end,
    -- Tour guide animations
    actions = {{
        id = 'bong',
        name = 'Rip a cone'
    }, {
        id = 'joint',
        name = 'Put a joint in your mouth'
    }, {
        id = 'guitar',
        name = 'Play guitar'
    }, {
        id = 'map',
        name = 'Look at a map'
    }, {
        id = 'bow',
        name = 'Take a bow',
        variants = {'2'}
    }, {
        id = 'clap',
        name = 'Clap'
    }, {
        id = 'celebrate',
        name = 'Celebrate'
    }, {
        id = 'flip',
        variants = {'2'},
        name = 'Flip'
    }, {
        id = 'lapdance',
        name = 'Sexual dance',
        variants = {'', '3', '4'}
    }, {
        id = 'stretch',
        name = 'Stretches',
        variants = {'', '2', '3', '4'}
    }, {
        id = 'whistle',
        name = 'Over here!',
        variants = {'2'}
    }}
}

return adventureData
