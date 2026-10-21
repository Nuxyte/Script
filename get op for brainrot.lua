-- /!\ IMPORT POUR GUI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- /!\ PLAYER IMPORT
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- /!\ VARIABLES
local AutoFarm           = false
local AutoFarmMoney      = false
local AutoRebirth        = false
local AutoUpgradeBrainrot = false
local AutoBuy            = false
local HowManyBuy         = 1
local selectedType       = nil
local ChoosenZone        = nil
local BrainrotFolder     = workspace:FindFirstChild("BrainrotModels")
local cycleCount         = 0

-- ─── ZONES (triées Poor → Best dans l'ordre de rareté) ───────────────────────
-- L'ordre du tableau est respecté grâce à zoneNames défini manuellement
local Zone = {
    ["Common"]           = { ObjectName = "A1",  RarityName = "Common" },
    ["Best Common"]      = { ObjectName = "A2",  RarityName = "Common" },
    ["Uncommon"]         = { ObjectName = "A3",  RarityName = "Uncommon" },
    ["Best Uncommon"]    = { ObjectName = "A4",  RarityName = "Uncommon" },
    ["Rare"]             = { ObjectName = "A5",  RarityName = "Rare" },
    ["Best Rare"]        = { ObjectName = "A6",  RarityName = "Rare" },
    ["Epic"]             = { ObjectName = "A7",  RarityName = "Epic" },
    ["Best Epic"]        = { ObjectName = "A8",  RarityName = "Epic" },
    ["Legendary"]        = { ObjectName = "A9",  RarityName = "Legendary" },
    ["Best Legendary"]   = { ObjectName = "A10", RarityName = "Legendary" },
    ["Mythic"]           = { ObjectName = "A11", RarityName = "Mythic" },
    ["Best Mythic"]      = { ObjectName = "A13", RarityName = "Mythic" },
    ["Cosmic"]           = { ObjectName = "A14", RarityName = "Cosmic" },
    ["Best Cosmic"]      = { ObjectName = "A15", RarityName = "Cosmic" },
    ["Secret"]           = { ObjectName = "A16", RarityName = "Secret" },
    ["Best Secret"]      = { ObjectName = "A17", RarityName = "Secret" },
    ["Divine"]           = { ObjectName = "A18", RarityName = "Divine" },
    ["Best Divine"]      = { ObjectName = "A19", RarityName = "Divine" },
    ["OG"]               = { ObjectName = "A20", RarityName = "OG" },
    ["Best OG"]          = { ObjectName = "A21", RarityName = "OG" },
    ["Celestial"]        = { ObjectName = "A22", RarityName = "Celestial" },
    ["Best Celestial"]   = { ObjectName = "A23", RarityName = "Celestial" },
    ["Ethereal"]         = { ObjectName = "A24", RarityName = "Ethereal" },
    ["Best Ethereal"]    = { ObjectName = "A25", RarityName = "Ethereal" },
    ["Ancient"]          = { ObjectName = "A26", RarityName = "Ancient" },
    ["Best Ancient"]     = { ObjectName = "A27", RarityName = "Ancient" },
}

-- Ordre manuel : Poor → Best, du plus faible au plus rare
local zoneNames = {
    "Common", "Best Common",
    "Uncommon", "Best Uncommon",
    "Rare", "Best Rare",
    "Epic", "Best Epic",
    "Legendary", "Best Legendary",
    "Mythic", "Best Mythic",
    "Cosmic", "Best Cosmic",
    "Secret", "Best Secret",
    "Divine", "Best Divine",
    "OG", "Best OG",
    "Celestial", "Best Celestial",
    "Ethereal", "Best Ethereal",
    "Ancient", "Best Ancient",
}

local Type = { ["Speed"] = "speed", ["Power"] = "power" }
local typeNames = { "Speed", "Power" }

-- ─── WINDOW ──────────────────────────────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title = "AutoFarm",
    SubTitle = "by Ox",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm    = Window:AddTab({ Title = "🌾 Farm",    Icon = "" }),
    Misc    = Window:AddTab({ Title = "⚙️ Misc",    Icon = "" }),
    TP      = Window:AddTab({ Title = "🔀 TP",      Icon = "" }),
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function notify(title, content, duration)
    Fluent:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

local function getBase()
    local b = workspace:FindFirstChild("Bases")
    if not b then return nil end
    return b:FindFirstChild(player.Name)
end

local function rarityMatches(rarityText, targetRarity)
    local extracted = rarityText:match("^(.-)%s*%(") or rarityText:match("^%s*(.-)%s*$")
    return string.lower(extracted) == string.lower(targetRarity)
end

-- ─── TAB : 🌾 FARM ────────────────────────────────────────────────────────────

Tabs.Farm:AddParagraph({ Title = "Auto Farm Brainrot", Content = "TP automatiquement vers les brainrots de la zone choisie et fire le prompt." })

Tabs.Farm:AddDropdown("ZoneSelector", {
    Title = "Zone cible",
    Description = "Choisir du plus faible au plus rare",
    Values = zoneNames,
    Multi = false,
    Callback = function(selectedName)
        ChoosenZone = selectedName
        local zoneData = Zone[selectedName]
        notify("Zone sélectionnée", selectedName .. " → " .. zoneData.ObjectName)
        print("[AutoFarm] Zone :", selectedName, "| Object :", zoneData.ObjectName, "| Rarity :", zoneData.RarityName)
    end
})

Tabs.Farm:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Brainrot",
    Description = "Active le farm automatique dans la zone choisie",
    Default = false,
    Callback = function(Value)
        AutoFarm = Value
        if Value and not ChoosenZone then
            notify("⚠️ Attention", "Aucune zone sélectionnée !", 4)
        end
        notify(Value and "✅ AutoFarm ON" or "🛑 AutoFarm OFF", Value and ("Zone : " .. (ChoosenZone or "?")) or "Farm arrêté")
        print("[AutoFarm] Toggle →", Value and "ON" or "OFF")
    end
})

