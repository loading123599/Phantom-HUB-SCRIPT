-- Phantom Hub Premium Animation System
-- UI by Phantom Hub, Reanimation script by AK ADMIN

Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TweenService = game:GetService("TweenService")
LocalPlayer = Players.LocalPlayer
HttpService = game:GetService("HttpService") -- Get HttpService for JSON

-- Variables for state storage
local ghostEnabled = false
local originalCharacter
local ghostClone
local originalCFrame
local originalAnimateScript
local updateConnection

-- Variable to store the original HipHeight of the clone
local ghostOriginalHipHeight

-- Clone settings: overall scale and extra width factor (default = 1, i.e., original size)
local cloneSize = 1
local cloneWidth = 1

-- Tables to store the original sizes of parts and Motor6D CFrames (for non-uniform scaling)
local ghostOriginalSizes = {}
local ghostOriginalMotorCFrames = {}

-- List of body parts to synchronize
local bodyParts = {
"Head", "UpperTorso", "LowerTorso",
"LeftUpperArm", "LeftLowerArm", "LeftHand",
"RightUpperArm", "RightLowerArm", "RightHand",
"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
"RightUpperLeg", "RightLowerLeg", "RightFoot"
}

-- Built-in Animations R15 (Example - you can expand this table)
-- Built-in Animations R15
local BuiltInAnimationsR15 = {
    -- Animation IDs removed as requested - you'll add them later
}

local newAnimations = {
    -- Animation IDs removed as requested - you'll add them later
}

-- NEW: Table to store custom animations (name -> ID)
local customAnimations = {}

-- Check for duplicates and add new animations
local existingIds = {}
for _, id in pairs(BuiltInAnimationsR15) do
    existingIds[id] = true
end

for animName, animId in pairs(newAnimations) do
    if not existingIds[animId] then
        BuiltInAnimationsR15[animName] = animId
        print("Added animation:", animName, "with ID:", animId)
    else
        print("Duplicate animation ID found, skipping:", animName, "with ID:", animId)
    end
end

-- NEW: Table to store favorite animations (by name)
local favoriteAnimations = {}
-- NEW: Table to store keybinds for animations (animation name -> KeyCode)
local animationKeybinds = {}
-- NEW: Table to track currently playing animations by keybind
local activeAnimationsByKeybind = {}

-- Function to save favorite animations to a file
local function saveFavorites()
    local success, encodedFavorites = pcall(HttpService.JSONEncode, HttpService, favoriteAnimations)
    if success then
        if writefile then
            local saveSuccess, errorMessage = pcall(function()
                writefile("favorite_animations.json", encodedFavorites)
            end)
            if not saveSuccess then
                warn("Error saving favorites:", errorMessage)
            end
        else
            warn("File system functions not supported in this environment")
        end
    else
        warn("Error encoding favorites:", encodedFavorites)
    end
end

-- Function to load favorite animations from a file
local function loadFavorites()
    local success, fileContent = pcall(readfile, "favorite_animations.json")
    if success then
        local decodeSuccess, decodedFavorites = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)
        if decodeSuccess and typeof(decodedFavorites) == "table" then
            favoriteAnimations = decodedFavorites
            print("Favorites loaded successfully.")
        else
            warn("Error decoding favorites:", decodedFavorites)
            favoriteAnimations = {}
        end
    else
        warn("No favorites file found, starting with empty favorites")
        favoriteAnimations = {}
    end
end

-- NEW: Function to save custom animations to a file
local function saveCustomAnimations()
    local success, encodedCustom = pcall(HttpService.JSONEncode, HttpService, customAnimations)
    if success then
        if writefile then
            local saveSuccess, errorMessage = pcall(function()
                writefile("custom_animations.json", encodedCustom)
            end)
            if not saveSuccess then
                warn("Error saving custom animations:", errorMessage)
            end
        else
            warn("File system functions not supported in this environment")
        end
    else
        warn("Error encoding custom animations:", encodedCustom)
    end
end

-- NEW: Function to load custom animations from a file
local function loadCustomAnimations()
    local success, fileContent = pcall(readfile, "custom_animations.json")
    if success then
        local decodeSuccess, decodedCustom = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)
        if decodeSuccess and typeof(decodedCustom) == "table" then
            customAnimations = decodedCustom
            -- Add custom animations to the main animations table
            for animName, animId in pairs(customAnimations) do
                if not BuiltInAnimationsR15[animName] then
                    BuiltInAnimationsR15[animName] = animId
                    print("Loaded custom animation:", animName, "with ID:", animId)
                else
                    print("Custom animation name conflict:", animName, "- skipping")
                end
            end
            print("Custom animations loaded successfully.")
        else
            warn("Error decoding custom animations:", decodedCustom)
            customAnimations = {}
        end
    else
        print("No custom animations file found, starting with empty custom animations")
        customAnimations = {}
    end
end

