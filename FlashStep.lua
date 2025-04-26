-- Flash Step Script
-- With fixed keybind system

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlashStepGui"
ScreenGui.ResetOnSpawn = false

-- Try to use CoreGui if possible
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

-- Fallback to PlayerGui if CoreGui fails
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Color scheme
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 20),       -- Black
    TITLE_BG = Color3.fromRGB(30, 0, 50),          -- Dark purple
    ACCENT = Color3.fromRGB(130, 0, 255),          -- Bright purple
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),  -- White
    TEXT_SECONDARY = Color3.fromRGB(200, 180, 255) -- Light purple
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
MainFrame.BackgroundColor3 = COLORS.BACKGROUND
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Add rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Label
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0.15, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = COLORS.TITLE_BG
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "Flash Step"
TitleLabel.TextColor3 = COLORS.TEXT_PRIMARY
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

-- Add rounded corners to title (only top corners)
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Credit Label
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Name = "CreditLabel"
CreditLabel.Size = UDim2.new(1, 0, 0.08, 0)
CreditLabel.Position = UDim2.new(0, 0, 0.15, 0)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Made By: Phantom hub"
CreditLabel.TextColor3 = COLORS.TEXT_SECONDARY
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextSize = 14
CreditLabel.Parent = MainFrame

-- Speed Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.23, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 5"
SpeedLabel.TextColor3 = COLORS.TEXT_PRIMARY
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

-- Speed Slider Background
local SpeedSliderBackground = Instance.new("Frame")
SpeedSliderBackground.Name = "SpeedSliderBackground"
SpeedSliderBackground.Size = UDim2.new(0.9, 0, 0.07, 0)
SpeedSliderBackground.Position = UDim2.new(0.05, 0, 0.31, 0)
SpeedSliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedSliderBackground.BorderSizePixel = 0
SpeedSliderBackground.Parent = MainFrame

-- Add rounded corners to speed slider background
local SpeedSliderBackgroundCorner = Instance.new("UICorner")
SpeedSliderBackgroundCorner.CornerRadius = UDim.new(0, 4)
SpeedSliderBackgroundCorner.Parent = SpeedSliderBackground

-- Speed Slider Fill
local SpeedSliderFill = Instance.new("Frame")
SpeedSliderFill.Name = "SpeedSliderFill"
SpeedSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SpeedSliderFill.Position = UDim2.new(0, 0, 0, 0)
SpeedSliderFill.BackgroundColor3 = COLORS.ACCENT
SpeedSliderFill.BorderSizePixel = 0
SpeedSliderFill.Parent = SpeedSliderBackground

-- Add rounded corners to speed slider fill
local SpeedSliderFillCorner = Instance.new("UICorner")
SpeedSliderFillCorner.CornerRadius = UDim.new(0, 4)
SpeedSliderFillCorner.Parent = SpeedSliderFill

-- Speed Slider Knob
local SpeedSliderKnob = Instance.new("Frame")
SpeedSliderKnob.Name = "SpeedSliderKnob"
SpeedSliderKnob.Size = UDim2.new(0, 16, 0, 16)
SpeedSliderKnob.Position = UDim2.new(0.5, -8, 0.5, -8)
SpeedSliderKnob.BackgroundColor3 = COLORS.TEXT_PRIMARY
SpeedSliderKnob.BorderSizePixel = 0
SpeedSliderKnob.ZIndex = 2
SpeedSliderKnob.Parent = SpeedSliderBackground

-- Add rounded corners to speed slider knob
local SpeedSliderKnobCorner = Instance.new("UICorner")
SpeedSliderKnobCorner.CornerRadius = UDim.new(0, 8)
SpeedSliderKnobCorner.Parent = SpeedSliderKnob

-- Distance Label
local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Name = "DistanceLabel"
DistanceLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
DistanceLabel.Position = UDim2.new(0.05, 0, 0.38, 0)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Distance: 3"
DistanceLabel.TextColor3 = COLORS.TEXT_PRIMARY
DistanceLabel.Font = Enum.Font.Gotham
DistanceLabel.TextSize = 14
DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
DistanceLabel.Parent = MainFrame

-- Distance Slider Background
local DistanceSliderBackground = Instance.new("Frame")
DistanceSliderBackground.Name = "DistanceSliderBackground"
DistanceSliderBackground.Size = UDim2.new(0.9, 0, 0.07, 0)
DistanceSliderBackground.Position = UDim2.new(0.05, 0, 0.46, 0)
DistanceSliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DistanceSliderBackground.BorderSizePixel = 0
DistanceSliderBackground.Parent = MainFrame

