-- New Roblox Islands Duplication Script
-- Compatible with Vega X Executor
-- True duplication with persistence and comprehensive remote search

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0, 10, 1, -460)
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
scanResults.Size = UDim2.new(0.9, 0, 0, 150)
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

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
    if debugMode then
        print("[Islands Dupe] " .. text)
    end
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
        print("[Islands Dupe] Debug mode enabled. Check console for logs.")
    end
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
    updateStatus("Duplicating " .. tool.Name .. " x" .. amount)
    
    if #allRemotes == 0 then
        updateStatus("Run scan first to find remotes.")
        duplicating = false
        return
    end
    
    -- Prioritize inventory/hotbar remotes
    local inventoryRemotes = {}
    for _, remote in ipairs(allRemotes) do
        if string.find(remote.Name:lower(), "inventory") or string.find(remote.Name:lower(), "hotbar") or string.find(remote.Name:lower(), "add") or string.find(remote.Name:lower(), "give") then
            table.insert(inventoryRemotes, remote)
        end
    end
    
    local saveRemote = nil
    for _, remote in ipairs(allRemotes) do
        if string.find(remote.Name:lower(), "save") or string.find(remote.Name:lower(), "update") or string.find(remote.Name:lower(), "datastore") then
            saveRemote = remote
            break
        end
    end
    
    if debugMode then
        print("[Islands Dupe] Found " .. #allRemotes .. " remotes, prioritizing " .. #inventoryRemotes .. " inventory remotes.")
        print("[Islands Dupe] Using save remote: " .. (saveRemote and saveRemote.Name or "none"))
    end
    
    local successCount = 0
    for i = 1, amount do
        local success = false
        local triedArgs = 0
        local initialCount = #backpack:GetChildren()

        -- Try inventory remotes first
        for _, remote in ipairs(inventoryRemotes) do
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
                    print("[Islands Dupe] Tried inventory remote " .. remote.Name .. " with args: " .. table.concat(args, ", "))
                end

                -- Check if item was added
                wait(0.1)
                local newCount = #backpack:GetChildren()
                if newCount > initialCount then
                    success = true
                    if debugMode then
                        print("[Islands Dupe] Success! Item added via " .. remote.Name)
                    end
                    break
                end
            end
            if success then break end
        end

        -- If no success with inventory, try all remotes
        if not success then
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

                    -- Check if item was added
                    wait(0.1)
                    local newCount = #backpack:GetChildren()
                    if newCount > initialCount then
                        success = true
                        if debugMode then
                            print("[Islands Dupe] Success! Item added via " .. remote.Name)
                        end
                        break
                    end
                end
                if success then break end
            end
        end

        if debugMode then
            print("[Islands Dupe] Dupe attempt " .. i .. " tried " .. triedArgs .. " arg combinations.")
        end

        if success then
            successCount = successCount + 1
            wait(delayTime)
        else
            cloneTool:Destroy()  -- Remove local if server fails
            if debugMode then
                print("[Islands Dupe] Failed to add item legitimately, removed local clone.")
            end
            break
        end
    end
    
    -- Fire save after all dupes for persistence
    if saveRemote then
        pcall(function()
            if saveRemote:IsA("RemoteEvent") then
                saveRemote:FireServer()
            else
                saveRemote:InvokeServer()
            end
        end)
        if debugMode then
            print("[Islands Dupe] Fired save remote after dupes")
        end
    end
    
    updateStatus("Duplicated " .. successCount .. "/" .. amount .. " items legitimately.")
    duplicating = false
end

-- Events
debugButton.MouseButton1Click:Connect(toggleDebug)
dupeButton.MouseButton1Click:Connect(duplicateItem)
scanButton.MouseButton1Click:Connect(scanRemotes)

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
print("[Islands Dupe] New script loaded.")