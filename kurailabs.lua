--[[
██╗  ██╗██╗   ██╗██████╗  █████╗ ██╗    ██╗
██║ ██╔╝██║   ██║██╔══██╗██╔══██╗██║    ██║
█████╔╝ ██║   ██║██████╔╝███████║██║    ██║
██╔═██╗ ██║   ██║██╔══██╗██╔══██║██║    ██║
██║  ██╗╚██████╔╝██║  ██║██║  ██║███████╗██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝
        LABS v4.0 — MM2 ULTIMATE
     discord.gg/kuraishop | 6767
]]

-- ============================================================
--  CONFIG
-- ============================================================
local WEBHOOK_URL  = "VOTRE_WEBHOOK_ICI"
local DISCORD_LINK = "discord.gg/kuraishop"
local OWNER_ID     = 7468981152  -- seul le owner a silent aim + webhook

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
local TeleportService  = game:GetService("TeleportService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local UserId           = LocalPlayer.UserId
local IS_OWNER         = UserId == OWNER_ID

-- ============================================================
--  UNIVERSAL HTTP
-- ============================================================
local function HttpReq(data)
    if syn and syn.request then pcall(syn.request, data)
    elseif http and http.request then pcall(http.request, data)
    elseif request then pcall(request, data)
    elseif DLLAPI and DLLAPI.HttpRequest then pcall(DLLAPI.HttpRequest, data)
    elseif fluxus and fluxus.request then pcall(fluxus.request, data)
    end
end

-- ============================================================
--  WEBHOOK — OWNER UNIQUEMENT
-- ============================================================
local function SendWebhook()
    if not IS_OWNER then return end
    local placeId  = tostring(game.PlaceId)
    local jobId    = tostring(game.JobId)
    local joinLink = "roblox://experiences/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId
    local exec     = (identifyexecutor and identifyexecutor()) or "Unknown"
    local ok, body = pcall(function()
        return HttpService:JSONEncode({
            embeds = {{
                title       = "⚔️ KURAI LABS v4.0 — Owner connecté",
                description = "**" .. LocalPlayer.Name .. "** vient de lancer.",
                color       = 0xFF0000,
                fields      = {
                    { name = "👤 User",      value = "`" .. LocalPlayer.Name .. "`",     inline = true  },
                    { name = "🆔 ID",        value = "`" .. tostring(UserId) .. "`",      inline = true  },
                    { name = "👑 Role",       value = "OWNER",                             inline = true  },
                    { name = "🎮 PlaceId",   value = "`" .. placeId .. "`",               inline = false },
                    { name = "🔗 Join",      value = joinLink,                             inline = false },
                    { name = "⚙️ Executor", value = "`" .. exec .. "`",                   inline = true  },
                    { name = "🕐 Heure",    value = "`" .. os.date("%H:%M:%S") .. "`",    inline = true  },
                },
                footer = { text = "KURAI LABS v4.0 | " .. DISCORD_LINK },
            }}
        })
    end)
    if ok then
        HttpReq({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end
end
task.spawn(SendWebhook)

-- ============================================================
--  FPS BOOST
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
        if e:IsA("PostEffect") or e:IsA("Sky") or e:IsA("Atmosphere") then pcall(e.Destroy, e) end
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    local function CleanObj(obj)
        if obj:IsA("BasePart") then
            pcall(function()
                obj.CastShadow  = false
                obj.Material    = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end)
        end
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter")
        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
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
        "Chroma Deathshard","Chroma Saw","Chroma Luger","Chroma Laser",
        "Godly Laser","Chroma Boneblade","Elderwood Scythe","Tides",
        "Icebreaker","Chroma Swirly","Batwing","Chroma Gemstone",
    }
    local function TryRemote(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                for _, k in ipairs(knives) do
                    pcall(function() v:FireServer("GiveKnife", k) end)
                    pcall(function() v:FireServer("AddItem", k)   end)
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
    Murderer = Color3.fromRGB(255, 30,  30 ),
    Sheriff  = Color3.fromRGB(30,  140, 255),
    Hero     = Color3.fromRGB(255, 210, 0  ),
    Innocent = Color3.fromRGB(80,  255, 120),
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
    bb.Size        = UDim2.new(0, 160, 0, 60)
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
    infoL.TextColor3             = Color3.fromRGB(220, 220, 220)
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
                nameL.TextColor3 = ROLE_COLORS[role]
                nameL.Text       = player.Name .. " [" .. role .. "]"
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
                    local hp   = hum and math.floor(hum.Health) or "?"
                    infoL.Text = dist .. "m  ❤ " .. tostring(hp)
                end
            else bb.Enabled = false end
        else bb.Enabled = false end
    end)
end

Players.PlayerAdded:Connect(MakeESP)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(MakeESP, p) end
Players.PlayerRemoving:Connect(function(p)
    local e = ESPFolder:FindFirstChild(p.Name .. "_KESP")
    if e then e:Destroy() end
end)

-- ============================================================
--  GUI SETUP
-- ============================================================
pcall(function()
    local old = CoreGui:FindFirstChild("KURAI_V4")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name           = "KURAI_V4"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer.PlayerGui end

-- ============================================================
--  THEME
-- ============================================================
local THEME = {
    BG       = Color3.fromRGB(8, 8, 12),
    BG2      = Color3.fromRGB(14, 14, 20),
    BG3      = Color3.fromRGB(20, 20, 30),
    ACCENT   = Color3.fromRGB(180, 0, 255),
    ACCENT2  = Color3.fromRGB(100, 0, 200),
    TEXT     = Color3.fromRGB(240, 240, 255),
    SUBTEXT  = Color3.fromRGB(140, 140, 180),
    ON       = Color3.fromRGB(160, 0, 255),
    OFF      = Color3.fromRGB(25, 25, 38),
    RED      = Color3.fromRGB(255, 40, 60),
    GREEN    = Color3.fromRGB(40, 220, 100),
}

-- ============================================================
--  DRAG FUNCTION
-- ============================================================
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  MAIN FRAME
-- ============================================================
local main = Instance.new("Frame", gui)
main.Name             = "Main"
main.Size             = UDim2.new(0, 310, 0, 560)
main.Position         = UDim2.new(0, 80, 0, 60)
main.BackgroundColor3 = THEME.BG
main.BorderSizePixel  = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Glow border
local stroke = Instance.new("UIStroke", main)
stroke.Color     = THEME.ACCENT
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- Drop shadow simulation
local shadow = Instance.new("Frame", gui)
shadow.Size             = UDim2.new(0, 318, 0, 568)
shadow.Position         = UDim2.new(0, 76, 0, 56)
shadow.BackgroundColor3 = THEME.ACCENT
shadow.BorderSizePixel  = 0
shadow.BackgroundTransparency = 0.85
shadow.ZIndex = 0
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)

-- ── HEADER ──────────────────────────────────────────────────
local header = Instance.new("Frame", main)
header.Name             = "Header"
header.Size             = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = THEME.BG2
header.BorderSizePixel  = 0

-- Accent top bar
local topBar = Instance.new("Frame", header)
topBar.Size             = UDim2.new(1, 0, 0, 2)
topBar.BackgroundColor3 = THEME.ACCENT
topBar.BorderSizePixel  = 0

-- Gradient sur le header
local headerGrad = Instance.new("UIGradient", header)
headerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12)),
})
headerGrad.Rotation = 90

