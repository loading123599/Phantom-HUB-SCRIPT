-- Poison Hub Animation System
-- UI by Poison Hub, Reanimation script by AK ADMIN

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
-- End of Fake Animation Section

-- NEW: Function to update Keybind Button Text
local function updateKeybindButtonText(animButtonData, animName)
    local keybind = animationKeybinds[animName]
    if keybind then
        animButtonData.KeybindButton.Text = keybind.Name -- Display KeyCode Name
    else
        animButtonData.KeybindButton.Text = "Key"
    end
end

-- Function to create the separate Animation List GUI
local function createAnimationListGui(animTextBox)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnimationListGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    loadFavorites() -- Load favorites when GUI is created
    loadKeybinds() -- Load keybinds when GUI is created

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 330, 0, 400)
    mainFrame.Position = UDim2.new(0.75, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Darker background
    mainFrame.BorderSizePixel = 0
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame
    mainFrame.Parent = screenGui

    -- Add a subtle gradient to the main frame
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    titleBar.Parent = mainFrame

    -- Add a subtle gradient to the title bar
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 63, 246))
    })
    titleGradient.Rotation = 45
    titleGradient.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 25, 0, 0)
    titleLabel.Text = "Poison Hub Animations"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Add Animation Button (+ button)
    local addAnimButton = Instance.new("TextButton")
    addAnimButton.Name = "AddAnimButton"
    addAnimButton.Size = UDim2.new(0, 36, 0, 36)
    addAnimButton.Position = UDim2.new(1, -80, 0, 7) -- Position it on the title bar
    addAnimButton.Text = "+"
    addAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addAnimButton.TextSize = 24
    addAnimButton.Font = Enum.Font.GothamBold
    addAnimButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75) -- Green color
    addAnimButton.BackgroundTransparency = 0.3
    addAnimButton.AutoButtonColor = true
    local addAnimCorner = Instance.new("UICorner")
    addAnimCorner.CornerRadius = UDim.new(1, 0) -- Circle
    addAnimCorner.Parent = addAnimButton
    addAnimButton.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -44, 0, 7)
    closeButton.Text = "×" -- Using a multiplication symbol for a cleaner look
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BackgroundTransparency = 0.3
    closeButton.AutoButtonColor = true
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    closeButton.Parent = titleBar

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 55)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Search TextBox with modern styling
    local animSearchTextBox = Instance.new("TextBox")
    animSearchTextBox.Name = "AnimSearchTextBox"
    animSearchTextBox.Text = ""
    animSearchTextBox.Size = UDim2.new(1, 0, 0, 36) -- Taller for better touch
    animSearchTextBox.Position = UDim2.new(0, 0, 0, 0)
    animSearchTextBox.PlaceholderText = "Search Animations..."
    animSearchTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    animSearchTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    animSearchTextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    animSearchTextBox.ClearTextOnFocus = false
    animSearchTextBox.Font = Enum.Font.Gotham
    animSearchTextBox.TextSize = 14
    local animSearchTextBoxCorner = Instance.new("UICorner")
    animSearchTextBoxCorner.CornerRadius = UDim.new(0, 8)
    animSearchTextBoxCorner.Parent = animSearchTextBox
    
    -- Add a search icon
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://3926305904" -- Roblox magnifying glass icon
    searchIcon.ImageRectOffset = Vector2.new(964, 324)
    searchIcon.ImageRectSize = Vector2.new(36, 36)
    searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
    searchIcon.Parent = animSearchTextBox
    
    -- Add padding for the search icon
    animSearchTextBox.TextXAlignment = Enum.TextXAlignment.Left
    animSearchTextBox.Text = "  "  -- Add space for the icon
    animSearchTextBox.Parent = contentFrame

    local animScrollFrame = Instance.new("ScrollingFrame")
    animScrollFrame.Name = "AnimScrollFrame"
    animScrollFrame.Size = UDim2.new(1, 0, 1, -46) -- Account for search box
    animScrollFrame.Position = UDim2.new(0, 0, 0, 46)
    animScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    animScrollFrame.BorderSizePixel = 0
    animScrollFrame.ScrollBarThickness = 4
    animScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226) -- Purple scrollbar
    animScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    local scrollFrameCorner = Instance.new("UICorner")
    scrollFrameCorner.CornerRadius = UDim.new(0, 8)
    scrollFrameCorner.Parent = animScrollFrame
    animScrollFrame.Parent = contentFrame

    -- Create the popup for adding custom animations (initially hidden)
    local addAnimPopup = Instance.new("Frame")
    addAnimPopup.Name = "AddAnimPopup"
    addAnimPopup.Size = UDim2.new(0, 300, 0, 200)
    addAnimPopup.Position = UDim2.new(0.5, -150, 0.5, -100)
    addAnimPopup.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    addAnimPopup.BorderSizePixel = 0
    addAnimPopup.Visible = false
    addAnimPopup.ZIndex = 10
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 10)
    popupCorner.Parent = addAnimPopup
    
    -- Add a shadow to the popup
    local popupShadow = Instance.new("ImageLabel")
    popupShadow.Name = "Shadow"
    popupShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    popupShadow.BackgroundTransparency = 1
    popupShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    popupShadow.Size = UDim2.new(1, 12, 1, 12)
    popupShadow.ZIndex = 9
    popupShadow.Image = "rbxassetid://6014261993"
    popupShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    popupShadow.ImageTransparency = 0.6
    popupShadow.ScaleType = Enum.ScaleType.Slice
    popupShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    popupShadow.Parent = addAnimPopup
    
    -- Popup title
    local popupTitle = Instance.new("TextLabel")
    popupTitle.Name = "Title"
    popupTitle.Size = UDim2.new(1, 0, 0, 40)
    popupTitle.Text = "Add Custom Animation"
    popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    popupTitle.TextSize = 18
    popupTitle.Font = Enum.Font.GothamBold
    popupTitle.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    popupTitle.BorderSizePixel = 0
    popupTitle.ZIndex = 10
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = popupTitle
    
    -- Fix the bottom corners of the title
    local titleBottom = Instance.new("Frame")
    titleBottom.Name = "TitleBottom"
    titleBottom.Size = UDim2.new(1, 0, 0, 10)
    titleBottom.Position = UDim2.new(0, 0, 1, -10)
    titleBottom.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleBottom.BorderSizePixel = 0
    titleBottom.ZIndex = 10
    titleBottom.Parent = popupTitle
    
    popupTitle.Parent = addAnimPopup
    
    -- Animation name input
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -40, 0, 20)
    nameLabel.Position = UDim2.new(0, 20, 0, 50)
    nameLabel.Text = "Animation Name:"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 10
    nameLabel.Parent = addAnimPopup
    
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -40, 0, 36)
    nameInput.Position = UDim2.new(0, 20, 0, 70)
    nameInput.PlaceholderText = "Enter animation name"
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    nameInput.BorderSizePixel = 0
    nameInput.ZIndex = 10
    local nameInputCorner = Instance.new("UICorner")
    nameInputCorner.CornerRadius = UDim.new(0, 6)
    nameInputCorner.Parent = nameInput
    nameInput.Parent = addAnimPopup
    
    -- Animation ID input
    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "IDLabel"
    idLabel.Size = UDim2.new(1, -40, 0, 20)
    idLabel.Position = UDim2.new(0, 20, 0, 116)
    idLabel.Text = "Animation ID:"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.TextSize = 14
    idLabel.Font = Enum.Font.GothamSemibold
    idLabel.BackgroundTransparency = 1
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.ZIndex = 10
    idLabel.Parent = addAnimPopup
    
    local idInput = Instance.new("TextBox")
    idInput.Name = "IDInput"
    idInput.Size = UDim2.new(1, -40, 0, 36)
    idInput.Position = UDim2.new(0, 20, 0, 136)
    idInput.PlaceholderText = "Enter animation ID"
    idInput.Text = ""
    idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    idInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    idInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    idInput.BorderSizePixel = 0
    idInput.ZIndex = 10
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 6)
    idInputCorner.Parent = idInput
    idInput.Parent = addAnimPopup
    
    -- Buttons
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0.5, -25, 0, 36)
    saveButton.Position = UDim2.new(0, 20, 1, -46)
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 16
    saveButton.Font = Enum.Font.GothamSemibold
    saveButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75) -- Green
    saveButton.BorderSizePixel = 0
    saveButton.ZIndex = 10
    local saveButtonCorner = Instance.new("UICorner")
    saveButtonCorner.CornerRadius = UDim.new(0, 6)
    saveButtonCorner.Parent = saveButton
    saveButton.Parent = addAnimPopup
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.5, -25, 0, 36)
    cancelButton.Position = UDim2.new(0.5, 5, 1, -46)
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.GothamSemibold
    cancelButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
    cancelButton.BorderSizePixel = 0
    cancelButton.ZIndex = 10
    local cancelButtonCorner = Instance.new("UICorner")
    cancelButtonCorner.CornerRadius = UDim.new(0, 6)
    cancelButtonCorner.Parent = cancelButton
    cancelButton.Parent = addAnimPopup
    
    addAnimPopup.Parent = screenGui

    -- Table to store animation buttons for search functionality
    local animationButtons = {}
    local keybindInputActive = false
    local currentAnimationForKeybind = nil

    -- Function to update animation button visibility based on search text and favorites
    local function updateAnimationButtonsVisibility(searchText)
        local yOffset = 10 -- Start with padding
        local visibleButtonCount = 0

        -- Sort animations: Favorites first, then alphabetically
        local sortedAnimationNames = {}
        local favoriteNames = {}
        local nonFavoriteNames = {}

        for animName in pairs(BuiltInAnimationsR15) do
            if favoriteAnimations[animName] then
                table.insert(favoriteNames, animName)
            else
                table.insert(nonFavoriteNames, animName)
            end
        end
        table.sort(favoriteNames)
        table.sort(nonFavoriteNames)
        for _, name in ipairs(favoriteNames) do
            table.insert(sortedAnimationNames, name)
        end
        for _, name in ipairs(nonFavoriteNames) do
            table.insert(sortedAnimationNames, name)
        end

        for _, animName in ipairs(sortedAnimationNames) do -- Iterate through sorted names
            local animButtonData = animationButtons[animName]
            if not animButtonData then continue end -- Safety check

            if string.find(string.lower(animName), string.lower(searchText)) then
                animButtonData.Container.Visible = true
                animButtonData.Container.Position = UDim2.new(0, 5, 0, yOffset)
                yOffset = yOffset + 70 -- Increased spacing for modern look
                visibleButtonCount = visibleButtonCount + 1

                -- Highlight favorite animations visually
                if favoriteAnimations[animName] then
                    animButtonData.NameButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple for favorites
                    animButtonData.Container.BackgroundColor3 = Color3.fromRGB(45, 35, 55) -- Slightly purple tinted background
                else
                    animButtonData.NameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    animButtonData.Container.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Neutral dark background
                end
                updateKeybindButtonText(animButtonData, animName) -- Update Keybind Button Text
            else
                animButtonData.Container.Visible = false
            end
        end
        animScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, yOffset + 10)) -- Add padding at bottom
    end

    -- Function to refresh the animation list after adding a new animation
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
        
        -- Recreate buttons for all animations (including custom ones)
        for animName, animId in pairs(BuiltInAnimationsR15) do
            -- Create a container for each animation entry
            local animContainer = Instance.new("Frame")
            animContainer.Name = animName .. "Container"
            animContainer.Size = UDim2.new(1, -10, 0, 60) -- Taller container for modern look
            animContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            animContainer.BorderSizePixel = 0
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = animContainer
            animContainer.Parent = animScrollFrame
            
            -- Add subtle shadow effect
            local shadow = Instance.new("ImageLabel")
            shadow.Name = "Shadow"
            shadow.AnchorPoint = Vector2.new(0.5, 0.5)
            shadow.BackgroundTransparency = 1
            shadow.Position = UDim2.new(0.5, 0, 0.5, 2) -- Offset slightly
            shadow.Size = UDim2.new(1, 6, 1, 6)
            shadow.ZIndex = 0
            shadow.Image = "rbxassetid://6014261993" -- Soft shadow image
            shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            shadow.ImageTransparency = 0.7
            shadow.ScaleType = Enum.ScaleType.Slice
            shadow.SliceCenter = Rect.new(49, 49, 450, 450)
            shadow.Parent = animContainer

            local animNameButton = Instance.new("TextButton")
            animNameButton.Name = animName .. "NameButton"
            animNameButton.Size = UDim2.new(1, -140, 0, 30) -- Wider button for title
            animNameButton.Position = UDim2.new(0, 10, 0, 5) -- Positioned inside container
            animNameButton.Text = animName
            animNameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            animNameButton.TextSize = 14
            animNameButton.Font = Enum.Font.GothamSemibold
            animNameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            animNameButton.BorderSizePixel = 0
            animNameButton.TextXAlignment = Enum.TextXAlignment.Center
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = animNameButton
            animNameButton.Parent = animContainer

            -- When clicked, set the animation ID in the textbox of the main GUI
            animNameButton.MouseButton1Click:Connect(function()
                animTextBox.Text = tostring(animId)
            end)

            -- Play Animation Button
            local playAnimButton = Instance.new("TextButton")
            playAnimButton.Name = animName .. "PlayButton"
            playAnimButton.Size = UDim2.new(0.5, -15, 0, 30) -- Half width minus padding
            playAnimButton.Position = UDim2.new(0, 10, 0, 40) -- Below name button
            playAnimButton.Text = "Play"
            playAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playAnimButton.TextSize = 14
            playAnimButton.Font = Enum.Font.GothamMedium
            playAnimButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple
            playAnimButton.BorderSizePixel = 0
            local playButtonCorner = Instance.new("UICorner")
            playButtonCorner.CornerRadius = UDim.new(0, 6)
            playButtonCorner.Parent = playAnimButton
            playAnimButton.Parent = animContainer

            playAnimButton.MouseButton1Click:Connect(function()
                playFakeAnimation(tostring(animId)) -- Call playFakeAnimation with the ID
            end)

            -- Stop Animation Button
            local stopAnimButton = Instance.new("TextButton")
            stopAnimButton.Name = animName .. "StopButton"
            stopAnimButton.Size = UDim2.new(0.5, -15, 0, 30) -- Half width minus padding
            stopAnimButton.Position = UDim2.new(0.5, 5, 0, 40) -- Right of play button
            stopAnimButton.Text = "Stop"
            stopAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            stopAnimButton.TextSize = 14
            stopAnimButton.Font = Enum.Font.GothamMedium
            stopAnimButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
            stopAnimButton.BorderSizePixel = 0
            local stopButtonCorner = Instance.new("UICorner")
            stopButtonCorner.CornerRadius = UDim.new(0, 6)
            stopButtonCorner.Parent = stopAnimButton
            stopAnimButton.Parent = animContainer

            stopAnimButton.MouseButton1Click:Connect(function()
                stopFakeAnimation() -- Call stopFakeAnimation function
            end)

            -- Favorite Animation Button
            local favoriteAnimButton = Instance.new("TextButton")
            favoriteAnimButton.Name = animName .. "FavoriteButton"
            favoriteAnimButton.Size = UDim2.new(0, 36, 0, 36)
            favoriteAnimButton.Position = UDim2.new(1, -130, 0, 12) -- Right side of container
            favoriteAnimButton.Text = favoriteAnimations[animName] and "★" or "☆" -- Filled star if favorite, otherwise empty
            favoriteAnimButton.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
            favoriteAnimButton.TextSize = 24
            favoriteAnimButton.Font = Enum.Font.GothamBold
            favoriteAnimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            favoriteAnimButton.BorderSizePixel = 0
            local favoriteButtonCorner = Instance.new("UICorner")
            favoriteButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
            favoriteButtonCorner.Parent = favoriteAnimButton
            favoriteAnimButton.Parent = animContainer

            favoriteAnimButton.MouseButton1Click:Connect(function()
                if favoriteAnimations[animName] then
                    favoriteAnimations[animName] = nil -- Remove from favorites
                else
                    favoriteAnimations[animName] = true -- Add to favorites
                end
                favoriteAnimButton.Text = favoriteAnimations[animName] and "★" or "☆" -- Update button text
                updateAnimationButtonsVisibility(animSearchTextBox.Text) -- Refresh list to re-sort
                saveFavorites() -- Save favorites after change
            end)

            -- NEW: Keybind Animation Button
            local keybindAnimButton = Instance.new("TextButton")
            keybindAnimButton.Name = animName .. "KeybindButton"
            keybindAnimButton.Size = UDim2.new(0, 36, 0, 36)
            keybindAnimButton.Position = UDim2.new(1, -80, 0, 12) -- Right of favorite button
            keybindAnimButton.Text = "Key" -- Initial text
            keybindAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindAnimButton.TextSize = 12
            keybindAnimButton.Font = Enum.Font.GothamMedium
            keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            keybindAnimButton.BorderSizePixel = 0
            local keybindButtonCorner = Instance.new("UICorner")
            keybindButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
            keybindButtonCorner.Parent = keybindAnimButton
            keybindAnimButton.Parent = animContainer

            keybindAnimButton.MouseButton1Click:Connect(function()
                if keybindInputActive then return end -- Prevent overlapping keybind inputs
                keybindInputActive = true
                currentAnimationForKeybind = animName
                keybindAnimButton.Text = "..." -- Prompt user to press a key
                keybindAnimButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Highlight with purple

                local function inputBeganHandler(input, gameProcessedEvent)
                    if not keybindInputActive or currentAnimationForKeybind ~= animName then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        animationKeybinds[animName] = input.KeyCode
                        saveKeybinds()
                        updateKeybindButtonText(animationButtons[animName], animName)
                        keybindInputActive = false
                        currentAnimationForKeybind = nil
                        keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) -- Reset color
                        UserInputService.InputBegan:Disconnect(inputBeganHandler) -- Disconnect after setting keybind
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        -- Allow canceling keybind setting by clicking away
                        updateKeybindButtonText(animationButtons[animName], animName) -- Revert text
                        keybindInputActive = false
                        currentAnimationForKeybind = nil
                        keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) -- Reset color
                        UserInputService.InputBegan:Disconnect(inputBeganHandler)
                    end
                end

                UserInputService.InputBegan:Connect(inputBeganHandler)
            end)

            -- Add a delete button for custom animations
            if customAnimations[animName] then
                local deleteAnimButton = Instance.new("TextButton")
                deleteAnimButton.Name = animName .. "DeleteButton"
                deleteAnimButton.Size = UDim2.new(0, 36, 0, 36)
                deleteAnimButton.Position = UDim2.new(1, -40, 0, 12) -- Right of keybind button
                deleteAnimButton.Text = "×" -- X symbol
                deleteAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                deleteAnimButton.TextSize = 24
                deleteAnimButton.Font = Enum.Font.GothamBold
                deleteAnimButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
                deleteAnimButton.BorderSizePixel = 0
                local deleteButtonCorner = Instance.new("UICorner")
                deleteButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
                deleteButtonCorner.Parent = deleteAnimButton
                deleteAnimButton.Parent = animContainer
                
                deleteAnimButton.MouseButton1Click:Connect(function()
                    -- Remove from custom animations
                    customAnimations[animName] = nil
                    -- Remove from built-in animations
                    BuiltInAnimationsR15[animName] = nil
                    -- Save changes
                    saveCustomAnimations()
                    -- Refresh the list
                    refreshAnimationList()
                    updateAnimationButtonsVisibility(animSearchTextBox.Text)
                end)
            end

            animationButtons[animName] = {
                Container = animContainer,
                NameButton = animNameButton,
                PlayButton = playAnimButton,
                StopButton = stopAnimButton,
                FavoriteButton = favoriteAnimButton,
                KeybindButton = keybindAnimButton
            }
        end
        
        -- Update visibility based on current search
        updateAnimationButtonsVisibility(animSearchTextBox.Text)
    end

    -- Create buttons for each animation in the BuiltInAnimationsR15 table
    for animName, animId in pairs(BuiltInAnimationsR15) do
        -- Create a container for each animation entry
        local animContainer = Instance.new("Frame")
        animContainer.Name = animName .. "Container"
        animContainer.Size = UDim2.new(1, -10, 0, 60) -- Taller container for modern look
        animContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        animContainer.BorderSizePixel = 0
        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 8)
        containerCorner.Parent = animContainer
        animContainer.Parent = animScrollFrame
        
        -- Add subtle shadow effect
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0.5, 0, 0.5, 2) -- Offset slightly
        shadow.Size = UDim2.new(1, 6, 1, 6)
        shadow.ZIndex = 0
        shadow.Image = "rbxassetid://6014261993" -- Soft shadow image
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.7
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        shadow.Parent = animContainer

        local animNameButton = Instance.new("TextButton")
        animNameButton.Name = animName .. "NameButton"
        animNameButton.Size = UDim2.new(1, -140, 0, 30) -- Wider button for title
        animNameButton.Position = UDim2.new(0, 10, 0, 5) -- Positioned inside container
        animNameButton.Text = animName
        animNameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        animNameButton.TextSize = 14
        animNameButton.Font = Enum.Font.GothamSemibold
        animNameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        animNameButton.BorderSizePixel = 0
        animNameButton.TextXAlignment = Enum.TextXAlignment.Center
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = animNameButton
        animNameButton.Parent = animContainer

        -- When clicked, set the animation ID in the textbox of the main GUI
        animNameButton.MouseButton1Click:Connect(function()
            animTextBox.Text = tostring(animId)
        end)

        -- Play Animation Button
        local playAnimButton = Instance.new("TextButton")
        playAnimButton.Name = animName .. "PlayButton"
        playAnimButton.Size = UDim2.new(0.5, -15, 0, 30) -- Half width minus padding
        playAnimButton.Position = UDim2.new(0, 10, 0, 40) -- Below name button
        playAnimButton.Text = "Play"
        playAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        playAnimButton.TextSize = 14
        playAnimButton.Font = Enum.Font.GothamMedium
        playAnimButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple
        playAnimButton.BorderSizePixel = 0
        local playButtonCorner = Instance.new("UICorner")
        playButtonCorner.CornerRadius = UDim.new(0, 6)
        playButtonCorner.Parent = playAnimButton
        playAnimButton.Parent = animContainer

        playAnimButton.MouseButton1Click:Connect(function()
            playFakeAnimation(tostring(animId)) -- Call playFakeAnimation with the ID
        end)

        -- Stop Animation Button
        local stopAnimButton = Instance.new("TextButton")
        stopAnimButton.Name = animName .. "StopButton"
        stopAnimButton.Size = UDim2.new(0.5, -15, 0, 30) -- Half width minus padding
        stopAnimButton.Position = UDim2.new(0.5, 5, 0, 40) -- Right of play button
        stopAnimButton.Text = "Stop"
        stopAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopAnimButton.TextSize = 14
        stopAnimButton.Font = Enum.Font.GothamMedium
        stopAnimButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
        stopAnimButton.BorderSizePixel = 0
        local stopButtonCorner = Instance.new("UICorner")
        stopButtonCorner.CornerRadius = UDim.new(0, 6)
        stopButtonCorner.Parent = stopAnimButton
        stopAnimButton.Parent = animContainer

        stopAnimButton.MouseButton1Click:Connect(function()
            stopFakeAnimation() -- Call stopFakeAnimation function
        end)

        -- Favorite Animation Button
        local favoriteAnimButton = Instance.new("TextButton")
        favoriteAnimButton.Name = animName .. "FavoriteButton"
        favoriteAnimButton.Size = UDim2.new(0, 36, 0, 36)
        favoriteAnimButton.Position = UDim2.new(1, -130, 0, 12) -- Right side of container
        favoriteAnimButton.Text = favoriteAnimations[animName] and "★" or "☆" -- Filled star if favorite, otherwise empty
        favoriteAnimButton.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
        favoriteAnimButton.TextSize = 24
        favoriteAnimButton.Font = Enum.Font.GothamBold
        favoriteAnimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        favoriteAnimButton.BorderSizePixel = 0
        local favoriteButtonCorner = Instance.new("UICorner")
        favoriteButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
        favoriteButtonCorner.Parent = favoriteAnimButton
        favoriteAnimButton.Parent = animContainer

        favoriteAnimButton.MouseButton1Click:Connect(function()
            if favoriteAnimations[animName] then
                favoriteAnimations[animName] = nil -- Remove from favorites
            else
                favoriteAnimations[animName] = true -- Add to favorites
            end
            favoriteAnimButton.Text = favoriteAnimations[animName] and "★" or "☆" -- Update button text
            updateAnimationButtonsVisibility(animSearchTextBox.Text) -- Refresh list to re-sort
            saveFavorites() -- Save favorites after change
        end)

        -- NEW: Keybind Animation Button
        local keybindAnimButton = Instance.new("TextButton")
        keybindAnimButton.Name = animName .. "KeybindButton"
        keybindAnimButton.Size = UDim2.new(0, 36, 0, 36)
        keybindAnimButton.Position = UDim2.new(1, -80, 0, 12) -- Right of favorite button
        keybindAnimButton.Text = "Key" -- Initial text
        keybindAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        keybindAnimButton.TextSize = 12
        keybindAnimButton.Font = Enum.Font.GothamMedium
        keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        keybindAnimButton.BorderSizePixel = 0
        local keybindButtonCorner = Instance.new("UICorner")
        keybindButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
        keybindButtonCorner.Parent = keybindAnimButton
        keybindAnimButton.Parent = animContainer

        keybindAnimButton.MouseButton1Click:Connect(function()
            if keybindInputActive then return end -- Prevent overlapping keybind inputs
            keybindInputActive = true
            currentAnimationForKeybind = animName
            keybindAnimButton.Text = "..." -- Prompt user to press a key
            keybindAnimButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Highlight with purple

            local function inputBeganHandler(input, gameProcessedEvent)
                if not keybindInputActive or currentAnimationForKeybind ~= animName then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    animationKeybinds[animName] = input.KeyCode
                    saveKeybinds()
                    updateKeybindButtonText(animationButtons[animName], animName)
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) -- Reset color
                    UserInputService.InputBegan:Disconnect(inputBeganHandler) -- Disconnect after setting keybind
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    -- Allow canceling keybind setting by clicking away
                    updateKeybindButtonText(animationButtons[animName], animName) -- Revert text
                    keybindInputActive = false
                    currentAnimationForKeybind = nil
                    keybindAnimButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80) -- Reset color
                    UserInputService.InputBegan:Disconnect(inputBeganHandler)
                end
            end

            UserInputService.InputBegan:Connect(inputBeganHandler)
        end)

        -- Add a delete button for custom animations
        if customAnimations[animName] then
            local deleteAnimButton = Instance.new("TextButton")
            deleteAnimButton.Name = animName .. "DeleteButton"
            deleteAnimButton.Size = UDim2.new(0, 36, 0, 36)
            deleteAnimButton.Position = UDim2.new(1, -40, 0, 12) -- Right of keybind button
            deleteAnimButton.Text = "×" -- X symbol
            deleteAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            deleteAnimButton.TextSize = 24
            deleteAnimButton.Font = Enum.Font.GothamBold
            deleteAnimButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
            deleteAnimButton.BorderSizePixel = 0
            local deleteButtonCorner = Instance.new("UICorner")
            deleteButtonCorner.CornerRadius = UDim.new(1, 0) -- Circle
            deleteButtonCorner.Parent = deleteAnimButton
            deleteAnimButton.Parent = animContainer
            
            deleteAnimButton.MouseButton1Click:Connect(function()
                -- Remove from custom animations
                customAnimations[animName] = nil
                -- Remove from built-in animations
                BuiltInAnimationsR15[animName] = nil
                -- Save changes
                saveCustomAnimations()
                -- Refresh the list
                refreshAnimationList()
                updateAnimationButtonsVisibility(animSearchTextBox.Text)
            end)
        end

        animationButtons[animName] = {
            Container = animContainer,
            NameButton = animNameButton,
            PlayButton = playAnimButton,
            StopButton = stopAnimButton,
            FavoriteButton = favoriteAnimButton,
            KeybindButton = keybindAnimButton
        }
    end

    -- Initially update button visibility to show all animations
    updateAnimationButtonsVisibility("")

    -- Update button visibility when search text changes
    animSearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateAnimationButtonsVisibility(animSearchTextBox.Text)
    end)

    -- Button click handlers for the Add Animation popup
    addAnimButton.MouseButton1Click:Connect(function()
        nameInput.Text = ""
        idInput.Text = ""
        addAnimPopup.Visible = true
    end)
    
    saveButton.MouseButton1Click:Connect(function()
        local animName = nameInput.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        local animId = idInput.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
        
        -- Validate inputs
        if animName == "" then
            -- Flash the name input red to indicate error
            local originalColor = nameInput.BackgroundColor3
            nameInput.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            task.delay(0.3, function()
                nameInput.BackgroundColor3 = originalColor
            end)
            return
        end
        
        if animId == "" or not tonumber(animId) then
            -- Flash the ID input red to indicate error
            local originalColor = idInput.BackgroundColor3
            idInput.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            task.delay(0.3, function()
                idInput.BackgroundColor3 = originalColor
            end)
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
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        addAnimPopup.Visible = false
    end)

    -- Drag functionality for the Animation List GUI
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

