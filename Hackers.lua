-- Script to create a GUI for toggling flying, adjusting speed, enabling wallclip, player ESP, and teleporting to players

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local wallclip = false
local espEnabled = false
local speedMultiplier = 2000  -- Initial flying speed
local isMinimized = false
local originalSize = UDim2.new(0, 220, 0, 350)

-- Create main GUI frame
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

-- Create open button (not draggable)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 100, 0, 50)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.Text = "Open Fly GUI"
openButton.Parent = screenGui

-- Create flying control panel frame
local controlPanel = Instance.new("Frame")
controlPanel.Size = originalSize
controlPanel.Position = UDim2.new(0, 120, 0, 10)
controlPanel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
controlPanel.Visible = false
controlPanel.Parent = screenGui

-- Create draggable top bar for control panel
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
topBar.Parent = controlPanel

local topBarLabel = Instance.new("TextLabel")
topBarLabel.Size = UDim2.new(0.7, 0, 1, 0)
topBarLabel.BackgroundTransparency = 1
topBarLabel.Text = "Control Panel"
topBarLabel.TextColor3 = Color3.new(1, 1, 1)
topBarLabel.TextXAlignment = Enum.TextXAlignment.Left
topBarLabel.Parent = topBar

-- Create minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0.15, -5, 1, 0)
minimizeButton.Position = UDim2.new(0.7, 0, 0, 0)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
minimizeButton.Parent = topBar

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.15, -5, 1, 0)
closeButton.Position = UDim2.new(0.85, 0, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
closeButton.Parent = topBar

-- Create Toggle Fly button inside control panel
local toggleFlyButton = Instance.new("TextButton")
toggleFlyButton.Size = UDim2.new(0, 200, 0, 50)
toggleFlyButton.Position = UDim2.new(0, 10, 0, 40)
toggleFlyButton.Text = "Toggle Fly"
toggleFlyButton.Parent = controlPanel

-- Create Speed Slider inside control panel
local speedSliderFrame = Instance.new("Frame")
speedSliderFrame.Size = UDim2.new(0, 200, 0, 50)
speedSliderFrame.Position = UDim2.new(0, 10, 0, 100)
speedSliderFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
speedSliderFrame.Parent = controlPanel

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0, 20, 1, 0)
speedSlider.Position = UDim2.new(speedMultiplier / 5000, 0, 0, 0)
speedSlider.Text = tostring(speedMultiplier)
speedSlider.Parent = speedSliderFrame

-- Create Wallclip button inside control panel
local wallclipButton = Instance.new("TextButton")
wallclipButton.Size = UDim2.new(0, 200, 0, 50)
wallclipButton.Position = UDim2.new(0, 10, 0, 160)
wallclipButton.Text = "Enable Wallclip"
wallclipButton.Parent = controlPanel

-- Create Player ESP button inside control panel
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 200, 0, 50)
espButton.Position = UDim2.new(0, 10, 0, 220)
espButton.Text = "Enable ESP"
espButton.Parent = controlPanel

-- Create Teleport input box inside control panel
local teleportBox = Instance.new("TextBox")
teleportBox.Size = UDim2.new(0, 200, 0, 40)
teleportBox.Position = UDim2.new(0, 10, 0, 280)
teleportBox.PlaceholderText = "Enter player name"
teleportBox.Text = ""
teleportBox.Parent = controlPanel

-- Function to toggle flying
local function toggleFlying()
    if flying then
        -- Stop flying
        flying = false
        humanoid.PlatformStand = false  -- Re-enable character's standard animations
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        workspace.Gravity = 196.2  -- Reset gravity to default value
    else
        -- Start flying
        flying = true
        humanoid.PlatformStand = true  -- Disable character's standard animations
        workspace.Gravity = 0  -- Set gravity to 0 to simulate flying
    end
end

-- Function to handle flying movement
local function onRenderStepped()
    if flying then
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        -- Normalize moveDirection and apply speed
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * speedMultiplier
        end

        humanoidRootPart.Velocity = moveDirection
    end
end

-- Function to enable wallclip
local function enableWallclip()
    if wallclip then
        wallclip = false
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        wallclipButton.Text = "Enable Wallclip"
    else
        wallclip = true
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        wallclipButton.Text = "Disable Wallclip"
    end
end

-- Function to toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "Disable ESP" or "Enable ESP"

    if espEnabled then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = otherPlayer.Character
                highlight.Name = "ESPHighlight"
                highlight.Parent = otherPlayer.Character
            end
        end
    else
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local highlight = otherPlayer.Character:FindFirstChild("ESPHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- Function to handle teleportation
local function teleportToPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end

-- Function to handle speed slider input
local draggingSlider = false

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

speedSliderFrame.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local frameX = speedSliderFrame.AbsolutePosition.X
        local frameWidth = speedSliderFrame.AbsoluteSize.X
        local newSliderPos = math.clamp((mouseX - frameX) / frameWidth, 0, 1)
        speedSlider.Position = UDim2.new(newSliderPos, 0, 0, 0)
        speedMultiplier = math.floor(newSliderPos * 5000)
        speedSlider.Text = tostring(speedMultiplier)
    end
end)

-- Make the control panel draggable by clicking the top bar
local draggingControlPanel = false
local controlPanelDragOffset

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingControlPanel = true
        controlPanelDragOffset = Vector2.new(input.Position.X - controlPanel.AbsolutePosition.X, input.Position.Y - controlPanel.AbsolutePosition.Y)
    end
end)

topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingControlPanel = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingControlPanel and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPosition = Vector2.new(input.Position.X - controlPanelDragOffset.X, input.Position.Y - controlPanelDragOffset.Y)
        controlPanel.Position = UDim2.new(0, newPosition.X, 0, newPosition.Y)
    end
end)

-- Minimize button functionality
minimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        controlPanel.Size = UDim2.new(0, 220, 0, 30)
        isMinimized = true
    else
        controlPanel.Size = originalSize
        isMinimized = false
    end
end)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    controlPanel.Visible = false
end)

-- Connect buttons to their respective functions
toggleFlyButton.MouseButton1Click:Connect(toggleFlying)
wallclipButton.MouseButton1Click:Connect(enableWallclip)
espButton.MouseButton1Click:Connect(toggleESP)
teleportBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        teleportToPlayer(teleportBox.Text)
        teleportBox.Text = ""
    end
end)
openButton.MouseButton1Click:Connect(function()
    controlPanel.Visible = not controlPanel.Visible
end)

-- Connect RenderStepped to handle flying movement
RunService.RenderStepped:Connect(onRenderStepped)