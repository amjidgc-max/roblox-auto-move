-- Auto Move Script (Vinchester Edition)
-- Anti-AFK otomatik
-- made by vinchester

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local BASE_INTERVAL = 60
local HASTE_MULTIPLIER = 2
local TARGET_DISTANCE = 10

-- STATE
local autoMoveEnabled = true
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
panel.Size = UDim2.new(0, 300, 0, 140)
panel.Position = UDim2.new(0, 50, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(28, 0, 40) -- mor-siyah
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0,10,0,8)
title.BackgroundTransparency = 1
title.Text = "Auto Move — vinchester"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(245,245,245)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle button
local toggleButton = Instance.new("TextButton", panel)
toggleButton.Size = UDim2.new(0.6, -12, 0, 36)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(123, 65, 238)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Text = "Auto: ON"
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

-- Hurry / Faster button
local hurryButton = Instance.new("TextButton", panel)
hurryButton.Size = UDim2.new(0.35, -12, 0, 36)
hurryButton.Position = UDim2.new(0.62, 10, 0, 50)
hurryButton.BackgroundColor3 = Color3.fromRGB(180, 0, 200)
hurryButton.TextColor3 = Color3.fromRGB(255,255,255)
hurryButton.Font = Enum.Font.GothamBold
hurryButton.TextSize = 15
hurryButton.Text = "Faster Timer"
Instance.new("UICorner", hurryButton).CornerRadius = UDim.new(0,8)

-- Countdown label
local countdownLabel = Instance.new("TextLabel", panel)
countdownLabel.Size = UDim2.new(1, -20, 0, 24)
countdownLabel.Position = UDim2.new(0,10,0,100)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.fromRGB(220,220,220)
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Drag Handle (sağ üst köşe)
local dragHandle = Instance.new("Frame", panel)
dragHandle.Size = UDim2.new(0, 20, 0, 20)
dragHandle.Position = UDim2.new(1, -25, 0, 5)
dragHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
dragHandle.Active = true
dragHandle.AnchorPoint = Vector2.new(0,0)
Instance.new("UICorner", dragHandle).CornerRadius = UDim.new(0,10)

-- Dragging logic (fare ve dokunmatik)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	panel.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
end

dragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

dragHandle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- UI Helpers
local function formatTime(s)
	s = math.max(0, math.floor(s+0.5))
	return string.format("%02d:%02d", math.floor(s/60), s%60)
end

local function updateUI()
	if menuClosed then return end
	-- countdown animasyon: sayıyı hafif yukarı-aşağı hareket ettir
	countdownLabel.Position = countdownLabel.Position + UDim2.new(0,0,0,math.sin(tick()*5))
	if hurryEnabled then
		hurryButton.BackgroundColor3 = Color3.fromRGB(255,140,200)
	else
		hurryButton.BackgroundColor3 = Color3.fromRGB(180,0,200)
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
	targetPart.Color = Color3.fromRGB(100,0,255)
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
