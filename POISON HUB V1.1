-- Wrap the entire script in pcall for error handling
local success, errorMsg = pcall(function()
    -- Start with debug information
    print("Script execution starting...")
    print("Current time: " .. os.date("%X"))
    print("Initializing variables...")

    -- Add global variable for chat spam toggle first so it's available throughout the script
    _G.ChatSpamEnabled = true
    print("_G.ChatSpamEnabled initialized: " .. tostring(_G.ChatSpamEnabled))

    -- Initialize services first to avoid nil references
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local TextService = game:GetService("TextService")
    local StarterGui = game:GetService("StarterGui")
    
    print("Services initialized successfully")

    -- Create a notification to show the script is working
    local function showNotification(title, text, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration
            })
        end)
    end

    -- Show a notification that the script is starting
    showNotification("Poison Hub", "Script is starting...", 3)
    print("Initial notification shown")

    -- Safely load BigBaseplate with error handling
    local function safelyLoadBigBaseplate()
        print("Attempting to load BigBaseplate...")
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/loading123599/Poisons-Hub-V1.1/refs/heads/main/BigBaseplate.lua")
        end)
        
        if not success then
            warn("Failed to fetch BigBaseplate: " .. tostring(result))
            return false
        end
        
        print("BigBaseplate fetched, attempting to execute...")
        local loadSuccess, loadError = pcall(function()
            loadstring(result)()
        end)
        
        if not loadSuccess then
            warn("Failed to execute BigBaseplate: " .. tostring(loadError))
            return false
        end
        
        print("BigBaseplate loaded successfully!")
        return true
    end

    -- Try to load BigBaseplate but continue even if it fails
    print("Calling safelyLoadBigBaseplate function...")
    local bigBaseplateLoaded = safelyLoadBigBaseplate()
    if not bigBaseplateLoaded then
        warn("Continuing without BigBaseplate...")
    end

    -- Rest of your script continues here...
    print("Loading Player Tags system...")

    -- Show credits notification
    local function showCredits()
        print("Showing credits notification...")
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CreditsGui"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        if RunService:IsStudio() then
            screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        else
            pcall(function()
                screenGui.Parent = game.CoreGui
            end)
            
            if not screenGui.Parent then
                screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
            end
        end
        
        local frame = Instance.new("Frame")
        frame.Name = "CreditsFrame"
        frame.Size = UDim2.new(0, 350, 0, 100)
        frame.Position = UDim2.new(0.5, -175, 0, -100) -- Start off-screen
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(138, 43, 226) -- Purple
        stroke.Thickness = 2
        stroke.Parent = frame
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 10)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Text = "Credits"
        title.Parent = frame
        
        local message = Instance.new("TextLabel")
        message.Name = "Message"
        message.Size = UDim2.new(1, -20, 0, 60)
        message.Position = UDim2.new(0, 10, 0, 40)
        message.BackgroundTransparency = 1
        message.Font = Enum.Font.Gotham
        message.TextColor3 = Color3.fromRGB(255, 255, 255)
        message.TextSize = 14
        message.TextWrapped = true
        message.Text = "All credits go to AK ADMIN, join their server\ndiscord.gg/akadmin"
        message.Parent = frame
        
        -- Slide in animation
        local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Position = UDim2.new(0.5, -175, 0, 20)})
        tweenIn:Play()
        
        -- Wait 10 seconds then slide out
        spawn(function()
            wait(10)
            local tweenOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
                {Position = UDim2.new(0.5, -175, 0, -100)})
            tweenOut:Play()
            tweenOut.Completed:Wait()
            screenGui:Destroy()
        end)
        print("Credits notification created successfully")
    end

    -- Show credits when script loads
    print("Spawning credits notification...")
    spawn(showCredits)

    -- Rest of your script...
    -- (Include the rest of the script here)
    
    -- Checks if a value exists in a table (case-insensitive)
    local function containsIgnoreCase(tbl, name)
        if not tbl or not name then return false end
        name = name:lower()
        for _, v in ipairs(tbl) do
            if v:lower() == name then
                return true
            end
        end
        return false
    end

    -- Tag configuration
    local CONFIG = {
        TAG_SIZE = UDim2.new(0, 0, 0, 32),  -- height only, width will be dynamic
        TAG_OFFSET = Vector3.new(0, 2.0, 0),
        MAX_DISTANCE = 200000,
        DISTANCE_THRESHOLD = 50,      -- when player backs away 50 studs, tag minimizes
        HYSTERESIS = 5,               -- only switch state when crossing 45 studs on the way back (50-5)
        CORNER_RADIUS = UDim.new(0, 10),
        PARTICLE_COUNT = 20,         -- increased particle count
        PARTICLE_SPEED = 2,
        GLOW_INTENSITY = 0.3,
        TELEPORT_DISTANCE = 5,
        TELEPORT_HEIGHT = 0.5,
    }

    -- Define founders/owners with their custom tags (keeping original Poison Hub names and roles)
    local FounderTags = {
       ["GoodHelper12345"] = "Poison VIP",
       ["1can3uss"] = "1can3uss",
       ["auralinker"] = "Poison Admin",
       ["YournothimbuddyXD"] = "AK Owner",
        ["Skyler_Saint"] = "Poison<3"
    }

    -- Rank data with colors and emojis (using Poison Hub ranks)
    local RankData = {
        ["Poison Owner"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(138, 43, 226), emoji = "👑" },
        ["Poison Admin"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(255, 0, 0), emoji = "⚡" },
        ["Poison VIP"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(255, 215, 0), emoji = "💎" },
        ["Poison User"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(128, 0, 128), emoji = "☠️" },
        ["Poison<3"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(255, 105, 180), emoji = "❤" },
        ["AK Owner"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(138, 43, 226), emoji = "👑" },
        ["1can3uss"] = { primary = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(138, 43, 226), emoji = "💵" }
    }

    local ChatWhitelist = {}

    -- Remove spaces from a string
    local function modifyString(randomText)
        local modified = ""
        for char in randomText:gmatch(".") do
            if char ~= " " then
                modified = modified .. char
            end
        end
        return modified
    end

    local message = "Poison Hub ON TOP ON TOP ABCDEFGH()"
    local modifiedMessage = modifyString(message)

    -- Create basic particle frames
    local function createParticles(tag, parent, accentColor)
        for i = 1, CONFIG.PARTICLE_COUNT do
            local particle = Instance.new("Frame")
            particle.Name = "Particle_" .. i
            particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6))
            particle.Position = UDim2.new(math.random(), math.random(-10, 10), 1 + math.random() * 0.5, 0)
            particle.BackgroundColor3 = accentColor
            particle.BackgroundTransparency = math.random(0, 0.4)
            particle.BorderSizePixel = 0
            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(1, 0)
            pCorner.Parent = particle
            particle.Parent = parent

            spawn(function()
                while tag and tag.Parent do
                    local startX = math.random()
                    local startOffsetX = math.random(-10, 10)
                    particle.Position = UDim2.new(startX, startOffsetX, 1 + math.random() * 0.5, 0)
                    particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6))
                    particle.BackgroundTransparency = math.random(0, 0.4)

                    local duration = math.random(10, 40) / (CONFIG.PARTICLE_SPEED * 10)
                    local endX = startX + (math.random() - 0.5) * 0.3
                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

                    local tween = TweenService:Create(particle, tweenInfo, {
                        Position = UDim2.new(endX, startOffsetX, -0.5, math.random(-20, 20)),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0)
                    })
                    tween:Play()
                    task.wait(math.random(20, 40) / (CONFIG.PARTICLE_SPEED * 10))
                end
            end)
        end
    end

    -- Teleport function
    local function teleportToPlayer(targetPlayer)
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character
        local targetCharacter = targetPlayer.Character
        if not (character and targetCharacter) then return end
        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not (humanoid and hrp and targetHRP) then return end
        local targetCFrame = targetHRP.CFrame
        local teleportPosition = targetCFrame.Position - (targetCFrame.LookVector * CONFIG.TELEPORT_DISTANCE)
        teleportPosition = teleportPosition + Vector3.new(0, CONFIG.TELEPORT_HEIGHT, 0)
        local particlepart = Instance.new("Part", workspace)
        particlepart.Transparency = 1
        particlepart.Anchored = true
        particlepart.CanCollide = false
        particlepart.Position = hrp.Position
        local transmitter1 = Instance.new("ParticleEmitter")
        transmitter1.Texture = "rbxassetid://241922778" -- Fixed asset ID
        transmitter1.Size = NumberSequence.new(4)
        transmitter1.Lifetime = NumberRange.new(0.15, 0.15)
        transmitter1.Rate = 100
        transmitter1.TimeScale = 0.25
        transmitter1.VelocityInheritance = 1
        transmitter1.Drag = 5
        transmitter1.Parent = particlepart
        local particlepart2 = Instance.new("Part", workspace)
        particlepart2.Transparency = 1
        particlepart2.Anchored = true
        particlepart2.CanCollide = false
        particlepart2.Position = teleportPosition
        local transmitter2 = Instance.new("ParticleEmitter")
        transmitter2.Texture = "rbxassetid://241922778" -- Fixed asset ID
        transmitter2.Size = NumberSequence.new(4)
        transmitter2.Lifetime = NumberRange.new(0.15, 0.15)
        transmitter2.Rate = 100
        transmitter2.TimeScale = 0.25
        transmitter2.VelocityInheritance = 1
        transmitter2.Drag = 5
        transmitter2.Parent = particlepart2
        local fadeTime = 0.1
        local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local meshParts = {}
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("MeshPart") then
                table.insert(meshParts, part)
            end
        end
        for _, part in ipairs(meshParts) do
            local tween = TweenService:Create(part, tweenInfo, {Transparency = 1})
            tween:Play()
        end
        task.wait(fadeTime)
        hrp.CFrame = CFrame.new(teleportPosition, targetHRP.Position)
        local teleportSound = Instance.new("Sound")
        teleportSound.SoundId = "rbxassetid://5066021887"
        local head = character:FindFirstChild("Head")
        if head then
            teleportSound.Parent = head
        else
            teleportSound.Parent = hrp
        end
        teleportSound.Volume = 0.5
        teleportSound:Play()
        for _, part in ipairs(meshParts) do
            local tween = TweenService:Create(part, tweenInfo, {Transparency = 0})
            tween:Play()
        end
        game.Debris:AddItem(teleportSound, 2)
        task.wait(1)
        particlepart:Destroy()
        particlepart2:Destroy()
    end

    -- Helper function to calculate text width
    local function getTextWidth(text, font, textSize)
        local size = TextService:GetTextSize(text, textSize, font, Vector2.new(2000, CONFIG.TAG_SIZE.Y.Offset))
        return math.ceil(size.X)
    end

    -- Function to create and apply nametag
    local function attachTagToHead(character, player, rankText)
        local head = character:FindFirstChild("Head")
        if not head then
            head = character:WaitForChild("Head", 1)
            if not head then return end
        end
        
        -- Disable default Roblox nametag
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        
        -- Remove any existing custom tag for this head
        for _, child in ipairs(head:GetChildren()) do
            if child.Name == "PoisonTag" then
                child:Destroy()
            end
        end

        local rankData = RankData[rankText] or RankData["Poison User"] -- Default fallback

        local tag = Instance.new("BillboardGui")
        tag.Name = "PoisonTag"
        tag.Adornee = head
        tag.Size = CONFIG.TAG_SIZE -- Initial size, will be updated
        tag.StudsOffset = CONFIG.TAG_OFFSET
        tag.AlwaysOnTop = true
        tag.MaxDistance = CONFIG.MAX_DISTANCE
        tag.LightInfluence = 0
        tag.ResetOnSpawn = false
        tag.Active = true

        local container = Instance.new("Frame")
        container.Name = "TagContainer"
        container.Size = UDim2.new(1, 0, 1, 0) -- Container fills the tag
        container.BackgroundColor3 = rankData.primary
        container.BackgroundTransparency = 0.15
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        container.Parent = tag

        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = CONFIG.CORNER_RADIUS
        containerCorner.Parent = container

        local border = Instance.new("UIStroke")
        border.Color = rankData.accent
        border.Thickness = 2
        border.Transparency = 0.2
        border.Parent = container

        local clickButton = Instance.new("TextButton")
        clickButton.Name = "ClickButton"
        clickButton.Size = UDim2.new(1, 0, 1, 0)
        clickButton.BackgroundTransparency = 1
        clickButton.Text = ""
        clickButton.ZIndex = 10
        clickButton.AutoButtonColor = false
        clickButton.Active = true
        clickButton.Parent = container

        -- Event connections for click/hover
        if player ~= Players.LocalPlayer then
            clickButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
            clickButton.MouseEnter:Connect(function()
                TweenService:Create(container, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
            end)
            clickButton.MouseLeave:Connect(function()
                TweenService:Create(container, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
            end)
        end

        local particlesContainer = Instance.new("Frame")
        particlesContainer.Name = "ParticlesContainer"
        particlesContainer.Size = UDim2.new(1, 0, 1, 0)
        particlesContainer.BackgroundTransparency = 1
        particlesContainer.ZIndex = 2
        particlesContainer.ClipsDescendants = true
        particlesContainer.Parent = container
        local pContainerCorner = Instance.new("UICorner")
        pContainerCorner.CornerRadius = UDim.new(1, 0)
        pContainerCorner.Parent = particlesContainer
        createParticles(tag, particlesContainer, rankData.accent)

        local emojiLabel = Instance.new("TextLabel")
        emojiLabel.Name = "EmojiLabel"
        emojiLabel.Size = UDim2.new(0, 30, 0, 30)
        emojiLabel.Position = UDim2.new(0, 8, 0.5, -15)
        emojiLabel.BackgroundTransparency = 1
        emojiLabel.Text = rankData.emoji
        emojiLabel.TextSize = 22
        emojiLabel.Font = Enum.Font.GothamBold
        emojiLabel.TextColor3 = Color3.new(1, 1, 1)
        emojiLabel.ZIndex = 5
        emojiLabel.Parent = container

        -- DisplayName label
        local displayNameLabel = Instance.new("TextLabel")
        displayNameLabel.Name = "DisplayNameLabel"
        displayNameLabel.BackgroundTransparency = 1
        local fullDisplayName = player.DisplayName or player.Name
        displayNameLabel.Text = "@" .. fullDisplayName
        displayNameLabel.TextSize = 10
        displayNameLabel.Font = Enum.Font.GothamBold
        displayNameLabel.TextColor3 = Color3.new(1, 1, 1)
        displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        displayNameLabel.ZIndex = 5

        -- Rank label
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Name = "RankLabel"
        rankLabel.BackgroundTransparency = 1
        rankLabel.Text = rankText
        rankLabel.TextSize = 14
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.TextColor3 = rankData.accent
        rankLabel.TextXAlignment = Enum.TextXAlignment.Left
        rankLabel.ZIndex = 5

        -- Dynamic Width Calculation
        local sidePadding = 16
        local emojiWidth = 36
        local emojiLabelWidth = 30
        local emojiLeftPadding = 8

        -- Calculate actual text widths needed
        local rankWidthActual = getTextWidth(rankLabel.Text, rankLabel.Font, rankLabel.TextSize)
        local displayNameWidthActual = getTextWidth(displayNameLabel.Text, displayNameLabel.Font, displayNameLabel.TextSize)
        local maxTextWidth = math.max(rankWidthActual, displayNameWidthActual)

        -- Calculate total width
        local totalWidth = emojiLeftPadding + emojiLabelWidth + sidePadding + maxTextWidth + sidePadding

        -- Update tag size
        tag.Size = UDim2.new(0, totalWidth, 0, CONFIG.TAG_SIZE.Y.Offset)
        container.Size = UDim2.new(1, 0, 1, 0)

        -- Position and Size Elements
        emojiLabel.Position = UDim2.new(0, emojiLeftPadding, 0.5, -15)
        emojiLabel.Size = UDim2.new(0, emojiLabelWidth, 0, 30)

        local textBlockXOffset = emojiLeftPadding + emojiLabelWidth + sidePadding

        -- Position and size rank label
        rankLabel.Position = UDim2.new(0, textBlockXOffset, 0, 3)
        rankLabel.Size = UDim2.new(0, rankWidthActual, 0, 16)
        rankLabel.Parent = container

        -- Position and size display name label
        displayNameLabel.Position = UDim2.new(0, textBlockXOffset, 0, 17)
        displayNameLabel.Size = UDim2.new(0, displayNameWidthActual, 0, 16)
        displayNameLabel.Parent = container

        -- Minimized configuration
        local isMinimized = false
        local FULL_SIZE = UDim2.new(0, totalWidth, 0, CONFIG.TAG_SIZE.Y.Offset)
        local MINI_SIZE = UDim2.new(0, 40, 0, 40)
        local MINI_OFFSET = Vector3.new(0, 1.0, 0)
        local activeTween = true

        -- Minimize/maximize tween loop
        spawn(function()
            while activeTween do
                if character and head and head.Parent and Players.LocalPlayer and Players.LocalPlayer.Character then
                    local localHead = Players.LocalPlayer.Character:FindFirstChild("Head")
                    if localHead then
                        local distance = (head.Position - localHead.Position).Magnitude
                        if distance > (CONFIG.DISTANCE_THRESHOLD + CONFIG.HYSTERESIS) and not isMinimized then
                            isMinimized = true
                            TweenService:Create(tag, TweenInfo.new(0.5), { Size = MINI_SIZE, StudsOffset = MINI_OFFSET }):Play()
                            TweenService:Create(rankLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
                            TweenService:Create(displayNameLabel, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
                            TweenService:Create(emojiLabel, TweenInfo.new(0.5), { Position = UDim2.new(0.5, -15, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), TextSize = 26 }):Play()
                            TweenService:Create(containerCorner, TweenInfo.new(0.5), { CornerRadius = UDim.new(1, 0) }):Play()
                        elseif distance < (CONFIG.DISTANCE_THRESHOLD - CONFIG.HYSTERESIS) and isMinimized then
                            isMinimized = false
                            TweenService:Create(tag, TweenInfo.new(0.5), { Size = FULL_SIZE, StudsOffset = CONFIG.TAG_OFFSET }):Play()
                            TweenService:Create(rankLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
                            TweenService:Create(displayNameLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
                            TweenService:Create(emojiLabel, TweenInfo.new(0.5), { Position = UDim2.new(0, 8, 0.5, -15), Size = UDim2.new(0, 30, 0, 30), TextSize = 22 }):Play()
                            TweenService:Create(containerCorner, TweenInfo.new(0.5), { CornerRadius = CONFIG.CORNER_RADIUS }):Play()
                        end
                    end
                else
                    activeTween = false
                end
                task.wait(0.2)
            end
        end)

        -- Cleanup logic
        tag.AncestryChanged:Connect(function(_, parent)
            if not parent then
                activeTween = false
            end
        end)
        
        Players.PlayerRemoving:Connect(function(removedPlayer)
            if removedPlayer == player then
                if tag and tag.Parent then
                    tag:Destroy()
                end
                activeTween = false
            end
        end)

        -- Parent the tag to the local player's PlayerGui
        tag.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

        -- Re-connect click button
        if player ~= Players.LocalPlayer then
            clickButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
        end
        
        return tag
    end

    local localTagChoice = true -- Auto-accept tags

    -- Modified Notification GUI function for Poison Hub - FIX: Added check for player UserId
    local function showPoisonHubNotification(player)
        -- Only show notification for the local player (script executor)
        if player ~= Players.LocalPlayer then return end
        
        local playerName = player.Name
        local notifMessage = "You have executed Poison Hub"
        
        -- FIX: Add check for player UserId
        local thumb = ""
        if player and player.UserId then
            local success, result = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success then 
                thumb = result 
            end
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PoisonHubNotificationGui"
        screenGui.ResetOnSpawn = false
        
        -- Use pcall to handle potential errors when parenting to CoreGui
        pcall(function()
            screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end)

        local frame = Instance.new("Frame")
        frame.Name = "NotificationFrame"
        frame.Size = UDim2.new(0, 300, 0, 80)
        frame.Position = UDim2.new(1, 310, 0, -80)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 12)
        uiCorner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(138, 43, 226) -- Purple
        stroke.Transparency = 0.2
        stroke.Thickness = 2
        stroke.Parent = frame

        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Name = "ProfilePic"
        imageLabel.Size = UDim2.new(0, 50, 0, 50)
        imageLabel.Position = UDim2.new(0, 10, 0, 15)
        imageLabel.BackgroundTransparency = 1
        imageLabel.Image = thumb
        imageLabel.Parent = frame

        local imgCorner = Instance.new("UICorner")
        imgCorner.CornerRadius = UDim.new(1, 0)
        imgCorner.Parent = imageLabel

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "NotificationText"
        textLabel.Size = UDim2.new(1, -70, 1, 0)
        textLabel.Position = UDim2.new(0, 60, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = notifMessage
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 16
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.Parent = frame

        -- Tweens
        local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -310, 0, 10)})
        tweenIn:Play()
        tweenIn.Completed:Wait()

        task.wait(3)

        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 310, 0, -80)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        screenGui:Destroy()
    end

    -- Function to create tag
    local function createTag(player, rankText)
        if player.Character then
            attachTagToHead(player.Character, player, rankText)
        end
        
        local charAddedConn = player.CharacterAdded:Connect(function(character)
            task.wait()
            attachTagToHead(character, player, rankText)
        end)
        
        local playerRemovingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
            if leavingPlayer == player then
                if charAddedConn then charAddedConn:Disconnect() end
                if playerRemovingConn then playerRemovingConn:Disconnect() end
            end
        end)
    end

    -- Player tag application logic - FIX: Only apply tags to specific players
    local function applyPlayerTag(player)
        if not player or not player:IsDescendantOf(Players) then
            return
        end
        
        local assignedTag = nil
        
        -- Check if player is a founder/owner
        if FounderTags[player.Name] then
            assignedTag = FounderTags[player.Name]
        elseif player == Players.LocalPlayer then
            -- Only give the local player (script executor) a tag
            assignedTag = "Poison User"
        end

        -- Remove existing tag if present
        if player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            for _, child in ipairs(head:GetChildren()) do
                if child.Name == "PoisonTag" then
                    child:Destroy()
                end
            end
            
            local localPlayerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
            if localPlayerGui then
                for _, gui in ipairs(localPlayerGui:GetChildren()) do
                    if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" and gui.Adornee == head then
                        gui:Destroy()
                    end
                end
            end
        end

        if assignedTag then
            createTag(player, assignedTag)
        end
    end

    -- Function to refresh all nametags
    local function refreshAllTags()
        for _, player in ipairs(Players:GetPlayers()) do
            applyPlayerTag(player)
        end
    end

    local localPlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Tag Refresh/Cleanup Coroutine - FIX: Only check for tags on whitelisted players
    spawn(function()
        while task.wait(2) do
            local validAdornees = {}
            local currentPlayers = Players:GetPlayers()

            for _, player in ipairs(currentPlayers) do
                -- Only check players who should have tags
                local shouldHaveTag = FounderTags[player.Name] or player == Players.LocalPlayer
                
                if shouldHaveTag and player.Character and player.Character:FindFirstChild("Head") then
                    table.insert(validAdornees, player.Character.Head)
                    local hasTag = false
                    
                    for _, gui in ipairs(localPlayerGui:GetChildren()) do
                        if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" and gui.Adornee == player.Character.Head then
                            hasTag = true
                            break
                        end
                    end

                    if not hasTag then
                        applyPlayerTag(player)
                    end
                end
            end

            -- Cleanup orphaned tags
            for i = #localPlayerGui:GetChildren(), 1, -1 do
                local gui = localPlayerGui:GetChildren()[i]
                if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" then
                    local adornee = gui.Adornee
                    if not adornee or not adornee:IsDescendantOf(workspace) or not table.find(validAdornees, adornee) then
                        gui:Destroy()
                    end
                end
            end
        end
    end)

    -- Initial setup for existing players - FIX: Only apply tags to specific players
    for _, player in ipairs(Players:GetPlayers()) do
        if FounderTags[player.Name] or player == Players.LocalPlayer then
            task.spawn(applyPlayerTag, player)
        end
    end

    -- Handle players joining - FIX: Only apply tags to specific players and only show notification for local player
    Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        
        -- Only apply tag if player is in whitelist or is the local player
        if FounderTags[player.Name] or player == Players.LocalPlayer then
            task.spawn(applyPlayerTag, player)
        end
        
        -- Only show notification for the local player (already fixed in the function)
        if player == Players.LocalPlayer then
            showPoisonHubNotification(player)
        end
    end)

    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(player)
        -- Remove the tag associated with the player from the local player's GUI
        local playerHead = player.Character and player.Character:FindFirstChild("Head")
        if playerHead and localPlayerGui then
            for _, gui in ipairs(localPlayerGui:GetChildren()) do
                if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" and gui.Adornee == playerHead then
                    gui:Destroy()
                    break
                end
            end
        end
    end)

    -- Create tag system API for the UI to use
    local TagSystem = {
        refreshTags = refreshAllTags,
        forceTag = function(player, rankType)
            if not player or not player:IsDescendantOf(Players) then
                warn("forceTag: Invalid player provided.")
                return false
            end
            
            if RankData[rankType] then
                print(string.format("Forcing tag '%s' for player %s", rankType, player.Name))
                
                -- Remove existing tag
                if player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    for _, child in ipairs(head:GetChildren()) do
                        if child.Name == "PoisonTag" then
                            child:Destroy()
                        end
                    end
                end
                
                -- Also remove from LocalPlayerGui
                for _, gui in ipairs(localPlayerGui:GetChildren()) do
                    if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" and gui.Adornee and gui.Adornee.Parent == player.Character then
                        gui:Destroy()
                    end
                end
                
                -- Create tag
                createTag(player, rankType)
                return true
            else
                warn(string.format("forceTag: Invalid rankType '%s' provided.", rankType))
                return false
            end
        end,
        getActiveUsers = function()
            local usersList = {}
            for _, player in ipairs(Players:GetPlayers()) do
                local hasTag = false
                if player.Character and player.Character:FindFirstChild("Head") then
                    for _, gui in ipairs(localPlayerGui:GetChildren()) do
                        if gui:IsA("BillboardGui") and gui.Name == "PoisonTag" and gui.Adornee == player.Character.Head then
                            hasTag = true
                            break
                        end
                    end
                end
                if hasTag then
                    table.insert(usersList, player.Name)
                end
            end
            return usersList
        end
    }

    print("Player Tags system loaded successfully!")

    -- Wait to ensure Player Tags are fully loaded
    wait(1)

    -- Finally, load the Mobile Buttons and Rayfield UI
    print("Loading Mobile Buttons and Rayfield UI...")

    -- Create the mobile buttons
    local function createMobileButtons()
       -- Check if the user is "1can3uss" - if so, skip creating buttons
       if Players.LocalPlayer.Name == "1can3uss" then
           print("Mobile buttons skipped for 1can3uss as requested")
           return -- Skip the rest of this function but continue with the script
       end
       
       -- Check if the user is on mobile
       local UserInputService = game:GetService("UserInputService")
       local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

       -- Create the GUI
       local MobileButtonsGui = Instance.new("ScreenGui")
       MobileButtonsGui.Name = "MobileButtonsGui"
       MobileButtonsGui.ResetOnSpawn = false
       MobileButtonsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

       -- Parent the GUI to the appropriate location
       if game:GetService("RunService"):IsStudio() then
           MobileButtonsGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
       else
           pcall(function()
               MobileButtonsGui.Parent = game.CoreGui
           end)
           
           if not MobileButtonsGui.Parent then
               MobileButtonsGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
           end
       end

       -- Only show for mobile users
       if not isMobile then
           -- Create a notification for non-mobile users
           local notification = Instance.new("TextLabel")
           notification.Size = UDim2.new(0, 200, 0, 50)
           notification.Position = UDim2.new(0.5, -100, 0.1, 0)
           notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
           notification.BackgroundTransparency = 0.5
           notification.TextColor3 = Color3.fromRGB(255, 255, 255)
           notification.Text = "Mobile buttons only available on mobile devices"
           notification.TextWrapped = true
           notification.Parent = MobileButtonsGui
           
           -- Remove notification after 5 seconds
           game:GetService("Debris"):AddItem(notification, 5)
           return
       end

       -- Create the B button
       local BButton = Instance.new("TextButton")
       BButton.Name = "BButton"
       BButton.Size = UDim2.new(0, 60, 0, 60)
       BButton.Position = UDim2.new(0.8, 0, 0.6, 0)
       BButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
       BButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
       BButton.Text = "B"
       BButton.TextSize = 24
       BButton.Font = Enum.Font.GothamBold
       BButton.Parent = MobileButtonsGui

       -- Create purple outline for B button
       local BOutline = Instance.new("UIStroke")
       BOutline.Color = Color3.fromRGB(128, 0, 128) -- Purple
       BOutline.Thickness = 3
       BOutline.Parent = BButton

       -- Round the corners
       local BCorner = Instance.new("UICorner")
       BCorner.CornerRadius = UDim.new(0.2, 0)
       BCorner.Parent = BButton

       -- Create the Z button
       local ZButton = Instance.new("TextButton")
       ZButton.Name = "ZButton"
       ZButton.Size = UDim2.new(0, 60, 0, 60)
       ZButton.Position = UDim2.new(0.65, 0, 0.6, 0)
       ZButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
       ZButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
       ZButton.Text = "Z"
       ZButton.TextSize = 24
       ZButton.Font = Enum.Font.GothamBold
       ZButton.Parent = MobileButtonsGui

       -- Create purple outline for Z button
       local ZOutline = Instance.new("UIStroke")
       ZOutline.Color = Color3.fromRGB(128, 0, 128) -- Purple
       ZOutline.Thickness = 3
       ZOutline.Parent = ZButton

       -- Round the corners
       local ZCorner = Instance.new("UICorner")
       ZCorner.CornerRadius = UDim.new(0.2, 0)
       ZCorner.Parent = ZButton

       -- Create the toggle button
       local ToggleButton = Instance.new("TextButton")
       ToggleButton.Name = "ToggleButton"
       ToggleButton.Size = UDim2.new(0, 40, 0, 40)
       ToggleButton.Position = UDim2.new(0.9, 0, 0.1, 0)
       ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
       ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
       ToggleButton.Text = "≡"
       ToggleButton.TextSize = 24
       ToggleButton.Font = Enum.Font.GothamBold
       ToggleButton.Parent = MobileButtonsGui

       -- Create purple outline for toggle button
       local ToggleOutline = Instance.new("UIStroke")
       ToggleOutline.Color = Color3.fromRGB(128, 0, 128) -- Purple
       ToggleOutline.Thickness = 3
       ToggleOutline.Parent = ToggleButton

       -- Round the corners
       local ToggleCorner = Instance.new("UICorner")
       ToggleCorner.CornerRadius = UDim.new(0.2, 0)
       ToggleCorner.Parent = ToggleButton

       -- Function to make a button draggable
       local function makeDraggable(button)
           local dragging = false
           local dragInput
           local dragStart
           local startPos
           
           button.InputBegan:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                   dragging = true
                   dragStart = input.Position
                   startPos = button.Position
                   
                   input.Changed:Connect(function()
                       if input.UserInputState == Enum.UserInputState.End then
                           dragging = false
                       end
                   end)
               end
           end)
           
           button.InputChanged:Connect(function(input)
               if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                   dragInput = input
               end
           end)
           
           UserInputService.InputChanged:Connect(function(input)
               if input == dragInput and dragging then
                   local delta = input.Position - dragStart
                   button.Position = UDim2.new(
                       startPos.X.Scale, 
                       startPos.X.Offset + delta.X, 
                       startPos.Y.Scale, 
                       startPos.Y.Offset + delta.Y
                   )
               end
           end)
       end

       -- Make buttons draggable
       makeDraggable(BButton)
       makeDraggable(ZButton)
       makeDraggable(ToggleButton)

       -- Function to simulate key press
       local function simulateKeyPress(keyCode)
           -- Fire virtual input events
           local vim = game:GetService("VirtualInputManager")
           
           -- Key down
           vim:SendKeyEvent(true, keyCode, false, game)
           
           -- Small delay
           wait(0.05)
           
           -- Key up
           vim:SendKeyEvent(false, keyCode, false, game)
       end

       -- Connect button press events
       BButton.MouseButton1Click:Connect(function()
           simulateKeyPress(Enum.KeyCode.B)
           
           -- Visual feedback
           BButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple flash
           wait(0.1)
           BButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Back to black
       end)

       ZButton.MouseButton1Click:Connect(function()
           simulateKeyPress(Enum.KeyCode.Z)
           
           -- Visual feedback
           ZButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple flash
           wait(0.1)
           ZButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Back to black
       end)

       -- Toggle button functionality
       local buttonsVisible = true
       ToggleButton.MouseButton1Click:Connect(function()
           buttonsVisible = not buttonsVisible
           
           BButton.Visible = buttonsVisible
           ZButton.Visible = buttonsVisible
           
           -- Visual feedback
           ToggleButton.BackgroundColor3 = Color3.fromRGB(128, 0, 128) -- Purple flash
           wait(0.1)
           ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Back to black
       end)

       -- Notification that buttons are ready
       local notification = Instance.new("TextLabel")
       notification.Size = UDim2.new(0, 200, 0, 50)
       notification.Position = UDim2.new(0.5, -100, 0.1, 0)
       notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
       notification.BackgroundTransparency = 0.5
       notification.TextColor3 = Color3.fromRGB(255, 255, 255)
       notification.Text = "Mobile buttons loaded! Drag to reposition."
       notification.TextWrapped = true
       notification.Parent = MobileButtonsGui

       -- Add purple outline to notification
       local notifOutline = Instance.new("UIStroke")
       notifOutline.Color = Color3.fromRGB(128, 0, 128) -- Purple
       notifOutline.Thickness = 2
       notifOutline.Parent = notification

       -- Round the corners
       local notifCorner = Instance.new("UICorner")
       notifCorner.CornerRadius = UDim.new(0.2, 0)
       notifCorner.Parent = notification

       -- Remove notification after 5 seconds
       game:GetService("Debris"):AddItem(notification, 5)

       print("Mobile buttons loaded successfully!")
    end

    -- Create mobile buttons
    print("Creating mobile buttons...")
    createMobileButtons()

    -- Wait to ensure mobile buttons are fully loaded
    wait(1)

    -- Load the Rayfield UI
    local function loadRayfieldUI()
       print("Loading Rayfield UI library...")
       
       -- Use pcall to catch any errors
       local success, Rayfield = pcall(function()
           return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
       end)
       
       if not success then
           warn("Failed to load Rayfield UI: " .. tostring(Rayfield))
           showNotification("Error", "Failed to load Rayfield UI. Check console for details.", 5)
           return nil
       end
       
       print("Rayfield UI library loaded, creating window...")
       local Window = Rayfield:CreateWindow({
          Name = "Poison's Hub ",
          Icon = 0,
          LoadingTitle = "Welcome. To Poison's Hub",
          LoadingSubtitle = "by Alex,and 9⁹9",
          Theme = {
                  TextColor = Color3.fromRGB(225, 225, 225),
                  Background = Color3.fromRGB(5, 5, 5),
                  Topbar = Color3.fromRGB(138, 43, 226),
                  Shadow = Color3.fromRGB(138, 43, 226),

                  NotificationBackground = Color3.fromRGB(138, 43, 226),
                  NotificationActionsBackground = Color3.fromRGB(138, 43, 226),

                  TabBackground = Color3.fromRGB(138, 43, 226),
                  TabStroke = Color3.fromRGB(138, 43, 226),
                  TabBackgroundSelected = Color3.fromRGB(138, 43, 226),
                  TabTextColor = Color3.fromRGB(0, 0, 0),

                  SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
                  ElementBackground = Color3.fromRGB(138, 43, 226),
                  ElementBackgroundHover = Color3.fromRGB(138, 43, 226),
                  SecondaryElementBackground = Color3.fromRGB(138, 43, 226),
                  ElementStroke = Color3.fromRGB(0, 0, 0),
                  SecondaryElementStroke = Color3.fromRGB(138, 43, 226),

                  SliderBackground = Color3.fromRGB(5, 5, 5),
                  SliderProgress = Color3.fromRGB(138, 43, 226),
                  SliderStroke = Color3.fromRGB(138, 43, 226),

                  ToggleBackground = Color3.fromRGB(138, 43, 226),
                  ToggleEnabled = Color3.fromRGB(138, 43, 226),
                  ToggleDisabled = Color3.fromRGB(0, 0, 0),
                  ToggleEnabledStroke = Color3.fromRGB(138, 43, 226),
                  ToggleDisabledStroke = Color3.fromRGB(0, 0, 0),
                  ToggleEnabledOuterStroke = Color3.fromRGB(138, 43, 226),
                  ToggleDisabledOuterStroke = Color3.fromRGB(138, 43, 226),

                  DropdownSelected = Color3.fromRGB(5, 5, 5),
                  DropdownUnselected = Color3.fromRGB(0, 0, 0),

                  InputBackground = Color3.fromRGB(0, 0, 0),
                  InputStroke = Color3.fromRGB(138, 43, 226),
                  PlaceholderColor = Color3.fromRGB(138, 43, 226)
              },
          DisableRayfieldPrompts = false,
          DisableBuildWarnings = false,

          ConfigurationSaving = {
             Enabled = true,
             FolderName = nil,
             FileName = "Poison's Hub"
          },

          Discord = {
             Enabled = true, 
             Invite = "nil", 
             RememberJoins = false
          },

          KeySystem = true,
          KeySettings = {
             Title = "Enter Key Below",
             Subtitle = "Key System",
             Note = "key is POISONONTOP", 
             FileName = "Key", 
             SaveKey = true,
             GrabKeyFromSite = false,  
             Key = {"POISONONTOP"}
          }
       })
         
       local Tab = Window:CreateTab("Main", "home")
       local Slider = Tab:CreateSlider({
          Name = "WalkSpeed",
          Range = {0, 210},
          Increment = 10,
          Suffix = "speed",
          CurrentValue = 10,
          Flag = "speed",
          Callback = function(Value)
           game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value    
          end,
       })
     
      local Divider = Tab:CreateDivider()
      
           local Button = Tab:CreateButton({
           Name = "BasePlate ",
           Callback = function()
             loadstring(game:HttpGet("https://pastebin.com/raw/bRfz41fk"))()

           end,
       })

     local Divider = Tab:CreateDivider()
     
    local Toggle = Tab:CreateToggle({
      Name = "Infinite Zoom",
      CurrentValue = false,
      Flag = "InfZoom",
      Callback = function(Value)
         local Players = game:GetService("Players")
         local player = Players.LocalPlayer
         local camera = workspace.CurrentCamera
         local StarterGui = game:GetService("StarterGui")

         if Value then
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = math.huge
            player.CameraMinZoomDistance = 0.5
            camera.CameraType = Enum.CameraType.Custom

            pcall(function()
               StarterGui:SetCore("SendNotification", {
                  Title = "Poison's Hub",
                  Text = "Infinite Zoom Enabled thx for using poisons hub my nigga<3 :heart:",
                  Duration = 4
               })
            end)
         else
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = 128
            player.CameraMinZoomDistance = 0
            camera.CameraType = Enum.CameraType.Custom

            pcall(function()
               StarterGui:SetCore("SendNotification", {
                  Title = "Poison's Hub",
                  Text = "Infinite Zoom Disabled :(",
                  Duration = 4
               })
            end)
         end
      end,
    })

       local Divider = Tab:CreateDivider()
     
       local Tab = Window:CreateTab("Universal", "rewind")
       local Button = Tab:CreateButton({
           Name = "Infinite Yield",
           Callback = function()
              loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
           end,
       })
     
    local Divider = Tab:CreateDivider()

           local Button = Tab:CreateButton({
           Name = "Emote Gui",
           Callback = function()
             loadstring(game:HttpGet("https://pastebin.com/raw/Etrj10ww"))()

           end,
       })
       
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Vc Unban",
           Callback = function()
               game:GetService("VoiceChatService"):joinVoice()
           end,
       })
     
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Empty Tool's",
           Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/likelysmith/EmptyTools/main/script"))()
           end,
       })
     
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Poison Hub (System Broken Remade)",
           Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/loading123599/Poisons-Hub-V1.1/refs/heads/main/Custom%20System%20Broken"))()
           end,
       })
     
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Flash Step",
           Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/loading123599/Poisons-Hub-V1.1/refs/heads/main/Flash%20step.lua"))()
           end,
       })
     
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Jerk Off Tool",
           Callback = function()
                loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
           end,
       })
         
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Face Fuck",
           Callback = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EnterpriseExperience/bruhlolw/refs/heads/main/face_bang_script.lua'))()
           end,
       })
     
    local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "Tp Tool",
           Callback = function()
               local player = game.Players.LocalPlayer 
               local mouse = player:GetMouse() 

               local tool = Instance.new("Tool") 
               tool.Name = "Teleport Tool" 
               tool.RequiresHandle = false 
               tool.Parent = player.Backpack 

               local function teleportToClick() 
                   local character = player.Character or player.CharacterAdded:Wait() 
                   local rootPart = character:FindFirstChild("HumanoidRootPart") 

                   if rootPart and mouse.Target then 
                       local targetPosition = mouse.Hit.Position 
                       rootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0)) 
                   end
               end

               tool.Activated:Connect(teleportToClick) 
           end 
       }) 
         
    local Divider = Tab:CreateDivider()

       local Tab = Window:CreateTab("Settings", "settings")
       
       -- Add Chat Spam Toggle
       local Toggle = Tab:CreateToggle({
          Name = "Chat Spam",
          CurrentValue = true,
          Flag = "ChatSpam",
          Callback = function(Value)
             _G.ChatSpamEnabled = Value
             if Value then
                showNotification("Poison Hub", "Chat spam enabled", 3)
             else
                showNotification("Poison Hub", "Chat spam disabled", 3)
             end
          end,
       })
       
       -- Add Player Tags tab and controls (ONLY FOR OWNERS)
       if FounderTags[Players.LocalPlayer.Name] then
           local TagsTab = Window:CreateTab("Player Tags", "user")
           
           local Button = TagsTab:CreateButton({
               Name = "Refresh Player Tags",
               Callback = function()
                   refreshAllTags()
               end,
           })
           
           local Paragraph = TagsTab:CreateParagraph({
               Title = "Player Tag Instructions",
               Content = "• Regular players get 'Poison User' tag\n• Owners get 'Poison Owner' tag\n• Available tag types: Poison Owner, Poison Admin, Poison VIP, Poison<3"
           })
           
           -- Add input for custom tag
           local Input = TagsTab:CreateInput({
               Name = "Add Custom Tag",
               PlaceholderText = "Username,TagType (e.g. player1,Poison Admin)",
               RemoveTextAfterFocusLost = true,
               Callback = function(Text)
                   local username, tagType = Text:match("([^,]+),([^,]+)")
                   if username and tagType then
                       TagSystem.forceTag(Players:FindFirstChild(username), tagType)
                       Rayfield:Notify({
                           Title = "Tag Added",
                           Content = "Added " .. tagType .. " tag to " .. username,
                           Duration = 3,
                       })
                   else
                       Rayfield:Notify({
                           Title = "Invalid Format",
                           Content = "Please use format: username,tagType",
                           Duration = 3,
                       })
                   end
               end,
           })
           
           -- List active users button
           local Button = TagsTab:CreateButton({
               Name = "List Active Users",
               Callback = function()
                   local activeUsers = TagSystem.getActiveUsers()
                   local userList = table.concat(activeUsers, ", ")
                   Rayfield:Notify({
                       Title = "Active Users",
                       Content = "Current users: " .. (userList ~= "" and userList or "None"),
                       Duration = 5,
                   })
               end,
           })
       end
       
       -- Add Info tab to explain the tag system
       local InfoTab = Window:CreateTab("Info", "info")
       local Paragraph = InfoTab:CreateParagraph({
           Title = "Important Information",
           Content = "Player tags are only visible to you. Other players who execute this script will see their own version of the tags. This is a client-side feature.\n\nAll credits go to AK ADMIN, join their server: discord.gg/akadmin"
       })
       
       local Divider = Tab:CreateDivider()

       local Tab = Window:CreateTab("Visuals", "eye")
       local Divider = Tab:CreateDivider()

       local Button = Tab:CreateButton({
           Name = "RTX shaders",
           Callback = function()
               loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
           end,
       })
       
       local Divider = Tab:CreateDivider()

       local Tab = Window:CreateTab("ReAnimation", "user")
       local Divider = Tab:CreateDivider()

       local Tab = Window:CreateTab("Copy Animation", "pen")
       local Divider = Tab:CreateDivider()
       
       print("Poisons-Hub-V1 loaded successfully!")
       
       return Window
    end

    -- Wait a short moment before loading Rayfield UI to ensure mobile buttons are set up
    wait(1)
    print("Starting Rayfield UI...")
    local window = loadRayfieldUI()

    if window then
        print("All components loaded successfully!")
        showNotification("Poison Hub", "All components loaded successfully!", 3)
    else
        warn("Failed to load Rayfield UI. The script may not function correctly.")
        showNotification("Warning", "Some components failed to load. The script may not function correctly.", 5)
    end

    -- Chat Spam Functionality with toggle check
    spawn(function()
        print("Starting chat spam functionality...")
        while true do
            if _G.ChatSpamEnabled then
                for i = 1, 10 do
                    pcall(function()
                        Players:Chat(modifiedMessage)
                    end)
                end
            end
            wait(10)
        end
    end)

    print("Poison Hub script execution completed!")
end)

-- Check if the script executed successfully
if not success then
    warn("SCRIPT ERROR: " .. tostring(errorMsg))
    
    -- Try to show a notification about the error
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Script Error",
            Text = "Error: " .. tostring(errorMsg),
            Duration = 10
        })
    end)
end
