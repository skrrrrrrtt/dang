-- =====================================================
-- PS99 KRAMPUS + COINS + CANDYCANE WEBHOOK (FINAL FIX)
-- Uses LocalData:Get() (matches your script)
-- =====================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer

-- PS99 modules you ALREADY use
local LocalData = require(ReplicatedStorage.Library.Client.LocalData)
local Client = require(ReplicatedStorage.Library.Client)

-- ================== CONFIG ==================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440202664389640242/RR2NiQ4WqbtRy4zH9YmmQcdW4YgPCqz22HCBnW-XVd0nNvH1WklGYX_eDjoyQyF8ruoU"
local UPDATE_INTERVAL = 600 -- seconds

local PET_NAME = "Krampus"
local CANDYCANE_KEY_1 = "Candycane Gift"
local CANDYCANE_KEY_2 = "candycanegift"

-- ================== SAFE DATA ==================
local function getData()
    local ok, data = pcall(function()
        return LocalData:Get()
    end)
    return ok and data or nil
end

-- ================== COUNTERS ==================

-- 🐾 Krampus
local function countKrampus()
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

-- 🎁 Candycane Gifts (POWERUPS, NOT INVENTORY)
local function countCandycane()
    local data = getData()
    if not data or not data.Powerups then return 0 end

    return data.Powerups[CANDYCANE_KEY_1]
        or data.Powerups[CANDYCANE_KEY_2]
        or 0
end

-- 🪙 Coins (LOCALDATA)
local function getCoins()
    local data = getData()
    if not data or not data.Currency then return 0 end

    return data.Currency.Coins or 0
end

-- ================== WEBHOOK ==================
local function sendWebhook(isInitial)
    local payload = {
        embeds = {{
            title = "PS99 Inventory Monitor",
            color = 0x00ff99,
            fields = {
                { name = isInitial and "Initial" or "Update", value = os.date("%H:%M:%S"), inline = false },
                { name = "Krampus", value = tostring(countKrampus()), inline = true },
                { name = "Coins", value = tostring(getCoins()), inline = true },
                { name = "Candycane Gifts", value = tostring(countCandycane()), inline = true },
                { name = "Player", value = plr.Name, inline = true },
                { name = "Server", value = game.JobId, inline = true },
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
task.wait(2)
sendWebhook(true)

while task.wait(UPDATE_INTERVAL) do
    sendWebhook(false)
end