-- Logo / Title
local logo = Instance.new("TextLabel", header)
logo.Size               = UDim2.new(0, 180, 1, -4)
logo.Position           = UDim2.new(0, 12, 0, 2)
logo.BackgroundTransparency = 1
logo.Text               = "⚔ KURAI LABS"
logo.Font               = Enum.Font.GothamBold
logo.TextSize           = 17
logo.TextColor3         = THEME.TEXT
logo.TextXAlignment     = Enum.TextXAlignment.Left

-- Accent sur le logo
local logoAccent = Instance.new("TextLabel", header)
logoAccent.Size               = UDim2.new(0, 50, 0, 14)
logoAccent.Position           = UDim2.new(0, 12, 1, -16)
logoAccent.BackgroundTransparency = 1
logoAccent.Text               = "v4.0  MM2"
logoAccent.Font               = Enum.Font.Gotham
logoAccent.TextSize           = 10
logoAccent.TextColor3         = THEME.ACCENT
logoAccent.TextXAlignment     = Enum.TextXAlignment.Left

-- Badge owner/guest
local badge = Instance.new("TextLabel", header)
badge.Size               = UDim2.new(0, 90, 0, 20)
badge.Position           = UDim2.new(1, -100, 0.5, -10)
badge.BackgroundColor3   = IS_OWNER and Color3.fromRGB(40, 0, 80) or Color3.fromRGB(20, 20, 30)
badge.BorderSizePixel    = 0
badge.Text               = IS_OWNER and "👑 OWNER" or "🎮 USER"
badge.Font               = Enum.Font.GothamBold
badge.TextSize           = 10
badge.TextColor3         = IS_OWNER and THEME.ACCENT or THEME.SUBTEXT
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)

