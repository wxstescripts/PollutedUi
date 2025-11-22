-- PollutedUiLib.lua
local PollutedUiLib = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== UTILS =====
local function createUICorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
end

local function tween(object, properties, duration, style, dir)
    TweenService:Create(object, TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), properties):Play()
end

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ===== LOADING SCREEN =====
function PollutedUiLib:CreateLoadingScreen(text)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "PollutedUILoading"

    local bg = Instance.new("Frame", gui)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
    bg.BackgroundTransparency = 0.2

    local label = Instance.new("TextLabel", bg)
    label.Size = UDim2.new(1,0,0,60)
    label.Position = UDim2.new(0,0,0.5,-30)
    label.BackgroundTransparency = 1
    label.Text = text or "Loading..."
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true

    local barContainer = Instance.new("Frame", bg)
    barContainer.Size = UDim2.new(0.6,0,0,20)
    barContainer.Position = UDim2.new(0.2,0,0.6,0)
    barContainer.BackgroundColor3 = Color3.fromRGB(50,50,50)
    createUICorner(barContainer, 10)

    local bar = Instance.new("Frame", barContainer)
    bar.Size = UDim2.new(0,0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(0,255,128)
    createUICorner(bar, 10)

    tween(bar, {Size = UDim2.new(1,0,1,0)}, 2)
    delay(2, function() gui:Destroy() end)
end

-- ===== MAIN WINDOW =====
function PollutedUiLib:CreateWindow(config)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = config.Title or "PollutedUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, config.Width or 600, 0, config.Height or 450)
    frame.Position = UDim2.new(0.5, -(config.Width or 600)/2, 0.5, -(config.Height or 450)/2)
    frame.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(28,28,28)
    createUICorner(frame, config.CornerRadius or 16)
    frame.ClipsDescendants = true

    makeDraggable(frame)

    -- HEADER
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1,0,0,50)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Polluted UI"
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 28

    -- TABS
    local tabBar = Instance.new("Frame", frame)
    tabBar.Size = UDim2.new(1,0,0,40)
    tabBar.Position = UDim2.new(0,0,0,50)
    tabBar.BackgroundTransparency = 1

    local tabContainer = Instance.new("Frame", frame)
    tabContainer.Size = UDim2.new(1,0,1,-90)
    tabContainer.Position = UDim2.new(0,0,0,90)
    tabContainer.BackgroundTransparency = 1

    local Tabs = {}
    local Buttons = {}

    function frame:CreateTab(name)
        local tab = Instance.new("Frame", tabContainer)
        tab.Size = UDim2.new(1,0,1,0)
        tab.BackgroundTransparency = 1
        tab.Visible = false
        Tabs[name] = tab

        local button = Instance.new("TextButton", tabBar)
        button.Size = UDim2.new(0,120,1,0)
        button.Position = UDim2.new(0,#Buttons*120,0,0)
        button.BackgroundColor3 = Color3.fromRGB(40,40,40)
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 18
        createUICorner(button, 6)

        button.MouseEnter:Connect(function()
            tween(button, {BackgroundColor3 = Color3.fromRGB(0,255,128)}, 0.15)
        end)
        button.MouseLeave:Connect(function()
            if not tab.Visible then
                tween(button, {BackgroundColor3 = Color3.fromRGB(40,40,40)}, 0.15)
            end
        end)

        button.MouseButton1Click:Connect(function()
            self:SwitchTab(name)
        end)

        Buttons[name] = button
        return tab
    end

    function frame:SwitchTab(name)
        for tabName, tab in pairs(Tabs) do
            tab.Visible = false
            Buttons[tabName].BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
        if Tabs[name] then
            Tabs[name].Visible = true
            Buttons[name].BackgroundColor3 = Color3.fromRGB(0,255,128)
        end
    end

    frame.Frame = frame
    return frame
end

-- ===== BUTTON =====
function PollutedUiLib:CreateButton(parent, title, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 20
    createUICorner(btn, 8)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(0,255,128)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(60,60,60)}, 0.15)
    end)
    btn.MouseButton1Click:Connect(callback)
end

-- ===== TOGGLE =====
function PollutedUiLib:CreateToggle(parent, title, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,35)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.8,0,1,0)
    label.Text = title
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.15,0,0.6,0)
    toggle.Position = UDim2.new(0.85,0,0.2,0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0,255,128) or Color3.fromRGB(60,60,60)
    createUICorner(toggle, 20)

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0,255,128) or Color3.fromRGB(60,60,60)
        callback(state)
    end)
end

-- ===== NOTIFICATIONS =====
function PollutedUiLib:Notification()
    local notif = {}
    function notif.new(config)
        local player = Players.LocalPlayer
        local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
        gui.Name = "PollutedNotification"

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0,250,0,60)
        frame.Position = UDim2.new(1, -260, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
        createUICorner(frame, 10)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,-10,1,0)
        label.Position = UDim2.new(0,5,0,0)
        label.BackgroundTransparency = 1
        label.Text = (config.Title or "Notification").."\n"..(config.Description or "")
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextWrapped = true
        label.Font = Enum.Font.Gotham
        label.TextSize = 16

        tween(frame, {Position = UDim2.new(1, -260, 0, 10)}, 0.5)
        delay(config.Duration or 3, function()
            gui:Destroy()
        end)
    end
    return notif
end

return PollutedUiLib
