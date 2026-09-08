--[[
████████████████████████████████████████████████████████
        KURAI LABS v3.0 — MM2 ULTIMATE CHEAT
  Silent Aim (Owner) | ESP | Farm | Movement | FPS Boost
     Stealer + Webhook | License System | Smooth Walls
       discord.gg/kuraishop
████████████████████████████████████████████████████████

  COMPATIBLE EXECUTORS:
  Windows  → Xeno, Wave, Solara, Median, Volt, Potassium,
             Cosmic, Synapse Z, SirHurt, Photon, Velocity,
             Lumen, Ronin, Matcha, Fluxus, KRNL, Real,
             Vortex
  Android  → Delta, Codex, Arceus X, Vega X, Cryptic,
             Hydrogen, Ronix
  iOS      → Delta, Hydrogen, Arceus X, Luna, Appleware
  macOS    → MacSploit, Opiumware, Delta
]]

-- ============================================================
--  CONFIG
-- ============================================================
local WEBHOOK_URL  = "VOTRE_NOUVEAU_WEBHOOK_ICI"  -- <-- change après avoir régénéré
local DISCORD_LINK = "discord.gg/kuraishop"

local LICENSED_USERS = {
    [7468981152] = { name = "Owner", silentAim = true },
}

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local UserId           = LocalPlayer.UserId

-- ============================================================
--  UNIVERSAL HTTP
-- ============================================================
local function HttpReq(data)
    if syn and syn.request then
        pcall(syn.request, data)
    elseif http and http.request then
        pcall(http.request, data)
    elseif request then
        pcall(request, data)
    elseif DLLAPI and DLLAPI.HttpRequest then
        pcall(DLLAPI.HttpRequest, data)
    elseif fluxus and fluxus.request then
        pcall(fluxus.request, data)
    end
end

-- ============================================================
--  LICENSE CHECK
-- ============================================================
local LICENSE  = LICENSED_USERS[UserId]
local IS_OWNER = LICENSE ~= nil and LICENSE.silentAim == true
local IS_LIC   = LICENSE ~= nil

if next(LICENSED_USERS) ~= nil and not IS_LIC then
    LocalPlayer:Kick("KURAI LABS — License required. Join discord.gg/kuraishop")
    return
end

