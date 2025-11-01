if game.PlaceId == 13822562292 then
    local Players        = game:GetService("Players")
    local RunService     = game:GetService("RunService")
    local ReplicatedStore= game:GetService("ReplicatedStorage")
    local Workspace      = game:GetService("Workspace")
    local UserInput      = game:GetService("UserInputService")
    local vimOk, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
    if not vimOk then VirtualInputManager = nil end
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    local Options, Toggles = Library.Options, Library.Toggles
    Library.ForceCheckbox = false
    Library.ShowToggleFrameInKeybinds = true
    local Window = Library:CreateWindow({
        Title = "Midnight Leaders",
        Footer = "version 0.1a",
        Icon = 106699849015954,
        NotifySide = "Right",
        ShowCustomCursor = false,
    })
    local Tabs = {
        Main = Window:AddTab("Main", "user"),
        ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
    }
    local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Easier playing")
    local RightGroupBox = Tabs.Main:AddRightGroupbox("Automatic playing")
    LeftGroupBox:AddToggle("AutoTuning", {
        Text = "Auto Car Tuning",
        Tooltip = "Infinite physical nitro ((YOU MUST HAVE AT LEAST LEVEL 1 TO USE!!) and it gets upgraded)",
        Default = false,
        Callback = function(Value)
            if Value then
                task.spawn(function()
                    local plr = Players.LocalPlayer
                    if not plr then return end
                    local targetName = plr.Name
                    while Toggles.AutoTuning.Value do
                        local car = Workspace:FindFirstChild(targetName .. "'s Car")
                        if car then
                            pcall(function()
                                car:SetAttribute("NitrousType", "3")
                                car:SetAttribute("BoostEnabled", true)
                            end)
                        end
                        task.wait()
                    end
                end)
            end
        end,
    })
    LeftGroupBox:AddButton({
        Text = "Remove Traffic",
        Tooltip = "Deletes all traffic",
        Func = function()
            if not getgenv().DeletedTraffic then
                if Workspace:FindFirstChild("NPCVehicles") then
                    pcall(function() Workspace.NPCVehicles:Destroy() end)
                end
                getgenv().DeletedTraffic = true
            end
        end,
    })
getgenv().hood_settings = getgenv().hood_settings or {
    OffsetX = 1,
    OffsetY = 1,
    OffsetZ = -4,
    PitchDeg = 22,
    FOV      = 120,
}
if not getgenv()._hood_ui_created then
    LeftGroupBox:AddSlider("HoodOffsetX", {
        Text = "Hood Offset X (left/right)",
        Tooltip = "",
        Min = -10, Max = 10, Default = getgenv().hood_settings.OffsetX, Precise = true,
        Callback = function(v) getgenv().hood_settings.OffsetX = tonumber(v) or getgenv().hood_settings.OffsetX end,
    })
    LeftGroupBox:AddSlider("HoodOffsetY", {
        Text = "Hood Offset Y (up/down)",
        Tooltip = "",
        Min = -10, Max = 10, Default = getgenv().hood_settings.OffsetY, Precise = true,
        Callback = function(v) getgenv().hood_settings.OffsetY = tonumber(v) or getgenv().hood_settings.OffsetY end,
    })
    LeftGroupBox:AddSlider("HoodOffsetZ", {
        Text = "Hood Offset Z (forward/backward)",
        Tooltip = "",
        Min = -20, Max = 20, Default = getgenv().hood_settings.OffsetZ, Precise = true,
        Callback = function(v) getgenv().hood_settings.OffsetZ = tonumber(v) or getgenv().hood_settings.OffsetZ end,
    })
    LeftGroupBox:AddSlider("HoodPitch", {
        Text = "Look Up/Down (degrees)",
        Tooltip = "",
        Min = -45, Max = 90, Default = getgenv().hood_settings.PitchDeg, Precise = true,
        Callback = function(v) getgenv().hood_settings.PitchDeg = tonumber(v) or getgenv().hood_settings.PitchDeg end,
    })
    LeftGroupBox:AddSlider("HoodFOV", {
        Text = "FOV",
        Tooltip = "Field of view while hood view is active.",
        Min = 30, Max = 120, Default = getgenv().hood_settings.FOV, Precise = true,
        Callback = function(v) getgenv().hood_settings.FOV = tonumber(v) or getgenv().hood_settings.FOV end,
    })
    getgenv()._hood_ui_created = true
