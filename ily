-- =====================================================
-- PS99 ADVANCED STATS HUD - ULTIMATE EDITION
-- =====================================================

repeat task.wait() until game:IsLoaded()

-- ================= SERVICES =================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
repeat task.wait() until player
repeat task.wait() until not player.PlayerGui:FindFirstChild("__INTRO")

local PlayerSave = require(ReplicatedStorage.Library.Client.Save)

-- Remove old GUI
pcall(function()
    CoreGui:FindFirstChild("AdvancedStatsHUD"):Destroy()
end)

-- ================= CONFIG =================
local CONFIG = {
    PrimaryColor = Color3.fromRGB(138, 43, 226),      -- Purple
    SecondaryColor = Color3.fromRGB(75, 0, 130),      -- Indigo
    AccentColor = Color3.fromRGB(255, 20, 147),       -- Pink
    BackgroundColor = Color3.fromRGB(15, 15, 20),     -- Dark
    TextColor = Color3.fromRGB(255, 255, 255),        -- White
    GlowColor = Color3.fromRGB(138, 43, 226),         -- Purple glow
    UpdateInterval = 0.5,                              -- Update every 0.5s
    AnimationSpeed = 0.3
}

-- ================= GUI CREATION =================
local gui = Instance.new("ScreenGui")
gui.Name = "AdvancedStatsHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Main Background Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(600, 550)
mainFrame.BackgroundColor3 = CONFIG.BackgroundColor
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

-- Gradient Background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.SecondaryColor),
    ColorSequenceKeypoint.new(0.5, CONFIG.BackgroundColor),
    ColorSequenceKeypoint.new(1, CONFIG.SecondaryColor)
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Animated Border Glow
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.fromScale(0.5, 0.5)
glow.Size = UDim2.fromScale(1.05, 1.05)
glow.BackgroundTransparency = 1
glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
glow.ImageColor3 = CONFIG.GlowColor
glow.ImageTransparency = 0.7
glow.ZIndex = 0
glow.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 22)
glowCorner.Parent = glow

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = CONFIG.PrimaryColor
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 20)
topBarCorner.Parent = topBar

-- Title with gradient
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.fromOffset(20, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "⚡ ADVANCED STATS ⚡"
title.TextSize = 28
title.TextColor3 = CONFIG.TextColor
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
titleGradient.Parent = title

-- Content Container
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "Content"
contentFrame.Position = UDim2.fromOffset(0, 70)
contentFrame.Size = UDim2.new(1, 0, 1, -130)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.ScrollBarImageColor3 = CONFIG.PrimaryColor
contentFrame.CanvasSize = UDim2.fromOffset(0, 0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 15)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 20)
contentPadding.PaddingRight = UDim.new(0, 20)
contentPadding.Parent = contentFrame

-- ================= STAT CARD CREATOR =================
local function createStatCard(iconEmoji, mainText, subText, accentColor)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -40, 0, 90)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    card.BorderSizePixel = 0
    card.Parent = contentFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 12)
    cardCorner.Parent = card
    
    -- Card gradient
    local cardGradient = Instance.new("UIGradient")
    cardGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    cardGradient.Rotation = 90
    cardGradient.Parent = card
    
    -- Left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 5, 1, 0)
    accentBar.BackgroundColor3 = accentColor or CONFIG.AccentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = card
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 12)
    accentCorner.Parent = accentBar
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Position = UDim2.fromOffset(20, 0)
    icon.Size = UDim2.fromOffset(50, 90)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.Text = iconEmoji
    icon.TextSize = 32
    icon.TextColor3 = CONFIG.TextColor
    icon.Parent = card
    
    -- Main text
    local main = Instance.new("TextLabel")
    main.Position = UDim2.fromOffset(80, 15)
    main.Size = UDim2.new(1, -90, 0, 30)
    main.BackgroundTransparency = 1
    main.Font = Enum.Font.GothamBold
    main.Text = mainText
    main.TextSize = 24
    main.TextColor3 = CONFIG.TextColor
    main.TextXAlignment = Enum.TextXAlignment.Left
    main.Parent = card
    
    -- Sub text
    local sub = Instance.new("TextLabel")
    sub.Position = UDim2.fromOffset(80, 50)
    sub.Size = UDim2.new(1, -90, 0, 25)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = subText
    sub.TextSize = 16
    sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = card
    
    return card, main, sub
