-- ══════════════════════════════════════════════
-- KARMAN SCRIPT v1.0
-- Multi-Game: TSB + DOORS
-- ══════════════════════════════════════════════

local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

------------------------------------------------
-- GAME DETECTION
------------------------------------------------
local PlaceId = game.PlaceId
local GameId  = game.GameId

local GAMES = {
    TSB = {
        placeIds = {
            4476116877, -- alt / ggf. lobby
            6456828791  -- alt
        },
        gameId = 10449761463 -- ✅ The Strongest Battlegrounds UniverseId
    },

    DOORS = {
        placeIds = {
            6516141723, -- Lobby
            6839171747  -- Hotel / Run
        },
        gameId = 2440500124 -- ✅ DOORS UniverseId
    }
}

local function detectGame()
    for name, data in pairs(GAMES) do
        -- Check PlaceIds
        for _, id in ipairs(data.placeIds) do
            if PlaceId == id then
                return name
            end
        end

        -- Check GameId (wichtig bei Teleports)
        if GameId == data.gameId then
            return name
        end
    end

    -- 🔥 SMART FALLBACK (falls Roblox wieder Unsinn macht)
    if workspace:FindFirstChild("CurrentRooms") then
        return "DOORS"
    end

    if workspace:FindFirstChild("Characters") then
        return "TSB"
    end

    return "UNKNOWN"
end

local GAME = detectGame()

------------------------------------------------
-- FARBEN & DESIGN
------------------------------------------------
local C = {
    bg      = Color3.fromRGB(8,  8,  15),
    panel   = Color3.fromRGB(14, 14, 26),
    card    = Color3.fromRGB(20, 20, 36),
    cardH   = Color3.fromRGB(28, 28, 50),
    acc     = Color3.fromRGB(110, 180, 255),  -- Blau (Default)
    acc2    = Color3.fromRGB(80,  130, 220),
    green   = Color3.fromRGB(75,  215, 125),
    red     = Color3.fromRGB(255, 75,  75),
    orange  = Color3.fromRGB(255, 160, 50),
    yellow  = Color3.fromRGB(255, 210, 60),
    off     = Color3.fromRGB(40,  40,  60),
    text    = Color3.fromRGB(230, 230, 255),
    sub     = Color3.fromRGB(120, 120, 155),
    white   = Color3.new(1,1,1),
    black   = Color3.fromRGB(5,5,10),
}

-- Spiel-spezifische Akzentfarben
if GAME == "TSB" then
    C.acc  = Color3.fromRGB(255, 185, 50)
    C.acc2 = Color3.fromRGB(255, 75,  45)
elseif GAME == "DOORS" then
    C.acc  = Color3.fromRGB(180, 110, 255)
    C.acc2 = Color3.fromRGB(110, 200, 255)
end

-- Custom Symbole
local S = {
    dot    = "◆", star   = "✦", eye    = "◉",
    arrow  = "➤", cross  = "✕", check  = "✔",
    shield = "⬡", bolt   = "⚡", sword  = "⟁",
    door   = "⊞", skull  = "◈", wave   = "≋",
    warn   = "▲", lock   = "⊘", key    = "⊕",
    gem    = "⬟", chart  = "▣", music  = "♪",
}

------------------------------------------------
-- SCREEN GUI
------------------------------------------------
local GUI = Instance.new("ScreenGui")
GUI.Name = "KarmanScript"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local GW = isMobile and 310 or 420
local GH = isMobile and 460 or 540
local FL = isMobile and 11 or 13
local FS = isMobile and 9  or 10
local CH = isMobile and 38 or 44

------------------------------------------------
-- SOUND HELPER
------------------------------------------------
local function uiSnd(p)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://6042053626"
    s.Volume = 0.25
    s.PlaybackSpeed = p or 1
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 3)
end

------------------------------------------------
-- OPEN BUTTON
------------------------------------------------
local OB = Instance.new("Frame", GUI)
OB.Size = UDim2.new(0, 50, 0, 50)
OB.Position = UDim2.new(0, 10, 0.5, -25)
OB.BackgroundColor3 = C.bg
OB.BorderSizePixel = 0
OB.ZIndex = 10
OB.Visible = true
Instance.new("UICorner", OB).CornerRadius = UDim.new(1, 0)

local OBStr = Instance.new("UIStroke", OB)
OBStr.Thickness = 2
OBStr.Color = C.acc

local OBLbl = Instance.new("TextLabel", OB)
OBLbl.Size = UDim2.new(1,0,1,0)
OBLbl.BackgroundTransparency = 1
OBLbl.Text = GAME == "TSB" and "⚡" or GAME == "DOORS" and "⊞" or "◈"
OBLbl.TextScaled = true
OBLbl.Font = Enum.Font.GothamBold
OBLbl.ZIndex = 11

local OBC = Instance.new("TextButton", OB)
OBC.Size = UDim2.new(1,0,1,0)
OBC.BackgroundTransparency = 1
OBC.Text = ""
OBC.ZIndex = 12

-- Ring-Animation
task.spawn(function()
    local t = 0
    while true do
        t = t + 0.03
        OBStr.Color = C.acc:Lerp(C.acc2, (math.sin(t)+1)/2)
        task.wait(0.04)
    end
end)

-- Drag
local obDrag, obStart, obPos, obMoved
OBC.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        obDrag=true obStart=i.Position obPos=OB.Position obMoved=false
    end
end)
UIS.InputChanged:Connect(function(i)
    if obDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-obStart
        if math.abs(d.X)>4 or math.abs(d.Y)>4 then obMoved=true end
        OB.Position=UDim2.new(obPos.X.Scale,obPos.X.Offset+d.X,obPos.Y.Scale,obPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        obDrag=false
    end
end)

------------------------------------------------
-- MAIN FRAME
------------------------------------------------
local MF = Instance.new("Frame", GUI)
MF.Size = UDim2.new(0,GW,0,GH)
MF.Position = UDim2.new(0.5,-GW/2,0.5,-GH/2)
MF.BackgroundColor3 = C.bg
MF.BorderSizePixel = 0
MF.ClipsDescendants = false
MF.Visible = false
MF.ZIndex = 20
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 14)

local MFStr = Instance.new("UIStroke", MF)
MFStr.Thickness = 1.5
MFStr.Color = C.acc
MFStr.Transparency = 0.25

task.spawn(function()
    local t=0 while true do t=t+0.025
        MFStr.Color=C.acc:Lerp(C.acc2,(math.sin(t)+1)/2) task.wait(0.04)
    end
end)

-- BG Gradient
local BGGrad = Instance.new("UIGradient", MF)
BGGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8,8,16)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,8,20)),
})
BGGrad.Rotation = 135

------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------
local isOpen = false

