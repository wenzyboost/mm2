--[[
    ██╗  ██╗██╗   ██╗██████╗  █████╗ ██╗
    ██║ ██╔╝██║   ██║██╔══██╗██╔══██╗██║
    █████╔╝ ██║   ██║██████╔╝███████║██║
    ██╔═██╗ ██║   ██║██╔══██╗██╔══██║██║
    ██║  ██╗╚██████╔╝██║  ██║██║  ██║██║
    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝
    KURAI SOFTWARE — v1.0.0
    discord.gg/kuraishop
    Single-File Architecture
--]]

-- ============================================================
-- KURAI SOFTWARE — SINGLE FILE MASTER
-- All modules, UI, animations, logic in this one file.
-- ============================================================

local KuraiSoftware = {}
KuraiSoftware.__index = KuraiSoftware

-- ============================================================
-- [CORE] — Runtime State & Constants
-- ============================================================

local KURAI_VERSION   = "1.0.0"
local KURAI_DISCORD   = "discord.gg/kuraishop"
local KURAI_TITLE     = "KURAI SOFTWARE"

local Core = {
    initialized    = false,
    panicMode      = false,
    debugMode      = false,
    sessionStart   = os.clock(),
    activeFeatures = {},
    eventHandlers  = {},
    cleanupTasks   = {},
    timers         = {},
    connections    = {},
    logs           = {},
    errors         = {},
}

-- ============================================================
-- [PLATFORM] — Detection & Adapter
-- ============================================================

local Platform = {
    os           = "Unknown",
    arch         = "Unknown",
    environment  = "Unknown",
    executor     = "Unknown",
    capabilities = {
        ui          = false,
        visuals     = false,
        movement    = false,
        combat      = false,
        config      = false,
        network     = false,
        drawing     = false,
        input       = false,
        filesystem  = false,
    },
    support = {},
}

local WINDOWS_EXECUTORS = {
    "Xeno","Wave","Solara","Madium","Volt","Potassium","Cosmic",
    "Synapse Z","SirHurt","Photon","Velocity","Lumen","Ronin",
    "Matcha","Fluxus","KRNL","Real","Vortex",
}
local ANDROID_EXECUTORS = { "Delta","Codex","Arceus X","Vega X","Cryptic","Hydrogen","Ronix" }
local IOS_EXECUTORS     = { "Delta","Hydrogen","Arceus X","Luna","Appleware" }
local MACOS_EXECUTORS   = { "MacSploit","Opiumware","Delta" }

function Platform.detect()
    -- Detect OS
    if type(os) == "table" and os.clock then
        if _G["syn"] or _G["KRNL_LOADED"] or _G["fluxus"] then
            Platform.os = "Windows"
        elseif _G["DELTA_ENV"] or _G["Codex"] then
            Platform.os = "Android"
        else
            Platform.os = "Windows" -- default assumption in Roblox context
        end
    end

    -- Detect executor
    if _G["syn"]          then Platform.executor = "Synapse Z"
    elseif _G["KRNL_LOADED"] then Platform.executor = "KRNL"
    elseif _G["fluxus"]   then Platform.executor = "Fluxus"
    elseif _G["DELTA_ENV"] then Platform.executor = "Delta"
    elseif _G["Codex"]    then Platform.executor = "Codex"
    else Platform.executor = "Unknown"
    end

    -- Detect capabilities
    Platform.capabilities.ui         = (typeof(Instance) ~= nil) and true or false
    Platform.capabilities.drawing    = (Drawing ~= nil) and true or false
    Platform.capabilities.filesystem = (writefile ~= nil) and true or false
    Platform.capabilities.network    = (request ~= nil or syn and syn.request ~= nil) and true or false
    Platform.capabilities.input      = (game and game:GetService("UserInputService") ~= nil) and true or false
    Platform.capabilities.visuals    = Platform.capabilities.drawing
    Platform.capabilities.movement   = true
    Platform.capabilities.combat     = true
    Platform.capabilities.config     = true

    -- Build compatibility table
    Platform.support = {
        { platform = Platform.os, environment = Platform.executor,
          ui = Platform.capabilities.ui and "SUPPORTED" or "UNAVAILABLE",
          visual = Platform.capabilities.visuals and "SUPPORTED" or "PARTIAL",
          movement = "SUPPORTED", combat = "SUPPORTED",
          config = Platform.capabilities.config and "SUPPORTED" or "PARTIAL" }
    }

    Platform.initialized = true
end

function Platform.featureAvailable(featureName)
    -- Generic availability check; can be extended per-feature
    if Core.panicMode then return false end
    return true
end

-- ============================================================
-- [LOGGER] — Centralized log system
-- ============================================================

local Logger = {}

function Logger.log(category, message, level)
    local entry = {
        timestamp = os.clock() - Core.sessionStart,
        category  = category or "Core",
        message   = message or "",
        level     = level or "INFO",
    }
    table.insert(Core.logs, entry)
    -- Print to console if debug
    if Core.debugMode then
        print(string.format("[KURAI][%s][%.2fs] %s", entry.category, entry.timestamp, entry.message))
    end
end

function Logger.error(category, featureName, err)
    local entry = {
        timestamp   = os.clock() - Core.sessionStart,
        category    = category,
        featureName = featureName,
        error       = tostring(err),
    }
    table.insert(Core.errors, entry)
    Logger.log(category, "ERROR in " .. featureName .. ": " .. tostring(err), "ERROR")
end

-- ============================================================
-- [EVENT MANAGER]
-- ============================================================

local EventManager = {}

function EventManager.on(event, handler)
    if not Core.eventHandlers[event] then
        Core.eventHandlers[event] = {}
    end
    table.insert(Core.eventHandlers[event], handler)
end

function EventManager.fire(event, ...)
    if Core.eventHandlers[event] then
        for _, handler in ipairs(Core.eventHandlers[event]) do
            local ok, err = pcall(handler, ...)
            if not ok then Logger.error("EventManager", event, err) end
        end
    end
end

-- ============================================================
-- [CLEANUP MANAGER]
-- ============================================================

local CleanupManager = {}

function CleanupManager.register(id, fn)
    Core.cleanupTasks[id] = fn
end

function CleanupManager.runAll()
    for id, fn in pairs(Core.cleanupTasks) do
        local ok, err = pcall(fn)
        if not ok then Logger.error("Cleanup", id, err) end
    end
    Core.cleanupTasks = {}
    Logger.log("Cleanup", "All cleanup tasks completed.")
end

function CleanupManager.run(id)
    if Core.cleanupTasks[id] then
        local ok, err = pcall(Core.cleanupTasks[id])
        if not ok then Logger.error("Cleanup", id, err) end
        Core.cleanupTasks[id] = nil
    end
end

-- ============================================================
-- [CONFIG MANAGER]
-- ============================================================

local Config = {
    current = {},
    defaults = {
        -- Startup
        startupAnimation       = true,
        animationSpeed         = 1.0,
        showLoadingDetails     = true,
        showLogo               = true,
        showProgressBar        = true,
        skipAnimationKeybind   = "RightShift",
        -- Theme
        theme                  = "Dark",
        accentColor            = Color3.fromRGB(120, 80, 255),
        uiTransparency         = 0.05,
        uiScale                = 1.0,
        animationSpeedUI       = 1.0,
        -- Performance
        performanceMode        = false,
        debugMode              = false,
        -- ESP defaults
        espEnabled             = false,
        espRange               = 500,
        espThickness           = 1,
        -- Combat defaults
        aimbotEnabled          = false,
        silentAimEnabled       = false,
        aimFOV                 = 90,
        -- Movement defaults
        speedEnabled           = false,
        walkSpeed              = 16,
        jumpPower              = 50,
        flyEnabled             = false,
        noclipEnabled          = false,
    },
    profiles = {},
    keybindProfiles = {},
    themeProfiles   = {},
}

function Config.load()
    Config.current = {}
    for k, v in pairs(Config.defaults) do
        Config.current[k] = v
    end

    -- Attempt filesystem load
    if Platform.capabilities.filesystem then
        local ok, data = pcall(function()
            if isfile("kurai_config.json") then
                return game:GetService("HttpService"):JSONDecode(readfile("kurai_config.json"))
            end
        end)
        if ok and data then
            for k, v in pairs(data) do
                Config.current[k] = v
            end
            Logger.log("Config", "Configuration loaded from file.")
        else
            Logger.log("Config", "No saved config found, using defaults.")
        end
    else
        Logger.log("Config", "Filesystem unavailable, using defaults.")
    end
end

function Config.save()
    if Platform.capabilities.filesystem then
        local ok, err = pcall(function()
            local json = game:GetService("HttpService"):JSONEncode(Config.current)
            writefile("kurai_config.json", json)
        end)
        if not ok then Logger.error("Config", "Save", err) end
    end
end

function Config.reset()
    Config.current = {}
    for k, v in pairs(Config.defaults) do
        Config.current[k] = v
    end
    Config.save()
    Logger.log("Config", "Configuration reset to defaults.")
end

function Config.get(key)
    return Config.current[key]
end

function Config.set(key, value)
    Config.current[key] = value
    Config.save()
end

-- ============================================================
-- [PERFORMANCE MONITOR]
-- ============================================================

local Performance = {
    fps     = 0,
    ping    = 0,
    memory  = 0,
    history = { fps = {}, ping = {} },
    running = false,
}

function Performance.start()
    if Performance.running then return end
    Performance.running = true
    local lastTick = tick()
    local frames   = 0

    -- FPS tracking via RunService if available
    if game and game:GetService("RunService") then
        local rs = game:GetService("RunService")
        local conn = rs.Heartbeat:Connect(function()
            if Core.panicMode then return end
            frames = frames + 1
            local now = tick()
            if now - lastTick >= 1 then
                Performance.fps = frames
                table.insert(Performance.history.fps, frames)
                if #Performance.history.fps > 60 then
                    table.remove(Performance.history.fps, 1)
                end
                frames   = 0
                lastTick = now
            end
        end)
        table.insert(Core.connections, conn)
        CleanupManager.register("Performance", function()
            conn:Disconnect()
            Performance.running = false
        end)
    end
end

-- ============================================================
-- [STATISTICS]
-- ============================================================

local Statistics = {
    sessionTime       = 0,
    totalKills        = 0,
    totalDeaths       = 0,
    coinsCollected    = 0,
    roundsPlayed      = 0,
    roundsWon         = 0,
    roundsLost        = 0,
    murdererWins      = 0,
    sheriffWins       = 0,
    innocentWins      = 0,
    bestStreak        = 0,
    currentStreak     = 0,
    history           = {},
}

function Statistics.getKD()
    if Statistics.totalDeaths == 0 then return Statistics.totalKills end
    return math.floor((Statistics.totalKills / Statistics.totalDeaths) * 100) / 100
