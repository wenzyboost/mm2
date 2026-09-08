--[[
  KURAI LABS v5.0 — MM2
  discord.gg/kuraishop
]]

-- ============================================================
--  CONFIG
-- ============================================================
local WEBHOOK_URL  = "VOTRE_WEBHOOK_ICI"
local DISCORD_LINK = "discord.gg/kuraishop"
local OWNER_ID     = 7468981152

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
--  HTTP
-- ============================================================
local function HttpReq(d)
    if syn and syn.request then pcall(syn.request,d)
    elseif http and http.request then pcall(http.request,d)
    elseif request then pcall(request,d)
    elseif DLLAPI and DLLAPI.HttpRequest then pcall(DLLAPI.HttpRequest,d)
    elseif fluxus and fluxus.request then pcall(fluxus.request,d)
    end
end

-- ============================================================
--  WEBHOOK — OWNER ONLY
-- ============================================================
if IS_OWNER then
    task.spawn(function()
        local pid = tostring(game.PlaceId)
        local jid = tostring(game.JobId)
        local ok,body = pcall(function()
            return HttpService:JSONEncode({embeds={{
                title="⚔️ KURAI LABS v5.0 — Owner",
                color=0xAA00FF,
                fields={
                    {name="👤 User",  value="`"..LocalPlayer.Name.."`", inline=true},
                    {name="🆔 ID",   value="`"..tostring(UserId).."`",  inline=true},
                    {name="🎮 Place",value="`"..pid.."`",                inline=false},
                    {name="🔗 Join", value="roblox://experiences/start?placeId="..pid.."&gameInstanceId="..jid, inline=false},
                },
                footer={text="KURAI LABS v5.0 | "..DISCORD_LINK}
            }}})
        end)
        if ok then HttpReq({Url=WEBHOOK_URL,Method="POST",Headers={["Content-Type"]="application/json"},Body=body}) end
    end)
end

