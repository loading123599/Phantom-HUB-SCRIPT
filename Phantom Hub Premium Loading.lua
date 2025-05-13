-- Premium Loading Screen for Phantom Hub
-- With executor-specific file handling for GitHub image
-- Mobile-friendly, proper image scaling, and fade-in effect

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Color scheme (matching your existing UI)
local COLORS = {
    BACKGROUND = Color3.fromRGB(10, 10, 10),       -- Almost black
    ACCENT = Color3.fromRGB(130, 0, 255),          -- Bright purple
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),  -- White
    TEXT_SECONDARY = Color3.fromRGB(200, 180, 255) -- Light purple
}

-- Check if the device is mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

-- Download and save the image using executor functions
local function downloadImage()
    -- Create folder if it doesn't exist
    if not isfolder("PhantomHubPremium") then
        makefolder("PhantomHubPremium")
        print("Created folder: PhantomHubPremium")
    end
    
    -- GitHub image URL
    local imageUrl = "https://github.com/loading123599/Phantom-Hub-V1.1/blob/main/a_df8ec20590a2fd2c9dfdb24ba8795cdd.jpg?raw=true"
    local imagePath = "PhantomHubPremium/loading_image.jpg"
    
    -- Check if image already exists
    if not isfile(imagePath) then
        -- Download the image
        local success, imageData = pcall(function()
            return game:HttpGet(imageUrl)
        end)
        
        if success then
            -- Save the image
            writefile(imagePath, imageData)
            print("Downloaded and saved image to: " .. imagePath)
            return true
        else
            print("Failed to download image: " .. tostring(imageData))
            return false
        end
    else
        print("Image already exists at: " .. imagePath)
        return true
    end
end

-- Try to download the image
local imageDownloaded = pcall(downloadImage)

-- Create the loading screen GUI
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "PhantomHubPremiumLoader"
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingScreen.DisplayOrder = 999999 -- Ensure it's on top of everything
LoadingScreen.IgnoreGuiInset = true -- Cover the topbar
LoadingScreen.ResetOnSpawn = false -- Don't reset when character respawns

-- Try to use CoreGui if possible for better performance and security
pcall(function()
    LoadingScreen.Parent = game:GetService("CoreGui")
end)

-- Fallback to PlayerGui if CoreGui fails
if not LoadingScreen.Parent then
    LoadingScreen.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Background frame that covers the entire screen
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.Position = UDim2.fromScale(0, 0)
Background.BackgroundColor3 = COLORS.BACKGROUND
Background.BorderSizePixel = 0
Background.BackgroundTransparency = 1 -- Start fully transparent for fade-in
Background.Parent = LoadingScreen

-- Create a container for the loading content
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
-- Adjust size based on device type
ContentContainer.Size = isMobile and UDim2.fromScale(0.9, 0.8) or UDim2.fromScale(0.8, 0.8)
ContentContainer.Position = UDim2.fromScale(0.5, 0.5)
ContentContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Background

-- Create an aspect ratio constraint for the image to maintain proper proportions
local ImageContainer = Instance.new("Frame")
ImageContainer.Name = "ImageContainer"
ImageContainer.Size = UDim2.fromScale(0.7, 0.5) -- Larger container for the image
ImageContainer.Position = UDim2.fromScale(0.5, 0.4)
ImageContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ImageContainer.BackgroundTransparency = 1
ImageContainer.Parent = ContentContainer

-- Add aspect ratio constraint to maintain image proportions
local AspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
AspectRatioConstraint.AspectRatio = 16/9 -- Standard aspect ratio
AspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
AspectRatioConstraint.Parent = ImageContainer

-- Create the image that will move up and down
local PhantomImage = Instance.new("ImageLabel")
PhantomImage.Name = "PhantomImage"
PhantomImage.Size = UDim2.fromScale(1, 1) -- Fill the container
PhantomImage.Position = UDim2.fromScale(0.5, 0.5)
PhantomImage.AnchorPoint = Vector2.new(0.5, 0.5)
PhantomImage.BackgroundTransparency = 1
PhantomImage.ImageTransparency = 1 -- Start fully transparent for fade-in
-- Set proper scale type to prevent stretching
PhantomImage.ScaleType = Enum.ScaleType.Fit
PhantomImage.ResampleMode = Enum.ResamplerMode.Default