Tabs.Farm:AddParagraph({ Title = "Auto Farm Money", Content = "Appuie automatiquement sur les boutons de ta base pour collecter l'argent." })

Tabs.Farm:AddToggle("AutoFarmMoneyToggle", {
    Title = "Auto Farm Money",
    Default = false,
    Callback = function(Value)
        AutoFarmMoney = Value
        notify(Value and "✅ AutoFarm Money ON" or "🛑 AutoFarm Money OFF", Value and "Collecte en cours..." or "Collecte arrêtée")
    end
})

-- ─── TAB : ⚙️ MISC ────────────────────────────────────────────────────────────

Tabs.Misc:AddParagraph({ Title = "Auto Rebirth", Content = "Fire le remote de rebirth automatiquement." })

Tabs.Misc:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(Value)
        AutoRebirth = Value
        notify(Value and "✅ Auto Rebirth ON" or "🛑 Auto Rebirth OFF", Value and "Rebirth automatique activé" or "Rebirth arrêté")
    end
})

Tabs.Misc:AddParagraph({ Title = "Auto Upgrade Brainrot", Content = "Upgrade automatiquement tous les stands de ta base." })

Tabs.Misc:AddToggle("AutoUpgradeBrainrotToggle", {
    Title = "Auto Upgrade Brainrot",
    Default = false,
    Callback = function(Value)
        AutoUpgradeBrainrot = Value
        notify(Value and "✅ Auto Upgrade ON" or "🛑 Auto Upgrade OFF", Value and "Upgrade automatique activé" or "Upgrade arrêté")
    end
})

Tabs.Misc:AddParagraph({ Title = "Auto Buy Speed / Power", Content = "Achète automatiquement le type et la quantité choisis." })

Tabs.Misc:AddDropdown("TypePurchase", {
    Title = "Type d'achat",
    Description = "Speed ou Power",
    Values = typeNames,
    Multi = false,
    Callback = function(value)
        selectedType = Type[value]
        notify("Type sélectionné", value .. " → remote : " .. selectedType)
        print("[AutoBuy] Type :", selectedType)
    end
})

Tabs.Misc:AddInput("AmountInput", {
    Title = "Quantité",
    Description = "Nombre de Speed / Power à acheter par cycle",
    Default = "1",
    Placeholder = "ex: 10",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        HowManyBuy = tonumber(Value) or 1
        print("[AutoBuy] Quantité :", HowManyBuy)
    end
})