-- ============================================================
--  UTILS
-- ============================================================
local function Tween(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function TweenBack(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function Corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function Stroke(obj, col, thick, trans)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or Color3.fromRGB(170,0,255)
    s.Thickness = thick or 1.5
    s.Transparency = trans or 0
    return s
end

-- ============================================================
--  DRAG
-- ============================================================
local function Drag(frame, handle)
    local drag, inp, st, sp = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag=true; st=i.Position; sp=frame.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then inp=i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i==inp and drag then
            local d=i.Position-st
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ============================================================
--  ESP STATE
-- ============================================================
local ESP = {
    enabled    = true,
    boxes      = false,
    tracers    = false,
    skeletons  = false,
    chams      = false,
    offscreen  = false,
}

local ROLE_COL = {
    Murderer = Color3.fromRGB(255,40,40),
    Sheriff  = Color3.fromRGB(40,140,255),
    Hero     = Color3.fromRGB(255,200,0),
    Innocent = Color3.fromRGB(60,220,100),
}

local function GetRole(p)
    local c=p.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Murderer") then return "Murderer" end
    if c:FindFirstChild("Sheriff")  then return "Sheriff"  end
    if c:FindFirstChild("Hero")     then return "Hero"     end
    return "Innocent"
end

-- ============================================================
--  COMBAT STATE
-- ============================================================
local SA_enabled = false
local function GetNearest()
    local best,dist=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local sp,on=Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local d=(Vector2.new(sp.X,sp.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                    if d<dist then dist=d; best=p end
                end
            end
        end
    end
    return best
end

if IS_OWNER then
    pcall(function()
        local Old
        Old=hookmetamethod(game,"__index",function(self,key)
            if SA_enabled and key=="Hit" and self==Mouse then
                local t=GetNearest()
                if t and t.Character then
                    local h=t.Character:FindFirstChild("Head")
                    if h then return h.CFrame end
                end
            end
            return Old(self,key)
        end)
    end)
end

-- ============================================================
--  ESP LOOP
-- ============================================================
local ESPFolder = Instance.new("Folder",Camera); ESPFolder.Name="K_ESP"

local function MakeESP(player)
    if player==LocalPlayer then return end
    local bb=Instance.new("BillboardGui")
    bb.Name=player.Name.."_K"
    bb.AlwaysOnTop=true
    bb.Size=UDim2.new(0,180,0,70)
    bb.StudsOffset=Vector3.new(0,4,0)
    bb.Parent=ESPFolder

    local nL=Instance.new("TextLabel",bb)
    nL.Size=UDim2.new(1,0,0.45,0)
    nL.BackgroundTransparency=1
    nL.Font=Enum.Font.GothamBold
    nL.TextScaled=true
    nL.TextStrokeTransparency=0
    nL.TextStrokeColor3=Color3.new(0,0,0)

    local iL=Instance.new("TextLabel",bb)
    iL.Size=UDim2.new(1,0,0.35,0)
    iL.Position=UDim2.new(0,0,0.45,0)
    iL.BackgroundTransparency=1
    iL.Font=Enum.Font.Gotham
    iL.TextScaled=true
    iL.TextColor3=Color3.fromRGB(220,220,220)
    iL.TextStrokeTransparency=0
    iL.TextStrokeColor3=Color3.new(0,0,0)

    -- Health bar
    local hbg=Instance.new("Frame",bb)
    hbg.Size=UDim2.new(0.8,0,0.12,0)
    hbg.Position=UDim2.new(0.1,0,0.82,0)
    hbg.BackgroundColor3=Color3.fromRGB(30,30,30)
    hbg.BorderSizePixel=0
    Corner(hbg,3)

    local hfill=Instance.new("Frame",hbg)
    hfill.Size=UDim2.new(1,0,1,0)
    hfill.BackgroundColor3=ROLE_COL.Innocent
    hfill.BorderSizePixel=0
    Corner(hfill,3)

    RunService.RenderStepped:Connect(function()
        if not ESP.enabled then bb.Enabled=false return end
        local char=player.Character
        if char then
            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hrp then
                bb.Adornee=hrp; bb.Enabled=true
                local role=GetRole(player)
                local col=ROLE_COL[role]
                nL.TextColor3=col
                nL.Text=player.Name.." ‹"..role.."›"
                local myH=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myH then
                    local d=math.floor((hrp.Position-myH.Position).Magnitude)
                    local hp=hum and math.floor(hum.Health) or 0
                    local maxhp=hum and math.floor(hum.MaxHealth) or 100
                    iL.Text=d.."m  ♥ "..tostring(hp)
                    local ratio=math.clamp(hp/math.max(maxhp,1),0,1)
                    Tween(hfill,0.2,{Size=UDim2.new(ratio,0,1,0)}):Play()
                    hfill.BackgroundColor3=ratio>0.6 and ROLE_COL.Innocent or ratio>0.3 and Color3.fromRGB(255,180,0) or ROLE_COL.Murderer
                end
            else bb.Enabled=false end
        else bb.Enabled=false end
    end)
end

Players.PlayerAdded:Connect(MakeESP)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(MakeESP,p) end
Players.PlayerRemoving:Connect(function(p)
    local e=ESPFolder:FindFirstChild(p.Name.."_K")
    if e then e:Destroy() end
end)

-- ============================================================
--  GUI BASE
-- ============================================================
pcall(function() local o=CoreGui:FindFirstChild("KURAI_V5") if o then o:Destroy() end end)

local gui=Instance.new("ScreenGui")
gui.Name="KURAI_V5"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CoreGui end)
if not gui.Parent then gui.Parent=LocalPlayer.PlayerGui end

-- ── Palette ──────────────────────────────────────────────────
local C = {
    bg      = Color3.fromRGB(6,6,10),
    bg2     = Color3.fromRGB(12,12,20),
    bg3     = Color3.fromRGB(18,18,30),
    acc     = Color3.fromRGB(150,0,255),
    acc2    = Color3.fromRGB(90,0,200),
    txt     = Color3.fromRGB(240,235,255),
    sub     = Color3.fromRGB(130,120,160),
    on      = Color3.fromRGB(140,0,255),
    off     = Color3.fromRGB(22,22,35),
    red     = Color3.fromRGB(255,45,60),
    grn     = Color3.fromRGB(40,210,90),
    ylw     = Color3.fromRGB(255,195,0),
}

-- ── Main window ──────────────────────────────────────────────
local win=Instance.new("Frame",gui)
win.Name="Win"
win.Size=UDim2.new(0,320,0,580)
win.Position=UDim2.new(0,80,0,50)
win.BackgroundColor3=C.bg
win.BorderSizePixel=0
win.ClipsDescendants=true
Corner(win,14)
Stroke(win,C.acc,1.5,0.2)

-- Glow behind window
local glow=Instance.new("ImageLabel",gui)
glow.Size=UDim2.new(0,400,0,660)
glow.Position=UDim2.new(0,40,0,10)
glow.BackgroundTransparency=1
glow.Image="rbxassetid://5028857472"
glow.ImageColor3=C.acc
glow.ImageTransparency=0.88
glow.ZIndex=0
glow.ScaleType=Enum.ScaleType.Stretch

-- ── Header ───────────────────────────────────────────────────
local head=Instance.new("Frame",win)
head.Size=UDim2.new(1,0,0,56)
head.BackgroundColor3=C.bg2
head.BorderSizePixel=0

-- gradient
local hgrad=Instance.new("UIGradient",head)
hgrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(28,0,55)),
    ColorSequenceKeypoint.new(1,C.bg2),
})
hgrad.Rotation=90

