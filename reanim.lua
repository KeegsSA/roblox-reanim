-- ✅ REANIMATION API (auto-exposes as _G.API)
-- Paste this anywhere (preferably in StarterPlayerScripts or as a ModuleScript)
-- It will automatically register itself globally for other scripts to use.

local fbi = {
	services = {
		players = game:GetService("Players");
		workspace = game:GetService("Workspace");
		replicated = game:GetService("ReplicatedStorage");
		run_service = game:GetService("RunService");
		user_input_service = game:GetService("UserInputService");
		http_service = game:GetService("HttpService");
	};
	flags = { reanimated = false; };
	clones = {};
	connections = {
		hb = nil;
		died = nil;
		real_char_child_removed = nil;
		character_removing = nil;
		clone_died = nil;
		clone_char_child_removed = nil;
		animation_hb = nil;
	};
	real_chars = {};
	callbacks = { on_play = nil, on_stop = nil };
	animation = {
		cache = {};
		state = {
			is_playing = false;
			current_url = nil;
			speed = 1.0;
			keyframes = nil;
			total_duration = 0;
			elapsed_time = 0;
		};
		original_motor_c0s = {};
		joints = {};
	};
};

local API = {}

local set_model_transparency = function(model, transparency)
	if not model then return end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = transparency
		end
	end
end

local get_local_player = function()
	local player = fbi.services.players.LocalPlayer
	if not player then
		return "bad argument to 'get_local_player' (LocalPlayer not found; must run in a LocalScript)"
	end
	return player
end

local get_char = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return ("bad argument #1 to 'get_char' (Player expected, got %s)"):format(typeof(player))
	end
	local character = player.Character
	if not character or not character.Parent then
		return ("Player %s has no active character."):format(player.Name)
	end
	return character
end

local clone_char = function(model)
	if typeof(model) ~= "Instance" then
		return ("bad argument #1 to 'clone_char' (Instance expected, got %s)"):format(typeof(model))
	end
	model.Archivable = true
	local new_clone = model:Clone()
	model.Archivable = false
	new_clone.Name = "Reanimation"
	new_clone.Parent = fbi.services.workspace
	new_clone:WaitForChild("Animate").Disabled = true
	new_clone.Humanoid.RequiresNeck = false
	new_clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	if new_clone:FindFirstChildWhichIsA("ForceField") then
		new_clone:FindFirstChildWhichIsA("ForceField"):Destroy()
	end
	return new_clone
end

local fire_remote = function(remote, ...)
	if typeof(remote) ~= "Instance" then
		return ("bad argument to 'fire_remote' (Instance expected, got %s)"):format(typeof(remote))
	end
	if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
		return ("bad argument to 'fire_remote' (RemoteEvent or RemoteFunction expected, got %s)"):format(remote.ClassName)
	end
	if remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		remote:InvokeServer(...)
	end
end

-- STOP ANIMATION
API.stop_animation = function()
	if not fbi.animation.state.is_playing then return end
	local stopped_url = fbi.animation.state.current_url
	if fbi.connections.animation_hb then
		fbi.connections.animation_hb:Disconnect()
		fbi.connections.animation_hb = nil
	end
	local player = get_local_player()
	if typeof(player) == "string" then return player end
	local clone_char = API.get_clone(player)
	if clone_char then
		for motor, orig_c0 in pairs(fbi.animation.original_motor_c0s) do
			if motor and motor.Parent then
				motor.C0 = orig_c0
			end
		end
		local clone_animate_script = clone_char:FindFirstChild("Animate")
		if clone_animate_script then clone_animate_script.Enabled = true end
	end
	table.clear(fbi.animation.original_motor_c0s)
	table.clear(fbi.animation.joints)
	fbi.animation.state = {
		is_playing = false,
		current_url = nil,
		speed = 1.0,
		keyframes = nil,
		total_duration = 0,
		elapsed_time = 0
	}
	if fbi.callbacks.on_stop then pcall(fbi.callbacks.on_stop, stopped_url) end
end

