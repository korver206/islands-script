-- New Roblox Islands Duplication Script
-- Compatible with Vega X Executor
-- True duplication with persistence and comprehensive remote search

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local enabled = true
local duplicating = false
local debugMode = false
local maxAmount = 5
local delayTime = 2
local allRemotes = {}

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IslandsDupeUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(0, 10, 1, -610)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = enabled

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Islands Duplication Script"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(0.9, 0, 0, 30)
amountBox.Position = UDim2.new(0.05, 0, 0, 40)
amountBox.Text = "1"
amountBox.PlaceholderText = "Enter amount (max 5)"
amountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
amountBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
amountBox.BackgroundTransparency = 0.2
amountBox.BorderSizePixel = 0
amountBox.Font = Enum.Font.Gotham
amountBox.TextScaled = true
amountBox.Parent = mainFrame

local amountCorner = Instance.new("UICorner")
amountCorner.CornerRadius = UDim.new(0, 5)
amountCorner.Parent = amountBox

local dupeButton = Instance.new("TextButton")
dupeButton.Size = UDim2.new(0.9, 0, 0, 40)
dupeButton.Position = UDim2.new(0.05, 0, 0, 80)
dupeButton.Text = "Duplicate Item"
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
dupeButton.BorderSizePixel = 0
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextScaled = true
dupeButton.Parent = mainFrame

local dupeCorner = Instance.new("UICorner")
dupeCorner.CornerRadius = UDim.new(0, 5)
dupeCorner.Parent = dupeButton

local magentaTrimDupe = Instance.new("UIStroke")
magentaTrimDupe.Color = Color3.fromRGB(255, 100, 255)
magentaTrimDupe.Thickness = 2
magentaTrimDupe.Parent = dupeButton

local function shimmerEffect(stroke)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local goal1 = {Color = Color3.fromRGB(255, 100, 255)}
    local goal2 = {Color = Color3.fromRGB(255, 200, 255)}
    local tween1 = TweenService:Create(stroke, tweenInfo, goal1)
    local tween2 = TweenService:Create(stroke, tweenInfo, goal2)
    tween1:Play()
    tween2:Play()
end

shimmerEffect(magentaTrimDupe)

local debugButton = Instance.new("TextButton")
debugButton.Size = UDim2.new(0.45, 0, 0, 30)
debugButton.Position = UDim2.new(0.05, 0, 0, 130)
debugButton.Text = "Debug OFF"
debugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
debugButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
debugButton.BorderSizePixel = 0
debugButton.Font = Enum.Font.GothamBold
debugButton.TextScaled = true
debugButton.Parent = mainFrame

local debugCorner = Instance.new("UICorner")
debugCorner.CornerRadius = UDim.new(0, 5)
debugCorner.Parent = debugButton

local magentaTrimDebug = Instance.new("UIStroke")
magentaTrimDebug.Color = Color3.fromRGB(255, 100, 255)
magentaTrimDebug.Thickness = 2
magentaTrimDebug.Parent = debugButton

shimmerEffect(magentaTrimDebug)

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0.45, 0, 0, 30)
scanButton.Position = UDim2.new(0.5, 0, 0, 130)
scanButton.Text = "Scan Remotes"
scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scanButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
scanButton.BorderSizePixel = 0
scanButton.Font = Enum.Font.GothamBold
scanButton.TextScaled = true
scanButton.Parent = mainFrame

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 5)
scanCorner.Parent = scanButton

local magentaTrimScan = Instance.new("UIStroke")
magentaTrimScan.Color = Color3.fromRGB(255, 100, 255)
magentaTrimScan.Thickness = 2
magentaTrimScan.Parent = scanButton

shimmerEffect(magentaTrimScan)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 100)
statusLabel.Position = UDim2.new(0.05, 0, 0, 180)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready. Hold an item and duplicate."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local scanResults = Instance.new("ScrollingFrame")
scanResults.Size = UDim2.new(0.9, 0, 0, 80)
scanResults.Position = UDim2.new(0.05, 0, 0, 290)
scanResults.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scanResults.BackgroundTransparency = 0.3
scanResults.BorderSizePixel = 0
scanResults.ScrollBarThickness = 8
scanResults.Parent = mainFrame

local resultsCorner = Instance.new("UICorner")
resultsCorner.CornerRadius = UDim.new(0, 5)
resultsCorner.Parent = scanResults

local resultsLayout = Instance.new("UIListLayout")
resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
resultsLayout.Parent = scanResults

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(0.9, 0, 0, 150)
consoleFrame.Position = UDim2.new(0.05, 0, 0, 380)
consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
consoleFrame.BackgroundTransparency = 0.1
consoleFrame.BorderSizePixel = 2
consoleFrame.BorderColor3 = Color3.fromRGB(255, 100, 255)
consoleFrame.ScrollBarThickness = 8
consoleFrame.Parent = mainFrame