Tabs.Misc:AddToggle("AutoBuyToggle", {
    Title = "Auto Buy",
    Default = false,
    Callback = function(Value)
        AutoBuy = Value
        if Value and not selectedType then
            notify("⚠️ Attention", "Aucun type sélectionné (Speed/Power) !", 4)
        end
        notify(Value and "✅ Auto Buy ON" or "🛑 Auto Buy OFF", Value and (selectedType or "? — sélectionne un type") or "Achat arrêté")
    end
})

-- ─── TAB : 🔀 TP ─────────────────────────────────────────────────────────────

Tabs.TP:AddParagraph({ Title = "Téléportations manuelles", Content = "TP instantané vers ta base ou la zone sélectionnée." })

Tabs.TP:AddButton({
    Title = "TP → Zone sélectionnée",
    Description = "Se téléporte au-dessus de la zone choisie dans le dropdown",
    Callback = function()
        if not ChoosenZone or not Zone[ChoosenZone] then
            notify("❌ Erreur", "Aucune zone sélectionnée !", 4) return
        end
        local zoneData = Zone[ChoosenZone]
        local zoneObject = workspace:FindFirstChild(zoneData.ObjectName, true)
        if not zoneObject then
            notify("❌ Erreur", "Zone introuvable dans le workspace : " .. zoneData.ObjectName, 4) return
        end
        rootPart.CFrame = zoneObject.CFrame + Vector3.new(0, 5, 0)
        notify("✅ TP effectué", "Zone : " .. ChoosenZone)
        print("[TP] → Zone :", ChoosenZone, "(", zoneData.ObjectName, ")")
    end
})

Tabs.TP:AddButton({
    Title = "TP → Ma Base",
    Description = "Se téléporte sur l'UpgradeBase de ta base",
    Callback = function()
        local base = getBase()
        if not base then notify("❌ Erreur", "Base introuvable !", 4) return end
        local upgradeBase = base:FindFirstChild("UpgradeBase")
        if not upgradeBase then notify("❌ Erreur", "UpgradeBase introuvable !", 4) return end
        rootPart.CFrame = upgradeBase.CFrame + Vector3.new(0, 3, 0)
        notify("✅ TP effectué", "Base de " .. player.Name)
        print("[TP] → Base :", player.Name)
    end
})

-- ─── LOGIQUE : AutoFarm Brainrot ─────────────────────────────────────────────
local function farmCycle()
    if not ChoosenZone or not Zone[ChoosenZone] then
        warn("[AutoFarm] Aucune zone sélectionnée")
        return
    end

    local zoneData   = Zone[ChoosenZone]
    local zoneObject = workspace:FindFirstChild(zoneData.ObjectName, true)
    cycleCount += 1

    print(string.format("[AutoFarm] ── Cycle #%d | %s (%s) ──", cycleCount, ChoosenZone, zoneData.ObjectName))

    if not zoneObject then
        warn("[AutoFarm] Zone introuvable : " .. zoneData.ObjectName)
        return
    end

    rootPart.CFrame = zoneObject.CFrame + Vector3.new(0, 5, 0)
    task.wait(1.5)

    local totalScanned, totalMatched, totalTped, totalSkipped = 0, 0, 0, 0

    for _, v in ipairs(BrainrotFolder:GetChildren()) do
        if not AutoFarm then print("[AutoFarm] Toggle coupé, arrêt du scan") break end
        if v.Name:match("%a") then continue end  -- Skip si nom contient une lettre

        totalScanned += 1

        local billboard = v:FindFirstChild("BrainrotBillboard")
        if not billboard then totalSkipped += 1 continue end
        local infoFrame = billboard:FindFirstChild("Info")
        if not infoFrame then totalSkipped += 1 continue end
        local rarityLabel = infoFrame:FindFirstChild("Rarity")
        if not rarityLabel then totalSkipped += 1 continue end
        local rarityText = rarityLabel.Text
        if not rarityText or rarityText == "" then totalSkipped += 1 continue end

        if rarityMatches(rarityText, zoneData.RarityName) then
            totalMatched += 1

            local part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
            if not part then
                warn(string.format("[AutoFarm] Aucune BasePart sur %s", v.Name))
                continue
            end

            totalTped += 1
            rootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
            print(string.format("[AutoFarm] ✓ TP → %s | '%s' | part : %s", v.Name, rarityText, part.Name))

            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.HoldDuration = 0
                task.wait(0.2)
                fireproximityprompt(prompt)

                -- TP retour à la base après avoir fire le prompt
                local base = getBase()
                if base then
                    local upgradeBase = base:FindFirstChild("UpgradeBase")
                    if upgradeBase then
                        rootPart.CFrame = upgradeBase.CFrame + Vector3.new(0, 3, 0)
                    end
                end
                print(string.format("[AutoFarm] ✓ Prompt fired → %s", v.Name))
            else
                warn(string.format("[AutoFarm] Pas de ProximityPrompt sur %s", v.Name))
            end

            task.wait(0.2)
        end
    end

    print(string.format("[AutoFarm] Cycle #%d terminé | Scannés : %d | Matchés : %d | TPs : %d | Skip billboard : %d",
        cycleCount, totalScanned, totalMatched, totalTped, totalSkipped))