-- Add rounded corners to distance slider background
local DistanceSliderBackgroundCorner = Instance.new("UICorner")
DistanceSliderBackgroundCorner.CornerRadius = UDim.new(0, 4)
DistanceSliderBackgroundCorner.Parent = DistanceSliderBackground

-- Distance Slider Fill
local DistanceSliderFill = Instance.new("Frame")
DistanceSliderFill.Name = "DistanceSliderFill"
DistanceSliderFill.Size = UDim2.new(0.3, 0, 1, 0)
DistanceSliderFill.Position = UDim2.new(0, 0, 0, 0)
DistanceSliderFill.BackgroundColor3 = COLORS.ACCENT
DistanceSliderFill.BorderSizePixel = 0
DistanceSliderFill.Parent = DistanceSliderBackground

-- Add rounded corners to distance slider fill
local DistanceSliderFillCorner = Instance.new("UICorner")
DistanceSliderFillCorner.CornerRadius = UDim.new(0, 4)
DistanceSliderFillCorner.Parent = DistanceSliderFill

-- Distance Slider Knob
local DistanceSliderKnob = Instance.new("Frame")
DistanceSliderKnob.Name = "DistanceSliderKnob"
DistanceSliderKnob.Size = UDim2.new(0, 16, 0, 16)
DistanceSliderKnob.Position = UDim2.new(0.3, -8, 0.5, -8)
DistanceSliderKnob.BackgroundColor3 = COLORS.TEXT_PRIMARY
DistanceSliderKnob.BorderSizePixel = 0
DistanceSliderKnob.ZIndex = 2
DistanceSliderKnob.Parent = DistanceSliderBackground

-- Add rounded corners to distance slider knob
local DistanceSliderKnobCorner = Instance.new("UICorner")
DistanceSliderKnobCorner.CornerRadius = UDim.new(0, 8)
DistanceSliderKnobCorner.Parent = DistanceSliderKnob

-- Keybind Label
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Name = "KeybindLabel"
KeybindLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
KeybindLabel.Position = UDim2.new(0.05, 0, 0.53, 0)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Keybind:"
KeybindLabel.TextColor3 = COLORS.TEXT_PRIMARY
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextSize = 14
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = MainFrame

-- Keybind Button
local KeybindButton = Instance.new("TextButton")
KeybindButton.Name = "KeybindButton"
KeybindButton.Size = UDim2.new(0.6, 0, 0.1, 0)
KeybindButton.Position = UDim2.new(0.05, 0, 0.61, 0)
KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeybindButton.BorderSizePixel = 0
KeybindButton.Text = "Click to set keybind"
KeybindButton.TextColor3 = COLORS.TEXT_PRIMARY
KeybindButton.Font = Enum.Font.Gotham
KeybindButton.TextSize = 14
KeybindButton.Parent = MainFrame

-- Add rounded corners to keybind button
local KeybindButtonCorner = Instance.new("UICorner")
KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
KeybindButtonCorner.Parent = KeybindButton

-- Clear Keybind Button
local ClearKeybindButton = Instance.new("TextButton")
ClearKeybindButton.Name = "ClearKeybindButton"
ClearKeybindButton.Size = UDim2.new(0.25, 0, 0.1, 0)
ClearKeybindButton.Position = UDim2.new(0.7, 0, 0.61, 0)
ClearKeybindButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ClearKeybindButton.BorderSizePixel = 0
ClearKeybindButton.Text = "Clear"
ClearKeybindButton.TextColor3 = COLORS.TEXT_PRIMARY
ClearKeybindButton.Font = Enum.Font.GothamBold
ClearKeybindButton.TextSize = 14
ClearKeybindButton.Parent = MainFrame

-- Add rounded corners to clear keybind button
local ClearKeybindButtonCorner = Instance.new("UICorner")
ClearKeybindButtonCorner.CornerRadius = UDim.new(0, 4)
ClearKeybindButtonCorner.Parent = ClearKeybindButton

-- Flash Step Button
local FlashButton = Instance.new("TextButton")
FlashButton.Name = "FlashButton"
FlashButton.Size = UDim2.new(0.9, 0, 0.15, 0)
FlashButton.Position = UDim2.new(0.5, 0, 0.85, 0)
FlashButton.AnchorPoint = Vector2.new(0.5, 0.5)
FlashButton.BackgroundColor3 = COLORS.ACCENT
FlashButton.BorderSizePixel = 0
FlashButton.Text = "Flash Step: OFF"
FlashButton.TextColor3 = COLORS.TEXT_PRIMARY
FlashButton.Font = Enum.Font.GothamBold
FlashButton.TextSize = 16
FlashButton.Parent = MainFrame

