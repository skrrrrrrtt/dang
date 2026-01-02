--=====================================================
-- 🎄 PS99 KRAMPUS MONITOR | TIER 3 ADVANCED
--=====================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer

--================ CONFIG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440202664389640242/RR2NiQ4WqbtRy4zH9YmmQcdW4YgPCqz22HCBnW-XVd0nNvH1WklGYX_eDjoyQyF8ruoU"
local UPDATE_INTERVAL = 600 -- seconds
local PET_NAME = "Krampus"

--================ STATE =================
local sessionStart = os.time()
local dayStart = os.date("!*t").yday

local lastCheckTime = os.time()
local lastTotal = 0

local peakRate = 0
local lifetimeGained = 0
local dailyGained = 0
local sessionGained = 0

--================ SAVE ACCESS =================
local function getSave()
    local ok, save = pcall(function()
        return require(ReplicatedStorage.Library.Client.Save).Get()
    end)
    return ok and save or nil
end

--================ PET COUNT =================
local function countKrampus()
    local save = getSave()
    if not save or not save.Inventory or not save.Inventory.Pet then return 0 end

    local total = 0
    for _, pet in pairs(save.Inventory.Pet) do
        if pet.id == PET_NAME then
            total += pet._am or 1
        end
    end
    return total
end

--================ RATE CALCS =================
local function calcRate(gain, deltaTime)
    if deltaTime <= 0 then return 0 end
    return math.floor(((gain / deltaTime) * 3600) * 100) / 100
end

--================ WEBHOOK =================
local function sendWebhook(data)
    local payload = {
        embeds = {{
            title = "🎄 Krampus Monitor — Tier 3",
            color = data.color,
            fields = {
                {
                    name = "📦 Totals",
                    value =
                        "**Session Gain:** "..data.sessionGain..
                        "\n**Daily Gain:** "..data.dailyGain..
                        "\n**Lifetime Gain:** "..data.lifetime,
                    inline = true
                },
                {
                    name = "📈 Rates (/h)",
                    value =
                        "**Instant:** "..data.instant..
                        "\n**Avg Session:** "..data.avgSession..
                        "\n**Avg Daily:** "..data.avgDaily..
                        "\n**Peak:** "..data.peak,
                    inline = true
                },
                {
                    name = "⏱️ Session",
                    value = data.sessionTime,
                    inline = true
                }
            },
            footer = {
                text = "Player: "..plr.Name.." | Server: "..game.JobId
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

--================ MAIN LOOP =================
task.wait(3)
lastTotal = countKrampus()

while true do
    task.wait(UPDATE_INTERVAL)

    local now = os.time()
    local currentDay = os.date("!*t").yday

    -- DAILY RESET
    if currentDay ~= dayStart then
        dailyGained = 0
        dayStart = currentDay
    end

    local currentTotal = countKrampus()
    local gained = currentTotal - lastTotal
    local delta = now - lastCheckTime

    sessionGained += gained
    dailyGained += gained
    lifetimeGained += gained

    local instantRate = calcRate(gained, delta)
    local sessionRate = calcRate(sessionGained, now - sessionStart)
    local dailyRate = calcRate(dailyGained, now - os.time({year=1970}))

    peakRate = math.max(peakRate, instantRate)

    -- ALERT COLOR LOGIC
    local color = 0x00FF00
    if gained == 0 then
        color = 0xFF0000 -- stalled
    elseif instantRate > peakRate * 1.5 then
        color = 0xFFD700 -- spike
    end

    local elapsed = now - sessionStart
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)

    sendWebhook({
        sessionGain = sessionGained,
        dailyGain = dailyGained,
        lifetime = lifetimeGained,
        instant = instantRate,
        avgSession = sessionRate,
        avgDaily = dailyRate,
        peak = peakRate,
        sessionTime = h.."h "..m.."m",
        color = color
    })

    lastTotal = currentTotal
    lastCheckTime = now
end
