-- PhantomRig v3.4 - Updated Reanimation GUI Script
-- Author: You
-- Executor: Xeno (tested), others supported

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- State
local savedAnimations = {}
local playingTracks = {}
local reanimationEnabled = true
local guiVisible = true
local toggleKey = Enum.KeyCode.RightShift
local animationSpeed = 1

-- GUI Construction
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "PhantomRig"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 500, 0, 450)
frame.Position = UDim2.new(0.5, -250, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Text = "PhantomRig"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
minimizeBtn.Position = UDim2.new(1, -50, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 70)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 10, 0, 50)
content.Size = UDim2.new(1, -20, 1, -60)
content.BackgroundTransparency = 1

local nameInput = Instance.new("TextBox", content)
nameInput.PlaceholderText = "Reanimations"
nameInput.Size = UDim2.new(1, 0, 0, 30)
nameInput.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
nameInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

local animInput = Instance.new("TextBox", content)
animInput.PlaceholderText = "Saved"
animInput.Position = UDim2.new(0, 0, 0, 40)
animInput.Size = UDim2.new(1, 0, 0, 30)
animInput.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
animInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", animInput).CornerRadius = UDim.new(0, 6)

local playButton = Instance.new("TextButton", content)
playButton.Text = "💾 Save & Play"
playButton.Position = UDim2.new(0, 0, 0, 80)
playButton.Size = UDim2.new(1, 0, 0, 30)
playButton.BackgroundColor3 = Color3.fromRGB(70, 0, 100)
playButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", content)
toggleBtn.Text = "Reanimation: ON"
toggleBtn.Position = UDim2.new(0, 0, 0, 120)
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel", content)
speedLabel.Text = "Speed: 1x"
speedLabel.Position = UDim2.new(0, 0, 0, 160)
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1

local speedSlider = Instance.new("Frame", content)
speedSlider.Position = UDim2.new(0, 0, 0, 190)
speedSlider.Size = UDim2.new(1, 0, 0, 8)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 0, 80)
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 4)

local fill = Instance.new("Frame", speedSlider)
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

local searchBox = Instance.new("TextBox", content)
searchBox.PlaceholderText = "🔍 Search saved..."
searchBox.Position = UDim2.new(0, 0, 0, 210)
searchBox.Size = UDim2.new(1, 0, 0, 25)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
searchBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

local dropdown = Instance.new("ScrollingFrame", content)
dropdown.Position = UDim2.new(0, 0, 0, 240)
dropdown.Size = UDim2.new(1, 0, 0, 100)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 4
dropdown.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local function getAnimator()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	end
end

local function stopAnimation(id)
	for _, track in pairs(playingTracks) do
		if track.Animation and track.Animation.AnimationId == ("rbxassetid://" .. id) then
			track:Stop()
			playingTracks[track] = nil
		end
	end
end

local function playAnimation(id)
	if not reanimationEnabled then return end
	if not tonumber(id) then
		return
	end

	local animator = getAnimator()
	if not animator then return end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. tostring(id)

	local success, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)

	if success and track then
		-- Stop if playing, else play
		if playingTracks[track] then
			track:Stop()
			playingTracks[track] = nil
		else
			track:AdjustSpeed(animationSpeed)
			track:Play()
			playingTracks[track] = true
		end
	end
end

playButton.MouseButton1Click:Connect(function()
	local name = nameInput.Text
	local id = animInput.Text
	if name ~= "" and id ~= "" then
		savedAnimations[name] = id
		playAnimation(id)
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	reanimationEnabled = not reanimationEnabled
	toggleBtn.Text = "Reanimation: " .. (reanimationEnabled and "ON" or "OFF")
end)

minimizeBtn.MouseButton1Click:Connect(function()
	content.Visible = not content.Visible
end)

UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == toggleKey then
		guiVisible = not guiVisible
		screenGui.Enabled = guiVisible
	end
end)

speedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		speedSlider.InputChanged:Connect(function(moveInput)
			if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
				local pos = math.clamp((Mouse.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(pos, 0, 1, 0)
				animationSpeed = math.round(pos * 19 + 1) / 10
				speedLabel.Text = "Speed: " .. animationSpeed .. "x"
			end
		end)
	end
end)

-- Future: add search filtering dropdown code