end

-- ================= CREATE STAT CARDS =================
-- Player Info
local playerCard, playerMain, playerSub = createStatCard(
    "👤", 
    "PLAYER: " .. player.Name, 
    "Session Active",
    Color3.fromRGB(0, 200, 255)
)

-- Diamonds
local diamondCard, diamondMain, diamondSub = createStatCard(
    "💎", 
    "Diamonds: Loading...", 
    "Rate: Calculating...",
    Color3.fromRGB(0, 255, 255)
)

-- Eggs Hatched
local eggCard, eggMain, eggSub = createStatCard(
    "🥚", 
    "Eggs Hatched: 0", 
    "Rate: +0 / min",
    Color3.fromRGB(255, 200, 0)
)

-- Merry Mule
local muleCard, muleMain, muleSub = createStatCard(
    "🐴", 
    "Merry Mule: Loading...", 
    "G:0  R:0  S:0",
    Color3.fromRGB(255, 100, 200)
)

-- Session Time
local timeCard, timeMain, timeSub = createStatCard(
    "⏱", 
    "Session Time: 00:00:00", 
    "Started: " .. os.date("%H:%M:%S"),
    Color3.fromRGB(150, 255, 150)
)

-- Performance Stats
local perfCard, perfMain, perfSub = createStatCard(
    "⚙️", 
    "Performance", 
    "FPS: 60 | Ping: 0ms",
    Color3.fromRGB(255, 150, 0)
)

-- ================= BUTTONS =================
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "Buttons"
buttonContainer.Position = UDim2.new(0, 0, 1, -60)
buttonContainer.Size = UDim2.new(1, 0, 0, 60)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.FillDirection = Enum.FillDirection.Horizontal
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
buttonLayout.Padding = UDim.new(0, 15)
buttonLayout.Parent = buttonContainer

local function createButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(180, 40)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 16
    btn.TextColor3 = CONFIG.TextColor
    btn.AutoButtonColor = false
    btn.Parent = buttonContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, color.R * 255 * 1.2),
                math.min(255, color.G * 255 * 1.2),
                math.min(255, color.B * 255 * 1.2)
            )
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

local minimizeBtn = createButton("MINIMIZE", Color3.fromRGB(255, 165, 0), function()
    mainFrame.Visible = false
    openButton.Visible = true
end)

local closeBtn = createButton("CLOSE", Color3.fromRGB(220, 20, 60), function()
    gui:Destroy()
end)

-- Open button (floating)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.fromOffset(180, 50)
openButton.Position = UDim2.new(0.5, -90, 0.1, 0)
openButton.BackgroundColor3 = CONFIG.PrimaryColor
openButton.BorderSizePixel = 0
openButton.Font = Enum.Font.GothamBold
openButton.Text = "📊 OPEN STATS"
openButton.TextSize = 18
openButton.TextColor3 = CONFIG.TextColor
openButton.Visible = false
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openButton

openButton.MouseButton1Click:Connect(function()
    openButton.Visible = false
    mainFrame.Visible = true
end)

-- ================= HELPER FUNCTIONS =================
local function fmt(n)
    if n >= 1e12 then return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n/1e3)
    end
    return tostring(math.floor(n))
end