end

function Statistics.reset()
    Statistics.totalKills     = 0
    Statistics.totalDeaths    = 0
    Statistics.coinsCollected = 0
    Statistics.roundsPlayed   = 0
    Statistics.roundsWon      = 0
    Statistics.roundsLost     = 0
    Statistics.bestStreak     = 0
    Statistics.currentStreak  = 0
    Logger.log("Statistics", "Statistics reset.")
end

-- ============================================================
-- [FEATURE MANAGER]
-- ============================================================

local FeatureManager = {
    registry = {},
}

local function makeFeature(id, name, category, description, supportedPlatforms)
    return {
        id                = id,
        name              = name,
        category          = category,
        description       = description,
        enabled           = false,
        status            = "IDLE",
        settings          = {},
        keybind           = nil,
        dependencies      = {},
        supportedPlatforms= supportedPlatforms or { "Windows","Android","iOS","macOS" },
        cleanupHandler    = nil,
    }
end

function FeatureManager.register(feature)
    FeatureManager.registry[feature.id] = feature
    Logger.log("FeatureManager", "Registered: " .. feature.name)
end

function FeatureManager.enable(id)
    local f = FeatureManager.registry[id]
    if not f then return false, "Feature not found" end
    if not Platform.featureAvailable(id) then
        return false, "Feature unavailable on this environment"
    end
    f.enabled = true
    f.status  = "ACTIVE"
    Core.activeFeatures[id] = true
    EventManager.fire("FeatureEnabled", f)
    Logger.log("FeatureManager", "Enabled: " .. f.name)
    return true
end

function FeatureManager.disable(id)
    local f = FeatureManager.registry[id]
    if not f then return false end
    f.enabled = false
    f.status  = "IDLE"
    Core.activeFeatures[id] = nil
    if f.cleanupHandler then
        local ok, err = pcall(f.cleanupHandler)
        if not ok then Logger.error("FeatureManager", id, err) end
    end
    EventManager.fire("FeatureDisabled", f)
    Logger.log("FeatureManager", "Disabled: " .. f.name)
    return true
end

function FeatureManager.toggle(id)
    local f = FeatureManager.registry[id]
    if not f then return end
    if f.enabled then FeatureManager.disable(id)
    else FeatureManager.enable(id) end
end

function FeatureManager.disableAll()
    for id, _ in pairs(Core.activeFeatures) do
        FeatureManager.disable(id)
    end
end