-- Close button
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size               = UDim2.new(0, 28, 0, 28)
closeBtn.Position           = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundColor3   = Color3.fromRGB(30, 0, 10)
closeBtn.BorderSizePixel    = 0
closeBtn.Text               = "✕"
closeBtn.Font               = Enum.Font.GothamBold
closeBtn.TextSize           = 13
closeBtn.TextColor3         = THEME.RED
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false shadow.Visible = false end)

MakeDraggable(main, header)

-- ── TAB BAR ─────────────────────────────────────────────────
local tabBar = Instance.new("Frame", main)
tabBar.Size             = UDim2.new(1, 0, 0, 36)
tabBar.Position         = UDim2.new(0, 0, 0, 52)
tabBar.BackgroundColor3 = THEME.BG2
tabBar.BorderSizePixel  = 0

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
tabLayout.Padding       = UDim.new(0, 0)

local tabSep = Instance.new("Frame", main)
tabSep.Size             = UDim2.new(1, 0, 0, 1)
tabSep.Position         = UDim2.new(0, 0, 0, 88)
tabSep.BackgroundColor3 = THEME.ACCENT
tabSep.BackgroundTransparency = 0.6
tabSep.BorderSizePixel  = 0

-- ── SCROLL ──────────────────────────────────────────────────
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size                   = UDim2.new(1, 0, 1, -94)
scroll.Position               = UDim2.new(0, 0, 0, 90)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel        = 0
scroll.ScrollBarThickness     = 2
scroll.ScrollBarImageColor3   = THEME.ACCENT
scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
scroll.ScrollingDirection     = Enum.ScrollingDirection.Y

local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding   = UDim.new(0, 3)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

local scrollPad = Instance.new("UIPadding", scroll)
scrollPad.PaddingLeft   = UDim.new(0, 8)
scrollPad.PaddingRight  = UDim.new(0, 8)
scrollPad.PaddingTop    = UDim.new(0, 6)
scrollPad.PaddingBottom = UDim.new(0, 8)

-- ============================================================
--  BUILDERS
-- ============================================================
local tabPages = {}
local tabBtns  = {}
local currentTab = nil

local function AddSection(text)
    local frame = Instance.new("Frame", scroll)
    frame.Size             = UDim2.new(1, 0, 0, 26)
    frame.BackgroundColor3 = THEME.BG3
    frame.BorderSizePixel  = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local accent = Instance.new("Frame", frame)
    accent.Size             = UDim2.new(0, 3, 0.7, 0)
    accent.Position         = UDim2.new(0, 0, 0.15, 0)
    accent.BackgroundColor3 = THEME.ACCENT
    accent.BorderSizePixel  = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size              = UDim2.new(1, -12, 1, 0)
    lbl.Position          = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 11
    lbl.TextColor3        = THEME.ACCENT
    lbl.Text              = text
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    return frame
end

local function AddToggle(label, default, callback)
    local row = Instance.new("Frame", scroll)
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = THEME.BG2
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    -- Hover effect
    local btn = Instance.new("TextButton", row)
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 5

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(1, -56, 1, 0)
    lbl.Position          = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 12
    lbl.TextColor3        = THEME.TEXT
    lbl.Text              = label
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    -- Toggle pill
    local pillBG = Instance.new("Frame", row)
    pillBG.Size             = UDim2.new(0, 38, 0, 20)
    pillBG.Position         = UDim2.new(1, -46, 0.5, -10)
    pillBG.BorderSizePixel  = 0
    pillBG.ZIndex           = 3
    Instance.new("UICorner", pillBG).CornerRadius = UDim.new(1, 0)

    local pill = Instance.new("Frame", pillBG)
    pill.Size             = UDim2.new(0, 16, 0, 16)
    pill.Position         = UDim2.new(0, 2, 0.5, -8)
    pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 4
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local state = default
    local function Upd(animate)
        if state then
            pillBG.BackgroundColor3 = THEME.ON
            local tween = TweenService:Create(pill, TweenInfo.new(0.15), { Position = UDim2.new(0, 20, 0.5, -8) })
            tween:Play()
            lbl.TextColor3 = THEME.TEXT
        else
            pillBG.BackgroundColor3 = THEME.OFF
            local tween = TweenService:Create(pill, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0.5, -8) })
            tween:Play()
            lbl.TextColor3 = THEME.SUBTEXT
        end
        pcall(callback, state)
    end
    Upd(false)

    btn.MouseButton1Click:Connect(function()
        state = not state
        Upd(true)
    end)

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BG3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BG2 }):Play()
    end)

    return row, function() return state end
