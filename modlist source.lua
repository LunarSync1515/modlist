local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModListUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
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

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.Padding = UDim.new(0, 4)

local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)

local Moderators = {}
local trackedMods = {}

local function add_mod(UserId, Username, Role)
    if Moderators[UserId] then
        Moderators[UserId].Frame:Destroy()
    end

    local ModFrame = Instance.new("Frame")
    ModFrame.Parent = Content
    ModFrame.Size = UDim2.new(1, 0, 0, 15)
    ModFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel")
    Label.Parent = ModFrame
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.RichText = true

    Label.Text = string.format(
        '<font color="#4DA6FF">%s</font>  <font color="#B9B9B9">%s</font>',
        Username,
        Role or "Moderator"
    )

    Moderators[UserId] = {Frame = ModFrame}
end

local function remove_mod(UserId)
    if Moderators[UserId] then
        Moderators[UserId].Frame:Destroy()
        Moderators[UserId] = nil
    end
end

local function CenterAlert(text)
    local AlertGui = Instance.new("ScreenGui", CoreGui)

    local Frame = Instance.new("Frame", AlertGui)
    Frame.Size = UDim2.new(0, 300, 0, 55)
    Frame.Position = UDim2.new(0.5, -150, 0.18, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255,60,60)
    Label.TextScaled = true

    task.delay(3, function()
        AlertGui:Destroy()
    end)
end

local GROUP_ID = 1154360
local MODERATOR_RANK = 15

local SPECIAL_IDS = {
    [2229169589] = "Trial Mod",
    [4243907215] = "Trial Mod",
    [3020799797] = "Trial Mod",
    [30934698] = "Trial Mod",
    [813030262] = "Trial Mod",
    [1406181681] = "Trial Mod",
    [839333692] = "Trial Mod",
    [419652748] = "Trial Mod",
    [353983652] = "Trial Mod",
    [2639766722] = "Trial Mod",
    [8838291970] = "Trial Mod",
    [3004094651] = "Trial Mod",
    [979624578] = "Trial Mod"
}

local function addModerator(player, tag)
    if trackedMods[player.UserId] then return end
    trackedMods[player.UserId] = true

    add_mod(player.UserId, player.Name, tag)
    CenterAlert("STAFF DETECTED\n"..player.Name.." ["..tag.."]")
end

local function removeModerator(player)
    trackedMods[player.UserId] = nil
    remove_mod(player.UserId)
end

local function checkPlayer(player)
    if SPECIAL_IDS[player.UserId] then
        addModerator(player, SPECIAL_IDS[player.UserId])
        return
    end

    if player:IsInGroup(GROUP_ID) then
        if player:GetRankInGroup(GROUP_ID) == MODERATOR_RANK then
            addModerator(player, "Moderator")
            return
        end
    end

    removeModerator(player)
end

for _, p in ipairs(Players:GetPlayers()) do
    checkPlayer(p)
end

Players.PlayerAdded:Connect(checkPlayer)
Players.PlayerRemoving:Connect(removeModerator)