-- Register all features
local function registerAllFeatures()
    -- ESP
    local espFeatures = {
        {"esp_player","Player ESP","ESP","Highlight all players"},
        {"esp_murderer","Murderer ESP","ESP","Highlight murderers"},
        {"esp_sheriff","Sheriff ESP","ESP","Highlight sheriffs"},
        {"esp_hero","Hero ESP","ESP","Highlight heroes"},
        {"esp_innocent","Innocent ESP","ESP","Highlight innocents"},
        {"esp_role","Role ESP","ESP","Show roles above players"},
        {"esp_name","Name ESP","ESP","Show player names"},
        {"esp_distance","Distance ESP","ESP","Show distance to players"},
        {"esp_health","Health ESP","ESP","Show player health bars"},
        {"esp_box","Box ESP","ESP","Draw boxes around players"},
        {"esp_corner_box","Corner Box","ESP","Corner-style boxes"},
        {"esp_skeleton","Skeleton ESP","ESP","Draw player skeletons"},
        {"esp_tracer","Tracer ESP","ESP","Draw tracer lines"},
        {"esp_chams","Chams","ESP","Color players through walls"},
        {"esp_head","Head ESP","ESP","Highlight player heads"},
        {"esp_gun","Gun ESP","ESP","Highlight guns"},
        {"esp_knife","Knife ESP","ESP","Highlight knives"},
        {"esp_coin","Coin ESP","ESP","Highlight coins"},
        {"esp_item","Item ESP","ESP","Highlight all items"},
        {"esp_drop","Dropped Item ESP","ESP","Highlight dropped items"},
        {"esp_dead","Dead Player ESP","ESP","Show dead players"},
        {"esp_offscreen","Off-Screen Arrows","ESP","Arrow indicators for off-screen players"},
        {"esp_map","Map ESP","ESP","ESP elements on minimap"},
        {"esp_spectator","Spectator ESP","ESP","Show spectating players"},
        {"esp_rainbow","Rainbow ESP","ESP","Rainbow color cycling ESP"},
    }
    for _, f in ipairs(espFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Combat
    local combatFeatures = {
        {"combat_autofling","Auto Fling","Combat","Automatically fling targets"},
        {"combat_autotarget","Auto Target","Combat","Automatically acquire targets"},
        {"combat_aimbot","Aimbot","Combat","Full aimbot assistance"},
        {"combat_silentaim","Silent Aim","Combat","Silent aim assistance"},
        {"combat_aimfov","Aim FOV","Combat","Configurable aim field-of-view"},
        {"combat_autoshoot","Auto Shoot","Combat","Automatically shoot when target locked"},
        {"combat_autostab","Auto Stab","Combat","Automatically stab with knife"},
        {"combat_autothrow","Auto Throw","Combat","Automatically throw knives"},
        {"combat_reach","Reach","Combat","Extended melee reach"},
        {"combat_hitbox","Hitbox Expander","Combat","Expand target hitboxes"},
        {"combat_hitbox_vis","Hitbox Visualizer","Combat","Visualize hitboxes"},
        {"combat_damage_indicator","Damage Indicator","Combat","Show damage dealt"},
        {"combat_rage_preset","Rage Preset","Combat","Maximum aggression preset"},
        {"combat_legit_preset","Legit Preset","Combat","Subtle assistance preset"},
    }
    for _, f in ipairs(combatFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Movement
    local movementFeatures = {
        {"move_speed","Speed","Movement","Increase walk speed"},
        {"move_jumppower","Jump Power","Movement","Modify jump height"},
        {"move_infjump","Infinite Jump","Movement","Jump infinitely in air"},
        {"move_fly","Fly","Movement","Enable flight"},
        {"move_noclip","Noclip","Movement","Phase through walls"},
        {"move_gravity","Gravity Control","Movement","Modify gravity"},
        {"move_airwalk","Air Walk","Movement","Walk on air"},
        {"move_bunnyhop","Bunny Hop","Movement","Automatic bunny hop"},
        {"move_dash","Dash","Movement","Quick dash ability"},
        {"move_tpwalk","TP Walk","Movement","Teleport-based movement"},
        {"move_spin","Spin","Movement","Character spin"},
        {"move_autojump","Auto Jump","Movement","Automatically jump"},
        {"move_autodoge","Auto Dodge","Movement","Automatically dodge attacks"},
        {"move_freecam","Freecam","Movement","Detached free camera"},
        {"move_thirdperson","Third Person","Movement","Third-person camera"},
    }
    for _, f in ipairs(movementFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Farm
    local farmFeatures = {
        {"farm_autocollect","Auto Collect","Farm","Automatically collect coins"},
        {"farm_coin_farm","Coin Farm","Farm","Farm coins automatically"},
        {"farm_coin_aura","Coin Aura","Farm","Collect nearby coins passively"},
        {"farm_autofarm","Auto Farm","Farm","Full auto-farm loop"},
        {"farm_item_finder","Item Finder","Farm","Locate items on map"},
        {"farm_gun_finder","Gun Finder","Farm","Locate guns on map"},
    }
    for _, f in ipairs(farmFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Intelligence
    local intelligenceFeatures = {
        {"intel_role_detect","Role Detector","Intelligence","Detect player roles"},
        {"intel_murderer_detect","Murderer Detector","Intelligence","Identify murderer"},
        {"intel_sheriff_detect","Sheriff Detector","Intelligence","Identify sheriff"},
        {"intel_round_detect","Round Detector","Intelligence","Detect round state"},
        {"intel_gun_drop","Gun Drop Detector","Intelligence","Detect dropped guns"},
        {"intel_murderer_alert","Murderer Alert","Intelligence","Alert when murderer identified"},
        {"intel_gun_alert","Gun Drop Alert","Intelligence","Alert when gun dropped"},
    }
    for _, f in ipairs(intelligenceFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Misc
    local miscFeatures = {
        {"misc_notifs","Notifications","Misc","In-game notifications"},
        {"misc_screenshot","Screenshot Mode","Misc","Hide UI for screenshots"},
        {"misc_streamer","Streamer Mode","Misc","Streamer-safe mode"},
        {"misc_hide_ui","Hide UI","Misc","Toggle UI visibility"},
        {"misc_debug","Debug Mode","Misc","Show debug information"},
        {"misc_perf_mode","Performance Mode","Misc","Optimize for performance"},
        {"misc_fps_monitor","FPS Monitor","Misc","Display FPS counter"},
        {"misc_ping_monitor","Ping Monitor","Misc","Display ping counter"},
        {"misc_session_log","Session Logger","Misc","Log session events"},
    }
    for _, f in ipairs(miscFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    -- Visual
    local visualFeatures = {
        {"visual_crosshair","Crosshair","Visual","Custom crosshair overlay"},
        {"visual_hit_effects","Hit Effects","Visual","Visual hit effects"},
        {"visual_kill_effects","Kill Effects","Visual","Visual kill effects"},
        {"visual_cam_shake","Camera Shake","Visual","Camera shake on hit"},
        {"visual_fov_slider","FOV Slider","Visual","Adjust camera FOV"},
        {"visual_thirdperson","Third Person View","Visual","Third-person visual mode"},
        {"visual_ui_blur","UI Blur","Visual","Blur background behind UI"},
    }
    for _, f in ipairs(visualFeatures) do
        FeatureManager.register(makeFeature(f[1], f[2], f[3], f[4]))
    end

    Logger.log("FeatureManager", "All features registered: " .. #espFeatures + #combatFeatures + #movementFeatures + #farmFeatures + #intelligenceFeatures + #miscFeatures + #visualFeatures)
end

-- ============================================================
-- [KEYBIND MANAGER]
-- ============================================================

local KeybindManager = {
    binds   = {},
    active  = true,
}

function KeybindManager.bind(key, featureId, toggleFn)
    KeybindManager.binds[key] = { featureId = featureId, fn = toggleFn or function()
        FeatureManager.toggle(featureId)
    end}
end

function KeybindManager.init()
    if game and game:GetService("UserInputService") then
        local UIS = game:GetService("UserInputService")
        local conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not KeybindManager.active then return end
            local key = tostring(input.KeyCode)
            if KeybindManager.binds[key] then
                local ok, err = pcall(KeybindManager.binds[key].fn)
                if not ok then Logger.error("KeybindManager", key, err) end
            end
        end)
        table.insert(Core.connections, conn)
        CleanupManager.register("KeybindManager", function() conn:Disconnect() end)
    end
    Logger.log("KeybindManager", "Initialized.")
end

-- ============================================================
-- [NOTIFICATION MANAGER]
-- ============================================================

local NotificationManager = {
    queue   = {},
    history = {},
}

function NotificationManager.send(title, message, notifType, duration)
    local n = {
        title     = title or "Kurai",
        message   = message or "",
        type      = notifType or "INFO",
        duration  = duration or 3,
        timestamp = os.clock(),
    }
    table.insert(NotificationManager.queue, n)
    table.insert(NotificationManager.history, n)

    -- Roblox star notification if available
    if game and game:GetService("StarterGui") then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title    = n.title,
                Text     = n.message,
                Duration = n.duration,
            })
        end)
    end
    Logger.log("Notification", n.title .. " — " .. n.message)
end

-- ============================================================
-- [PANIC BUTTON]
-- ============================================================

local PanicButton = {}

function PanicButton.activate()
    Core.panicMode = true

    -- Disable all features
    FeatureManager.disableAll()

    -- Stop timers
    for _, timer in ipairs(Core.timers) do
        if timer and timer.disconnect then timer:Disconnect() end
    end
    Core.timers = {}

    -- Stop connections
    for _, conn in ipairs(Core.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Core.connections = {}

    -- Run all cleanup tasks
    CleanupManager.runAll()

    -- Notify
    NotificationManager.send("KURAI", "ALL FEATURES DISABLED", "PANIC", 5)
    Logger.log("PanicButton", "PANIC ACTIVATED — all features disabled, all connections severed.")
end

-- ============================================================
-- [TARGET MANAGER]
-- ============================================================

local TargetManager = {
    playerList  = {},
    targetList  = {},
    whitelist   = {},
    blacklist   = {},
    locked      = nil,
    filters     = {
        ignoreDead = true,
        ignoreFriends = false,
        maxDistance = 500,
        roleFilter  = "All",
    },
}

function TargetManager.getNearest(origin)
    local nearest, dist = nil, math.huge
    if not game then return nil end
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local d   = (hrp.Position - origin).Magnitude
            if d < dist and not TargetManager.blacklist[p.Name] then
                nearest = p
                dist    = d
            end
        end
    end
    return nearest, dist
end

function TargetManager.lock(player)
    TargetManager.locked = player
    if player then
        NotificationManager.send("Target", "Locked: " .. player.Name, "INFO", 2)
    end
end

function TargetManager.unlock()
    TargetManager.locked = nil
end

function TargetManager.addToWhitelist(name) TargetManager.whitelist[name] = true end
function TargetManager.addToBlacklist(name) TargetManager.blacklist[name] = true end
function TargetManager.removeFromWhitelist(name) TargetManager.whitelist[name] = nil end
function TargetManager.removeFromBlacklist(name) TargetManager.blacklist[name] = nil end

-- ============================================================
-- [SERVER INFO]
-- ============================================================

local ServerInfo = {
    jobId       = "",
    playerCount = 0,
    maxPlayers  = 0,
    region      = "Unknown",
    ping        = 0,
}

function ServerInfo.refresh()
    if game then
        ServerInfo.jobId       = game.JobId or ""
        ServerInfo.playerCount = #game:GetService("Players"):GetPlayers()
        ServerInfo.maxPlayers  = game:GetService("Players").MaxPlayers or 0
    end
end

-- ============================================================
-- [THEMES]
-- ============================================================

local ThemeManager = {
    current = "Dark",
    themes  = {
        Dark = {
            bg          = Color3.fromRGB(12, 12, 18),
            bgSecondary = Color3.fromRGB(18, 18, 28),
            bgTertiary  = Color3.fromRGB(24, 24, 38),
            accent      = Color3.fromRGB(120, 80, 255),
            accentGlow  = Color3.fromRGB(90, 50, 220),
            text        = Color3.fromRGB(220, 220, 240),
            textDim     = Color3.fromRGB(140, 140, 160),
            border      = Color3.fromRGB(40, 40, 60),
            success     = Color3.fromRGB(80, 200, 120),
            warning     = Color3.fromRGB(240, 180, 60),
            danger      = Color3.fromRGB(240, 70, 70),
            info        = Color3.fromRGB(80, 160, 240),
        },
        Midnight = {
            bg          = Color3.fromRGB(5, 5, 12),
            bgSecondary = Color3.fromRGB(10, 10, 22),
            bgTertiary  = Color3.fromRGB(15, 15, 32),
            accent      = Color3.fromRGB(60, 120, 255),
            accentGlow  = Color3.fromRGB(40, 90, 200),
            text        = Color3.fromRGB(200, 210, 255),
            textDim     = Color3.fromRGB(120, 130, 180),
            border      = Color3.fromRGB(25, 30, 60),
            success     = Color3.fromRGB(60, 200, 140),
            warning     = Color3.fromRGB(240, 200, 60),
            danger      = Color3.fromRGB(255, 60, 80),
            info        = Color3.fromRGB(60, 180, 255),
        },
        Neon = {
            bg          = Color3.fromRGB(8, 8, 8),
            bgSecondary = Color3.fromRGB(14, 14, 14),
            bgTertiary  = Color3.fromRGB(20, 20, 20),
            accent      = Color3.fromRGB(0, 255, 160),
            accentGlow  = Color3.fromRGB(0, 200, 120),
            text        = Color3.fromRGB(230, 255, 240),
            textDim     = Color3.fromRGB(130, 180, 150),
            border      = Color3.fromRGB(30, 60, 45),
            success     = Color3.fromRGB(0, 255, 100),
            warning     = Color3.fromRGB(255, 200, 0),
            danger      = Color3.fromRGB(255, 50, 80),
            info        = Color3.fromRGB(0, 200, 255),
        },
        Glass = {
            bg          = Color3.fromRGB(20, 20, 35),
            bgSecondary = Color3.fromRGB(30, 30, 50),
            bgTertiary  = Color3.fromRGB(40, 40, 65),
            accent      = Color3.fromRGB(180, 140, 255),
            accentGlow  = Color3.fromRGB(140, 100, 220),
            text        = Color3.fromRGB(240, 235, 255),
            textDim     = Color3.fromRGB(160, 155, 185),
            border      = Color3.fromRGB(60, 60, 90),
            success     = Color3.fromRGB(100, 220, 140),
            warning     = Color3.fromRGB(255, 190, 80),
            danger      = Color3.fromRGB(255, 80, 100),
            info        = Color3.fromRGB(100, 180, 255),
        },
        AMOLED = {
            bg          = Color3.fromRGB(0, 0, 0),
            bgSecondary = Color3.fromRGB(8, 8, 8),
            bgTertiary  = Color3.fromRGB(14, 14, 14),
            accent      = Color3.fromRGB(200, 60, 255),
            accentGlow  = Color3.fromRGB(160, 40, 220),
            text        = Color3.fromRGB(255, 255, 255),
            textDim     = Color3.fromRGB(160, 160, 160),
            border      = Color3.fromRGB(30, 30, 30),
            success     = Color3.fromRGB(60, 255, 120),
            warning     = Color3.fromRGB(255, 200, 0),
            danger      = Color3.fromRGB(255, 40, 60),
            info        = Color3.fromRGB(60, 160, 255),
        },
    },
}

function ThemeManager.get()
    return ThemeManager.themes[ThemeManager.current] or ThemeManager.themes["Dark"]
end

function ThemeManager.set(name)
    if ThemeManager.themes[name] then
        ThemeManager.current = name
        Config.set("theme", name)
        EventManager.fire("ThemeChanged", name)
        Logger.log("ThemeManager", "Theme changed to: " .. name)
    end
end

-- ============================================================
-- [UI] — Roblox ScreenGui with Startup Animation + Dashboard
-- ============================================================

local UI = {
    gui             = nil,
    startupFrame    = nil,
    dashboardFrame  = nil,
    sidebarFrame    = nil,
    contentFrame    = nil,
    activeTab       = "Dashboard",
    searchQuery     = "",
    favorites       = {},
    recentlyUsed    = {},
    notifications   = {},
    isVisible       = true,
    animating       = false,
}

-- ---- Helpers ----

local function lerp(a, b, t) return a + (b - a) * t end

local function tweenProperty(obj, property, targetValue, duration, style, direction)
    if not obj or not obj[property] then return end
    local TS = game:GetService("TweenService")
    style     = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.4, style, direction)
    local tween = TS:Create(obj, info, { [property] = targetValue })
    tween:Play()
    return tween
end

local function createInstance(className, parent, props)
    local ok, inst = pcall(Instance.new, className)
    if not ok then return nil end
    for k, v in pairs(props or {}) do
        local setOk, err = pcall(function() inst[k] = v end)
        if not setOk then Logger.error("UI", "createInstance." .. className, err) end
    end
    inst.Parent = parent
    return inst
end

local function hex2rgb(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1,2), 16),
        tonumber(hex:sub(3,4), 16),
        tonumber(hex:sub(5,6), 16)
    )
end

-- ---- Startup Screen ----

function UI.buildStartupScreen()
    local theme    = ThemeManager.get()
    local animSpeed = Config.get("animationSpeed") or 1.0

    -- Startup Frame
    local startup = createInstance("Frame", UI.gui, {
        Name           = "StartupScreen",
        Size           = UDim2.fromScale(1, 1),
        Position       = UDim2.fromScale(0, 0),
        BackgroundColor3 = theme.bg,
        BorderSizePixel = 0,
        ZIndex         = 100,
    })
    UI.startupFrame = startup

    -- Subtle gradient overlay
    createInstance("UIGradient", startup, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 40)),
            ColorSequenceKeypoint.new(0.5, theme.bg),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 4, 20)),
        }),
        Rotation = 135,
    })

    -- Glow circle behind logo
    local glowCircle = createInstance("Frame", startup, {
        Name             = "GlowCircle",
        Size             = UDim2.fromOffset(300, 300),
        Position         = UDim2.new(0.5, -150, 0.4, -200),
        BackgroundColor3 = theme.accent,
        BorderSizePixel  = 0,
        BackgroundTransparency = 0.92,
        ZIndex           = 101,
    })
    createInstance("UICorner", glowCircle, { CornerRadius = UDim.new(1, 0) })

    -- Logo Text
    local logo = createInstance("TextLabel", startup, {
        Name             = "Logo",
        Text             = "KURAI",
        Font             = Enum.Font.GothamBold,
        TextSize         = 56,
        TextColor3       = theme.text,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.8, 0, 0, 80),
        Position         = UDim2.new(0.1, 0, 0.32, 0),
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 102,
    })

    -- Software subtitle
    local subtitle = createInstance("TextLabel", startup, {
        Name             = "Subtitle",
        Text             = "SOFTWARE",
        Font             = Enum.Font.Gotham,
        TextSize         = 22,
        TextColor3       = theme.accent,
        TextTransparency = 1,
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.8, 0, 0, 30),
        Position         = UDim2.new(0.1, 0, 0.32 + 0.09, 0),
        TextXAlignment   = Enum.TextXAlignment.Center,
        LetterSpacing    = 10,
        ZIndex           = 102,
    })

    -- Discord link
    local discord = createInstance("TextLabel", startup, {
        Name             = "Discord",
        Text             = KURAI_DISCORD,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextColor3       = theme.textDim,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.8, 0, 0, 20),
        Position         = UDim2.new(0.1, 0, 0.32 + 0.14, 0),
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 102,
    })

    -- Separator line
    local line = createInstance("Frame", startup, {
        Name             = "Separator",
        Size             = UDim2.new(0, 0, 0, 1),
        Position         = UDim2.new(0.25, 0, 0.62, 0),
        BackgroundColor3 = theme.accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel  = 0,
        ZIndex           = 102,
    })

    -- Status label
    local statusLabel = createInstance("TextLabel", startup, {
        Name             = "StatusLabel",
        Text             = "Initializing Kurai...",
        Font             = Enum.Font.GothamMedium,
        TextSize         = 13,
        TextColor3       = theme.textDim,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0.5, 0, 0, 20),
        Position         = UDim2.new(0.25, 0, 0.64, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 103,
    })

    -- Progress bar background
    local progressBG = createInstance("Frame", startup, {
        Name             = "ProgressBG",
        Size             = UDim2.new(0.5, 0, 0, 3),
        Position         = UDim2.new(0.25, 0, 0.68, 0),
        BackgroundColor3 = theme.border,
        BorderSizePixel  = 0,
        BackgroundTransparency = 0.5,
        ZIndex           = 102,
    })
    createInstance("UICorner", progressBG, { CornerRadius = UDim.new(1, 0) })

    -- Progress bar fill
    local progressFill = createInstance("Frame", progressBG, {
        Name             = "Fill",
        Size             = UDim2.new(0, 0, 1, 0),
        Position         = UDim2.fromScale(0, 0),
        BackgroundColor3 = theme.accent,
        BorderSizePixel  = 0,
        ZIndex           = 103,
    })
    createInstance("UICorner", progressFill, { CornerRadius = UDim.new(1, 0) })

    -- Glow on progress fill
    local progressGlow = createInstance("UIGradient", progressFill, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 160, 255)),
        }),
    })

    -- Version badge
    createInstance("TextLabel", startup, {
        Name             = "Version",
        Text             = "v" .. KURAI_VERSION,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = theme.textDim,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 60, 0, 18),
        Position         = UDim2.new(1, -70, 1, -28),
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 102,
    })

    -- Skip hint
    local skipLabel = createInstance("TextLabel", startup, {
        Name             = "SkipHint",
        Text             = "Press " .. (Config.get("skipAnimationKeybind") or "RightShift") .. " to skip",
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextColor3       = theme.textDim,
        TextTransparency = 0.5,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 160, 0, 18),
        Position         = UDim2.new(0, 10, 1, -28),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 102,
    })

    return {
        glowCircle    = glowCircle,
        logo          = logo,
        subtitle      = subtitle,
        discord       = discord,
        line          = line,
        statusLabel   = statusLabel,
        progressBG    = progressBG,
        progressFill  = progressFill,
        skipLabel     = skipLabel,
    }
