-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

task.spawn(function()
	local Players = game:GetService("Players")

	local LocalPlayer = Players.LocalPlayer
	while not LocalPlayer do
		task.wait()
		LocalPlayer = Players.LocalPlayer
	end

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)

	if not PlayerGui then
		warn("PlayerGui was not found; skipping TopbarPlus cleanup")
		return
	end

	local elementsToDelete = {
		TopbarCentered = true,
		TopbarCenteredClipped = true,
		TopbarStandard = true,
		TopbarStandardClipped = true,
		TopbarPlus = true,
		TopbarContainer = true,
	}

	local function RemoveTopbarPlusObject(object)
		if object and elementsToDelete[object.Name] then
			object:Destroy()
		end
	end

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		RemoveTopbarPlusObject(object)
	end

	PlayerGui.DescendantAdded:Connect(function(object)
		if elementsToDelete[object.Name] then
			task.defer(function()
				if object and object.Parent then
					object:Destroy()
				end
			end)
		end
	end)
end)
-- Functions
local Hide = function(Object, Property)
    if not Object or not Property then
        warn(`{Object}.{Property} ({debug.traceback()})`)
    end
    
    Object[Property] = false
    Object:GetPropertyChangedSignal(Property):Connect(function()
        Object[Property] = false
    end)
end

local Create = function(Class: string, Properties: { [string]: any })
	local Object = Instance.new(Class);

	for Property, Value in next, (Properties or {}) do
		Object[Property] = Value
	end

	return Object
end

local ChangeName = function(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if (Humanoid and Humanoid.DisplayName == Player.DisplayName) then
        Humanoid.DisplayName = Player.Name
    else
        Character.ChildAdded:Connect(function(Humanoid)
            if (Humanoid:IsA("Humanoid") and Humanoid.DisplayName == Player.DisplayName) then
                Humanoid.DisplayName = Player.Name
            end
        end)
    end
end

local NameChanger = function(Player)
    task.spawn(ChangeName, Player)
    Player.CharacterAdded:Connect(function()
        task.spawn(ChangeName, Player)
    end)
end

-- Variables
local Settings = getgenv().LegacySettings or ({
    Year = 2017,
    OldGraphics = true,
    HideDisplayName = true,
	AccountCategory = "13+",
})

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local RBXM = getgenv().RBXMSuite or loadstring(game:HttpGetAsync("https://github.com/RezyPlayz/rbxm-suite/releases/latest/download/rbxm-suite.lua"))()
local Source = RBXM.download("RezyPlayz/Legacy@latest", "Legacy.rbxm")
local Module = RBXM.launch(Source, {
    runscripts = true,
    deferred = true,
    nocirculardeps = true
})

-- Setup
RobloxGui.Enabled = false
RBXM.require(Module):Start(Settings.Year)
task.spawn(Hide, CoreGui:WaitForChild("TopBarApp", 10):WaitForChild("TopBarApp", 10), "Enabled")

if (Settings.OldGraphics) then
    task.spawn(function()
        Lighting.GlobalShadows = false

        for _, Object in next, Lighting:GetChildren() do
            if (table.find({ "DepthOfFieldEffect", "SunRaysEffect", "BloomEffect", "BlurEffect", "ColorCorrectionEffect", "Atmosphere" }, Object.ClassName)) then
                if (not Object:IsA("Atmosphere")) then
                    Hide(Object, "Enabled")
                else
                    Object:Destroy()
                end
            end
        end

        Create("ColorCorrectionEffect", {
            Parent = Lighting,
            Saturation = 0,
            Contrast = -0.1,
        })

        if (sethiddenproperty) then
            sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility);
        end
    end)
end

if (Settings.HideDisplayName) then
    for _, Player in next, Players:GetPlayers() do
        NameChanger(Player)
    end

    Players.PlayerAdded:Connect(NameChanger)
end

task.spawn(function()
    local SettingsShield = RobloxGui:WaitForChild("SettingsClippingShield"):WaitForChild("SettingsShield")
    local Modal = SettingsShield and SettingsShield:WaitForChild("Modal")

    if (SettingsShield) then
        Hide(Modal, "Visible")
        Hide(Modal, "Modal")
    end
end)

task.spawn(function()
    local ControlFrame = RobloxGui:WaitForChild("ControlFrame", 10)

    if (ControlFrame) then
        ControlFrame:Destroy()
    end
end)
