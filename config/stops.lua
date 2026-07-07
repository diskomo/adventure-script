-- Tour stop definitions: locations, spawn vehicles, and per-stop options.
--
-- Stop shape:
--   name, description, locations[] — { name, id, coords }
--   vehicles[] — { name, id, icon, options?, mods? }
--     id     = GTA vehicle spawn name (passed to joaat)
--     icon   = Font Awesome icon key for the NUI
--     mods   = VehicleMods index → mod index (-1 removes)

TourStops = {
    {
        name = 'Motocross',
        description = 'Race around the Redwood Lights motocross track using dirtbikes, quads or buggies',
        locations = {
            {
                name = 'Redwood Lights Track',
                id = 'motocross',
                coords = vector3(1093.9911, 2108.692, 53.391186),
            },
        },
        vehicles = {
            { name = 'Dirtbike', id = 'manchez2', icon = 'motorcycle' },
            { name = 'Quadbike', id = 'verus', icon = 'truck-monster' },
            { name = 'Buggy', id = 'vagrant', icon = 'truck-monster' },
            { name = 'Hot Quad', id = 'blazer3', icon = 'truck-monster' },
        },
    },
    {
        name = 'River Ride',
        description = 'Jetski down the rapids and on to the swamp swim event',
        locations = {
            {
                name = 'Rapids',
                id = 'riverrapids',
                coords = vector3(-47.31711, 3089.3042, 27.836765),
            },
        },
        vehicles = {
            { name = 'Jetski', id = 'seashark', icon = 'water' },
        },
    },
    {
        name = 'Swamp Swim',
        description = 'Swim some fat F250s through the river',
        locations = {
            {
                name = 'Zancudo River',
                id = 'swampswim',
                coords = vector3(-1447.9856, 2571.5137, 3.9270356),
            },
        },
        vehicles = {
            {
                name = 'F250',
                id = 'sandking',
                icon = 'truck-pickup',
                options = { f1Wheels = true },
            },
        },
    },
    {
        name = 'Drift',
        description = 'Drift around the dock carpark or the snaking dirt road by the wind farm',
        locations = {
            {
                name = 'Docks',
                id = 'drift1',
                coords = vector3(1266.2307, -3097.5962, 5.907445),
            },
            {
                name = 'Dirt Turbines',
                id = 'drift2',
                coords = vector3(2188.031, 1594.5018, 80.5829),
            },
        },
        vehicles = {
            {
                name = '65 Mustang',
                id = 'drifttampa',
                icon = 'car-side',
                options = { drift = true, f1Wheels = true },
            },
            {
                name = 'AE86',
                id = 'futo2',
                icon = 'car-side',
                options = { drift = true, f1Wheels = true, randomLivery = true },
            },
            {
                name = 'Skyline',
                id = 'elegy',
                icon = 'car-side',
                options = { drift = true },
                mods = {
                    [VehicleMods.ARCH_COVER] = 4,
                    [VehicleMods.EXHAUST] = 2,
                    [VehicleMods.REAR_BUMPER] = -1,
                    [VehicleMods.FRONT_BUMPER] = 2,
                    [VehicleMods.PLATEHOLDER] = 1,
                    [VehicleMods.WINDOWS] = 1,
                },
            },
        },
    },
    {
        name = 'Skatepark',
        description = 'Ride the halfpipes',
        locations = {
            {
                name = 'Vespucci Halfpipe',
                id = 'skatepark1',
                coords = vector3(-917.7622, -807.44653, 15.9212),
            },
            {
                name = 'Underpass Skatepark',
                id = 'skatepark2',
                coords = vector3(725.3054, -1226.8306, 24.691328),
            },
        },
        vehicles = {
            { name = 'BMX', id = 'bmx', icon = 'bicycle' },
            {
                name = 'Go-Kart',
                id = 'veto2',
                icon = 'gauge-high',
                options = { f1Wheels = true },
            },
            { name = 'Hot Quad', id = 'blazer3', icon = 'truck-monster' },
            { name = 'Lawnmower', id = 'mower', icon = 'tractor' },
        },
    },
    {
        name = 'Mountain Biking',
        description = 'Scenic mountain biking trails',
        locations = {
            {
                name = 'Gorge Trail',
                id = 'gorgetrail',
                coords = vector3(-1139.7003, 4610.722, 146.11864),
            },
        },
        vehicles = {
            { name = 'Mountain Bike', id = 'scorcher', icon = 'person-biking' },
        },
    },
    {
        name = '4WD',
        description = 'Mt Chiliad or Mt Gordo 4WD climbs and go-kart descent',
        locations = {
            {
                name = 'Chiliad Climb',
                id = 'chiliadclimb',
                coords = vector3(-367.6046, 4916.092, 196.70187),
            },
            {
                name = 'Gordo Climb',
                id = 'gordoclimb',
                coords = vector3(2920.821, 5310.7227, 96.14481),
            },
        },
        vehicles = {
            {
                name = 'Patrol',
                id = 'hellion',
                icon = 'truck-monster',
                mods = {
                    [VehicleMods.EXHAUST] = 2,
                    [VehicleMods.FENDER] = 7,
                },
            },
            { name = 'Hilux', id = 'everon', icon = 'truck-monster' },
        },
    },
    {
        name = 'Drag Racing',
        description = 'Some kind of sick street race? (WIP)',
        locations = {
            {
                name = 'Drag Strip',
                id = 'dragstrip',
                coords = vector3(1178.46, 302.3174, 81.98781),
            },
        },
        vehicles = {
            {
                name = 'Dragster',
                id = 'deveste',
                icon = 'flag-checkered',
            },
            {
                name = 'Muscle Car',
                id = 'dominator3',
                icon = 'car-side',
            },
        },
    },
    {
        name = 'Downhill',
        description = 'Downhill speed freak shit',
        rainbowMode = true,
        locations = {
            {
                name = 'Chiliad South',
                id = 'chiliadsouthdescent',
                coords = vector3(642.8843, 5629.7363, 726.7645),
            },
            {
                name = 'Chiliad East',
                id = 'chiliadeastdescent',
                coords = vector3(505.47202, 5539.428, 778.25977),
            },
        },
        vehicles = {
            {
                name = 'Go-Kart (for descent)',
                id = 'veto',
                icon = 'gauge-high',
                options = { randomLivery = true },
            },
            {
                name = 'Mini (for descent)',
                id = 'issi4',
                icon = 'car-side',
                options = { randomLivery = true },
                mods = {
                    [VehicleMods.AERIALS] = -1,
                    [VehicleMods.ARCH_COVER] = -1,
                    [VehicleMods.TANK] = -1,
                    [VehicleMods.FRONT_BUMPER] = 2,
                    [VehicleMods.SIDE_SKIRT] = 1,
                    [VehicleMods.EXHAUST] = 3,
                    [VehicleMods.HOOD] = 6,
                    [VehicleMods.FENDER] = 2,
                    [VehicleMods.GRILLE] = 1,
                },
            },
        },
    },
    {
        name = 'F1 Race',
        description = 'Formula 1 racing events',
        rainbowMode = true,
        locations = {
            {
                name = 'Arena Rooftop',
                id = 'f1ring',
                coords = vector3(-311.61465, -1922.4286, 51.293106),
            },
            {
                name = 'Raceway',
                id = 'raceway',
                coords = vector3(1178.46, 302.3174, 81.98781),
            },
        },
        vehicles = {
            {
                name = 'DR1',
                id = 'openwheel2',
                icon = 'flag-checkered',
                options = { randomLivery = true },
            },
            {
                name = 'R88',
                id = 'formula2',
                icon = 'flag-checkered',
                options = { randomLivery = true },
            },
        },
    },
    {
        name = 'Aero',
        description = 'Take flight in some stunt planes or jetpacks!',
        locations = {
            {
                name = 'Runway Desert',
                id = 'runway1',
                coords = vector3(1063.3182, 3079.62, 41.166504),
            },
            {
                name = 'Runway LSX',
                id = 'runway2',
                coords = vector3(-1663.9249, -2944.1997, 13.944448),
            },
            {
                name = 'Runway Mountain',
                id = 'runway3',
                coords = vector3(2128.0996, 4807.3364, 41.195976),
            },
        },
        vehicles = {
            { name = 'Stunt Plane', id = 'alphaz1', icon = 'plane' },
            { name = 'Jetpack', id = 'thruster', icon = 'rocket' },
        },
    },
    {
        name = 'Kart Offroad',
        description = 'Use go-karts on this little dirt track',
        rainbowMode = true,
        locations = {
            {
                name = 'Dirt Track',
                id = 'dirttrack',
                coords = vector3(1882.3873, 3351.0962, 42.945),
            },
        },
        vehicles = {
            {
                name = 'Go-Kart',
                id = 'veto',
                icon = 'gauge-high',
                options = { randomLivery = true },
            },
            { name = 'Mountain Bike', id = 'scorcher', icon = 'person-biking' },
        },
    },
}