-- Try to use the downloaded image if available
if imageDownloaded and isfile("PhantomHubPremium/loading_image.jpg") then
    -- Use the executor's function to load the image from file
    pcall(function()
        PhantomImage.Image = getcustomasset("PhantomHubPremium/loading_image.jpg") or "rbxassetid://7733658504"
    end)
else
    -- Fallback to a Roblox asset
    PhantomImage.Image = "rbxassetid://7733658504"
end

PhantomImage.Parent = ImageContainer

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(0.9, 0, 0.1, 0)
LoadingText.Position = UDim2.new(0.5, 0, 0.7, 0)
LoadingText.AnchorPoint = Vector2.new(0.5, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.TextTransparency = 1 -- Start fully transparent for fade-in
LoadingText.Font = Enum.Font.GothamBold
-- Adjust text size based on device
LoadingText.TextSize = isMobile and 18 or 24
LoadingText.TextColor3 = COLORS.TEXT_PRIMARY
LoadingText.Text = "LOADING PHANTOM HUB PREMIUM"
LoadingText.TextWrapped = true -- Enable text wrapping for mobile
LoadingText.Parent = ContentContainer

-- Status text (shows loading progress or status)
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(0.9, 0, 0.05, 0)
StatusText.Position = UDim2.new(0.5, 0, 0.8, 0)
StatusText.AnchorPoint = Vector2.new(0.5, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextTransparency = 1 -- Start fully transparent for fade-in
StatusText.Font = Enum.Font.Gotham
-- Adjust text size based on device
StatusText.TextSize = isMobile and 14 or 18
StatusText.TextColor3 = COLORS.TEXT_SECONDARY
StatusText.Text = "Initializing..."
StatusText.TextWrapped = true -- Enable text wrapping for mobile
StatusText.Parent = ContentContainer

-- Loading bar background
local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Name = "LoadingBarBg"
-- Adjust size based on device
LoadingBarBg.Size = UDim2.new(isMobile and 0.8 or 0.6, 0, 0.02, 0)
LoadingBarBg.Position = UDim2.new(0.5, 0, 0.85, 0)
LoadingBarBg.AnchorPoint = Vector2.new(0.5, 0)
LoadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoadingBarBg.BackgroundTransparency = 1 -- Start fully transparent for fade-in
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.Parent = ContentContainer

-- Add rounded corners to loading bar background
local LoadingBarBgCorner = Instance.new("UICorner")
LoadingBarBgCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
LoadingBarBgCorner.Parent = LoadingBarBg

-- Loading bar fill
local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Name = "LoadingBarFill"
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0) -- Start at 0% width
LoadingBarFill.Position = UDim2.new(0, 0, 0, 0)
LoadingBarFill.BackgroundColor3 = COLORS.ACCENT
LoadingBarFill.BackgroundTransparency = 1 -- Start fully transparent for fade-in
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Parent = LoadingBarBg

-- Add rounded corners to loading bar fill
local LoadingBarFillCorner = Instance.new("UICorner")
LoadingBarFillCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
LoadingBarFillCorner.Parent = LoadingBarFill

-- Phantom Hub logo/branding
local BrandingText = Instance.new("TextLabel")
BrandingText.Name = "BrandingText"
BrandingText.Size = UDim2.new(0.9, 0, 0.05, 0)
BrandingText.Position = UDim2.new(0.5, 0, 0.95, 0)
BrandingText.AnchorPoint = Vector2.new(0.5, 0)
BrandingText.BackgroundTransparency = 1
BrandingText.TextTransparency = 1 -- Start fully transparent for fade-in
BrandingText.Font = Enum.Font.GothamBold
-- Adjust text size based on device
BrandingText.TextSize = isMobile and 12 or 16
BrandingText.TextColor3 = COLORS.ACCENT
BrandingText.Text = "PHANTOM HUB PREMIUM"
BrandingText.Parent = ContentContainer

-- Function to create the fade-in effect
local function fadeInLoadingScreen()
    -- Create a list of all elements that need to fade in
    local elementsToFade = {
        {object = Background, property = "BackgroundTransparency"},
        {object = PhantomImage, property = "ImageTransparency"},
        {object = LoadingText, property = "TextTransparency"},
        {object = StatusText, property = "TextTransparency"},
        {object = LoadingBarBg, property = "BackgroundTransparency"},
        {object = LoadingBarFill, property = "BackgroundTransparency"},
        {object = BrandingText, property = "TextTransparency"}
    }
    
    -- Create a smooth fade-in animation
    local fadeInTime = 1.2 -- 1.2 seconds for fade-in
    
    -- Stagger the fade-ins for a more dynamic effect
    for i, element in ipairs(elementsToFade) do
        local delay = (i - 1) * 0.1 -- Stagger each element by 0.1 seconds
        
        task.delay(delay, function()
            local tweenInfo = TweenInfo.new(
                fadeInTime - delay, -- Adjust time so all finish together
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            )
            
            local tweenGoal = {}
            tweenGoal[element.property] = 0 -- Fade to fully visible
            
            local tween = TweenService:Create(element.object, tweenInfo, tweenGoal)
            tween:Play()
        end)
    end
end

-- Function to create smooth up and down animation for the image
local function animateImageUpDown()
    -- Create a smooth up and down animation
    local tweenInfo = TweenInfo.new(
        2, -- Duration (2 seconds)
        Enum.EasingStyle.Sine, -- Sine easing for smooth movement
        Enum.EasingDirection.InOut, -- InOut for smooth transitions
        -1, -- Repeat infinitely
        true -- Yoyo (reverse) for up and down motion
    )
    
    -- Starting position
    local startPos = ImageContainer.Position
    
    -- Create up position (move up by 5% of screen height)
    local upPos = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset, 
        startPos.Y.Scale - 0.03, -- Reduced movement for better appearance
        startPos.Y.Offset
    )
    
    -- Create the tween
    local tween = TweenService:Create(ImageContainer, tweenInfo, {Position = upPos})
    
    -- Start the animation
    tween:Play()