-- top accent line
local tLine=Instance.new("Frame",head)
tLine.Size=UDim2.new(1,0,0,2)
tLine.BackgroundColor3=C.acc
tLine.BorderSizePixel=0

-- animated accent dot
local dot=Instance.new("Frame",head)
dot.Size=UDim2.new(0,6,0,6)
dot.Position=UDim2.new(0,10,0,8)
dot.BackgroundColor3=C.acc
dot.BorderSizePixel=0
Corner(dot,3)

-- pulse dot
task.spawn(function()
    while true do
        Tween(dot,0.7,{BackgroundTransparency=0.8,Size=UDim2.new(0,4,0,4)}):Play()
        task.wait(0.7)
        Tween(dot,0.7,{BackgroundTransparency=0,Size=UDim2.new(0,6,0,6)}):Play()
        task.wait(0.7)
    end
end)

local title=Instance.new("TextLabel",head)
title.Size=UDim2.new(1,-110,0,30)
title.Position=UDim2.new(0,20,0,6)
title.BackgroundTransparency=1
title.Text="⚔  KURAI LABS"
title.Font=Enum.Font.GothamBold
title.TextSize=18
title.TextColor3=C.txt
title.TextXAlignment=Enum.TextXAlignment.Left

local sub=Instance.new("TextLabel",head)
sub.Size=UDim2.new(1,-110,0,16)
sub.Position=UDim2.new(0,20,0,34)
sub.BackgroundTransparency=1
sub.Text="v5.0  ·  MM2  ·  "..DISCORD_LINK
sub.Font=Enum.Font.Gotham
sub.TextSize=10
sub.TextColor3=C.acc
sub.TextXAlignment=Enum.TextXAlignment.Left

-- badge
local badge=Instance.new("Frame",head)
badge.Size=UDim2.new(0,80,0,22)
badge.Position=UDim2.new(1,-130,0.5,-11)
badge.BackgroundColor3=IS_OWNER and Color3.fromRGB(35,0,70) or Color3.fromRGB(18,18,30)
badge.BorderSizePixel=0
Corner(badge,6)
Stroke(badge,IS_OWNER and C.acc or C.sub,1,0)

local badgeTxt=Instance.new("TextLabel",badge)
badgeTxt.Size=UDim2.new(1,0,1,0)
badgeTxt.BackgroundTransparency=1
badgeTxt.Text=IS_OWNER and "👑 OWNER" or "🎮 USER"
badgeTxt.Font=Enum.Font.GothamBold
badgeTxt.TextSize=11
badgeTxt.TextColor3=IS_OWNER and C.acc or C.sub

-- close
local closeBtn=Instance.new("TextButton",head)
closeBtn.Size=UDim2.new(0,28,0,28)
closeBtn.Position=UDim2.new(1,-36,0.5,-14)
closeBtn.BackgroundColor3=Color3.fromRGB(28,5,10)
closeBtn.BorderSizePixel=0
closeBtn.Text="✕"
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=13
closeBtn.TextColor3=C.red
Corner(closeBtn,6)
closeBtn.MouseButton1Click:Connect(function()
    Tween(win,0.2,{Size=UDim2.new(0,320,0,0)}):Play()
    task.wait(0.22)
    win.Visible=false
    win.Size=UDim2.new(0,320,0,580)
end)

Drag(win,head)

-- ── Tab bar ──────────────────────────────────────────────────
local TABS = {"Combat","ESP","Move","Farm","Misc"}
local tabFrames = {}
local tabBtns   = {}
local activeTab = nil

local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,0,0,34)
tabBar.Position=UDim2.new(0,0,0,56)
tabBar.BackgroundColor3=C.bg2
tabBar.BorderSizePixel=0

local tabLayout=Instance.new("UIListLayout",tabBar)
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.SortOrder=Enum.SortOrder.LayoutOrder

local tabSepLine=Instance.new("Frame",win)
tabSepLine.Size=UDim2.new(1,0,0,1)
tabSepLine.Position=UDim2.new(0,0,0,90)
tabSepLine.BackgroundColor3=C.acc
tabSepLine.BackgroundTransparency=0.5
tabSepLine.BorderSizePixel=0

