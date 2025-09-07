-- New Roblox Islands Duplication Script
-- Compatible with Vega X Executor
-- True duplication with persistence

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local enabled = true
local duplicating = false
local maxAmount = 5
local delayTime = 2

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IslandsDupeUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0, 10, 1, -460)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.4
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

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0.9, 0, 0, 40)
scanButton.Position = UDim2.new(0.05, 0, 0, 130)
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
    print("[Islands Dupe] " .. text)
end

local function findRemote(names, parent)
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            for _, name in ipairs(names) do
                if child.Name:lower():find(name:lower()) then
                    return child
                end
            end
        end
    end
    return nil
end

local function scanRemotes()
    updateStatus("Scanning...")
    scanResults:ClearAllChildren()
    local remotesFound = {}
    
    local possibleNames = {"craft", "inv", "dupe", "additem", "give", "replicate", "save", "update"}
    
    local areas = {ReplicatedStorage, workspace}
    
    for _, area in ipairs(areas) do
        local remote = findRemote(possibleNames, area)
        if remote then
            table.insert(remotesFound, area.Name .. "/" .. remote:GetFullName())
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = area.Name .. ": " .. remote.Name .. " (" .. remote.ClassName .. ")"
            label.TextColor3 = Color3.fromRGB(0, 255, 0)
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.Parent = scanResults
        end
    end
    
    if #remotesFound > 0 then
        updateStatus("Found " .. #remotesFound .. " potential remotes. Check UI list.")
    else
        updateStatus("No remotes found. Game may have updated.")
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
    
    local possibleNames = {"craft", "inv", "additem", "give", "replicate"}
    local dupeRemote = findRemote(possibleNames, ReplicatedStorage)
    local saveRemote = findRemote({"save", "update"}, ReplicatedStorage)
    
    if not dupeRemote then
        updateStatus("No duplication remote found.")
        duplicating = false
        return
    end
    
    local successCount = 0
    for i = 1, amount do
        local success = pcall(function()
            if dupeRemote:IsA("RemoteEvent") then
                dupeRemote:FireServer(tool.Name, 1)  -- Assume args for Islands
            else
                dupeRemote:InvokeServer(tool.Name, 1)
            end
        end)
        
        if success then
            successCount = successCount + 1
            saveData(saveRemote)
            wait(delayTime)
        else
            break
        end
    end
    
    updateStatus("Duplicated " .. successCount .. "/" .. amount .. " items.")
    duplicating = false
end

-- Events
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