end

function UI.playStartupAnimation(elements, onComplete)
    local theme     = ThemeManager.get()
    local speed     = 1 / math.max((Config.get("animationSpeed") or 1.0), 0.1)
    local skipped   = false

    -- Skip handler
    local skipConn
    if game and game:GetService("UserInputService") then
        local UIS = game:GetService("UserInputService")
        local skipKey = Config.get("skipAnimationKeybind") or "RightShift"
        skipConn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if tostring(input.KeyCode):find(skipKey) then
                skipped = true
            end
        end)
    end

    local function waitOrSkip(t)
        local start = tick()
        while tick() - start < t * speed do
            if skipped then return end
            task.wait(0.016)
        end
    end

    local function setStatus(text, progress)
        if elements.statusLabel then
            elements.statusLabel.Text = text
        end
        if elements.progressFill then
            tweenProperty(elements.progressFill, "Size", UDim2.new(progress, 0, 1, 0), 0.35 * speed)
        end
    end

    -- Fade in glow
    tweenProperty(elements.glowCircle, "BackgroundTransparency", 0.85, 0.8 * speed)
    waitOrSkip(0.3)

    -- Fade in logo
    tweenProperty(elements.logo, "TextTransparency", 0, 0.7 * speed)
    waitOrSkip(0.4)

    -- Fade in subtitle
    tweenProperty(elements.subtitle, "TextTransparency", 0, 0.5 * speed)
    tweenProperty(elements.discord,  "TextTransparency", 0, 0.5 * speed)
    waitOrSkip(0.4)

    -- Expand separator line
    tweenProperty(elements.line, "Size", UDim2.new(0.5, 0, 0, 1), 0.5 * speed)
    waitOrSkip(0.2)

    -- Fade in status + progress
    tweenProperty(elements.statusLabel, "TextTransparency", 0, 0.3 * speed)
    waitOrSkip(0.2)

    -- Loading steps
    local steps = {
        { text = "Initializing Kurai...",     progress = 0.08 },
        { text = "Detecting environment...",  progress = 0.22 },
        { text = "Loading modules...",        progress = 0.42 },
        { text = "Loading interface...",      progress = 0.60 },
        { text = "Checking environment...",   progress = 0.72 },
        { text = "Loading configuration...",  progress = 0.88 },
        { text = "Ready.",                    progress = 1.0  },
    }

    for _, step in ipairs(steps) do
        if skipped then break end
        setStatus(step.text, step.progress)
        waitOrSkip(0.28)
    end

    if elements.statusLabel then
        elements.statusLabel.Text = "Ready."
    end
    if elements.progressFill then
        tweenProperty(elements.progressFill, "Size", UDim2.new(1, 0, 1, 0), 0.25 * speed)
    end
    waitOrSkip(0.5)

    -- Disconnect skip
    if skipConn then pcall(function() skipConn:Disconnect() end) end

    -- Fade out startup screen
    tweenProperty(UI.startupFrame, "BackgroundTransparency", 1, 0.45 * speed)
    for _, child in ipairs(UI.startupFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            if child:IsA("TextLabel") then
                tweenProperty(child, "TextTransparency", 1, 0.4 * speed)
            else
                tweenProperty(child, "BackgroundTransparency", 1, 0.4 * speed)
            end
        end
    end
    waitOrSkip(0.5)

    UI.startupFrame.Visible = false
    if onComplete then onComplete() end
end

-- ---- Dashboard ----

function UI.buildDashboard()
    local theme = ThemeManager.get()

    -- Root dashboard container
    local dash = createInstance("Frame", UI.gui, {
        Name             = "Dashboard",
        Size             = UDim2.new(0.88, 0, 0.85, 0),
        Position         = UDim2.new(0.06, 0, 0.075, 0),
        BackgroundColor3 = theme.bg,
        BorderSizePixel  = 0,
        BackgroundTransparency = 0.02,
        Visible          = false,
        ZIndex           = 10,
    })
    createInstance("UICorner", dash, { CornerRadius = UDim.new(0, 12) })
    createInstance("UIStroke", dash, {
        Color        = theme.border,
        Thickness    = 1,
        Transparency = 0.3,
    })

    -- Drop shadow
    local shadow = createInstance("ImageLabel", UI.gui, {
        Name             = "Shadow",
        Size             = UDim2.new(0.9, 0, 0.87, 0),
        Position         = UDim2.new(0.05, 0, 0.075, 8),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://7912134082",
        ImageColor3      = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.6,
        ZIndex           = 9,
        Visible          = false,
    })
    UI.shadowFrame = shadow

    -- Titlebar
    local titlebar = createInstance("Frame", dash, {
        Name             = "Titlebar",
        Size             = UDim2.new(1, 0, 0, 44),
        Position         = UDim2.fromScale(0, 0),
        BackgroundColor3 = theme.bgSecondary,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    })
    createInstance("UICorner", titlebar, { CornerRadius = UDim.new(0, 12) })

    -- Fix bottom corners of titlebar
    createInstance("Frame", titlebar, {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.bgSecondary,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    })

    -- Title icon/glow dot
    createInstance("Frame", titlebar, {
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 18, 0.5, -4),
        BackgroundColor3 = theme.accent,
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }):FindFirstChildWhichIsA("UICorner") or createInstance("UICorner", titlebar:FindFirstChild("Frame") or titlebar, { CornerRadius = UDim.new(1,0) })

    -- Kurai title label
    createInstance("TextLabel", titlebar, {
        Name             = "TitleText",
        Text             = "KURAI SOFTWARE",
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextColor3       = theme.text,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 200, 1, 0),
        Position         = UDim2.new(0, 34, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 12,
    })

    -- Window controls
    local closeBtn = createInstance("TextButton", titlebar, {
        Name             = "CloseBtn",
        Text             = "✕",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = theme.textDim,
        BackgroundColor3 = Color3.fromRGB(255,70,70),
        BackgroundTransparency = 0.6,
        Size             = UDim2.new(0, 26, 0, 26),
        Position         = UDim2.new(1, -36, 0.5, -13),
        ZIndex           = 12,
    })
    createInstance("UICorner", closeBtn, { CornerRadius = UDim.new(0, 6) })

    local panicBtn = createInstance("TextButton", titlebar, {
        Name             = "PanicBtn",
        Text             = "⚠",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = theme.warning,
        BackgroundColor3 = theme.bgTertiary,
        BackgroundTransparency = 0.4,
        Size             = UDim2.new(0, 26, 0, 26),
        Position         = UDim2.new(1, -68, 0.5, -13),
        ZIndex           = 12,
    })
    createInstance("UICorner", panicBtn, { CornerRadius = UDim.new(0, 6) })

    -- Search bar
    local searchBar = createInstance("Frame", titlebar, {
        Name             = "SearchBar",
        Size             = UDim2.new(0, 220, 0, 26),
        Position         = UDim2.new(0.5, -110, 0.5, -13),
        BackgroundColor3 = theme.bgTertiary,
        BorderSizePixel  = 0,
        ZIndex           = 12,
    })
    createInstance("UICorner", searchBar, { CornerRadius = UDim.new(0, 6) })
    createInstance("TextBox", searchBar, {
        Name             = "Input",
        Text             = "",
        PlaceholderText  = "🔍  Search features...",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = theme.text,
        PlaceholderColor3= theme.textDim,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -12, 1, 0),
        Position         = UDim2.new(0, 8, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 13,
        ClearTextOnFocus = false,
    })

    -- Sidebar
    local sidebar = createInstance("Frame", dash, {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 180, 1, -44),
        Position         = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = theme.bgSecondary,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    })
    createInstance("UICorner", sidebar, { CornerRadius = UDim.new(0, 12) })
    -- Fix right corners
    createInstance("Frame", sidebar, {
        Size             = UDim2.new(0.5, 0, 1, 0),
        Position         = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = theme.bgSecondary,
        BorderSizePixel  = 0,
        ZIndex           = 11,
    })

    local sidebarList = createInstance("ScrollingFrame", sidebar, {
        Name             = "List",
        Size             = UDim2.new(1, 0, 1, -10),
        Position         = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 3,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = 12,
    })
    createInstance("UIPadding", sidebarList, {
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop   = UDim.new(0, 4),
    })
    createInstance("UIListLayout", sidebarList, {
        SortOrder  = Enum.SortOrder.LayoutOrder,
        Padding    = UDim.new(0, 3),
    })

    -- Content area
    local content = createInstance("ScrollingFrame", dash, {
        Name             = "Content",
        Size             = UDim2.new(1, -188, 1, -52),
        Position         = UDim2.new(0, 184, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 3,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex           = 11,
    })
    createInstance("UIPadding", content, {
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop   = UDim.new(0, 8),
        PaddingBottom= UDim.new(0, 8),
    })
    createInstance("UIListLayout", content, {
        SortOrder  = Enum.SortOrder.LayoutOrder,
        Padding    = UDim.new(0, 6),
    })

    UI.dashboardFrame = dash
    UI.sidebarFrame   = sidebarList
    UI.contentFrame   = content

    -- Wire up buttons
    closeBtn.MouseButton1Click:Connect(function()
        UI.hide()
    end)
    panicBtn.MouseButton1Click:Connect(function()
        PanicButton.activate()
        NotificationManager.send("PANIC", "All features disabled.", "DANGER", 5)
    end)

    -- Build sidebar tabs
    local tabs = {
        { name = "Dashboard",    icon = "⬛" },
        { name = "ESP",          icon = "👁" },
        { name = "Combat",       icon = "⚔" },
        { name = "Movement",     icon = "💨" },
        { name = "Farm",         icon = "💰" },
        { name = "Intelligence", icon = "🧠" },
        { name = "Targets",      icon = "🎯" },
        { name = "Visual",       icon = "✨" },
        { name = "Misc",         icon = "⚙" },
        { name = "Statistics",   icon = "📊" },
        { name = "Server",       icon = "🌐" },
        { name = "Themes",       icon = "🎨" },
        { name = "Config",       icon = "💾" },
        { name = "Performance",  icon = "⚡" },
        { name = "Compatibility","icon" = "✅" },
        { name = "Logs",         icon = "📋" },
    }

    for i, tab in ipairs(tabs) do
        UI.createSidebarTab(tab.name, tab.icon, i)
    end

    -- Show default tab
    UI.switchTab("Dashboard")

    return dash
end

function UI.createSidebarTab(name, icon, order)
    local theme = ThemeManager.get()
    local isActive = (name == UI.activeTab)

    local btn = createInstance("TextButton", UI.sidebarFrame, {
        Name             = "Tab_" .. name,
        Text             = (icon or "") .. "  " .. name,
        Font             = Enum.Font.GothamMedium,
        TextSize         = 12,
        TextColor3       = isActive and theme.text or theme.textDim,
        BackgroundColor3 = isActive and theme.bgTertiary or theme.bgSecondary,
        BackgroundTransparency = isActive and 0 or 1,
        Size             = UDim2.new(1, 0, 0, 32),
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = order,
        ZIndex           = 13,
    })
    createInstance("UICorner", btn, { CornerRadius = UDim.new(0, 7) })
    createInstance("UIPadding", btn, { PaddingLeft = UDim.new(0, 10) })

    if isActive then
        createInstance("Frame", btn, {
            Name             = "ActiveBar",
            Size             = UDim2.new(0, 3, 0.6, 0),
            Position         = UDim2.new(0, -10, 0.2, 0),
            BackgroundColor3 = theme.accent,
            BorderSizePixel  = 0,
        })
    end

    btn.MouseButton1Click:Connect(function()
        UI.switchTab(name)
    end)

    btn.MouseEnter:Connect(function()
        if name ~= UI.activeTab then
            tweenProperty(btn, "BackgroundTransparency", 0.7, 0.15)
            tweenProperty(btn, "TextColor3", theme.text, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if name ~= UI.activeTab then
            tweenProperty(btn, "BackgroundTransparency", 1, 0.15)
            tweenProperty(btn, "TextColor3", theme.textDim, 0.15)
        end
    end)
end

function UI.switchTab(tabName)
    UI.activeTab = tabName

    -- Refresh sidebar highlights
    for _, child in ipairs(UI.sidebarFrame:GetChildren()) do
        if child:IsA("TextButton") then
            local theme   = ThemeManager.get()
            local active  = child.Name == "Tab_" .. tabName
            tweenProperty(child, "BackgroundTransparency", active and 0 or 1, 0.2)
            tweenProperty(child, "TextColor3", active and theme.text or theme.textDim, 0.2)
            local bar = child:FindFirstChild("ActiveBar")
            if bar then bar:Destroy() end
            if active then
                local newBar = createInstance("Frame", child, {
                    Name             = "ActiveBar",
                    Size             = UDim2.new(0, 3, 0.6, 0),
                    Position         = UDim2.new(0, -10, 0.2, 0),
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel  = 0,
                })
                createInstance("UICorner", newBar, { CornerRadius = UDim.new(1,0) })
            end
        end
    end

    -- Clear content
    for _, child in ipairs(UI.contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    -- Build tab content
    UI.buildTabContent(tabName)

    -- Add recently used
    local found = false
    for _, t in ipairs(UI.recentlyUsed) do if t == tabName then found = true break end end
    if not found then
        table.insert(UI.recentlyUsed, 1, tabName)
        if #UI.recentlyUsed > 8 then table.remove(UI.recentlyUsed) end
    end
end

function UI.buildTabContent(tabName)
    local theme = ThemeManager.get()

    local function header(text)
        local lbl = createInstance("TextLabel", UI.contentFrame, {
            Text             = text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 16,
            TextColor3       = theme.text,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 0, 28),
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 12,
        })
        createInstance("Frame", lbl, {
            Size             = UDim2.new(0, 3, 0.7, 0),
            Position         = UDim2.new(0, -8, 0.15, 0),
            BackgroundColor3 = theme.accent,
            BorderSizePixel  = 0,
        })
        return lbl
    end

    local function sectionHeader(text)
        local cont = createInstance("Frame", UI.contentFrame, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            ZIndex = 12,
        })
        createInstance("TextLabel", cont, {
            Text             = text:upper(),
            Font             = Enum.Font.GothamBold,
            TextSize         = 10,
            TextColor3       = theme.accent,
            BackgroundTransparency = 1,
            Size             = UDim2.new(1, 0, 1, 0),
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 12,
        })
        return cont
    end

    local function featureToggle(featureId, labelText, description)
        local feat  = FeatureManager.registry[featureId]
        if not feat then return end

        local row = createInstance("Frame", UI.contentFrame, {
            BackgroundColor3 = theme.bgSecondary,
            BackgroundTransparency = 0.3,
            Size             = UDim2.new(1, 0, 0, 52),
            BorderSizePixel  = 0,
            ZIndex           = 12,
        })
        createInstance("UICorner", row, { CornerRadius = UDim.new(0, 8) })
        createInstance("UIPadding", row, { PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12) })

        -- Feature name
        createInstance("TextLabel", row, {
            Text             = labelText or feat.name,
            Font             = Enum.Font.GothamMedium,
            TextSize         = 13,
            TextColor3       = theme.text,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.7, 0, 0, 22),
            Position         = UDim2.new(0, 12, 0, 8),
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 13,
        })

        -- Description
        if description or feat.description then
            createInstance("TextLabel", row, {
                Text             = description or feat.description,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = theme.textDim,
                BackgroundTransparency = 1,
                Size             = UDim2.new(0.7, 0, 0, 16),
                Position         = UDim2.new(0, 12, 0, 28),
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 13,
            })
        end

        -- Toggle switch
        local toggleBg = createInstance("Frame", row, {
            Name             = "ToggleBG",
            Size             = UDim2.new(0, 42, 0, 22),
            Position         = UDim2.new(1, -54, 0.5, -11),
            BackgroundColor3 = feat.enabled and theme.accent or theme.border,
            BorderSizePixel  = 0,
            ZIndex           = 13,
        })
        createInstance("UICorner", toggleBg, { CornerRadius = UDim.new(1, 0) })

        local knob = createInstance("Frame", toggleBg, {
            Name             = "Knob",
            Size             = UDim2.new(0, 16, 0, 16),
            Position         = feat.enabled
                and UDim2.new(1, -19, 0.5, -8)
                or  UDim2.new(0,  3,  0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            ZIndex           = 14,
        })
        createInstance("UICorner", knob, { CornerRadius = UDim.new(1, 0) })

        -- Clickable button over toggle
        local toggleBtn = createInstance("TextButton", row, {
            Text             = "",
            BackgroundTransparency = 1,
            Size             = UDim2.new(0, 50, 0, 30),
            Position         = UDim2.new(1, -56, 0.5, -15),
            ZIndex           = 15,
        })

        toggleBtn.MouseButton1Click:Connect(function()
            FeatureManager.toggle(featureId)
            local enabled = FeatureManager.registry[featureId].enabled
            tweenProperty(toggleBg, "BackgroundColor3", enabled and theme.accent or theme.border, 0.2)
            tweenProperty(knob, "Position",
                enabled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                0.2, Enum.EasingStyle.Quart
            )
            table.insert(UI.recentlyUsed, 1, featureId)
        end)

        return row
    end

    local function sliderRow(label, description, minVal, maxVal, currentVal, step, onChange)
        local row = createInstance("Frame", UI.contentFrame, {
            BackgroundColor3 = theme.bgSecondary,
            BackgroundTransparency = 0.3,
            Size             = UDim2.new(1, 0, 0, 66),
            BorderSizePixel  = 0,
            ZIndex           = 12,
        })
        createInstance("UICorner", row, { CornerRadius = UDim.new(0, 8) })
        createInstance("UIPadding", row, { PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12) })

        createInstance("TextLabel", row, {
            Text             = label,
            Font             = Enum.Font.GothamMedium,
            TextSize         = 13,
            TextColor3       = theme.text,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.6, 0, 0, 22),
            Position         = UDim2.new(0, 12, 0, 6),
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 13,
        })
        if description then
            createInstance("TextLabel", row, {
                Text             = description,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextColor3       = theme.textDim,
                BackgroundTransparency = 1,
                Size             = UDim2.new(0.6, 0, 0, 14),
                Position         = UDim2.new(0, 12, 0, 26),
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 13,
            })
        end

        local valLabel = createInstance("TextLabel", row, {
            Text             = tostring(currentVal),
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = theme.accent,
            BackgroundTransparency = 1,
            Size             = UDim2.new(0.3, 0, 0, 22),
            Position         = UDim2.new(0.7, 0, 0, 6),
            TextXAlignment   = Enum.TextXAlignment.Right,
            ZIndex           = 13,
        })

        -- Slider track
        local trackBG = createInstance("Frame", row, {
            Size             = UDim2.new(1, -24, 0, 4),
            Position         = UDim2.new(0, 12, 1, -16),
            BackgroundColor3 = theme.border,
            BorderSizePixel  = 0,
            ZIndex           = 13,
        })
        createInstance("UICorner", trackBG, { CornerRadius = UDim.new(1, 0) })

        local fillPct = (currentVal - minVal) / (maxVal - minVal)
        local trackFill = createInstance("Frame", trackBG, {
            Size             = UDim2.new(fillPct, 0, 1, 0),
            BackgroundColor3 = theme.accent,
            BorderSizePixel  = 0,
            ZIndex           = 14,
        })
        createInstance("UICorner", trackFill, { CornerRadius = UDim.new(1, 0) })

        local thumb = createInstance("Frame", trackBG, {
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = UDim2.new(fillPct, -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel  = 0,
            ZIndex           = 15,
        })
        createInstance("UICorner", thumb, { CornerRadius = UDim.new(1, 0) })

        -- Drag logic
        local dragging = false
        local dragBtn  = createInstance("TextButton", trackBG, {
            Text = "", BackgroundTransparency = 1,
            Size = UDim2.new(1, 12, 3, 0),
            Position = UDim2.new(0, -6, -1, 0),
            ZIndex = 16,
        })
        dragBtn.MouseButton1Down:Connect(function()   dragging = true end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        game:GetService("RunService").Heartbeat:Connect(function()
            if dragging then
                local mouseX = game:GetService("UserInputService"):GetMouseLocation().X
                local absPos  = trackBG.AbsolutePosition.X
                local absSize = trackBG.AbsoluteSize.X
                local t = math.clamp((mouseX - absPos) / absSize, 0, 1)
                local val = minVal + math.floor((t * (maxVal - minVal)) / (step or 1) + 0.5) * (step or 1)
                val = math.clamp(val, minVal, maxVal)
                valLabel.Text = tostring(val)
                trackFill.Size = UDim2.new(t, 0, 1, 0)
                thumb.Position = UDim2.new(t, -6, 0.5, -6)
                if onChange then pcall(onChange, val) end
            end
        end)

        return row
    end

    -- ---- TAB CONTENT BUILDERS ----

    if tabName == "Dashboard" then
        header("Dashboard")
        sectionHeader("Quick Stats")

        -- Stats cards row
        local statsRow = createInstance("Frame", UI.contentFrame, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 80),
            ZIndex = 12,
        })
        createInstance("UIListLayout", statsRow, {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder     = Enum.SortOrder.LayoutOrder,
            Padding       = UDim.new(0, 8),
        })

        local statsCards = {
            { label = "Active Features", value = tostring(#(function() local n=0 for _ in pairs(Core.activeFeatures) do n=n+1 end return {} end)()), color = theme.accent },
            { label = "FPS",             value = tostring(Performance.fps),       color = theme.success },
            { label = "K/D",             value = tostring(Statistics.getKD()),     color = theme.info },
            { label = "Coins",           value = tostring(Statistics.coinsCollected), color = theme.warning },
        }

        for i, card in ipairs(statsCards) do
            local c = createInstance("Frame", statsRow, {
                BackgroundColor3 = theme.bgSecondary,
                BackgroundTransparency = 0.3,
                Size = UDim2.new(0.25, -6, 1, 0),
                BorderSizePixel = 0,
                LayoutOrder = i,
                ZIndex = 13,
            })
            createInstance("UICorner", c, { CornerRadius = UDim.new(0, 8) })
            createInstance("TextLabel", c, {
                Text = card.value,
                Font = Enum.Font.GothamBold,
                TextSize = 22,
                TextColor3 = card.color,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0.55, 0),
                Position = UDim2.new(0, 0, 0.05, 0),
                ZIndex = 14,
            })
            createInstance("TextLabel", c, {
                Text = card.label,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = theme.textDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 0, 18),
                Position = UDim2.new(0, 8, 0.6, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 14,
            })
        end

        sectionHeader("Recently Used")
        if #UI.recentlyUsed == 0 then
            createInstance("TextLabel", UI.contentFrame, {
                Text = "No recently used features.",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.textDim,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12,
            })
        end
        sectionHeader("Session Info")
        local sessionTime = math.floor(os.clock() - Core.sessionStart)
        createInstance("TextLabel", UI.contentFrame, {
            Text = string.format("Session time: %dm %ds  |  Executor: %s  |  Platform: %s",
                math.floor(sessionTime/60), sessionTime%60,
                Platform.executor, Platform.os),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = theme.textDim,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12,
        })

    elseif tabName == "ESP" then
        header("ESP")
        sectionHeader("Players")
        featureToggle("esp_player",   "Player ESP",    "Highlight all players")
        featureToggle("esp_murderer", "Murderer ESP",  "Highlight murderers")
        featureToggle("esp_sheriff",  "Sheriff ESP",   "Highlight sheriffs")
        featureToggle("esp_hero",     "Hero ESP",      "Highlight heroes")
        featureToggle("esp_innocent", "Innocent ESP",  "Highlight innocents")
        featureToggle("esp_role",     "Role ESP",      "Show roles above players")
        featureToggle("esp_name",     "Name ESP",      "Show player names")
        featureToggle("esp_distance", "Distance ESP",  "Show distance to players")
        featureToggle("esp_health",   "Health ESP",    "Show player health bars")
        sectionHeader("Visual Style")
        featureToggle("esp_box",      "Box ESP",       "Draw boxes around players")
        featureToggle("esp_corner_box","Corner Box",   "Corner-style boxes")
        featureToggle("esp_skeleton", "Skeleton ESP",  "Draw player skeletons")
        featureToggle("esp_tracer",   "Tracer ESP",    "Draw tracer lines to players")
        featureToggle("esp_chams",    "Chams",         "Color players through walls")
        featureToggle("esp_rainbow",  "Rainbow ESP",   "Rainbow color cycling ESP")
        sectionHeader("Items & World")
        featureToggle("esp_gun",      "Gun ESP",       "Highlight guns")
        featureToggle("esp_knife",    "Knife ESP",     "Highlight knives")
        featureToggle("esp_coin",     "Coin ESP",      "Highlight coins")
        featureToggle("esp_item",     "Item ESP",      "Highlight all items")
        featureToggle("esp_drop",     "Dropped Items", "Highlight dropped items")
        featureToggle("esp_dead",     "Dead Players",  "Show dead players")
        featureToggle("esp_offscreen","Off-Screen Arrows","Arrow indicators for off-screen")
        sectionHeader("Settings")
        sliderRow("ESP Range", "Maximum detection distance", 50, 2000, Config.get("espRange") or 500, 50, function(v) Config.set("espRange", v) end)
        sliderRow("ESP Thickness", "Line thickness", 1, 5, 1, 1, function(v) Config.set("espThickness", v) end)

    elseif tabName == "Combat" then
        header("Combat")
        sectionHeader("Aimbot")
        featureToggle("combat_aimbot",      "Aimbot",           "Full aimbot assistance")
        featureToggle("combat_silentaim",   "Silent Aim",       "Silent aim assistance")
        featureToggle("combat_autotarget",  "Auto Target",      "Automatically acquire targets")
        sliderRow("Aim FOV", "Field of view for aim assist", 10, 180, Config.get("aimFOV") or 90, 5, function(v) Config.set("aimFOV", v) end)
        sectionHeader("Auto Actions")
        featureToggle("combat_autoshoot",   "Auto Shoot",       "Automatically shoot when target locked")
        featureToggle("combat_autostab",    "Auto Stab",        "Automatically stab with knife")
        featureToggle("combat_autothrow",   "Auto Throw",       "Automatically throw knives")
        featureToggle("combat_autofling",   "Auto Fling",       "Automatically fling targets")
        sectionHeader("Extended")
        featureToggle("combat_reach",       "Reach",            "Extended melee reach")
        featureToggle("combat_hitbox",      "Hitbox Expander",  "Expand target hitboxes")
        featureToggle("combat_hitbox_vis",  "Hitbox Visualizer","Visualize hitboxes")
        featureToggle("combat_damage_indicator","Damage Indicator","Show damage dealt")
        sectionHeader("Presets")
        featureToggle("combat_rage_preset", "Rage Preset",      "Maximum aggression preset")
        featureToggle("combat_legit_preset","Legit Preset",     "Subtle assistance preset")

    elseif tabName == "Movement" then
        header("Movement")
        sectionHeader("Speed")
        featureToggle("move_speed",    "Speed Hack",    "Increase walk speed")
        sliderRow("Walk Speed", "Character walk speed", 8, 300, Config.get("walkSpeed") or 16, 1, function(v) Config.set("walkSpeed", v) end)
        featureToggle("move_bunnyhop", "Bunny Hop",     "Automatic bunny hop")
        sectionHeader("Jump")
        featureToggle("move_infjump",  "Infinite Jump", "Jump infinitely in air")
        featureToggle("move_autojump", "Auto Jump",     "Automatically jump")
        sliderRow("Jump Power", "Character jump height", 25, 500, Config.get("jumpPower") or 50, 5, function(v) Config.set("jumpPower", v) end)
        sectionHeader("Flight")
        featureToggle("move_fly",      "Fly",           "Enable flight")
        featureToggle("move_noclip",   "Noclip",        "Phase through walls")
        featureToggle("move_airwalk",  "Air Walk",      "Walk on air")
        sectionHeader("Utility")
        featureToggle("move_dash",     "Dash",          "Quick dash ability")
        featureToggle("move_tpwalk",   "TP Walk",       "Teleport-based movement")
        featureToggle("move_spin",     "Spin",          "Character spin")
        featureToggle("move_autodoge", "Auto Dodge",    "Automatically dodge attacks")
        featureToggle("move_freecam",  "Freecam",       "Detached free camera")
        featureToggle("move_gravity",  "Gravity Control","Modify gravity")
        featureToggle("move_thirdperson","Third Person", "Third-person camera mode")

    elseif tabName == "Farm" then
        header("Farm")
        sectionHeader("Auto Farm")
        featureToggle("farm_autofarm",    "Auto Farm",        "Full auto-farm loop")
        featureToggle("farm_autocollect", "Auto Collect",     "Automatically collect coins")
        featureToggle("farm_coin_farm",   "Coin Farm",        "Farm coins automatically")
        featureToggle("farm_coin_aura",   "Coin Aura",        "Collect nearby coins passively")
        sectionHeader("Finders")
        featureToggle("farm_item_finder", "Item Finder",      "Locate items on map")
        featureToggle("farm_gun_finder",  "Gun Finder",       "Locate guns on map")
        sectionHeader("Session Stats")
        createInstance("TextLabel", UI.contentFrame, {
            Text = string.format("Coins collected this session: %d", Statistics.coinsCollected),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = theme.textDim, BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,24), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })

    elseif tabName == "Intelligence" then
        header("Intelligence")
        sectionHeader("Detectors")
        featureToggle("intel_role_detect",     "Role Detector",     "Detect player roles")
        featureToggle("intel_murderer_detect", "Murderer Detector", "Identify murderer")
        featureToggle("intel_sheriff_detect",  "Sheriff Detector",  "Identify sheriff")
        featureToggle("intel_round_detect",    "Round Detector",    "Detect round state")
        featureToggle("intel_gun_drop",        "Gun Drop Detector", "Detect dropped guns")
        sectionHeader("Alerts")
        featureToggle("intel_murderer_alert",  "Murderer Alert",    "Alert when murderer identified")
        featureToggle("intel_gun_alert",       "Gun Drop Alert",    "Alert when gun dropped")

    elseif tabName == "Targets" then
        header("Target Manager")
        sectionHeader("Target Filters")
        sliderRow("Max Distance", "Maximum target distance", 10, 2000, TargetManager.filters.maxDistance, 10, function(v) TargetManager.filters.maxDistance = v end)
        sectionHeader("Ignore Rules")
        -- Simple toggles that adjust filters
        local ignoreDeadRow = createInstance("Frame", UI.contentFrame, {
            BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.3,
            Size = UDim2.new(1,0,0,44), BorderSizePixel = 0, ZIndex = 12,
        })
        createInstance("UICorner", ignoreDeadRow, { CornerRadius = UDim.new(0,8) })
        createInstance("TextLabel", ignoreDeadRow, {
            Text = "Ignore Dead Players",
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = theme.text, BackgroundTransparency = 1,
            Size = UDim2.new(0.8,0,1,0), Position = UDim2.new(0,12,0,0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
        })
        sectionHeader("Whitelist / Blacklist")
        createInstance("TextLabel", UI.contentFrame, {
            Text = "Use TargetManager.addToWhitelist(name) / addToBlacklist(name) in console.",
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = theme.textDim, BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,24), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })

    elseif tabName == "Visual" then
        header("Visual")
        sectionHeader("Crosshair")
        featureToggle("visual_crosshair",  "Crosshair",     "Custom crosshair overlay")
        sectionHeader("Effects")
        featureToggle("visual_hit_effects", "Hit Effects",  "Visual hit effects")
        featureToggle("visual_kill_effects","Kill Effects",  "Visual kill effects")
        featureToggle("visual_cam_shake",  "Camera Shake",  "Camera shake on hit")
        sectionHeader("Camera")
        featureToggle("visual_fov_slider", "FOV Slider",    "Adjust camera FOV")
        featureToggle("visual_thirdperson","Third Person",  "Third-person visual mode")
        featureToggle("visual_ui_blur",    "UI Blur",       "Blur background behind UI")

    elseif tabName == "Misc" then
        header("Misc")
        sectionHeader("Interface")
        featureToggle("misc_hide_ui",      "Hide UI",          "Toggle UI visibility")
        featureToggle("misc_screenshot",   "Screenshot Mode",  "Hide UI for screenshots")
        featureToggle("misc_streamer",     "Streamer Mode",    "Streamer-safe mode")
        sectionHeader("Monitoring")
        featureToggle("misc_fps_monitor",  "FPS Monitor",      "Display FPS counter")
        featureToggle("misc_ping_monitor", "Ping Monitor",     "Display ping counter")
        featureToggle("misc_notifs",       "Notifications",    "In-game notifications")
        sectionHeader("Developer")
        featureToggle("misc_debug",        "Debug Mode",       "Show debug information")
        featureToggle("misc_perf_mode",    "Performance Mode", "Optimize for performance")
        featureToggle("misc_session_log",  "Session Logger",   "Log session events")

    elseif tabName == "Statistics" then
        header("Statistics")
        local stats = {
            { label = "Total Kills",     value = Statistics.totalKills },
            { label = "Total Deaths",    value = Statistics.totalDeaths },
            { label = "K/D Ratio",       value = Statistics.getKD() },
            { label = "Coins Collected", value = Statistics.coinsCollected },
            { label = "Rounds Played",   value = Statistics.roundsPlayed },
            { label = "Rounds Won",      value = Statistics.roundsWon },
            { label = "Rounds Lost",     value = Statistics.roundsLost },
            { label = "Murderer Wins",   value = Statistics.murdererWins },
            { label = "Sheriff Wins",    value = Statistics.sheriffWins },
            { label = "Innocent Wins",   value = Statistics.innocentWins },
            { label = "Best Streak",     value = Statistics.bestStreak },
            { label = "Current Streak",  value = Statistics.currentStreak },
            { label = "Average FPS",     value = Performance.fps },
        }
        for _, s in ipairs(stats) do
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.4,
                Size = UDim2.new(1,0,0,36), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,8) })
            createInstance("TextLabel", row, {
                Text = s.label,
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = theme.textDim, BackgroundTransparency = 1,
                Size = UDim2.new(0.6,0,1,0), Position = UDim2.new(0,12,0,0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            })
            createInstance("TextLabel", row, {
                Text = tostring(s.value),
                Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = theme.accent, BackgroundTransparency = 1,
                Size = UDim2.new(0.35,0,1,0), Position = UDim2.new(0.62,0,0,0),
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
            })
        end

    elseif tabName == "Server" then
        header("Server Info")
        ServerInfo.refresh()
        local serverData = {
            { "Job ID",        ServerInfo.jobId ~= "" and ServerInfo.jobId:sub(1,12) .. "..." or "N/A" },
            { "Players",       ServerInfo.playerCount .. " / " .. ServerInfo.maxPlayers },
            { "Ping",          tostring(Performance.ping) .. " ms" },
            { "FPS",           tostring(Performance.fps) },
            { "Executor",      Platform.executor },
            { "Platform",      Platform.os },
        }
        for _, d in ipairs(serverData) do
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.4,
                Size = UDim2.new(1,0,0,36), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,8) })
            createInstance("TextLabel", row, {
                Text = d[1], Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = theme.textDim, BackgroundTransparency = 1,
                Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0,12,0,0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            })
            createInstance("TextLabel", row, {
                Text = d[2], Font = Enum.Font.GothamBold, TextSize = 12,
                TextColor3 = theme.text, BackgroundTransparency = 1,
                Size = UDim2.new(0.45,0,1,0), Position = UDim2.new(0.52,0,0,0),
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
            })
        end

    elseif tabName == "Themes" then
        header("Themes")
        sectionHeader("Select Theme")
        for themeName, _ in pairs(ThemeManager.themes) do
            local isActive = (ThemeManager.current == themeName)
            local btn = createInstance("TextButton", UI.contentFrame, {
                Text             = themeName .. (isActive and "  ✓" or ""),
                Font             = Enum.Font.GothamMedium,
                TextSize         = 13,
                TextColor3       = isActive and theme.accent or theme.text,
                BackgroundColor3 = isActive and theme.bgTertiary or theme.bgSecondary,
                BackgroundTransparency = isActive and 0 or 0.4,
                Size             = UDim2.new(1,0,0,40),
                BorderSizePixel  = 0,
                ZIndex           = 12,
            })
            createInstance("UICorner", btn, { CornerRadius = UDim.new(0,8) })
            btn.MouseButton1Click:Connect(function()
                ThemeManager.set(themeName)
                UI.switchTab("Themes")
            end)
        end

    elseif tabName == "Config" then
        header("Configuration")
        sectionHeader("Startup")

        local function configToggle(configKey, label, description)
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.3,
                Size = UDim2.new(1,0,0,52), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,8) })
            createInstance("UIPadding", row, { PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12) })
            createInstance("TextLabel", row, {
                Text = label, Font = Enum.Font.GothamMedium, TextSize = 13,
                TextColor3 = theme.text, BackgroundTransparency = 1,
                Size = UDim2.new(0.7,0,0,22), Position = UDim2.new(0,12,0,8),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            })
            if description then
                createInstance("TextLabel", row, {
                    Text = description, Font = Enum.Font.Gotham, TextSize = 11,
                    TextColor3 = theme.textDim, BackgroundTransparency = 1,
                    Size = UDim2.new(0.7,0,0,16), Position = UDim2.new(0,12,0,28),
                    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
                })
            end
            local val = Config.get(configKey)
            local toggleBg = createInstance("Frame", row, {
                Size = UDim2.new(0,42,0,22), Position = UDim2.new(1,-54,0.5,-11),
                BackgroundColor3 = val and theme.accent or theme.border,
                BorderSizePixel = 0, ZIndex = 13,
            })
            createInstance("UICorner", toggleBg, { CornerRadius = UDim.new(1,0) })
            local knob = createInstance("Frame", toggleBg, {
                Size = UDim2.new(0,16,0,16),
                Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, ZIndex = 14,
            })
            createInstance("UICorner", knob, { CornerRadius = UDim.new(1,0) })
            local tBtn = createInstance("TextButton", row, {
                Text="", BackgroundTransparency=1,
                Size=UDim2.new(0,50,0,30), Position=UDim2.new(1,-56,0.5,-15), ZIndex=15,
            })
            tBtn.MouseButton1Click:Connect(function()
                local newVal = not Config.get(configKey)
                Config.set(configKey, newVal)
                tweenProperty(toggleBg, "BackgroundColor3", newVal and theme.accent or theme.border, 0.2)
                tweenProperty(knob, "Position", newVal and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), 0.2)
            end)
        end

        configToggle("startupAnimation",     "Startup Animation",       "Show animated startup screen")
        configToggle("showLoadingDetails",   "Show Loading Details",    "Show step-by-step loading text")
        configToggle("showLogo",             "Show Logo",               "Display KURAI logo on startup")
        configToggle("showProgressBar",      "Show Progress Bar",       "Display loading progress bar")
        sliderRow("Animation Speed", "Startup animation speed multiplier", 0.5, 3.0, Config.get("animationSpeed") or 1.0, 0.1, function(v) Config.set("animationSpeed", v) end)
        sectionHeader("Data")
        local saveBtn = createInstance("TextButton", UI.contentFrame, {
            Text = "Save Configuration",
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = theme.text, BackgroundColor3 = theme.accent,
            BackgroundTransparency = 0.2, Size = UDim2.new(1,0,0,40),
            BorderSizePixel = 0, ZIndex = 12,
        })
        createInstance("UICorner", saveBtn, { CornerRadius = UDim.new(0,8) })
        saveBtn.MouseButton1Click:Connect(function()
            Config.save()
            NotificationManager.send("Config", "Configuration saved.", "SUCCESS", 2)
        end)
        local resetBtn = createInstance("TextButton", UI.contentFrame, {
            Text = "Reset to Defaults",
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = theme.danger, BackgroundColor3 = theme.bgSecondary,
            BackgroundTransparency = 0.3, Size = UDim2.new(1,0,0,40),
            BorderSizePixel = 0, ZIndex = 12,
        })
        createInstance("UICorner", resetBtn, { CornerRadius = UDim.new(0,8) })
        resetBtn.MouseButton1Click:Connect(function()
            Config.reset()
            NotificationManager.send("Config", "Reset to defaults.", "INFO", 2)
            UI.switchTab("Config")
        end)

    elseif tabName == "Performance" then
        header("Performance")
        sectionHeader("Current Metrics")
        local metrics = {
            { "FPS",        tostring(Performance.fps) },
            { "Ping",       tostring(Performance.ping) .. " ms" },
            { "Memory",     tostring(math.floor(gcinfo() / 1024)) .. " MB" },
            { "Session",    string.format("%dm %ds", math.floor((os.clock()-Core.sessionStart)/60), math.floor(os.clock()-Core.sessionStart)%60) },
        }
        for _, m in ipairs(metrics) do
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.4,
                Size = UDim2.new(1,0,0,36), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,8) })
            createInstance("TextLabel", row, {
                Text = m[1], Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = theme.textDim, BackgroundTransparency = 1,
                Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0,12,0,0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            })
            createInstance("TextLabel", row, {
                Text = m[2], Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = theme.success, BackgroundTransparency = 1,
                Size = UDim2.new(0.4,0,1,0), Position = UDim2.new(0.57,0,0,0),
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
            })
        end

    elseif tabName == "Compatibility" then
        header("Compatibility Matrix")
        sectionHeader("Detected Environment")
        createInstance("TextLabel", UI.contentFrame, {
            Text = string.format("Platform: %s  |  Executor: %s", Platform.os, Platform.executor),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = theme.textDim, BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,24), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
        sectionHeader("Capability Status")
        local caps = {
            { name = "UI System",   cap = Platform.capabilities.ui },
            { name = "Drawing",     cap = Platform.capabilities.drawing },
            { name = "Filesystem",  cap = Platform.capabilities.filesystem },
            { name = "Network",     cap = Platform.capabilities.network },
            { name = "Input",       cap = Platform.capabilities.input },
            { name = "Movement",    cap = Platform.capabilities.movement },
            { name = "Combat",      cap = Platform.capabilities.combat },
            { name = "Config",      cap = Platform.capabilities.config },
        }
        for _, c in ipairs(caps) do
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.4,
                Size = UDim2.new(1,0,0,34), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,8) })
            createInstance("TextLabel", row, {
                Text = c.name, Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = theme.text, BackgroundTransparency = 1,
                Size = UDim2.new(0.6,0,1,0), Position = UDim2.new(0,12,0,0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
            })
            local statusText = c.cap and "SUPPORTED" or "UNAVAILABLE"
            local statusColor = c.cap and theme.success or theme.danger
            createInstance("TextLabel", row, {
                Text = statusText, Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = statusColor, BackgroundTransparency = 1,
                Size = UDim2.new(0.35,0,1,0), Position = UDim2.new(0.62,0,0,0),
                TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
            })
        end

    elseif tabName == "Logs" then
        header("Logs")
        sectionHeader("Recent Entries")
        local logEntries = Core.logs
        local shown = math.min(#logEntries, 60)
        for i = #logEntries, math.max(#logEntries - shown, 0) + 1, -1 do
            local entry = logEntries[i]
            local row = createInstance("Frame", UI.contentFrame, {
                BackgroundColor3 = theme.bgSecondary, BackgroundTransparency = 0.5,
                Size = UDim2.new(1,0,0,30), BorderSizePixel = 0, ZIndex = 12,
            })
            createInstance("UICorner", row, { CornerRadius = UDim.new(0,6) })
            local color = theme.textDim
            if entry.level == "ERROR"   then color = theme.danger
            elseif entry.level == "WARN" then color = theme.warning
            end
            createInstance("TextLabel", row, {
                Text = string.format("[%.1fs] [%s] %s", entry.timestamp, entry.category, entry.message),
                Font = Enum.Font.Code, TextSize = 10,
                TextColor3 = color, BackgroundTransparency = 1,
                Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,8,0,0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 13,
            })
        end
        if #logEntries == 0 then
            createInstance("TextLabel", UI.contentFrame, {
                Text = "No log entries yet.",
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = theme.textDim, BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,28), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
            })
        end
    end
end

-- ---- Show / Hide ----

function UI.show()
    if UI.dashboardFrame then
        UI.dashboardFrame.Visible = true
        if UI.shadowFrame then UI.shadowFrame.Visible = true end
        UI.dashboardFrame.BackgroundTransparency = 1
        tweenProperty(UI.dashboardFrame, "BackgroundTransparency", 0.02, 0.35)
        UI.isVisible = true
    end
end

function UI.hide()
    if UI.dashboardFrame then
        tweenProperty(UI.dashboardFrame, "BackgroundTransparency", 1, 0.3)
        task.delay(0.35, function()
            if UI.dashboardFrame then UI.dashboardFrame.Visible = false end
            if UI.shadowFrame then UI.shadowFrame.Visible = false end
        end)
        UI.isVisible = false
    end
end

function UI.toggleVisibility()
    if UI.isVisible then UI.hide() else UI.show() end
end

-- ---- Build root GUI ----

function UI.init()
    if not game or not game:GetService("Players") then
        Logger.log("UI", "Not in Roblox environment. UI skipped.")
        return false
    end

    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    if not lp then return false end

    local playerGui = lp:WaitForChild("PlayerGui", 5)
    if not playerGui then return false end

    -- Destroy existing
    local existing = playerGui:FindFirstChild("KuraiSoftwareUI")
    if existing then existing:Destroy() end

    local gui = createInstance("ScreenGui", playerGui, {
        Name             = "KuraiSoftwareUI",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 999,
    })
    UI.gui = gui

    return true
end

-- ============================================================
-- [TOGGLE KEYBIND] — RightControl to show/hide dashboard
-- ============================================================

local function setupToggleKeybind()
    if game and game:GetService("UserInputService") then
        local UIS = game:GetService("UserInputService")
        local conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.RightControl then
                UI.toggleVisibility()
            end
            if input.KeyCode == Enum.KeyCode.End then
                PanicButton.activate()
            end
        end)
        table.insert(Core.connections, conn)
        CleanupManager.register("ToggleKeybind", function() conn:Disconnect() end)
    end
