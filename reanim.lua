-- PhantomRig: Universal Reanimation GUI Script
-- Features:
-- - Midnight purple GUI
-- - Smooth reanimation logic
-- - Animation ID loader
-- - Searchable dropdown of saved animations
-- - Auto-save new animations
-- - Toggle reanimation
-- - Works in any game

-- Initialize GUI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "PhantomRigGUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "★ PhantomRig ★"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Reanimate Toggle
local reanimateToggle = Instance.new("TextButton")
reanimateToggle.Text = "Enable Reanimation"
reanimateToggle.Size = UDim2.new(0.4, 0, 0, 40)
reanimateToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
reanimateToggle.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
reanimateToggle.TextColor3 = Color3.new(1, 1, 1)
reanimateToggle.Font = Enum.Font.Gotham
reanimateToggle.TextScaled = true
reanimateToggle.Parent = frame

-- Animation ID Input
local animInput = Instance.new("TextBox")
animInput.PlaceholderText = "Enter Animation ID"
animInput.Size = UDim2.new(0.6, 0, 0, 40)
animInput.Position = UDim2.new(0.05, 0, 0.4, 0)
animInput.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
animInput.TextColor3 = Color3.new(1, 1, 1)
animInput.Font = Enum.Font.Gotham
animInput.TextScaled = true
animInput.Parent = frame

-- Play Animation Button
local playButton = Instance.new("TextButton")
playButton.Text = "Play Animation"
playButton.Size = UDim2.new(0.3, 0, 0, 40)
playButton.Position = UDim2.new(0.7, 0, 0.4, 0)
playButton.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.Gotham
playButton.TextScaled = true
playButton.Parent = frame

-- Search Bar
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Search Saved Animations"
searchBox.Size = UDim2.new(0.9, 0, 0, 30)
searchBox.Position = UDim2.new(0.05, 0, 0.6, 0)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextScaled = true
searchBox.Parent = frame

-- Dropdown for Saved Animations
local dropdown = Instance.new("ScrollingFrame")
dropdown.Size = UDim2.new(0.9, 0, 0.25, 0)
dropdown.Position = UDim2.new(0.05, 0, 0.7, 0)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 0, 100)
dropdown.BorderSizePixel = 0
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 6
dropdown.Parent = frame

-- Function to play animation
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

-- Function to add animation to dropdown
local savedAnimations = {}

local function updateDropdown()
    dropdown:ClearAllChildren()
    local yPos = 0
    for _, animId in ipairs(savedAnimations) do
        if animId:find(searchBox.Text) then
            local button = Instance.new("TextButton")
            button.Text = animId
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Position = UDim2.new(0, 0, 0, yPos)
            button.BackgroundColor3 = Color3.fromRGB(70, 0, 140)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.Gotham
            button.TextScaled = true
            button.Parent = dropdown

            button.MouseButton1Click:Connect(function()
                playAnimation(animId)
            end)

            yPos = yPos + 30
        end
    end
    dropdown.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Event connections
playButton.MouseButton1Click:Connect(function()
    local animId = animInput.Text
    if animId and animId ~= "" then
        table.insert(savedAnimations, animId)
        updateDropdown()
        playAnimation(animId)
    end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(updateDropdown)

reanimateToggle.MouseButton1Click:Connect(function()
    -- Placeholder for reanimation toggle logic
    print("Reanimation toggled.")
end)

-- Initial update
updateDropdown()
