-- PhantomRig v3.2 - Midnight Purple GUI with Speed Control & Keybind Customization

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "PhantomRigGUI"
gui.ResetOnSpawn = false

local savedAnimations = {}
local reanimationEnabled = true
local guiVisible = true
local animationSpeed = 1
local toggleKey = Enum.KeyCode.RightShift

-- Helper function
local function roundify(obj, radius)
	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, radius)
	uic.Parent = obj
end

-- Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 620, 0, 460)
frame.Position = UDim2.new(0.5, -310, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(35, 0, 65)
frame.Active = true
frame.Draggable = true
roundify(frame, 12)

-- Title Bar
local title = Instance.new("TextLabel", frame)
title.Text = "✦ PhantomRig ✦"
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Minimize
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -40, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextScaled = true
roundify(minimizeBtn, 8)

-- Settings Button
local settingsBtn = Instance.new("TextButton", frame)
settingsBtn.Text = "⚙️"
settingsBtn.Size = UDim2.new(0, 40, 0, 40)
settingsBtn.Position = UDim2.new(1, -80, 0, 0)
settingsBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 80)
settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsBtn.Font = Enum.Font.Gotham
settingsBtn.TextScaled = true
roundify(settingsBtn, 8)

-- Main Content
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 0, 0, 40)
content.Size = UDim2.new(1, 0, 1, -40)
content.BackgroundTransparency = 1

-- Input Fields
local nameInput = Instance.new("TextBox", content)
nameInput.PlaceholderText = "Reanimations"
nameInput.Size = UDim2.new(0.45, 0, 0, 40)
nameInput.Position = UDim2.new(0.05, 0, 0.05, 0)
nameInput.BackgroundColor3 = Color3.fromRGB(70, 0, 120)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.Font = Enum.Font.Gotham
nameInput.TextScaled = true
roundify(nameInput, 8)

local animInput = Instance.new("TextBox", content)
animInput.PlaceholderText = "Animation ID"
animInput.Size = UDim2.new(0.45, 0, 0, 40)
animInput.Position = UDim2.new(0.5, 0, 0.05, 0)
animInput.BackgroundColor3 = Color3.fromRGB(70, 0, 120)
animInput.TextColor3 = Color3.fromRGB(255, 255, 255)
animInput.Font = Enum.Font.Gotham
animInput.TextScaled = true
roundify(animInput, 8)

local playButton = Instance.new("TextButton", content)
playButton.Text = "Save & Play"
playButton.Size = UDim2.new(0.9, 0, 0, 40)
playButton.Position = UDim2.new(0.05, 0, 0.2, 0)
playButton.BackgroundColor3 = Color3.fromRGB(110, 0, 150)
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.GothamBold
playButton.TextScaled = true
roundify(playButton, 10)

local searchBox = Instance.new("TextBox", content)
searchBox.PlaceholderText = "Saved"
searchBox.Size = UDim2.new(0.9, 0, 0, 30)
searchBox.Position = UDim2.new(0.05, 0, 0.35, 0)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextScaled = true
roundify(searchBox, 8)

local dropdown = Instance.new("ScrollingFrame", content)
dropdown.Size = UDim2.new(0.9, 0, 0.3, 0)
dropdown.Position = UDim2.new(0.05, 0, 0.45, 0)
dropdown.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
dropdown.BorderSizePixel = 0
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 6
roundify(dropdown, 8)

local toggleBtn = Instance.new("TextButton", content)
toggleBtn.Text = "Reanimation: ON"
toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
toggleBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
roundify(toggleBtn, 8)

local speedLabel = Instance.new("TextLabel", content)
speedLabel.Text = "Speed: 1.0x"
speedLabel.Size = UDim2.new(0.5, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.89, 0)
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
speedLabel.BackgroundTransparency = 1
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold

local speedSlider = Instance.new("TextButton", content)
speedSlider.Size = UDim2.new(0.4, 0, 0, 20)
speedSlider.Position = UDim2.new(0.5, 0, 0.9, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(90, 0, 140)
speedSlider.Text = ""
roundify(speedSlider, 8)

local fill = Instance.new("Frame", speedSlider)
fill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
fill.Size = UDim2.new(animationSpeed / 2, 0, 1, 0)
fill.Position = UDim2.new(0, 0, 0, 0)
fill.BorderSizePixel = 0
roundify(fill, 8)

-- Utility: Play animation
local function playAnimation(id)
	if not reanimationEnabled then return end
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. id
		local track = humanoid:LoadAnimation(anim)
		track:AdjustSpeed(animationSpeed)
		track:Play()
	end
end

-- Save + play logic
playButton.MouseButton1Click:Connect(function()
	local animName = nameInput.Text
	local animID = animInput.Text

	if animName ~= "" and animID ~= "" then
		savedAnimations[animName] = animID

		local button = Instance.new("TextButton", dropdown)
		button.Size = UDim2.new(1, 0, 0, 25)
		button.Text = animName
		button.TextScaled = true
		button.BackgroundColor3 = Color3.fromRGB(50, 0, 70)
		button.TextColor3 = Color3.new(1, 1, 1)
		roundify(button, 6)

		button.MouseButton1Click:Connect(function()
			playAnimation(savedAnimations[animName])
		end)

		dropdown.CanvasSize = UDim2.new(0, 0, 0, #dropdown:GetChildren() * 30)
		playAnimation(animID)
	end
end)

-- Toggle button
toggleBtn.MouseButton1Click:Connect(function()
	reanimationEnabled = not reanimationEnabled
	toggleBtn.Text = "Reanimation: " .. (reanimationEnabled and "ON" or "OFF")
	toggleBtn.BackgroundColor3 = reanimationEnabled and Color3.fromRGB(80, 0, 120) or Color3.fromRGB(40, 0, 50)
end)

-- GUI toggle key
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == toggleKey then
		guiVisible = not guiVisible
		frame.Visible = guiVisible
	end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
end)

-- Speed slider logic
local dragging = false
speedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
		animationSpeed = math.round((x * 1.9 + 0.1) * 10) / 10
		fill.Size = UDim2.new(x, 0, 1, 0)
		speedLabel.Text = "Speed: " .. animationSpeed .. "x"
	end
end)

-- Search Box (live filter)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = searchBox.Text:lower()
	for _, btn in ipairs(dropdown:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.Visible = btn.Text:lower():find(query) ~= nil
		end
	end
end)

-- Settings - keybind rebinder
settingsBtn.MouseButton1Click:Connect(function()
	settingsBtn.Text = "Press a key..."
	local conn
	conn = UIS.InputBegan:Connect(function(input, gp)
		if not gp then
			toggleKey = input.KeyCode
			settingsBtn.Text = "⚙️"
			conn:Disconnect()
		end
	end)
end)