local function openUI()
    isOpen = true
    MF.Size = UDim2.new(0,0,0,0)
    MF.Position = UDim2.new(0.5,0,0.5,0)
    MF.Visible = true
    uiSnd(1.3)
    TweenService:Create(MF, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {
        Size = UDim2.new(0,GW,0,GH),
        Position = UDim2.new(0.5,-GW/2,0.5,-GH/2),
    }):Play()
end

local function closeUI()
    isOpen = false
    uiSnd(0.85)
    TweenService:Create(MF, TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.In), {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
    }):Play()
    task.wait(0.3)
    if not isOpen then MF.Visible = false end
end

OBC.MouseButton1Click:Connect(function()
    if not obMoved then if isOpen then closeUI() else openUI() end end
end)

-- Keybind: RightShift öffnet/schließt UI
UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then
        if isOpen then closeUI() else openUI() end
    end
end)

------------------------------------------------
-- HEADER
------------------------------------------------
local Hdr = Instance.new("Frame", MF)
Hdr.Size = UDim2.new(1,0,0,56)
Hdr.BackgroundColor3 = C.panel
Hdr.BorderSizePixel = 0
Hdr.ZIndex = 21
Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0,14)

local HGrad = Instance.new("UIGradient", Hdr)
HGrad.Rotation = 90
HGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, GAME=="TSB" and Color3.fromRGB(22,10,4) or GAME=="DOORS" and Color3.fromRGB(12,6,22) or Color3.fromRGB(6,10,22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,8,18)),
})

-- Spiel-Icon
local HIcon = Instance.new("TextLabel", Hdr)
HIcon.Size = UDim2.new(0,40,0,40)
HIcon.Position = UDim2.new(0,9,0.5,-20)
HIcon.BackgroundTransparency = 1
HIcon.Text = GAME=="TSB" and "⚡" or GAME=="DOORS" and "⊞" or "◈"
HIcon.TextScaled = true
HIcon.Font = Enum.Font.GothamBold
HIcon.TextColor3 = C.acc
HIcon.ZIndex = 22

-- Titel
local HTit = Instance.new("TextLabel", Hdr)
HTit.Size = UDim2.new(0,160,0,20)
HTit.Position = UDim2.new(0,54,0,9)
HTit.BackgroundTransparency = 1
HTit.Text = "KARMAN SCRIPT"
HTit.Font = Enum.Font.GothamBold
HTit.TextSize = isMobile and 13 or 15
HTit.TextXAlignment = Enum.TextXAlignment.Left
HTit.ZIndex = 22
Instance.new("UIGradient", HTit).Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.acc),
    ColorSequenceKeypoint.new(1, C.acc2),
})

-- Spiel-Badge
local HBadge = Instance.new("Frame", Hdr)
HBadge.Size = UDim2.new(0,80,0,16)
HBadge.Position = UDim2.new(0,54,0,31)
HBadge.BackgroundColor3 = GAME=="TSB" and Color3.fromRGB(35,18,4) or GAME=="DOORS" and Color3.fromRGB(20,8,35) or Color3.fromRGB(8,14,30)
HBadge.BorderSizePixel = 0
HBadge.ZIndex = 22
Instance.new("UICorner", HBadge).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", HBadge).Color = C.acc

local HBLbl = Instance.new("TextLabel", HBadge)
HBLbl.Size = UDim2.new(1,0,1,0)
HBLbl.BackgroundTransparency = 1
HBLbl.Text = GAME=="TSB" and "TSB" or GAME=="DOORS" and "DOORS" or "UNKNOWN"
HBLbl.TextColor3 = C.acc
HBLbl.Font = Enum.Font.GothamBold
HBLbl.TextSize = 9
HBLbl.ZIndex = 23

-- Minimize + Close
local MinB = Instance.new("TextButton", Hdr)
MinB.Size = UDim2.new(0,22,0,22)
MinB.Position = UDim2.new(1,-54,0.5,-11)
MinB.BackgroundColor3 = C.acc
MinB.Text = "–"
MinB.TextColor3 = Color3.fromRGB(10,8,4)
MinB.Font = Enum.Font.GothamBold
MinB.TextSize = 13
MinB.ZIndex = 23
Instance.new("UICorner", MinB).CornerRadius = UDim.new(1,0)

local ClB = Instance.new("TextButton", Hdr)
ClB.Size = UDim2.new(0,22,0,22)
ClB.Position = UDim2.new(1,-26,0.5,-11)
ClB.BackgroundColor3 = C.red
ClB.Text = S.cross
ClB.TextColor3 = C.white
ClB.Font = Enum.Font.GothamBold
ClB.TextSize = 11
ClB.ZIndex = 23
Instance.new("UICorner", ClB).CornerRadius = UDim.new(1,0)
ClB.MouseButton1Click:Connect(closeUI)

local isMin = false
MinB.MouseButton1Click:Connect(function()
    isMin = not isMin
    uiSnd(isMin and 0.9 or 1.2)
    TweenService:Create(MF, TweenInfo.new(0.25,Enum.EasingStyle.Quad), {
        Size = isMin and UDim2.new(0,GW,0,56) or UDim2.new(0,GW,0,GH)
    }):Play()
    MinB.Text = isMin and "+" or "–"
end)

-- Drag Header
local dg,ds,dp
Hdr.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=true ds=i.Position dp=MF.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-ds
        MF.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=false
    end
end)

------------------------------------------------
-- TAB BAR
------------------------------------------------
local TH = isMobile and 34 or 38
local TO = 60 + TH + 5

local TabBar = Instance.new("Frame", MF)
TabBar.Size = UDim2.new(1,-16,0,TH)
TabBar.Position = UDim2.new(0,8,0,60)
TabBar.BackgroundColor3 = C.panel
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 21
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,9)

local TabInner = Instance.new("Frame", TabBar)
TabInner.Size = UDim2.new(1,-8,1,-8)
TabInner.Position = UDim2.new(0,4,0,4)
TabInner.BackgroundTransparency = 1
TabInner.ZIndex = 22

local TabLL = Instance.new("UIListLayout", TabInner)
TabLL.FillDirection = Enum.FillDirection.Horizontal
TabLL.Padding = UDim.new(0,3)
TabLL.VerticalAlignment = Enum.VerticalAlignment.Center

-- Content Area
local ContentArea = Instance.new("Frame", MF)
ContentArea.Size = UDim2.new(1,-16,1,-(TO+8))
ContentArea.Position = UDim2.new(0,8,0,TO)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 21

------------------------------------------------
-- TABS SYSTEM
------------------------------------------------
-- Tab-Definitionen je nach Spiel
local TAB_DEFS
if GAME == "TSB" then
    TAB_DEFS = {
        {n="Main",    l="Main"},
        {n="Visuals", l="Visuals"},
        {n="Player",  l="Player"},
        {n="Settings",l="Settings"},
    }