-- Add rounded corners to button
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = FlashButton

-- Add a shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.Parent = MainFrame

-- Add drag handle for better control
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(1, 0, 0.25, 0)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

-- Flash Step Variables
local isFlashStepEnabled = false
local flashStepConnection = nil
local flashSpeedValue = 5     -- Default speed value (1-10)
local flashDistanceValue = 3  -- Default distance value (1-10)
local flashDelay = 0.05       -- Base delay between flashes
local flashDistance = 3       -- Base distance for flash step
local currentKeybind = nil    -- No default keybind
local isSettingKeybind = false
local keybindConnection = nil -- Connection for keybind detection

-- Function to convert slider value to actual delay
local function getFlashDelay(speedValue)
    -- Convert speed value (1-10) to delay (0.2-0.01)
    -- 1 = slowest (0.2s delay)
    -- 10 = fastest (0.01s delay)
    return 0.2 - ((speedValue - 1) * 0.021)
end

-- Function to convert slider value to actual distance
local function getFlashDistance(distanceValue)
    -- Convert distance value (1-10) to actual distance (1-10)
    return distanceValue
end

-- Update speed slider visuals and value
local function updateSpeedSlider(value)
    -- Clamp value between 1 and 10
    value = math.clamp(value, 1, 10)
    
    -- Update speed value
    flashSpeedValue = value
    flashDelay = getFlashDelay(value)
    
    -- Update slider visuals
    local percent = (value - 1) / 9
    SpeedSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SpeedSliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
    
    -- Update speed label
    SpeedLabel.Text = "Speed: " .. tostring(math.floor(flashSpeedValue))
end

-- Update distance slider visuals and value
local function updateDistanceSlider(value)
    -- Clamp value between 1 and 10
    value = math.clamp(value, 1, 10)
    
    -- Update distance value
    flashDistanceValue = value
    flashDistance = getFlashDistance(value)
    
    -- Update slider visuals
    local percent = (value - 1) / 9
    DistanceSliderFill.Size = UDim2.new(percent, 0, 1, 0)
    DistanceSliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
    
    -- Update distance label
    DistanceLabel.Text = "Distance: " .. tostring(math.floor(flashDistanceValue))
end

-- Function to get key name from KeyCode
local function getKeyName(keyCode)
    if keyCode then
        return keyCode.Name
    else
        return "None"
    end
end

-- Function to update keybind button text
local function updateKeybindText()
    if currentKeybind then
        KeybindButton.Text = getKeyName(currentKeybind)
    else
        KeybindButton.Text = "Click to set keybind"
    end
end

-- Flash Step Function with direct speed and distance control
local function performFlashStep()
    -- Get character and humanoid root part
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Use the current flash delay and distance (controlled by sliders)
    local currentDelay = flashDelay
    local currentDistance = flashDistance
    
    -- Zigzag movement with controlled timing and distance
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(currentDistance, 0, 0)
    task.wait(currentDelay)
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(-currentDistance*2, 0, 0)
    task.wait(currentDelay)
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(currentDistance, 0, 0)
    
    -- Add a small delay at the end to make the flash more visible
    -- This delay is also affected by the speed setting
    task.wait(currentDelay * 1.5)
end

-- Toggle Flash Step
local function toggleFlashStep()
    isFlashStepEnabled = not isFlashStepEnabled
    
    if isFlashStepEnabled then
        FlashButton.Text = "Flash Step: ON"
        FlashButton.BackgroundColor3 = Color3.fromRGB(100, 0, 200) -- Darker purple when on
        
        -- Start the flash step loop
        flashStepConnection = RunService.Heartbeat:Connect(function()
            performFlashStep()
        end)
    else
        FlashButton.Text = "Flash Step: OFF"
        FlashButton.BackgroundColor3 = COLORS.ACCENT
        
        -- Stop the flash step loop
        if flashStepConnection then
            flashStepConnection:Disconnect()
            flashStepConnection = nil
        end
    end
end

-- Function to setup keybind activation
local function setupKeybindActivation()
    -- Disconnect previous connection if it exists
    if keybindConnection then
        keybindConnection:Disconnect()
        keybindConnection = nil
    end
    
    -- Only setup if we have a keybind
    if currentKeybind then
        keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKeybind then
                toggleFlashStep()
            end
        end)
    end
end

