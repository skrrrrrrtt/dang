--[[
    Christmas Egg Hatcher - FINAL WORKING VERSION
    Uses exact format: "Egg Name", amount
]]--

repeat task.wait() until game:IsLoaded()

-- Services
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Network = ReplicatedStorage.Network

-- ⚙️ CONFIGURATION - Change these as needed
local CONFIG = {
    HATCH_AMOUNT = 36,  -- Change to 3 or 8 for multiple eggs
    WAIT_TIME = 1,     -- Seconds between hatches
    
    -- Christmas egg names (these rotate)
    EGGS = {
        "Candy Cane Egg",
        "Icy Egg",
        "Pine Tree Egg"
    }
}

print("="..string.rep("=", 60))
print("🎄 Christmas Egg Hatcher - FINAL VERSION 🎄")
print("="..string.rep("=", 60))
print("\n📋 Settings:")
print("  • Hatch Amount:", CONFIG.HATCH_AMOUNT)
print("  • Wait Time:", CONFIG.WAIT_TIME, "seconds")
print("\n🥚 Eggs to hatch:")
for i, egg in ipairs(CONFIG.EGGS) do
    print(string.format("  %d. %s", i, egg))
end
print("\n"..string.rep("=", 60))
print("🚀 Starting hatcher...\n")

-- Helper function to click and skip animation
local function clickPosition(x, y)
    VirtualUser:Button1Down(Vector2.new(x, y))
    VirtualUser:Button1Up(Vector2.new(x, y))
end

-- Main hatching function
local function hatchEgg(eggName, amount)
    print(string.format("[HATCH] Attempting: %s (x%d)", eggName, amount))
    
    -- Invoke the server using EXACT format
    local args = {
        [1] = eggName,
        [2] = amount
    }
    
    local success, result = pcall(function()
        return Network.Eggs_RequestPurchase:InvokeServer(unpack(args))
    end)
    
    if not success then
        warn("[ERROR] Failed to invoke:", result)
        return false
    end
    
    print("[OK] Request sent successfully")
    
    -- Wait a moment for eggs to appear
    task.wait(0.4)
    
    -- Wait for egg animation
    local foundEggs = false
    local waitStart = tick()
    
    while tick() - waitStart < 5 do
        if Workspace.Camera:FindFirstChild("Eggs") then
            foundEggs = true
            print("[SKIP] Eggs detected! Clicking to skip animation...")
            break
        end
        task.wait(0.1)
    end
    
    -- Click to skip the animation
    if foundEggs then
        repeat
            task.wait()
            clickPosition(math.huge, math.huge)
        until not Workspace.Camera:FindFirstChild("Eggs")
        
        print("[SUCCESS] ✅ Hatched successfully!\n")
        task.wait(0.75)
        return true
    else
        warn("[FAIL] ❌ Eggs didn't appear - egg may not be active right now\n")
        return false
    end
end

-- Main loop
local currentIndex = 1
local totalHatches = 0
local consecutiveFails = 0

while task.wait(CONFIG.WAIT_TIME) do
    -- Safety check
    if not LocalPlayer or not LocalPlayer.Character then
        warn("⚠️ Player disconnected, stopping...")
        break
    end
    
    -- Get current egg
    local currentEgg = CONFIG.EGGS[currentIndex]
    
    -- Try to hatch
    local success = hatchEgg(currentEgg, CONFIG.HATCH_AMOUNT)
    
    if success then
        totalHatches = totalHatches + 1
        consecutiveFails = 0
        print(string.format("📊 Total Successful Hatches: %d\n", totalHatches))
        
        -- Move to next egg after success
        currentIndex = currentIndex % #CONFIG.EGGS + 1
    else
        consecutiveFails = consecutiveFails + 1
        
        -- After 3 fails on same egg, try next one
        if consecutiveFails >= 3 then
            warn(string.format("[CYCLE] Failed %d times, trying next egg...\n", consecutiveFails))
            consecutiveFails = 0
            currentIndex = currentIndex % #CONFIG.EGGS + 1
            task.wait(2) -- Extra wait when cycling
        end
    end
end

print("\n"..string.rep("=", 60))
print("🎄 Hatcher Stopped 🎄")
print(string.format("📊 Total Successful Hatches: %d", totalHatches))
print(string.rep("=", 60))
