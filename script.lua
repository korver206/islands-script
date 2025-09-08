-- Tabbed Roblox Islands Duplication Script
-- Compatible with Vega X Executor
-- Organized item browser with categories

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local enabled = true
local itemBrowserEnabled = false
local allRemotes = {}
local allItems = {}
local currentTab = "All"
local categories = {
    "All",
    "Tools",
    "Materials",
    "Food",
    "Blocks",
    "Weapons",
    "Armor",
    "Other"
}

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

local function shimmerEffect(stroke)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local goal1 = {Color = Color3.fromRGB(255, 100, 255)}
    local goal2 = {Color = Color3.fromRGB(255, 200, 255)}
    local tween1 = TweenService:Create(stroke, tweenInfo, goal1)
    local tween2 = TweenService:Create(stroke, tweenInfo, goal2)
    tween1:Play()
    tween2:Play()
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
statusLabel.Position = UDim2.new(0.05, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Press H to open Item Browser"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(0.9, 0, 0, 300)
consoleFrame.Position = UDim2.new(0.05, 0, 0, 80)
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

-- Item Browser UI with Tabs
local itemBrowserFrame = Instance.new("Frame")
itemBrowserFrame.Size = UDim2.new(0, 500, 0, 550)
itemBrowserFrame.Position = UDim2.new(0, 320, 1, -560)
itemBrowserFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
itemBrowserFrame.BackgroundTransparency = 0.2
itemBrowserFrame.BorderSizePixel = 0
itemBrowserFrame.Parent = screenGui
itemBrowserFrame.Visible = itemBrowserEnabled

local browserCorner = Instance.new("UICorner")
browserCorner.CornerRadius = UDim.new(0, 10)
browserCorner.Parent = itemBrowserFrame

local browserTitle = Instance.new("TextLabel")
browserTitle.Size = UDim2.new(1, 0, 0, 30)
browserTitle.BackgroundTransparency = 1
browserTitle.Text = "Item Browser - " .. currentTab
browserTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
browserTitle.TextScaled = true
browserTitle.Font = Enum.Font.GothamBold
browserTitle.Parent = itemBrowserFrame

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0.95, 0, 0, 40)
tabContainer.Position = UDim2.new(0.025, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = itemBrowserFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabContainer

-- Item Grid
local itemGrid = Instance.new("ScrollingFrame")
itemGrid.Size = UDim2.new(0.95, 0, 0, 450)
itemGrid.Position = UDim2.new(0.025, 0, 0, 80)
itemGrid.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
itemGrid.BackgroundTransparency = 0.1
itemGrid.BorderSizePixel = 2
itemGrid.BorderColor3 = Color3.fromRGB(255, 100, 255)
itemGrid.ScrollBarThickness = 8
itemGrid.Parent = itemBrowserFrame

local gridCorner = Instance.new("UICorner")
gridCorner.CornerRadius = UDim.new(0, 5)
gridCorner.Parent = itemGrid

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 60, 0, 60)
gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = itemGrid

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
    print("[Islands Dupe] " .. text)
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
local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(message, messageType)
    addConsoleMessage("[LOG] " .. message, messageType)
end)

local function categorizeItem(itemName)
    itemName = itemName:lower()

    -- Tools category
    if itemName:find("pickaxe") or itemName:find("axe") or itemName:find("shovel") or
       itemName:find("hammer") or itemName:find("sword") or itemName:find("bow") or
       itemName:find("fishing") or itemName:find("rod") then
        return "Tools"
    end

    -- Materials category
    if itemName:find("wood") or itemName:find("stone") or itemName:find("iron") or
       itemName:find("gold") or itemName:find("diamond") or itemName:find("coal") or
       itemName:find("ore") or itemName:find("ingot") then
        return "Materials"
    end

    -- Food category
    if itemName:find("apple") or itemName:find("bread") or itemName:find("fish") or
       itemName:find("meat") or itemName:find("berry") or itemName:find("fruit") or
       itemName:find("cake") or itemName:find("pie") then
        return "Food"
    end

    -- Blocks category
    if itemName:find("block") or itemName:find("brick") or itemName:find("plank") or
       itemName:find("log") or itemName:find("stone") or itemName:find("dirt") or
       itemName:find("sand") or itemName:find("glass") then
        return "Blocks"
    end

    -- Weapons category
    if itemName:find("sword") or itemName:find("bow") or itemName:find("arrow") or
       itemName:find("shield") or itemName:find("dagger") or itemName:find("spear") then
        return "Weapons"
    end

    -- Armor category
    if itemName:find("helmet") or itemName:find("chestplate") or itemName:find("leggings") or
       itemName:find("boots") or itemName:find("armor") or itemName:find("shield") then
        return "Armor"
    end

    return "Other"
end

