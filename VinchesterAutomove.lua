--AUTO MOVE
--------------
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----
----

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")


---

-- CONFIG

local BASE_INTERVAL = 60
local HASTE_MULTIPLIER = 3
local TARGET_DISTANCE = 10

local autoMoveEnabled = false
local hurryEnabled = false
local countdown = BASE_INTERVAL
local fps = 0
local frameCount = 0
local minimized = false
local nextDirection = -1

local character
player.CharacterAdded:Connect(function(c) character = c end)
if player.Character then character = player.Character end


---

-- UI CREATION

local screen = Instance.new("ScreenGui", playerGui)
screen.Name = "VinchesterUI"
screen.ResetOnSpawn = false

local main = Instance.new("Frame", screen)
main.Size = UDim2.new(0,0,0,0)
main.Position = UDim2.new(0.5,0,0.5,0)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.BackgroundTransparency = 0.6 -- koyu ve şeffaf
main.BorderSizePixel = 0
main.ClipsDescendants = true
local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,18)


---

-- SPLASH SCREEN

local splashText = Instance.new("TextLabel", main)
splashText.Size = UDim2.new(1,0,0,50)
splashText.Position = UDim2.new(0,0,0.3,0)
splashText.BackgroundTransparency = 1
splashText.Font = Enum.Font.GothamBold
splashText.TextColor3 = Color3.new(1,1,1)
splashText.TextSize = 28
splashText.Text = "Made by Vinchester"

local openBtn = Instance.new("TextButton", main)
openBtn.Size = UDim2.new(0,100,0,40)
openBtn.Position = UDim2.new(0.5,-50,0.5,0)
openBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18
openBtn.Text = "Open"
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0,10)


---

-- PROFILE AREA

local avatar = Instance.new("ImageLabel", main)
avatar.Size = UDim2.new(0,70,0,70)
avatar.Position = UDim2.new(0.5,-35,0,15)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxassetid://0"
local avatCorner = Instance.new("UICorner", avatar)
avatCorner.CornerRadius = UDim.new(1,0)

local display = Instance.new("TextLabel", main)
display.Size = UDim2.new(1,0,0,24)
display.Position = UDim2.new(0,0,0,95)
display.BackgroundTransparency = 1
display.Font = Enum.Font.GothamBold
display.TextColor3 = Color3.new(1,1,1)
display.TextSize = 20
display.Text = player.DisplayName

local user = Instance.new("TextLabel", main)
user.Size = UDim2.new(1,0,0,20)
user.Position = UDim2.new(0,0,0,125)
user.BackgroundTransparency = 1
user.Font = Enum.Font.Gotham
user.TextColor3 = Color3.fromRGB(180,180,180)
user.TextSize = 16
user.Text = "@"..player.Name

local uid = Instance.new("TextLabel", main)
uid.Size = UDim2.new(0,200,0,18)
uid.Position = UDim2.new(0,10,0,150)
uid.BackgroundTransparency = 1
uid.Font = Enum.Font.Gotham
uid.TextColor3 = Color3.fromRGB(140,140,140)
uid.TextSize = 14
uid.Text = "UserId: "..player.UserId

-- COPY USERID BUTTON
local copyBtn = Instance.new("TextButton", main)
copyBtn.Size = UDim2.new(0,50,0,18)
copyBtn.Position = UDim2.new(0,215,0,150)
copyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
copyBtn.TextColor3 = Color3.new(1,1,1)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 14
copyBtn.Text = "Copy"
local copyCorner = Instance.new("UICorner", copyBtn)
copyCorner.CornerRadius = UDim.new(0,4)
copyBtn.MouseButton1Click:Connect(function()
setclipboard(tostring(player.UserId))
copyBtn.Text = "Copied!"
task.delay(1, function() copyBtn.Text = "Copy" end)
end)

task.spawn(function()
local content, ready = Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420)
if ready then avatar.Image = content end
end)


---

-- BUTTON FUNCTION

local function CreateButton(name, y, width)
local b = Instance.new("TextButton", main)
b.Size = UDim2.new(0, width or 300,0,40)
b.Position = UDim2.new(0.5,-(width or 300)/2,0,y)
b.BackgroundColor3 = Color3.fromRGB(40,40,40)
b.TextColor3 = Color3.new(1,1,1)
b.Font = Enum.Font.GothamBold
b.TextSize = 18
b.Text = name
local c = Instance.new("UICorner", b)
c.CornerRadius = UDim.new(0,10)
return b
end

-- BUTTONS
local btn_cancel = CreateButton("Cancel",190)
local btn_delete = CreateButton("Delete",240)
local btn_auto   = CreateButton("Auto Move: ON",290)
local btn_faster = CreateButton("Get Faster: OFF",340)
local btn_timer  = CreateButton("Timer: "..BASE_INTERVAL,390,145)
local btn_fps    = CreateButton("FPS: 0",390,145)
btn_timer.Position = UDim2.new(0.5,-150,0,390)
btn_fps.Position   = UDim2.new(0.5,5,0,390)

for _,v in pairs({btn_cancel,btn_delete,btn_auto,btn_faster,btn_timer,btn_fps}) do
v.Visible = false
end