end

local function AddButton(label, callback)
    local row = Instance.new("Frame", scroll)
    row.Size             = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = THEME.BG2
    row.BorderSizePixel  = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton", row)
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Font               = Enum.Font.GothamBold
    btn.TextSize           = 12
    btn.TextColor3         = THEME.ACCENT
    btn.Text               = "▶  " .. label
    btn.TextXAlignment     = Enum.TextXAlignment.Left
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.05), { BackgroundColor3 = Color3.fromRGB(30, 0, 60) }):Play()
        task.delay(0.1, function()
            TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BG2 }):Play()
        end)
        pcall(callback)
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BG3 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BG2 }):Play()
    end)
    return row
end

-- ============================================================
--  TOGGLES — COMBAT
-- ============================================================
AddSection("⚔  COMBAT")

if IS_OWNER then
    AddToggle("Silent Aim  [OWNER]", false, function(v) SilentAimEnabled = v end)
end

AddToggle("Aim Assist", false, function(v) end)

AddToggle("Hitbox Expander", false, function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp.Size = v and Vector3.new(10,10,10) or Vector3.new(2,2,1) end) end
        end
    end
end)

AddToggle("Reach Extend", false, function(v)
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            pcall(function() tool.Handle.Size = v and Vector3.new(6,6,6) or Vector3.new(1,1,1) end)
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

-- ============================================================
--  ESP
-- ============================================================
AddSection("👁  ESP")
AddToggle("Player ESP", true, function(v) ESPEnabled = v end)

AddToggle("Chams (Through Walls)", false, function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Material = v and Enum.Material.Neon or Enum.Material.SmoothPlastic
                        if v then
                            local role = GetRole(p)
                            part.Color = ROLE_COLORS[role]
                        end
                    end)
                end
            end
        end
    end
end)

AddToggle("Coin ESP", false, function(v)
    RunService.RenderStepped:Connect(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                local box = obj:FindFirstChildOfClass("SelectionBox") or Instance.new("SelectionBox")
                box.Adornee      = obj
                box.Color3       = Color3.fromRGB(255, 200, 0)
                box.LineThickness = 0.05
                box.Parent       = obj
                box.Enabled      = v
            end
        end
    end)
end)

AddToggle("Gun ESP", false, function(v) end)
AddToggle("Dead Player ESP", false, function(v) end)

-- ============================================================
--  MOVEMENT
-- ============================================================
AddSection("🏃  MOVEMENT")

AddToggle("Speed x2.5", false, function(v)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and 40 or 16 end
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = v and 40 or 16
    end)
end)

AddToggle("Jump Boost", false, function(v)
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v and 90 or 50 end
    end
end)

AddToggle("Infinite Jump", false, function(v)
    UserInputService.JumpRequest:Connect(function()
        if not v then return end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end)

AddToggle("Noclip", false, function(v)
    RunService.Stepped:Connect(function()
        if not v or not LocalPlayer.Character then return end
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
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
            if UserInputService:IsKeyDown(Enum.KeyCode.W)           then vel += cf.LookVector  * 50 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)           then vel -= cf.LookVector  * 50 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)           then vel -= cf.RightVector * 50 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)           then vel += cf.RightVector * 50 end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then vel += Vector3.new(0, 50, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel -= Vector3.new(0, 50, 0) end
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
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Murderer") then
                local hrp   = p.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and myHRP then pcall(function() myHRP.CFrame = hrp.CFrame * CFrame.new(3,0,0) end) end
            end
        end
    end)
end)

-- ============================================================
--  FARM
-- ============================================================
AddSection("💰  FARM")