end

-- ─── LOGIQUE : AutoFarm Money ─────────────────────────────────────────────────
local function AutoFarmMoneyFunction()
    local base = getBase()
    if not base then warn("[AutoFarmMoney] Base introuvable") return end

    for _, v in ipairs(base:GetChildren()) do
        if not AutoFarmMoney then break end
        if not v:IsA("Model") then continue end

        local button = v:FindFirstChild("Button")
        if not button then continue end

        local part = button:IsA("BasePart") and button or button:FindFirstChildWhichIsA("BasePart", true)
        if not part then continue end

        rootPart.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.15)

        local prompt = button:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
            print(string.format("[AutoFarmMoney] ✓ Collecté sur %s", v.Name))
        end
        task.wait(0.1)
    end
end

-- ─── LOGIQUE : AutoRebirth ────────────────────────────────────────────────────
local function AutoRebirthFunction()
    local remote = game:GetService("ReplicatedStorage").Remotes:FindFirstChild("economy/makepurchase")
    if not remote then warn("[AutoRebirth] Remote introuvable") return end

    remote:FireServer({ ["Name"] = "rebirths", ["Amount"] = 1 })
    print("[AutoRebirth] ✓ Rebirth fired")
end

-- ─── LOGIQUE : AutoUpgrade Brainrot ──────────────────────────────────────────
local function AutoUpgradeBrainrotFunction()
    local base = getBase()
    if not base then warn("[AutoUpgrade] Base introuvable") return end

    local remote = game.ReplicatedStorage.Remotes:FindFirstChild("base/interactstand")
    if not remote then warn("[AutoUpgrade] Remote introuvable") return end

    for _, v in ipairs(base:GetChildren()) do
        if not AutoUpgradeBrainrot then break end
        if not v:IsA("Model") then continue end
        remote:InvokeServer("Upgrade", v.Name)
        print(string.format("[AutoUpgrade] ✓ Upgrade fired → %s", v.Name))
        task.wait(0.1)
    end
end

-- ─── LOGIQUE : AutoBuy ────────────────────────────────────────────────────────
local function buy(purchaseName, amount)
    local remote = game:GetService("ReplicatedStorage").Remotes:FindFirstChild("economy/makepurchase")
    if not remote then warn("[AutoBuy] Remote introuvable") return end
    if not purchaseName then warn("[AutoBuy] Aucun type sélectionné") return end

    remote:FireServer({ ["Name"] = purchaseName, ["Amount"] = tonumber(amount) or 1 })
    print(string.format("[AutoBuy] ✓ Achat → %s x%d", purchaseName, tonumber(amount) or 1))
end

-- ─── BOUCLE PRINCIPALE ───────────────────────────────────────────────────────
task.spawn(function()
    print("[Main] Boucle principale démarrée")
    while true do
        if AutoFarm            then farmCycle()                          end
        if AutoFarmMoney       then AutoFarmMoneyFunction()              end
        if AutoRebirth         then AutoRebirthFunction()                end
        if AutoUpgradeBrainrot then AutoUpgradeBrainrotFunction()        end
        if AutoBuy and selectedType then buy(selectedType, HowManyBuy)  end
        task.wait(0.2)
    end
end)
