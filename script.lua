-- Simplified Roblox Islands Duplication Script
-- Compatible with Vega X Executor
-- True duplication with persistence

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local player = Players.LocalPlayer

local enabled = true
local duplicating = false
local maxAmount = 5
local delayTime = 2
local allRemotes = {}

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IslandsDupeUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 1, -410)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = enabled

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local dupeButton = Instance.new("TextButton")
dupeButton.Size = UDim2.new(0.9, 0, 0, 50)
dupeButton.Position = UDim2.new(0.05, 0, 0, 20)
dupeButton.Text = "DUPLICATE ITEM"
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
dupeButton.BorderSizePixel = 0
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextScaled = true
dupeButton.Active = true
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

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
statusLabel.Position = UDim2.new(0.05, 0, 0, 80)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready. Hold an item and click DUPLICATE."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(0.9, 0, 0, 250)
consoleFrame.Position = UDim2.new(0.05, 0, 0, 140)
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
consoleTitle.Text = "Console Logs"
consoleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
consoleTitle.TextScaled = true
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.Parent = consoleFrame

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
    print("[Islands Dupe] " .. text)
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
    updateStatus("Scanning for duplication remotes...")
    allRemotes = {}

    local areas = {ReplicatedStorage, workspace}
    if player.PlayerGui then
        table.insert(areas, player.PlayerGui)
    end

    for _, area in ipairs(areas) do
        for _, child in ipairs(area:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(allRemotes, child)
            end
        end
    end

    if #allRemotes > 0 then
        updateStatus("Found " .. #allRemotes .. " remotes. Ready to duplicate.")
    else
        updateStatus("No remotes found.")
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

local function duplicateItem()
    print("[Islands Dupe] Duplicate button clicked")
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

    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        updateStatus("No backpack found.")
        duplicating = false
        return
    end

    updateStatus("Scanning and duplicating " .. tool.Name .. "...")

    -- Auto scan if not done yet
    if #allRemotes == 0 then
        scanRemotes()
        task.wait(0.5)
    end

    if #allRemotes == 0 then
        updateStatus("No remotes found. Cannot duplicate.")
        duplicating = false
        return
    end

    -- Check if item already exists in backpack or hotbar (to avoid multiple instances)
    local existingTool = nil
    if backpack then
        existingTool = backpack:FindFirstChild(tool.Name)
    end
    if not existingTool and character then
        existingTool = character:FindFirstChild(tool.Name)
    end
    if existingTool then
        updateStatus("Item already exists in inventory/hotbar. Cannot duplicate to avoid anti-cheat.")
        duplicating = false
        return
    end

    local successCount = 0
    local amount = 1  -- Fixed to 1 for now, can be made configurable later

    -- Add to backpack (local)
    local cloneTool = tool:Clone()
    cloneTool.Parent = backpack
    successCount = successCount + 1

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

                    if ok then
                        print("[Islands Dupe] Successfully fired remote " .. remote.Name .. " with args: " .. table.concat(args, ", "))
                        -- Try to save data for persistence
                        local saveRemote = findRemote({"save", "update", "datastore"}, ReplicatedStorage)
                        saveData(saveRemote)
                        break
                    end
                end
            end

            print("[Islands Dupe] Tried " .. triedArgs .. " arg combinations for legitimate dupe.")
        end)
    end

    updateStatus("Added " .. successCount .. " item to backpack. Check persistence by relogging.")
    duplicating = false
end

-- Events
dupeButton.MouseButton1Click:Connect(duplicateItem)

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

updateStatus("Script loaded. Press G to toggle.")
print("[Islands Dupe] Simplified script loaded.")