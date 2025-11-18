-- Auto Move Script (Vinchester Edition)
-- Anti-AFK otomatik
-- made by vinchester

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local BASE_INTERVAL = 60
local HASTE_MULTIPLIER = 2
local TARGET_DISTANCE = 10

-- STATE
local autoMoveEnabled = true -- Toggle sadece görünüm için
local hurryEnabled = false
local countdown = BASE_INTERVAL
local character
local nextDirection = -1
local menuClosed = false

-- CHARACTER
local function onCharacterAdded(char)
	character = char
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- UI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AutoMoveUI"
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 240, 0, 110)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(35, 0, 50) -- koyu mor-siyah
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0,10,0,8)
title.BackgroundTransparency = 1
title.Text = "Auto Move — vinchester"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,200,255)
title.TextXAlignment = Enum.TextXAlignment.Left

local toggleButton = Instance.new("TextButton", panel)
toggleButton.Size = UDim2.new(0.6, -12, 0, 36)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(120, 0, 120) -- mor
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Text = "Auto: ON"
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

local hurryButton = Instance.new("TextButton", panel)
hurryButton.Size = UDim2.new(0.35, -12, 0, 36)
hurryButton.Position = UDim2.new(0.62, 10, 0, 40)
hurryButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150) -- mor
hurryButton.TextColor3 = Color3.fromRGB(255,255,255)
hurryButton.Font = Enum.Font.GothamBold
hurryButton.TextSize = 15
hurryButton.Text = "FASTER TIMER"
Instance.new("UICorner", hurryButton).CornerRadius = UDim.new(0,8)

local countdownLabel = Instance.new("TextLabel", panel)
countdownLabel.Size = UDim2.new(1, -20, 0, 24)
countdownLabel.Position = UDim2.new(0,10,0,82)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.fromRGB(220,180,255)
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left

-- UI Helpers
local function formatTime(s)
	s = math.max(0, math.floor(s+0.5))
	return string.format("%02d:%02d", math.floor(s/60), s%60)
end

local function updateUI()
	if menuClosed then return end
	countdownLabel.Position = countdownLabel.Position + UDim2.new(0,0,0,math.sin(tick()*5))
	if hurryEnabled then
		hurryButton.BackgroundColor3 = Color3.fromRGB(255,100,255)
		hurryButton.Text = "FASTER: ON"
	else
		hurryButton.BackgroundColor3 = Color3.fromRGB(150,0,150)
		hurryButton.Text = "FASTER TIMER"
	end
	countdownLabel.Text = "Next move in: "..formatTime(countdown)
end

-- Buttons
hurryButton.MouseButton1Click:Connect(function()
	hurryEnabled = not hurryEnabled
	updateUI()
end)

toggleButton.MouseButton1Click:Connect(function()
	autoMoveEnabled = not autoMoveEnabled
	toggleButton.Text = autoMoveEnabled and "Auto: ON" or "Auto: OFF"
end)

-- Movement
local function performWalk(directionSign)
	if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then return end
	local root = character.HumanoidRootPart
	local humanoid = character.Humanoid

	local targetPart = Instance.new("Part")
	targetPart.Size = Vector3.new(1,1,1)
	targetPart.Anchored = true
	targetPart.CanCollide = false
	targetPart.Transparency = 0.5
	targetPart.Color = Color3.fromRGB(0,100,255)
	targetPart.CFrame = root.CFrame + root.CFrame.LookVector * TARGET_DISTANCE * directionSign
	targetPart.Parent = workspace
	Debris:AddItem(targetPart,3)

	humanoid:MoveTo(targetPart.Position)
end

-- Timer Loop
RunService.Heartbeat:Connect(function(delta)
	local speed = hurryEnabled and HASTE_MULTIPLIER or 1
	countdown -= delta * speed
	if countdown <= 0 then
		performWalk(-nextDirection)
		nextDirection = -nextDirection
		countdown = BASE_INTERVAL
	end
	updateUI()
end)

updateUI()
-- made by vinchester