-- Tab content area
local tabArea=Instance.new("Frame",win)
tabArea.Size=UDim2.new(1,0,1,-92)
tabArea.Position=UDim2.new(0,0,0,92)
tabArea.BackgroundTransparency=1
tabArea.BorderSizePixel=0
tabArea.ClipsDescendants=true

local function MakeScroll()
    local sc=Instance.new("ScrollingFrame",tabArea)
    sc.Size=UDim2.new(1,0,1,0)
    sc.BackgroundTransparency=1
    sc.BorderSizePixel=0
    sc.ScrollBarThickness=2
    sc.ScrollBarImageColor3=C.acc
    sc.CanvasSize=UDim2.new(0,0,0,0)
    sc.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sc.ScrollingDirection=Enum.ScrollingDirection.Y
    sc.Visible=false

    local ly=Instance.new("UIListLayout",sc)
    ly.Padding=UDim.new(0,4)
    ly.SortOrder=Enum.SortOrder.LayoutOrder

    local pd=Instance.new("UIPadding",sc)
    pd.PaddingLeft=UDim.new(0,8)
    pd.PaddingRight=UDim.new(0,8)
    pd.PaddingTop=UDim.new(0,8)
    pd.PaddingBottom=UDim.new(0,8)
    return sc
end

for i,name in ipairs(TABS) do
    local sc=MakeScroll()
    tabFrames[name]=sc

    local tbtn=Instance.new("TextButton",tabBar)
    tbtn.Size=UDim2.new(1/#TABS,0,1,0)
    tbtn.BackgroundTransparency=1
    tbtn.BorderSizePixel=0
    tbtn.Font=Enum.Font.GothamBold
    tbtn.TextSize=11
    tbtn.TextColor3=C.sub
    tbtn.Text=name
    tabBtns[name]=tbtn

    -- underline
    local ul=Instance.new("Frame",tbtn)
    ul.Size=UDim2.new(0,0,0,2)
    ul.Position=UDim2.new(0.5,0,1,-2)
    ul.AnchorPoint=Vector2.new(0.5,0)
    ul.BackgroundColor3=C.acc
    ul.BorderSizePixel=0

    tbtn.MouseButton1Click:Connect(function()
        if activeTab then
            tabFrames[activeTab].Visible=false
            tabBtns[activeTab].TextColor3=C.sub
            local oldUl=tabBtns[activeTab]:FindFirstChildOfClass("Frame")
            if oldUl then Tween(oldUl,0.15,{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0.5,0,1,-2)}):Play() end
        end
        activeTab=name
        tabFrames[name].Visible=true
        tbtn.TextColor3=C.txt
        Tween(ul,0.2,{Size=UDim2.new(0.7,0,0,2),Position=UDim2.new(0.15,0,1,-2)}):Play()
    end)
end

-- ── Builders ─────────────────────────────────────────────────
local function AddSection(scroll, text)
    local f=Instance.new("Frame",scroll)
    f.Size=UDim2.new(1,0,0,28)
    f.BackgroundColor3=C.bg3
    f.BorderSizePixel=0
    Corner(f,7)

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(0,3,0.6,0)
    bar.Position=UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3=C.acc
    bar.BorderSizePixel=0
    Corner(bar,2)

    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-14,1,0)
    l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold
    l.TextSize=11
    l.TextColor3=C.acc
    l.Text=text
    l.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

