local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "GOD_VALLEY_HUB"

------------------------------------------------
-- DEVICE DETECT (AUTO)
------------------------------------------------
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isTablet = UIS.TouchEnabled and UIS.KeyboardEnabled
local isPC = UIS.KeyboardEnabled and UIS.MouseEnabled

------------------------------------------------
-- STATE
------------------------------------------------
local openState = false
local fpsTarget = 60

------------------------------------------------
-- OPEN BUTTON
------------------------------------------------
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,60,0,60)
openBtn.Position = UDim2.new(0,15,0.5,-30)
openBtn.BackgroundColor3 = Color3.fromRGB(20,20,25)
openBtn.TextColor3 = Color3.fromRGB(100,200,255)
openBtn.Text = "⚡"

------------------------------------------------
-- MAIN FRAME
------------------------------------------------
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,520,0,420)
frame.Position = UDim2.new(0.5,-260,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(15,15,18)
frame.Visible = false
frame.Active = true
frame.Draggable = true

------------------------------------------------
-- AUTO DEVICE SETTINGS
------------------------------------------------
local function applyDevice()

	if isMobile then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		frame.Size = UDim2.new(0,600,0,520)
		openBtn.Size = UDim2.new(0,80,0,80)

	elseif isTablet then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
		openBtn.Size = UDim2.new(0,70,0,70)

	else
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
	end
end

applyDevice()

------------------------------------------------
-- TITLE
------------------------------------------------
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "👑 GOD VALLEY PRO HUB"
title.TextColor3 = Color3.fromRGB(120,200,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

------------------------------------------------
-- TAB SYSTEM
------------------------------------------------
local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1,0,0,35)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundTransparency = 1

local pages = {}
local yOffset = {}

local function createTab(name, x)
	local b = Instance.new("TextButton", tabFrame)
	b.Size = UDim2.new(0,120,1,0)
	b.Position = UDim2.new(0,x,0,0)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(30,30,35)
	b.TextColor3 = Color3.new(1,1,1)

	local page = Instance.new("Frame", frame)
	page.Size = UDim2.new(1,0,1,-80)
	page.Position = UDim2.new(0,0,0,80)
	page.BackgroundTransparency = 1
	page.Visible = false

	pages[name] = page
	yOffset[name] = 0

	b.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do
			p.Visible = false
		end
		page.Visible = true
	end)
end

createTab("Performance", 0)
createTab("Visual", 120)
createTab("Misc", 240)
createTab("FPS", 360)

pages["Performance"].Visible = true

------------------------------------------------
-- BUTTON SYSTEM
------------------------------------------------
local function addButton(tab, text, callback)
	local y = yOffset[tab]

	local b = Instance.new("TextButton", pages[tab])
	b.Size = UDim2.new(1,-20,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(30,30,35)
	b.TextColor3 = Color3.new(1,1,1)

	yOffset[tab] += 40

	local state = false

	b.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		b.Text = text .. (state and " [ON]" or " [OFF]")
	end)
end

------------------------------------------------
-- PERFORMANCE
------------------------------------------------
addButton("Performance","FPS BOOST",function(on)
	if on then
		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false end
			if v:IsA("BasePart") then
				v.Material=Enum.Material.Plastic
				v.Reflectance=0
			end
		end
		Lighting.GlobalShadows=false
	end
end)

addButton("Performance","ULTRA LOW GRAPHICS",function(on)
	if on then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end
end)

addButton("Performance","DISABLE DECALS",function(on)
	if on then
		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Decal") then v:Destroy() end
		end
	end
end)

addButton("Performance","REMOVE TEXTURES",function(on)
	if on then
		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Texture") then v:Destroy() end
		end
	end
end)

addButton("Performance","FULL BRIGHT",function(on)
	if on then
		Lighting.Ambient=Color3.new(1,1,1)
		Lighting.OutdoorAmbient=Color3.new(1,1,1)
	end
end)

------------------------------------------------
-- VISUAL
------------------------------------------------
addButton("Visual","DISABLE EFFECTS",function(on)
	if on then
		for _,v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then v.Enabled=false end
		end
	end
end)

addButton("Visual","CLEAN LIGHTING",function(on)
	if on then
		for _,v in ipairs(Lighting:GetChildren()) do
			if v:IsA("ColorCorrectionEffect") then v:Destroy() end
		end
	end
end)

------------------------------------------------
-- FPS SYSTEM
------------------------------------------------
local fpsBox = Instance.new("TextBox", pages["FPS"])
fpsBox.Size = UDim2.new(0,250,0,35)
fpsBox.Position = UDim2.new(0,10,0,10)
fpsBox.PlaceholderText = "FPS Ziel (60 / 120 / 144)"
fpsBox.Text = ""
fpsBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
fpsBox.TextColor3 = Color3.new(1,1,1)

fpsBox.FocusLost:Connect(function()
	local v = tonumber(fpsBox.Text)
	if v then
		fpsTarget = v
	end
end)

------------------------------------------------
-- FPS COUNTER
------------------------------------------------
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0,200,0,30)
fpsLabel.Position = UDim2.new(1,-210,0,10)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
fpsLabel.TextColor3 = Color3.fromRGB(0,255,120)

local frames = 0
local last = tick()

RunService.RenderStepped:Connect(function()
	frames += 1
	if tick()-last >= 1 then
		fpsLabel.Text = "FPS: "..frames.." | Target: "..fpsTarget
		frames = 0
		last = tick()
	end
end)

------------------------------------------------
-- AUTO FPS BOOST
------------------------------------------------
local function autoFPSBoost()
	local mem = Stats:GetTotalMemoryUsageMb()

	if mem > 2000 then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	elseif mem > 1200 then
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
	else
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
	end
end

autoFPSBoost()

------------------------------------------------
-- VFX REMOVER (KEEP ANIMATIONS)
------------------------------------------------
local function removeVFX(obj)
	for _,v in ipairs(obj:GetDescendants()) do
		if v:IsA("ParticleEmitter") then v.Enabled = false end
		if v:IsA("Trail") then v.Enabled = false end
		if v:IsA("Beam") then v.Enabled = false end
		if v:IsA("PointLight") or v:IsA("SpotLight") then v.Enabled = false end
	end
end

removeVFX(workspace)

workspace.DescendantAdded:Connect(function(obj)
	task.wait()
	removeVFX(obj)
end)

------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------
openBtn.MouseButton1Click:Connect(function()
	openState = not openState
	frame.Visible = openState
end)
