task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Player = Players.LocalPlayer
    local PlaceId = game.PlaceId
    local JobId = game.JobId

    local RootFolder = "ServerHop"
    local StorageFile = `{RootFolder}/{PlaceId}.json`
    local MaxTracked = 2

    if not isfolder(RootFolder) then makefolder(RootFolder) end

    local Tracked = {}
    if isfile(StorageFile) then
        local data = HttpService:JSONDecode(readfile(StorageFile))
        if typeof(data) == "table" then
            Tracked = data
        end
    end

    if not table.find(Tracked, JobId) then
        table.insert(Tracked, 1, JobId)
        if #Tracked > MaxTracked then table.remove(Tracked, #Tracked) end
        writefile(StorageFile, HttpService:JSONEncode(Tracked))
    end

    local guiParent = Player:WaitForChild("PlayerGui", 5) or game:GetService("CoreGui")
    local screenGui = Instance.new("ScreenGui", guiParent)
    screenGui.Name = "ServerHopUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local function CreateMainButton(text, position, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 40)
        btn.Position = position
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Parent = screenGui
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    CreateMainButton("Rejoin Server", UDim2.new(0.5, -160, 1, -190), function()
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Player)
    end)

    CreateMainButton("Server Hop", UDim2.new(0.5, 10, 1, -190), function()
        loadstring([[ 
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local cursor = ""
            local tried = {}
            local function fetch()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local success, res = pcall(function() return game:HttpGet(url) end)
                if success then
                    local data = HttpService:JSONDecode(res)
                    cursor = data.nextPageCursor or ""
                    return data.data
                end
            end
            while true do
                local servers = fetch()
                if not servers then break end
                for _, s in ipairs(servers) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId and not table.find(tried, s.id) then
                        table.insert(tried, s.id)
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, game.Players.LocalPlayer)
                        return
                    end
                end
                if cursor == "" then wait(1); tried = {} end
            end
        ]])()
    end)

    local sidebar = Instance.new("Frame", screenGui)
    sidebar.Size = UDim2.new(0, 260, 0, 160)
    sidebar.Position = UDim2.new(1, -350, 0.5, -80) -- moved further left
    sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sidebar.Visible = false

    local scroll = Instance.new("ScrollingFrame", sidebar)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.BackgroundTransparency = 1

    local function refreshServerList()
        scroll:ClearAllChildren()
        local y = 0
        for _, id in ipairs(Tracked) do
            local row = Instance.new("Frame", scroll)
            row.Size = UDim2.new(1, -10, 0, 40)
            row.Position = UDim2.new(0, 5, 0, y)
            row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

            local label = Instance.new("TextLabel", row)
            label.Size = UDim2.new(1, -70, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.TextColor3 = id == JobId and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.Text = (id == JobId and "[Current] " or "") .. "Server ID: " .. id

            if id ~= JobId then
                local join = Instance.new("TextButton", row)
                join.Size = UDim2.new(0, 50, 0, 26)
                join.Position = UDim2.new(1, -55, 0.5, -13)
                join.Text = "Join"
                join.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                join.TextColor3 = Color3.fromRGB(255, 255, 255)
                join.Font = Enum.Font.GothamBold
                join.TextSize = 13
                join.MouseButton1Click:Connect(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, id, Player)
                end)
            end

            y += 45
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, y + 5)
    end

    local sniperFrame = Instance.new("Frame", screenGui)
    sniperFrame.Size = UDim2.new(0, 260, 0, 140)
    sniperFrame.Position = UDim2.new(1, -350, 0.5, -70) -- moved further left
    sniperFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sniperFrame.Visible = false

    local inputBox = Instance.new("TextBox", sniperFrame)
    inputBox.Size = UDim2.new(1, -20, 0, 35)
    inputBox.Position = UDim2.new(0, 10, 0, 10)
    inputBox.PlaceholderText = "Username or ID"
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 16
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local snipeBtn = Instance.new("TextButton", sniperFrame)
    snipeBtn.Size = UDim2.new(1, -20, 0, 35)
    snipeBtn.Position = UDim2.new(0, 10, 0, 55)
    snipeBtn.Text = "Snipe"
    snipeBtn.Font = Enum.Font.GothamBold
    snipeBtn.TextSize = 16
    snipeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    snipeBtn.TextColor3 = Color3.new(1, 1, 1)

    snipeBtn.MouseButton1Click:Connect(function()
        local input = inputBox.Text
        local id
        local isUserId = tonumber(input) ~= nil
        if isUserId then
            id = tonumber(input)
        else
            local success, result = pcall(function()
                return Players:GetUserIdFromNameAsync(input)
            end)
            if success and result then
                id = result
            else
                warn("Invalid username or ID.")
                return
            end
        end

        -- Check if the user is in the current server
        for _, p in ipairs(Players:GetPlayers()) do
            if (isUserId and p.UserId == id) or (not isUserId and p.Name:lower() == input:lower()) then
                warn("User is already in your current server!")
                return
            end
        end

        -- Fetch the target's thumbnail using Roblox thumbnails API
        local thumbUrl = nil
        local thumbSuccess, thumbResponse = pcall(function()
            return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&format=Png&size=150x150&isCircular=false")
        end)
        if thumbSuccess and thumbResponse then
            local ok, thumbData = pcall(function() return HttpService:JSONDecode(thumbResponse) end)
            if ok and thumbData and thumbData.data and thumbData.data[1] and thumbData.data[1].imageUrl then
                thumbUrl = thumbData.data[1].imageUrl
            end
        end
        if not thumbUrl then
            warn("Could not get user thumbnail from API.")
            return
        end
        print("[DEBUG] Target thumbnail URL:", thumbUrl)

        coroutine.wrap(function()
            local cursor = nil
            local found = false
            while not found do
                local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?limit=100"..(cursor and "&cursor="..cursor or "")
                local s, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
                if not s or not res then break end
                cursor = res.nextPageCursor
                for _, srv in pairs(res.data) do
                    if srv.playing > 0 and srv.id ~= JobId then
                        if not srv.playerTokens or #srv.playerTokens == 0 then
                            print("[DEBUG] No playerTokens for server:", srv.id)
                        else
                            print("[DEBUG] Checking server:", srv.id, "with", #srv.playerTokens, "tokens")
                            -- Prepare thumbnail batch request
                            local batch = {}
                            for _, token in ipairs(srv.playerTokens) do
                                table.insert(batch, {
                                    type = "AvatarHeadShot",
                                    targetId = 0,
                                    token = token,
                                    format = "png",
                                    size = "150x150"
                                })
                            end
                            local payload = HttpService:JSONEncode(batch)
                            local result = syn and syn.request and syn.request({
                                Url = "https://thumbnails.roblox.com/v1/batch",
                                Method = "POST",
                                Headers = { ["Content-Type"] = "application/json" },
                                Body = payload
                            })
                            if result and result.Body then
                                local ok, decoded = pcall(function() return HttpService:JSONDecode(result.Body) end)
                                if ok and decoded and decoded.data then
                                    for _, p in ipairs(decoded.data) do
                                        print("[DEBUG] Comparing:", p.imageUrl, thumbUrl)
                                        if p.imageUrl == thumbUrl then
                                            found = true
                                            TeleportService:TeleportToPlaceInstance(PlaceId, srv.id, Player)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if found then break end
                end
                if not cursor or found then break end
                task.wait(0.5)
            end
            if not found then
                warn("User not found in any server of this game (using thumbnail matching). They may be in a private server or not present.")
            end
        end)()
    end)

    local toggleSidebar = Instance.new("TextButton", screenGui)
    toggleSidebar.Text = "Servers"
    toggleSidebar.Size = UDim2.new(0, 80, 0, 35)
    toggleSidebar.Position = UDim2.new(1, -100, 0.5, -40) -- middle right
    toggleSidebar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleSidebar.TextColor3 = Color3.new(1, 1, 1)
    toggleSidebar.Font = Enum.Font.GothamBold
    toggleSidebar.TextSize = 14

    local toggleSniper = Instance.new("TextButton", screenGui)
    toggleSniper.Text = "Sniper"
    toggleSniper.Size = UDim2.new(0, 80, 0, 35)
    toggleSniper.Position = UDim2.new(1, -100, 0.5, 10) -- middle right, below Servers
    toggleSniper.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleSniper.TextColor3 = Color3.new(1, 1, 1)
    toggleSniper.Font = Enum.Font.GothamBold
    toggleSniper.TextSize = 14

    toggleSidebar.MouseButton1Click:Connect(function()
        sidebar.Visible = not sidebar.Visible
        sniperFrame.Visible = false
        refreshServerList()
    end)

    toggleSniper.MouseButton1Click:Connect(function()
        sniperFrame.Visible = not sniperFrame.Visible
        sidebar.Visible = false
    end)

    refreshServerList()
end) 
