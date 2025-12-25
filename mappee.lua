local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Settings = {
    FullbrightEnabled = false,
    TPWalkEnabled = false,
    TPWalkSpeed = 5,
    NoClipEnabled = false,
    InfiniteJumpEnabled = false,
    ESPEnabled = false,
    OriginalValuesSaved = false,
    OriginalAmbient = nil,
    OriginalBrightness = nil,
    OriginalClockTime = nil,
    OriginalFogEnd = nil,
    OriginalFogStart = nil,
    OriginalOutdoorAmbient = nil,
    OriginalEffects = {}
}

local espEnabled = false
local espConnections = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESPInfo"
    billboardGui.Parent = humanoidRootPart
    billboardGui.Size = UDim2.new(0, 200, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboardGui
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = billboardGui
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0 studs"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled or not player.Character or not LocalPlayer.Character then
            if updateConnection then
                updateConnection:Disconnect()
            end
            if highlight then highlight:Destroy() end
            if billboardGui then billboardGui:Destroy() end
            return
        end
        
        local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
        
        if localHRP and playerHRP then
            local distance = math.floor((localHRP.Position - playerHRP.Position).Magnitude)
            distanceLabel.Text = distance .. " studs"
            
            local ratio = math.clamp(distance / 100, 0, 1)
            local color = Color3.new(1 - ratio, ratio, 0)
            highlight.FillColor = color
        end
    end)
    
    espConnections[player] = {updateConnection, highlight, billboardGui}
end

local function enableESP()
    if espEnabled then return end
    
    espEnabled = true
    
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    espConnections.playerAdded = Players.PlayerAdded:Connect(createESP)
    
    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        if espConnections[player] then
            local connection, highlight, billboardGui = unpack(espConnections[player])
            if connection then connection:Disconnect() end
            if highlight then highlight:Destroy() end
            if billboardGui then billboardGui:Destroy() end
            espConnections[player] = nil
        end
    end)
    
    espConnections.characterAdded = {}
    for _, player in pairs(Players:GetPlayers()) do
        espConnections.characterAdded[player] = player.CharacterAdded:Connect(function()
            wait(1)
            createESP(player)
        end)
    end
    
    print("ESP enabled!")
end

local function disableESP()
    if not espEnabled then return end
    
    espEnabled = false
    
    for player, data in pairs(espConnections) do
        if type(data) == "table" and #data == 3 then
            local connection, highlight, billboardGui = unpack(data)
            if connection then connection:Disconnect() end
            if highlight then highlight:Destroy() end
            if billboardGui then billboardGui:Destroy() end
        elseif type(data) == "userdata" and data.Disconnect then
            data:Disconnect()
        end
    end
    
    if espConnections.characterAdded then
        for _, connection in pairs(espConnections.characterAdded) do
            if connection then connection:Disconnect() end
        end
    end
    
    espConnections = {}
    print("ESP disabled!")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedScriptGui"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 100)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.Size = UDim2.new(1, 10, 1, 10)
DropShadow.Position = UDim2.new(0, -5, 0, -5)
DropShadow.BackgroundTransparency = 1
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.8
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
DropShadow.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarGradient = Instance.new("UIGradient")
TitleBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
TitleBarGradient.Parent = TitleBar

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DIABLO SCRIPT"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(0.9, 0, 0.18, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(1, 0)
CloseButtonCorner.Parent = CloseButton

local CloseButtonStroke = Instance.new("UIStroke")
CloseButtonStroke.Color = Color3.fromRGB(150, 40, 40)
CloseButtonStroke.Thickness = 1.5
CloseButtonStroke.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(0.8, 0, 0.18, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(1, 0)
MinimizeButtonCorner.Parent = MinimizeButton

local MinimizeButtonStroke = Instance.new("UIStroke")
MinimizeButtonStroke.Color = Color3.fromRGB(60, 60, 80)
MinimizeButtonStroke.Thickness = 1.5
MinimizeButtonStroke.Parent = MinimizeButton

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentFrame
ContentLayout.Padding = UDim.new(0, 12)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateModernToggle(name, icon)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ToggleFrame.BackgroundTransparency = 0.3
    ToggleFrame.LayoutOrder = 1
    ToggleFrame.Parent = ContentFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(60, 60, 80)
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleFrame

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Name = "Icon"
    IconLabel.Size = UDim2.new(0, 35, 0, 35)
    IconLabel.Position = UDim2.new(0, 10, 0.5, -17.5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
    IconLabel.TextSize = 20
    IconLabel.Font = Enum.Font.Gotham
    IconLabel.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0.5, -50, 1, 0)
    Label.Position = UDim2.new(0, 55, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 255)
    Label.TextSize = 15
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Name = name .. "Button"
    Button.Size = UDim2.new(0, 70, 0, 30)
    Button.Position = UDim2.new(1, -80, 0.5, -15)
    Button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    Button.BorderSizePixel = 0
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = ToggleFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
    ButtonStroke.Thickness = 1.5
    ButtonStroke.Parent = Button

    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 80, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 50))
    })
    ButtonGradient.Parent = Button

    return Button
