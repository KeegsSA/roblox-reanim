-- PhantomRig v2: Reanimation GUI with Midnight Theme, Smooth UX, and Storage
-- Features: Rounded UI, Draggable GUI, Minimize/Expand, Saved Animations with Search

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PhantomRigGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 320)
frame.Position = UDim2.new(0.5, -200, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Title Bar
local title = Instance.new("TextLabel")
title.Text = "★ PhantomRig ★"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 0, 60)
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Minimize Button
local minimize = Instance.new("TextButton")
minimize.Text = "–"
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -35, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
minimize.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimize

-- Toggle Content
local contentVisible = true

-- Container for below-title content
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, -40)
container.Position = UDim2.new(0, 0, 0, 40)
container.BackgroundTransparency = 1
container.Parent = frame

-- Reanimations Input
local animInput = Instance.new("TextBox")
animInput.PlaceholderText = "Reanimations"
animInput.Size = UDim2.new(0.6, 0, 0, 40)
animInput.Position = UDim2.new(0.05, 0, 0, 10)
animInput.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
animInput.TextColor3 = Color3.new(1, 1, 1)
animInput.Font = Enum.Font.Gotham
animInput.TextScaled = true
animInput.Parent = container
local corner1 = Instance.new("UICorner", animInput)

-- Play Button
local playButton = Instance.new("TextButton")
playButton.Text = "Play"
playButton.Size = UDim2.new(0.25, 0, 0, 40)
playButton.Position = UDim2.new(0.7, 0, 0, 10)
playButton.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.Gotham
playButton.TextScaled = true
playButton.Parent = container
local corner2 = Instance.new("UICorner", playButton)

-- Search Bar
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Saved"
searchBox.Size = UDim2.new(0.9, 0, 0, 30)
searchBox.Position = UDim2.new(0.05, 0, 0, 60)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextScaled = true
searchBox.Parent = container
local corner3 = Instance.new("UICorner", searchBox)

-- Dropdown
local dropdown = Instance.new("ScrollingFrame")
dropdown.Size = UDim2.new(0.9, 0, 0.5, 0)
dropdown.Position = UDim2.new(0.05, 0, 0, 100)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
dropdown.BorderSizePixel = 0
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 6
dropdown.Parent = container
local corner4 = Instance.new("UICorner", dropdown)

-- Play Function
local savedAnimations = {}
local function playAnimation(animId)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animId
        local track = animator:LoadAnimation(animation)
        track:Play()
    end
end

-- Update Dropdown
local function updateDropdown()
    dropdown:ClearAllChildren()
    local y = 0
    for _, id in ipairs(savedAnimations) do
        if id:lower():find(searchBox.Text:lower()) then
            local btn = Instance.new("TextButton")
            btn.Text = id
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(70, 0, 140)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.Parent = dropdown
            local bcorner = Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                playAnimation(id)
            end)

            y = y + 32
        end
    end
    dropdown.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Button Events
playButton.MouseButton1Click:Connect(function()
    local animId = animInput.Text
    if animId and animId ~= "" then
        table.insert(savedAnimations, animId)
        updateDropdown()
        playAnimation(animId)
    end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(updateDropdown)

minimize.MouseButton1Click:Connect(function()
    contentVisible = not contentVisible
    container.Visible = contentVisible
    minimize.Text = contentVisible and "–" or "+"
end)

-- Init
updateDropdown()
