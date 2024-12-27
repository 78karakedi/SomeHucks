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
local fling = false
local flySpeed = 100  -- Initial flying speed
local walkSpeed = 16  -- Initial walk speed
local walkSpeedEnabled = false
local isMinimized = false
local flingConnection
local originalSize = UDim2.new(0, 300, 0, 500)  -- Adjusted horizontal length

-- Create main GUI frame
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

-- Create open button (not draggable)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 100, 0, 50)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.Text = "GoodHub"
openButton.Parent = screenGui

-- Create flying control panel frame
local controlPanel = Instance.new("Frame")
controlPanel.Size = originalSize
controlPanel.Position = UDim2.new(0, 120, 0, 10)
controlPanel.BackgroundColor3 = Color3.new(0, 0, 0)  -- Set background color to black
controlPanel.Visible = false
controlPanel.Parent = screenGui

-- Make the control panel scrollable
local controlPanelCanvas = Instance.new("ScrollingFrame")
controlPanelCanvas.Size = UDim2.new(1, 0, 1, 0)
controlPanelCanvas.CanvasSize = UDim2.new(0, 0, 1.5, 0) -- Adjust for more or less scrolling
controlPanelCanvas.ScrollBarThickness = 10
controlPanelCanvas.Parent = controlPanel

-- Create draggable top bar for control panel
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
topBar.Parent = controlPanelCanvas

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
toggleFlyButton.Text = "Fly"
toggleFlyButton.Parent = controlPanelCanvas

-- Create Fly Speed Slider inside control panel
local flySpeedSliderFrame = Instance.new("Frame")
flySpeedSliderFrame.Size = UDim2.new(0, 200, 0, 50)
flySpeedSliderFrame.Position = UDim2.new(0, 10, 0, 100)
flySpeedSliderFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
flySpeedSliderFrame.Parent = controlPanelCanvas

local flySpeedSlider = Instance.new("TextButton")
flySpeedSlider.Size = UDim2.new(0, 20, 1, 0)
flySpeedSlider.Position = UDim2.new(flySpeed / 5000, 0, 0, 0)
flySpeedSlider.Text = tostring(flySpeed)
flySpeedSlider.Parent = flySpeedSliderFrame

-- Create Walk Speed Slider inside control panel
local walkSpeedSliderFrame = Instance.new("Frame")
walkSpeedSliderFrame.Size = UDim2.new(0, 120, 0, 50)
walkSpeedSliderFrame.Position = UDim2.new(0, 10, 0, 160)
walkSpeedSliderFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
walkSpeedSliderFrame.Parent = controlPanelCanvas

local walkSpeedSlider = Instance.new("TextButton")
walkSpeedSlider.Size = UDim2.new(0, 20, 1, 0)
walkSpeedSlider.Position = UDim2.new(walkSpeed / 200, 0, 0, 0)
walkSpeedSlider.Text = tostring(walkSpeed)
walkSpeedSlider.Parent = walkSpeedSliderFrame

-- Create Walk Speed Toggle Button
local walkSpeedToggleButton = Instance.new("TextButton")
walkSpeedToggleButton.Size = UDim2.new(0, 60, 1, 0)
walkSpeedToggleButton.Position = UDim2.new(1, 10, 0, 0)
walkSpeedToggleButton.Text = "Off"
walkSpeedToggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
walkSpeedToggleButton.TextColor3 = Color3.new(1, 1, 1)
walkSpeedToggleButton.Parent = walkSpeedSliderFrame

-- Create Wallclip button inside control panel
local wallclipButton = Instance.new("TextButton")
wallclipButton.Size = UDim2.new(0, 200, 0, 50)
wallclipButton.Position = UDim2.new(0, 10, 0, 220)
wallclipButton.Text = "Enable Wallclip"
wallclipButton.Parent = controlPanelCanvas

-- Create Player ESP button inside control panel
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 200, 0, 50)
espButton.Position = UDim2.new(0, 10, 0, 280)
espButton.Text = "Enable ESP"
espButton.Parent = controlPanelCanvas

-- Create Teleport input box inside control panel
local teleportBox = Instance.new("TextBox")
teleportBox.Size = UDim2.new(0, 200, 0, 40)
teleportBox.Position = UDim2.new(0, 10, 0, 340)
teleportBox.PlaceholderText = "Enter player name to teleport to"
teleportBox.Text = ""
teleportBox.Parent = controlPanelCanvas