end

-- ============================================================
-- [MAIN BOOT SEQUENCE]
-- ============================================================

function KuraiSoftware.init()
    -- Step 1: Platform detection
    local ok1, err1 = pcall(Platform.detect)
    if not ok1 then Logger.error("Boot", "Platform.detect", err1) end

    -- Step 2: Config load
    local ok2, err2 = pcall(Config.load)
    if not ok2 then Logger.error("Boot", "Config.load", err2) end

    -- Step 3: Register features
    local ok3, err3 = pcall(registerAllFeatures)
    if not ok3 then Logger.error("Boot", "registerAllFeatures", err3) end

    -- Step 4: Performance monitor
    local ok4, err4 = pcall(Performance.start)
    if not ok4 then Logger.error("Boot", "Performance.start", err4) end

    -- Step 5: UI init
    local uiReady = false
    local ok5, err5 = pcall(function() uiReady = UI.init() end)
    if not ok5 then Logger.error("Boot", "UI.init", err5) end

    if not uiReady then
        -- Headless mode: just log and continue
        Logger.log("Boot", "Running in headless mode (no UI environment).")
        Logger.log("Boot", "Kurai Software initialized (headless).")
        Core.initialized = true
        return
    end

    -- Check startup animation preference
    if not Config.get("startupAnimation") then
        -- Skip straight to dashboard
        UI.buildDashboard()
        UI.show()
        KeybindManager.init()
        setupToggleKeybind()
        Core.initialized = true
        Logger.log("Boot", "Kurai Software ready (animation skipped).")
        return
    end

    -- Step 6: Build startup screen
    local elements
    local ok6, err6 = pcall(function() elements = UI.buildStartupScreen() end)
    if not ok6 then
        Logger.error("Boot", "UI.buildStartupScreen", err6)
        -- Fallback: go straight to dashboard
        UI.buildDashboard()
        UI.show()
        return
    end

    -- Step 7: Play startup animation, then reveal dashboard
    task.spawn(function()
        local ok7, err7 = pcall(function()
            UI.playStartupAnimation(elements, function()
                -- Build dashboard while startup was running cleanup
                local okD, errD = pcall(UI.buildDashboard)
                if not okD then Logger.error("Boot", "UI.buildDashboard", errD) end
                UI.show()
                KeybindManager.init()
                setupToggleKeybind()
                Core.initialized = true
                Logger.log("Boot", "Kurai Software ready.")
                NotificationManager.send("Kurai Software", "Ready. Press RightCtrl to toggle.", "INFO", 4)
            end)
        end)
        if not ok7 then
            Logger.error("Boot", "StartupAnimation", err7)
            local okD2, errD2 = pcall(UI.buildDashboard)
            if not okD2 then Logger.error("Boot", "UI.buildDashboard(fallback)", errD2) end
            UI.show()
            Core.initialized = true
        end
    end)
end

-- ============================================================
-- [EXPORTS] — Expose public API on KuraiSoftware table
-- ============================================================

KuraiSoftware.Core            = Core
KuraiSoftware.Platform        = Platform
KuraiSoftware.Config          = Config
KuraiSoftware.Logger          = Logger
KuraiSoftware.EventManager    = EventManager
KuraiSoftware.CleanupManager  = CleanupManager
KuraiSoftware.FeatureManager  = FeatureManager
KuraiSoftware.KeybindManager  = KeybindManager
KuraiSoftware.NotificationManager = NotificationManager
KuraiSoftware.Performance     = Performance
KuraiSoftware.Statistics      = Statistics
KuraiSoftware.ThemeManager    = ThemeManager
KuraiSoftware.TargetManager   = TargetManager
KuraiSoftware.ServerInfo      = ServerInfo
KuraiSoftware.PanicButton     = PanicButton
KuraiSoftware.UI              = UI

-- ============================================================
-- [ENTRY POINT]
-- ============================================================

KuraiSoftware.init()

return KuraiSoftware