end

local FullbrightButton = CreateModernToggle("Fullbright", "☀️")
local TPWalkButton = CreateModernToggle("TP Walk", "⚡")
local NoClipButton = CreateModernToggle("NoClip", "👻")
local InfiniteJumpButton = CreateModernToggle("Inf Jump", "🦘")
local ESPButton = CreateModernToggle("ESP", "👁️")

local SpeedFrame = Instance.new("Frame")
SpeedFrame.Name = "SpeedFrame"
SpeedFrame.Size = UDim2.new(1, 0, 0, 60)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SpeedFrame.BackgroundTransparency = 0.3
SpeedFrame.LayoutOrder = 6
SpeedFrame.Parent = ContentFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 10)
SpeedCorner.Parent = SpeedFrame

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(60, 60, 80)
SpeedStroke.Thickness = 1
SpeedStroke.Parent = SpeedFrame

local SpeedIcon = Instance.new("TextLabel")
SpeedIcon.Name = "SpeedIcon"
SpeedIcon.Size = UDim2.new(0, 35, 0, 35)
SpeedIcon.Position = UDim2.new(0, 10, 0.5, -17.5)
SpeedIcon.BackgroundTransparency = 1
SpeedIcon.Text = "🎯"
SpeedIcon.TextColor3 = Color3.fromRGB(180, 180, 220)
SpeedIcon.TextSize = 18
SpeedIcon.Font = Enum.Font.Gotham
SpeedIcon.Parent = SpeedFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0.4, -50, 0.5, 0)
SpeedLabel.Position = UDim2.new(0, 55, 0, 5)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 5"
SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

local MinusButton = Instance.new("TextButton")
MinusButton.Name = "MinusButton"
MinusButton.Size = UDim2.new(0, 35, 0, 35)
MinusButton.Position = UDim2.new(0.4, 0, 0.5, -17.5)
MinusButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
MinusButton.Text = "-"
MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusButton.TextSize = 18
MinusButton.Font = Enum.Font.GothamBold
MinusButton.Parent = SpeedFrame

local MinusCorner = Instance.new("UICorner")
MinusCorner.CornerRadius = UDim.new(1, 0)
MinusCorner.Parent = MinusButton

local MinusStroke = Instance.new("UIStroke")
MinusStroke.Color = Color3.fromRGB(150, 40, 40)
MinusStroke.Thickness = 1.5
MinusStroke.Parent = MinusButton

local SpeedValue = Instance.new("TextButton")
SpeedValue.Name = "SpeedValue"
SpeedValue.Size = UDim2.new(0, 60, 0, 35)
SpeedValue.Position = UDim2.new(0.6, 0, 0.5, -17.5)
SpeedValue.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedValue.Text = "5"
SpeedValue.TextColor3 = Color3.fromRGB(220, 220, 255)
SpeedValue.TextSize = 15
SpeedValue.Font = Enum.Font.GothamBold
SpeedValue.Parent = SpeedFrame

local SpeedValueCorner = Instance.new("UICorner")
SpeedValueCorner.CornerRadius = UDim.new(0, 8)
SpeedValueCorner.Parent = SpeedValue

local SpeedValueStroke = Instance.new("UIStroke")
SpeedValueStroke.Color = Color3.fromRGB(80, 80, 100)
SpeedValueStroke.Thickness = 1.5
SpeedValueStroke.Parent = SpeedValue

local PlusButton = Instance.new("TextButton")
PlusButton.Name = "PlusButton"
PlusButton.Size = UDim2.new(0, 35, 0, 35)
PlusButton.Position = UDim2.new(0.85, 0, 0.5, -17.5)
PlusButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
PlusButton.Text = "+"
PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusButton.TextSize = 18
PlusButton.Font = Enum.Font.GothamBold
PlusButton.Parent = SpeedFrame

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(1, 0)
PlusCorner.Parent = PlusButton

local PlusStroke = Instance.new("UIStroke")
PlusStroke.Color = Color3.fromRGB(40, 140, 60)
PlusStroke.Thickness = 1.5
PlusStroke.Parent = PlusButton

