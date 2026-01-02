-- =====================================================
-- 🎄 PS99 KRAMPUS MONITOR (ADVANCED)
-- =====================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer

local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= CONFIG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440202664389640242/RR2NiQ4WqbtRy4zH9YmmQcdW4YgPCqz22HCBnW-XVd0nNvH1WklGYX_eDjoyQyF8ruoU"
local UPDATE_INTERVAL = 600 -- 10 minutes
local MONITORED_PET = "Krampus"

-- ================= SESSION DATA =================
local sessionStart = os.time()
local lastTotal = 0
local firstRun = true

-- ================= FUNCTIONS =================
local function getSave()
    local ok, data = pcall(function()
        return require(ReplicatedStorage.Library.Client.Save).Get()
    end)
    return ok and data or nil
end

local function countKrampus()
    local sd = getSave()
    if not sd or not sd.Inventory or not sd.Inventory.Pet then return nil end

    local data = {
        Normal = 0,
        Golden = 0,
        Rainbow = 0,
        ShinyRainbow = 0,
        Total = 0
    }

    for _, pet in pairs(sd.Inventory.Pet) do
        if pet.id == MONITORED_PET then
            local amount = pet._am or 1
            local pt = pet.pt
            local shiny = pet.sh == true

            if shiny and pt == 2 then
                data.ShinyRainbow += amount
            elseif pt == 2 then
                data.Rainbow += amount
            elseif pt == 1 then
                data.Golden += amount
            else
                data.Normal += amount
            end

            data.Total += amount
        end
    end

    return data
end

local function calcRate(currentTotal)
    local elapsed = os.time() - sessionStart
    if elapsed <= 0 then return 0 end

    local gained = currentTotal - lastTotal
    local perHour = (gained / elapsed) * 3600
    return math.floor(perHour * 100) / 100
end

local function sendWebhook(stats)
    if WEBHOOK_URL == "" then return end

    local elapsed = os.time() - sessionStart
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)

    local rate = calcRate(stats.Total)

    local payload = {
        embeds = {{
            title = "🎄 Krampus Monitor",
            color = 0x8B0000,
            fields = {
                {
                    name = "🐾 Inventory",
                    value =
                        "**Normal:** "..stats.Normal..
                        "\n**Golden:** "..stats.Golden..
                        "\n**Rainbow:** "..stats.Rainbow..
                        "\n**Shiny Rainbow:** "..stats.ShinyRainbow..
                        "\n\n**Total:** "..stats.Total,
                    inline = true
                },
                {
                    name = "📈 Rates",
                    value =
                        "**Gain / Hour:** "..rate..
                        "\n**Session Time:** "..hours.."h "..minutes.."m",
                    inline = true
                },
                {
                    name = "👤 Player",
                    value = plr.Name,
                    inline = true
                },
                {
                    name = "🌍 Server",
                    value = game.JobId,
                    inline = false
                }
            },
            footer = {
                text = "PS99 Advanced Pet Monitor"
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

-- ================= START =================
print("🎄 Krampus Monitor Started")

task.wait(3)

while true do
    local stats = countKrampus()
    if stats then
        if firstRun then
            lastTotal = stats.Total
            firstRun = false
        end

        sendWebhook(stats)
        lastTotal = stats.Total
    end

    task.wait(UPDATE_INTERVAL)
end