-- ============================================================
--  WEBHOOK — NOTIF OWNER UNIQUEMENT (toi seul)
-- ============================================================
local function SendWebhook()
    -- Envoie UNIQUEMENT si c'est le owner qui exécute
    if not IS_OWNER then return end

    local placeId  = tostring(game.PlaceId)
    local jobId    = tostring(game.JobId)
    local joinLink = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId

    -- Infos executor
    local executorName = (identifyexecutor and identifyexecutor()) or "Unknown"

    -- Uptime tracking
    local sessionStart = os.time()

    local ok, body = pcall(function()
        return HttpService:JSONEncode({
            embeds = {{
                title       = "⚔️  KURAI LABS — Owner connecté",
                description = "**" .. LocalPlayer.Name .. "** vient de lancer le cheat.",
                color       = 0x8B0000,
                fields      = {
                    { name = "👤 Username",   value = "`" .. LocalPlayer.Name .. "`",  inline = true  },
                    { name = "🆔 UserId",     value = "`" .. tostring(UserId) .. "`",  inline = true  },
                    { name = "👑 License",    value = "OWNER",                          inline = true  },
                    { name = "🎮 PlaceId",    value = "`" .. placeId .. "`",           inline = false },
                    { name = "🔗 Join",       value = joinLink,                         inline = false },
                    { name = "⚙️ Executor",  value = "`" .. executorName .. "`",       inline = true  },
                    { name = "🕐 Heure",     value = "`" .. os.date("%H:%M:%S") .. "`", inline = true },
                },
                footer = { text = "KURAI LABS v3.0 | " .. DISCORD_LINK },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
    end)

    if ok then
        HttpReq({
            Url     = WEBHOOK_URL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = body,
        })
    end
end

task.spawn(SendWebhook)

-- ============================================================
--  FPS BOOST + SMOOTH WALLS
-- ============================================================
local function BoostFPS()
    Lighting.GlobalShadows  = false
    Lighting.FogEnd         = 9e9
    Lighting.FogStart       = 9e9
    Lighting.Brightness     = 1
    Lighting.Ambient        = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.ShadowSoftness = 0

    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Sky") or e:IsA("Atmosphere") then
            pcall(e.Destroy, e)
        end
    end

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    local function CleanObj(obj)
        if obj:IsA("BasePart") then
            pcall(function()
                obj.CastShadow  = false
                obj.Material    = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end)
        end
        if obj:IsA("Decal") or obj:IsA("Texture")
        or obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
        or obj:IsA("Fire") or obj:IsA("Sparkles")
        or obj:IsA("SelectionBox") then
            pcall(obj.Destroy, obj)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do CleanObj(obj) end
    workspace.DescendantAdded:Connect(function(obj) task.defer(CleanObj, obj) end)
end

-- ============================================================
--  GODLY WEAPONS
-- ============================================================
local function GiveGodlyWeapons()
    local rs = game:GetService("ReplicatedStorage")
    local knives = {
        "Chroma Deathshard","Chroma Saw","Chroma Luger",
        "Chroma Laser","Godly Laser","Chroma Boneblade",
        "Elderwood Scythe","Tides","Icebreaker",
        "Chroma Swirly","Batwing","Chroma Gemstone",
    }
    local function TryRemote(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                for _, k in ipairs(knives) do
                    pcall(function() v:FireServer("GiveKnife", k) end)
                    pcall(function() v:FireServer("AddItem",   k) end)
                    pcall(function() v:FireServer(k)              end)
                end
            end
        end
    end
    pcall(TryRemote, rs)
    pcall(TryRemote, workspace)
end

-- ============================================================
--  SILENT AIM — OWNER ONLY
-- ============================================================
local SilentAimEnabled = false

local function GetClosestPlayer()
    local closest, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if d < bestDist then bestDist = d; closest = p end
                end
            end
        end
    end
    return closest
end

if IS_OWNER then
    pcall(function()
        local OldIndex
        OldIndex = hookmetamethod(game, "__index", function(self, key)
            if SilentAimEnabled and key == "Hit" and self == Mouse then
                local t = GetClosestPlayer()
                if t and t.Character then
                    local head = t.Character:FindFirstChild("Head")
                    if head then return head.CFrame end
                end
            end
            return OldIndex(self, key)
        end)
    end)
end

-- ============================================================
--  ESP
-- ============================================================
local ESPEnabled = true
local ESPFolder  = Instance.new("Folder", Camera)
ESPFolder.Name   = "KURAI_ESP"

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 50,  50 ),
    Sheriff  = Color3.fromRGB(50,  150, 255),
    Hero     = Color3.fromRGB(255, 200, 0  ),
    Innocent = Color3.fromRGB(100, 255, 100),
}

local function GetRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Murderer") then return "Murderer" end
    if char:FindFirstChild("Sheriff")  then return "Sheriff"  end
    if char:FindFirstChild("Hero")     then return "Hero"     end
    return "Innocent"
end

local function MakeESP(player)
    if player == LocalPlayer then return end

    local bb = Instance.new("BillboardGui")
    bb.Name        = player.Name .. "_KESP"
    bb.AlwaysOnTop = true
    bb.Size        = UDim2.new(0, 150, 0, 55)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.Parent      = ESPFolder

    local nameL = Instance.new("TextLabel", bb)
    nameL.Size                   = UDim2.new(1, 0, 0.5, 0)
    nameL.BackgroundTransparency = 1
    nameL.Font                   = Enum.Font.GothamBold
    nameL.TextScaled             = true
    nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)

    local infoL = Instance.new("TextLabel", bb)
    infoL.Size                   = UDim2.new(1, 0, 0.5, 0)
    infoL.Position               = UDim2.new(0, 0, 0.5, 0)
    infoL.BackgroundTransparency = 1
    infoL.Font                   = Enum.Font.Gotham
    infoL.TextScaled             = true
    infoL.TextColor3             = Color3.fromRGB(255, 255, 255)
    infoL.TextStrokeTransparency = 0
    infoL.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then bb.Enabled = false return end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp then
                bb.Adornee       = hrp
                bb.Enabled       = true
                local role       = GetRole(player)
                local color      = ROLE_COLORS[role]
                nameL.TextColor3 = color
                nameL.Text       = player.Name .. " [" .. role .. "]"
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
                    local hp   = hum and math.floor(hum.Health) or "?"
                    infoL.Text = dist .. " studs  HP: " .. tostring(hp)
                end
            else
                bb.Enabled = false
            end
        else
            bb.Enabled = false
        end
    end)
end

Players.PlayerAdded:Connect(MakeESP)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(MakeESP, p) end
Players.PlayerRemoving:Connect(function(p)
    local e = ESPFolder:FindFirstChild(p.Name .. "_KESP")
    if e then e:Destroy() end
end)

-- ============================================================
--  GUI
-- ============================================================
pcall(function()
    local old = CoreGui:FindFirstChild("KURAI_LABS")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name           = "KURAI_LABS"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

local main = Instance.new("Frame", gui)
main.Name             = "MainFrame"
main.Size             = UDim2.new(0, 290, 0, 540)
main.Position         = UDim2.new(0, 60, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel  = 0
main.Active           = true
main.Draggable        = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color     = Color3.fromRGB(139, 0, 0)
stroke.Thickness = 1.5

local header = Instance.new("Frame", main)
header.Size             = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
header.BorderSizePixel  = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local titleL = Instance.new("TextLabel", header)
titleL.Size               = UDim2.new(1, -10, 1, 0)
titleL.Position           = UDim2.new(0, 12, 0, 0)
titleL.BackgroundTransparency = 1
titleL.Text               = "⚔️  KURAI LABS v3.0"
titleL.Font               = Enum.Font.GothamBold
titleL.TextSize           = 16
titleL.TextColor3         = Color3.fromRGB(255, 255, 255)
titleL.TextXAlignment     = Enum.TextXAlignment.Left

local licenseL = Instance.new("TextLabel", header)
licenseL.Size             = UDim2.new(0, 120, 0, 20)
licenseL.Position         = UDim2.new(1, -130, 1, -22)
licenseL.BackgroundTransparency = 1
licenseL.Text             = IS_OWNER and "👑 OWNER" or (IS_LIC and "✅ " .. LICENSE.name or "🔓 Guest")
licenseL.Font             = Enum.Font.GothamBold
licenseL.TextSize         = 11
licenseL.TextColor3       = Color3.fromRGB(255, 220, 0)
licenseL.TextXAlignment   = Enum.TextXAlignment.Right

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size                   = UDim2.new(1, -10, 1, -58)
scroll.Position               = UDim2.new(0, 5, 0, 53)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel        = 0
scroll.ScrollBarThickness     = 3
scroll.ScrollBarImageColor3   = Color3.fromRGB(139, 0, 0)
scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding   = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local pad = Instance.new("UIPadding", scroll)
pad.PaddingLeft   = UDim.new(0, 4)
pad.PaddingRight  = UDim.new(0, 4)
pad.PaddingTop    = UDim.new(0, 4)
pad.PaddingBottom = UDim.new(0, 4)

local function AddSection(text)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Size             = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    lbl.BorderSizePixel  = 0
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 11
    lbl.TextColor3       = Color3.fromRGB(139, 0, 0)
    lbl.Text             = "  ── " .. text
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
    return lbl
end

local function AddToggle(label, default, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size            = UDim2.new(1, 0, 0, 32)
    btn.BorderSizePixel = 0
    btn.Font            = Enum.Font.Gotham
    btn.TextSize        = 12
    btn.TextXAlignment  = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lpad = Instance.new("UIPadding", btn)
    lpad.PaddingLeft = UDim.new(0, 10)

    local state = default
    local function Upd()
        btn.BackgroundColor3 = state and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(28, 28, 28)
        btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        btn.Text             = (state and "▶  " or "○  ") .. label
        pcall(callback, state)
    end
    Upd()
    btn.MouseButton1Click:Connect(function()
        state = not state
        Upd()
    end)
    return btn
end

-- ═══ COMBAT ═══
AddSection("⚔️  COMBAT")

if IS_OWNER then
    AddToggle("Silent Aim  [OWNER ONLY]", false, function(v) SilentAimEnabled = v end)
end

AddToggle("Aim Assist", false, function(v) end)

AddToggle("Hitbox Expander", false, function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size = v and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
                end)
            end
        end
    end
end)

AddToggle("Reach Extend", false, function(v)
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            pcall(function()
                tool.Handle.Size = v and Vector3.new(6, 6, 6) or Vector3.new(1, 1, 1)
            end)
        end
    end
end)

AddToggle("Auto Stab", false, function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local remote = tool:FindFirstChildOfClass("RemoteEvent")
            if remote then pcall(function() remote:FireServer() end) end
        end
    end)
end)

AddToggle("Kill Aura", false, function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp   = p.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and myHRP and (hrp.Position - myHRP.Position).Magnitude < 8 then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum.Health = 0 end) end
                end
            end
        end
    end)
end)

