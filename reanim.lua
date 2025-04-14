-- PhantomRig v3.7 - Universal Reanimation GUI Script with Tabbed Layout
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
local selectedTarget = nil
local voidWalkEnabled = true -- Automatically enable Void Walk

-- GUI Construction
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "PhantomRig"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 650, 0, 500)
frame.Position = UDim2.new(0.5, -325, 0.5, -250)
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

local sidePanel = Instance.new("Frame", frame)
sidePanel.Size = UDim2.new(0, 130, 1, -50)
sidePanel.Position = UDim2.new(0, 0, 0, 50)
sidePanel.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
Instance.new("UICorner", sidePanel).CornerRadius = UDim.new(0, 10)

local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 140, 0, 50)
content.Size = UDim2.new(1, -150, 1, -60)
content.BackgroundTransparency = 1

-- Create pages
local pages = {}
local function createPage(name)
    local page = Instance.new("Frame", content)
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    pages[name] = page
    return page
end

local reanimPage = createPage("Reanimation")
local targetPage = createPage("Target")

-- Tab switching logic
local function showPage(name)
    for n, page in pairs(pages) do
        page.Visible = (n == name)
    end
end

local function createSideButton(name, yOffset, callback)
    local button = Instance.new("TextButton", sidePanel)
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, yOffset)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(80, 0, 110)
    button.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    button.MouseButton1Click:Connect(callback)
    return button
end

createSideButton("🎯 Target", 10, function() showPage("Target") end)
createSideButton("💃 Reanim", 50, function() showPage("Reanimation") end)

-- Default to Reanimation
showPage("Reanimation")

-- Reanimation Page Elements
local nameInput = Instance.new("TextBox", reanimPage)
nameInput.PlaceholderText = "Reanimations"
nameInput.Size = UDim2.new(1, 0, 0, 30)
nameInput.BackgroundColor3 = Color3.fromRGB(50, 0, 75)
nameInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

local animInput = Instance.new("TextBox", reanimPage)
animInput.PlaceholderText = "Saved"
animInput.Position = UDim2.new(0, 0, 0, 40)
animInput.Size = UDim2.new(1, 0, 0, 30)
animInput.BackgroundColor3 = Color3.fromRGB(50, 0, 75)
animInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", animInput).CornerRadius = UDim.new(0, 6)

local playButton = Instance.new("TextButton", reanimPage)
playButton.Text = "💾 Save & Play"
playButton.Position = UDim2.new(0, 0, 0, 80)
playButton.Size = UDim2.new(1, 0, 0, 30)
playButton.BackgroundColor3 = Color3.fromRGB(80, 0, 110)
playButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton", reanimPage)
toggleBtn.Text = "Reanimation: ON"
toggleBtn.Position = UDim2.new(0, 0, 0, 120)
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 140)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel", reanimPage)
speedLabel.Text = "Speed: 1x"
speedLabel.Position = UDim2.new(0, 0, 0, 160)
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
speedLabel.BackgroundTransparency = 1

local speedSlider = Instance.new("Frame", reanimPage)
speedSlider.Position = UDim2.new(0, 0, 0, 190)
speedSlider.Size = UDim2.new(1, 0, 0, 8)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 4)

local fill = Instance.new("Frame", speedSlider)
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(130, 0, 190)
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

local searchBox = Instance.new("TextBox", reanimPage)
searchBox.PlaceholderText = "🔍 Search saved..."
searchBox.Position = UDim2.new(0, 0, 0, 210)
searchBox.Size = UDim2.new(1, 0, 0, 25)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
searchBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

local dropdown = Instance.new("ScrollingFrame", reanimPage)
dropdown.Position = UDim2.new(0, 0, 0, 240)
dropdown.Size = UDim2.new(1, 0, 0, 100)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 4
dropdown.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

-- Target Page Elements
local targetBox = Instance.new("TextBox", targetPage)
targetBox.PlaceholderText = "Type username here"
targetBox.Position = UDim2.new(0, 0, 0, 0)
targetBox.Size = UDim2.new(1, -40, 0, 30)
targetBox.BackgroundColor3 = Color3.fromRGB(60, 0, 80)
targetBox.TextColor3 = Color3.new(1, 1, 1)
targetBox.Text = ""
Instance.new("UICorner", targetBox).CornerRadius = UDim.new(0, 6)

local selectToolBtn = Instance.new("TextButton", targetPage)
selectToolBtn.Text = "🖱 Get Target Tool"
selectToolBtn.Position = UDim2.new(1, -35, 0, 0)
selectToolBtn.Size = UDim2.new(0, 30, 0, 30)
selectToolBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 130)
selectToolBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", selectToolBtn).CornerRadius = UDim.new(0, 6)

local headsitBtn = Instance.new("TextButton", targetPage)
headsitBtn.Text = "🪑 Headsit"
headsitBtn.Position = UDim2.new(0, 0, 0, 40)
headsitBtn.Size = UDim2.new(1, 0, 0, 30)
headsitBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 150)
headsitBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", headsitBtn).CornerRadius = UDim.new(0, 6)

local standBtn = Instance.new("TextButton", targetPage)
standBtn.Text = "🧍 Stand Beside"
standBtn.Position = UDim2.new(0, 0, 0, 80)
standBtn.Size = UDim2.new(1, 0, 0, 30)
standBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 160)
standBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", standBtn).CornerRadius = UDim.new(0, 6)

-- Enable Void Walk Automatically
local function enableVoidWalk()
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")

        humanoid.Changed:Connect(function()
            if humanoid:GetState() == Enum.HumanoidStateType.Physics then
                hrp.CFrame = CFrame.new(hrp.Position.X, 500, hrp.Position.Z) -- Adjust Y to a high value
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
end

-- Automatically enable Void Walk when script runs
enableVoidWalk()

-- Status Label
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
statusLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Void Walk is Enabled"
statusLabel.TextScaled = true
statusLabel.TextAlignment = Enum.TextAlignment.Center
