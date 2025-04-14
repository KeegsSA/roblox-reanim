-- PhantomRig v3.6 - Universal Reanimation GUI Script with Enhanced Dark Purple Theme and Advanced Animation Controls
-- Author: You
-- Executor: Xeno (tested), others supported

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- State
local savedAnimations = {}
local playingTracks = {}
local reanimationEnabled = true
local guiVisible = true
local toggleKey = Enum.KeyCode.RightShift
local guiToggleKey = Enum.KeyCode.F1
local animationSpeed = 1

-- GUI Construction
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "PhantomRig"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 550, 0, 500)
frame.Position = UDim2.new(0.5, -275, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Visible = true

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", frame)
title.Text = "PhantomRig"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 180, 255)
title.TextScaled = true

local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
minimizeBtn.Position = UDim2.new(1, -50, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 10, 0, 50)
content.Size = UDim2.new(1, -20, 1, -60)
content.BackgroundTransparency = 1

-- Inputs
local nameInput = Instance.new("TextBox", content)
nameInput.PlaceholderText = "Reanimations"
nameInput.Size = UDim2.new(1, 0, 0, 30)
nameInput.BackgroundColor3 = Color3.fromRGB(50, 0, 75)
nameInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

local animInput = Instance.new("TextBox", content)
animInput.PlaceholderText = "Saved"
animInput.Position = UDim2.new(0, 0, 0, 40)
animInput.Size = UDim2.new(1, 0, 0, 30)
animInput.BackgroundColor3 = Color3.fromRGB(50, 0, 75)
animInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", animInput).CornerRadius = UDim.new(0, 6)

local playButton = Instance.new("TextButton", content)
playButton.Text = "💾 Save & Play"
playButton.Position = UDim2.new(0, 0, 0, 80)
playButton.Size = UDim2.new(1, 0, 0, 30)
playButton.BackgroundColor3 = Color3.fromRGB(80, 0, 110)
playButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", content)
toggleBtn.Text = "Reanimation: ON"
toggleBtn.Position = UDim2.new(0, 0, 0, 120)
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 140)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel", content)
speedLabel.Text = "Speed: 1x"
speedLabel.Position = UDim2.new(0, 0, 0, 160)
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
speedLabel.BackgroundTransparency = 1

local speedSlider = Instance.new("Frame", content)
speedSlider.Position = UDim2.new(0, 0, 0, 190)
speedSlider.Size = UDim2.new(1, 0, 0, 8)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 4)

local fill = Instance.new("Frame", speedSlider)
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(130, 0, 190)
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

local searchBox = Instance.new("TextBox", content)
searchBox.PlaceholderText = "🔍 Search saved..."
searchBox.Position = UDim2.new(0, 0, 0, 210)
searchBox.Size = UDim2.new(1, 0, 0, 25)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

local dropdown = Instance.new("ScrollingFrame", content)
dropdown.Position = UDim2.new(0, 0, 0, 240)
dropdown.Size = UDim2.new(1, 0, 0, 100)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 4
dropdown.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
statusLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(230, 200, 255)
statusLabel.Text = ""
statusLabel.TextScaled = true

-- You can add even more MicUp-like options or stylizations here
-- Add future modular expansion or integration as needed

-- More features added soon
