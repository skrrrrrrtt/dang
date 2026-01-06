-- PS99 ADVANCED STATS OVERLAY (REAL FIX)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===== PS99 PLAYER DATA =====
local PlayerDataModule =
    ReplicatedStorage:WaitForChild("Library")
    :WaitForChild("Client")
    :WaitForChild("PlayerData")

local PlayerData = require(PlayerDataModule)

-- ===== REMOVE OLD =====
pcall(function()
    CoreGui:FindFirstChild("StatsOverlay"):Destroy()
end)

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "StatsOverlay"
gui.IgnoreGuiInset = true -- 🔥 FULL SCREEN FIX
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1,1)
bg.Position = UDim2.fromScale(0,0)
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0
bg.Parent = gui

-- ===== CONTAINER =====
local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0.5,0.5)
container.Position = UDim2.fromScale(0.5,0.5)
container.Size = UDim2.fromOffset(450,320)
container.BackgroundTransparency = 1
container.Parent = bg

-- ===== TITLE =====
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "STATS OVERLAY"
title.Font = Enum.Font.GothamBold
title.TextSize = 34
title.TextColor3 = Color3.new(1,1,1)
title.Parent = container

-- ===== PLAYER =====
local playerLabel = Instance.new("TextLabel")
playerLabel.Position = UDim2.fromOffset(0,80)
playerLabel.Size = UDim2.new(1,0,0,30)
playerLabel.BackgroundTransparency = 1
playerLabel.Text = lp.Name
playerLabel.Font = Enum.Font.GothamBold
playerLabel.TextSize = 24
playerLabel.TextColor3 = Color3.fromRGB(0,255,127)
playerLabel.Parent = container

-- ===== DIAMONDS =====
local diamondsLabel = Instance.new("TextLabel")
diamondsLabel.Position = UDim2.fromOffset(0,150)
diamondsLabel.Size = UDim2.new(1,0,0,30)
diamondsLabel.BackgroundTransparency = 1
diamondsLabel.Text = "Diamonds: 0"
diamondsLabel.Font = Enum.Font.GothamBold
diamondsLabel.TextSize = 24
diamondsLabel.TextColor3 = Color3.fromRGB(0,191,255)
diamondsLabel.Parent = container

-- ===== TIMER =====
local timerLabel = Instance.new("TextLabel")
timerLabel.Position = UDim2.fromOffset(0,210)
timerLabel.Size = UDim2.new(1,0,0,40)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "00:00:00"
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextSize = 28
timerLabel.TextColor3 = Color3.fromRGB(255,215,0)
timerLabel.Parent = container

-- ===== CLOSE BUTTON =====
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(150,40)
closeBtn.Position = UDim2.fromScale(0.5,1)
closeBtn.AnchorPoint = Vector2.new(0.5,1)
closeBtn.Text = "CLOSE"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BackgroundColor3 = Color3.fromRGB(220,20,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = container
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

-- ===== STATE =====
local visible = true
local start = os.clock()

local function setVisible(v)
    visible = v
    bg.Visible = v
end

closeBtn.MouseButton1Click:Connect(function()
    setVisible(false)
end)

-- ===== FORMAT =====
local function fmt(n)
    if n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n/1e3)
    end
    return tostring(math.floor(n))
end

-- ===== UPDATE LOOP =====
RunService.RenderStepped:Connect(function()
    if not visible then return end

    local save = PlayerData.Get()
    local diamonds = save and save.Currency and save.Currency.Diamonds or 0

    diamondsLabel.Text = "Diamonds: "..fmt(diamonds)
    timerLabel.Text = string.format(
        "%02d:%02d:%02d",
        math.floor((os.clock()-start)/3600),
        math.floor((os.clock()-start)%3600/60),
        math.floor((os.clock()-start)%60)
    )
end)

-- ===== GLOBAL CONTROL =====
getgenv().StatsOverlay = {
    open = function() setVisible(true) end,
    close = function() setVisible(false) end,
    toggle = function() setVisible(not visible) end,
    destroy = function() gui:Destroy() end
}

print("✅ PS99 STATS OVERLAY LOADED")
print("Commands:")
print("StatsOverlay.open()")
print("StatsOverlay.toggle()")