local function AddToggle(scroll, label, default, callback)
    local row=Instance.new("Frame",scroll)
    row.Size=UDim2.new(1,0,0,38)
    row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0
    Corner(row,9)

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1
    btn.Text=""
    btn.ZIndex=5

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-56,1,0)
    lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.Text=label
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local pillBG=Instance.new("Frame",row)
    pillBG.Size=UDim2.new(0,40,0,22)
    pillBG.Position=UDim2.new(1,-48,0.5,-11)
    pillBG.BorderSizePixel=0
    pillBG.ZIndex=3
    Corner(pillBG,11)

    local pill=Instance.new("Frame",pillBG)
    pill.Size=UDim2.new(0,18,0,18)
    pill.Position=UDim2.new(0,2,0.5,-9)
    pill.BackgroundColor3=Color3.fromRGB(255,255,255)
    pill.BorderSizePixel=0
    pill.ZIndex=4
    Corner(pill,9)

    local state=default
    local function Upd()
        if state then
            pillBG.BackgroundColor3=C.on
            Tween(pill,0.18,{Position=UDim2.new(0,20,0.5,-9)}):Play()
            lbl.TextColor3=C.txt
            Tween(row,0.1,{BackgroundColor3=Color3.fromRGB(16,8,28)}):Play()
        else
            pillBG.BackgroundColor3=C.off
            Tween(pill,0.18,{Position=UDim2.new(0,2,0.5,-9)}):Play()
            lbl.TextColor3=C.sub
            Tween(row,0.1,{BackgroundColor3=C.bg2}):Play()
        end
        pcall(callback,state)
    end
    Upd()

    btn.MouseButton1Click:Connect(function()
        state=not state; Upd()
    end)
    btn.MouseEnter:Connect(function()
        if not state then Tween(row,0.1,{BackgroundColor3=C.bg3}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if not state then Tween(row,0.1,{BackgroundColor3=C.bg2}):Play() end
    end)
    return row, function() return state end
end

local function AddButton(scroll, label, callback)
    local row=Instance.new("Frame",scroll)
    row.Size=UDim2.new(1,0,0,36)
    row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0
    Corner(row,9)

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12
    btn.TextColor3=C.acc
    btn.Text="▶  "..label
    btn.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UIPadding",btn).PaddingLeft=UDim.new(0,12)

    btn.MouseButton1Click:Connect(function()
        Tween(row,0.06,{BackgroundColor3=Color3.fromRGB(28,0,55)}):Play()
        task.delay(0.15,function() Tween(row,0.12,{BackgroundColor3=C.bg2}):Play() end)
        pcall(callback)
    end)
    btn.MouseEnter:Connect(function() Tween(row,0.1,{BackgroundColor3=C.bg3}):Play() end)
    btn.MouseLeave:Connect(function() Tween(row,0.1,{BackgroundColor3=C.bg2}):Play() end)
    return row
end

local function AddSlider(scroll, label, min, max, default, callback)
    local row=Instance.new("Frame",scroll)
    row.Size=UDim2.new(1,0,0,52)
    row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0
    Corner(row,9)

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-60,0,24)
    lbl.Position=UDim2.new(0,12,0,2)
    lbl.BackgroundTransparency=1
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12
    lbl.TextColor3=C.txt
    lbl.Text=label
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local valLbl=Instance.new("TextLabel",row)
    valLbl.Size=UDim2.new(0,50,0,24)
    valLbl.Position=UDim2.new(1,-58,0,2)
    valLbl.BackgroundTransparency=1
    valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=12
    valLbl.TextColor3=C.acc
    valLbl.Text=tostring(default)
    valLbl.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-24,0,6)
    track.Position=UDim2.new(0,12,0,32)
    track.BackgroundColor3=C.bg3
    track.BorderSizePixel=0
    Corner(track,3)

    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=C.acc
    fill.BorderSizePixel=0
    Corner(fill,3)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=UDim2.new((default-min)/(max-min),−7,0.5,−7)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0
    knob.ZIndex=3
    Corner(knob,7)

    local val=default
    local sliding=false

    local function SetVal(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        val=math.floor(min+(max-min)*rel)
        fill.Size=UDim2.new(rel,0,1,0)
        knob.Position=UDim2.new(rel,−7,0.5,−7)
        valLbl.Text=tostring(val)
        pcall(callback,val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true; SetVal(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            SetVal(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
    return row
end

-- ============================================================
--  POPULATE TABS
-- ============================================================
local sc = tabFrames

-- ── COMBAT ───────────────────────────────────────────────────
AddSection(sc.Combat,"⚔  AIM & COMBAT")

if IS_OWNER then
    AddToggle(sc.Combat,"Silent Aim  [OWNER]",false,function(v) SA_enabled=v end)
end

local fovVal=120
AddToggle(sc.Combat,"FOV Circle",false,function(v)
    -- drawing api
    if not Drawing then return end
    local circle
    if v then
        circle=Drawing.new("Circle")
        circle.Radius=fovVal
        circle.Color=Color3.fromRGB(170,0,255)
        circle.Thickness=1.5
        circle.Filled=false
        circle.Visible=true
        RunService.RenderStepped:Connect(function()
            if not v then if circle then circle.Visible=false end return end
            circle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
            circle.Radius=fovVal
        end)
    end
end)

AddSlider(sc.Combat,"FOV Size",10,300,120,function(v) fovVal=v end)

AddToggle(sc.Combat,"Hitbox Expander",false,function(v)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local h=p.Character:FindFirstChild("HumanoidRootPart")
            if h then pcall(function() h.Size=v and Vector3.new(10,10,10) or Vector3.new(2,2,1) end) end
        end
    end
end)

AddToggle(sc.Combat,"Reach Extend",false,function(v)
    if LocalPlayer.Character then
        local t=LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if t and t:FindFirstChild("Handle") then
            pcall(function() t.Handle.Size=v and Vector3.new(6,6,6) or Vector3.new(1,1,1) end)
        end
    end
end)

AddToggle(sc.Combat,"Auto Stab",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        local c=LocalPlayer.Character; if not c then return end
        local t=c:FindFirstChildOfClass("Tool"); if not t then return end
        local r=t:FindFirstChildOfClass("RemoteEvent"); if not r then return end
        pcall(function() r:FireServer() end)
    end)
end)

AddToggle(sc.Combat,"Auto Throw Knife",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        local c=LocalPlayer.Character; if not c then return end
        local t=c:FindFirstChildOfClass("Tool"); if not t then return end
        local r=t:FindFirstChild("ThrowKnife") or t:FindFirstChildOfClass("RemoteEvent")
        if r then pcall(function() r:FireServer() end) end
    end)
end)

AddToggle(sc.Combat,"Kill Aura",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                local me=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and me and (hrp.Position-me.Position).Magnitude<8 then
                    local h=p.Character:FindFirstChildOfClass("Humanoid")
                    if h then pcall(function() h.Health=0 end) end
                end
            end
        end
    end)
end)

-- ── ESP ───────────────────────────────────────────────────────
AddSection(sc.ESP,"👁  ESP & VISUALS")
AddToggle(sc.ESP,"Player ESP (Name+HP+Dist)",true,function(v) ESP.enabled=v end)

AddToggle(sc.ESP,"Box ESP",false,function(v) ESP.boxes=v end)

AddToggle(sc.ESP,"Tracers",false,function(v) ESP.tracers=v end)

AddToggle(sc.ESP,"Chams (Through Walls)",false,function(v)
    ESP.chams=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            for _,part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Material=v and Enum.Material.Neon or Enum.Material.SmoothPlastic
                        if v then part.Color=ROLE_COL[GetRole(p)] end
                    end)
                end
            end
        end
    end
end)

