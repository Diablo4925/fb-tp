local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Settings = {
    FullbrightEnabled = false,
    TPWalkEnabled = false,
    TPWalkSpeed = 5,
    OriginalAmbient = Lighting.Ambient,
    OriginalBrightness = Lighting.Brightness,
    OriginalClockTime = Lighting.ClockTime,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalFogStart = Lighting.FogStart,
    OriginalOutdoorAmbient = Lighting.OutdoorAmbient
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FullbrightTPWalkGui"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Text = "Fullbright & TP Walk | Diablo"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleUICorner = Instance.new("UICorner")
TitleUICorner.CornerRadius = UDim.new(0, 8)
TitleUICorner.Parent = Title

local Divider = Instance.new("Frame")
Divider.Name = "Divider"
Divider.Size = UDim2.new(0.9, 0, 0, 2)
Divider.Position = UDim2.new(0.05, 0, 0.18, 0)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local FullbrightLabel = Instance.new("TextLabel")
FullbrightLabel.Name = "FullbrightLabel"
FullbrightLabel.Size = UDim2.new(0.5, 0, 0, 30)
FullbrightLabel.Position = UDim2.new(0.05, 0, 0.22, 0)
FullbrightLabel.BackgroundTransparency = 1
FullbrightLabel.Text = "Fullbright"
FullbrightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FullbrightLabel.TextSize = 18
FullbrightLabel.Font = Enum.Font.SourceSansBold
FullbrightLabel.TextXAlignment = Enum.TextXAlignment.Left
FullbrightLabel.Parent = MainFrame

local FullbrightButton = Instance.new("TextButton")
FullbrightButton.Name = "FullbrightButton"
FullbrightButton.Size = UDim2.new(0, 120, 0, 35)
FullbrightButton.Position = UDim2.new(0.6, 0, 0.22, 0)
FullbrightButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
FullbrightButton.BorderSizePixel = 0
FullbrightButton.Text = "OFF"
FullbrightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FullbrightButton.TextSize = 18
FullbrightButton.Font = Enum.Font.SourceSansBold
FullbrightButton.Parent = MainFrame

local FullbrightUICorner = Instance.new("UICorner")
FullbrightUICorner.CornerRadius = UDim.new(0, 6)
FullbrightUICorner.Parent = FullbrightButton

local TPWalkLabel = Instance.new("TextLabel")
TPWalkLabel.Name = "TPWalkLabel"
TPWalkLabel.Size = UDim2.new(0.5, 0, 0, 30)
TPWalkLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
TPWalkLabel.BackgroundTransparency = 1
TPWalkLabel.Text = "TP Walk"
TPWalkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TPWalkLabel.TextSize = 18
TPWalkLabel.Font = Enum.Font.SourceSansBold
TPWalkLabel.TextXAlignment = Enum.TextXAlignment.Left
TPWalkLabel.Parent = MainFrame

local TPWalkButton = Instance.new("TextButton")
TPWalkButton.Name = "TPWalkButton"
TPWalkButton.Size = UDim2.new(0, 120, 0, 35)
TPWalkButton.Position = UDim2.new(0.6, 0, 0.4, 0)
TPWalkButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
TPWalkButton.BorderSizePixel = 0
TPWalkButton.Text = "OFF"
TPWalkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPWalkButton.TextSize = 18
TPWalkButton.Font = Enum.Font.SourceSansBold
TPWalkButton.Parent = MainFrame

local TPWalkUICorner = Instance.new("UICorner")
TPWalkUICorner.CornerRadius = UDim.new(0, 6)
TPWalkUICorner.Parent = TPWalkButton

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0.55, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "TP Walk Speed: 5"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = MainFrame

local MinusButton = Instance.new("TextButton")
MinusButton.Name = "MinusButton"
MinusButton.Size = UDim2.new(0, 40, 0, 40)
MinusButton.Position = UDim2.new(0.1, 0, 0.65, 0)
MinusButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinusButton.Text = "-"
MinusButton.TextSize = 24
MinusButton.Font = Enum.Font.SourceSansBold
MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusButton.BorderSizePixel = 0
MinusButton.Parent = MainFrame

local MinusUICorner = Instance.new("UICorner")
MinusUICorner.CornerRadius = UDim.new(0, 8)
MinusUICorner.Parent = MinusButton

local SpeedValue = Instance.new("TextLabel")
SpeedValue.Name = "SpeedValue"
SpeedValue.Size = UDim2.new(0, 60, 0, 40)
SpeedValue.Position = UDim2.new(0.4, 0, 0.65, 0)
SpeedValue.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedValue.BorderSizePixel = 0
SpeedValue.Text = "5"
SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValue.TextSize = 20
SpeedValue.Font = Enum.Font.SourceSansBold
SpeedValue.Parent = MainFrame

local SpeedValueUICorner = Instance.new("UICorner")
SpeedValueUICorner.CornerRadius = UDim.new(0, 8)
SpeedValueUICorner.Parent = SpeedValue

local PlusButton = Instance.new("TextButton")
PlusButton.Name = "PlusButton"
PlusButton.Size = UDim2.new(0, 40, 0, 40)
PlusButton.Position = UDim2.new(0.7, 0, 0.65, 0)
PlusButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
PlusButton.Text = "+"
PlusButton.TextSize = 24
PlusButton.Font = Enum.Font.SourceSansBold
PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusButton.BorderSizePixel = 0
PlusButton.Parent = MainFrame

local PlusUICorner = Instance.new("UICorner")
PlusUICorner.CornerRadius = UDim.new(0, 8)
PlusUICorner.Parent = PlusButton

local HintLabel = Instance.new("TextLabel")
HintLabel.Name = "HintLabel"
HintLabel.Size = UDim2.new(0.9, 0, 0, 40)
HintLabel.Position = UDim2.new(0.05, 0, 0.82, 0)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "ปรับระดับความวิ่งไว"
HintLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HintLabel.TextSize = 22
HintLabel.Font = Enum.Font.SourceSans
HintLabel.TextYAlignment = Enum.TextYAlignment.Top
HintLabel.Parent = MainFrame

local function SetFullbright(enable)
    if enable then
        if not Settings.FullbrightEnabled then
            Settings.OriginalAmbient = Lighting.Ambient
            Settings.OriginalBrightness = Lighting.Brightness
            Settings.OriginalClockTime = Lighting.ClockTime
            Settings.OriginalFogEnd = Lighting.FogEnd
            Settings.OriginalFogStart = Lighting.FogStart
            Settings.OriginalOutdoorAmbient = Lighting.OutdoorAmbient
        end
        
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
        Lighting.Ambient = Settings.OriginalAmbient
        Lighting.Brightness = Settings.OriginalBrightness
        Lighting.ClockTime = Settings.OriginalClockTime
        Lighting.FogEnd = Settings.OriginalFogEnd
        Lighting.FogStart = Settings.OriginalFogStart
        Lighting.OutdoorAmbient = Settings.OriginalOutdoorAmbient
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                effect.Enabled = true
            end
        end
    end
end

local TPWalkConnection = nil
local function SetupTPWalk()
    if Settings.TPWalkEnabled then
        if TPWalkConnection then
            TPWalkConnection:Disconnect()
        end
        
        TPWalkConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                local moveDirection = character.Humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + 
                        (moveDirection * Settings.TPWalkSpeed / 10)
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

FullbrightButton.MouseButton1Click:Connect(function()
    Settings.FullbrightEnabled = not Settings.FullbrightEnabled
    if Settings.FullbrightEnabled then
        FullbrightButton.Text = "ON"
        FullbrightButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        SetFullbright(true)
    else
        FullbrightButton.Text = "OFF"
        FullbrightButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        SetFullbright(false)
    end
end)

TPWalkButton.MouseButton1Click:Connect(function()
    Settings.TPWalkEnabled = not Settings.TPWalkEnabled
    if Settings.TPWalkEnabled then
        TPWalkButton.Text = "ON"
        TPWalkButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        SetupTPWalk()
    else
        TPWalkButton.Text = "OFF"
        TPWalkButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        SetupTPWalk()
    end
end)

MinusButton.MouseButton1Click:Connect(function()
    if Settings.TPWalkSpeed > 1 then
        Settings.TPWalkSpeed = Settings.TPWalkSpeed - 1
        SpeedValue.Text = tostring(Settings.TPWalkSpeed)
        SpeedLabel.Text = "TP Walk Speed: " .. tostring(Settings.TPWalkSpeed)
    end
end)

PlusButton.MouseButton1Click:Connect(function()
    if Settings.TPWalkSpeed < 50 then
        Settings.TPWalkSpeed = Settings.TPWalkSpeed + 1
        SpeedValue.Text = tostring(Settings.TPWalkSpeed)
        SpeedLabel.Text = "TP Walk Speed: " .. tostring(Settings.TPWalkSpeed)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    if Settings.TPWalkEnabled then
        SetupTPWalk()
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.FullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fullbright & TP Walk | Diablo",
    Text = "Script loaded successfully!",
    Duration = 5
})

print("Fullbright & TP Walk script by Diablo loaded successfully!")
