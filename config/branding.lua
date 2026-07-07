-- Brand colours, tour messages, guide outfit data, and guide action presets.

Branding = {
    scriptVersion = '2.0.0',

    licensePlate = 'ADVTOURS',

    colours = {
        yellow = { r = 204, g = 132, b = 0 },
        pink = { r = 252, g = 134, b = 255 },
        white = { r = 255, g = 255, b = 255 },
    },

    tourRules = {
        'TOUR BUS RULES:',
        'No killing other passengers',
        'No setting waypoints',
        'No shooting out of the bus windows',
    },

    welcomeMessage = 'Welcome to the tour! We have many fun activities planned. Please remain seated while we pick up more passengers.',
    callToActionMessage = 'Would anyone else like to join the tour?',
    thankYouMessage = 'Thank you all so much for joining the tour!',

    tourEndedMessage = 'The tour has ended.',
    gatherToBusMessage = 'Gathering the tour group to the bus.',
    gatherToStopMessage = 'Gathering the tour group to the current stop.',

    guidePromotedMessage = '%s is now the tour guide.',
    guideTransferredMessage = 'Tour guide role transferred to %s.',
    guideYouAreGuideMessage = 'You are the tour guide.',
    guideYouArePassengerMessage = '%s is leading the tour.',

    electionDurationSec = 30,
    electionCooldownSec = 90,
    nextStopVoteThreshold = 0.5,
    electionStartedMessage = 'Election started: vote whether %s should become tour guide.',
    electionPassedMessage = '%s was elected as the new tour guide.',
    electionFailedMessage = 'Election failed — %s did not receive enough votes.',
    electionCancelledMessage = 'The guide election was cancelled.',
    electionBallotMessage = 'Vote whether %s should become the tour guide?',

    helpStuckMessage = '%s needs help — they are stuck!',
    helpInjuredMessage = '%s needs help — they are injured!',
    nextStopVoteThresholdMessage = 'Passengers want to move on! %d of %d voted for the next stop.',

    followingEnabledMessage = 'You are following the tour again.',
    followingDisabledMessage = 'You are no longer following tour teleports.',

    inviteMaxDistance = 0,
    awayDistance = 75.0,

    tourGuideOutfit = {
        components = {
            [2] = { drawable = 56, texture = 0 },   -- hair
            [3] = { drawable = 11, texture = 0 },   -- gloves / torso
            [4] = { drawable = 144, texture = 12 }, -- pants (denim jorts)
            [8] = { drawable = 15, texture = 0 },   -- top 2 / undershirt
            [11] = { drawable = 13, texture = 1 },   -- top
        },
        hairColour = 2,     -- Dark Gray
        hairHighlight = 27,   -- Light Gray
        -- Facial hair: overlay id 1, index 10 = mustache (see AGENTS.md / rage.mp wiki).
        -- Colour uses the hair palette (https://wiki.rage.mp/wiki/Hair_Colors); 2 = dark gray.
        facialHair = { index = 10, colour = 2 },
    },

    -- Branded hat, glasses, boots, and watch per tour colour (merged onto tourGuideOutfit).
    tourGuideOutfitColours = {
        yellow = {
            components = {
                [6] = { drawable = 12, texture = 12 },  -- work boots (Beige)
            },
            props = {
                [0] = { drawable = 105, texture = 19 }, -- boonie (Sand)
                [1] = { drawable = 16, texture = 2 },   -- wraparound glasses (Orange)
                [6] = { drawable = 5, texture = 3 },    -- LED watch (Yellow)
            },
        },
        pink = {
            components = {
                [6] = { drawable = 12, texture = 13 },  -- work boots (Pink)
            },
            props = {
                [0] = { drawable = 105, texture = 4 },  -- boonie (Peach)
                [1] = { drawable = 16, texture = 0 },   -- wraparound glasses (Pink)
                [6] = { drawable = 12, texture = 2 },   -- iFruit Link (Pink)
            },
        },
        white = {
            components = {
                [6] = { drawable = 12, texture = 10 },  -- work boots (White)
            },
            props = {
                [0] = { drawable = 105, texture = 22 }, -- boonie (White)
                [1] = { drawable = 16, texture = 6 },   -- wraparound glasses (Onyx)
                [6] = { drawable = 5, texture = 2 },    -- LED watch (White)
            },
        },
    },

    actions = {
        { id = 'holdcamera', name = 'Hold camera', type = 'anim', icon = 'camera', dict = 'amb@world_human_paparazzi@male@base', clip = 'base' },
        { id = 'binoculars', name = 'Binoculars', type = 'scen', icon = 'binoculars', scenario = 'WORLD_HUMAN_BINOCULARS' },
        { id = 'examinemap', name = 'Examine map', type = 'anim', icon = 'map', dict = 'amb@world_human_tourist_map@male@base', clip = 'base' },
        { id = 'yoga', name = 'Yoga', type = 'scen', icon = 'spa', scenario = 'WORLD_HUMAN_YOGA' },
        { id = 'weld', name = 'Weld', type = 'scen', icon = 'fire', scenario = 'WORLD_HUMAN_WELDING' },
        { id = 'standfish', name = 'Fishing', type = 'scen', icon = 'fish', scenario = 'WORLD_HUMAN_STAND_FISHING' },
        { id = 'sweepwithbroom', name = 'Broom sweep', type = 'anim', icon = 'broom', dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a' },
        { id = 'highclassprostitute', name = 'Sassy smoke', type = 'scen', icon = 'smoking', scenario = 'WORLD_HUMAN_SMOKING' },
        { id = 'tendtodead', name = 'Tend to dead', type = 'scen', icon = 'kit-medical', scenario = 'WORLD_HUMAN_MEDIC_TEND_TO_DEAD' },
        { id = 'stretch', name = 'Stretch', type = 'anim', icon = 'person-walking', dict = 'mini@triathlon', clip = 'idle_e' },
        { id = 'sunbathe', name = 'Sunbathe', type = 'scen', icon = 'umbrella-beach', scenario = 'WORLD_HUMAN_SUNBATHE' },
        { id = 'playbongos', name = 'Play bongos', type = 'anim', icon = 'drum', dict = 'anim@mp_player_intcelebrationmale@bongo', clip = 'bongo' },
        {
            id = 'lapdance',
            name = 'Sexual dance',
            variants = { '1', '3', '4' },
            type = 'anim',
            icon = 'music',
            dict = 'mp_safehouse',
            clips = { 'lap_dance_girl', 'lap_dance_girl2', 'lap_dance_girl3' },
        },
        { id = 'buttwiggle', name = 'Buttwiggle dance', type = 'anim', icon = 'music', dict = 'switch@trevor@mocks_lapdance', clip = 'twerk_loop_lapdance' },
        { id = 'drinkbeer', name = 'Drink beer', type = 'anim', icon = 'beer-mug-empty', dict = 'amb@world_human_drinking@beer@male@idle_a', clip = 'idle_a' },
        { id = 'holdrose', name = 'Hold rose', type = 'anim', icon = 'seedling', dict = 'anim@heists@humane_labs@finale@keycards', clip = 'ped_a_enter_loop' },
    },
}

function GetBrandColour(key)
    return Branding.colours[key] or Branding.colours.yellow
end
