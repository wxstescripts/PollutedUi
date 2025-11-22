local PollutedUiLib = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== HELPERS =====
local function createUICorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
end

local function tweenObject(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function isMobile()
    return UserInputService.TouchEnabled
end

local function scaleSize(value)
    return isMobile() and value * 0.75 or value
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

-- ===== NOTIFICATIONS =====
PollutedUiLib.Notification = {}
function PollutedUiLib.Notification.new(params)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "PollutedNotification"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, scaleSize(300), 0, scaleSize(80))
    frame.Position = UDim2.new(1, scaleSize(310), 0, scaleSize(50))
    frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    createUICorner(frame, 12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -scaleSize(60), 0, scaleSize(30))
    title.Position = UDim2.new(0, scaleSize(50), 0, scaleSize(5))
    title.BackgroundTransparency = 1
    title.Text = params.Title or "Notification"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = scaleSize(18)

    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -scaleSize(60), 0, scaleSize(40))
    desc.Position = UDim2.new(0, scaleSize(50), 0, scaleSize(35))
    desc.BackgroundTransparency = 1
    desc.Text = params.Description or ""
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = scaleSize(14)
    desc.TextWrapped = true

    if params.Icon then
        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, scaleSize(40), 0, scaleSize(40))
        icon.Position = UDim2.new(0, scaleSize(5), 0, scaleSize(20))
        icon.BackgroundTransparency = 1
        icon.Image = params.Icon
    end

    tweenObject(frame, {Position = UDim2.new(1, -scaleSize(310), 0, scaleSize(50))}, 0.3)
    task.delay(params.Duration or 5, function()
        tweenObject(frame, {Position = UDim2.new(1, scaleSize(310), 0, scaleSize(50))}, 0.3)
        task.delay(0.3, function() gui:Destroy() end)
    end)
end

-- ===== WINDOW =====
function PollutedUiLib.new(config)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = config.Title or "PollutedWindow"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, scaleSize(config.Width or 600), 0, scaleSize(450))
    frame.Position = UDim2.new(0.5, -scaleSize((config.Width or 600)/2), 0.5, -scaleSize(450/2))
    frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    createUICorner(frame, config.CornerRadius or 12)
    makeDraggable(frame)

    -- Header
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1,0,0,scaleSize(50))
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Polluted Hub"
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = scaleSize(24)

    -- Tab container
    local tabContainer = Instance.new("Frame", frame)
    tabContainer.Size = UDim2.new(1,0,1,-scaleSize(50))
    tabContainer.Position = UDim2.new(0,0,0,scaleSize(50))
    tabContainer.BackgroundTransparency = 1

    local Tabs = {}
    local windowAPI = {}

    function windowAPI:NewTab(tabConfig)
        local tabFrame = Instance.new("Frame", tabContainer)
        tabFrame.Size = UDim2.new(1,0,1,0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        Tabs[tabConfig.Title] = tabFrame

        local tabAPI = {}

        function tabAPI:NewSection(sectionConfig)
            local sectionFrame = Instance.new("Frame", tabFrame)
            sectionFrame.Size = UDim2.new(isMobile() and 1 or 0.5, -10, 1, 0)
            sectionFrame.Position = isMobile() and UDim2.new(0,5,0,0)
                or (sectionConfig.Position == "Left" and UDim2.new(0,5,0,0) or UDim2.new(0.5,5,0,0))
            sectionFrame.BackgroundTransparency = 1

            local sectionAPI = {}

            -- BUTTON
            function sectionAPI:NewButton(params)
                local btn = Instance.new("TextButton", sectionFrame)
                btn.Size = UDim2.new(1,-20,0,scaleSize(35))
                btn.Position = UDim2.new(0,10,0,(#sectionFrame:GetChildren()-1)*scaleSize(40))
                btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                btn.Text = params.Title
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = scaleSize(18)
                createUICorner(btn, 8)
                btn.MouseButton1Click:Connect(params.Callback)
            end

            -- TOGGLE
            function sectionAPI:NewToggle(params)
                local toggleFrame = Instance.new("Frame", sectionFrame)
                toggleFrame.Size = UDim2.new(1,-20,0,scaleSize(35))
                toggleFrame.Position = UDim2.new(0,10,0,(#sectionFrame:GetChildren()-1)*scaleSize(40))
                toggleFrame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", toggleFrame)
                label.Size = UDim2.new(0.8,0,1,0)
                label.Text = params.Title
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.Font = Enum.Font.Gotham
                label.TextSize = scaleSize(18)

                local toggleBtn = Instance.new("TextButton", toggleFrame)
                toggleBtn.Size = UDim2.new(0.15,0,0.6,0)
                toggleBtn.Position = UDim2.new(0.85,0,0.2,0)
                toggleBtn.BackgroundColor3 = params.Default and Color3.fromRGB(0,255,128) or Color3.fromRGB(60,60,60)
                createUICorner(toggleBtn, 20)

                local state = params.Default
                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0,255,128) or Color3.fromRGB(60,60,60)
                    params.Callback(state)
                end)
            end

            -- SLIDER
            function sectionAPI:NewSlider(params)
                local sliderFrame = Instance.new("Frame", sectionFrame)
                sliderFrame.Size = UDim2.new(1,-20,0,scaleSize(35))
                sliderFrame.Position = UDim2.new(0,10,0,(#sectionFrame:GetChildren()-1)*scaleSize(40))
                sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
                createUICorner(sliderFrame, 8)

                local label = Instance.new("TextLabel", sliderFrame)
                label.Size = UDim2.new(0.5,0,1,0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.Font = Enum.Font.Gotham
                label.TextSize = scaleSize(16)
                label.Text = params.Title

                local sliderBtn = Instance.new("Frame", sliderFrame)
                sliderBtn.Size = UDim2.new((params.Default - params.Min)/(params.Max - params.Min), 0, 1, 0)
                sliderBtn.BackgroundColor3 = Color3.fromRGB(0,255,128)
                createUICorner(sliderBtn, 8)

                local dragging = false
                sliderFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                sliderFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                        local percent = relativeX / sliderFrame.AbsoluteSize.X
                        sliderBtn.Size = UDim2.new(percent,0,1,0)
                        local value = math.floor(params.Min + (params.Max - params.Min) * percent)
                        params.Callback(value)
                    end
                end)
            end

            -- LABEL
            function sectionAPI:NewLabel(text)
                local lbl = Instance.new("TextLabel", sectionFrame)
                lbl.Size = UDim2.new(1,-20,0,scaleSize(25))
                lbl.Position = UDim2.new(0,10,0,(#sectionFrame:GetChildren()-1)*scaleSize(30))
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Color3.fromRGB(255,255,255)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = scaleSize(16)
            end

            return sectionAPI
        end

        return tabAPI
    end

    function windowAPI:SwitchTab(title)
        for name, tab in pairs(Tabs) do
            tab.Visible = false
        end
        if Tabs[title] then
            Tabs[title].Visible = true
        end
    end

    return windowAPI
end

return PollutedUiLib