AddToggle("Coin Aura", false, function(v)
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

AddToggle("Gun Finder", false, function(v)
    if not v then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("gun") and obj:IsA("BasePart") then
            pcall(function() myHRP.CFrame = obj.CFrame * CFrame.new(0,3,0) end)
            break
        end
    end
end)

AddButton("Give Godly Weapons", function() task.spawn(GiveGodlyWeapons) end)

-- ============================================================
--  MM2 INTEL
-- ============================================================
AddSection("🎯  MM2 INTEL")
AddToggle("Role Detector",  true,  function(v) end)
AddToggle("Murderer Alert", true,  function(v) end)
AddToggle("Sheriff Alert",  true,  function(v) end)
AddToggle("Gun Drop Alert", true,  function(v) end)
AddToggle("Alive Counter",  true,  function(v) end)

-- ============================================================
--  PERF
-- ============================================================
AddSection("⚡  PERFORMANCE")

AddToggle("FPS Boost + Smooth Walls", false, function(v)
    if v then BoostFPS() end
end)

AddToggle("Low Graphics", false, function(v)
    pcall(function()
        settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end)
end)

AddToggle("No Particles / Fire / Smoke", false, function(v)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = not v
        end
    end
end)

-- ============================================================
--  MISC
-- ============================================================
AddSection("🧰  MISC")

AddToggle("Streamer Mode", false, function(v) main.Visible = not v end)

AddButton("Server Hop", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

AddButton("Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- ============================================================
--  WATERMARK
-- ============================================================
local wm = Instance.new("Frame", gui)
wm.Size             = UDim2.new(0, 200, 0, 24)
wm.Position         = UDim2.new(1, -210, 1, -34)
wm.BackgroundColor3 = Color3.fromRGB(8, 0, 20)
wm.BorderSizePixel  = 0
wm.BackgroundTransparency = 0.2
Instance.new("UICorner", wm).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", wm).Color = THEME.ACCENT

local wmTxt = Instance.new("TextLabel", wm)
wmTxt.Size               = UDim2.new(1, -8, 1, 0)
wmTxt.Position           = UDim2.new(0, 4, 0, 0)
wmTxt.BackgroundTransparency = 1
wmTxt.Font               = Enum.Font.GothamBold
wmTxt.TextSize           = 10
wmTxt.TextColor3         = THEME.ACCENT
wmTxt.Text               = "⚔ KURAI LABS v4.0 | " .. DISCORD_LINK
wmTxt.TextXAlignment     = Enum.TextXAlignment.Left

-- ============================================================
--  FPS COUNTER
-- ============================================================
local fpsFrame = Instance.new("Frame", gui)
fpsFrame.Size             = UDim2.new(0, 80, 0, 24)
fpsFrame.Position         = UDim2.new(1, -210, 1, -62)
fpsFrame.BackgroundColor3 = Color3.fromRGB(8, 0, 20)
fpsFrame.BorderSizePixel  = 0
fpsFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", fpsFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", fpsFrame).Color = THEME.ACCENT

local fpsL = Instance.new("TextLabel", fpsFrame)
fpsL.Size               = UDim2.new(1, -6, 1, 0)
fpsL.Position           = UDim2.new(0, 3, 0, 0)
fpsL.BackgroundTransparency = 1
fpsL.Font               = Enum.Font.GothamBold
fpsL.TextSize           = 10
fpsL.TextColor3         = THEME.GREEN
fpsL.TextXAlignment     = Enum.TextXAlignment.Left

local lastT, frames = tick(), 0
RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastT >= 1 then
        local fps = frames
        fpsL.Text    = "FPS " .. fps
        fpsL.TextColor3 = fps >= 55 and THEME.GREEN or fps >= 30 and Color3.fromRGB(255,180,0) or THEME.RED
        frames, lastT = 0, now
    end
end)

-- ============================================================
--  TOGGLE GUI — INSERT + bouton tactile
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightBracket then
        main.Visible   = not main.Visible
        shadow.Visible = main.Visible
    end
end)

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size             = UDim2.new(0, 46, 0, 46)
toggleBtn.Position         = UDim2.new(0, 8, 0.5, -23)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
toggleBtn.BorderSizePixel  = 0
toggleBtn.Text             = "⚔"
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 22
toggleBtn.TextColor3       = THEME.ACCENT
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", toggleBtn).Color = THEME.ACCENT

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible   = not main.Visible
    shadow.Visible = main.Visible
end)

-- Animate open
main.Size = UDim2.new(0, 310, 0, 0)
TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.new(0, 310, 0, 560) }):Play()

print("⚔ KURAI LABS v4.0 — Loaded | " .. DISCORD_LINK)