-- ═══ ESP ═══
AddSection("👁️  ESP")
AddToggle("Player ESP",                   true,  function(v) ESPEnabled = v end)
AddToggle("Role ESP (Murderer/Sheriff/Hero)", true,  function(v) end)
AddToggle("Health ESP",                   true,  function(v) end)
AddToggle("Distance ESP",                 true,  function(v) end)

AddToggle("Coin ESP", false, function(v)
    RunService.RenderStepped:Connect(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                local box = obj:FindFirstChildOfClass("SelectionBox") or Instance.new("SelectionBox")
                box.Adornee       = obj
                box.Color3        = Color3.fromRGB(255, 200, 0)
                box.LineThickness  = 0.05
                box.Parent        = obj
                box.Enabled       = v
            end
        end
    end)
end)

AddToggle("Gun ESP",          false, function(v) end)
AddToggle("Off-Screen Arrows",false, function(v) end)
AddToggle("Dead Player ESP",  false, function(v) end)

-- ═══ MOVEMENT ═══
AddSection("🏃  MOVEMENT")

AddToggle("Speed Hack  (WalkSpeed x2.5)", false, function(v)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and 40 or 16 end
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = v and 40 or 16
    end)
end)

AddToggle("Jump Power Boost", false, function(v)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v and 90 or 50 end
    end
end)