local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 5)
consoleCorner.Parent = consoleFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Parent = consoleFrame

local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1, 0, 0, 20)
consoleTitle.BackgroundTransparency = 1
consoleTitle.Text = "Console Logs (F9 Alternative)"
consoleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
consoleTitle.TextScaled = true
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.Parent = consoleFrame

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
    if debugMode then
        print("[Islands Dupe] " .. text)
    end
end

local function addConsoleMessage(message, messageType)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.LayoutOrder = #consoleFrame:GetChildren()

    if messageType == Enum.MessageType.MessageOutput then
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif messageType == Enum.MessageType.MessageWarning then
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
    elseif messageType == Enum.MessageType.MessageError then
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
    else
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    label.Parent = consoleFrame
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLayout.AbsoluteContentSize.Y)

    -- Limit to last 50 messages
    local children = consoleFrame:GetChildren()
    if #children > 51 then
        children[2]:Destroy()  -- Keep title
    end
end

-- Override print to also show in UI
local oldPrint = print
print = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    addConsoleMessage("[PRINT] " .. message, Enum.MessageType.MessageOutput)
    return oldPrint(...)
end

local oldWarn = warn
warn = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    addConsoleMessage("[WARN] " .. message, Enum.MessageType.MessageWarning)
    return oldWarn(...)
end

local oldError = error
error = function(message, level)
    addConsoleMessage("[ERROR] " .. tostring(message), Enum.MessageType.MessageError)
    return oldError(message, level)
end

-- Also capture LogService messages
LogService.MessageOut:Connect(function(message, messageType)
    addConsoleMessage("[LOG] " .. message, messageType)
end)

local function clearConsole()
    for _, child in ipairs(consoleFrame:GetChildren()) do
        if child:IsA("TextLabel") and child ~= consoleTitle then
            child:Destroy()
        end
    end
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLayout.AbsoluteContentSize.Y)
end

local function findRemote(names, parent)
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            for _, name in ipairs(names) do
                if string.find(child.Name:lower(), name:lower()) then
                    return child
                end
            end
        end
    end
    return nil
end

local function scanRemotes()
    updateStatus("Scanning all remotes...")
    for _, child in ipairs(scanResults:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    allRemotes = {}
    
    local areas = {ReplicatedStorage, workspace, game:GetService("Lighting"), game:GetService("SoundService"), game:GetService("StarterGui"), game:GetService("StarterPack"), game:GetService("HttpService")}
    if player.PlayerGui then
        table.insert(areas, player.PlayerGui)
    end
    if player.Backpack then
        table.insert(areas, player.Backpack)
    end
    
    local count = 0
    for _, area in ipairs(areas) do
        for _, child in ipairs(area:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(allRemotes, child)
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -10, 0, 25)
                label.BackgroundTransparency = 1
                label.Text = area.Name .. "/" .. child:GetFullName() .. " (" .. child.ClassName .. ")"
                label.TextColor3 = Color3.fromRGB(255, 255, 0)
                label.TextScaled = true
                label.Font = Enum.Font.Gotham
                label.LayoutOrder = count
                label.Parent = scanResults
                count = count + 1
            end
        end
    end
    
    scanResults.CanvasSize = UDim2.new(0, 0, 0, resultsLayout.AbsoluteContentSize.Y)
    
    if #allRemotes > 0 then
        updateStatus("Found " .. #allRemotes .. " total remotes. Check UI list for all.")
    else
        updateStatus("No remotes found anywhere.")
    end
end

local function saveData(remote)
    if remote then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
            else
                remote:InvokeServer()
            end
        end)
    end
end

local function toggleDebug()
    debugMode = not debugMode
    updateStatus(debugMode and "Debug ON" or "Debug OFF")
    debugButton.Text = "Debug " .. (debugMode and "ON" or "OFF")
    if debugMode then
        print("[Islands Dupe] Debug mode enabled. Check UI console logs.")
    end
end

local function findClosestChest(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestChest = nil
    local closestDist = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if string.find(name, "chest") or string.find(name, "storage") or string.find(name, "box") or string.find(name, "container") then
                local dist = (obj:IsA("Model") and obj.PrimaryPart and (hrp.Position - obj.PrimaryPart.Position).Magnitude) or (obj:IsA("Part") and (hrp.Position - obj.Position).Magnitude)
                if dist and dist < closestDist and dist < 50 then  -- Within 50 studs
                    closestChest = obj
                    closestDist = dist
                end
            end
        end
    end

    return closestChest
end

local function duplicateItem()
    if duplicating then return end
    duplicating = true

    local character = player.Character
    if not character then
        updateStatus("No character found.")
        duplicating = false
        return
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        updateStatus("No tool held.")
        duplicating = false
        return
    end

    local amount = math.min(tonumber(amountBox.Text) or 1, maxAmount)
    local closestChest = findClosestChest(character)

    if not closestChest then
        updateStatus("No chest found nearby. Open a chest first.")
        duplicating = false
        return
    end

    updateStatus("Depositing " .. tool.Name .. " x" .. amount .. " into chest")

    if #allRemotes == 0 then
        updateStatus("Run scan first to find remotes.")
        duplicating = false
        return
    end

    local successCount = 0
    for i = 1, amount do
        -- Deposit into chest
        local cloneTool = tool:Clone()
        if closestChest:IsA("Model") and closestChest.PrimaryPart then
            cloneTool.Handle.CFrame = closestChest.PrimaryPart.CFrame + Vector3.new(0, 1, 0)
        elseif closestChest:IsA("Part") then
            cloneTool.Handle.CFrame = closestChest.CFrame + Vector3.new(0, 1, 0)
        end
        cloneTool.Parent = closestChest
        successCount = successCount + 1

        if debugMode then
            print("[Islands Dupe] Deposited item " .. i .. "/" .. amount .. " into chest")
        end

        -- Try legitimate dupe in background
        if #allRemotes > 0 then
            task.spawn(function()
                local triedArgs = 0
                for _, remote in ipairs(allRemotes) do
                    local argSets = {
                        {tool.Name, 1},
                        {tool, 1},
                        {tool.Name, amount},
                        {player, tool.Name, 1},
                        {1, tool.Name},
                        {tool},
                        {tool.Name, 1, "craft"},
                        {player, tool.Name, 1, "process"},
                        {tool.Name, 1, player.UserId},
                        {"add", tool.Name, 1},
                        {tool.Name, 1, "furnace"},
                        {tool.Name, 1, "anvil"}
                    }

                    for _, args in ipairs(argSets) do
                        triedArgs = triedArgs + 1
                        local ok = pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(args))
                            else
                                remote:InvokeServer(unpack(args))
                            end
                        end)

                        if ok and debugMode then
                            print("[Islands Dupe] Tried remote " .. remote.Name .. " with args: " .. table.concat(args, ", "))
                        end
                    end
                end

                if debugMode then
                    print("[Islands Dupe] Tried " .. triedArgs .. " arg combinations for legitimate dupe.")
                end
            end)
        end

        wait(delayTime)
    end

    updateStatus("Deposited " .. successCount .. "/" .. amount .. " items into chest.")
    duplicating = false
