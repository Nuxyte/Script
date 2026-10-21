local brainrotsFolder = workspace:FindFirstChild("Brainrots")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")


local function getPlot()
    local plotsFolder = workspace:FindFirstChild("Bases")
    if not plotsFolder then warn("Error: can't find plots Folder") return nil end
    
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local sign = plot:FindFirstChild("Sign")
        if sign then
            local display = sign:FindFirstChild("Display")
            local gui = display and display:FindFirstChild("BaseDisplayGui")
            local frame = gui and gui:FindFirstChild("Frame")
            local info = frame and frame:FindFirstChild("Info")
            local nameLabel = info and info:FindFirstChild("PlayerName")
            
            if nameLabel and string.find(nameLabel.Text, player.DisplayName) then 
                return plot 
            end
        end
    end
    return nil
end

if brainrotsFolder then
    for _, brainrot in ipairs(brainrotsFolder:GetChildren()) do
        local zoneValue = brainrot:GetAttribute("Zone")
        
        if zoneValue == 8 or zoneValue == 7 then
            
            local meshFinded = nil
            for _, descendant in ipairs(brainrot:GetDescendants()) do
                if descendant:IsA("MeshPart") then
                    meshFinded = descendant
                    break
                end
            end

            if meshFinded then
                rootPart.CFrame = meshFinded.CFrame
                task.wait(0.3) 

                local prompt = meshFinded:FindFirstChild("PickupPrompt")
                if prompt and prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt) 
                end
            end

           
            task.wait(0.5) 
            local plot = getPlot()
            if plot then
                local floor1 = plot:FindFirstChild("Floor1")
                local floorPart = floor1 and floor1:FindFirstChild("Floor")
                
                if floorPart and floorPart:IsA("BasePart") then
                    rootPart.CFrame = floorPart.CFrame
                end
            end
            
            task.wait(0.5)
        end
    end
end
