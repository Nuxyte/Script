local brainrotFolder = workspace:WaitForChild("Brainrots")
local ZoneFolder = workspace.Zones
local baseFolder = workspace:WaitForChild("Bases")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Loading Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Brainrot Automation Panel",
    LoadingTitle = "Loading Farmer...",
    LoadingSubtitle = "by 0x",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Farmer", nil)

-- Global Flag
getgenv().Flags = { AutoPickBrainrot = false }

MainTab:CreateToggle({
    Name = "Auto Pickup Brainrot (Ancient)",
    CurrentValue = false,
    Flag = "AutoPickBrainrot",
    Callback = function(Value)
        Flags.AutoPickBrainrot = Value
        print("Farm toggled: " .. tostring(Value))
    end
})

MainTab:CreateToggle({
    Name = "Auto Farm Money (Ancient)",
    CurrentValue = false,
    Flag = "AutoCollectMoney",
    Callback = function(Value)
        Flags.AutoCollectMoney = Value
        print("Farm toggled: " .. tostring(Value))
    end
})

-- 1. Helper function to find and RETURN the plot
local function getPlot()
    if not baseFolder then return nil end
    for _, plot in ipairs(baseFolder:GetChildren()) do
        local sign = plot:FindFirstChild("Sign")
        local playerInfo = sign and sign:FindFirstChild("PlayerInfo")
        local surfaceGui = playerInfo and playerInfo:FindFirstChild("SurfaceGui")
        local playerNameLabel = surfaceGui and surfaceGui:FindFirstChild("PlayerName")

        if playerNameLabel and string.find(playerNameLabel.Text, player.Name) then
            return plot
        end
    end
    return nil
end

-- 2. Teleport to the zone
local BestZoneCFrame = ZoneFolder.Locations.AncientFloorBest.CFrame
task.wait(1) -- Give the game a moment to load the objects

-- 3. Loop through brainrots correctly using :GetChildren()
local myPlot = getPlot() -- Get the plot reference to use later
local targetPart = myPlot.OwnerSpawn


-- Farming Loop
task.spawn(function()
    while true do
        if Flags.AutoPickBrainrot then
            local myPlot = getPlot()
            
            -- Ensure we found the plot and the target before looping
            if myPlot and myPlot:FindFirstChild("OwnerSpawn") then
                local targetPart = myPlot.OwnerSpawn
                
                for _, brainrot in ipairs(brainrotFolder:GetChildren()) do
                    -- Check if we are still toggled ON
                    if not Flags.AutoPickBrainrot then break end
                    
                    -- Check attributes
                    if brainrot:GetAttribute("Rarity") == "Ancient" and brainrot:GetAttribute("ZoneIndex") == 22 then
                        local HRP = brainrot:FindFirstChild("HumanoidRootPart")
                        local attachment = HRP and HRP:FindFirstChild("StealPromptAttachment")
                        local prompt = attachment and attachment:FindFirstChild("ProximityPrompt")
                        
                        if HRP and prompt then
                            -- Teleport to Brainrot
                            rootPart.CFrame = HRP.CFrame
                            task.wait(0.4) 
                            
                            -- Interaction
                            prompt.HoldDuration = 0
                            fireproximityprompt(prompt)
                            task.wait(0.2)
                            
                            -- Return to base
                            rootPart.CFrame = targetPart.CFrame
                            task.wait(0.5)
                        end
                    end
                end
            end
        end

        if Flags.AutoCollectMoney then
            local myPlot = getPlot()

            if myPlot and myPlot:FindFirstChild("Slots") then
                for _, slotFolder in ipairs(myPlot.Slots:GetChildren()) do
                    if not Flags.AutoCollectMoney then break end
                    
                    local collectZone = slotFolder:FindFirstChild("Collect")
                    
                    if collectZone then
                        rootPart.CFrame = collectZone.CFrame
                        
                        task.wait(1) 
                    end
                end
            end
        end
        task.wait(0.5) -- Prevents lag
    end
end)