local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Size = UDim2.new(0, 60, 0, 35)
SpeedInput.Position = UDim2.new(0.6, 0, 0.5, -17.5)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
SpeedInput.Text = ""
SpeedInput.TextColor3 = Color3.fromRGB(220, 220, 255)
SpeedInput.TextSize = 15
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.PlaceholderText = "Speed"
SpeedInput.Visible = false
SpeedInput.Parent = SpeedFrame

local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 8)
SpeedInputCorner.Parent = SpeedInput

local SpeedInputStroke = Instance.new("UIStroke")
SpeedInputStroke.Color = Color3.fromRGB(100, 100, 140)
SpeedInputStroke.Thickness = 2
SpeedInputStroke.Parent = SpeedInput

local UIElements = {
    FullbrightButton.Parent, TPWalkButton.Parent, NoClipButton.Parent, InfiniteJumpButton.Parent, ESPButton.Parent, SpeedFrame
}

local function AnimateButton(button)
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local scaleDown = TweenService:Create(button, tweenInfo, {Size = originalSize - UDim2.new(0, 4, 0, 4)})
    local scaleUp = TweenService:Create(button, tweenInfo, {Size = originalSize})
    
    scaleDown:Play()
    scaleDown.Completed:Connect(function()
        scaleUp:Play()
    end)
end

local function UpdateSpeedDisplay()
    SpeedValue.Text = tostring(Settings.TPWalkSpeed)
    SpeedLabel.Text = "Speed: " .. tostring(Settings.TPWalkSpeed)
end

local function HideSpeedInputAndSave()
    if SpeedInput.Visible then
        local newSpeed = tonumber(SpeedInput.Text)
        if newSpeed then
            if newSpeed < 0.5 then newSpeed = 0.5
            elseif newSpeed > 500 then newSpeed = 500 end
            Settings.TPWalkSpeed = newSpeed
            UpdateSpeedDisplay()
        end
        SpeedInput.Visible = false
        SpeedValue.Visible = true
    end
end

local NoClipConnection = nil
local function SetupNoClip()
    if Settings.NoClipEnabled then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

local InfiniteJumpConnection = nil
local function SetupInfiniteJump()
    if Settings.InfiniteJumpEnabled then
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if InfiniteJumpConnection then
            InfiniteJumpConnection:Disconnect()
            InfiniteJumpConnection = nil
        end
    end
end

local function SaveOriginalLighting()
    if not Settings.OriginalValuesSaved then
        Settings.OriginalAmbient = Lighting.Ambient
        Settings.OriginalBrightness = Lighting.Brightness
        Settings.OriginalClockTime = Lighting.ClockTime
        Settings.OriginalFogEnd = Lighting.FogEnd
        Settings.OriginalFogStart = Lighting.FogStart
        Settings.OriginalOutdoorAmbient = Lighting.OutdoorAmbient
        Settings.OriginalEffects = {}
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                Settings.OriginalEffects[effect] = effect.Enabled
            end
        end
        Settings.OriginalValuesSaved = true
    end
end

local function RestoreOriginalLighting()
    if Settings.OriginalValuesSaved then
        Lighting.Ambient = Settings.OriginalAmbient
        Lighting.Brightness = Settings.OriginalBrightness
        Lighting.ClockTime = Settings.OriginalClockTime
        Lighting.FogEnd = Settings.OriginalFogEnd
        Lighting.FogStart = Settings.OriginalFogStart
        Lighting.OutdoorAmbient = Settings.OriginalOutdoorAmbient
        for effect, wasEnabled in pairs(Settings.OriginalEffects) do
            if effect and effect.Parent then effect.Enabled = wasEnabled end
        end
    end
end

local function SetFullbright(enable)
    if enable then
        SaveOriginalLighting()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                effect.Enabled = false
            end
        end
    else
        RestoreOriginalLighting()
    end
end

local TPWalkConnection = nil
local function SetupTPWalk()
    if Settings.TPWalkEnabled then
        if TPWalkConnection then TPWalkConnection:Disconnect() end
        TPWalkConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                local moveDirection = character.Humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + (moveDirection * Settings.TPWalkSpeed / 10)
                end
            end
        end)
    else
        if TPWalkConnection then
            TPWalkConnection:Disconnect()
            TPWalkConnection = nil
        end
    end
end

CloseButton.MouseButton1Click:Connect(function()
    AnimateButton(CloseButton)
    wait(0.1)
    ScreenGui:Destroy()
end)