local function fmtTime(t)
    local hours = math.floor(t / 3600)
    local mins = math.floor((t % 3600) / 60)
    local secs = math.floor(t % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- ================= DATA FUNCTIONS =================
local sessionStartEggs = nil
local initializing = true

local function getEggsHatched()
    local ok, data = pcall(function()
        return PlayerSave.Get()
    end)
    if not ok or type(data) ~= "table" then
        return nil
    end
    return tonumber(data.EggsHatched) or 0
end

task.spawn(function()
    task.wait(2)
    sessionStartEggs = getEggsHatched()
    if sessionStartEggs then
        initializing = false
    end
end)

local function getSessionEggs()
    if initializing or not sessionStartEggs then
        return 0
    end
    local current = getEggsHatched()
    if not current then
        return 0
    end
    return math.max(0, current - sessionStartEggs)
end

local function countMerryMule()
    local ok, sd = pcall(function()
        return PlayerSave.Get()
    end)
    if not ok or not sd then return nil end
    
    local counts = {
        Normal = 0,
        Golden = 0,
        Rainbow = 0,
        ShinyRainbow = 0,
        Total = 0
    }
    
    if sd.Inventory and sd.Inventory.Pet then
        for uid, pet in pairs(sd.Inventory.Pet) do
            if pet.id == "Merry Mule" then
                local amount = pet._am or 1
                local pt = pet.pt
                local sh = pet.sh == true
                
                if sh and pt == 2 then
                    counts.ShinyRainbow = counts.ShinyRainbow + amount
                elseif pt == 2 then
                    counts.Rainbow = counts.Rainbow + amount
                elseif pt == 1 then
                    counts.Golden = counts.Golden + amount
                else
                    counts.Normal = counts.Normal + amount
                end
                
                counts.Total = counts.Total + amount
            end
        end
    end
    
    return counts
end

-- ================= DIAMONDS TRACKING =================
local diamondsStat
task.spawn(function()
    local ls = player:WaitForChild("leaderstats")
    diamondsStat = ls:FindFirstChild("💎 Diamonds") or ls:FindFirstChild("\240\159\146\142 Diamonds")
end)

-- ================= STATS TRACKING =================
local startTime = os.clock()
local lastDiamonds = 0
local lastDiamondCheck = os.clock()
local diamondRate = 0

local lastEggs = 0
local lastEggCheck = os.clock()
local eggRate = 0

local lastUpdate = os.clock()

-- ================= ANIMATIONS =================
-- Pulsing glow animation
task.spawn(function()
    while task.wait(0.05) do
        local pulse = math.sin(tick() * 2) * 0.15 + 0.85
        glow.ImageTransparency = 0.7 + (pulse * 0.2)
    end
end)

-- Gradient rotation
task.spawn(function()
    while task.wait(0.1) do
        gradient.Rotation = (gradient.Rotation + 1) % 360
    end
end)

-- ================= MAIN UPDATE LOOP =================
RunService.RenderStepped:Connect(function()
    if not mainFrame.Visible then return end
    
    local now = os.clock()
    
    -- Update session time
    local sessionTime = now - startTime
    timeMain.Text = "Session Time: " .. fmtTime(sessionTime)
    
    -- Update diamonds
    if diamondsStat then
        local d = diamondsStat.Value
        diamondMain.Text = "💎 Diamonds: " .. fmt(d)
        
        if now - lastDiamondCheck >= 5 then
            diamondRate = (d - lastDiamonds) / ((now - lastDiamondCheck) / 60)
            lastDiamonds = d
            lastDiamondCheck = now
        end
        
        diamondSub.Text = "Rate: +" .. fmt(math.max(diamondRate, 0)) .. " / min"
    end
    
    -- Update eggs
    local currentEggs = getSessionEggs()
    eggMain.Text = "🥚 Eggs Hatched: " .. fmt(currentEggs)
    
    if now - lastEggCheck >= 5 then
        eggRate = (currentEggs - lastEggs) / ((now - lastEggCheck) / 60)
        lastEggs = currentEggs
        lastEggCheck = now
    end
    
    eggSub.Text = "Rate: +" .. fmt(math.max(eggRate, 0)) .. " / min"
    
    -- Update merry mule (less frequent)
    if now - lastUpdate >= CONFIG.UpdateInterval then
        local muleCounts = countMerryMule()
        if muleCounts then
            muleMain.Text = "🐴 Merry Mule: " .. fmt(muleCounts.Total)
            muleSub.Text = string.format(
                "G:%s  R:%s  S:%s",
                fmt(muleCounts.Golden),
                fmt(muleCounts.Rainbow),
                fmt(muleCounts.ShinyRainbow)
            )
        end
        
        lastUpdate = now
    end
    
    -- Update performance stats
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.floor(player:GetNetworkPing() * 1000)
    perfSub.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
end)

print("✅ ADVANCED STATS HUD LOADED - ULTIMATE EDITION")
print("🎨 Features: Animations, Gradients, Real-time Tracking")
print("⚡ Press MINIMIZE to hide | CLOSE to remove")