-- Create Bring Player input box inside control panel
local bringPlayerBox = Instance.new("TextBox")
bringPlayerBox.Size = UDim2.new(0, 200, 0, 40)
bringPlayerBox.Position = UDim2.new(0, 10, 0, 400)
bringPlayerBox.PlaceholderText = "Enter player name to bring"
bringPlayerBox.Text = ""
bringPlayerBox.Parent = controlPanelCanvas

-- Create Fling button inside control panel
local flingButton = Instance.new("TextButton")
flingButton.Size = UDim2.new(0, 200, 0, 50)
flingButton.Position = UDim2.new(0, 10, 0, 460)
flingButton.Text = "Enable Fling"
flingButton.Parent = controlPanelCanvas

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
            moveDirection = moveDirection.Unit * flySpeed
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

-- Function to bring a player to your location
local function bringPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        targetPlayer.Character.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
    end
end

-- Function to handle speed slider input
local draggingFlySpeedSlider = false
local draggingWalkSpeedSlider = false

flySpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFlySpeedSlider = true
    end
end)

flySpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFlySpeedSlider = false
    end
end)

flySpeedSliderFrame.InputChanged:Connect(function(input)
    if draggingFlySpeedSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local frameX = flySpeedSliderFrame.AbsolutePosition.X
        local frameWidth = flySpeedSliderFrame.AbsoluteSize.X
        local newSliderPos = math.clamp((mouseX - frameX) / frameWidth, 0, 1)
        flySpeedSlider.Position = UDim2.new(newSliderPos, 0, 0, 0)
        flySpeed = math.floor(newSliderPos * 5000)
        flySpeedSlider.Text = tostring(flySpeed)
    end
end)

walkSpeedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalkSpeedSlider = true
    end
end)

walkSpeedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalkSpeedSlider = false
    end
end)

walkSpeedSliderFrame.InputChanged:Connect(function(input)
    if draggingWalkSpeedSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local frameX = walkSpeedSliderFrame.AbsolutePosition.X
        local frameWidth = walkSpeedSliderFrame.AbsoluteSize.X
        local newSliderPos = math.clamp((mouseX - frameX) / frameWidth, 0, 1)
        walkSpeedSlider.Position = UDim2.new(newSliderPos, 0, 0, 0)
        walkSpeed = math.floor(newSliderPos * 200)
        walkSpeedSlider.Text = tostring(walkSpeed)
        if walkSpeedEnabled then
            humanoid.WalkSpeed = walkSpeed
        end
    end
end)

-- Function to toggle walk speed
local function toggleWalkSpeed()
    walkSpeedEnabled = not walkSpeedEnabled
    walkSpeedToggleButton.Text = walkSpeedEnabled and "On" or "Off"
    humanoid.WalkSpeed = walkSpeedEnabled and walkSpeed or 16
end

-- Function to enable fling
local function enableFling()
    if fling then
        fling = false
        flingButton.Text = "Enable Fling"
        if flingConnection then
            flingConnection:Disconnect()
            humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)  -- Stop spinning
        end
    else
        fling = true
        flingButton.Text = "Disable Fling"
        flingConnection = RunService.Stepped:Connect(function()
            humanoidRootPart.RotVelocity = Vector3.new(0, 500, 0)
            humanoidRootPart.Velocity = Vector3.new(0, -50, 0)  -- Keep the player grounded
        end)
    end
end

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
        controlPanel.Size = UDim2.new(0, 300, 0, 30)  -- Adjusted horizontal length
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
bringPlayerBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        bringPlayer(bringPlayerBox.Text)
        bringPlayerBox.Text = ""
    end
end)
flingButton.MouseButton1Click:Connect(enableFling)
openButton.MouseButton1Click:Connect(function()
    controlPanel.Visible = not controlPanel.Visible
end)
walkSpeedToggleButton.MouseButton1Click:Connect(toggleWalkSpeed)

-- Ensure walk speed remains active
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if walkSpeedEnabled and humanoid.WalkSpeed ~= walkSpeed then
        humanoid.WalkSpeed = walkSpeed
    end
end)

-- Connect RenderStepped to handle flying movement
RunService.RenderStepped:Connect(onRenderStepped)