-- NEW: Function to save animation keybinds to a file
local function saveKeybinds()
    local keybindsToSave = {}
    for animName, keyCode in pairs(animationKeybinds) do
        keybindsToSave[animName] = keyCode.Name -- Save KeyCode as String
    end
    local success, encodedKeybinds = pcall(HttpService.JSONEncode, HttpService, keybindsToSave)
    if success then
        local saveSuccess, errorMessage = pcall(function()
            writefile("animation_keybinds.json", encodedKeybinds) -- Changed to writefile and new filename
        end)
        if not saveSuccess then
            warn("Error saving keybinds:", errorMessage)
        end
    else
        warn("Error encoding keybinds:", encodedKeybinds)
    end
end

-- NEW: Function to load animation keybinds from a file
local function loadKeybinds()
    local success, fileContent = pcall(readfile, "animation_keybinds.json")
    if success then
        local decodeSuccess, decodedKeybinds = pcall(HttpService:JSONDecode(fileContent))
        if decodeSuccess and typeof(decodedKeybinds) == "table" then
            for animName, keyName in pairs(decodedKeybinds) do
                animationKeybinds[animName] = Enum.KeyCode[keyName] -- Convert String back to KeyCode
            end
            print("Keybinds loaded successfully.")
        else
            warn("Error decoding keybinds:", decodedKeybinds)
            animationKeybinds = {}
        end
    else
        warn("No keybinds file found, starting with empty keybinds:", fileContent)
        animationKeybinds = {}
    end
end

-- Load custom animations when the script starts
loadCustomAnimations()

-- Helper function to scale a CFrame uniformly (keeps rotation)
local function scaleCFrame(cf, scale)
    local pos = cf.Position * scale
    local xRot, yRot, zRot = cf:ToEulerAnglesXYZ()
    return CFrame.new(pos) * CFrame.Angles(xRot, yRot, zRot)
end

-- Function that moves the clone so its lowest point (Y-coordinate) is at 0
local function adjustCloneToGround(clone)
    if not clone then return end
    local lowestY = math.huge
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            local bottomY = part.Position.Y - (part.Size.Y / 2)
            if bottomY < lowestY then
                lowestY = bottomY
            end
        end
    end
    local groundY = 0
    local offset = groundY - lowestY
    if offset > 0 then
        if clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame + Vector3.new(0, offset, 0))
        else
            clone:TranslateBy(Vector3.new(0, offset, 0))
        end
    end
end

-- Functions to temporarily preserve GUIs (ResetOnSpawn)
local preservedGuis = {}
local function preserveGuis()
    local playerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.ResetOnSpawn then
                table.insert(preservedGuis, gui)
                gui.ResetOnSpawn = false
            end
        end
    end
end

local function restoreGuis()
    for _, gui in ipairs(preservedGuis) do
        gui.ResetOnSpawn = true
    end
    table.clear(preservedGuis)
end

-- Function to update the clone's scale using both cloneSize (uniform scaling)
-- and cloneWidth (extra scaling only on the X-axis).
local function updateCloneScale()
    if not ghostClone then return end
    for part, origSize in pairs(ghostOriginalSizes) do
        if part and part:IsA("BasePart") then
            part.Size = Vector3.new(origSize.X * cloneSize * cloneWidth, origSize.Y * cloneSize, origSize.Z * cloneSize)
        end
    end
    for motor, orig in pairs(ghostOriginalMotorCFrames) do
        if motor and motor:IsA("Motor6D") then
            local c0 = orig.C0
            local c1 = orig.C1
            local newC0 = CFrame.new(
                c0.Position.X * cloneSize * cloneWidth,
                c0.Position.Y * cloneSize,
                c0.Position.Z * cloneSize
            ) * CFrame.Angles(c0:ToEulerAnglesXYZ())
            local newC1 = CFrame.new(
                c1.Position.X * cloneSize * cloneWidth,
                c1.Position.Y * cloneSize,
                c1.Position.Z * cloneSize
            ) * CFrame.Angles(c1:ToEulerAnglesXYZ())
            motor.C0 = newC0
            motor.C1 = newC1
        end
    end

    local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
    if ghostHumanoid and ghostOriginalHipHeight then
        ghostHumanoid.HipHeight = ghostOriginalHipHeight * cloneSize
    end

    adjustCloneToGround(ghostClone)
end