---

-- RESTORE BUTTON

local restoreButton = Instance.new("TextButton", screen)
restoreButton.Size = UDim2.new(0,40,0,40)
restoreButton.AnchorPoint = Vector2.new(0.5,0)
restoreButton.Position = UDim2.new(0.5,0,0,20)
restoreButton.BackgroundColor3 = Color3.fromRGB(25,25,25)
restoreButton.Text = "▶"
restoreButton.Visible = false
restoreButton.TextColor3 = Color3.new(1,1,1)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 20
local restoreCorner = Instance.new("UICorner", restoreButton)
restoreCorner.CornerRadius = UDim.new(1,0)


---

-- MINIMIZE / RESTORE LOGIC

function setMinimized(state)
minimized = state
if state then
local targetPos = restoreButton.Position
local tween = TweenService:Create(main, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(0,40,0,40), Position=targetPos})
tween:Play()
tween.Completed:Wait()
main.Visible = false
restoreButton.Visible = true
else
restoreButton.Visible = false
main.Visible = true
local startPos = restoreButton.Position
main.Position = startPos
TweenService:Create(main, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(0,350,0,480), Position=UDim2.new(0.5,0,0.5,0)}):Play()
end
end

btn_cancel.MouseButton1Click:Connect(function()
setMinimized(not minimized)
end)

restoreButton.MouseButton1Click:Connect(function()
setMinimized(false)
end)


---

-- OPEN BUTTON LOGIC

openBtn.MouseButton1Click:Connect(function()
TweenService:Create(main, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(0,350,0,480)}):Play()
task.delay(0.5,function()
splashText.Visible = false
openBtn.Visible = false
for _,v in pairs({btn_cancel,btn_delete,btn_auto,btn_faster,btn_timer,btn_fps}) do
v.Visible = true
end
autoMoveEnabled = true
end)
end)


---

-- DELETE BUTTON

btn_delete.MouseButton1Click:Connect(function()
screen:Destroy()
script:Destroy()
end)


---

-- AUTO MOVE

btn_auto.MouseButton1Click:Connect(function()
autoMoveEnabled = not autoMoveEnabled
btn_auto.Text = "Auto Move: "..(autoMoveEnabled and "ON" or "OFF")
end)


---

-- GET FASTER EXPLAIN + CONFIRM

local explanationFrame = Instance.new("Frame", main)
explanationFrame.Size = UDim2.new(0,300,0,100)
explanationFrame.Position = UDim2.new(0.5,-150,0.5,50)
explanationFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
explanationFrame.Visible = false
local exCorner = Instance.new("UICorner", explanationFrame)
exCorner.CornerRadius = UDim.new(0,10)

local exText = Instance.new("TextLabel", explanationFrame)
exText.Size = UDim2.new(1,0,0,60)
exText.Position = UDim2.new(0,0,0,0)
exText.BackgroundTransparency = 1
exText.Font = Enum.Font.Gotham
exText.TextColor3 = Color3.new(1,1,1)
exText.TextSize = 16
exText.TextWrapped = true
exText.Text = 'When you open "Get Faster", your timer get 2x faster'

local exOk = Instance.new("TextButton", explanationFrame)
exOk.Size = UDim2.new(0,80,0,30)
exOk.Position = UDim2.new(0.5,-40,0,65)
exOk.BackgroundColor3 = Color3.fromRGB(60,60,60)
exOk.TextColor3 = Color3.new(1,1,1)
exOk.Font = Enum.Font.GothamBold
exOk.TextSize = 16
exOk.Text = "OK"
local exOkCorner = Instance.new("UICorner", exOk)
exOkCorner.CornerRadius = UDim.new(0,6)

btn_faster.MouseButton1Click:Connect(function()
explanationFrame.Visible = true
end)

exOk.MouseButton1Click:Connect(function()
hurryEnabled = not hurryEnabled
btn_faster.Text = "Get Faster: "..(hurryEnabled and "ON" or "OFF")
explanationFrame.Visible = false
end)


---

-- MOVEMENT

local function performWalk(direction)
if not character then return end
local hrp = character:FindFirstChild("HumanoidRootPart")
local hum = character:FindFirstChild("Humanoid")
if not hrp or not hum then return end
local target = hrp.CFrame + hrp.CFrame.LookVector * TARGET_DISTANCE * direction
hum:MoveTo(target.Position)
end


---

-- HEARTBEAT LOOP

local last = tick()
RunService.Heartbeat:Connect(function(dt)
if autoMoveEnabled then
local speed = hurryEnabled and HASTE_MULTIPLIER or 1
countdown -= dt * speed
if countdown <= 0 then
performWalk(nextDirection)
nextDirection = -nextDirection
countdown = BASE_INTERVAL
end
end
btn_timer.Text = "Timer: "..math.floor(countdown)
frameCount += 1
local now = tick()
if now - last >= 0.25 then
fps = math.floor(frameCount / (now - last))
frameCount = 0
last = now
btn_fps.Text = "FPS: "..fps
end
end)


---

-- OPENING ANIMATION (3 saniye)

TweenService:Create(main, TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
{Size=UDim2.new(0,350,0,480)}):Play(openpen