AddToggle(sc.ESP,"Coin ESP",false,function(v)
    RunService.RenderStepped:Connect(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                local box=obj:FindFirstChildOfClass("SelectionBox") or Instance.new("SelectionBox")
                box.Adornee=obj; box.Color3=C.ylw; box.LineThickness=0.05; box.Parent=obj; box.Enabled=v
            end
        end
    end)
end)

AddToggle(sc.ESP,"Gun ESP",false,function(v) end)
AddToggle(sc.ESP,"Dead Player ESP",false,function(v) end)
AddToggle(sc.ESP,"Off-Screen Arrows",false,function(v) end)

-- ── MOVEMENT ─────────────────────────────────────────────────
AddSection(sc.Move,"🏃  MOVEMENT")

local speedVal=40
AddToggle(sc.Move,"Speed Hack",false,function(v)
    if LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=v and speedVal or 16 end
    end
    LocalPlayer.CharacterAdded:Connect(function(c)
        local h=c:WaitForChild("Humanoid")
        h.WalkSpeed=v and speedVal or 16
    end)
end)
AddSlider(sc.Move,"Speed Value",16,200,40,function(v) speedVal=v end)

AddToggle(sc.Move,"Jump Boost",false,function(v)
    if LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower=v and 90 or 50 end
    end
end)