-- Function to update the clone's transparency (fully invisible)
local function updateCloneTransparency()
    if not ghostClone then return end
    for _, part in pairs(ghostClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    local head = ghostClone:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                child.Transparency = 1
            end
        end
    end
end

-- Function to synchronize the ragdolled body parts
local function updateRagdolledParts()
    if not ghostEnabled or not originalCharacter or not ghostClone then return end
    for _, partName in ipairs(bodyParts) do
        local originalPart = originalCharacter:FindFirstChild(partName)
        local clonePart = ghostClone:FindFirstChild(partName)
        if originalPart and clonePart then
            originalPart.CFrame = clonePart.CFrame
            originalPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            originalPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Function to enable/disable ghost mode
local function setGhostEnabled(newState)
    ghostEnabled = newState

    if ghostEnabled then
        local char = LocalPlayer.Character
        if not char then
            warn("No character found!")
            return
        end

        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then
            warn("Character is missing either Humanoid or HumanoidRootPart!")
            return
        end

        originalCharacter = char
        originalCFrame = root.CFrame

        char.Archivable = true
        ghostClone = char:Clone()
        char.Archivable = false

        local originalName = originalCharacter.Name
        ghostClone.Name = originalName .. "_clone"

        local ghostHumanoid = ghostClone:FindFirstChildWhichIsA("Humanoid")
        if ghostHumanoid then
            ghostHumanoid.DisplayName = originalName .. "_clone"
            ghostOriginalHipHeight = ghostHumanoid.HipHeight
        end

        if not ghostClone.PrimaryPart then
            local hrp = ghostClone:FindFirstChild("HumanoidRootPart")
            if hrp then
                ghostClone.PrimaryPart = hrp
            end
        end

        for _, part in ipairs(ghostClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        local head = ghostClone:FindFirstChild("Head")
        if head then
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("Decal") then
                    child.Transparency = 1
                end
            end
        end

        ghostOriginalSizes = {}
        ghostOriginalMotorCFrames = {}
        for _, desc in ipairs(ghostClone:GetDescendants()) do
            if desc:IsA("BasePart") then
                ghostOriginalSizes[desc] = desc.Size
            elseif desc:IsA("Motor6D") then
                ghostOriginalMotorCFrames[desc] = { C0 = desc.C0, C1 = desc.C1 }
            end
        end

        if cloneSize ~= 1 or cloneWidth ~= 1 then
            updateCloneScale()
        end

        local animate = originalCharacter:FindFirstChild("Animate")
        if animate then
            originalAnimateScript = animate
            originalAnimateScript.Disabled = true
            originalAnimateScript.Parent = ghostClone
        end

        preserveGuis()
        ghostClone.Parent = originalCharacter.Parent

        adjustCloneToGround(ghostClone)

        LocalPlayer.Character = ghostClone
        if ghostHumanoid then
            Workspace.CurrentCamera.CameraSubject = ghostHumanoid
        end
        restoreGuis()

        if originalAnimateScript then
            originalAnimateScript.Disabled = false
        end

        task.delay(0, function() -- Changed delay to 0
            if not ghostEnabled then return end
            ReplicatedStorage.RagdollEvent:FireServer()
            task.delay(0, function()
                if not ghostEnabled then return end
                if updateConnection then updateConnection:Disconnect() end
                updateConnection = RunService.Heartbeat:Connect(updateRagdolledParts)
            end)
        end)

    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end

        if not originalCharacter or not ghostClone then return end

        for i = 1, 3 do
            ReplicatedStorage.UnragdollEvent:FireServer()
            task.wait(0.1)
        end

        local origRoot = originalCharacter:FindFirstChild("HumanoidRootPart")
        local ghostRoot = ghostClone:FindFirstChild("HumanoidRootPart")
        local targetCFrame = ghostRoot and ghostRoot.CFrame or originalCFrame

        local animate = ghostClone:FindFirstChild("Animate")
        if animate then
            animate.Disabled = true
            animate.Parent = originalCharacter
        end

        ghostClone:Destroy()

        if origRoot then
            origRoot.CFrame = targetCFrame
        end

        local origHumanoid = originalCharacter:FindFirstChildWhichIsA("Humanoid")
        preserveGuis()
        LocalPlayer.Character = originalCharacter
        if origHumanoid then
            Workspace.CurrentCamera.CameraSubject = origHumanoid
        end
        restoreGuis()

        if animate then
            task.wait(0.1)
            animate.Disabled = false
        end

        cloneSize = 1
        cloneWidth = 1
    end
end

-- NEW SECTION: Fake Animation on Ghost (Fake) Character --
local fakeAnimStop
local fakeAnimRunning = false
local fakeAnimSpeed = 1 -- Default speed (1.0 = 100%)
local currentPlayingAnimation = nil

local function stopFakeAnimation()
    fakeAnimStop = true
    fakeAnimRunning = false -- Ensure the loop breaks
    currentPlayingAnimation = nil
    
    -- Clear active animations tracking when stopping manually
    activeAnimationsByKeybind = {}
    
    for i,script in pairs(ghostClone:GetChildren()) do
        if script:IsA("LocalScript") and script.Enabled == false then
            script.Enabled=true
        end
    end
    -- Reset body parts to original positions
    if ghostClone then
        for motor, orig in pairs(ghostOriginalMotorCFrames) do
            if motor and motor:IsA("Motor6D") then
                motor.C0 = orig.C0
                motor.C1 = orig.C1
            end
        end

        -- Reset velocity on all body parts
        for _, partName in ipairs(bodyParts) do
            local part = ghostClone:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end

local function playFakeAnimation(animationId)
    if not ghostClone then
        warn("No fake character available!")
        return
    end
    if animationId == "" then return end
    
    -- If this animation is already playing, stop it instead
    if currentPlayingAnimation == animationId then
        stopFakeAnimation()
        return
    end
    
    -- If another animation is playing, stop it first
    if fakeAnimRunning then
        stopFakeAnimation()
    end
    
    -- Clear active animations tracking when starting a new animation
    activeAnimationsByKeybind = {}
    
    wait(0.1)
    -- Reset ghostClone scaling so it's at its original size
    cloneSize = 1
    cloneWidth = 1
    updateCloneScale()

    -- Reset joints to original values before applying animation transforms
    for motor, orig in pairs(ghostOriginalMotorCFrames) do
        motor.C0 = orig.C0
    end

    local success, NeededAssets = pcall(function()
        return game:GetObjects("rbxassetid://" .. animationId)[1]
    end)
    if not success or not NeededAssets then
        warn("Invalid Animation ID.")
        return
    end

    -- Set the current playing animation
    currentPlayingAnimation = animationId

    -- Get the joints from ghostClone (assuming an R15 rig)
    local character = ghostClone
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local head = character:WaitForChild("Head")
    local leftFoot = character:WaitForChild("LeftFoot")
    local leftHand = character:WaitForChild("LeftHand")
    local leftLowerArm = character:WaitForChild("LeftLowerArm")
    local leftLowerLeg = character:WaitForChild("LeftLowerLeg")
    local leftUpperArm = character:WaitForChild("LeftUpperArm")
    local leftUpperLeg = character:WaitForChild("LeftUpperLeg")
    local lowerTorso = character:WaitForChild("LowerTorso")
    local rightFoot = character:WaitForChild("RightFoot")
    local rightHand = character:WaitForChild("RightHand")
    local rightLowerArm = character:WaitForChild("RightLowerArm")
    local rightLowerLeg = character:WaitForChild("RightLowerLeg")
    local rightUpperArm = character:WaitForChild("RightUpperArm")
    local rightUpperLeg = character:WaitForChild("RightUpperLeg")
    local upperTorso = character:WaitForChild("UpperTorso")

    local Joints = {
        ["Torso"] = rootPart:FindFirstChild("RootJoint"),
        ["Head"] = head:FindFirstChild("Neck"),
        ["LeftUpperArm"] = leftUpperArm:FindFirstChild("LeftShoulder"),
        ["RightUpperArm"] = rightUpperArm:FindFirstChild("RightShoulder"),
        ["LeftUpperLeg"] = leftUpperLeg:FindFirstChild("LeftHip"),
        ["RightUpperLeg"] = rightUpperLeg:FindFirstChild("RightHip"),
        ["LeftFoot"] = leftFoot:FindFirstChild("LeftAnkle"),
        ["RightFoot"] = rightFoot:FindFirstChild("RightAnkle"),
        ["LeftHand"] = leftHand:FindFirstChild("LeftWrist"),
        ["RightHand"] = rightHand:FindFirstChild("RightWrist"),
        ["LeftLowerArm"] = leftLowerArm:FindFirstChild("LeftElbow"),
        ["RightLowerArm"] = rightLowerArm:FindFirstChild("RightElbow"),
        ["LeftLowerLeg"] = leftLowerLeg:FindFirstChild("LeftKnee"),
        ["RightLowerLeg"] = rightLowerLeg:FindFirstChild("RightKnee"),
        ["LowerTorso"] = lowerTorso:FindFirstChild("Root"),
        ["UpperTorso"] = upperTorso:FindFirstChild("Waist"),
    }
    
    fakeAnimStop = false
    fakeAnimRunning = true
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(2048,0.1,2048)
    part.Anchored = true
    part.Position = game.Players.LocalPlayer.Character.LowerTorso.Position + Vector3.new(0,-0.2,0)
    part.Transparency = 1
    part.Parent = workspace
    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
    wait(0.1)
    for i,script in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if script:IsA("LocalScript") and script.Enabled then
            script.Enabled=false
        end
    end
    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
    part:Destroy()
    spawn(function()
        while fakeAnimRunning do
        if fakeAnimStop then
            fakeAnimRunning = false
            break
        end

        pcall(function() -- Add pcall to handle errors gracefully
            local keyframes = NeededAssets:GetKeyframes()
            for ii = 1, #keyframes do
            if fakeAnimStop then break end

            local currentFrame = keyframes[ii]
            local nextFrame = keyframes[ii + 1] or keyframes[1] -- Loop back to first frame
            local currentTime = currentFrame.Time
            local nextTime = nextFrame.Time
            if nextTime <= currentTime then
                nextTime = nextTime + NeededAssets.Length
            end

            local frameLength = (nextTime - currentTime) / fakeAnimSpeed
            local startTime = tick()
            
            while tick() - startTime < frameLength and not fakeAnimStop do
                local alpha = (tick() - startTime) / frameLength
                
                pcall(function() -- Add nested pcall for pose updates
                for _, currentPose in pairs(currentFrame:GetDescendants()) do
                    local nextPose = nextFrame:FindFirstChild(currentPose.Name, true)
                    local motor = Joints[currentPose.Name]
                    
                    if motor and nextPose and ghostOriginalMotorCFrames[motor] then
                    local currentCF = ghostOriginalMotorCFrames[motor].C0 * currentPose.CFrame
                    local nextCF = ghostOriginalMotorCFrames[motor].C0 * nextPose.CFrame
                    motor.C0 = currentCF:Lerp(nextCF, alpha)
                    end
                end
                end)
                
                RunService.RenderStepped:Wait()
            end
            end
        end)
        
        -- Small delay to prevent tight loops if errors occur
        wait(0.03)
        end
    end)
end

-- Create the Phantom Hub Premium GUI
local function createPhantomHubGui()
    -- Load saved data
    loadCustomAnimations()
    loadFavorites()
    loadKeybinds()
    
    -- Create the main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PhantomHubPremium"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create the main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    mainFrame.BorderSizePixel = 0
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Fix the bottom corners of the title bar
    local titleBottom = Instance.new("Frame")
    titleBottom.Name = "TitleBottom"
    titleBottom.Size = UDim2.new(1, 0, 0, 8)
    titleBottom.Position = UDim2.new(0, 0, 1, -8)
    titleBottom.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBottom.BorderSizePixel = 0
    titleBottom.Parent = titleBar
    
    titleBar.Parent = mainFrame
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -36, 1, 0)
    titleText.Position = UDim2.new(0, 12, 0, 0)
    titleText.Text = "Phantom Hub Premium"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.BackgroundTransparency = 1
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -36, 0, 0)
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundTransparency = 1
    closeButton.Parent = titleBar
    
    -- Toggle button for reanimation
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, -16, 0, 36)
    toggleButton.Position = UDim2.new(0, 8, 0, 44)
    toggleButton.Text = "Enable Reanimation"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    toggleButton.BorderSizePixel = 0
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    toggleButton.Parent = mainFrame
    
    -- Search bar container
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(1, -16, 0, 36)
    searchContainer.Position = UDim2.new(0, 8, 0, 88)
    searchContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    searchContainer.BorderSizePixel = 0
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchContainer
    searchContainer.Parent = mainFrame
    
    -- Search icon
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 8, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://3926305904" -- Roblox magnifying glass icon
    searchIcon.ImageRectOffset = Vector2.new(964, 324)
    searchIcon.ImageRectSize = Vector2.new(36, 36)
    searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    searchIcon.Parent = searchContainer
    
    -- Search text box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -80, 1, 0)
    searchBox.Position = UDim2.new(0, 30, 0, 0)
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search animations..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.Gotham
    searchBox.BackgroundTransparency = 1
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer
    
    -- Add button
    local addButton = Instance.new("TextButton")
    addButton.Name = "AddButton"
    addButton.Size = UDim2.new(0, 50, 0, 28)
    addButton.Position = UDim2.new(1, -50, 0.5, -14)
    addButton.Text = "Add"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 14
    addButton.Font = Enum.Font.GothamBold
    addButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    addButton.BorderSizePixel = 0
    local addButtonCorner = Instance.new("UICorner")
    addButtonCorner.CornerRadius = UDim.new(0, 4)
    addButtonCorner.Parent = addButton
    addButton.Parent = searchContainer
    
    -- Animation list container
    local animListContainer = Instance.new("ScrollingFrame")
    animListContainer.Name = "AnimListContainer"
    animListContainer.Size = UDim2.new(1, -16, 1, -172) -- Adjusted for toggle button
    animListContainer.Position = UDim2.new(0, 8, 0, 132) -- Adjusted for toggle button
    animListContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    animListContainer.BorderSizePixel = 0
    animListContainer.ScrollBarThickness = 4
    animListContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    animListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = animListContainer
    animListContainer.Parent = mainFrame
    
    -- Speed control container
    local speedContainer = Instance.new("Frame")
    speedContainer.Name = "SpeedContainer"
    speedContainer.Size = UDim2.new(1, -16, 0, 36)
    speedContainer.Position = UDim2.new(0, 8, 1, -44)
    speedContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    speedContainer.BorderSizePixel = 0
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedContainer
    speedContainer.Parent = mainFrame
    
    -- Speed label
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0, 50, 1, 0)
    speedLabel.Position = UDim2.new(0, 8, 0, 0)
    speedLabel.Text = "Speed:"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedContainer
    
    -- Speed slider background
    local sliderBG = Instance.new("Frame")
    sliderBG.Name = "SliderBG"
    sliderBG.Size = UDim2.new(0, 150, 0, 4)
    sliderBG.Position = UDim2.new(0, 60, 0.5, -2)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderBG.BorderSizePixel = 0
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(0, 2)
    sliderBGCorner.Parent = sliderBG
    sliderBG.Parent = speedContainer
    
    -- Speed slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 2)
    sliderFillCorner.Parent = sliderFill
    sliderFill.Parent = sliderBG
    
    -- Speed slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "SliderKnob"
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(0.5, -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    sliderKnob.Parent = sliderFill
    
    -- Speed value label
    local speedValue = Instance.new("TextLabel")
    speedValue.Name = "SpeedValue"
    speedValue.Size = UDim2.new(0, 40, 1, 0)
    speedValue.Position = UDim2.new(1, -48, 0, 0)
    speedValue.Text = "100"
    speedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedValue.TextSize = 14
    speedValue.Font = Enum.Font.GothamBold
    speedValue.BackgroundTransparency = 1
    speedValue.TextXAlignment = Enum.TextXAlignment.Right
    speedValue.Parent = speedContainer
    
    -- Add Animation Popup
    local addAnimPopup = Instance.new("Frame")
    addAnimPopup.Name = "AddAnimPopup"
    addAnimPopup.Size = UDim2.new(0, 280, 0, 180)
    addAnimPopup.Position = UDim2.new(0.5, -140, 0.5, -90)
    addAnimPopup.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    addAnimPopup.BorderSizePixel = 0
    addAnimPopup.Visible = false
    addAnimPopup.ZIndex = 10
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 8)
    popupCorner.Parent = addAnimPopup
    addAnimPopup.Parent = screenGui
    
    -- Popup title
    local popupTitle = Instance.new("TextLabel")
    popupTitle.Name = "PopupTitle"
    popupTitle.Size = UDim2.new(1, 0, 0, 36)
    popupTitle.Text = "Add Animation"
    popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    popupTitle.TextSize = 16
    popupTitle.Font = Enum.Font.GothamBold
    popupTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    popupTitle.BorderSizePixel = 0
    popupTitle.ZIndex = 10
    local popupTitleCorner = Instance.new("UICorner")
    popupTitleCorner.CornerRadius = UDim.new(0, 8)
    popupTitleCorner.Parent = popupTitle
    
    -- Fix the bottom corners of the popup title
    local popupTitleBottom = Instance.new("Frame")
    popupTitleBottom.Name = "TitleBottom"
    popupTitleBottom.Size = UDim2.new(1, 0, 0, 8)
    popupTitleBottom.Position = UDim2.new(0, 0, 1, -8)
    popupTitleBottom.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    popupTitleBottom.BorderSizePixel = 0
    popupTitleBottom.ZIndex = 10
    popupTitleBottom.Parent = popupTitle
    
    popupTitle.Parent = addAnimPopup
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 40, 0, 20)
    nameLabel.Position = UDim2.new(0, 16, 0, 50)
    nameLabel.Text = "Name"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 10
    nameLabel.Parent = addAnimPopup
    
    -- Name input
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -32, 0, 36)
    nameInput.Position = UDim2.new(0, 16, 0, 70)
    nameInput.PlaceholderText = "Enter name..."
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    nameInput.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    nameInput.BorderSizePixel = 0
    nameInput.ZIndex = 10
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextSize = 14
    local nameInputCorner = Instance.new("UICorner")
    nameInputCorner.CornerRadius = UDim.new(0, 4)
    nameInputCorner.Parent = nameInput
    nameInput.Parent = addAnimPopup
    
    -- ID label
    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "IDLabel"
    idLabel.Size = UDim2.new(0, 40, 0, 20)
    idLabel.Position = UDim2.new(0, 16, 0, 110)
    idLabel.Text = "ID"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.TextSize = 14
    idLabel.Font = Enum.Font.Gotham
    idLabel.BackgroundTransparency = 1
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.ZIndex = 10
    idLabel.Parent = addAnimPopup
    
    -- ID input
    local idInput = Instance.new("TextBox")
    idInput.Name = "IDInput"
    idInput.Size = UDim2.new(1, -32, 0, 36)
    idInput.Position = UDim2.new(0, 16, 0, 130)
    idInput.PlaceholderText = "Enter id..."
    idInput.Text = ""
    idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    idInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    idInput.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    idInput.BorderSizePixel = 0
    idInput.ZIndex = 10
    idInput.Font = Enum.Font.Gotham
    idInput.TextSize = 14
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 4)
    idInputCorner.Parent = idInput
    idInput.Parent = addAnimPopup
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 80, 0, 36)
    cancelButton.Position = UDim2.new(0, 16, 1, -46)
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 14
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    cancelButton.BorderSizePixel = 0
    cancelButton.ZIndex = 10
    local cancelButtonCorner = Instance.new("UICorner")
    cancelButtonCorner.CornerRadius = UDim.new(0, 4)
    cancelButtonCorner.Parent = cancelButton
    cancelButton.Parent = addAnimPopup
    
    -- Add button for popup
    local popupAddButton = Instance.new("TextButton")
    popupAddButton.Name = "AddButton"
    popupAddButton.Size = UDim2.new(0, 80, 0, 36)
    popupAddButton.Position = UDim2.new(1, -96, 1, -46)
    popupAddButton.Text = "Add"
    popupAddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    popupAddButton.TextSize = 14
    popupAddButton.Font = Enum.Font.GothamBold
    popupAddButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    popupAddButton.BorderSizePixel = 0
    popupAddButton.ZIndex = 10
    local popupAddButtonCorner = Instance.new("UICorner")
    popupAddButtonCorner.CornerRadius = UDim.new(0, 4)
    popupAddButtonCorner.Parent = popupAddButton
    popupAddButton.Parent = addAnimPopup
    
    -- Table to store animation buttons for search functionality
    local animationButtons = {}
    
    -- Function to update animation button visibility based on search text
    local function updateAnimationButtonsVisibility(searchText)
        local yOffset = 5
        local visibleButtonCount = 0
        
        for animName, animButtonData in pairs(animationButtons) do
            if string.find(string.lower(animName), string.lower(searchText)) then
                animButtonData.Container.Visible = true
                animButtonData.Container.Position = UDim2.new(0, 5, 0, yOffset)
                yOffset = yOffset + 45
                visibleButtonCount = visibleButtonCount + 1
            else
                animButtonData.Container.Visible = false
            end
        end
        
        animListContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(0, yOffset))
    end
    
    -- Function to refresh the animation list
    local function refreshAnimationList()
        -- Clear existing buttons
        for _, animButtonData in pairs(animationButtons) do
            for _, element in pairs(animButtonData) do
                if element and typeof(element) == "Instance" then
                    element:Destroy()
                end
            end
        end
        animationButtons = {}
        
        -- Recreate buttons for all animations
        local yOffset = 5
        for animName, animId in pairs(BuiltInAnimationsR15) do
            -- Create a container for each animation entry
            local animContainer = Instance.new("Frame")
            animContainer.Name = animName .. "Container"
            animContainer.Size = UDim2.new(1, -10, 0, 40)
            animContainer.Position = UDim2.new(0, 5, 0, yOffset)
            animContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            animContainer.BorderSizePixel = 0
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 6)
            containerCorner.Parent = animContainer
            animContainer.Parent = animListContainer
            
            -- Animation name label
            local animNameLabel = Instance.new("TextLabel")
            animNameLabel.Name = animName .. "Label"
            animNameLabel.Size = UDim2.new(1, -100, 1, 0)
            animNameLabel.Position = UDim2.new(0, 10, 0, 0)
            animNameLabel.Text = animName
            animNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            animNameLabel.TextSize = 14
            animNameLabel.Font = Enum.Font.Gotham
            animNameLabel.BackgroundTransparency = 1
            animNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            animNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            animNameLabel.Parent = animContainer
            
            -- Play button
            local playButton = Instance.new("TextButton")
            playButton.Name = animName .. "PlayButton"
            playButton.Size = UDim2.new(0, 80, 0, 30)
            playButton.Position = UDim2.new(1, -90, 0.5, -15)
            playButton.Text = "Play"
            playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playButton.TextSize = 14
            playButton.Font = Enum.Font.GothamBold
            playButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            playButton.BorderSizePixel = 0
            local playButtonCorner = Instance.new("UICorner")
            playButtonCorner.CornerRadius = UDim.new(0, 4)
            playButtonCorner.Parent = playButton
            playButton.Parent = animContainer
            
            -- Play button click handler
            playButton.MouseButton1Click:Connect(function()
                if not ghostEnabled then
                    -- Show notification that reanimation needs to be enabled
                    local notification = Instance.new("TextLabel")
                    notification.Text = "Enable reanimation first!"
                    notification.Size = UDim2.new(0, 200, 0, 40)
                    notification.Position = UDim2.new(0.5, -100, 0, 10)
                    notification.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
                    notification.TextSize = 14
                    notification.Font = Enum.Font.GothamBold
                    notification.Parent = screenGui
                    local notifCorner = Instance.new("UICorner")
                    notifCorner.CornerRadius = UDim.new(0, 6)
                    notifCorner.Parent = notification
                    
                    game:GetService("Debris"):AddItem(notification, 2)
                    return
                end
                
                playFakeAnimation(tostring(animId))
                
                -- Update all play buttons to show "Stop" for this animation
                for otherName, otherButtonData in pairs(animationButtons) do
                    if otherName == animName then
                        otherButtonData.PlayButton.Text = "Stop"
                    else
                        otherButtonData.PlayButton.Text = "Play"
                    end
                end
            end)
            
            -- Keybind button
            local keybindButton = Instance.new("TextButton")
            keybindButton.Name = animName .. "KeybindButton"
            keybindButton.Size = UDim2.new(0, 30, 0, 30)
            keybindButton.Position = UDim2.new(1, -130, 0.5, -15)
            keybindButton.Text = "⌨"
            keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindButton.TextSize = 14
            keybindButton.Font = Enum.Font.GothamBold
            keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            keybindButton.BorderSizePixel = 0
            local keybindButtonCorner = Instance.new("UICorner")
            keybindButtonCorner.CornerRadius = UDim.new(0, 4)
            keybindButtonCorner.Parent = keybindButton
            keybindButton.Parent = animContainer
            
            -- Keybind button tooltip
            local keybindTooltip = Instance.new("TextLabel")
            keybindTooltip.Name = "KeybindTooltip"
            keybindTooltip.Size = UDim2.new(0, 100, 0, 30)
            keybindTooltip.Position = UDim2.new(0, -110, 0, 0)
            keybindTooltip.Text = "Set keybind"
            keybindTooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindTooltip.TextSize = 12
            keybindTooltip.Font = Enum.Font.Gotham
            keybindTooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            keybindTooltip.BorderSizePixel = 0
            keybindTooltip.Visible = false
            keybindTooltip.ZIndex = 10
            local tooltipCorner = Instance.new("UICorner")
            tooltipCorner.CornerRadius = UDim.new(0, 4)
            tooltipCorner.Parent = keybindTooltip
            keybindTooltip.Parent = keybindButton
            
            -- Show tooltip on hover
            keybindButton.MouseEnter:Connect(function()
                keybindTooltip.Visible = true
            end)
            
            keybindButton.MouseLeave:Connect(function()
                keybindTooltip.Visible = false
            end)
            
            -- Update keybind button text if a keybind exists
            if animationKeybinds[animName] then
                keybindTooltip.Text = "Keybind: " .. animationKeybinds[animName].Name
            end
            
            -- Keybind button click handler
            local isSettingKeybind = false
            keybindButton.MouseButton1Click:Connect(function()
                if isSettingKeybind then return end
                
                isSettingKeybind = true
                keybindButton.Text = "..."
                keybindButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        animationKeybinds[animName] = input.KeyCode
                        keybindButton.Text = "⌨"
                        keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        keybindTooltip.Text = "Keybind: " .. input.KeyCode.Name
                        isSettingKeybind = false
                        saveKeybinds()
                        connection:Disconnect()
                    end
                end)
            end)
            
            animationButtons[animName] = {
                Container = animContainer,
                NameLabel = animNameLabel,
                PlayButton = playButton,
                KeybindButton = keybindButton
            }
            
            yOffset = yOffset + 45
        end
        
        animListContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(0, yOffset))
    end
    
    -- Initialize the animation list
    refreshAnimationList()
    
    -- Search box functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateAnimationButtonsVisibility(searchBox.Text)
    end)
    
    -- Speed slider functionality
    local isDraggingSpeed = false
    
    local function updateSpeedFromPosition(input)
        local sliderPosition = (input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newSpeed = 0.5 + sliderPosition * 3.5 -- Range from 0.5 to 4.0
        
        -- Update slider visuals
        sliderFill.Size = UDim2.new(sliderPosition, 0, 1, 0)
        
        -- Update speed value
        local displaySpeed = math.floor(newSpeed * 100)
        speedValue.Text = tostring(displaySpeed)
        
        -- Update animation speed
        fakeAnimSpeed = newSpeed
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = true
            updateSpeedFromPosition(input)
        end
    end)
    
    sliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
        end
    end)
    
    sliderBG.InputChanged:Connect(function(input)
        if isDraggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSpeedFromPosition(input)
        end
    end)
    
    -- Initialize speed slider to 100%
    sliderFill.Size = UDim2.new(0.143, 0, 1, 0) -- ~14.3% position = 100% speed (0.5 + 0.143*3.5 = ~1.0)
    speedValue.Text = "100"
    fakeAnimSpeed = 1.0
    
    -- Add button functionality
    addButton.MouseButton1Click:Connect(function()
        nameInput.Text = ""
        idInput.Text = ""
        addAnimPopup.Visible = true
    end)
    
    -- Cancel button functionality
    cancelButton.MouseButton1Click:Connect(function()
        addAnimPopup.Visible = false
    end)
    
    -- Popup add button functionality
    popupAddButton.MouseButton1Click:Connect(function()
        local animName = nameInput.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        local animId = idInput.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        
        -- Validate inputs
        if animName == "" or animId == "" then
            return
        end
        
        -- Add to custom animations
        customAnimations[animName] = animId
        -- Add to built-in animations for immediate use
        BuiltInAnimationsR15[animName] = animId
        
        -- Save to file
        saveCustomAnimations()
        
        -- Hide popup
        addAnimPopup.Visible = false
        
        -- Refresh the animation list
        refreshAnimationList()
        updateAnimationButtonsVisibility(searchBox.Text)
    end)
    
    -- Toggle button functionality
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not ghostEnabled
        setGhostEnabled(newState)
        
        if newState then
            toggleButton.Text = "Disable Reanimation"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red for active
        else
            toggleButton.Text = "Enable Reanimation"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- Blue for inactive
            
            -- Reset all play buttons to "Play"
            for _, buttonData in pairs(animationButtons) do
                buttonData.PlayButton.Text = "Play"
            end
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Make the GUI draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            updateInput(input)
        end
    end)
    
    return screenGui
end

-- Create the GUI when the script runs
local phantomHubGui = createPhantomHubGui()

-- Keybind handling for animations
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end -- Don't process if chat or other UI is using input
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for animName, keyCode in pairs(animationKeybinds) do
            if input.KeyCode == keyCode then
                -- Check if this animation is already playing
                if currentPlayingAnimation == BuiltInAnimationsR15[animName] then
                    -- If it's playing, stop it
                    stopFakeAnimation()
                else
                    -- If it's not playing or a different animation is playing, play this one
                    if ghostEnabled then
                        playFakeAnimation(BuiltInAnimationsR15[animName])
                    end
                end
                return -- Stop checking after finding a match
            end
        end
    end
end)