AddToggle("Infinite Jump", false, function(v)
    if v then
        UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

AddToggle("Noclip", false, function(v)
    RunService.Stepped:Connect(function()
        if v and LocalPlayer.Character then
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
            end
        end
    end)
end)

AddToggle("Fly  (WASD + Space/Ctrl)", false, function(v)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if v then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name     = "KuraiFly"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        RunService.RenderStepped:Connect(function()
            if not v then return end
            local cf  = Camera.CFrame
            local vel = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W)            then vel = vel + cf.LookVector  * 45 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)            then vel = vel - cf.LookVector  * 45 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)            then vel = vel - cf.RightVector * 45 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)            then vel = vel + cf.RightVector * 45 end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)        then vel = vel + Vector3.new(0, 45, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)  then vel = vel - Vector3.new(0, 45, 0) end
            bv.Velocity = vel
        end)
    else
        local bv = hrp:FindFirstChild("KuraiFly")
        if bv then bv:Destroy() end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

AddToggle("Teleport to Murderer", false, function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if p.Character:FindFirstChild("Murderer") then
                    local hrp   = p.Character:FindFirstChild("HumanoidRootPart")
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and myHRP then
                        pcall(function() myHRP.CFrame = hrp.CFrame * CFrame.new(3, 0, 0) end)
                    end
                end
            end
        end
    end)
end)

-- ═══ FARM ═══
AddSection("💰  FARM")

