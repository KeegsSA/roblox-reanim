-- PhantomRig (uses Reanimation API)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Try to get the reanimation API from common places
local ReanimAPI
local function try_get_api()
    -- try ReplicatedStorage ModuleScript named "ReanimateAPI"
    local mod = ReplicatedStorage:FindFirstChild("ReanimateAPI")
    if mod and mod:IsA("ModuleScript") then
        local ok, result = pcall(require, mod)
        if ok and type(result) == "table" then
            return result
        end
    end
    -- try _G
    if _G and type(_G.ReanimateAPI) == "table" then
        return _G.ReanimateAPI
    end
    -- try global variable API (if the user inserted it in same env)
    if type(API) == "table" then
        return API
    end
    return nil
end

ReanimAPI = try_get_api()

-- State
local savedAnimations = {} -- { {name=..., url=...}, ... }
local reanimationEnabled = true
local guiVisible = true
local toggleKey = Enum.KeyCode.RightShift
local guiToggleKey = Enum.KeyCode.F1
local animationSpeed = 1
local selectedAnimIndex = nil
local voidWalkEnabled = true -- Automatically enable Void Walk

-- GUI Construction (kept structure from your original)
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

-- Pages
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
showPage("Reanimation")

-- Reanimation Page Elements
local nameInput = Instance.new("TextBox", reanimPage)
nameInput.PlaceholderText = "Name (optional)"
nameInput.Size = UDim2.new(1, 0, 0, 30)
nameInput.BackgroundColor3 = Color3.fromRGB(50, 0, 75)
nameInput.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

local animInput = Instance.new("TextBox", reanimPage)
animInput.PlaceholderText = "Animation URL (keyframe script)"
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

-- Status Label
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
statusLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextScaled = true
statusLabel.TextAlignment = Enum.TextAlignment.Center

if not ReanimAPI then
    statusLabel.Text = "Reanimation API not found. Put ModuleScript named 'ReanimateAPI' in ReplicatedStorage or set global API."
end

-- Helpers
local function updateDropdown(filter)
    filter = (filter or ""):lower()
    for _, child in ipairs(dropdown:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 0
    for i, anim in ipairs(savedAnimations) do
        if filter == "" or (anim.name and anim.name:lower():find(filter)) or (anim.url and anim.url:lower():find(filter)) then
            local b = Instance.new("TextButton", dropdown)
            b.Size = UDim2.new(1, -4, 0, 28)
            b.Position = UDim2.new(0, 2, 0, y)
            b.Text = (anim.name and (#anim.name > 0) and anim.name) or anim.url
            b.BackgroundTransparency = 0.9
            b.TextColor3 = Color3.new(1,1,1)
            b.AnchorPoint = Vector2.new(0,0)
            b.MouseButton1Click:Connect(function()
                selectedAnimIndex = i
                -- highlight selection
                for _, ch in ipairs(dropdown:GetChildren()) do
                    if ch:IsA("TextButton") then
                        ch.BackgroundColor3 = Color3.fromRGB(40,0,60)
                    end
                end
                b.BackgroundColor3 = Color3.fromRGB(80,0,120)
            end)
            y = y + 30
        end
    end
    dropdown.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Speed slider interaction
local dragging = false
speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.Heartbeat:Connect(function()
    if dragging then
        local mouseX = UIS:GetMouseLocation().X
        local guiPos = speedSlider.AbsolutePosition.X
        local guiSize = speedSlider.AbsoluteSize.X
        local relative = math.clamp((mouseX - guiPos) / guiSize, 0, 1)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        local newSpeed = math.floor((relative * 20) + 1) / 10 -- map to 0.1 to 2.1 roughly
        animationSpeed = math.clamp(newSpeed, 0.1, 2)
        speedLabel.Text = ("Speed: %.1fx"):format(animationSpeed)
        if ReanimAPI and ReanimAPI.set_animation_speed then
            ReanimAPI.set_animation_speed(animationSpeed)
        end
    end
end)

-- Save & Play
playButton.MouseButton1Click:Connect(function()
    local url = animInput.Text ~= "" and animInput.Text or (selectedAnimIndex and savedAnimations[selectedAnimIndex] and savedAnimations[selectedAnimIndex].url)
    if not url or url == "" then
        statusLabel.Text = "No animation URL provided or selected."
        return
    end
    local name = nameInput.Text
    -- save to list
    table.insert(savedAnimations, {name = name or "", url = url})
    updateDropdown(searchBox.Text)
    -- ensure API available
    ReanimAPI = ReanimAPI or try_get_api()
    if not ReanimAPI then
        statusLabel.Text = "Reanimation API not found."
        return
    end
    -- ensure reanimated
    if not ReanimAPI.is_reanimated or not ReanimAPI.is_reanimated() then
        local ok, err = pcall(function() ReanimAPI.reanimate(true) end)
        if not ok then
            statusLabel.Text = "Reanimate failed: " .. tostring(err)
            return
        end
    end
    -- set speed and play
    if ReanimAPI.set_animation_speed then ReanimAPI.set_animation_speed(animationSpeed) end
    local ok, err = pcall(function() ReanimAPI.play_animation(url, animationSpeed) end)
    if not ok then
        statusLabel.Text = "Play failed: " .. tostring(err)
        return
    end
    statusLabel.Text = "Playing animation."
end)

-- Toggle reanimation
local function updateToggleText()
    if ReanimAPI and ReanimAPI.is_reanimated and ReanimAPI.is_reanimated() then
        toggleBtn.Text = "Reanimation: ON"
    else
        toggleBtn.Text = "Reanimation: OFF"
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    ReanimAPI = ReanimAPI or try_get_api()
    if not ReanimAPI then
        statusLabel.Text = "Reanimation API not found."
        return
    end
    if ReanimAPI.is_reanimated and ReanimAPI.is_reanimated() then
        pcall(function() ReanimAPI.reanimate(false) end)
        statusLabel.Text = "Reanimation disabled."
    else
        pcall(function() ReanimAPI.reanimate(true) end)
        statusLabel.Text = "Reanimation enabled."
    end
    updateToggleText()
end)

-- minimize / restore
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    sidePanel.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 200, 0, 60) or UDim2.new(0, 650, 0, 500)
end)

