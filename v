--=====================================================
-- 🎄 PS99 KRAMPUS MONITOR | TIER 3+ HARDENED
--=====================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

--================ SERVICES =================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer

--================ EXECUTOR SAFE HTTP =================
local httpRequest =
    request or
    http_request or
    syn and syn.request or
    fluxus and fluxus.request

assert(httpRequest, "❌ No HTTP request function found")

--================ CONFIG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440202664389640242/RR2NiQ4WqbtRy4zH9YmmQcdW4YgPCqz22HCBnW-XVd0nNvH1WklGYX_eDjoyQyF8ruoU"
local UPDATE_INTERVAL = 600
local PET_NAME = "Krampus"

--================ PERSISTENCE =================
local SAVE_KEY = "KRAMPUS_MONITOR_DATA"

local persisted = {}
if isfile and readfile and isfile(SAVE_KEY..".json") then
    persisted = HttpService:JSONDecode(readfile(SAVE_KEY..".json"))
end

--================ STATE =================
local sessionStart = os.time()
local dayStart = os.date("!*t").yday

local lastCheckTime = os.time()
local lastTotal = persisted.lastTotal or 0

local peakRate = persisted.peakRate or 0
local lifetimeGained = persisted.lifetimeGained or 0
local dailyGained = persisted.dailyGained or 0
local sessionGained = 0

--================ LOG =================
print("===================================")
print("🎄 Krampus Monitor Started")
print("👤 Player:", plr.Name)
print("⏱ Interval:", UPDATE_INTERVAL)
print("===================================")

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

--================ RATE =================
local function rate(gain, delta)
    if delta <= 0 then return 0 end
    return math.floor(((gain / delta) * 3600) * 100) / 100
end

--================ SAVE STATE =================
local function persist()
    if writefile then
        writefile(SAVE_KEY..".json", HttpService:JSONEncode({
            lastTotal = lastTotal,
            peakRate = peakRate,
            lifetimeGained = lifetimeGained,
            dailyGained = dailyGained
        }))
    end
end

--================ WEBHOOK =================
local function sendWebhook(data)
    httpRequest({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            embeds = {{
                title = "🎄 Krampus Monitor — Tier 3+",
                color = data.color,
                fields = {
                    {
                        name = "📦 Totals",
                        value =
                            "**Session:** "..data.session..
                            "\n**Daily:** "..data.daily..
                            "\n**Lifetime:** "..data.life,
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
                        name = "⏱ Session Time",
                        value = data.time,
                        inline = true
                    }
                },
                footer = {
                    text = "Player: "..plr.Name.." | Server: "..game.JobId
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        )
    })
end

--================ BOOTSTRAP =================
task.wait(3)
lastTotal = countKrampus()
lastCheckTime = os.time()

print("📤 Sending initial webhook")

sendWebhook({
    session = 0,
    daily = dailyGained,
    life = lifetimeGained,
    instant = 0,
    avgSession = 0,
    avgDaily = 0,
    peak = peakRate,
    time = "0h 0m",
    color = 0x3498DB
})

--================ MAIN LOOP =================
while true do
    task.wait(UPDATE_INTERVAL)

    local now = os.time()
    local currentDay = os.date("!*t").yday

    -- DAILY RESET
    if currentDay ~= dayStart then
        dailyGained = 0
        dayStart = currentDay
        print("📆 Daily reset")
    end

    local currentTotal = countKrampus()
    local gained = currentTotal - lastTotal
    local delta = now - lastCheckTime

    sessionGained += gained
    dailyGained += gained
    lifetimeGained += gained

    local instant = rate(gained, delta)
    local avgSession = rate(sessionGained, now - sessionStart)
    local avgDaily = rate(dailyGained, delta)

    peakRate = math.max(peakRate, instant)

    local elapsed = now - sessionStart
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)

    local color = 0x00FF00
    if gained == 0 then color = 0xFF0000 end
    if instant >= peakRate * 1.5 then color = 0xFFD700 end

    print("Tick | Gained:", gained, "| Rate:", instant)

    sendWebhook({
        session = sessionGained,
        daily = dailyGained,
        life = lifetimeGained,
        instant = instant,
        avgSession = avgSession,
        avgDaily = avgDaily,
        peak = peakRate,
        time = h.."h "..m.."m",
        color = color
    })

    lastTotal = currentTotal
    lastCheckTime = now
    persist()
end
