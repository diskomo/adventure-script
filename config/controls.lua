-- On-screen keybind hint labels for HUD and L3 quick-action overlays.

ControlHints = {
    foot = {
        { keys = { 'R3', 'dpad-left' }, label = 'Previous venue' },
        { keys = { 'R3', 'dpad-left', '×2' }, label = 'Previous stop', double = true },
        { keys = { 'R3', 'dpad-right' }, label = 'Next venue' },
        { keys = { 'R3', 'dpad-right', '×2' }, label = 'Next stop', double = true },
        { keys = { 'R3', 'dpad-up' }, label = 'Next vehicle' },
        { keys = { 'R3', 'dpad-down' }, label = 'Previous vehicle' },
        { keys = { 'L3' }, label = 'Quick actions' },
        { keys = { 'L1' }, label = 'Toggle superdrive' },
        { keys = { 'R1' }, label = 'Open menu' },
    },
    bus = {
        { keys = { 'R3', 'dpad-left' }, label = 'Previous venue' },
        { keys = { 'R3', 'dpad-left', '×2' }, label = 'Previous stop', double = true },
        { keys = { 'R3', 'dpad-right' }, label = 'Next venue' },
        { keys = { 'R3', 'dpad-right', '×2' }, label = 'Next stop', double = true },
        { keys = { 'R3', 'dpad-up' }, label = 'Next vehicle' },
        { keys = { 'R3', 'dpad-down' }, label = 'Previous vehicle' },
        { keys = { 'L3' }, label = 'Quick actions' },
        { keys = { 'L1' }, label = 'Toggle superdrive' },
        { keys = { 'R1' }, label = 'Open menu' },
    },
    l3MenuFoot = {
        { keys = { 'dpad-up' }, label = 'Grid spawn' },
        { keys = { 'dpad-right' }, label = 'Clear area' },
        { keys = { 'dpad-left' }, label = 'Undo' },
        { keys = { 'dpad-down' }, label = 'Spawn bus' },
        { keys = { 'X' }, label = 'Stop tour' },
        { keys = { 'L3' }, label = 'Close' },
    },
    l3MenuBus = {
        { keys = { 'dpad-up' }, label = 'Grid spawn' },
        { keys = { 'dpad-right' }, label = 'Clear area' },
        { keys = { 'dpad-left' }, label = 'Undo' },
        { keys = { 'dpad-down' }, label = 'Spawn bus' },
        { keys = { 'X' }, label = 'Play/stop tour' },
        { keys = { 'L3' }, label = 'Close' },
    },
}