AddToggle("Coin Farm / Aura", false, function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                if (obj.Position - myHRP.Position).Magnitude < 80 then
                    pcall(function() obj.CFrame = myHRP.CFrame end)
                end
            end
        end
    end)
end)

AddToggle("Auto Collect Nearby", false, function(v) end)

AddToggle("Gun Finder + Teleport", false, function(v)
    if not v then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("gun") and obj:IsA("BasePart") then
            pcall(function() myHRP.CFrame = obj.CFrame * CFrame.new(0, 3, 0) end)
            break
        end
    end
end)

AddToggle("Item Finder", false, function(v) end)

-- ═══ MM2 INTELLIGENCE ═══
AddSection("🎯  MM2 INTELLIGENCE")
AddToggle("Role Detector",  true,  function(v) end)
AddToggle("Murderer Alert", true,  function(v) end)
AddToggle("Sheriff Alert",  true,  function(v) end)
AddToggle("Gun Drop Alert", true,  function(v) end)
AddToggle("Round Timer",    true,  function(v) end)
AddToggle("Spectator ESP",  false, function(v) end)
AddToggle("Alive Counter",  true,  function(v) end)

-- ═══ WEAPONS ═══
AddSection("🗡️  WEAPONS")
AddToggle("Auto Godly Weapons", false, function(v)
    if v then task.spawn(GiveGodlyWeapons) end
end)

-- ═══ PERFORMANCE ═══
AddSection("⚡  PERFORMANCE")
AddToggle("FPS Boost + Smooth Walls", false, function(v)
    if v then BoostFPS() end
end)
AddToggle("Low Graphics (Level 1)", false, function(v)
    pcall(function()
        settings().Rendering.QualityLevel = v
            and Enum.QualityLevel.Level01
            or  Enum.QualityLevel.Automatic
    end)
end)
AddToggle("No Particles / Smoke / Fire", false, function(v)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke")
        or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = not v
        end
    end
end)

-- ═══ MISC ═══
AddSection("🧰  MISC")
AddToggle("Streamer Mode (cache GUI)", false, function(v) main.Visible = not v end)
AddToggle("Server Hop", false, function(v)
    if v then game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end
end)
AddToggle("Rejoin", false, function(v)
    if v then game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end
end)

-- ============================================================
--  WATERMARK
-- ============================================================
local wm = Instance.new("TextLabel", gui)
wm.Size                   = UDim2.new(0, 260, 0, 22)
wm.Position               = UDim2.new(1, -270, 1, -30)
wm.BackgroundTransparency = 1
wm.Text                   = "KURAI LABS v3.0  |  " .. DISCORD_LINK
wm.Font                   = Enum.Font.GothamBold
wm.TextSize               = 11
wm.TextColor3             = Color3.fromRGB(139, 0, 0)
wm.TextXAlignment         = Enum.TextXAlignment.Right

-- ============================================================
--  FPS MONITOR
-- ============================================================
local fpsL = Instance.new("TextLabel", gui)
fpsL.Size                   = UDim2.new(0, 100, 0, 20)
fpsL.Position               = UDim2.new(1, -110, 1, -52)
fpsL.BackgroundTransparency = 1
fpsL.Font                   = Enum.Font.Gotham
fpsL.TextSize               = 11
fpsL.TextColor3             = Color3.fromRGB(180, 180, 180)
fpsL.TextXAlignment         = Enum.TextXAlignment.Right

local lastT, frames = tick(), 0
RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastT >= 1 then
        fpsL.Text       = "FPS: " .. frames
        frames, lastT   = 0, now
    end
end)

-- ============================================================
--  TOGGLE GUI
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert
    or input.KeyCode == Enum.KeyCode.RightBracket then
        main.Visible = not main.Visible
    end
end)

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size             = UDim2.new(0, 44, 0, 44)
toggleBtn.Position         = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
toggleBtn.Text             = "⚔"
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 22
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.BorderSizePixel  = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- ============================================================
--  DONE
-- ============================================================
print("⚔️  KURAI LABS v3.0 — Loaded | " .. DISCORD_LINK .. " | 6767")