AddToggle(sc.Move,"Infinite Jump",false,function(v)
    UserInputService.JumpRequest:Connect(function()
        if not v then return end
        local c=LocalPlayer.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

AddToggle(sc.Move,"Noclip",false,function(v)
    RunService.Stepped:Connect(function()
        if not v or not LocalPlayer.Character then return end
        for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end
        end
    end)
end)

AddToggle(sc.Move,"Fly  (WASD+Space/Ctrl)",false,function(v)
    local c=LocalPlayer.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if v then
        local bv=Instance.new("BodyVelocity",hrp)
        bv.Name="KFly"; bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5)
        local hum=c:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=true end
        RunService.RenderStepped:Connect(function()
            if not v then return end
            local cf=Camera.CFrame; local vel=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel+=cf.LookVector*55 end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel-=cf.LookVector*55 end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel-=cf.RightVector*55 end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel+=cf.RightVector*55 end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel+=Vector3.new(0,55,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel-=Vector3.new(0,55,0) end
            bv.Velocity=vel
        end)
    else
        local bv=hrp:FindFirstChild("KFly"); if bv then bv:Destroy() end
        local hum=c:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
    end
end)

AddToggle(sc.Move,"Teleport to Murderer",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Murderer") then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                local me=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and me then pcall(function() me.CFrame=hrp.CFrame*CFrame.new(3,0,0) end) end
            end
        end
    end)
end)

AddToggle(sc.Move,"Bunny Hop",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v or not LocalPlayer.Character then return end
        local hum=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState()==Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- ── FARM ─────────────────────────────────────────────────────
AddSection(sc.Farm,"💰  FARM")

AddToggle(sc.Farm,"Coin Aura (Auto Collect)",false,function(v)
    RunService.Heartbeat:Connect(function()
        if not v then return end
        local me=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not me then return end
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                if (obj.Position-me.Position).Magnitude<80 then
                    pcall(function() obj.CFrame=me.CFrame end)
                end
            end
        end
    end)
end)

AddToggle(sc.Farm,"Auto Farm Loop",false,function(v)
    task.spawn(function()
        while v do
            local me=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if me then
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if not v then break end
                    if (obj.Name:lower():find("coin") or obj.Name:lower():find("item")) and obj:IsA("BasePart") then
                        pcall(function() me.CFrame=obj.CFrame end)
                        task.wait(0.05)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

AddButton(sc.Farm,"Gun Finder + TP",function()
    local me=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not me then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("gun") and obj:IsA("BasePart") then
            pcall(function() me.CFrame=obj.CFrame*CFrame.new(0,3,0) end); break
        end
    end
end)

AddButton(sc.Farm,"Give Godly Weapons",function()
    local rs=game:GetService("ReplicatedStorage")
    local knives={"Chroma Deathshard","Chroma Saw","Chroma Luger","Chroma Laser","Godly Laser","Chroma Boneblade","Elderwood Scythe","Tides","Icebreaker","Chroma Swirly","Batwing","Chroma Gemstone"}
    local function Try(parent)
        for _,v in ipairs(parent:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                for _,k in ipairs(knives) do
                    pcall(function() v:FireServer("GiveKnife",k) end)
                    pcall(function() v:FireServer("AddItem",k) end)
                    pcall(function() v:FireServer(k) end)
                end
            end
        end
    end
    pcall(Try,rs); pcall(Try,workspace)
end)

-- ── MISC ─────────────────────────────────────────────────────
AddSection(sc.Misc,"🧰  MISC & PERF")

AddToggle(sc.Misc,"FPS Boost + Smooth Walls",false,function(v)
    if not v then return end
    Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.FogStart=9e9
    Lighting.Brightness=1; Lighting.ShadowSoftness=0
    Lighting.Ambient=Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    for _,e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Sky") or e:IsA("Atmosphere") then pcall(e.Destroy,e) end
    end
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    local function Cl(obj)
        if obj:IsA("BasePart") then pcall(function() obj.CastShadow=false; obj.Material=Enum.Material.SmoothPlastic; obj.Reflectance=0 end) end
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then pcall(obj.Destroy,obj) end
    end
    for _,o in ipairs(workspace:GetDescendants()) do Cl(o) end
    workspace.DescendantAdded:Connect(function(o) task.defer(Cl,o) end)
end)

AddToggle(sc.Misc,"Low Graphics",false,function(v)
    pcall(function() settings().Rendering.QualityLevel=v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
end)

AddToggle(sc.Misc,"No Particles / Fire",false,function(v)
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ParticleEmitter") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=not v end
    end
end)

AddToggle(sc.Misc,"Streamer Mode",false,function(v) win.Visible=not v end)

AddButton(sc.Misc,"Server Hop",function()
    TeleportService:Teleport(game.PlaceId,LocalPlayer)
end)

AddButton(sc.Misc,"Rejoin",function()
    TeleportService:Teleport(game.PlaceId,LocalPlayer)
end)

-- ============================================================
--  ACTIVATE DEFAULT TAB
-- ============================================================
tabBtns["Combat"]:MouseButton1Click()  -- déclenche l'onglet Combat

-- ============================================================
--  NOTIFICATIONS
-- ============================================================
local notifQueue={}
local notifRunning=false

local function Notify(title, text, col)
    col=col or C.acc
    local nf=Instance.new("Frame",gui)
    nf.Size=UDim2.new(0,260,0,60)
    nf.Position=UDim2.new(1,10,1,-80)
    nf.BackgroundColor3=C.bg2
    nf.BorderSizePixel=0
    nf.ZIndex=20
    Corner(nf,10)
    Stroke(nf,col,1.5,0)

    local bar=Instance.new("Frame",nf)
    bar.Size=UDim2.new(0,3,1,-10)
    bar.Position=UDim2.new(0,0,0,5)
    bar.BackgroundColor3=col
    bar.BorderSizePixel=0
    Corner(bar,2)

    local t1=Instance.new("TextLabel",nf)
    t1.Size=UDim2.new(1,-14,0,22)
    t1.Position=UDim2.new(0,10,0,4)
    t1.BackgroundTransparency=1
    t1.Font=Enum.Font.GothamBold
    t1.TextSize=12
    t1.TextColor3=C.txt
    t1.Text=title
    t1.TextXAlignment=Enum.TextXAlignment.Left

    local t2=Instance.new("TextLabel",nf)
    t2.Size=UDim2.new(1,-14,0,18)
    t2.Position=UDim2.new(0,10,0,26)
    t2.BackgroundTransparency=1
    t2.Font=Enum.Font.Gotham
    t2.TextSize=11
    t2.TextColor3=C.sub
    t2.Text=text
    t2.TextXAlignment=Enum.TextXAlignment.Left

    -- slide in
    Tween(nf,0.3,{Position=UDim2.new(1,-270,1,-80)}):Play()
    task.delay(3,function()
        Tween(nf,0.3,{Position=UDim2.new(1,10,1,-80)}):Play()
        task.delay(0.35,function() nf:Destroy() end)
    end)
end

-- notif de bienvenue
task.delay(0.5,function()
    Notify("KURAI LABS v5.0","Loaded — "..LocalPlayer.Name,IS_OWNER and C.acc or C.grn)
end)

-- ============================================================
--  WATERMARK + FPS
-- ============================================================
local wmBar=Instance.new("Frame",gui)
wmBar.Size=UDim2.new(0,240,0,26)
wmBar.Position=UDim2.new(1,-250,1,-36)
wmBar.BackgroundColor3=C.bg
wmBar.BackgroundTransparency=0.15
wmBar.BorderSizePixel=0
Corner(wmBar,7)
Stroke(wmBar,C.acc,1,0.3)

local wmTxt=Instance.new("TextLabel",wmBar)
wmTxt.Size=UDim2.new(0.65,0,1,0)
wmTxt.Position=UDim2.new(0,8,0,0)
wmTxt.BackgroundTransparency=1
wmTxt.Font=Enum.Font.GothamBold
wmTxt.TextSize=10
wmTxt.TextColor3=C.acc
wmTxt.Text="⚔ KURAI LABS v5.0"
wmTxt.TextXAlignment=Enum.TextXAlignment.Left

local fpsLabel=Instance.new("TextLabel",wmBar)
fpsLabel.Size=UDim2.new(0.35,0,1,0)
fpsLabel.Position=UDim2.new(0.65,0,0,0)
fpsLabel.BackgroundTransparency=1
fpsLabel.Font=Enum.Font.GothamBold
fpsLabel.TextSize=10
fpsLabel.TextColor3=C.grn
fpsLabel.TextXAlignment=Enum.TextXAlignment.Right
Instance.new("UIPadding",fpsLabel).PaddingRight=UDim.new(0,6)

local lt,fr=tick(),0
RunService.RenderStepped:Connect(function()
    fr+=1
    local now=tick()
    if now-lt>=1 then
        fpsLabel.Text="FPS "..fr
        fpsLabel.TextColor3=fr>=55 and C.grn or fr>=30 and C.ylw or C.red
        fr,lt=0,now
    end
end)

-- ============================================================
--  TOGGLE BUTTON
-- ============================================================
local tBtn=Instance.new("TextButton",gui)
tBtn.Size=UDim2.new(0,48,0,48)
tBtn.Position=UDim2.new(0,6,0.5,-24)
tBtn.BackgroundColor3=Color3.fromRGB(15,0,30)
tBtn.BorderSizePixel=0
tBtn.Text="⚔"
tBtn.Font=Enum.Font.GothamBold
tBtn.TextSize=22
tBtn.TextColor3=C.acc
Corner(tBtn,10)
Stroke(tBtn,C.acc,1.5,0)

tBtn.MouseButton1Click:Connect(function()
    if win.Visible then
        Tween(win,0.2,{Size=UDim2.new(0,320,0,0)}):Play()
        task.delay(0.22,function() win.Visible=false; win.Size=UDim2.new(0,320,0,580) end)
    else
        win.Visible=true
        win.Size=UDim2.new(0,320,0,0)
        TweenBack(win,0.3,{Size=UDim2.new(0,320,0,580)}):Play()
    end
end)

UserInputService.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.Insert or i.KeyCode==Enum.KeyCode.RightBracket then
        tBtn.MouseButton1Click:Fire()
    end
end)

-- open animation
win.Size=UDim2.new(0,320,0,0)
TweenBack(win,0.4,{Size=UDim2.new(0,320,0,580)}):Play()

print("⚔ KURAI LABS v5.0 loaded | "..DISCORD_LINK)
