local constants = require('lib.AdventureScript.constants')

local DATA = {}

-- Official AdventureTours Bus Stops: teleport locations and vehicles
DATA.tourStops = {{
    name = 'Motocross',
    description = 'Race around the Redwood Lights motocross track using dirtbikes, quads or buggies',
    locations = {{
        name = 'Redwood Lights Track',
        id = 'motocross',
        coords = {
            x = 1093.9911,
            y = 2108.692,
            z = 53.391186
        }
    }},
    vehicles = {{
        name = 'Dirtbike',
        id = 'manchez2'
    }, {
        name = 'Quadbike',
        id = 'verus'
    }, {
        name = 'Buggy',
        id = 'vagrant'
    }, {
        name = 'Hot Quad',
        id = 'blazer3'
    }}
}, {
    name = 'River Ride',
    description = 'Jetski down the rapids and on to the swamp swim event',
    locations = {{
        name = 'Rapids',
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
    }}
}, {
    name = 'Swamp Swim',
    description = 'Swim some fat F250s through the river',
    locations = {{
        name = 'Zancudo River',
        id = 'swampswim',
        coords = {
            x = -1447.9856,
            y = 2571.5137,
            z = 3.9270356
        }
    }},
    vehicles = {{
        name = 'F250',
        id = 'sandking',
        options = {
            f1Wheels = true
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
        name = '65 Mustang',
        id = 'drifttampa',
        options = {
            drift = true,
            f1Wheels = true
        }
    }, {
        name = 'AE86',
        id = 'futo2',
        options = {
            drift = true,
            f1Wheels = true,
            randomLivery = true
        }
    }, {
        name = 'Skyline',
        id = 'elegy',
        options = {
            drift = true
        },
        mods = {
            [constants.vehicleMods.ARCH_COVER] = 4,
            [constants.vehicleMods.EXHAUST] = 2,
            [constants.vehicleMods.REAR_BUMPER] = -1,
            [constants.vehicleMods.FRONT_BUMPER] = 2,
            [constants.vehicleMods.PLATEHOLDER] = 1,
            [constants.vehicleMods.WINDOWS] = 1
        }
    }}
}, {
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
        name = 'Hot Quad',
        id = 'blazer3'
    }, {
        name = 'Lawnmower',
        id = 'mower'
    }}
}, {
    name = 'Mountain Biking',
    description = 'Scenic mountain biking trails',
    locations = {{
        name = 'Gorge Trail',
        id = 'gorgetrail',
        coords = {
            x = -1139.7003,
            y = 4610.722,
            z = 146.11864
        }
    }},
    vehicles = {{
        name = 'Mountain Bike',
        id = 'scorcher'
    }}
}, {
    name = '4WD',
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
        name = 'Gordo Climb',
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
            [constants.vehicleMods.EXHAUST] = 2,
            [constants.vehicleMods.FENDER] = 7
        }
    }, {
        name = 'Hilux',
        id = 'everon'
    }}
}, {
    name = 'Drag Racing',
    description = 'Some kind of sick street race? (WIP)',
    locations = {{
        name = 'Drag Strip',
        id = 'dragstrip',
        coords = {
            x = 1178.46,
            y = 302.3174,
            z = 81.98781
        }
    }},
    vehicles = {{
        name = 'Dragster',
        id = 'deveste',
        options = {
            randomColour = true
        }
    }, {
        name = 'Muscle Car',
        id = 'dominator3',
        options = {
            randomColour = true
        }
    }}
}, {
    name = 'Downhill',
    description = 'Downhill speed freak shit',
    locations = {{
        name = 'Chiliad South',
        id = 'chiliadsouthdescent',
        coords = {
            x = 642.8843,
            y = 5629.7363,
            z = 726.7645
        }
    }, {
        name = 'Chiliad East',
        id = 'chiliadeastdescent',
        coords = {
            x = 505.47202,
            y = 5539.428,
            z = 778.25977
        }
    }},
    vehicles = {{
        name = 'Go-Kart (for descent)',
        id = 'veto',
        options = {
            randomColour = true,
            randomLivery = true
        }
    }, {
        name = 'Mini (for descent)',
        id = 'issi4',
        options = {
            randomLivery = true
        },
        mods = {
            [constants.vehicleMods.AERIALS] = -1,
            [constants.vehicleMods.ARCH_COVER] = -1,
            [constants.vehicleMods.TANK] = -1,
            [constants.vehicleMods.FRONT_BUMPER] = 2,
            [constants.vehicleMods.SIDE_SKIRT] = 1,
            [constants.vehicleMods.EXHAUST] = 3,
            [constants.vehicleMods.HOOD] = 6,
            [constants.vehicleMods.FENDER] = 2,
            [constants.vehicleMods.GRILLE] = 1
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
        name = 'DR1',
        id = 'openwheel2',
        options = {
            randomLivery = true,
            randomColour = true
        }
    }, {
        name = 'R88',
        id = 'formula2',
        options = {
            randomLivery = true
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
        name = 'Runway LSX',
        id = 'runway2',
        coords = {
            x = -1663.9249,
            y = -2944.1997,
            z = 13.944448
        }
    }, {
        name = 'Runway Mountain',
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
    }}
}, {
    name = 'Kart Offroad',
    description = 'Use go-karts on this little dirt track',
    locations = {{
        name = 'Dirt Track',
        id = 'dirttrack',
        coords = {
            x = 1882.3873,
            y = 3351.0962,
            z = 42.945
        }
    }},
    vehicles = {{
        name = 'Go-Kart',
        id = 'veto',
        options = {
            randomLivery = true
        }
    }, {
        name = 'Mountain Bike',
        id = 'scorcher'
    }}
}}

-- Tour guide animations
DATA.actions = {{
    id = 'holdcamera',
    name = 'Hold camera',
    type = 'anim'
}, {
    id = 'binoculars',
    name = 'Binoculars',
    type = 'scen'
}, {
    id = 'examinemap',
    name = 'Examine map',
    type = 'anim'
}, {
    id = 'yoga',
    name = 'Yoga',
    type = 'scen'
}, {
    id = 'weld',
    name = 'Weld',
    type = 'scen'
}, {
    id = 'standfish',
    name = 'Fishing',
    type = 'scen'
}, {
    id = 'sweepwithbroom',
    name = 'Broom sweep',
    type = 'anim'
}, {
    id = 'highclassprostitute',
    name = 'Sassy smoke',
    type = 'scen'
}, {
    id = 'tendtodead',
    name = 'Tend to dead',
    type = 'scen'
}, {
    id = 'stretch',
    name = 'Stretch',
    type = 'anim'
}, {
    id = 'sunbathe',
    name = 'Sunbathe',
    type = 'scen'
}, {
    id = 'playbongos',
    name = 'Play bongos',
    type = 'anim'
}, {
    id = 'lapdance',
    name = 'Sexual dance',
    variants = {'1', '3', '4'},
    type = 'anim'
}, {
    id = 'buttwiggle',
    name = 'Buttwiggle dance',
    type = 'anim'
}, {
    id = 'drinkbeer',
    name = 'Drink beer',
    type = 'anim'
}, {
    id = 'holdrose',
    name = 'Hold rose',
    type = 'anim'
}}

-- function to access colour based on key
DATA.getColour = function(key)
    return constants.colours[key]
end

return DATA
