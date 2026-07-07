-- ox_lib notification wrapper with Adventure Tours branding.

AdventureTours = AdventureTours or {}

local NOTIFY_ICONS = {
    success = 'circle-check',
    error = 'circle-exclamation',
    warning = 'triangle-exclamation',
    inform = 'circle-info',
}

local OX_NOTIFY_TYPES = {
    success = 'success',
    error = 'error',
    warning = 'warning',
    inform = 'info',
}

function AdventureTours.Notify(description, ntype)
    ntype = ntype or 'inform'
    lib.notify({
        title = 'Adventure Tours',
        description = description,
        type = OX_NOTIFY_TYPES[ntype] or 'info',
        icon = NOTIFY_ICONS[ntype] or NOTIFY_ICONS.inform,
        position = 'top',
    })
end