end
LeftGroupBox:AddToggle("ForceFOV", {
    Text = "Hood view",
    Tooltip = "",
    Default = false,
    Callback = function(Value)
        getgenv().forceFOV_running = Value
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local plr = Players.LocalPlayer
        if not plr then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        if Value then
            getgenv()._prev_camtype = getgenv()._prev_camtype or cam.CameraType
            getgenv()._prev_fov     = getgenv()._prev_fov or cam.FieldOfView
        end
        if getgenv()._forceFovConnection then
            if getgenv()._forceFovConnection.Connected then
                getgenv()._forceFovConnection:Disconnect()
            end
            getgenv()._forceFovConnection = nil
        end
        if Value then
            getgenv()._forceFovConnection = RunService.RenderStepped:Connect(function()
                if not getgenv().forceFOV_running then
                    if getgenv()._forceFovConnection then
                        getgenv()._forceFovConnection:Disconnect()
                        getgenv()._forceFovConnection = nil
                    end
                    return
                end
                local char = plr.Character
                if not char then return end
                local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 0.05)
                if not head then return end
                local sx = tonumber(getgenv().hood_settings.OffsetX) or 0
                local sy = tonumber(getgenv().hood_settings.OffsetY) or 0
                local sz = tonumber(getgenv().hood_settings.OffsetZ) or 5
                local pitchDeg = tonumber(getgenv().hood_settings.PitchDeg) or 0
                local forcedFov = tonumber(getgenv().hood_settings.FOV) or 90
                pcall(function()
                    cam.FieldOfView = forcedFov
                    cam.CameraType = Enum.CameraType.Scriptable
                    local offsetCFrame = CFrame.new(sx, sy, sz)
                    local worldPos = (head.CFrame * offsetCFrame).Position
                    local rotatedCFrame = head.CFrame * CFrame.Angles(math.rad(-pitchDeg), 0, 0)
                    local lookVec = rotatedCFrame.LookVector

                    cam.CFrame = CFrame.lookAt(worldPos, worldPos + lookVec)
                end)
            end)
        else
            getgenv().forceFOV_running = false
            if getgenv()._forceFovConnection then
                getgenv()._forceFovConnection:Disconnect()
                getgenv()._forceFovConnection = nil
            end
            pcall(function()
                if cam and getgenv()._prev_fov then cam.FieldOfView = getgenv()._prev_fov end
                if cam and getgenv()._prev_camtype then cam.CameraType = getgenv()._prev_camtype end
                getgenv()._prev_fov = nil
                getgenv()._prev_camtype = nil
            end)
        end
    end,
})
    RightGroupBox:AddToggle("NitroVFX", {
        Text = "Spam Nitro VFX",
        Tooltip = "Infinite Visual Nitro",
        Default = false,
        Callback = function(Value)
            getgenv().Nitro = Value
            if Value then
                task.spawn(function()
                    local ok, Event = pcall(function() return ReplicatedStore:WaitForChild("NitrousVFX") end)
                    local car = Workspace:FindFirstChild("curvedstatisticforms's Car")
                    while getgenv().Nitro and ok and Event and car do
                        pcall(function()
                            Event:FireServer("Enable", car)
                        end)
                        task.wait()
                    end
                end)
            end
        end,
    })
    RightGroupBox:AddToggle("AutoDrive", {
        Text = "Auto-Drive",
        Tooltip = "Automatically drives for you (Presses W with VIM)",
        Default = false,
        Callback = function(Value)
            getgenv().holdW_running = Value
            local plr = Players.LocalPlayer
            if not plr then return end
            local char = plr.Character or plr.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart", 5)

            local function pressDown()
                if VirtualInputManager then
                    pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game) end)
                end
            end
            local function releaseKey()
                if VirtualInputManager then
                    pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
                end
            end

            task.spawn(function()
                while getgenv().holdW_running do
                    pressDown()
                    task.wait()
                end
                releaseKey()
            end)
        end,
    })
    if type(RightGroupBox.AddWarningBox) == "function" then
        RightGroupBox:AddWarningBox({
            Visible = true,
            Title = "Warning",
            Text = "⚠️ Please use a VIP server, that only you can access, for extra safety!"
        })
    else
        RightGroupBox:AddLabel("⚠️ Please use a VIP server, that only you can access, for extra safety!", true)
    end
    RightGroupBox:AddButton({
        Text = "Start Streaming Base",
        Tooltip = "Creates infinite parts around your character",
        Func = function()
            if getgenv().StreamingBaseActive then return end
            getgenv().StreamingBaseActive = true
            task.spawn(function()
                local lp = Players.LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                local TILE, INITIAL_RADIUS, MAX_DISTANCE = 2048, 3, 10000
                local CREATE_YIELD_EVERY = 16
                local Y, HEIGHT, MATERIAL, CAN_COLLIDE, CAST_SHADOW = 16040, 1, Enum.Material.Concrete, true, true
                local PARENT = Workspace
                local function snapToTileIndex(n) return math.floor(n / TILE + 0.5) end
                local function tileWorldX(gx) return gx * TILE end
                local function tileWorldZ(gz) return gz * TILE end
                local function createTile(gx, gz)
                    local ok, part = pcall(function()
                        local p = Instance.new("Part")
                        p.Name = ("tile_%d_%d"):format(gx, gz)
                        p.Size = Vector3.new(TILE, HEIGHT, TILE)
                        p.Anchored, p.CanCollide, p.CastShadow, p.Material = true, CAN_COLLIDE, CAST_SHADOW, MATERIAL
                        p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
                        p.Position = Vector3.new(tileWorldX(gx), Y, tileWorldZ(gz))
                        p.Parent = PARENT
                        return p
                    end)
                    if ok and part then return { part = part, gx = gx, gz = gz } end
                    return nil
                end
                local function createInitialPool(centerGX, centerGZ, radius)
                    local pool, created = {}, 0
                    for gx = centerGX - radius, centerGX + radius do
                        for gz = centerGZ - radius, centerGZ + radius do
                            local entry = createTile(gx, gz)
                            if entry then
                                table.insert(pool, entry)
                                created = created + 1
                                if created % CREATE_YIELD_EVERY == 0 then task.wait() end
                            end
                        end
                    end
                    return pool
                end
                local function createMissingTiles(state, centerGX, centerGZ)
                    local existing = {}
                    for _, e in ipairs(state.pool) do existing[e.gx .. "," .. e.gz] = true end
                    local created = 0
                    for gx = centerGX - state.RADIUS, centerGX + state.RADIUS do
                        for gz = centerGZ - state.RADIUS, centerGZ + state.RADIUS do
                            local key = gx .. "," .. gz
                            if not existing[key] then
                                local entry = createTile(gx, gz)
                                if entry then
                                    table.insert(state.pool, entry)
                                    existing[key] = true
                                    created = created + 1
                                    if created % CREATE_YIELD_EVERY == 0 then task.wait() end
                                end
                            end
                        end
                    end
                end
                local function cleanupTiles(state, px, pz)
                    for i = #state.pool, 1, -1 do
                        local entry = state.pool[i]
                        local part = entry.part
                        if not part or not part.Parent then
                            table.remove(state.pool, i)
                        else
                            if math.abs(part.Position.X - px) > MAX_DISTANCE or math.abs(part.Position.Z - pz) > MAX_DISTANCE then
                                pcall(function() part:Destroy() end)
                                table.remove(state.pool, i)
                            end
                        end
                    end
                end
                local centerGX, centerGZ = snapToTileIndex(hrp.Position.X), snapToTileIndex(hrp.Position.Z)
                getgenv().StreamingBaseState = {
                    pool = createInitialPool(centerGX, centerGZ, INITIAL_RADIUS),
                    RADIUS = INITIAL_RADIUS,
                    centerGX = centerGX,
                    centerGZ = centerGZ
                }
                getgenv().StreamingBaseState.conn = RunService.RenderStepped:Connect(function()
                    if not hrp.Parent then return end
                    local px, pz = hrp.Position.X, hrp.Position.Z
                    local newGX, newGZ = snapToTileIndex(px), snapToTileIndex(pz)
                    local state = getgenv().StreamingBaseState
                    state.centerGX, state.centerGZ = newGX, newGZ
                    createMissingTiles(state, newGX, newGZ)
                    local localGX = (px / TILE) - newGX
                    local localGZ = (pz / TILE) - newGZ
                    if math.abs(localGX) >= state.RADIUS - 1 or math.abs(localGZ) >= state.RADIUS - 1 then
                        state.RADIUS = state.RADIUS + 1
                        createMissingTiles(state, newGX, newGZ)
                    end
                    cleanupTiles(state, px, pz)
                end)
            end)
        end,
    })
    RightGroupBox:AddButton({
        Text = "Teleport To Streaming Base",
        Tooltip = "Teleports you to streaming base (locked if sitting)",
        Func = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Sit then
                warn("Cannot teleport while sitting!")
                return
            end
            local X, Y, Z = 484, 16040, -2761
            local hrpHeight = (hrp.Size and hrp.Size.Y) or 2
            local safeY = Y + hrpHeight / 2 + 0.5
            local look = hrp.CFrame.LookVector
            pcall(function()
                hrp.Anchored = false
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end)
            hrp.CFrame = CFrame.new(X, safeY, Z, look.X,0,look.Z, 0,1,0, -look.Z,0,look.X)
        end,
    })
    RightGroupBox:AddToggle("AutoCollect", {
        Text = "Auto-Collect Rewards",
        Tooltip = "Automatically collects playtime rewards",
        Default = false,
        Callback = function(Value)
            if Value then
                if getgenv().autoCollect_running then return end
                getgenv().autoCollect_running = true
                task.spawn(function()
                    local ok, Network = pcall(function()
                        return ReplicatedStore:WaitForChild("Modules"):WaitForChild("Modules"):WaitForChild("Network")
                    end)
                    if not ok or not Network then
                        warn("AutoCollect: Network path not found")
                        getgenv().autoCollect_running = false
                        return
                    end
                    local rewardRemotes = {}
                    for _, obj in ipairs(Network:GetChildren()) do
                        local name = tostring(obj.Name)
                        if obj:IsA("RemoteEvent") and name:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                            table.insert(rewardRemotes, obj)
                        end
                    end
                    if #rewardRemotes == 0 then
                        warn("AutoCollect: no matching RemoteEvents found")
                        getgenv().autoCollect_running = false
                        return
                    end
                    local timings = {2, 2, 2, 2, 2}
                    local tiers = {"Tier1","Tier2","Tier3","Tier4","Tier5"}
                    local function waitInterruptible(total)
                        local step = 0.05
                        local elapsed = 0
                        while elapsed < total do
                            if not Toggles.AutoCollect.Value then
                                return false
                            end
                            task.wait(math.min(step, total - elapsed))
                            elapsed = elapsed + step
                        end
                        return Toggles.AutoCollect.Value
                    end
                    while Toggles.AutoCollect.Value do
                        for _, remote in ipairs(rewardRemotes) do
                            if not Toggles.AutoCollect.Value then break end
                            for i, tier in ipairs(tiers) do
                                if not Toggles.AutoCollect.Value then break end
                                pcall(function() remote:FireServer(tier) end)
                                if not waitInterruptible(timings[i]) then break end
                            end
                        end
                    end
                    getgenv().autoCollect_running = false
                end)
            else
                getgenv().autoCollect_running = false
            end
        end,
    })
    do
        local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

        MenuGroup:AddToggle("ShowCustomCursor", {
            Text = "Custom Cursor",
            Default = Library.ShowCustomCursor or false,
            Callback = function(Value)
                Library.ShowCustomCursor = Value
            end,
        })
        MenuGroup:AddDropdown("NotificationSide", {
            Values = { "Left", "Right" },
            Default = "Right",
            Text = "Notification Side",
            Callback = function(Value)
                Library:SetNotifySide(Value)
            end,
        })
        MenuGroup:AddDropdown("DPIDropdown", {
            Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
            Default = "100%",
            Text = "DPI Scale",
            Callback = function(Value)
                Value = Value:gsub("%%", "")
                local DPI = tonumber(Value)
                if DPI then Library:SetDPIScale(DPI) end
            end,
        })
        MenuGroup:AddDivider()
        MenuGroup:AddLabel("Menu bind")
            :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        MenuGroup:AddButton("Unload", function()
            Library:Unload()
        end)
        if Options and Options.MenuKeybind then
            Library.ToggleKeybind = Options.MenuKeybind
        end
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
        ThemeManager:SetFolder("MidnightLeaders")
        SaveManager:SetFolder("MidnightLeaders/Game")
        SaveManager:SetSubFolder("MainPlace")
        pcall(function()
            SaveManager:BuildConfigSection(Tabs["UI Settings"])
            ThemeManager:ApplyToTab(Tabs["UI Settings"])
            SaveManager:LoadAutoloadConfig()
        end)
    end
end