end

-- Add a pulsing effect to the branding text
local function createPulseEffect()
    local tweenInfo = TweenInfo.new(
        1.5, -- Duration
        Enum.EasingStyle.Sine, -- Easing style
        Enum.EasingDirection.InOut, -- Easing direction
        -1, -- Repeat count (-1 means loop forever)
        true -- Reverses
    )
    
    local tween = TweenService:Create(
        BrandingText,
        tweenInfo,
        {TextTransparency = 0.5} -- Target transparency
    )
    
    -- Wait a moment before starting the pulse (after fade-in)
    task.delay(1.5, function()
        tween:Play()
    end)
end

-- Function to update loading progress
local function updateLoadingProgress(progress, status)
    -- Update loading bar
    local tween = TweenService:Create(
        LoadingBarFill,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(progress, 0, 1, 0)}
    )
    tween:Play()
    
    -- Update status text if provided
    if status then
        StatusText.Text = status
    end
end

-- Block input while loading
local function blockInput()
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Allow Alt+F4 and Windows key to work
            if input.KeyCode == Enum.KeyCode.F4 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
                return
            elseif input.KeyCode == Enum.KeyCode.LeftMeta or input.KeyCode == Enum.KeyCode.RightMeta then
                return
            end
            
            -- Block all other inputs
            input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.Cancel then
                    input.UserInputState = Enum.UserInputState.Cancel
                end
            end)
        end
    end)
    
    -- Return the connection so it can be disconnected later
    return inputConnection
end

