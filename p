-- =====================================================
-- 🛡️ ANTI-AFK (SAFE)
-- =====================================================

pcall(function()
    game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
end)

if getconnections then
    for _, v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
        v:Disable()
    end
end

local VirtualUser = game:GetService("VirtualUser")

task.spawn(function()
    while true do
        task.wait(900) -- 15 minutes
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- =====================================================
-- 🎄 XMASWORLD TRAIN OPTIMIZER
-- =====================================================

if not _G.VAR_OPTIMIZE_XMASWORLD then
_G.VAR_OPTIMIZE_XMASWORLD = true

local active = false
local lastOptimize = 0
local REOPT_INTERVAL = 60

local function getTrain()
    local things = workspace:FindFirstChild("__THINGS")
    local inst = things and things:FindFirstChild("__INSTANCE_CONTAINER")
    local activeNode = inst and inst:FindFirstChild("Active")
    local xmas = activeNode and activeNode:FindFirstChild("XmasWorld")
    local interact = xmas and xmas:FindFirstChild("INTERACT")
    return interact and interact:FindFirstChild("Train")
end

local function optimizeTrain(train)
    local FAR_CFRAME = CFrame.new(0, -1e6, 0)

    for _, obj in ipairs(train:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 1
            obj.Transparency = 1
            obj.CanCollide = false
            obj.CanTouch = false
            obj.CanQuery = false
            obj.CastShadow = false
            obj.CFrame = FAR_CFRAME

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1

        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire") then
            obj.Enabled = false

        elseif obj:IsA("PointLight")
            or obj:IsA("SurfaceLight")
            or obj:IsA("SpotLight") then
            obj.Enabled = false
        end
    end

    for _, m in ipairs(train:GetChildren()) do
        if m:IsA("Model") then
            pcall(function()
                m:PivotTo(FAR_CFRAME)
            end)
        end
    end
end

task.spawn(function()
    while true do
        local train = getTrain()
        if train then
            local now = os.clock()
            if not active or (now - lastOptimize >= REOPT_INTERVAL) then
                active = true
                lastOptimize = now
                optimizeTrain(train)
            end
        else
            active = false
        end
        task.wait(1)
    end
end)

end

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
local UPDATE_INTERVAL = 600
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
    return math.floor(((gained / elapsed) * 3600) * 100) / 100
end

local function sendWebhook(stats)
    if WEBHOOK_URL == "" then return end

    local elapsed = os.time() - sessionStart
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)

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
                        "**Gain / Hour:** "..calcRate(stats.Total)..
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
            footer = { text = "PS99 Advanced Pet Monitor" },
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
print("🎄 Krampus Monitor Started (Anti-AFK + Optimized)")

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