-- search
searchBox.Changed:Connect(function()
    updateDropdown(searchBox.Text)
end)

-- GUI toggle key
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == guiToggleKey then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
    elseif input.KeyCode == toggleKey then
        -- toggle reanimate quickly
        ReanimAPI = ReanimAPI or try_get_api()
        if ReanimAPI and ReanimAPI.is_reanimated and ReanimAPI.reanimate then
            if ReanimAPI.is_reanimated() then
                pcall(function() ReanimAPI.reanimate(false) end)
            else
                pcall(function() ReanimAPI.reanimate(true) end)
            end
            updateToggleText()
        else
            statusLabel.Text = "Reanimation API not available."
        end
    end
end)

-- Target actions
local function getPlayerByNamePart(namePart)
    if not namePart or namePart == "" then return nil end
    namePart = namePart:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(namePart) or (p.DisplayName and p.DisplayName:lower():find(namePart)) then
            return p
        end
    end
    return nil
end

local function moveCloneToTarget(targetPlayer, offsetCFrame)
    ReanimAPI = ReanimAPI or try_get_api()
    if not ReanimAPI then
        statusLabel.Text = "Reanimation API not found."
        return
    end
    local clone = ReanimAPI.get_clone and ReanimAPI.get_clone()
    if not clone or not clone.Parent then
        statusLabel.Text = "Clone not available. Reanimate first."
        return
    end
    local targetChar = targetPlayer.Character
    if not targetChar or not targetChar.Parent then
        statusLabel.Text = "Target has no character."
        return
    end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local cloneHRP = clone:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not cloneHRP then
        statusLabel.Text = "HumanoidRootPart missing."
        return
    end
    offsetCFrame = offsetCFrame or CFrame.new(0, 0, 0)
    -- try to place clone near target, repeated attempt in case reanimation heartbeat adjusts it
    cloneHRP.CFrame = targetHRP.CFrame * offsetCFrame
    statusLabel.Text = "Moved clone near target."
end

headsitBtn.MouseButton1Click:Connect(function()
    local target = getPlayerByNamePart(targetBox.Text)
    if not target then
        statusLabel.Text = "Target not found."
        return
    end
    -- small offset to sit on head
    moveCloneToTarget(target, CFrame.new(0, 2.2, 0))
end)

standBtn.MouseButton1Click:Connect(function()
    local target = getPlayerByNamePart(targetBox.Text)
    if not target then
        statusLabel.Text = "Target not found."
        return
    end
    -- stand beside (to the right)
    moveCloneToTarget(target, CFrame.new(1.2, 0, 0))
end)

-- Headsit tool (simple: click to pick target under mouse)
selectToolBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "Click a player to select them as target."
    local conn
    conn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = Mouse.Target
            if target then
                local char = target:FindFirstAncestorOfClass("Model")
                if char and Players:GetPlayerFromCharacter(char) then
                    local p = Players:GetPlayerFromCharacter(char)
                    targetBox.Text = p.Name
                    statusLabel.Text = "Selected: " .. p.Name
                else
                    statusLabel.Text = "No player under mouse."
                end
            else
                statusLabel.Text = "No target under mouse."
            end
            conn:Disconnect()
        end
    end)
end)

-- Keep toggle button text in sync if API callbacks exist
if ReanimAPI and ReanimAPI.on_animation_play then
    ReanimAPI.on_animation_play(function(url)
        statusLabel.Text = "Animation started: " .. tostring(url)
    end)
end
if ReanimAPI and ReanimAPI.on_animation_stop then
    ReanimAPI.on_animation_stop(function(url)
        statusLabel.Text = "Animation stopped: " .. tostring(url)
    end)
end

-- Auto-enable Void Walk (kept from your original)
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

if voidWalkEnabled then
    enableVoidWalk()
end

-- initialize dropdown
updateDropdown()

-- initial toggle text
updateToggleText()
