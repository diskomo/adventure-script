-- Match the ox_lib UI accent (hover, title, arrows) to the Adventure Tours
-- brand yellow. ox_lib only reads these on its own start, so they apply to
-- clients that connect after this resource has set them.
SetConvarReplicated('ox:primaryColor', 'yellow')
SetConvarReplicated('ox:primaryShade', '8')

local B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- Hand-rolled: FiveM server Lua has no bundled base64/bit library.
local function base64Encode(data)
    return ((data:gsub('.', function(x)
        local r, byte = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (byte % 2^i - byte % 2^(i-1) > 0 and '1' or '0')
        end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then
            return ''
        end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2^(6 - i) or 0)
        end
        return B64:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local cachedBannerB64

local function getBannerBase64()
    if cachedBannerB64 then
        return cachedBannerB64
    end

    local resource = GetCurrentResourceName()
    local raw = LoadResourceFile(resource, 'html/banner.jpg')

    if not raw then
        return nil
    end

    cachedBannerB64 = base64Encode(raw)
    return cachedBannerB64
end

RegisterNetEvent('adventure_tours:requestBanner', function()
    local src = source
    local b64 = getBannerBase64()
    if b64 then
        TriggerClientEvent('adventure_tours:receiveBanner', src, b64)
    end
end)

local function sendChatMessage(message)
    local colour = Branding.colours.yellow
    TriggerClientEvent('chat:addMessage', -1, {
        color = { colour.r, colour.g, colour.b },
        multiline = true,
        args = { 'Adventure Tours', message },
    })
end

local CHAT_MESSAGES = {
    welcome = Branding.welcomeMessage,
    invite = Branding.callToActionMessage,
    thankyou = Branding.thankYouMessage,
}

RegisterNetEvent('adventure_tours:sendChat', function(chatId)
    local src = source
    if not exports[GetCurrentResourceName()]:IsTourGuide(src) then
        return
    end

    if type(chatId) ~= 'string' then
        return
    end

    if chatId == 'rules' then
        CreateThread(function()
            for _, message in ipairs(Branding.tourRules) do
                if type(message) == 'string' and message ~= '' then
                    sendChatMessage(message)
                    Wait(1000)
                end
            end
        end)
        return
    end

    local message = CHAT_MESSAGES[chatId]
    if message then
        sendChatMessage(message)
    end
end)
