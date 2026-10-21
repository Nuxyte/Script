-- Initialization
local BrainrotsFolder = workspace:WaitForChild("Brainrots")
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
    Name = "Auto Pickup Cosmic Brainrot",
    CurrentValue = false,
    Flag = "AutoPickBrainrot",
    Callback = function(Value)
        Flags.AutoPickBrainrot = Value
        print("Farm toggled: " .. tostring(Value))
    end
})

-- Function to find the Plot
local function getPlot()
    local plotsFolder = workspace:FindFirstChild("Bases")
    if not plotsFolder then return nil end
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local sign = plot:FindFirstChild("Plot sign")
        if sign and sign:FindFirstChild("Name") then
            local label = sign.Name:FindFirstChild("SurfaceGui") and sign.Name.SurfaceGui:FindFirstChild("TextLabel")
            if label and string.find(label.Text, player.Name) then 
                return plot 
            end
        end
    end
    return nil
end

-- Farming loop
task.spawn(function()
    while true do
        if Flags.AutoPickBrainrot then
            local myPlot = getPlot()
            if myPlot then
                local tpPart = myPlot:FindFirstChild("Base Plot") and myPlot["Base Plot"]:FindFirstChild("Part606")
                
                if tpPart then
                    for _, brainrot in ipairs(BrainrotsFolder:GetChildren()) do
                        if not Flags.AutoPickBrainrot then break end
                        
                        -- Check rarity (change "Cosmic" if needed)
                        if brainrot:GetAttribute("BrainrotRarity") == "Cosmic" then
                            local root = brainrot:FindFirstChild("HumanoidRootPart")
                            if root then
                                print("Targeting: " .. brainrot.Name)
                                
                                -- TP to the object
                                rootPart.CFrame = root.CFrame
                                task.wait(0.5) -- Wait increased for stability
                                
                                -- Recursive search for the prompt
                                local prompt = brainrot:FindFirstChild("PickupBrainrot", true)
                                
                                if prompt and prompt:IsA("ProximityPrompt") then
                                    prompt.HoldDuration = 0
                                    fireproximityprompt(prompt)
                                    print("Interaction successful on: " .. brainrot.Name)
                                else
                                    warn("Error: No 'PickupBrainrot' prompt found on " .. brainrot.Name)
                                end
                                
                                -- Return to base
                                rootPart.CFrame = tpPart.CFrame
                                task.wait(0.8) -- Wait increased to avoid anti-cheat
                            end
                        end
                    end
                else
                    warn("Part606 not found in the plot!")
                end
            else
                warn("Player plot not found!")
            end
        end
        task.wait(1)
    end
end)
