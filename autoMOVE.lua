--[[
    AUTO MOVE + RANDOM WALK + JUMP + UI + HURRY MODE
    Script starts AUTOMATICALLY. No click needed.
    LocalScript → StarterPlayerScripts
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== CONFIG ==========
local BASE_INTERVAL = 60          -- normal süre
local HASTE_MULTIPLIER = 2        -- Hurry mod hızı
local TARGET_DISTANCE = 10        -- hedef uzaklığı
local RANDOM_MOVE_ENABLED = true  -- rastgele yön değişimi
local RANDOM_JUMP_ENABLED = true  -- ara sıra zıplama
local JUMP_CHANCE = 0.25          -- %25 zıplama ihtimali
-- =============================

local autoMoveEnabled = true  -- ⚠ OTO AÇIK BAŞLASIN
local hurryEnabled = false
local countdown = BASE_INTERVAL
local nextDirection = -1
local menuClosed = false
local character

-- ========== CHARACTER ==========
local function onCharacterAdded(char)
    character = char
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- 🚫 Eski UI'yi sil
local old = playerGui:FindFirstChild("AutoMoveUI")
if old then old:Destroy() end

-- ========== UI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoMoveUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 240, 0, 110)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(28,28,30)
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,24,0,24)
closeButton.Position = UDim2.new(1,-28,0,4)
closeButton.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = panel
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,12)

closeButton.MouseButton1Click:Connect(function()
    menuClosed = true
    autoMoveEnabled = false
    screenGui:Destroy()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,28)
title.Position = UDim2.new(0,10,0,8)
title.BackgroundTransparency = 1
title.Text = "Auto Move"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(245,245,245)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.6,-12,0,36)
toggleButton.Position = UDim2.new(0,10,0,40)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = panel
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

local hurryButton = Instance.new("TextButton")
hurryButton.Size = UDim2.new(0.35,-12,0,36)
hurryButton.Position = UDim2.new(0.62,10,0,40)
hurryButton.TextColor3 = Color3.fromRGB(255,255,255)
hurryButton.Font = Enum.Font.GothamBold
hurryButton.TextSize = 15
hurryButton.Parent = panel
Instance.new("UICorner", hurryButton).CornerRadius = UDim.new(0,8)

local countdownLabel = Instance.new("TextLabel")
countdownLabel.Size = UDim2.new(1,-20,0,24)
countdownLabel.Position = UDim2.new(0,10,0,82)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.fromRGB(220,220,220)
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left
countdownLabel.Parent = panel

-- ========== UI UPDATE ==========
local function pad(t) return string.format("%02d:%02d", math.floor(t/60), t%60) end

local function updateUI()
    toggleButton.Text = autoMoveEnabled and "Auto: ON" or "Auto: OFF"
    toggleButton.BackgroundColor3 = autoMoveEnabled and Color3.fromRGB(0,200,120) or Color3.fromRGB(60,130,255)

    hurryButton.Text = hurryEnabled and "HURRY: ON" or "HURRY UP!"
    hurryButton.BackgroundColor3 = hurryEnabled and Color3.fromRGB(255,140,40) or Color3.fromRGB(220,60,60)

    countdownLabel.Text = (autoMoveEnabled and "Next move: " or "Paused: ") .. pad(countdown)
end

toggleButton.MouseButton1Click:Connect(function() end) -- 🔒 KAPATILMASIN

hurryButton.MouseButton1Click:Connect(function()
    hurryEnabled = not hurryEnabled
end)

-- ========== MOVE FUNCTION ==========
local function performWalk(dirSign)
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    local direction = root.CFrame.LookVector

    if RANDOM_MOVE_ENABLED then
        local axis = math.random(1,4)
        if axis == 2 then direction = root.CFrame.RightVector end
        if axis == 3 then direction = -root.CFrame.RightVector end
        if axis == 4 then direction = -direction end
    else
        direction *= dirSign
    end

    local pos = root.Position + direction * TARGET_DISTANCE
    humanoid:MoveTo(pos)

    local part = Instance.new("Part")
    part.Size = Vector3.new(1,1,1)
    part.Anchored = true
    part.CanCollide = false
    part.Color = Color3.fromRGB(0,100,255)
    part.Transparency = 0.4
    part.Position = pos
    part.Parent = workspace
    Debris:AddItem(part, 2)

    if RANDOM_JUMP_ENABLED and math.random() < JUMP_CHANCE then
        humanoid.Jump = true
    end
end

-- ========== TIMER ==========
RunService.Heartbeat:Connect(function(delta)
    if menuClosed then return end
    if not autoMoveEnabled then return end

    local speed = hurryEnabled and HASTE_MULTIPLIER or 1
    countdown -= delta * speed

    if countdown <= 0 then
        performWalk(nextDirection)
        nextDirection = -nextDirection
        countdown = BASE_INTERVAL
    end

    updateUI()
end)

updateUI()
