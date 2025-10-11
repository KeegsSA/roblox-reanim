-- PhantomRig Lite – Reanimation Only
-- by Keegan (Toihz)
-- Midnight purple theme with rounded UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

--// Reanimation API fetch
local function getReanimAPI()
	local mod = ReplicatedStorage:FindFirstChild("ReanimateAPI")
	if mod and mod:IsA("ModuleScript") then
		local ok, api = pcall(require, mod)
		if ok and type(api) == "table" then return api end
	end
	if _G.ReanimateAPI and type(_G.ReanimateAPI) == "table" then
		return _G.ReanimateAPI
	end
	if _G.API and type(_G.API) == "table" then
		return _G.API
	end
	if type(API) == "table" then
		return API
	end
	return nil
end

local API = getReanimAPI()

--// GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "PhantomRigLite"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 180)
frame.Position = UDim2.new(0.5, -200, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(25, 0, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", frame)
title.Text = "PhantomRig"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 180, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
minimizeBtn.Position = UDim2.new(1, -45, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local reanimBtn = Instance.new("TextButton", frame)
reanimBtn.Size = UDim2.new(0.8, 0, 0, 45)
reanimBtn.Position = UDim2.new(0.1, 0, 0.5, -22)
reanimBtn.Text = "Reanimate: OFF"
reanimBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 140)
reanimBtn.TextColor3 = Color3.new(1, 1, 1)
reanimBtn.Font = Enum.Font.GothamBold
reanimBtn.TextScaled = true
Instance.new("UICorner", reanimBtn).CornerRadius = UDim.new(0, 10)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0, 40)
status.Position = UDim2.new(0, 0, 1, -40)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(220, 200, 255)
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.Text = ""

--// State
local minimized = false
local guiVisible = true
local toggleKey = Enum.KeyCode.RightShift

--// Functions
local function updateButton()
	if API and API.is_reanimated and API.is_reanimated() then
		reanimBtn.Text = "Reanimate: ON"
		reanimBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 160)
	else
		reanimBtn.Text = "Reanimate: OFF"
		reanimBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 140)
	end
end

local function setStatus(text)
	status.Text = text
end

--// Minimize behavior
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	reanimBtn.Visible = not minimized
	frame.Size = minimized and UDim2.new(0, 400, 0, 50) or UDim2.new(0, 400, 0, 180)
end)

--// Reanimate toggle
reanimBtn.MouseButton1Click:Connect(function()
	API = API or getReanimAPI()
	if not API then
		setStatus("⚠️ API not found")
		return
	end
	local ok, result = pcall(function()
		if API.is_reanimated and API.is_reanimated() then
			API.reanimate(false)
		else
			API.reanimate(true)
		end
	end)
	if not ok then
		setStatus("Error: " .. tostring(result))
	else
		setStatus("Toggled reanimation")
	end
	updateButton()
end)

--// GUI toggle key
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == toggleKey then
		guiVisible = not guiVisible
		gui.Enabled = guiVisible
	end
end)

--// Initial check
if API then
	setStatus("✅ API Loaded")
else
	setStatus("⚠️ No Reanimation API found")
end

updateButton()
