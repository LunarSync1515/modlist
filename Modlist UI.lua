local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModListUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 0)
Frame.Position = UDim2.new(1, -220, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
Frame.AutomaticSize = Enum.AutomaticSize.Y

local Padding = Instance.new("UIPadding")
Padding.Parent = Frame
Padding.PaddingTop = UDim.new(0, 6)
Padding.PaddingBottom = UDim.new(0, 6)
Padding.PaddingLeft = UDim.new(0, 6)
Padding.PaddingRight = UDim.new(0, 6)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Frame
Layout.Padding = UDim.new(0, 4)

--// MOD LIST SYSTEM
local Moderators = {}

local function add_mod(UserId, Username, Role)
    Role = Role or "Moderator"

    -- remove old if exists
    if Moderators[UserId] then
        Moderators[UserId]:Destroy()
    end

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.RichText = true

    Label.Text = string.format(
        '<font color="#4DA6FF">%s</font>  <font color="#B9B9B9">%s</font>',
        Username,
        Role
    )

    Moderators[UserId] = Label
end

local function remove_mod(UserId)
    if Moderators[UserId] then
        Moderators[UserId]:Destroy()
        Moderators[UserId] = nil
    end
end

local function clear_mods()
    for _, v in pairs(Moderators) do
        v:Destroy()
    end
    Moderators = {}
end