local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    AnimateButton(MinimizeButton)
    Minimized = not Minimized
    if Minimized then
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        for _, element in pairs(UIElements) do
            if element then element.Visible = false end
        end
        SpeedInput.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 350, 0, 400)
        for _, element in pairs(UIElements) do
            if element then element.Visible = true end
        end
        SpeedValue.Visible = true
        SpeedInput.Visible = false
    end
end)

SpeedValue.MouseButton1Click:Connect(function()
    AnimateButton(SpeedValue)
    SpeedValue.Visible = false
    SpeedInput.Visible = true
    SpeedInput.Text = tostring(Settings.TPWalkSpeed)
    SpeedInput:CaptureFocus()
end)

SpeedInput.Focused:Connect(function()
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local inputAbsPos = SpeedInput.AbsolutePosition
            local inputAbsSize = SpeedInput.AbsoluteSize
            if mousePos.X < inputAbsPos.X or mousePos.X > inputAbsPos.X + inputAbsSize.X or
               mousePos.Y < inputAbsPos.Y or mousePos.Y > inputAbsPos.Y + inputAbsSize.Y then
                HideSpeedInputAndSave()
                inputConnection:Disconnect()
            end
        end
    end)
end)

SpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then HideSpeedInputAndSave() end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and SpeedInput.Visible then
        SpeedInput.Visible = false
        SpeedValue.Visible = true
    end
end)

local function ToggleButton(button, setting)
    AnimateButton(button)
    if setting then
        button.Text = "ON"
        button.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        if button:FindFirstChild("UIStroke") then
            button.UIStroke.Color = Color3.fromRGB(40, 140, 60)
        end
        local gradient = button:FindFirstChildOfClass("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 200, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 160, 80))
            })
        end
    else
        button.Text = "OFF"
        button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        if button:FindFirstChild("UIStroke") then
            button.UIStroke.Color = Color3.fromRGB(150, 40, 40)
        end
        local gradient = button:FindFirstChildOfClass("UIGradient")
        if gradient then
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 80, 80)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 50))
            })
        end
    end
end

ESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    ToggleButton(ESPButton, Settings.ESPEnabled)
    
    if Settings.ESPEnabled then
        enableESP()
    else
        disableESP()
    end
end)

FullbrightButton.MouseButton1Click:Connect(function()
    Settings.FullbrightEnabled = not Settings.FullbrightEnabled
    ToggleButton(FullbrightButton, Settings.FullbrightEnabled)
    SetFullbright(Settings.FullbrightEnabled)
end)

TPWalkButton.MouseButton1Click:Connect(function()
    Settings.TPWalkEnabled = not Settings.TPWalkEnabled
    ToggleButton(TPWalkButton, Settings.TPWalkEnabled)
    SetupTPWalk()
end)

NoClipButton.MouseButton1Click:Connect(function()
    Settings.NoClipEnabled = not Settings.NoClipEnabled
    ToggleButton(NoClipButton, Settings.NoClipEnabled)
    SetupNoClip()
end)

InfiniteJumpButton.MouseButton1Click:Connect(function()
    Settings.InfiniteJumpEnabled = not Settings.InfiniteJumpEnabled
    ToggleButton(InfiniteJumpButton, Settings.InfiniteJumpEnabled)
    SetupInfiniteJump()
end)

MinusButton.MouseButton1Click:Connect(function()
    AnimateButton(MinusButton)
    if Settings.TPWalkSpeed > 0.5 then
        if Settings.TPWalkSpeed == 1 then
            Settings.TPWalkSpeed = 0.5
        else
            Settings.TPWalkSpeed = Settings.TPWalkSpeed - 1
        end
        UpdateSpeedDisplay()
    end
end)

PlusButton.MouseButton1Click:Connect(function()
    AnimateButton(PlusButton)
    if Settings.TPWalkSpeed < 500 then
        if Settings.TPWalkSpeed == 0.5 then
            Settings.TPWalkSpeed = 1
        else
            Settings.TPWalkSpeed = Settings.TPWalkSpeed + 1
        end
        UpdateSpeedDisplay()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if Settings.TPWalkEnabled then SetupTPWalk() end
    if Settings.NoClipEnabled then SetupNoClip() end
    if Settings.ESPEnabled then
        wait(1)
        enableESP()
    end
end)

