-- PollutedUiLib.lua
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

-- ===== NOTIFICATION =====
PollutedUiLib.Notification = {}
function PollutedUiLib.Notification.new(params)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "PollutedNotification"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(1, -310, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    createUICorner(frame, 10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -60, 0, 30)
    title.Position = UDim2.new(0, 50, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = params.Title or "Notification"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -60, 0, 40)
    desc.Position = UDim2.new(0, 50, 0, 35)
    desc.BackgroundTransparency = 1
    desc.Text = params.Description or ""
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 14
    desc.TextWrapped = true

    if params.Icon then
        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 5, 0, 20)
        icon.BackgroundTransparency = 1
        icon.Image = params.Icon
    end

    -- Tween in/out
    frame.Position = UDim2.new(1, 310, 0, 50)
    tweenObject(frame, {Position = UDim2.new(1, -310, 0, 50)}, 0.3)
    task.delay(params.Duration or 5, function()
        tweenObject(frame, {Position = UDim2.new(1, 310, 0, 50)}, 0.3)
        task.delay(0.3, function() gui:Destroy() end)
    end)
end

-- ===== WINDOW =====
function PollutedUiLib.new(config)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = config.Title or "PollutedWindow"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, config.Width or 600, 0, config.Height or 450)
    frame.Position = UDim2.new(0.5, -(config.Width or 600)/2, 0.5, -(config.Height or 450)/2)
    frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
    createUICorner(frame, config.CornerRadius or 10)

    -- Header
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1,0,0,50)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Polluted Hub"
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24

    -- Container for tabs
    local tabContainer = Instance.new("Frame", frame)
    tabContainer.Size = UDim2.new(1,0,1,-50)
    tabContainer.Position = UDim2.new(0,0,0,50)
    tabContainer.BackgroundTransparency = 1

    local Tabs = {}
    local Sections = {}

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
            sectionFrame.Size = UDim2.new(0.5, -10, 1, 0)
            sectionFrame.Position = sectionConfig.Position == "Left" and UDim2.new(0, 5, 0, 0) or UDim2.new(0.5, 5, 0, 0)
            sectionFrame.BackgroundTransparency = 1
            Sections[sectionConfig.Title] = sectionFrame

            local sectionAPI = {}

            function sectionAPI:NewButton(params)
                local btn = Instance.new("TextButton", sectionFrame)
                btn.Size = UDim2.new(1, -20, 0, 35)
                btn.Position = UDim2.new(0, 10, 0, (#sectionFrame:GetChildren()-1)*40)
                btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                btn.Text = params.Title
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 18
                createUICorner(btn, 8)
                btn.MouseButton1Click:Connect(params.Callback)
            end

            function sectionAPI:NewToggle(params)
                local toggleFrame = Instance.new("Frame", sectionFrame)
                toggleFrame.Size = UDim2.new(1, -20, 0, 35)
                toggleFrame.Position = UDim2.new(0, 10, 0, (#sectionFrame:GetChildren()-1)*40)
                toggleFrame.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", toggleFrame)
                label.Size = UDim2.new(0.8,0,1,0)
                label.Text = params.Title
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1,1,1)
                label.Font = Enum.Font.Gotham
                label.TextSize = 18

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

            function sectionAPI:NewSlider(params)
                local sliderFrame = Instance.new("Frame", sectionFrame)
                sliderFrame.Size = UDim2.new(1, -20, 0, 35)
                sliderFrame.Position = UDim2.new(0, 10, 0, (#sectionFrame:GetChildren()-1)*40)
                sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
                createUICorner(sliderFrame, 8)

                local label = Instance.new("TextLabel", sliderFrame)
                label.Size = UDim2.new(0.5,0,1,0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1,1,1)
                label.Font = Enum.Font.Gotham
                label.TextSize = 16
                label.Text = params.Title

                local slider = Instance.new("TextButton", sliderFrame)
                slider.Size = UDim2.new(0.5, -10, 0, 35)
                slider.Position = UDim2.new(0.5, 5, 0, 0)
                slider.BackgroundColor3 = Color3.fromRGB(0,255,128)
                createUICorner(slider, 8)

                slider.MouseButton1Down:Connect(function()
                    local dragging = true
                    local mouse = Players.LocalPlayer:GetMouse()
                    local function move()
                        if dragging then
                            local rel = math.clamp(mouse.X - slider.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                            slider.Size = UDim2.new(rel / sliderFrame.AbsoluteSize.X, 0, 1, 0)
                            local value = math.floor(params.Min + (params.Max - params.Min)*(rel / sliderFrame.AbsoluteSize.X))
                            params.Callback(value)
                        end
                    end
                    move()
                    local conn
                    conn = RunService.RenderStepped:Connect(move)
                    mouse.Button1Up:Connect(function()
                        dragging = false
                        conn:Disconnect()
                    end)
                end)
            end

            function sectionAPI:NewLabel(text)
                local lbl = Instance.new("TextLabel", sectionFrame)
                lbl.Size = UDim2.new(1, -20, 0, 25)
                lbl.Position = UDim2.new(0, 10, 0, (#sectionFrame:GetChildren()-1)*30)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 16
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
