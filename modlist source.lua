local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModListUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Name = "ModList"
Frame.Size = UDim2.new(0, 200, 0, 0)
Frame.Position = UDim2.new(1, -220, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
Frame.AutomaticSize = Enum.AutomaticSize.Y
Frame.BorderSizePixel = 0

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Frame
Stroke.Color = Color3.fromRGB(46, 52, 61)

local TopBar = Instance.new("Frame")
TopBar.Parent = Frame
TopBar.Size = UDim2.new(1, 18, 0, 3)
TopBar.Position = UDim2.new(0, -9, 0, -9)
TopBar.BorderSizePixel = 0
TopBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

local Padding = Instance.new("UIPadding")
Padding.Parent = Frame
Padding.PaddingTop = UDim.new(0, 9)
Padding.PaddingBottom = UDim.new(0, 9)
Padding.PaddingLeft = UDim.new(0, 9)
Padding.PaddingRight = UDim.new(0, 9)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 15)
Title.Font = Enum.Font.SourceSans
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Moderators"

local Divider = Instance.new("Frame")
Divider.Parent = Frame
Divider.Position = UDim2.new(0, 0, 0, 21)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.BorderSizePixel = 0
Divider.BackgroundColor3 = Color3.fromRGB(46, 52, 61)

local Content = Instance.new("Frame")
Content.Parent = Frame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 28)
Content.Size = UDim2.new(1, 0, 0, 0)
Content.AutomaticSize = Enum.AutomaticSize.Y
Content.BorderSizePixel = 0

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.Padding = UDim.new(0, 4)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

--// Mod list storage
local Moderators = {}
local trackedMods = {}

local function add_mod(UserId, Username, Role)
    Role = Role or "Moderator"

    if Moderators[UserId] then
        Moderators[UserId].Frame:Destroy()
        Moderators[UserId] = nil
    end

    local ModFrame = Instance.new("Frame")
    ModFrame.Parent = Content
    ModFrame.BackgroundTransparency = 1
    ModFrame.Size = UDim2.new(1, 0, 0, 15)
    ModFrame.BorderSizePixel = 0

    local Line = Instance.new("TextLabel")
    Line.Parent = ModFrame
    Line.BackgroundTransparency = 1
    Line.Size = UDim2.new(1, 0, 0, 15)
    Line.Font = Enum.Font.SourceSans
    Line.TextSize = 14
    Line.TextXAlignment = Enum.TextXAlignment.Left
    Line.TextColor3 = Color3.fromRGB(255, 255, 255)
    Line.RichText = true
    Line.Text = string.format(
        '<font color="#4DA6FF">%s</font>  <font color="#B9B9B9">%s</font>',
        tostring(Username),
        tostring(Role)
    )

    Moderators[UserId] = {
        Frame = ModFrame,
        Username = Username,
        Role = Role,
    }
end

local function remove_mod(UserId)
    local ModData = Moderators[UserId]
    if ModData then
        ModData.Frame:Destroy()
        Moderators[UserId] = nil
    end
end

--// Alert from source logic
local function CenterAlert(text, duration)
    duration = duration or 3

    local old = CoreGui:FindFirstChild("ModeratorAlert")
    if old then
        old:Destroy()
    end

    local AlertGui = Instance.new("ScreenGui")
    AlertGui.Name = "ModeratorAlert"
    AlertGui.ResetOnSpawn = false
    AlertGui.Parent = CoreGui

    local AlertFrame = Instance.new("Frame")
    AlertFrame.Size = UDim2.new(0, 300, 0, 55)
    AlertFrame.Position = UDim2.new(0.5, -150, 0.18, 0)
    AlertFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    AlertFrame.BorderSizePixel = 0
    AlertFrame.Parent = AlertGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = AlertFrame

    local AlertStroke = Instance.new("UIStroke")
    AlertStroke.Color = Color3.fromRGB(255, 60, 60)
    AlertStroke.Thickness = 2
    AlertStroke.Parent = AlertFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 1, -12)
    Label.Position = UDim2.new(0, 6, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 60, 60)
    Label.TextScaled = true
    Label.Font = Enum.Font.GothamBold
    Label.Parent = AlertFrame

    task.delay(duration, function()
        if AlertGui and AlertGui.Parent then
            AlertGui:Destroy()
        end
    end)
end

--// Detection values from source
local GROUP_ID = 1154360
local MODERATOR_RANK = 15

local SPECIAL_IDS = {
    [2229169589] = "Trial Mod",
    [4243907215] = "Trial Mod",
    [3020799797] = "Trial Mod",
    [30934698]   = "Trial Mod",
    [813030262]  = "Trial Mod",
    [1406181681] = "Trial Mod",
    [839333692]  = "Trial Mod",
    [419652748]  = "Trial Mod",
    [353983652]  = "Trial Mod",
    [2639766722] = "Trial Mod",
    [8838291970] = "Trial Mod",
    [3004094651] = "Trial Mod",
    [979624578]  = "Trial Mod",
}

local function addModerator(player, tag)
    if trackedMods[player.UserId] then
        return
    end

    trackedMods[player.UserId] = true
    add_mod(player.UserId, player.Name, tag)

    warn(("STAFF DETECTED: %s [%s]"):format(player.Name, tag))
    CenterAlert("STAFF DETECTED\n" .. player.Name .. " [" .. tag .. "]", 3)
end

local function removeModerator(player)
    if trackedMods[player.UserId] then
        trackedMods[player.UserId] = nil
        remove_mod(player.UserId)
    end
end

local function checkPlayer(player)
    local manualTag = SPECIAL_IDS[player.UserId]
    if manualTag then
        addModerator(player, manualTag)
        return
    end

    if not player:IsInGroup(GROUP_ID) then
        removeModerator(player)
        return
    end

    local rank = player:GetRankInGroup(GROUP_ID)

    if rank == MODERATOR_RANK then
        addModerator(player, "Moderator")
    else
        removeModerator(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    checkPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    checkPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeModerator(player)
end)