local animationListGui = nil -- Variable to track if animation list is open

-- Creates a modern, sleek draggable GUI
local function createDraggableGui(getGhostEnabled, toggleGhost, getSizeValue, setSizeValue, getWidthValue, setWidthValue)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PoisonHubGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 360, 0, 480)  -- Slightly larger for modern look
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Darker background
    mainFrame.BorderSizePixel = 0
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    -- Add a subtle gradient to the main frame
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    mainFrame.Parent = screenGui

    -- Add a subtle shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4) -- Offset slightly
    shadow.Size = UDim2.new(1, 12, 1, 12)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://6014261993" -- Soft shadow image
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50) -- Taller title bar
    titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    titleBar.BorderSizePixel = 0
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    -- Add a subtle gradient to the title bar
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 63, 246))
    })
    titleGradient.Rotation = 45
    titleGradient.Parent = titleBar
    
    titleBar.Parent = mainFrame

    -- Create a bottom edge for the title bar to fix corner clipping
    local titleBarBottom = Instance.new("Frame")
    titleBarBottom.Name = "BottomEdge"
    titleBarBottom.Size = UDim2.new(1, 0, 0, 12)
    titleBarBottom.Position = UDim2.new(0, 0, 1, -12)
    titleBarBottom.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleBarBottom.BorderSizePixel = 0
    titleBarBottom.ZIndex = 0
    titleGradient:Clone().Parent = titleBarBottom
    titleBarBottom.Parent = titleBar

    -- Modern logo
    local logoContainer = Instance.new("Frame")
    logoContainer.Name = "LogoContainer"
    logoContainer.Size = UDim2.new(0, 36, 0, 36)
    logoContainer.Position = UDim2.new(0, 12, 0, 7)
    logoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    logoContainer.BackgroundTransparency = 0.9
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(1, 0) -- Circle
    logoCorner.Parent = logoContainer
    logoContainer.Parent = titleBar

    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Position = UDim2.new(0.5, -12, 0.5, -12)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://6022668885" -- You can replace with a custom logo
    logo.Parent = logoContainer

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 0, 30)
    titleLabel.Position = UDim2.new(0, 60, 0, 5)
    titleLabel.Text = "Poison Hub"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Credit Label
    local creditLabel = Instance.new("TextLabel")
    creditLabel.Name = "CreditLabel"
    creditLabel.Size = UDim2.new(1, -120, 0, 20)
    creditLabel.Position = UDim2.new(0, 60, 0, 30)
    creditLabel.Text = "Reanimation script by AK ADMIN"
    creditLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    creditLabel.TextSize = 12
    creditLabel.Font = Enum.Font.Gotham
    creditLabel.BackgroundTransparency = 1
    creditLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditLabel.Parent = titleBar

    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 36, 0, 36)
    minimizeButton.Position = UDim2.new(1, -80, 0, 7)
    minimizeButton.Text = "−" -- Minus symbol
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 24
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.BackgroundTransparency = 0.9
    minimizeButton.AutoButtonColor = true
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(1, 0) -- Circle
    minimizeCorner.Parent = minimizeButton
    minimizeButton.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 36, 0, 36)
    closeButton.Position = UDim2.new(1, -44, 0, 7)
    closeButton.Text = "×" -- Multiplication symbol for a cleaner look
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BackgroundTransparency = 0.3
    closeButton.AutoButtonColor = true
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0) -- Circle
    closeCorner.Parent = closeButton
    closeButton.Parent = titleBar

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -40, 1, -70)
    contentFrame.Position = UDim2.new(0, 20, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Modern toggle button with animation
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(1, 0, 0, 50)
    toggleContainer.Position = UDim2.new(0, 0, 0, 0)
    toggleContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleContainer.BorderSizePixel = 0
    local toggleContainerCorner = Instance.new("UICorner")
    toggleContainerCorner.CornerRadius = UDim.new(0, 10)
    toggleContainerCorner.Parent = toggleContainer
    toggleContainer.Parent = contentFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, -20, 1, -20)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Text = "Enable Reanimation"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 16
    toggleButton.Font = Enum.Font.GothamSemibold
    toggleButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = true
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton
    toggleButton.Parent = toggleContainer

    -- Add a subtle shadow to the toggle button
    local toggleShadow = Instance.new("ImageLabel")
    toggleShadow.Name = "Shadow"
    toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleShadow.BackgroundTransparency = 1
    toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    toggleShadow.Size = UDim2.new(1, 6, 1, 6)
    toggleShadow.ZIndex = 0
    toggleShadow.Image = "rbxassetid://6014261993"
    toggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    toggleShadow.ImageTransparency = 0.7
    toggleShadow.ScaleType = Enum.ScaleType.Slice
    toggleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    toggleShadow.Parent = toggleButton

    -- Size Slider Section with modern styling
    local sizeSection = Instance.new("Frame")
    sizeSection.Name = "SizeSection"
    sizeSection.Size = UDim2.new(1, 0, 0, 60)
    sizeSection.Position = UDim2.new(0, 0, 0, 60)
    sizeSection.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sizeSection.BorderSizePixel = 0
    local sizeSectionCorner = Instance.new("UICorner")
    sizeSectionCorner.CornerRadius = UDim.new(0, 10)
    sizeSectionCorner.Parent = sizeSection
    sizeSection.Parent = contentFrame

    local sizeLabel = Instance.new("TextLabel")
    sizeLabel.Name = "SizeLabel"
    sizeLabel.Size = UDim2.new(1, -20, 0, 24)
    sizeLabel.Position = UDim2.new(0, 15, 0, 8)
    sizeLabel.Text = "Clone Size: 100%"
    sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeLabel.TextSize = 14
    sizeLabel.Font = Enum.Font.GothamSemibold
    sizeLabel.BackgroundTransparency = 1
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    sizeLabel.Parent = sizeSection

    local sizeSliderBG = Instance.new("Frame")
    sizeSliderBG.Name = "SliderBG"
    sizeSliderBG.Size = UDim2.new(1, -30, 0, 8)
    sizeSliderBG.Position = UDim2.new(0, 15, 0, 38)
    sizeSliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    sizeSliderBG.BorderSizePixel = 0
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(0, 4)
    sliderBGCorner.Parent = sizeSliderBG
    sizeSliderBG.Parent = sizeSection

    local sizeSliderFill = Instance.new("Frame")
    sizeSliderFill.Name = "SliderFill"
    sizeSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sizeSliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    sizeSliderFill.BorderSizePixel = 0
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 4)
    sliderFillCorner.Parent = sizeSliderFill
    sizeSliderFill.Parent = sizeSliderBG

    -- Add a slider knob
    local sizeSliderKnob = Instance.new("Frame")
    sizeSliderKnob.Name = "SliderKnob"
    sizeSliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sizeSliderKnob.Position = UDim2.new(0.5, -8, 0.5, -8)
    sizeSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sizeSliderKnob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0) -- Circle
    knobCorner.Parent = sizeSliderKnob
    
    -- Add a subtle shadow to the knob
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Name = "Shadow"
    knobShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Position = UDim2.new(0.5, 0, 0.5, 1)
    knobShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
    knobShadow.ZIndex = 0
    knobShadow.Image = "rbxassetid://6014261993"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    knobShadow.Parent = sizeSliderKnob
    
    sizeSliderKnob.Parent = sizeSliderFill

    local function updateSizeSlider(value)
        local fillValue = 0
        if value <= 0.5 then
            fillValue = 0
        elseif value >= 20 then
            fillValue = 1
        else
            fillValue = (value - 0.5) / 19.5
        end
        sizeSliderFill.Size = UDim2.new(fillValue, 0, 1, 0)
        sizeLabel.Text = "Clone Size: " .. math.floor(value * 100) .. "%"
        setSizeValue(value)
    end

    updateSizeSlider(getSizeValue())

    local isDraggingSize = false
    local function updateSizeFromPosition(input)
        local sliderPosition = (input.Position.X - sizeSliderBG.AbsolutePosition.X) / sizeSliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newValue = 0.5 + sliderPosition * 19.5
        updateSizeSlider(newValue)
    end

    sizeSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSize = true
            updateSizeFromPosition(input)
        end
    end)
    sizeSliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSize = false
        end
    end)
    sizeSliderBG.InputChanged:Connect(function(input)
        if isDraggingSize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSizeFromPosition(input)
        end
    end)

    -- Width Slider Section with modern styling
    local widthSection = Instance.new("Frame")
    widthSection.Name = "WidthSection"
    widthSection.Size = UDim2.new(1, 0, 0, 60)
    widthSection.Position = UDim2.new(0, 0, 0, 130)
    widthSection.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    widthSection.BorderSizePixel = 0
    local widthSectionCorner = Instance.new("UICorner")
    widthSectionCorner.CornerRadius = UDim.new(0, 10)
    widthSectionCorner.Parent = widthSection
    widthSection.Parent = contentFrame

    local widthLabel = Instance.new("TextLabel")
    widthLabel.Name = "WidthLabel"
    widthLabel.Size = UDim2.new(1, -20, 0, 24)
    widthLabel.Position = UDim2.new(0, 15, 0, 8)
    widthLabel.Text = "Clone Width: 100%"
    widthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    widthLabel.TextSize = 14
    widthLabel.Font = Enum.Font.GothamSemibold
    widthLabel.BackgroundTransparency = 1
    widthLabel.TextXAlignment = Enum.TextXAlignment.Left
    widthLabel.Parent = widthSection

    local widthSliderBG = Instance.new("Frame")
    widthSliderBG.Name = "WidthSliderBG"
    widthSliderBG.Size = UDim2.new(1, -30, 0, 8)
    widthSliderBG.Position = UDim2.new(0, 15, 0, 38)
    widthSliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    widthSliderBG.BorderSizePixel = 0
    local widthSliderBGCorner = Instance.new("UICorner")
    widthSliderBGCorner.CornerRadius = UDim.new(0, 4)
    widthSliderBGCorner.Parent = widthSliderBG
    widthSliderBG.Parent = widthSection

    local widthSliderFill = Instance.new("Frame")
    widthSliderFill.Name = "SliderFill"
    widthSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    widthSliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    widthSliderFill.BorderSizePixel = 0
    local widthSliderFillCorner = Instance.new("UICorner")
    widthSliderFillCorner.CornerRadius = UDim.new(0, 4)
    widthSliderFillCorner.Parent = widthSliderFill
    widthSliderFill.Parent = widthSliderBG

    -- Add a slider knob
    local widthSliderKnob = Instance.new("Frame")
    widthSliderKnob.Name = "SliderKnob"
    widthSliderKnob.Size = UDim2.new(0, 16, 0, 16)
    widthSliderKnob.Position = UDim2.new(0.5, -8, 0.5, -8)
    widthSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    widthSliderKnob.BorderSizePixel = 0
    local widthKnobCorner = Instance.new("UICorner")
    widthKnobCorner.CornerRadius = UDim.new(1, 0) -- Circle
    widthKnobCorner.Parent = widthSliderKnob
    
    -- Add a subtle shadow to the knob
    local widthKnobShadow = knobShadow:Clone()
    widthKnobShadow.Parent = widthSliderKnob
    
    widthSliderKnob.Parent = widthSliderFill

    local function updateWidthSlider(value)
        local fillValue = 0
        if value <= 0.5 then
            fillValue = 0
        elseif value >= 20 then
            fillValue = 1
        else
            fillValue = (value - 0.5) / 19.5
        end
        widthSliderFill.Size = UDim2.new(fillValue, 0, 1, 0)
        widthLabel.Text = "Clone Width: " .. math.floor(value * 100) .. "%"
        setWidthValue(value)
    end

    updateWidthSlider(getWidthValue())

    local isDraggingWidth = false
    local function updateWidthFromPosition(input)
        local sliderPosition = (input.Position.X - widthSliderBG.AbsolutePosition.X) / widthSliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newValue = 0.5 + sliderPosition * 19.5
        updateWidthSlider(newValue)
    end

    widthSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidth = true
            updateWidthFromPosition(input)
        end
    end)
    widthSliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingWidth = false
        end
    end)
    widthSliderBG.InputChanged:Connect(function(input)
        if isDraggingWidth and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateWidthFromPosition(input)
        end
    end)

    -- Animation Speed Slider Section with modern styling
    local speedSection = Instance.new("Frame")
    speedSection.Name = "SpeedSection"
    speedSection.Size = UDim2.new(1, 0, 0, 60)
    speedSection.Position = UDim2.new(0, 0, 0, 200)
    speedSection.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    speedSection.BorderSizePixel = 0
    local speedSectionCorner = Instance.new("UICorner")
    speedSectionCorner.CornerRadius = UDim.new(0, 10)
    speedSectionCorner.Parent = speedSection
    speedSection.Parent = contentFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, -20, 0, 24)
    speedLabel.Position = UDim2.new(0, 15, 0, 8)
    speedLabel.Text = "Animation Speed: 100%"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamSemibold
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedSection

    local speedSliderBG = Instance.new("Frame")
    speedSliderBG.Name = "SpeedSliderBG"
    speedSliderBG.Size = UDim2.new(1, -30, 0, 8)
    speedSliderBG.Position = UDim2.new(0, 15, 0, 38)
    speedSliderBG.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    speedSliderBG.BorderSizePixel = 0
    local speedSliderBGCorner = Instance.new("UICorner")
    speedSliderBGCorner.CornerRadius = UDim.new(0, 4)
    speedSliderBGCorner.Parent = speedSliderBG
    speedSliderBG.Parent = speedSection

    local speedSliderFill = Instance.new("Frame")
    speedSliderFill.Name = "SpeedSliderFill"
    speedSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    speedSliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    speedSliderFill.BorderSizePixel = 0
    local speedSliderFillCorner = Instance.new("UICorner")
    speedSliderFillCorner.CornerRadius = UDim.new(0, 4)
    speedSliderFillCorner.Parent = speedSliderFill
    speedSliderFill.Parent = speedSliderBG

    -- Add a slider knob
    local speedSliderKnob = Instance.new("Frame")
    speedSliderKnob.Name = "SliderKnob"
    speedSliderKnob.Size = UDim2.new(0, 16, 0, 16)
    speedSliderKnob.Position = UDim2.new(0.5, -8, 0.5, -8)
    speedSliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    speedSliderKnob.BorderSizePixel = 0
    local speedKnobCorner = Instance.new("UICorner")
    speedKnobCorner.CornerRadius = UDim.new(1, 0) -- Circle
    speedKnobCorner.Parent = speedSliderKnob
    
    -- Add a subtle shadow to the knob
    local speedKnobShadow = knobShadow:Clone()
    speedKnobShadow.Parent = speedSliderKnob
    
    speedSliderKnob.Parent = speedSliderFill

    local function updateSpeedSlider(value)
        local fillValue = 0
        if value <= 0 then -- Min speed 0%
            fillValue = 0
        elseif value >= 3.6 then -- Max speed 360%
            fillValue = 1
        else
            fillValue = (value) / (3.6)
        end
        speedSliderFill.Size = UDim2.new(fillValue, 0, 1, 0)
        speedLabel.Text = "Animation Speed: " .. math.floor(value * 100) .. "%"
        fakeAnimSpeed = value -- Update global animation speed variable, 100% on slider is original speed
    end

    updateSpeedSlider(1.7) -- Initialize slider to 170% which will be original speed

    local isDraggingSpeed = false
    local function updateSpeedFromPosition(input)
        local sliderPosition = (input.Position.X - speedSliderBG.AbsolutePosition.X) / speedSliderBG.AbsoluteSize.X
        sliderPosition = math.clamp(sliderPosition, 0, 1)
        local newValue = sliderPosition * 3.6 -- Slider range 0 to 3.6 (0% to 360%)
        updateSpeedSlider(newValue)
    end

    speedSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = true
            updateSpeedFromPosition(input)
        end
    end)
    speedSliderBG.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSpeed = false
        end
    end)
    speedSliderBG.InputChanged:Connect(function(input)
        if isDraggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSpeedFromPosition(input)
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Minimize Logic ---
    local originalGuiHeight = mainFrame.Size.Y.Offset -- Store initial height
    local minimizedGuiHeight = titleBar.Size.Y.Offset + 10 -- Height when minimized
    local minimized = false -- Track minimized state

    minimizeButton.MouseButton1Click:Connect(function() -- Minimize button functionality
        minimized = not minimized
        if minimized then
            contentFrame.Visible = false -- Hide content
            mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, minimizedGuiHeight) -- Resize to minimized height
        else
            contentFrame.Visible = true -- Show content
            mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, originalGuiHeight) -- Restore original height
        end
    end)
    -- End Minimize Logic ---

    toggleButton.MouseButton1Click:Connect(function()
        local newState = not getGhostEnabled()
        toggleGhost(newState)
        if newState then
            toggleButton.Text = "Disable Reanimation"
            toggleButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red for active
            updateSizeSlider(getSizeValue())
            updateWidthSlider(getWidthValue())
        else
            toggleButton.Text = "Enable Reanimation"
            toggleButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
        end
    end)

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

    -- EXTRA SECTION: Animation Input & Buttons with modern styling
    local fakeAnimSection = Instance.new("Frame")
    fakeAnimSection.Name = "FakeAnimSection"
    fakeAnimSection.Size = UDim2.new(1, 0, 0, 120)
    fakeAnimSection.Position = UDim2.new(0, 0, 0, 270)
    fakeAnimSection.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    fakeAnimSection.BorderSizePixel = 0
    local fakeAnimSectionCorner = Instance.new("UICorner")
    fakeAnimSectionCorner.CornerRadius = UDim.new(0, 10)
    fakeAnimSectionCorner.Parent = fakeAnimSection
    fakeAnimSection.Parent = contentFrame

    local animLabel = Instance.new("TextLabel")
    animLabel.Name = "AnimLabel"
    animLabel.Size = UDim2.new(1, -20, 0, 24)
    animLabel.Position = UDim2.new(0, 15, 0, 8)
    animLabel.Text = "Animation ID"
    animLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    animLabel.TextSize = 14
    animLabel.Font = Enum.Font.GothamSemibold
    animLabel.BackgroundTransparency = 1
    animLabel.TextXAlignment = Enum.TextXAlignment.Left
    animLabel.Parent = fakeAnimSection

    local fakeAnimTextBox = Instance.new("TextBox")
    fakeAnimTextBox.Name = "FakeAnimTextBox"
    fakeAnimTextBox.Text = ""
    fakeAnimTextBox.Size = UDim2.new(1, -30, 0, 36)
    fakeAnimTextBox.Position = UDim2.new(0, 15, 0, 32)
    fakeAnimTextBox.PlaceholderText = "Enter Animation ID"
    fakeAnimTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    fakeAnimTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    fakeAnimTextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    fakeAnimTextBox.ClearTextOnFocus = false
    fakeAnimTextBox.Font = Enum.Font.Gotham
    fakeAnimTextBox.TextSize = 14
    local fakeAnimTextBoxCorner = Instance.new("UICorner")
    fakeAnimTextBoxCorner.CornerRadius = UDim.new(0, 8)
    fakeAnimTextBoxCorner.Parent = fakeAnimTextBox
    fakeAnimTextBox.Parent = fakeAnimSection

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -30, 0, 36)
    buttonContainer.Position = UDim2.new(0, 15, 0, 74)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = fakeAnimSection

    local fakeAnimButton = Instance.new("TextButton")
    fakeAnimButton.Name = "FakeAnimButton"
    fakeAnimButton.Size = UDim2.new(0.5, -5, 1, 0)
    fakeAnimButton.Position = UDim2.new(0, 0, 0, 0)
    fakeAnimButton.Text = "Play Animation"
    fakeAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fakeAnimButton.TextSize = 14
    fakeAnimButton.Font = Enum.Font.GothamSemibold
    fakeAnimButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple
    fakeAnimButton.BorderSizePixel = 0
    local fakeAnimButtonCorner = Instance.new("UICorner")
    fakeAnimButtonCorner.CornerRadius = UDim.new(0, 8)
    fakeAnimButtonCorner.Parent = fakeAnimButton
    fakeAnimButton.Parent = buttonContainer

    local stopFakeAnimButton = Instance.new("TextButton")
    stopFakeAnimButton.Name = "StopFakeAnimButton"
    stopFakeAnimButton.Size = UDim2.new(0.5, -5, 1, 0)
    stopFakeAnimButton.Position = UDim2.new(0.5, 5, 0, 0)
    stopFakeAnimButton.Text = "Stop Animation"
    stopFakeAnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopFakeAnimButton.TextSize = 14
    stopFakeAnimButton.Font = Enum.Font.GothamSemibold
    stopFakeAnimButton.BackgroundColor3 = Color3.fromRGB(211, 47, 47) -- Red
    stopFakeAnimButton.BorderSizePixel = 0
    local stopFakeAnimButtonCorner = Instance.new("UICorner")
    stopFakeAnimButtonCorner.CornerRadius = UDim.new(0, 8)
    stopFakeAnimButtonCorner.Parent = stopFakeAnimButton
    stopFakeAnimButton.Parent = buttonContainer

    -- Add button shadows
    local playButtonShadow = toggleShadow:Clone()
    playButtonShadow.Parent = fakeAnimButton
    
    local stopButtonShadow = toggleShadow:Clone()
    stopButtonShadow.Parent = stopFakeAnimButton

    fakeAnimButton.MouseButton1Click:Connect(function()
        if ghostClone then
            local animId = fakeAnimTextBox.Text
            playFakeAnimation(animId)
        else
            warn("No fake character available!")
        end
    end)

    stopFakeAnimButton.MouseButton1Click:Connect(function()
        stopFakeAnimation()
    end)

    -- Animation List Button Section
    local animListSection = Instance.new("Frame")
    animListSection.Name = "AnimListSection"
    animListSection.Size = UDim2.new(1, 0, 0, 50)
    animListSection.Position = UDim2.new(0, 0, 1, -50)
    animListSection.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    animListSection.BorderSizePixel = 0
    local animListSectionCorner = Instance.new("UICorner")
    animListSectionCorner.CornerRadius = UDim.new(0, 10)
    animListSectionCorner.Parent = animListSection
    animListSection.Parent = contentFrame

    local animListButton = Instance.new("TextButton")
    animListButton.Name = "AnimListButton"
    animListButton.Size = UDim2.new(1, -30, 1, -20)
    animListButton.Position = UDim2.new(0, 15, 0, 10)
    animListButton.Text = "Open Animation List"
    animListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    animListButton.TextSize = 16
    animListButton.Font = Enum.Font.GothamSemibold
    animListButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple color for Poison Hub
    animListButton.BorderSizePixel = 0
    animListButton.AutoButtonColor = true
    local animListCorner = Instance.new("UICorner")
    animListCorner.CornerRadius = UDim.new(0, 8)
    animListCorner.Parent = animListButton
    
    -- Add button shadow
    local animListButtonShadow = toggleShadow:Clone()
    animListButtonShadow.Parent = animListButton
    
    animListButton.Parent = animListSection

    animListButton.MouseButton1Click:Connect(function()
        if animationListGui then
            animationListGui:Destroy()
            animationListGui = nil
            animListButton.Text = "Open Animation List"
        else
            animationListGui = createAnimationListGui(fakeAnimTextBox)
            animListButton.Text = "Close Animation List"
        end
    end)

    return screenGui
end

local gui = createDraggableGui(
    function() return ghostEnabled end,
    setGhostEnabled,
    function() return cloneSize end,
    function(size)
        cloneSize = size
        if ghostEnabled and ghostClone then
            updateCloneScale()
        end
    end,
    function() return cloneWidth end,
    function(width)
        cloneWidth = width
        if ghostEnabled and ghostClone then
            updateCloneScale()
        end
    end
)
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- NEW: Keybind Handling outside GUI with toggle functionality
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
                    playFakeAnimation(BuiltInAnimationsR15[animName])
                end
                return -- Stop checking after finding a match
            end
        end
    end
end)
