-- LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local BASE_INTERVAL = 60
local HASTE_MULTIPLIER = 2
local TARGET_DISTANCE = 10

local autoMoveEnabled = true
local hurryEnabled = false
local countdown = BASE_INTERVAL
local character
local nextDirection = -1

-- Karakter yükleme
local function onCharacterAdded(char)
	character = char
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

-- UI temizleme
local old = playerGui:FindFirstChild("AutoMoveUI")
if old then old:Destroy() end

-- ==== PANEL ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoMoveUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0.25,0,0.3,0) -- yarı boyut
panel.Position = UDim2.new(0.5,0,0.5,0)
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.BackgroundColor3 = Color3.fromRGB(26, 29, 46)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 15)
panelCorner.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,10)
listLayout.Parent = panel

-- ==== BAŞLIK ====
local title = Instance.new("TextLabel")
title.Text = "Vinchester Auto Move"
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1,0,0,30)
title.LayoutOrder = 1
title.Parent = panel

-- ==== AUTO TOGGLE ====
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.6,0,0,40)
toggleButton.BackgroundColor3 = Color3.fromRGB(0,200,120)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.Text = "Auto: ON"
toggleButton.LayoutOrder = 2
toggleButton.Parent = panel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0,8)
toggleCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
	autoMoveEnabled = not autoMoveEnabled
	toggleButton.Text = autoMoveEnabled and "Auto: ON" or "Auto: OFF"
	toggleButton.BackgroundColor3 = autoMoveEnabled and Color3.fromRGB(0,200,120) or Color3.fromRGB(60,130,255)
end)

-- ==== GET FAST BUTTON ====
local hurryButton = Instance.new("TextButton")
hurryButton.Size = UDim2.new(0.35,0,0,40)
hurryButton.BackgroundColor3 = Color3.fromRGB(220,60,60)
hurryButton.TextColor3 = Color3.new(1,1,1)
hurryButton.Font = Enum.Font.GothamBold
hurryButton.TextSize = 16
hurryButton.Text = "GET FAST"
hurryButton.LayoutOrder = 3
hurryButton.Parent = panel

local hurryCorner = Instance.new("UICorner")
hurryCorner.CornerRadius = UDim.new(0,8)
hurryCorner.Parent = hurryButton

hurryButton.MouseButton1Click:Connect(function()
	hurryEnabled = not hurryEnabled
	hurryButton.Text = hurryEnabled and "GET FASTER" or "GET FAST"
	hurryButton.BackgroundColor3 = hurryEnabled and Color3.fromRGB(255,140,40) or Color3.fromRGB(220,60,60)
end)

-- ==== COUNTDOWN ====
local countdownLabel = Instance.new("TextLabel")
countdownLabel.Size = UDim2.new(1,0,0,25)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.fromRGB(220,220,220)
countdownLabel.Text = "Next move in: 00:00"
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left
countdownLabel.LayoutOrder = 4
countdownLabel.Parent = panel

local function formatTime(s)
	s = math.max(0, math.floor(s+0.5))
	local mins = math.floor(s/60)
	local secs = s%60
	return string.format("%02d:%02d",mins,secs)
end

local function updateUI()
	toggleButton.Text = autoMoveEnabled and "Auto: ON" or "Auto: OFF"
	toggleButton.BackgroundColor3 = autoMoveEnabled and Color3.fromRGB(0,200,120) or Color3.fromRGB(60,130,255)
	hurryButton.Text = hurryEnabled and "GET FASTER" or "GET FAST"
	hurryButton.BackgroundColor3 = hurryEnabled and Color3.fromRGB(255,140,40) or Color3.fromRGB(220,60,60)
	countdownLabel.Text = "Next move in: "..formatTime(countdown)
end

-- ==== HAREKET ====
local function performWalk(directionSign)
	if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
	local humanoid = character.Humanoid
	local root = character.HumanoidRootPart

	local targetPart = Instance.new("Part")
	targetPart.Size = Vector3.new(1,1,1)
	targetPart.Anchored = true
	targetPart.CanCollide = false
	targetPart.Transparency = 0.5
	targetPart.Color = Color3.fromRGB(0,100,255)
	targetPart.Parent = workspace

	local offset = root.CFrame.LookVector * (TARGET_DISTANCE * directionSign)
	targetPart.CFrame = CFrame.new(root.Position + offset)
	humanoid:MoveTo(targetPart.Position)

	task.spawn(function()
		for i=0.5,1,0.05 do
			targetPart.Transparency = i
			task.wait(0.05)
		end
	end)
	Debris:AddItem(targetPart,3)
end

-- ==== TIMER ====
RunService.Heartbeat:Connect(function(delta)
	if autoMoveEnabled then
		local speed = hurryEnabled and HASTE_MULTIPLIER or 1
		countdown -= delta*speed
		if countdown <= 0 then
			performWalk(nextDirection)
			nextDirection = -nextDirection
			countdown = BASE_INTERVAL
		end
	end
	updateUI()
end)

-- ==== SÜRÜKLEME ====
local dragToggle = false
local dragInput, mousePos, framePos

local dragPoint = Instance.new("Frame")
dragPoint.Size = UDim2.new(0,12,0,12)
dragPoint.Position = UDim2.new(1,-15,0,5)
dragPoint.AnchorPoint = Vector2.new(0.5,0.5)
dragPoint.BackgroundColor3 = Color3.new(1,1,1)
dragPoint.BorderSizePixel = 0
dragPoint.Parent = panel
local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0,6)
dragCorner.Parent = dragPoint

dragPoint.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragToggle = true
		mousePos = input.Position
		framePos = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end)

dragPoint.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

RunService.RenderStepped:Connect(function()
	if dragToggle and dragInput then
		local delta = dragInput.Position - mousePos
		panel.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
								   framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

updateUI()