local function createTabs()
    -- Clear existing tabs
    for _, child in ipairs(tabContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for i, category in ipairs(categories) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 60, 0, 35)
        tabButton.BackgroundColor3 = currentTab == category and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)
        tabButton.BackgroundTransparency = 0.3
        tabButton.BorderSizePixel = 1
        tabButton.BorderColor3 = Color3.fromRGB(255, 100, 255)
        tabButton.Text = category:sub(1, 4)  -- Abbreviate
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.GothamBold
        tabButton.LayoutOrder = i
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 5)
        tabCorner.Parent = tabButton

        if currentTab == category then
            local tabTrim = Instance.new("UIStroke")
            tabTrim.Color = Color3.fromRGB(255, 100, 255)
            tabTrim.Thickness = 2
            tabTrim.Parent = tabButton
            shimmerEffect(tabTrim)
        end

        tabButton.MouseButton1Click:Connect(function()
            currentTab = category
            browserTitle.Text = "Item Browser - " .. currentTab
            createTabs()  -- Refresh tabs
            displayItemsForTab()
        end)
    end
end

local function displayItemsForTab()
    print("[Islands Dupe] Displaying items for tab: " .. currentTab)

    -- Clear existing items
    for _, child in ipairs(itemGrid:GetChildren()) do
        if child:IsA("ImageButton") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local itemsToShow = {}

    if currentTab == "All" then
        itemsToShow = allItems
        print("[Islands Dupe] Showing all " .. #allItems .. " items")
    else
        for _, item in ipairs(allItems) do
            if item.category == currentTab then
                table.insert(itemsToShow, item)
            end
        end
        print("[Islands Dupe] Showing " .. #itemsToShow .. " items in category: " .. currentTab)
    end

    -- Sort alphabetically
    table.sort(itemsToShow, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    -- Create item buttons in batches
    local itemCount = 0
    local batchSize = 20  -- Increased batch size

    for batchStart = 1, #itemsToShow, batchSize do
        local batchEnd = math.min(batchStart + batchSize - 1, #itemsToShow)

        for i = batchStart, batchEnd do
            local itemData = itemsToShow[i]

            local itemButton = Instance.new("ImageButton")
            itemButton.Size = UDim2.new(0, 50, 0, 50)
            itemButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            itemButton.BackgroundTransparency = 0.3
            itemButton.BorderSizePixel = 1
            itemButton.BorderColor3 = Color3.fromRGB(255, 100, 255)
            itemButton.Image = itemData.icon
            itemButton.LayoutOrder = itemCount
            itemButton.Parent = itemGrid

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 5)
            buttonCorner.Parent = itemButton

            -- Always show name bubble for every item
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
            nameLabel.Position = UDim2.new(0, 0, 0.7, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = itemData.name:sub(1, 4)
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = itemButton

            -- If no icon, adjust background for visibility
            if itemData.icon == "rbxassetid://0" then
                itemButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                itemButton.BackgroundTransparency = 0.1
            end

            -- Enhanced tooltip with category
            local tooltip = Instance.new("TextLabel")
            tooltip.Size = UDim2.new(0, 140, 0, 25)
            tooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            tooltip.BackgroundTransparency = 0.5
            tooltip.Text = itemData.name .. "\n[" .. itemData.category .. "]"
            tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
            tooltip.TextScaled = true
            tooltip.Font = Enum.Font.Gotham
            tooltip.Visible = false
            tooltip.ZIndex = 10
            tooltip.Parent = itemButton

            local tooltipCorner = Instance.new("UICorner")
            tooltipCorner.CornerRadius = UDim.new(0, 3)
            tooltipCorner.Parent = tooltip

            itemButton.MouseEnter:Connect(function()
                tooltip.Visible = true
            end)

            itemButton.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)

            itemButton.MouseButton1Click:Connect(function()
                updateStatus("Giving: " .. itemData.name)
                local backpack = player:FindFirstChild("Backpack")
                if backpack and not backpack:FindFirstChild(itemData.name) then
                    pcall(function()
                        local clonedItem = itemData.object:Clone()
                        clonedItem.Parent = backpack
                        updateStatus("Added: " .. itemData.name)
                        print("[Islands Dupe] Successfully added " .. itemData.name .. " to backpack")
                    end)
                else
                    updateStatus("Item already exists or no backpack")
                end
            end)

            itemCount = itemCount + 1
        end

        -- Delay between batches
        if batchEnd < #itemsToShow then
            task.wait(0.01)
        end
    end

    -- Calculate CanvasSize
    local itemsPerRow = math.floor(itemGrid.AbsoluteSize.X / 65)
    if itemsPerRow < 1 then itemsPerRow = 1 end
    local rows = math.ceil(itemCount / itemsPerRow)
    itemGrid.CanvasSize = UDim2.new(0, 0, 0, rows * 65)

    print("[Islands Dupe] Display complete: " .. itemCount .. " items shown")
    updateStatus("Showing " .. itemCount .. " items in " .. currentTab)
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

    -- Limit to last 30 messages
    local children = consoleFrame:GetChildren()
    if #children > 32 then
        children[2]:Destroy()  -- Keep title
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
    updateStatus("Scanning for remotes...")
    allRemotes = {}

    local areas = {ReplicatedStorage, workspace}
    if player.PlayerGui then
        table.insert(areas, player.PlayerGui)
    end

    local scannedCount = 0
    local scanLimit = 1000

    for _, area in ipairs(areas) do
        pcall(function()
            local descendants = area:GetDescendants()
            for i, child in ipairs(descendants) do
                scannedCount = scannedCount + 1
                if scannedCount > scanLimit then
                    break
                end
                if i % 100 == 0 then
                    task.wait(0.01)
                end
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    table.insert(allRemotes, child)
                end
            end
        end)
        if scannedCount > scanLimit then
            break
        end
    end

    if #allRemotes > 0 then
        updateStatus("Found " .. #allRemotes .. " remotes.")
    else
        updateStatus("No remotes found.")
    end
end

local function scanItems()
    updateStatus("Scanning items...")
    allItems = {}

    local areas = {ReplicatedStorage, game:GetService("StarterPack")}
    if player:FindFirstChild("Backpack") then
        table.insert(areas, player.Backpack)
    end
    local foundItems = {}
    local scannedCount = 0
    local scanLimit = 2000
    local toolsFound = 0
    local modelsFound = 0

    print("[Islands Dupe] Starting item scan...")

    for _, area in ipairs(areas) do
        print("[Islands Dupe] Scanning " .. area.Name)
        pcall(function()
            local descendants = area:GetDescendants()
            for i, child in ipairs(descendants) do
                scannedCount = scannedCount + 1
                if scannedCount > scanLimit then
                    print("[Islands Dupe] Scan limit reached at " .. scannedCount)
                    break
                end

                if scannedCount % 50 == 0 then
                    task.wait(0.01)
                    updateStatus("Scanned " .. scannedCount .. " objects...")
                end

                local isValidItem = false
                local itemType = ""

                if child:IsA("Tool") then
                    isValidItem = true
                    itemType = "Tool"
                    toolsFound = toolsFound + 1
                elseif child:IsA("Model") and child:FindFirstChild("Handle") then
                    isValidItem = true
                    itemType = "Model"
                    modelsFound = modelsFound + 1
                end

                if isValidItem then
                    local itemName = child.Name
                    local iconId = ""
                    local category = categorizeItem(itemName)

                    -- Enhanced icon detection
                    if child:IsA("Tool") then
                        if child:FindFirstChild("IconId") and child.IconId:IsA("StringValue") and child.IconId.Value ~= "" then
                            iconId = "rbxassetid://" .. child.IconId.Value
                        elseif child.TextureId and child.TextureId ~= "" then
                            iconId = child.TextureId
                        elseif child:FindFirstChild("Icon") and child.Icon:IsA("ImageLabel") and child.Icon.Image ~= "" then
                            iconId = child.Icon.Image
                        end
                    elseif child:IsA("Model") then
                        local handle = child:FindFirstChild("Handle")
                        if handle then
                            if handle.TextureId and handle.TextureId ~= "" then
                                iconId = handle.TextureId
                            elseif handle:FindFirstChildOfClass("Decal") then
                                iconId = handle.Decal.Texture
                            elseif handle:FindFirstChild("Icon") and handle.Icon:IsA("ImageLabel") then
                                iconId = handle.Icon.Image
                            end
                        end
                    end

                    if iconId == "" then
                        iconId = "rbxassetid://0"
                    end

                    -- Always add the item, even if duplicate names (some games have multiple versions)
                    local itemData = {
                        name = itemName,
                        icon = iconId,
                        type = itemType,
                        object = child,
                        category = category
                    }

                    table.insert(foundItems, itemData)
                    print("[Islands Dupe] Found " .. itemType .. ": " .. itemName .. " -> " .. category)
                end
            end
        end)
        if scannedCount > scanLimit then
            break
        end
    end

    -- Set allItems directly from foundItems
    allItems = foundItems

    print("[Islands Dupe] Scan complete: " .. toolsFound .. " tools, " .. modelsFound .. " models")
    updateStatus("Found " .. #allItems .. " items (" .. toolsFound .. " tools, " .. modelsFound .. " models)")
end

-- Events
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            screenGui:Destroy()
            updateStatus("Script stopped.")
        else
            enabled = not enabled
            mainFrame.Visible = enabled
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        itemBrowserEnabled = not itemBrowserEnabled
        itemBrowserFrame.Visible = itemBrowserEnabled
        if itemBrowserEnabled then
            updateStatus("Scanning remotes and items...")
            scanRemotes()
            task.wait(0.5)
            scanItems()
            task.wait(0.5)
            createTabs()
            displayItemsForTab()
        end
        updateStatus(itemBrowserEnabled and "Item Browser enabled" or "Item Browser disabled")
    end
end)

updateStatus("Script loaded. G: toggle main UI, Shift+G: stop, H: item browser")
print("[Islands Dupe] Tabbed script loaded")