elseif GAME == "DOORS" then
    TAB_DEFS = {
        {n="Main",    l="Main"},
        {n="Visuals", l="Visuals"},
        {n="Player",  l="Player"},
        {n="Settings",l="Settings"},
    }
else
    TAB_DEFS = {
        {n="Main",    l="Main"},
        {n="Settings",l="Settings"},
    }
end

local SFS = {} -- ScrollFrames
local TBS = {} -- Tab Buttons
local LOS = {} -- Layout Orders
local curTab = nil
local TW = math.floor((GW-24)/#TAB_DEFS)-3

for _,t in ipairs(TAB_DEFS) do
    LOS[t.n] = 0

    local sf = Instance.new("ScrollingFrame", ContentArea)
    sf.Name = "SF_"..t.n
    sf.Size = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = isMobile and 3 or 4
    sf.ScrollBarImageColor3 = C.acc
    sf.ScrollBarImageTransparency = 0.3
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.ScrollingEnabled = true
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
    sf.Visible = false
    sf.ZIndex = 22

    local ll = Instance.new("UIListLayout", sf)
    ll.Padding = UDim.new(0,5)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local lp = Instance.new("UIPadding", sf)
    lp.PaddingTop = UDim.new(0,5)
    lp.PaddingBottom = UDim.new(0,10)
    lp.PaddingLeft = UDim.new(0,2)
    lp.PaddingRight = UDim.new(0,6)

    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+14)
    end)

    SFS[t.n] = sf

    -- Tab Button
    local btn = Instance.new("Frame", TabInner)
    btn.Size = UDim2.new(0,TW,1,0)
    btn.BackgroundTransparency = 1
    btn.ZIndex = 23

    local bb = Instance.new("Frame", btn)
    bb.Size = UDim2.new(1,0,1,0)
    bb.BackgroundColor3 = C.acc
    bb.BackgroundTransparency = 1
    bb.BorderSizePixel = 0
    bb.ZIndex = 23
    Instance.new("UICorner", bb).CornerRadius = UDim.new(0,7)

    local bl = Instance.new("TextLabel", btn)
    bl.Size = UDim2.new(1,0,1,0)
    bl.BackgroundTransparency = 1
    bl.Text = t.l
    bl.TextColor3 = C.sub
    bl.Font = Enum.Font.GothamBold
    bl.TextSize = FS
    bl.ZIndex = 24

    local bc = Instance.new("TextButton", btn)
    bc.Size = UDim2.new(1,0,1,0)
    bc.BackgroundTransparency = 1
    bc.Text = ""
    bc.ZIndex = 25

    TBS[t.n] = {bb=bb, bl=bl}

    local cap = t.n
    local function sw(name)
        if curTab==name then return end
        curTab = name
        uiSnd(1.5)
        for _,td in ipairs(TAB_DEFS) do
            local a = (td.n==name)
            SFS[td.n].Visible = a
            if a then SFS[td.n].CanvasPosition = Vector2.new(0,0) end
            TweenService:Create(TBS[td.n].bb, TweenInfo.new(0.18), {
                BackgroundColor3 = a and C.acc or Color3.fromRGB(0,0,0),
                BackgroundTransparency = a and 0 or 1,
            }):Play()
            TweenService:Create(TBS[td.n].bl, TweenInfo.new(0.18), {
                TextColor3 = a and C.white or C.sub,
            }):Play()
        end
    end
    bc.MouseButton1Click:Connect(function() sw(cap) end)
    bc.MouseEnter:Connect(function()
        if curTab~=cap then TweenService:Create(bb,TweenInfo.new(0.14),{BackgroundTransparency=0.8}):Play() end
    end)
    bc.MouseLeave:Connect(function()
        if curTab~=cap then TweenService:Create(bb,TweenInfo.new(0.14),{BackgroundTransparency=1}):Play() end
    end)
end

-- Ersten Tab aktivieren
curTab = TAB_DEFS[1].n
SFS[curTab].Visible = true
TBS[curTab].bb.BackgroundTransparency = 0
TBS[curTab].bl.TextColor3 = C.white

------------------------------------------------
-- UI HELPER FUNKTIONEN
------------------------------------------------
local function gs(n) return SFS[n] end
local function no(n) LOS[n]=LOS[n]+1 return LOS[n] end

local function sec(tn, sym, txt)
    local f = Instance.new("Frame", gs(tn))
    f.Size = UDim2.new(1,-8,0,22)
    f.BackgroundColor3 = Color3.fromRGB(18,9,4)
    f.BorderSizePixel = 0
    f.LayoutOrder = no(tn)
    f.ZIndex = 23
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0,3,0,11)
    bar.Position = UDim2.new(0,7,0.5,-5)
    bar.BackgroundColor3 = C.acc
    bar.BorderSizePixel = 0
    bar.ZIndex = 24
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-18,1,0)
    l.Position = UDim2.new(0,16,0,0)
    l.BackgroundTransparency = 1
    l.Text = sym.."  "..txt
    l.TextColor3 = C.acc
    l.Font = Enum.Font.GothamBold
    l.TextSize = FS
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 24
end

