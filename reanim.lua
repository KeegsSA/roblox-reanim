-- Reanimation UI + controller LocalScript
-- Requires the API you pasted to be available as a table named `API`
-- If not present, it will try to require ReplicatedStorage.ReanimAPI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Try to obtain the API table:
local API = rawget(_G, "API") -- try global first (in case you paste both scripts together)
if not API then
    local ok, mod = pcall(function()
        local candidate = ReplicatedStorage:FindFirstChild("ReanimAPI")
        if candidate and candidate:IsA("ModuleScript") then
            return require(candidate)
        end
        return nil
    end)
    if ok and mod then
        API = mod
    end
end

if not API then
    warn("Reanimation API not found. Place your API in a ModuleScript named 'ReanimAPI' in ReplicatedStorage or expose it as global 'API'.")
    return
end

-- Simple UI creation (ScreenGui)
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReanimUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0, 12, 0, 80)
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundTransparency = 0.08
frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Visible = true
frame.ClipsDescendants = true
frame.LayoutOrder = 1
frame.Padding = UDim.new(0,0)

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -12, 0, 26)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Text = "Reanimation"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -12, 0, 18)
statusLabel.Position = UDim2.new(0, 6, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(190,190,190)
statusLabel.Text = "Status: Idle"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- Reanimate Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleReanimate"
toggleBtn.Size = UDim2.new(0, 120, 0, 28)
toggleBtn.Position = UDim2.new(0, 6, 0, 58)
toggleBtn.BackgroundTransparency = 0
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggleBtn.TextColor3 = Color3.fromRGB(240,240,240)
toggleBtn.Text = "Reanimate: Off"
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = frame
local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0,6)

-- URL TextBox
local urlBox = Instance.new("TextBox")
urlBox.Name = "UrlBox"
urlBox.Size = UDim2.new(1, -138, 0, 28)
urlBox.Position = UDim2.new(0, 132, 0, 58)
urlBox.PlaceholderText = "Keyframe script URL (http://...)"
urlBox.Text = ""
urlBox.ClearTextOnFocus = false
urlBox.Font = Enum.Font.Gotham
urlBox.TextSize = 14
urlBox.TextColor3 = Color3.fromRGB(230,230,230)
urlBox.BackgroundColor3 = Color3.fromRGB(32,32,32)
urlBox.Parent = frame
local urlCorner = Instance.new("UICorner", urlBox)
urlCorner.CornerRadius = UDim.new(0,6)

-- Play Button
local playBtn = Instance.new("TextButton")
playBtn.Name = "Play"
playBtn.Size = UDim2.new(0, 92, 0, 28)
playBtn.Position = UDim2.new(0, 6, 0, 96)
playBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
playBtn.TextColor3 = Color3.fromRGB(240,240,240)
playBtn.Text = "Play"
playBtn.Font = Enum.Font.GothamSemibold
playBtn.TextSize = 14
playBtn.Parent = frame
Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0,6)

-- Stop Button
local stopBtn = Instance.new("TextButton")
stopBtn.Name = "Stop"
stopBtn.Size = UDim2.new(0, 92, 0, 28)
stopBtn.Position = UDim2.new(0, 106, 0, 96)
stopBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
stopBtn.TextColor3 = Color3.fromRGB(240,240,240)
stopBtn.Text = "Stop"
stopBtn.Font = Enum.Font.GothamSemibold
stopBtn.TextSize = 14
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,6)

-- Speed Box
local speedBox = Instance.new("TextBox")
speedBox.Name = "SpeedBox"
speedBox.Size = UDim2.new(0, 110, 0, 28)
speedBox.Position = UDim2.new(0, 206, 0, 96)
speedBox.PlaceholderText = "Speed (1.0)"
speedBox.Text = "1.0"
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.fromRGB(230,230,230)
speedBox.BackgroundColor3 = Color3.fromRGB(32,32,32)
speedBox.Parent = frame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

-- Small helper to update status
local function setStatus(text, warnMode)
    statusLabel.Text = "Status: " .. tostring(text)
    if warnMode then
        statusLabel.TextColor3 = Color3.fromRGB(255,140,120)
    else
        statusLabel.TextColor3 = Color3.fromRGB(190,190,190)
    end
end

-- Keep UI in sync with API state
local function refreshToggleLabel()
    local isRe = false
    local ok, res = pcall(function() return API.is_reanimated and API.is_reanimated() end)
    if ok and type(res) == "boolean" then isRe = res end
    toggleBtn.Text = "Reanimate: " .. (isRe and "On" or "Off")
end

-- Toggle function
local function toggleReanimate()
    local isRe = false
    local ok, res = pcall(function() return API.is_reanimated and API.is_reanimated() end)
    if ok and type(res) == "boolean" then isRe = res end

    if not isRe then
        setStatus("Attempting to reanimate...")
        -- try to find a RemoteEvent in ReplicatedStorage named 'Reanimate' (optional)
        local remote = nil
        local args = nil
        local ok2, res2 = pcall(function() return API.reanimate(true, remote, args) end)
        if not ok2 then
            setStatus("Reanimate failed: " .. tostring(res2), true)
            warn("Reanimate error:", res2)
        else
            setStatus("Reanimated")
        end
    else
        setStatus("Stopping reanimation...")
        local ok2, res2 = pcall(function() return API.reanimate(false) end)
        if not ok2 then
            setStatus("Stop failed: " .. tostring(res2), true)
            warn("Stop reanimate error:", res2)
        else
            setStatus("Restored real character")
        end
    end
    refreshToggleLabel()
end

toggleBtn.MouseButton1Click:Connect(toggleReanimate)

-- Play animation
playBtn.MouseButton1Click:Connect(function()
    local url = tostring(urlBox.Text or "")
    if url == "" then
        setStatus("No URL provided", true)
        return
    end
    local speed = tonumber(speedBox.Text) or 1.0
    setStatus("Fetching & playing animation...")
    local ok, res = pcall(function()
        return API.play_animation(url, speed)
    end)
    if not ok then
        setStatus("Play failed: " .. tostring(res), true)
        warn("Play animation error:", res)
    else
        -- API.play_animation returns nothing on success — update UI
        setStatus("Playing animation")
    end
    refreshToggleLabel()
end)

-- Stop animation
stopBtn.MouseButton1Click:Connect(function()
    local ok, res = pcall(function() return API.stop_animation() end)
    if not ok then
        setStatus("Stop animation error: " .. tostring(res), true)
        warn("Stop animation error:", res)
    else
        setStatus("Animation stopped")
    end
end)

-- Change speed live (applies if an animation is playing)
speedBox.FocusLost:Connect(function(enterPressed)
    local s = tonumber(speedBox.Text)
    if s then
        local ok, res = pcall(function() API.set_animation_speed(s) end)
        if not ok then
            setStatus("Speed change failed", true)
            warn("set_animation_speed error:", res)
        else
            setStatus("Speed set to " .. tostring(s))
        end
    else
        setStatus("Invalid speed value", true)
    end
end)

-- Update UI when API callbacks fire (if available)
if API.on_animation_play then
    pcall(function()
        API.on_animation_play(function(url)
            setStatus("Playing: " .. tostring(url))
        end)
    end)
end
if API.on_animation_stop then
    pcall(function()
        API.on_animation_stop(function(url)
            setStatus("Stopped: " .. tostring(url))
        end)
    end)
end

-- Hotkey: RightControl toggles reanimate
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleReanimate()
    end
end)

-- Keep UI toggle label updated every half second (to reflect external changes)
spawn(function()
    while true do
        pcall(refreshToggleLabel)
        wait(0.5)
    end
end)

setStatus("Ready")