-- Function to create a custom notification
local function createThankYouNotification()
    -- Create notification GUI
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "PhantomHubNotification"
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.ResetOnSpawn = false
    
    -- Try to use CoreGui if possible
    pcall(function()
        NotificationGui.Parent = game:GetService("CoreGui")
    end)
    
    -- Fallback to PlayerGui if CoreGui fails
    if not NotificationGui.Parent then
        NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create notification frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    -- Adjust size based on device
    NotificationFrame.Size = UDim2.new(0, isMobile and 250 or 300, 0, isMobile and 90 or 100)
    NotificationFrame.Position = UDim2.new(1, 20, 0.1, 0) -- Start off-screen to the right
    NotificationFrame.BackgroundColor3 = COLORS.BACKGROUND
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui
    
    -- Add rounded corners
    local NotificationCorner = Instance.new("UICorner")
    NotificationCorner.CornerRadius = UDim.new(0, 8)
    NotificationCorner.Parent = NotificationFrame
    
    -- Add accent bar on the left
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 5, 1, 0)
    AccentBar.Position = UDim2.new(0, 0, 0, 0)
    AccentBar.BackgroundColor3 = COLORS.ACCENT
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = NotificationFrame
    
    -- Add rounded corners to accent bar (only left side)
    local AccentBarCorner = Instance.new("UICorner")
    AccentBarCorner.CornerRadius = UDim.new(0, 8)
    AccentBarCorner.Parent = AccentBar
    
    -- Create a container for the user avatar
    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.Name = "AvatarContainer"
    -- Adjust size based on device
    AvatarContainer.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 50 or 60)
    AvatarContainer.Position = UDim2.new(0, isMobile and 15 or 20, 0.5, 0)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Parent = NotificationFrame
    
    -- Create user avatar image
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, 0, 1, 0)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    AvatarImage.Parent = AvatarContainer
    
    -- Add rounded corners to avatar
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
    AvatarCorner.Parent = AvatarImage
    
    -- Create thank you text
    local ThankYouText = Instance.new("TextLabel")
    ThankYouText.Name = "ThankYouText"
    ThankYouText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 25 or 30)
    ThankYouText.Position = UDim2.new(1, -10, 0, isMobile and 10 or 15)
    ThankYouText.AnchorPoint = Vector2.new(1, 0)
    ThankYouText.BackgroundTransparency = 1
    ThankYouText.Font = Enum.Font.GothamBold
    ThankYouText.TextSize = isMobile and 14 or 18
    ThankYouText.TextColor3 = COLORS.TEXT_PRIMARY
    ThankYouText.Text = "Thank You Premium User"
    ThankYouText.TextXAlignment = Enum.TextXAlignment.Right
    ThankYouText.Parent = NotificationFrame
    
    -- Create username text
    local UsernameText = Instance.new("TextLabel")
    UsernameText.Name = "UsernameText"
    UsernameText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 18 or 20)
    UsernameText.Position = UDim2.new(1, -10, 0, isMobile and 35 or 45)
    UsernameText.AnchorPoint = Vector2.new(1, 0)
    UsernameText.BackgroundTransparency = 1
    UsernameText.Font = Enum.Font.Gotham
    UsernameText.TextSize = isMobile and 12 or 14
    UsernameText.TextColor3 = COLORS.TEXT_SECONDARY
    UsernameText.Text = "@" .. LocalPlayer.Name
    UsernameText.TextXAlignment = Enum.TextXAlignment.Right
    UsernameText.Parent = NotificationFrame
    
    -- Create premium text
    local PremiumText = Instance.new("TextLabel")
    PremiumText.Name = "PremiumText"
    PremiumText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 18 or 20)
    PremiumText.Position = UDim2.new(1, -10, 0, isMobile and 55 or 65)
    PremiumText.AnchorPoint = Vector2.new(1, 0)
    PremiumText.BackgroundTransparency = 1
    PremiumText.Font = Enum.Font.Gotham
    PremiumText.TextSize = isMobile and 10 or 12
    PremiumText.TextColor3 = COLORS.ACCENT
    PremiumText.Text = "Phantom Hub Premium Activated"
    PremiumText.TextXAlignment = Enum.TextXAlignment.Right
    PremiumText.Parent = NotificationFrame
    
    -- Add shadow
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
    Shadow.Parent = NotificationFrame
    
    -- Calculate the final position based on screen size and device type
    local screenSize = workspace.CurrentCamera.ViewportSize
    local notifWidth = isMobile and 250 or 300
    local finalPosX = math.min(screenSize.X - notifWidth - 20, screenSize.X * 0.98 - notifWidth)
    
    -- Animate the notification sliding in
    local slideInTween = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, finalPosX, 0.1, 0)} -- Slide in from right, position based on screen size
    )
    
    slideInTween:Play()
    
    -- Wait and then slide out
    task.delay(5, function()
        local slideOutTween = TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0.1, 0)} -- Slide out to right
        )
        
        slideOutTween.Completed:Connect(function()
            NotificationGui:Destroy()
        end)
        
        slideOutTween:Play()
    end)
    
    return NotificationGui
end