-- Function to start keybind setting mode
local function startKeybindSetting()
    isSettingKeybind = true
    KeybindButton.Text = "Press any key..."
    KeybindButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    
    -- Disconnect previous connection if it exists
    if keybindConnection then
        keybindConnection:Disconnect()
        keybindConnection = nil
    end
    
    -- Create new connection for keybind detection
    keybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            -- Set the new keybind
            currentKeybind = input.KeyCode
            isSettingKeybind = false
            
            -- Update UI
            updateKeybindText()
            KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            
            -- Disconnect this temporary connection
            if keybindConnection then
                keybindConnection:Disconnect()
                keybindConnection = nil
            end
            
            -- Setup the keybind activation
            setupKeybindActivation()
        end
    end)
end

-- Function to clear keybind
local function clearKeybind()
    currentKeybind = nil
    updateKeybindText()
    
    -- Visual feedback
    ClearKeybindButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
    task.wait(0.2)
    ClearKeybindButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    
    -- Disconnect keybind activation if it exists
    if keybindConnection then
        keybindConnection:Disconnect()
        keybindConnection = nil
    end
end

-- Make speed slider interactive (without moving the main frame)
local isSpeedDragging = false

SpeedSliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSpeedDragging = true
        
        -- Calculate value based on mouse position
        local mousePos = input.Position.X
        local sliderPos = SpeedSliderBackground.AbsolutePosition.X
        local sliderSize = SpeedSliderBackground.AbsoluteSize.X
        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        local value = 1 + (percent * 9)
        
        updateSpeedSlider(value)
        
        -- Prevent event from propagating to parent
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isSpeedDragging = false
            end
        end)
    end
end)

-- Make distance slider interactive (without moving the main frame)
local isDistanceDragging = false

DistanceSliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDistanceDragging = true
        
        -- Calculate value based on mouse position
        local mousePos = input.Position.X
        local sliderPos = DistanceSliderBackground.AbsolutePosition.X
        local sliderSize = DistanceSliderBackground.AbsoluteSize.X
        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        local value = 1 + (percent * 9)
        
        updateDistanceSlider(value)
        
        -- Prevent event from propagating to parent
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDistanceDragging = false
            end
        end)
    end
end)

-- Handle slider dragging
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if isSpeedDragging then
            -- Calculate value based on mouse position
            local mousePos = input.Position.X
            local sliderPos = SpeedSliderBackground.AbsolutePosition.X
            local sliderSize = SpeedSliderBackground.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = 1 + (percent * 9)
            
            updateSpeedSlider(value)
        elseif isDistanceDragging then
            -- Calculate value based on mouse position
            local mousePos = input.Position.X
            local sliderPos = DistanceSliderBackground.AbsolutePosition.X
            local sliderSize = DistanceSliderBackground.AbsoluteSize.X
            local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            local value = 1 + (percent * 9)
            
            updateDistanceSlider(value)
        end
    end
end)

-- Make main frame draggable with boundary detection
local isDragging = false
local dragInput
local dragStart
local startPos

-- Function to check boundaries and clamp position
local function clampPosition(position)
    local viewportSize = Camera.ViewportSize
    local frameSize = MainFrame.AbsoluteSize
    
    -- Calculate boundaries
    local minX = 0
    local maxX = viewportSize.X - frameSize.X
    local minY = 0
    local maxY = viewportSize.Y - frameSize.Y
    
    -- Clamp position
    local clampedX = math.clamp(position.X.Offset, minX, maxX)
    local clampedY = math.clamp(position.Y.Offset, minY, maxY)
    
    return UDim2.new(0, clampedX, 0, clampedY)
end

DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if isDragging and dragInput and not isSpeedDragging and not isDistanceDragging then
        local delta = dragInput.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        -- Clamp position to screen boundaries
        newPosition = clampPosition(newPosition)
        
        MainFrame.Position = newPosition
    end
end)

-- Connect keybind button
KeybindButton.MouseButton1Click:Connect(function()
    if not isSettingKeybind then
        startKeybindSetting()
    end
end)

-- Connect clear keybind button
ClearKeybindButton.MouseButton1Click:Connect(clearKeybind)

-- Connect button click
FlashButton.MouseButton1Click:Connect(toggleFlashStep)

-- Connect character death to reset status
local function setupDeathConnection()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid.Died:Connect(function()
        if isFlashStepEnabled then
            toggleFlashStep() -- Turn off flash step
        end
    end)
end

-- Setup initial death connection
setupDeathConnection()

-- Connect to character added event
LocalPlayer.CharacterAdded:Connect(setupDeathConnection)

-- Add default F key keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F and not currentKeybind then
        toggleFlashStep()
    end
end)

-- Initialize sliders to default values
updateSpeedSlider(flashSpeedValue)
updateDistanceSlider(flashDistanceValue)
updateKeybindText()

-- Return GUI for reference
return ScreenGui