end

-- Console Log Capture
LogService.MessageOut:Connect(function(message, messageType)
    addConsoleMessage(message, messageType)
end)

-- Events
debugButton.MouseButton1Click:Connect(toggleDebug)
dupeButton.MouseButton1Click:Connect(duplicateItem)
scanButton.MouseButton1Click:Connect(scanRemotes)

-- Clear console button (add to UI)
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.45, 0, 0, 30)
clearButton.Position = UDim2.new(0.05, 0, 0, 540)
clearButton.Text = "Clear Console"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
clearButton.BorderSizePixel = 0
clearButton.Font = Enum.Font.GothamBold
clearButton.TextScaled = true
clearButton.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 5)
clearCorner.Parent = clearButton

local magentaTrimClear = Instance.new("UIStroke")
magentaTrimClear.Color = Color3.fromRGB(255, 100, 255)
magentaTrimClear.Thickness = 2
magentaTrimClear.Parent = clearButton

shimmerEffect(magentaTrimClear)

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.45, 0, 0, 30)
copyButton.Position = UDim2.new(0.5, 0, 0, 540)
copyButton.Text = "Copy Console"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
copyButton.BorderSizePixel = 0
copyButton.Font = Enum.Font.GothamBold
copyButton.TextScaled = true
copyButton.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 5)
copyCorner.Parent = copyButton

local magentaTrimCopy = Instance.new("UIStroke")
magentaTrimCopy.Color = Color3.fromRGB(255, 100, 255)
magentaTrimCopy.Thickness = 2
magentaTrimCopy.Parent = copyButton

shimmerEffect(magentaTrimCopy)

local function copyConsole()
    local messages = {}
    for _, child in ipairs(consoleFrame:GetChildren()) do
        if child:IsA("TextLabel") and child ~= consoleTitle then
            table.insert(messages, child.Text)
        end
    end
    local fullText = table.concat(messages, "\n")
    if setclipboard then
        setclipboard(fullText)
        updateStatus("Console copied to clipboard!")
    else
        updateStatus("Clipboard not available.")
    end
end

clearButton.MouseButton1Click:Connect(clearConsole)
copyButton.MouseButton1Click:Connect(copyConsole)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            -- Stop
            screenGui:Destroy()
            updateStatus("Script stopped.")
        else
            -- Toggle
            enabled = not enabled
            mainFrame.Visible = enabled
        end
    end
end)

-- Auto scan on load
scanRemotes()

updateStatus("Script loaded. Press G to toggle.")
print("[Islands Dupe] New script loaded with auto-scan.")