-- Function to hide the loading screen with a SLOW fade-out effect
local function hideLoadingScreen(inputConnection)
    -- Disconnect the input blocking
    if inputConnection then
        inputConnection:Disconnect()
    end
    
    -- Create a slow fade-out effect (2 seconds)
    local fadeOutTween = TweenService:Create(
        Background,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    -- Also fade out all children
    for _, child in pairs(ContentContainer:GetDescendants()) do
        if child:IsA("GuiObject") and child.BackgroundTransparency < 1 then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            ):Play()
        end
        
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {TextTransparency = 1}
            ):Play()
        end
        
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {ImageTransparency = 1}
            ):Play()
        end
    end
    
    fadeOutTween.Completed:Connect(function()
        -- Remove the loading screen after fade-out
        LoadingScreen:Destroy()
        
        -- Show the thank you notification
        createThankYouNotification()
    end)
    
    fadeOutTween:Play()
end

-- Simulate loading process with guaranteed completion
local function simulateLoading(callback)
    local stages = {
        {progress = 0.1, status = "Checking premium status...", time = 0.5},
        {progress = 0.2, status = "Verifying user...", time = 0.5},
        {progress = 0.3, status = "Loading modules...", time = 0.5},
        {progress = 0.5, status = "Initializing features...", time = 0.5},
        {progress = 0.7, status = "Preparing UI...", time = 0.5},
        {progress = 0.9, status = "Almost ready...", time = 0.5},
        {progress = 1.0, status = "Welcome to Phantom Hub Premium!", time = 0.5}
    }
    
    -- Process each stage sequentially with coroutine to ensure completion
    coroutine.wrap(function()
        for i, stage in ipairs(stages) do
            updateLoadingProgress(stage.progress, stage.status)
            task.wait(stage.time) -- Wait for the specified time
        end
        
        -- Wait a moment on 100% before calling the callback
        task.wait(1) -- Wait 1 second at 100%
        
        -- Call the callback when done
        if callback then
            callback()
        end
    end)()
end

-- Function to handle screen orientation changes for mobile
local function setupOrientationHandling()
    if isMobile then
        -- Connect to orientation changed event
        local orientationConnection
        orientationConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            -- Get new viewport size
            local viewportSize = workspace.CurrentCamera.ViewportSize
            
            -- Adjust UI elements based on orientation
            local isPortrait = viewportSize.Y > viewportSize.X
            
            if isPortrait then
                -- Portrait adjustments
                ImageContainer.Size = UDim2.fromScale(0.8, 0.4)
                LoadingText.TextSize = 16
                StatusText.TextSize = 12
                BrandingText.TextSize = 10
            else
                -- Landscape adjustments
                ImageContainer.Size = UDim2.fromScale(0.7, 0.5)
                LoadingText.TextSize = 18
                StatusText.TextSize = 14
                BrandingText.TextSize = 12
            end
        end)
        
        -- Return the connection so it can be disconnected later
        return orientationConnection
    end
    
    return nil
end

-- Main function to start the loading screen
local function startPremiumLoading(loadingTime)
    loadingTime = loadingTime or 5 -- Default loading time in seconds
    
    -- Start with fade-in effect
    fadeInLoadingScreen()
    
    -- Setup orientation handling for mobile
    local orientationConnection = setupOrientationHandling()
    
    -- Start animations after a short delay (after fade-in starts)
    task.delay(0.5, function()
        createPulseEffect()
        animateImageUpDown()
    end)
    
    -- Block input and get the connection
    local inputConnection = blockInput()
    
    -- Start the loading simulation with guaranteed completion after fade-in
    task.delay(1.2, function() -- Wait for fade-in to complete
        simulateLoading(function()
            -- Hide the loading screen when done - with SLOW fade-out
            hideLoadingScreen(inputConnection)
            
            -- Disconnect orientation handling if it exists
            if orientationConnection then
                orientationConnection:Disconnect()
            end
        end)
    end)
    
    -- Failsafe: Force close after a maximum time to prevent getting stuck
    task.delay(loadingTime + 7, function() -- Extended to account for fade-in and fade-out time
        if LoadingScreen.Parent then
            print("Loading screen failsafe triggered - forcing close")
            hideLoadingScreen(inputConnection)
            
            -- Disconnect orientation handling if it exists
            if orientationConnection then
                orientationConnection:Disconnect()
            end
        end
    end)
end

-- Start the loading screen
startPremiumLoading(5) -- 5 seconds loading time

-- Return the loading screen object for external control
return {
    UpdateProgress = updateLoadingProgress,
    Hide = function() hideLoadingScreen() end
}