-- REANIMATE
API.reanimate = function(bool, remote, args)
	if bool ~= true and bool ~= false then
		return ("bad argument #1 to 'reanimate' (boolean expected, got %s)"):format(typeof(bool))
	end
	local player = get_local_player()
	if typeof(player) == "string" then return player end

	if bool then
		if fbi.flags.reanimated then return "Already reanimated." end
		local real_char = get_char(player)
		if typeof(real_char) == "string" then return real_char end
		if not real_char:FindFirstChild("Humanoid") then return "Real character missing Humanoid." end
		local real_hrp = real_char:FindFirstChild("HumanoidRootPart")
		if not real_hrp then return "Real character missing HumanoidRootPart" end

		fbi.real_chars[player] = real_char
		local cloned_char = clone_char(real_char)
		if typeof(cloned_char) == "string" then return cloned_char end
		if not cloned_char:FindFirstChild("Humanoid") then return "Clone missing Humanoid" end

		fbi.clones[player] = cloned_char
		set_model_transparency(cloned_char, 1)
		player.Character = cloned_char
		cloned_char:WaitForChild("Animate").Disabled = false

		fbi.connections.hb = fbi.services.run_service.Heartbeat:Connect(function()
			if not real_char or not cloned_char or not cloned_char.Parent then
				API.reanimate(false, remote, args)
				return
			end
			for _, p in real_char:GetChildren() do
				local clone_part = cloned_char:FindFirstChild(p.Name)
				if p:IsA("BasePart") and clone_part then
					p.CFrame = clone_part.CFrame
					p.Velocity = Vector3.zero
				end
			end
		end)

		fbi.connections.died = real_char:WaitForChild("Humanoid").Died:Connect(function()
			API.reanimate(false, remote, args)
		end)

		fbi.flags.reanimated = true
	else
		if not fbi.flags.reanimated then return end
		API.stop_animation()
		for _, conn in pairs(fbi.connections) do
			if conn then conn:Disconnect() end
		end
		table.clear(fbi.connections)
		local player = get_local_player()
		local clone = fbi.clones[player]
		local real = fbi.real_chars[player]
		if clone and clone.Parent then clone:Destroy() end
		if real and real.Parent then
			set_model_transparency(real, 0)
			player.Character = real
		end
		fbi.flags.reanimated = false
	end
end

-- PLAY ANIMATION
API.play_animation = function(url, speed)
	if not fbi.flags.reanimated then return "Cannot play animation, not reanimated." end
	local player = get_local_player()
	if typeof(player) == "string" then return player end
	local clone_char = API.get_clone(player)
	if not clone_char then return "Clone not found." end

	API.stop_animation()
	local anim = fbi.animation
	anim.state.speed = tonumber(speed) or 1.0

	local keyframe_data = anim.cache[url]
	if not keyframe_data then
		local ok, response = pcall(game.HttpGet, game, url)
		if not ok then return "Animation Error: Failed to fetch URL." end
		local fn, err = loadstring(response)
		if not fn then return "Animation Error: Invalid script. " .. tostring(err) end
		local success, data = pcall(fn)
		if not success then return "Animation Error: Failed to execute. " .. tostring(data) end
		if typeof(data) ~= "table" then return "Animation Error: Expected table return." end
		keyframe_data = data
		anim.cache[url] = keyframe_data
	end

	local keyframes = keyframe_data[next(keyframe_data)]
	if not keyframes or #keyframes == 0 then return "No keyframes found." end
	anim.state.keyframes = keyframes
	table.clear(anim.joints)
	table.clear(anim.original_motor_c0s)

	for _, d in ipairs(clone_char:GetDescendants()) do
		if d:IsA("Motor6D") then
			anim.joints[d.Part1.Name] = d
			anim.original_motor_c0s[d] = d.C0
		end
	end

	anim.state.is_playing = true
	anim.state.current_url = url
	anim.state.total_duration = keyframes[#keyframes].Time
	anim.state.elapsed_time = 0

	if fbi.callbacks.on_play then pcall(fbi.callbacks.on_play, url) end

	fbi.connections.animation_hb = fbi.services.run_service.Heartbeat:Connect(function(dt)
		if not anim.state.is_playing then return end
		anim.state.elapsed_time = (anim.state.elapsed_time + dt * anim.state.speed) % anim.state.total_duration
		local cf, nf
		for i = 1, #anim.state.keyframes - 1 do
			if anim.state.elapsed_time >= anim.state.keyframes[i].Time and anim.state.elapsed_time < anim.state.keyframes[i+1].Time then
				cf = anim.state.keyframes[i]
				nf = anim.state.keyframes[i+1]
				break
			end
		end
		cf = cf or anim.state.keyframes[#anim.state.keyframes]
		nf = nf or anim.state.keyframes[1]
		local dur = nf.Time - cf.Time
		if dur <= 0 then dur = anim.state.total_duration end
		local alpha = math.clamp((anim.state.elapsed_time - cf.Time) / dur, 0, 1)
		for partName, pose in pairs(cf.Data) do
			local motor = anim.joints[partName]
			if motor and anim.original_motor_c0s[motor] then
				local orig = anim.original_motor_c0s[motor]
				local nextPose = nf.Data and nf.Data[partName]
				motor.C0 = orig * (nextPose and pose:Lerp(nextPose, alpha) or pose)
			end
		end
	end)
end

-- SPEED CONTROL
API.set_animation_speed = function(speed)
	fbi.animation.state.speed = tonumber(speed) or 1.0
end

API.on_animation_play = function(callback)
	if type(callback) == "function" then fbi.callbacks.on_play = callback end
end

API.on_animation_stop = function(callback)
	if type(callback) == "function" then fbi.callbacks.on_stop = callback end
end

API.is_animation_playing = function()
	return fbi.animation.state.is_playing, fbi.animation.state.current_url
end

API.is_reanimated = function()
	return fbi.flags.reanimated
end

API.get_clone = function(player)
	player = player or get_local_player()
	if typeof(player) == "string" then return nil end
	return fbi.clones[player]
end

API.get_real_character = function(player)
	player = player or get_local_player()
	if typeof(player) == "string" then return nil end
	return fbi.real_chars[player]
end

-- ✅ Automatically expose globally for other scripts:
_G.API = API

return API
