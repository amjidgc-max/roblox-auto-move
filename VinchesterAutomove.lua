-- Auto Move Script (Vinchester Edition)
-- Anti-AFK otomatik
-- Geri sayım animasyonu eklendi
-- made by vinchester

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local BASE_INTERVAL = 60
local HASTE_MULTIPLIER = 2
local TARGET_DISTANCE = 10

-- STATE
local autoMoveEnabled = true -- script açılır açılmaz aktif
local hurryEnabled = false
local countdown = BASE_INTERVAL
local character
local nextDirection = -1
local menuClosed = false
local lastCountdown = math.ceil(countdown)

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
panel.Size = UDim2.new(0, 300, 0, 130)
panel.Position = UDim2.new(0, 20, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(28, 0, 40)
panel.BorderSizePixel = 0
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

-- Desenli arka fon efekti
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60,0,80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28,0,40))
}
gradient.Rotation = 45
gradient.Parent = panel

-- Başlık
local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0,10,0,8)
title.BackgroundTransparency = 1
title.Text = "Auto Move — vinchester"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(245,245,245)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle görsel amaçlı
local toggleButton = Instance.new("TextButton", panel)
toggleButton.Size = UDim2.new(0.6, -12, 0, 36)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(138,43,226)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Text = "Auto: ON"
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0,8)

toggleButton.MouseButton1Click:Connect(function()
	autoMoveEnabled = not autoMoveEnabled
	toggleButton.Text = autoMoveEnabled and "Auto: ON" or "Auto: OFF"
end)

-- Hurry button
local hurryButton = Instance.new("TextButton", panel)
hurryButton.Size = UDim2.new(0.35, -12, 0, 36)
hurryButton.Position = UDim2.new(0.62, 10, 0, 50)
hurryButton.BackgroundColor3 = Color3.fromRGB(220,60,60)
hurryButton.TextColor3 = Color3.fromRGB(255,255,255)
hurryButton.Font = Enum.Font.GothamBold
hurryButton.TextSize = 15
hurryButton.Text = "GET FASTER!"
Instance.new("UICorner", hurryButton).CornerRadius = UDim.new(0,8)

hurryButton.MouseButton1Click:Connect(function()
	hurryEnabled = not hurryEnabled
	hurryButton.Text = hurryEnabled and "GET FASTER: ON" or "GET FASTER!"
end)

-- Countdown label
local countdownLabel = Instance.new("TextLabel", panel)
countdownLabel.Size = UDim2.new(1, -20, 0, 24)
countdownLabel.Position = UDim2.new(0,10,0,95)
countdownLabel.BackgroundTransparency = 1
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextSize = 16
countdownLabel.TextColor3 = Color3.fromRGB(220,220,220)
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Panel sürükleme sağ üst köşeden
local dragHandle = Instance.new("Frame", panel)
dragHandle.Size = UDim2.new(0,30,0,30)
dragHandle.Position = UDim2.new(1,-32,0,2)
dragHandle.BackgroundColor3 = Color3.fromRGB(255,255,255)
dragHandle.BackgroundTransparency = 0.8
Instance.new("UICorner", dragHandle).CornerRadius = UDim.new(0,15)

local dragging = false
local dragOffset = Vector2.new(0,0)

dragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		local mousePos = input.Position
		local panelPos = panel.Position
		dragOffset = Vector2.new(mousePos.X - panelPos.X.Offset, mousePos.Y - panelPos.Y.Offset)
	end
end)

dragHandle.InputEnded:Connect(function(input)
	dragging = false
end)

dragHandle.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local newPos = input.Position - dragOffset
		panel.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
	end
end)

-- X butonu sol üst
local closeButton = Instance.new("TextButton", panel)
closeButton.Size = UDim2.new(0,24,0,24)
closeButton.Position = UDim2.new(0,2,0,2)
closeButton.BackgroundColor3 = Color3.fromRGB(180,40,40)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,12)

closeButton.MouseButton1Click:Connect(function()
	menuClosed = true
	screenGui:Destroy()
end)

-- UI Helper: countdown animasyonu
local function formatTime(s)
	s = math.max(0, math.floor(s+0.5))
	return string.format("%02d:%02d", math.floor(s/60), s%60)
end

local function updateUI()
	if menuClosed then return end
	local currentCountdown = math.ceil(countdown)
	if currentCountdown ~= lastCountdown then
		local oldLabel = countdownLabel:Clone()
		oldLabel.Parent = panel
		oldLabel.Text = countdownLabel.Text
		oldLabel.Position = countdownLabel.Position
		
		countdownLabel.Text = "Next move in: "..formatTime(currentCountdown)
		countdownLabel.Position = countdownLabel.Position + UDim2.new(0,0,0.2,0)
		
		local tween = TweenService:Create(countdownLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = countdownLabel.Position - UDim2.new(0,0,0.2,0)})
		tween:Play()
		
		local fadeTween = TweenService:Create(oldLabel, TweenInfo.new(0.3), {TextTransparency = 1, TextStrokeTransparency = 1})
		fadeTween:Play()
		fadeTween.Completed:Connect(function() oldLabel:Destroy() end)
		
		lastCountdown = currentCountdown
	end
end

-- Hareket fonksiyonu
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
	if autoMoveEnabled and not menuClosed then
		local speed = hurryEnabled and HASTE_MULTIPLIER or 1
		countdown -= delta * speed
		if countdown <= 0 then
			performWalk(-nextDirection)
			nextDirection = -nextDirection
			countdown = BASE_INTERVAL
		end
	end
	updateUI()
end)

updateUI()
-- made by vinchester