local function tog(tn, sym, title, desc, cb)
    local hD = desc and desc ~= ""
    local sf = gs(tn)
    local c = Instance.new("Frame", sf)
    c.Size = UDim2.new(1,-8,0, hD and 52 or CH)
    c.BackgroundColor3 = C.card
    c.BorderSizePixel = 0
    c.LayoutOrder = no(tn)
    c.ZIndex = 23
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,9)

    local sk = Instance.new("UIStroke", c)
    sk.Color = C.acc sk.Thickness = 1 sk.Transparency = 1

    local sl = Instance.new("TextLabel", c)
    sl.Size = UDim2.new(0,20,1,0) sl.Position = UDim2.new(0,8,0,0)
    sl.BackgroundTransparency = 1 sl.Text = sym
    sl.TextColor3 = C.acc sl.Font = Enum.Font.GothamBold sl.TextSize = 13 sl.ZIndex = 24

    local tl = Instance.new("TextLabel", c)
    tl.Size = UDim2.new(0.68,0,0,16) tl.Position = UDim2.new(0,30,0,hD and 8 or 12)
    tl.BackgroundTransparency = 1 tl.Text = title tl.TextColor3 = C.text
    tl.Font = Enum.Font.GothamBold tl.TextSize = FL tl.TextXAlignment = Enum.TextXAlignment.Left tl.ZIndex = 24

    if hD then
        local dl = Instance.new("TextLabel", c)
        dl.Size = UDim2.new(0.7,0,0,13) dl.Position = UDim2.new(0,30,0,28)
        dl.BackgroundTransparency = 1 dl.Text = desc dl.TextColor3 = C.sub
        dl.Font = Enum.Font.Gotham dl.TextSize = FS dl.TextXAlignment = Enum.TextXAlignment.Left dl.ZIndex = 24
    end

    local sb = Instance.new("Frame", c)
    sb.Size = UDim2.new(0,40,0,20) sb.Position = UDim2.new(1,-48,0.5,-10)
    sb.BackgroundColor3 = C.off sb.BorderSizePixel = 0 sb.ZIndex = 24
    Instance.new("UICorner", sb).CornerRadius = UDim.new(1,0)

    local kn = Instance.new("Frame", sb)
    kn.Size = UDim2.new(0,14,0,14) kn.Position = UDim2.new(0,3,0.5,-7)
    kn.BackgroundColor3 = C.white kn.BorderSizePixel = 0 kn.ZIndex = 25
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1,0)

    local st = false
    local btn = Instance.new("TextButton", c)
    btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = "" btn.ZIndex = 26

    btn.MouseEnter:Connect(function()
        TweenService:Create(c,TweenInfo.new(0.14),{BackgroundColor3=C.cardH}):Play()
        TweenService:Create(sk,TweenInfo.new(0.14),{Transparency=0.55}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(c,TweenInfo.new(0.14),{BackgroundColor3=C.card}):Play()
        TweenService:Create(sk,TweenInfo.new(0.14),{Transparency=1}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        st = not st
        uiSnd(st and 1.5 or 1.0)
        TweenService:Create(sb,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
            BackgroundColor3=st and C.green or C.off
        }):Play()
        TweenService:Create(kn,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=st and UDim2.new(0,23,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()
        TweenService:Create(sl,TweenInfo.new(0.2),{TextColor3=st and C.green or C.acc}):Play()
        cb(st)
    end)

    return {card=c, setColor=function(col) TweenService:Create(sb,TweenInfo.new(0.2),{BackgroundColor3=col}):Play() end}
end

-- Info Label (für DOORS: dynamische Anzeige)
local function infoLabel(tn, id)
    local sf = gs(tn)
    local f = Instance.new("Frame", sf)
    f.Size = UDim2.new(1,-8,0,CH)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    f.LayoutOrder = no(tn)
    f.ZIndex = 23
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-12,1,0)
    l.Position = UDim2.new(0,6,0,0)
    l.BackgroundTransparency = 1
    l.Text = "—"
    l.TextColor3 = C.sub
    l.Font = Enum.Font.Gotham
    l.TextSize = FS
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.ZIndex = 24

    return {frame=f, label=l}
end

-- Highlight Frame für Warnungen
local function warnCard(tn, text, color)
    local sf = gs(tn)
    local f = Instance.new("Frame", sf)
    f.Size = UDim2.new(1,-8,0,CH)
    f.BackgroundColor3 = Color3.fromRGB(30,10,10)
    f.BorderSizePixel = 0
    f.LayoutOrder = no(tn)
    f.ZIndex = 23
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)

    local str = Instance.new("UIStroke", f)
    str.Color = color or C.red
    str.Thickness = 1.5
    str.Transparency = 0.3

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-8,1,0)
    l.Position = UDim2.new(0,4,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.red
    l.Font = Enum.Font.GothamBold
    l.TextSize = FL
    l.TextWrapped = true
    l.ZIndex = 24

    f.Visible = false
    return {frame=f, label=l, stroke=str}
end

-- Slider
local function sld(tn, sym, title, mn, mx, def, cb)
    local sf = gs(tn)
    local c = Instance.new("Frame", sf)
    c.Size = UDim2.new(1,-8,0,52)
    c.BackgroundColor3 = C.card
    c.BorderSizePixel = 0
    c.LayoutOrder = no(tn)
    c.ZIndex = 23
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,9)

    local sl2 = Instance.new("TextLabel",c) sl2.Size=UDim2.new(0,18,0,15) sl2.Position=UDim2.new(0,8,0,6) sl2.BackgroundTransparency=1 sl2.Text=sym sl2.TextColor3=C.acc sl2.Font=Enum.Font.GothamBold sl2.TextSize=13 sl2.ZIndex=24
    local tl = Instance.new("TextLabel",c) tl.Size=UDim2.new(0.65,0,0,15) tl.Position=UDim2.new(0,28,0,6) tl.BackgroundTransparency=1 tl.Text=title tl.TextColor3=C.text tl.Font=Enum.Font.GothamBold tl.TextSize=FL tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=24
    local vl = Instance.new("TextLabel",c) vl.Size=UDim2.new(0,38,0,15) vl.Position=UDim2.new(1,-44,0,6) vl.BackgroundTransparency=1 vl.Text=tostring(def) vl.TextColor3=C.acc vl.Font=Enum.Font.GothamBold vl.TextSize=FL vl.TextXAlignment=Enum.TextXAlignment.Right vl.ZIndex=24
    local tr = Instance.new("Frame",c) tr.Size=UDim2.new(1,-18,0,5) tr.Position=UDim2.new(0,9,0,34) tr.BackgroundColor3=C.off tr.BorderSizePixel=0 tr.ZIndex=24
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fi = Instance.new("Frame",tr) fi.Size=UDim2.new((def-mn)/(mx-mn),0,1,0) fi.BackgroundColor3=C.acc fi.BorderSizePixel=0 fi.ZIndex=25
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local kn = Instance.new("Frame",tr) kn.Size=UDim2.new(0,12,0,12) kn.Position=UDim2.new((def-mn)/(mx-mn),-6,0.5,-6) kn.BackgroundColor3=C.white kn.BorderSizePixel=0 kn.ZIndex=26
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local dgs=false
    local btn=Instance.new("TextButton",c) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=27
    local function ds(x)
        local r=math.clamp((x-tr.AbsolutePosition.X)/math.max(tr.AbsoluteSize.X,1),0,1)
        local v=math.floor(mn+(mx-mn)*r) fi.Size=UDim2.new(r,0,1,0) kn.Position=UDim2.new(r,-6,0.5,-6) vl.Text=tostring(v) cb(v)
    end
    btn.MouseButton1Down:Connect(function(x) dgs=true ds(x) end)
    UIS.InputChanged:Connect(function(i) if dgs and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then ds(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dgs=false end end)
end

-- Dropdown
local function drp(tn, title, opts, cb)
    local sf = gs(tn)
    local c = Instance.new("Frame",sf) c.Size=UDim2.new(1,-8,0,CH) c.BackgroundColor3=C.card c.BorderSizePixel=0 c.ClipsDescendants=false c.LayoutOrder=no(tn) c.ZIndex=30
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,9)
    local l = Instance.new("TextLabel",c) l.Size=UDim2.new(0.5,0,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=C.text l.Font=Enum.Font.GothamBold l.TextSize=FL l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=31
    local dW=isMobile and 95 or 110
    local db=Instance.new("TextButton",c) db.Size=UDim2.new(0,dW,0,24) db.Position=UDim2.new(1,-(dW+8),0.5,-12) db.BackgroundColor3=C.acc db.TextColor3=Color3.fromRGB(8,8,18) db.Font=Enum.Font.GothamBold db.TextSize=FS db.Text=opts[1].." ▾" db.ClipsDescendants=false db.ZIndex=31
    Instance.new("UICorner",db).CornerRadius=UDim.new(0,7)
    local dl=Instance.new("Frame",c) dl.Size=UDim2.new(0,dW,0,#opts*24+6) dl.Position=UDim2.new(1,-(dW+8),1,3) dl.BackgroundColor3=C.panel dl.BorderSizePixel=0 dl.Visible=false dl.ZIndex=55
    Instance.new("UICorner",dl).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",dl).Color=C.acc
    Instance.new("UIListLayout",dl).Padding=UDim.new(0,2)
    local dlp=Instance.new("UIPadding",dl) dlp.PaddingTop=UDim.new(0,3) dlp.PaddingLeft=UDim.new(0,3) dlp.PaddingRight=UDim.new(0,3)
    for _,o in ipairs(opts) do
        local ob=Instance.new("TextButton",dl) ob.Size=UDim2.new(1,0,0,22) ob.BackgroundColor3=C.card ob.TextColor3=C.text ob.Font=Enum.Font.Gotham ob.TextSize=FS ob.Text=o ob.ZIndex=56
        Instance.new("UICorner",ob).CornerRadius=UDim.new(0,5)
        ob.MouseEnter:Connect(function() TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=C.cardH}):Play() end)
        ob.MouseLeave:Connect(function() TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
        ob.MouseButton1Click:Connect(function() db.Text=o.." ▾" dl.Visible=false uiSnd(1.3) cb(o) end)
    end
    db.MouseButton1Click:Connect(function() dl.Visible=not dl.Visible uiSnd(1.2) end)
end

------------------------------------------------
-- GEMEINSAME SETTINGS (alle Spiele)
------------------------------------------------
local function buildSettings()
    sec("Settings", S.dot, "KEYBINDS")

    local kbInfo = infoLabel("Settings", "keybind_info")
    kbInfo.label.Text = S.arrow.."  RightShift  →  UI öffnen / schließen"
    kbInfo.label.TextColor3 = C.sub

    sec("Settings", S.dot, "UI SOUNDS")
    tog("Settings", S.music, "UI Sounds", "Click Sounds beim Toggle", function(on)
        -- handled global
    end)

    sec("Settings", S.dot, "PERFORMANCE")
    tog("Settings", S.bolt, "FPS Counter", "FPS Anzeige einblenden", function(on)
        local fl = GUI:FindFirstChild("_FPS")
        if on then
            if not fl then
                fl = Instance.new("Frame",GUI) fl.Name="_FPS" fl.Size=UDim2.new(0,88,0,22) fl.Position=UDim2.new(0,70,0,4) fl.BackgroundColor3=C.panel fl.BorderSizePixel=0 fl.ZIndex=100
                Instance.new("UICorner",fl).CornerRadius=UDim.new(0,7)
                local st=Instance.new("UIStroke",fl) st.Color=C.acc st.Thickness=1 st.Transparency=0.5
                local ft=Instance.new("TextLabel",fl) ft.Size=UDim2.new(1,0,1,0) ft.BackgroundTransparency=1 ft.TextColor3=C.green ft.Font=Enum.Font.GothamBold ft.TextSize=11 ft.ZIndex=101
                task.spawn(function()
                    local last=tick() local fr=0
                    while fl and fl.Parent do
                        fr=fr+1
                        if tick()-last>=1 then ft.Text=S.bolt.." "..fr.." FPS" fr=0 last=tick() end
                        RunService.RenderStepped:Wait()
                    end
                end)
            end
        else if fl then fl:Destroy() end end
    end)

    tog("Settings", S.eye, "Anti AFK", "Verhindert AFK Kick", function(on)
        if on then
            local VU=game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
        end
    end)
end

-- ════════════════════════════════════════════
-- THE STRONGEST BATTLEGROUNDS MODULE
-- ════════════════════════════════════════════
local function buildTSB()

    ---- MAIN TAB ----
    sec("Main", S.bolt, "COMBAT")

    tog("Main", S.bolt, "FPS Boost", "VFX & Schatten entfernen", function(on)
        Lighting.GlobalShadows = not on
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=not on end
            if v:IsA("BasePart") and on then v.Material=Enum.Material.Plastic v.Reflectance=0 v.CastShadow=false end
        end
    end)

    tog("Main", S.shield, "Anti Stun", "Speed & Jump bei Stun wiederherstellen", function(on)
        task.spawn(function()
            while on do
                task.wait(0.1)
                local char=LocalPlayer.Character
                if char then
                    local h=char:FindFirstChildOfClass("Humanoid")
                    if h and h.Health>0 then
                        if h.JumpPower<35 then h.JumpPower=50 end
                    end
                end
            end
        end)
    end)

    tog("Main", S.target, "Enemy Highlight", "Roter Rahmen um Gegner", function(on)
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local sel=p.Character:FindFirstChild("_KB_EB")
                if on and not sel then
                    local b=Instance.new("SelectionBox",p.Character)
                    b.Name="_KB_EB" b.Adornee=p.Character
                    b.Color3=C.red b.LineThickness=0.04
                    b.SurfaceTransparency=0.85 b.SurfaceColor3=C.red
                elseif not on and sel then sel:Destroy() end
            end
        end
    end)

    tog("Main", S.eye, "Name Tags", "Namen über Spielern anzeigen", function(on)
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if on and r then
                    local bb=Instance.new("BillboardGui",r) bb.Name="_KB_NT"
                    bb.Size=UDim2.new(0,120,0,22) bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
                    local tl=Instance.new("TextLabel",bb) tl.Size=UDim2.new(1,0,1,0)
                    tl.BackgroundTransparency=1 tl.Text=S.sword.." "..p.Name
                    tl.TextColor3=C.acc tl.Font=Enum.Font.GothamBold tl.TextScaled=true
                elseif not on then
                    local t=r and r:FindFirstChild("_KB_NT") if t then t:Destroy() end
                end
            end
        end
    end)

    ---- VISUALS TAB ----
    sec("Visuals", S.eye, "LIGHTING")

    tog("Visuals", S.star, "Full Bright", "Maximale Helligkeit", function(on)
        Lighting.Ambient=on and Color3.new(1,1,1) or Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient=on and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        Lighting.Brightness=on and 10 or 2
    end)

    tog("Visuals", S.wave, "No Fog", "Nebel entfernen", function(on)
        Lighting.FogEnd=on and 9e9 or 1000 Lighting.FogStart=on and 9e9 or 0
    end)

    tog("Visuals", S.ban, "Remove VFX", "Partikel & Beams aus", function(on)
        local function cl(o)
            for _,v in ipairs(o:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=not on end
                if v:IsA("PointLight") or v:IsA("SpotLight") then v.Enabled=not on end
            end
        end
        cl(workspace)
        if on then workspace.DescendantAdded:Connect(function(o) task.wait() cl(o) end) end
    end)

    tog("Visuals", S.gem, "Neon Enemies", "Gegner leuchten neon", function(on)
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                for _,v in ipairs(p.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material=on and Enum.Material.Neon or Enum.Material.Plastic end
                end
            end
        end
    end)

    sec("Visuals", S.gem, "GRAFIK PRESET")
    drp("Visuals", "Grafik", {"POTATO","LOW","MEDIUM","HIGH","ULTRA"}, function(sel)
        local presets = {
            POTATO=function()
                settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 Lighting.GlobalShadows=false
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then v.Material=Enum.Material.Plastic v.Reflectance=0 v.CastShadow=false end
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false end
                end
            end,
            LOW=function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level03 Lighting.GlobalShadows=false end,
            MEDIUM=function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level07 Lighting.GlobalShadows=true end,
            HIGH=function()
                settings().Rendering.QualityLevel=Enum.QualityLevel.Level14 Lighting.GlobalShadows=true
                local b=Instance.new("BloomEffect",Lighting) b.Intensity=0.5 b.Size=30 b.Threshold=0.95
            end,
            ULTRA=function()
                settings().Rendering.QualityLevel=Enum.QualityLevel.Level21 Lighting.GlobalShadows=true Lighting.Brightness=2.5
                local b=Instance.new("BloomEffect",Lighting) b.Intensity=1 b.Size=50 b.Threshold=0.88
                local cc=Instance.new("ColorCorrectionEffect",Lighting) cc.Saturation=0.3 cc.Contrast=0.15
            end,
        }
        if presets[sel] then presets[sel]() end
    end)

    ---- PLAYER TAB ----
    sec("Player", S.arrow, "MOVEMENT")

    local speedOn = false
    local speedVal = 16
    local speedConn = nil

    local function applySpeed()
        local char=LocalPlayer.Character if not char then return end
        local h=char:FindFirstChildOfClass("Humanoid") if not h then return end
        h.WalkSpeed = speedVal
    end

    local function setupSpeedLoop(active)
        if speedConn then speedConn:Disconnect() speedConn=nil end
        if not active then return end
        speedConn = RunService.Heartbeat:Connect(function()
            local char=LocalPlayer.Character if not char then return end
            local h=char:FindFirstChildOfClass("Humanoid") if not h then return end
            if h.Health>0 and h.WalkSpeed~=speedVal then h.WalkSpeed=speedVal end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if speedOn then
            local h=char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=speedVal end
        end
    end)

    tog("Player", S.bolt, "Speed Boost", "WalkSpeed erhöhen", function(on)
        speedOn = on
        speedVal = on and 28 or 16
        applySpeed()
        setupSpeedLoop(on)
    end)

    sld("Player", S.arrow, "Custom Speed", 16, 100, 16, function(val)
        speedVal = val
        speedOn = (val > 16)
        applySpeed()
        setupSpeedLoop(speedOn)
    end)

    tog("Player", S.eye, "Max Camera Zoom", "Kamera weit rauszoomen", function(on)
        LocalPlayer.CameraMaxZoomDistance = on and 200 or 30
    end)

    tog("Player", S.bolt, "No Clip", "Durch Wände gehen", function(on)
        RunService.Stepped:Connect(function()
            if on and LocalPlayer.Character then
                for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false end
                end
            end
        end)
    end)

    buildSettings()
end

-- ════════════════════════════════════════════
-- DOORS MODULE
-- ════════════════════════════════════════════
local function buildDOORS()

    -- DOORS-spezifische Variablen
    local highlights   = {} -- aktive Highlights (Instanz → Highlight)
    local lastRoom     = nil
    local monsterWarning = nil
    local cleanupFns   = {}

    -- Alle Highlights entfernen
    local function clearHighlights()
        for inst, hl in pairs(highlights) do
            pcall(function() hl:Destroy() end)
        end
        highlights = {}
    end

    -- Highlight erstellen
    local function addHighlight(instance, fillColor, outlineColor, fillTrans)
        if not instance or not instance.Parent then return end
        if highlights[instance] then return end
        local hl = Instance.new("SelectionBox")
        hl.Adornee = instance
        hl.Color3 = outlineColor or C.acc
        hl.LineThickness = 0.04
        hl.SurfaceColor3 = fillColor or C.acc
        hl.SurfaceTransparency = fillTrans or 0.85
        hl.Parent = workspace
        highlights[instance] = hl
        return hl
    end

    -- Aktuellen Raum finden (DOORS Struktur)
    local function getCurrentRoom()
        -- DOORS speichert Räume unter workspace in Folder/Models
        -- Häufig: workspace.CurrentRooms oder ähnlich
        local roomFolder = workspace:FindFirstChild("CurrentRooms")
            or workspace:FindFirstChild("Rooms")
            or workspace:FindFirstChild("Map")
        if not roomFolder then return nil end

        local char = LocalPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        -- Nächsten Raum zum Spieler finden
        local closestRoom, closestDist = nil, math.huge
        for _, room in ipairs(roomFolder:GetChildren()) do
            if room:IsA("Model") or room:IsA("Folder") then
                local cf = room:FindFirstChild("RoomCFrame")
                    or room:FindFirstChild("SpawnPoint")
                    or room:FindFirstChildWhichIsA("BasePart")
                if cf then
                    local pos = cf:IsA("BasePart") and cf.Position or cf.Value
                    local dist = (root.Position - pos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestRoom = room
                    end
                end
            end
        end
        return closestRoom
    end

    -- Items im Raum finden
    local function findRoomItems(room)
        local items = {}
        if not room then return items end
        for _, obj in ipairs(room:GetDescendants()) do
            -- Schränke
            if obj.Name:lower():find("wardrobe")
            or obj.Name:lower():find("closet")
            or obj.Name:lower():find("locker") then
                table.insert(items, {type="Schrank", inst=obj})
            -- Kisten / Chests
            elseif obj.Name:lower():find("chest")
            or obj.Name:lower():find("crate")
            or obj.Name:lower():find("box") then
                table.insert(items, {type="Kiste", inst=obj})
            -- Items
            elseif obj.Name:lower():find("item")
            or obj.Name:lower():find("bandage")
            or obj.Name:lower():find("vitamin")
            or obj.Name:lower():find("lockpick") then
                table.insert(items, {type="Item", inst=obj})
            -- Türen
            elseif obj.Name:lower():find("door") and obj:IsA("Model") then
                table.insert(items, {type="Tür", inst=obj})
            end
        end
        return items
    end

    -- Monster erkennen
    local function detectMonster()
        local char = LocalPlayer.Character
        if not char then return nil, math.huge end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil, math.huge end

        -- Häufige DOORS Monster Names
        local monsterNames = {"Rush","Ambush","Seek","Eyes","Halt","Figure","Timothy","Snare"}
        local closestMonster, closestDist = nil, math.huge

        for _, name in ipairs(monsterNames) do
            local monster = workspace:FindFirstChild(name, true)
                or workspace:FindFirstChildWhichIsA("Model") -- fallback
            if monster then
                local mRoot = monster:FindFirstChildWhichIsA("BasePart")
                if mRoot then
                    local dist = (root.Position - mRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestMonster = monster
                    end
                end
            end
        end

        -- Auch nach unbekannten schnell-bewegenden Entities suchen
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local h = obj:FindFirstChildOfClass("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart")
                if h and r and not Players:GetPlayerFromCharacter(obj) then
                    local dist = (root.Position - r.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestMonster = obj
                    end
                end
            end
        end

        return closestMonster, closestDist
    end

    ---- DYNAMISCHE ROOM INFO LABELS ----
    local roomLabel   = nil
    local itemLabel   = nil
    local monsterCard = nil
    local doorLabel   = nil
    local itemToggleOn = false
    local doorToggleOn = false
    local monsterToggleOn = false

    ---- MAIN TAB ----
    sec("Main", S.door, "RAUM INFO")

    -- Aktueller Raum
    do
        local ri = infoLabel("Main", "room")
        ri.label.Text = S.door.."  Raum wird erkannt..."
        ri.label.TextColor3 = C.acc
        roomLabel = ri.label
    end

    -- Monster Warnung Card
    monsterCard = warnCard("Main", S.warn.."  Kein Monster in der Nähe", C.orange)
    monsterCard.frame.Visible = true
    monsterCard.frame.BackgroundColor3 = Color3.fromRGB(20,20,35)
    monsterCard.stroke.Color = C.sub
    monsterCard.stroke.Transparency = 0.6
    monsterCard.label.TextColor3 = C.sub

    sec("Main", S.dot, "RAUM INHALT")

    -- Items Label
    do
        local il = infoLabel("Main", "items")
        il.label.Text = S.gem.."  Items werden gescannt..."
        itemLabel = il.label
    end

    -- Türen Label
    do
        local dl2 = infoLabel("Main", "doors")
        dl2.label.Text = S.door.."  Türen werden gescannt..."
        doorLabel = dl2.label
    end

    ---- VISUALS TAB ----
    sec("Visuals", S.eye, "HIGHLIGHTS")

    local hlItemsOn   = false
    local hlDoorsOn   = false
    local hlMonsOn    = false

    tog("Visuals", S.gem, "Items highlighten", "Kisten & Items markieren", function(on)
        hlItemsOn = on
        if not on then
            for inst, hl in pairs(highlights) do
                if inst.Name:lower():find("chest") or inst.Name:lower():find("item") then
                    pcall(function() hl:Destroy() end)
                    highlights[inst] = nil
                end
            end
        end
    end)

    tog("Visuals", S.shield, "Schränke markieren", "Schränke & Locker hervorheben", function(on)
        -- wird beim nächsten Room-Scan aufgenommen
        hlItemsOn = on or hlItemsOn
    end)

    tog("Visuals", S.door, "Türen highlighten", "Türen im Raum markieren", function(on)
        hlDoorsOn = on
        if not on then
            for inst, hl in pairs(highlights) do
                if inst.Name:lower():find("door") then
                    pcall(function() hl:Destroy() end)
                    highlights[inst] = nil
                end
            end
        end
    end)

    tog("Visuals", S.warn, "Monster Outline", "Monster rot markieren", function(on)
        hlMonsOn = on
    end)

    sec("Visuals", S.eye, "LIGHTING")
    tog("Visuals", S.star, "Full Bright", "Maximale Helligkeit", function(on)
        Lighting.Ambient=on and Color3.new(1,1,1) or Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient=on and Color3.new(1,1,1) or Color3.fromRGB(100,100,100)
        Lighting.Brightness=on and 10 or 2
    end)
    tog("Visuals", S.wave, "No Fog", "Nebel entfernen", function(on)
        Lighting.FogEnd=on and 9e9 or 1000 Lighting.FogStart=on and 9e9 or 0
    end)

    ---- PLAYER TAB ----
    sec("Player", S.arrow, "MOVEMENT")
    tog("Player", S.bolt, "Speed Boost", "Schneller laufen", function(on)
        local char=LocalPlayer.Character if not char then return end
        local h=char:FindFirstChildOfClass("Humanoid") if not h then return end
        h.WalkSpeed=on and 24 or 16
        LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.3) local hum=c:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed=on and 24 or 16 end
        end)
    end)
    tog("Player", S.eye, "Max Zoom", "Kamera rauszoomen", function(on)
        LocalPlayer.CameraMaxZoomDistance=on and 150 or 30
    end)

    buildSettings()

    ---- HAUPT UPDATE LOOP (DOORS LOGIK) ----
    -- Sauber, kein Memory-Leak, mit Connection-Cleanup
    local updateConn = nil
    local monsterCheckConn = nil

    -- Raum-Scanner (läuft alle 1 Sekunde)
    local function startRoomScanner()
        if updateConn then updateConn:Disconnect() end

        local ticker = 0
        updateConn = RunService.Heartbeat:Connect(function(dt)
            ticker = ticker + dt
            if ticker < 1 then return end -- nur 1x pro Sekunde
            ticker = 0

            local room = getCurrentRoom()
            local roomName = room and room.Name or "Unbekannt"

            -- Raum geändert?
            if roomName ~= lastRoom then
                lastRoom = roomName
                -- Alte Highlights entfernen
                clearHighlights()

                if roomLabel then
                    roomLabel.Text = S.door.."  Raum: "..roomName
                end

                -- Neue Items scannen
                local items = findRoomItems(room)
                local itemList = {}
                local doorList = {}

                for _, item in ipairs(items) do
                    if item.type == "Tür" then
                        table.insert(doorList, item)
                        if hlDoorsOn then
                            addHighlight(item.inst, C.acc2, C.acc, 0.8)
                        end
                    elseif item.type == "Schrank" or item.type == "Kiste" or item.type == "Item" then
                        table.insert(itemList, item)
                        if hlItemsOn then
                            local col = item.type=="Item" and C.green or C.yellow
                            addHighlight(item.inst, col, col, 0.8)
                        end
                    end
                end

                -- Labels updaten
                if itemLabel then
                    if #itemList > 0 then
                        local parts = {}
                        for _, it in ipairs(itemList) do
                            table.insert(parts, S.dot.." "..it.type)
                        end
                        itemLabel.Text = table.concat(parts, "   ")
                        itemLabel.TextColor3 = C.green
                    else
                        itemLabel.Text = S.dot.."  Keine Items gefunden"
                        itemLabel.TextColor3 = C.sub
                    end
                end

                if doorLabel then
                    if #doorList > 0 then
                        doorLabel.Text = S.door.."  "..#doorList.." Türen erkannt"
                        doorLabel.TextColor3 = C.acc
                    else
                        doorLabel.Text = S.door.."  Keine Türen gefunden"
                        doorLabel.TextColor3 = C.sub
                    end
                end
            end
        end)
    end

    -- Monster-Scanner (läuft alle 0.3 Sekunden für flüssige Warnung)
    local function startMonsterScanner()
        if monsterCheckConn then monsterCheckConn:Disconnect() end

        local ticker = 0
        monsterCheckConn = RunService.Heartbeat:Connect(function(dt)
            ticker = ticker + dt
            if ticker < 0.3 then return end
            ticker = 0

            local monster, dist = detectMonster()

            if monster and dist < 150 then
                -- Monster in Nähe!
                local dangerLevel = dist < 30 and "KRITISCH" or dist < 60 and "GEFAHR" or "WARNUNG"
                local dangerColor = dist < 30 and C.red or dist < 60 and C.orange or C.yellow

                if monsterCard then
                    monsterCard.frame.Visible = true
                    monsterCard.frame.BackgroundColor3 = dist < 30 and Color3.fromRGB(35,6,6) or Color3.fromRGB(35,18,4)
                    monsterCard.stroke.Color = dangerColor
                    monsterCard.stroke.Transparency = 0
                    monsterCard.label.Text = S.warn.."  "..dangerLevel.."!  "..monster.Name.."  –  "..math.floor(dist).." studs"
                    monsterCard.label.TextColor3 = dangerColor

                    -- Pulsierende Animation wenn kritisch
                    if dist < 30 then
                        TweenService:Create(monsterCard.stroke, TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true), {
                            Transparency=0.7
                        }):Play()
                    end
                end

                -- Monster Highlight
                if hlMonsOn and monster then
                    if not highlights[monster] then
                        local hl = addHighlight(monster, C.red, C.red, 0.75)
                    end
                end

            else
                -- Kein Monster
                if monsterCard then
                    monsterCard.frame.BackgroundColor3 = Color3.fromRGB(20,20,35)
                    monsterCard.stroke.Color = C.sub
                    monsterCard.stroke.Transparency = 0.6
                    monsterCard.label.Text = S.check.."  Kein Monster in der Nähe"
                    monsterCard.label.TextColor3 = C.sub
                end

                -- Monster Highlights entfernen
                if hlMonsOn then
                    for inst, hl in pairs(highlights) do
                        if not Players:GetPlayerFromCharacter(inst) then
                            local isMon = inst:FindFirstChildOfClass("Humanoid") ~= nil
                            if isMon then
                                pcall(function() hl:Destroy() end)
                                highlights[inst] = nil
                            end
                        end
                    end
                end
            end
        end)
    end

    -- Starten
    startRoomScanner()
    startMonsterScanner()

    -- Cleanup wenn GUI zerstört wird
    GUI.AncestryChanged:Connect(function()
        if updateConn then updateConn:Disconnect() end
        if monsterCheckConn then monsterCheckConn:Disconnect() end
        clearHighlights()
    end)
end

-- ════════════════════════════════════════════
-- UNKNOWN GAME MODULE
-- ════════════════════════════════════════════
local function buildUnknown()
    sec("Main", S.skull, "GAME NICHT ERKANNT")

    local info = infoLabel("Main", "info")
    info.label.Text = S.warn.."  Dieses Spiel wird nicht unterstützt.\n  PlaceId: "..tostring(PlaceId)
    info.label.TextColor3 = C.orange

    local info2 = infoLabel("Main", "info2")
    info2.label.Text = S.dot.."  Unterstützte Spiele:\n  "..S.bolt.." The Strongest Battlegrounds\n  "..S.door.." DOORS"
    info2.label.TextColor3 = C.sub

    buildSettings()
end

-- ════════════════════════════════════════════
-- GAME LOADER
-- ════════════════════════════════════════════
if GAME == "TSB" then
    buildTSB()
elseif GAME == "DOORS" then
    buildDOORS()
else
    buildUnknown()
end

-- ════════════════════════════════════════════
-- STARTUP TOAST
-- ════════════════════════════════════════════
local function showToast(text, sub, color)
    local tw = isMobile and 230 or 260
    local toast = Instance.new("Frame", GUI)
    toast.Size = UDim2.new(0,tw,0,50)
    toast.Position = UDim2.new(0.5,-tw/2,1,10)
    toast.BackgroundColor3 = C.panel
    toast.BorderSizePixel = 0
    toast.ZIndex = 200
    Instance.new("UICorner",toast).CornerRadius=UDim.new(0,11)
    local ts = Instance.new("UIStroke",toast) ts.Color=color or C.acc ts.Thickness=1.2

    local tIcon = Instance.new("TextLabel",toast) tIcon.Size=UDim2.new(0,38,0,42) tIcon.Position=UDim2.new(0,4,0.5,-21) tIcon.BackgroundTransparency=1 tIcon.Text=GAME=="TSB" and "⚡" or GAME=="DOORS" and "⊞" or "◈" tIcon.TextScaled=true tIcon.Font=Enum.Font.GothamBold tIcon.TextColor3=C.acc tIcon.ZIndex=201

    local tT=Instance.new("TextLabel",toast) tT.Size=UDim2.new(1,-50,0,18) tT.Position=UDim2.new(0,46,0,7) tT.BackgroundTransparency=1 tT.Text=text tT.TextColor3=C.text tT.Font=Enum.Font.GothamBold tT.TextSize=isMobile and 11 or 12 tT.TextXAlignment=Enum.TextXAlignment.Left tT.ZIndex=201
    local tS=Instance.new("TextLabel",toast) tS.Size=UDim2.new(1,-50,0,13) tS.Position=UDim2.new(0,46,0,27) tS.BackgroundTransparency=1 tS.Text=sub tS.TextColor3=color or C.acc tS.Font=Enum.Font.Gotham tS.TextSize=isMobile and 9 or 10 tS.TextXAlignment=Enum.TextXAlignment.Left tS.ZIndex=201

    task.wait(0.5)
    TweenService:Create(toast,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=UDim2.new(0.5,-tw/2,1,-60)
    }):Play()

    task.delay(4, function()
        TweenService:Create(toast,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
            Position=UDim2.new(0.5,-tw/2,1,10)
        }):Play()
        task.wait(0.4) pcall(function() toast:Destroy() end)
    end)
end

showToast(
    "KARMAN SCRIPT v1.0",
    GAME=="TSB" and (S.check.." TSB erkannt") or GAME=="DOORS" and (S.check.." DOORS erkannt") or (S.warn.." Unbekanntes Spiel"),
    GAME~="UNKNOWN" and C.green or C.orange
)
