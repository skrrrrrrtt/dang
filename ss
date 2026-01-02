-- =====================================================
-- PS99 KRAMPUS ADVANCED WEBHOOK TRACKER
-- Tracks count + gain rate + estimated per hour
-- =====================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local LocalData = require(ReplicatedStorage.Library.Client.LocalData)

-- ================== CONFIG ==================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440202664389640242/RR2NiQ4WqbtRy4zH9YmmQcdW4YgPCqz22HCBnW-XVd0nNvH1WklGYX_eDjoyQyF8ruoU"
local SAMPLE_INTERVAL = 60      -- seconds between samples
local WEBHOOK_INTERVAL = 300    -- seconds between webhook sends
local PET_NAME = "Krampus"
local SMOOTHING = 0.25          -- EMA smoothing

-- ================== SAFE DATA ==================
local function getData()
    local ok, data = pcall(function()
        return LocalData:Get()
    end)
    return ok and data or nil
end

-- ================== KRAMPUS COUNT ==================
local function getKrampus()
    local data = getData()
    if not data or not data.Pets then return 0 end

    local total = 0
    for _, pet in pairs(data.Pets) do
        if pet.Name == PET_NAME then
            total += pet.Amount or 1
        end
    end
    return total
end

-- ================== TRACKING STATE ==================
local startTime = os.clock()
local startCount = getKrampus()

local lastCount = startCount
local lastSampleTime = os.clock()

local emaRate = 0 -- krampus per second

-- ================== SAMPLING LOOP ==================
task.spawn(function()
    while true do
        task.wait(SAMPLE_INTERVAL)

        local now = os.clock()
        local current = getKrampus()

        local deltaPets = current - lastCount
        local deltaTime = now - lastSampleTime

        if deltaTime > 0 then
            local rate = deltaPets / deltaTime
            emaRate = (emaRate == 0)
                and rate
                or (emaRate * (1 - SMOOTHING) + rate * SMOOTHING)
        end

        lastCount = current
        lastSampleTime = now
    end
end)

-- ================== WEBHOOK ==================
local function sendWebhook()
    local now = os.clock()
    local current = getKrampus()

    local elapsed = now - startTime
    local totalGained = current - startCount

    local perHour = math.floor(emaRate * 3600 * 100) / 100

    local payload = {
        embeds = {{
            title = "🐾 PS99 Krampus Tracker",
            color = 0xff4444,
            fields = {
                { name = "Current Krampus", value = tostring(current), inline = true },
                { name = "Session Gained", value = tostring(totalGained), inline = true },
                { name = "Estimated / Hour", value = tostring(perHour), inline = true },
                { name = "Player", value = plr.Name, inline = true },
                { name = "Server", value = game.JobId, inline = true },
                { name = "Uptime (min)", value = tostring(math.floor(elapsed / 60)), inline = true },
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

-- ================== START ==================
task.wait(5)
sendWebhook()

while task.wait(WEBHOOK_INTERVAL) do
    sendWebhook()
end
