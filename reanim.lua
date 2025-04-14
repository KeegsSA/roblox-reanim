-- Roblox Reanimation System [Safe + UI v2]
-- Fixed: No Reset | WASD Control | Dropdown Save System

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local SAVE_PATH = "reanim_ids.txt"
local reanimIDs = {}

-- 🔄 Load Save File
pcall(function()
	local data = readfile(SAVE_PATH)
	reanimIDs = HttpService:JSONDecode(data)
end)

-- 🔃 Save to File
local function saveToFile()
	writefile(SAVE_PATH, HttpService:JSONEncode(reanimIDs))
end

-- 🧲 Reanimation System
local function alignPart(part, root)
	local a0 = Instance.new("Attachment", part)
	local a1 = Instance.new("Attachment", root)

	local ap = Instance.new("AlignPosition")
	ap.Attachment0 = a0
	ap.Attachment1 = a1
	ap.MaxForce = math.huge
	ap.Responsiveness = 200
	ap.RigidityEnabled = false
	ap.ReactionForceEnabled = false
	ap.Parent = part

	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = a0
	ao.Attachment1 = a1
	ao.MaxTorque = math.huge
	ao.Responsiveness = 200
	ao.RigidityEnabled = false
	ao.ReactionTorqueEnabled = false
	ao.Parent = part
end

-- ✅ Fix: Disable instead of destroy motors
local function clearMotor6Ds()
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("Motor6D") and obj.Name ~= "RootJoint" then
			obj.Part0 = nil
			obj.Part1 = nil
		end
	end
end

local reanimRoot
local function runReanim()
	if reanimRoot and reanimRoot.Parent then
		reanimRoot:Destroy()
	end

	reanimRoot = Instance.new("Part")
	reanimRoot.Name = "ReanimRoot"
	reanimRoot.Size = Vector3.new(2, 2, 1)
	reanimRoot.Transparency = 1
	reanimRoot.Anchored = false
	reanimRoot.CanCollide = false
	reanimRoot.CFrame = hrp.CFrame
	reanimRoot.Parent = workspace

	clearMotor6Ds()
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part ~= hrp then
			part.CanCollide = false
			alignPart(part, reanimRoot)
		end
	end
	alignPart(hrp, reanimRoot)
end

-- 🎮 WASD Control
local moveDir = Vector3.zero
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then moveDir += Vector3.new(0, 0, -1) end
		if input.KeyCode == Enum.KeyCode.S then moveDir += Vector3.new(0, 0, 1) end
		if input.KeyCode == Enum.KeyCode.A then moveDir += Vector3.new(-1, 0, 0) end
		if input.KeyCode == Enum.KeyCode.D then moveDir += Vector3.new(1, 0, 0) end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then moveDir -= Vector3.new(0, 0, -1) end
		if input.KeyCode == Enum.KeyCode.S then moveDir -= Vector3.new(0, 0, 1) end
		if input.KeyCode == Enum.KeyCode.A then moveDir -= Vector3.new(-1, 0, 0) end
		if input.KeyCode == Enum.KeyCode.D then moveDir -= Vector3.new(1, 0, 0) end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if reanimRoot then
		local move = hrp.CFrame:VectorToWorldSpace(moveDir) * (10 * dt)
		reanimRoot.CFrame = reanimRoot.CFrame + move
	end
end)

-- 🟣 GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ReanimGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 420)
frame.Position = UDim2.new(0, 20, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(32, 0, 64) -- Midnight purple
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Draggable
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Title Label
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 0)
label.Text = "🧍 Reanim System"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.BackgroundTransparency = 1

-- Input Box for New ID
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0.8, 0, 0, 30)
idBox.Position = UDim2.new(0.1, 0, 0, 40)
idBox.PlaceholderText = "Enter new reanimation name"
idBox.Font = Enum.Font.Gotham
idBox.TextColor3 = Color3.new(1, 1, 1)
idBox.BackgroundColor3 = Color3.fromRGB(70, 20, 120)
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)

-- Dropdown Menu
local dropLabel = Instance.new("TextLabel", frame)
dropLabel.Size = UDim2.new(0.8, 0, 0, 20)
dropLabel.Position = UDim2.new(0.1, 0, 0, 80)
dropLabel.Text = "Select Saved Reanimation:"
dropLabel.TextColor3 = Color3.new(1, 1, 1)
dropLabel.Font = Enum.Font.Gotham
dropLabel.TextSize = 14
dropLabel.BackgroundTransparency = 1

local dropdown = Instance.new("TextButton", frame)
dropdown.Size = UDim2.new(0.8, 0, 0, 30)
dropdown.Position = UDim2.new(0.1, 0, 0, 110)
dropdown.BackgroundColor3 = Color3.fromRGB(100, 40, 160)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14
dropdown.Text = "Select Animation"
Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

local selectedID = nil
dropdown.MouseButton1Click:Connect(function()
	local menu = Instance.new("Frame", frame)
	menu.Size = UDim2.new(0.8, 0, 0, 150)
	menu.Position = UDim2.new(0.1, 0, 0, 150)
	menu.BackgroundColor3 = Color3.fromRGB(50, 20, 80)
	menu.ZIndex = 5
	menu.ClipsDescendants = true
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)

	for idName, _ in pairs(reanimIDs) do
		local btn = Instance.new("TextButton", menu)
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Position = UDim2.new(0, 0, 0, (#menu:GetChildren() - 1) * 30)
		btn.BackgroundColor3 = Color3.fromRGB(100, 50, 160)
		btn.Text = idName
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.ZIndex = 6
		btn.MouseButton1Click:Connect(function()
			selectedID = idName
			dropdown.Text = "Selected: " .. idName
			menu:Destroy()
		end)
	end
end)

-- Utility: Make Button
local function createButton(text, yOffset, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.8, 0, 0, 30)
	btn.Position = UDim2.new(0.1, 0, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
end

createButton("▶ Reanimate", 310, function()
	if selectedID then
		runReanim()
	end
end)

createButton("💾 Save New ID", 350, function()
	local id = idBox.Text
	if id and id ~= "" then
		reanimIDs[id] = true
		saveToFile()
	end
end)

createButton("❌ Close GUI", 390, function()
	gui:Destroy()
end)