local function ShowWelcomeMessage()
    local WelcomeGui = Instance.new("ScreenGui")
    WelcomeGui.Name = "WelcomeGui"
    WelcomeGui.Parent = game:GetService("CoreGui")
    WelcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 100)
    MainFrame.Position = UDim2.new(1, 20, 1, 20)
    MainFrame.AnchorPoint = Vector2.new(1, 1)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = WelcomeGui

    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    MainGradient.Rotation = 45
    MainGradient.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 14)
    UICorner.Parent = MainFrame

    local ParticlesFolder = Instance.new("Folder")
    ParticlesFolder.Name = "Particles"
    ParticlesFolder.Parent = MainFrame

    for i = 1, 8 do
        local Particle = Instance.new("Frame")
        Particle.Name = "Particle" .. i
        Particle.Size = UDim2.new(0, 4, 0, 4)
        Particle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        Particle.BorderSizePixel = 0
        Particle.Parent = ParticlesFolder
        
        local ParticleCorner = Instance.new("UICorner")
        ParticleCorner.CornerRadius = UDim.new(1, 0)
        ParticleCorner.Parent = Particle
    end

    local IconContainer = Instance.new("Frame")
    IconContainer.Name = "IconContainer"
    IconContainer.Size = UDim2.new(0, 50, 0, 50)
    IconContainer.Position = UDim2.new(0, 15, 0.5, -25)
    IconContainer.BackgroundTransparency = 1
    IconContainer.Parent = MainFrame

    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "⚡"
    Icon.TextColor3 = Color3.fromRGB(255, 255, 150)
    Icon.TextSize = 28
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = IconContainer

    local TextContainer = Instance.new("Frame")
    TextContainer.Name = "TextContainer"
    TextContainer.Size = UDim2.new(0, 190, 0, 60)
    TextContainer.Position = UDim2.new(0, 75, 0.5, -30)
    TextContainer.BackgroundTransparency = 1
    TextContainer.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "DIABLO SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTransparency = 1
    Title.Parent = TextContainer

    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 35)
    Status.BackgroundTransparency = 1
    Status.Text = "มึงจะโปรหาพ่อมึงหรอไอ่สัส"
    Status.TextColor3 = Color3.fromRGB(100, 255, 100)
    Status.TextSize = 23
    Status.Font = Enum.Font.GothamBold
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextTransparency = 1
    Status.Parent = TextContainer

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(0, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 15, 1, -10)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = MainFrame

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar

    local function AnimateParticles()
        local particles = ParticlesFolder:GetChildren()
        for i, particle in ipairs(particles) do
            local angle = (i / #particles) * 2 * math.pi
            local radius = 60
            local speed = 2 + math.random() * 2
            
            spawn(function()
                while WelcomeGui.Parent do
                    local time = tick() * speed
                    local x = math.cos(time + angle) * radius
                    local y = math.sin(time + angle) * radius
                    particle.Position = UDim2.new(0.5, x, 0.5, y)
                    
                    local scale = 0.5 + math.abs(math.sin(time * 2)) * 0.5
                    particle.Size = UDim2.new(0, 4 * scale, 0, 4 * scale)
                    
                    particle.BackgroundTransparency = 0.3 + math.abs(math.sin(time)) * 0.4
                    wait(0.03)
                end
            end)
        end
    end

    local function AnimateIcon()
        while WelcomeGui.Parent do
            local pulse = math.sin(tick() * 3) * 0.2 + 0.8
            Icon.TextSize = 28 * pulse
            wait(0.05)
        end
    end

    local slideIn = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -20, 1, -20)}
    )

    local titleFadeIn = TweenService:Create(
        Title,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )

    local statusFadeIn = TweenService:Create(
        Status,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )

    local progressFill = TweenService:Create(
        ProgressBar,
        TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, -30, 0, 3)}
    )

    local statusColorChange = TweenService:Create(
        Status,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextColor3 = Color3.fromRGB(255, 255, 255)}
    )

    local statusColorRevert = TweenService:Create(
        Status,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextColor3 = Color3.fromRGB(100, 255, 100)}
    )

    local slideOut = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 20, 1, 20)}
    )

    slideIn:Play()
    
    wait(0.3)
    titleFadeIn:Play()
    
    wait(0.2)
    statusFadeIn:Play()
    
    wait(0.2)
    progressFill:Play()
    
    spawn(AnimateParticles)
    spawn(AnimateIcon)

    wait(1.5)
    statusColorChange:Play()
    wait(0.3)
    statusColorRevert:Play()

    wait(2)
    
    slideOut:Play()
    slideOut.Completed:Wait()
    
    WelcomeGui:Destroy()
end

ShowWelcomeMessage()

print("มึงจะรัน Script กูหาพ่อมึงหรอไอ่สัส กูให้มึงใช้ตอนไหน!")
