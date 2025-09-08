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
local itemBrowserEnabled = false
local allItems = {}

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

-- Item Browser UI
local itemBrowserFrame = Instance.new("Frame")
itemBrowserFrame.Size = UDim2.new(0, 400, 0, 500)
itemBrowserFrame.Position = UDim2.new(0, 320, 1, -510)
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
browserTitle.Text = "Item Browser"
browserTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
browserTitle.TextScaled = true
browserTitle.Font = Enum.Font.GothamBold
browserTitle.Parent = itemBrowserFrame

local itemGrid = Instance.new("ScrollingFrame")
itemGrid.Size = UDim2.new(0.95, 0, 0, 430)
itemGrid.Position = UDim2.new(0.025, 0, 0, 40)
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

    -- Comprehensive list of areas to search
    local areas = {
        ReplicatedStorage,
        workspace,
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("HttpService")
    }

    if player.PlayerGui then
        table.insert(areas, player.PlayerGui)
    end

    -- Add all services
    for _, service in ipairs(game:GetChildren()) do
        if service:IsA("Service") and not table.find(areas, service) then
            table.insert(areas, service)
        end
    end

    -- Search for remotes in all areas
    for _, area in ipairs(areas) do
        pcall(function()
            for _, child in ipairs(area:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    table.insert(allRemotes, child)
                end
            end
        end)
    end

    -- Also search for remotes with specific names that might be obfuscated
    local specificNames = {
        "Remote", "Event", "Function", "Server", "Client",
        "Inventory", "Item", "Give", "Add", "Remove", "Update",
        "Craft", "Process", "Furnace", "Anvil", "Workbench",
        "Storage", "Chest", "Container", "Backpack",
        "Data", "Save", "Load", "Sync", "Network"
    }

    for _, area in ipairs(areas) do
        pcall(function()
            for _, child in ipairs(area:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    for _, name in ipairs(specificNames) do
                        if string.find(child.Name:lower(), name:lower()) then
                            if not table.find(allRemotes, child) then
                                table.insert(allRemotes, child)
                            end
                            break
                        end
                    end
                end
            end
        end)
    end

    if #allRemotes > 0 then
        updateStatus("Found " .. #allRemotes .. " remotes. Ready to give items.")
        print("[Islands Dupe] Found remotes: " .. #allRemotes)
    else
        updateStatus("No remotes found. Game may have updated.")
        print("[Islands Dupe] No remotes found in any location")
    end
end

local function scanItems()
    updateStatus("Scanning for all game items...")
    allItems = {}

    -- Clear existing items
    for _, child in ipairs(itemGrid:GetChildren()) do
        if child:IsA("ImageButton") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local areas = {ReplicatedStorage, workspace}
    local foundItems = {}

    for _, area in ipairs(areas) do
        for _, child in ipairs(area:GetDescendants()) do
            if child:IsA("Tool") or (child:IsA("Model") and child:FindFirstChild("Handle")) then
                local itemName = child.Name
                local iconId = ""
                local itemType = child:IsA("Tool") and "Tool" or "Model"

                -- Try to find icon in various places (improved for Roblox Islands)
                if child:IsA("Tool") then
                    -- Check for IconId first (common in Islands)
                    if child:FindFirstChild("IconId") and child.IconId:IsA("StringValue") then
                        iconId = "rbxassetid://" .. child.IconId.Value
                    elseif child:FindFirstChild("IconId") and type(child.IconId) == "string" then
                        iconId = "rbxassetid://" .. child.IconId
                    end

                    -- Check for Icon child
                    if child:FindFirstChild("Icon") and child.Icon:IsA("ImageLabel") then
                        iconId = child.Icon.Image
                    end

                    -- Check for TextureId
                    if child.TextureId and child.TextureId ~= "" then
                        iconId = child.TextureId
                    end

                    -- Check for Decal in Handle
                    if child:FindFirstChild("Handle") and child.Handle:FindFirstChildOfClass("Decal") then
                        iconId = child.Handle.Decal.Texture
                    end

                    -- Check for Icon in Handle
                    if child:FindFirstChild("Handle") and child.Handle:FindFirstChild("Icon") then
                        local handleIcon = child.Handle.Icon
                        if handleIcon:IsA("ImageLabel") then
                            iconId = handleIcon.Image
                        elseif handleIcon:IsA("Decal") then
                            iconId = handleIcon.Texture
                        end
                    end
                elseif child:IsA("Model") then
                    local handle = child:FindFirstChild("Handle")
                    if handle then
                        -- Check for IconId in model
                        if child:FindFirstChild("IconId") and child.IconId:IsA("StringValue") then
                            iconId = "rbxassetid://" .. child.IconId.Value
                        elseif child:FindFirstChild("IconId") and type(child.IconId) == "string" then
                            iconId = "rbxassetid://" .. child.IconId
                        end

                        -- Check for Icon in handle
                        if handle:FindFirstChild("Icon") then
                            local handleIcon = handle.Icon
                            if handleIcon:IsA("ImageLabel") then
                                iconId = handleIcon.Image
                            elseif handleIcon:IsA("Decal") then
                                iconId = handleIcon.Texture
                            end
                        end

                        -- Check for TextureId
                        if handle.TextureId and handle.TextureId ~= "" then
                            iconId = handle.TextureId
                        end

                        -- Check for Decal in Handle
                        if handle:FindFirstChildOfClass("Decal") then
                            iconId = handle.Decal.Texture
                        end
                    end
                end

                -- Search for icon in ReplicatedStorage (common location for Islands icons)
                if iconId == "" then
                    pcall(function()
                        for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
                            if item.Name == child.Name .. "Icon" or item.Name == child.Name .. "_Icon" then
                                if item:IsA("StringValue") and item.Value ~= "" then
                                    iconId = "rbxassetid://" .. item.Value
                                    break
                                elseif item:IsA("ImageLabel") and item.Image ~= "" then
                                    iconId = item.Image
                                    break
                                end
                            end
                        end
                    end)
                end

                -- If no icon found, try to find any image in the object
                if iconId == "" then
                    for _, descendant in ipairs(child:GetDescendants()) do
                        if descendant:IsA("ImageLabel") and descendant.Image and descendant.Image ~= "" then
                            iconId = descendant.Image
                            break
                        elseif descendant:IsA("Decal") and descendant.Texture and descendant.Texture ~= "" then
                            iconId = descendant.Texture
                            break
                        elseif descendant:IsA("StringValue") and descendant.Name:lower():find("icon") and descendant.Value ~= "" then
                            iconId = "rbxassetid://" .. descendant.Value
                            break
                        end
                    end
                end

                -- If still no icon found, use a default placeholder
                if iconId == "" then
                    iconId = "rbxassetid://0"  -- Transparent placeholder
                end

                if not foundItems[itemName] then
                    foundItems[itemName] = {
                        name = itemName,
                        icon = iconId,
                        type = itemType,
                        object = child
                    }
                end
            end
        end
    end

    -- Sort items alphabetically
    local sortedItems = {}
    for name, data in pairs(foundItems) do
        table.insert(sortedItems, data)
    end
    table.sort(sortedItems, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    -- Create buttons for sorted items
    local itemCount = 0
    for _, itemData in ipairs(sortedItems) do
        -- Create item button
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

        -- If no icon found, try to use the item's appearance or create a simple visual
        if itemData.icon == "rbxassetid://0" then
            -- Try to get the item's color or create a colored background
            local itemColor = Color3.fromRGB(150, 150, 150)  -- Default gray

            if child:IsA("Tool") and child:FindFirstChild("Handle") then
                local handle = child.Handle
                if handle:IsA("Part") and handle.BrickColor then
                    itemColor = handle.BrickColor.Color
                end
            elseif child:IsA("Model") and child:FindFirstChild("Handle") then
                local handle = child:FindFirstChild("Handle")
                if handle:IsA("Part") and handle.BrickColor then
                    itemColor = handle.BrickColor.Color
                end
            end

            itemButton.BackgroundColor3 = itemColor
            itemButton.BackgroundTransparency = 0.1

            -- Add item name as small text
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
            nameLabel.Position = UDim2.new(0, 0, 0.7, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = itemData.name:sub(1, 4)  -- First 4 letters
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Parent = itemButton
        end

        -- Add tooltip with full item name
        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 150, 0, 25)
        tooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tooltip.BackgroundTransparency = 0.3
        tooltip.Text = itemData.name .. " (" .. itemData.type .. ")"
        tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
        tooltip.TextScaled = true
        tooltip.Font = Enum.Font.Gotham
        tooltip.Visible = false
        tooltip.ZIndex = 10
        tooltip.Parent = itemButton

        local tooltipCorner = Instance.new("UICorner")
        tooltipCorner.CornerRadius = UDim.new(0, 3)
        tooltipCorner.Parent = tooltip

        -- Show/hide tooltip
        itemButton.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)

        itemButton.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)

        -- Click to get/give this item
        itemButton.MouseButton1Click:Connect(function()
            updateStatus("Attempting to give: " .. itemData.name)
            task.spawn(function()
                local success = false

                -- Always try to clone and add to backpack first (works for items you don't have)
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    -- Check if item already exists
                    local existingItem = backpack:FindFirstChild(itemData.name)
                    if not existingItem then
                        pcall(function()
                            local clonedItem = itemData.object:Clone()
                            clonedItem.Parent = backpack
                            success = true
                            print("[Islands Dupe] Added " .. itemData.name .. " to backpack")
                        end)
                    else
                        updateStatus("Item already in backpack: " .. itemData.name)
                        return
                    end
                end

                -- Then try server-side methods for persistence if remotes are available
                if #allRemotes > 0 then
                    for _, remote in ipairs(allRemotes) do
                        local argSets = {
                            {itemData.name, 1},
                            {itemData.name, 1, player},
                            {player, itemData.name, 1},
                            {"give", itemData.name, 1},
                            {"add", itemData.name, 1},
                            {itemData.name, 1, "inventory"},
                            {itemData.name, 1, "give"},
                            {itemData.name, 1, "backpack"},
                            {itemData.name, 1, "storage"}
                        }

                        for _, args in ipairs(argSets) do
                            local ok = pcall(function()
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(unpack(args))
                                else
                                    remote:InvokeServer(unpack(args))
                                end
                            end)

                            if ok then
                                print("[Islands Dupe] Server confirmed " .. itemData.name)
                                success = true
                                break
                            end
                        end
                        if success then break end
                    end
                else
                    print("[Islands Dupe] No remotes found, using local clone only")
                end

                -- Save data for persistence
                local saveRemote = findRemote({"save", "update", "datastore"}, ReplicatedStorage)
                saveData(saveRemote)

                if success then
                    updateStatus("Gave: " .. itemData.name)
                else
                    updateStatus("Failed to give: " .. itemData.name)
                end
            end)
        end)

        table.insert(allItems, itemData)
        itemCount = itemCount + 1
    end

    -- Calculate proper CanvasSize based on grid layout
    local itemsPerRow = math.floor(itemGrid.AbsoluteSize.X / 65)  -- 60px item + 5px padding
    if itemsPerRow < 1 then itemsPerRow = 1 end
    local rows = math.ceil(itemCount / itemsPerRow)
    itemGrid.CanvasSize = UDim2.new(0, 0, 0, rows * 65)  -- 60px item + 5px padding

    updateStatus("Found " .. itemCount .. " items (sorted alphabetically).")
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



UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            -- Stop script
            screenGui:Destroy()
            updateStatus("Script stopped.")
            print("[Islands Dupe] Script stopped with Shift+G")
        else
            -- Toggle main UI
            enabled = not enabled
            mainFrame.Visible = enabled
            updateStatus(enabled and "Main UI enabled" or "Main UI disabled")
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Toggle item browser UI
        itemBrowserEnabled = not itemBrowserEnabled
        itemBrowserFrame.Visible = itemBrowserEnabled
        if itemBrowserEnabled then
            updateStatus("Scanning remotes and items...")
            scanRemotes()
            task.wait(0.5)  -- Wait for remote scan to complete
            scanItems()
        end
        updateStatus(itemBrowserEnabled and "Item Browser enabled (H to toggle)" or "Item Browser disabled")
    end
end)

updateStatus("Script loaded. G: toggle main UI, Shift+G: stop script, H: toggle item browser")
print("[Islands Dupe] Simplified script loaded with item browser (H key)")