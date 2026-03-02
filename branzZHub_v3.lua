-- ══════════════════════════════════════════════
--         branzZ Hub | discord.gg/4RmZv2GyBx
--              UI Dark Theme - v3.0 (Mobile Optimized)
-- ══════════════════════════════════════════════

pcall(function()
    if game.CoreGui:FindFirstChild("branzZHub") then
        game.CoreGui:FindFirstChild("branzZHub"):Destroy()
    end
end)

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Workspace      = game:GetService("Workspace")

local LocalPlayer    = Players.LocalPlayer

-- ══════════════════════════════════════════════
--               VARIÁVEIS DE ESTADO
-- ══════════════════════════════════════════════

-- Teleguiad
local teleguiadAtivo      = false
local teleguiadConn       = nil

-- Booster (UCT)
local DefaultGravity      = 196.2
local BoostGravity        = 40
local DefaultJumpPower    = 50
local BoostJumpPower      = 30
local SpeedMultiplier     = 27
local CurrentGravity      = DefaultGravity
local BoosterConnection   = nil
local JumpBoostConnection = nil

-- Anti Knockback (UCT)
local AntiRagdollActive      = false
local AntiRagdollConnections = {}

-- Hitbox Expander (UCT)
local HitboxConnection = nil

-- Super Bypass Anti-Kick
local antikickConnections = {}

-- ══════════════════════════════════════════════
--                CRIAR SCREENUI
-- ══════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "branzZHub"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = game.CoreGui

-- Frame principal (menor para mobile)
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, 280, 0, 420)
MainFrame.Position         = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.Parent           = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color     = Color3.fromRGB(55, 55, 75)
MainStroke.Thickness = 1

-- Sombra
local Shadow = Instance.new("Frame", MainFrame)
Shadow.Size                  = UDim2.new(1, 8, 1, 8)
Shadow.Position              = UDim2.new(0, -4, 0, 4)
Shadow.BackgroundColor3      = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.55
Shadow.ZIndex                = MainFrame.ZIndex - 1
Shadow.BorderSizePixel       = 0
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 16)

-- ══════════════════════════════════════════════
--                    HEADER
-- ══════════════════════════════════════════════

local Header = Instance.new("Frame", MainFrame)
Header.Name             = "Header"
Header.Size             = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
Header.BorderSizePixel  = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size             = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position         = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
HeaderFix.BorderSizePixel  = 0

local Title = Instance.new("TextLabel", Header)
Title.Size               = UDim2.new(1, -110, 0, 24)
Title.Position           = UDim2.new(0, 15, 0, 4)
Title.BackgroundTransparency = 1
Title.Text               = "branzZ Hub"
Title.TextColor3         = Color3.fromRGB(255, 255, 255)
Title.TextSize           = 16
Title.Font               = Enum.Font.GothamBold
Title.TextXAlignment     = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size             = UDim2.new(1, -110, 0, 16)
SubTitle.Position         = UDim2.new(0, 15, 0, 28)
SubTitle.BackgroundTransparency = 1
SubTitle.Text             = "v3 Mobile"
SubTitle.TextColor3       = Color3.fromRGB(255, 80, 80)
SubTitle.TextSize         = 10
SubTitle.Font             = Enum.Font.Gotham
SubTitle.TextXAlignment   = Enum.TextXAlignment.Left

local CopyBtn = Instance.new("TextButton", Header)
CopyBtn.Size             = UDim2.new(0, 70, 0, 28)
CopyBtn.Position         = UDim2.new(1, -110, 0.5, -14)
CopyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
CopyBtn.Text             = "Copiar"
CopyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize         = 12
CopyBtn.Font             = Enum.Font.GothamBold
CopyBtn.BorderSizePixel  = 0
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize         = 13
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- ══════════════════════════════════════════════
--           ÁREA DE SCROLL (CONTEÚDO)
-- ══════════════════════════════════════════════

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size                = UDim2.new(1, -12, 1, -60)
Content.Position            = UDim2.new(0, 6, 0, 56)
Content.BackgroundTransparency = 1
Content.BorderSizePixel     = 0
Content.ScrollBarThickness  = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
Content.CanvasSize          = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ListLayout = Instance.new("UIListLayout", Content)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding   = UDim.new(0, 5)

local ListPad = Instance.new("UIPadding", Content)
ListPad.PaddingTop    = UDim.new(0, 4)
ListPad.PaddingBottom = UDim.new(0, 8)

-- ══════════════════════════════════════════════
--         FUNÇÕES DE CRIAÇÃO DE UI
-- ══════════════════════════════════════════════

local function createSection(labelText, order)
    local lbl = Instance.new("TextLabel", Content)
    lbl.Size             = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "  " .. labelText
    lbl.TextColor3       = Color3.fromRGB(255, 60, 60)
    lbl.TextSize         = 10
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.LayoutOrder      = order
end

local function createCard(labelText, descText, iconEmoji, iconColor, order)
    local Card = Instance.new("Frame", Content)
    Card.Name             = "Card_" .. labelText
    Card.Size             = UDim2.new(1, 0, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Card.BorderSizePixel  = 0
    Card.LayoutOrder      = order
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color     = Color3.fromRGB(40, 40, 58)
    Stroke.Thickness = 1

    local IconBg = Instance.new("Frame", Card)
    IconBg.Size             = UDim2.new(0, 36, 0, 36)
    IconBg.Position         = UDim2.new(0, 10, 0.5, -18)
    IconBg.BackgroundColor3 = iconColor or Color3.fromRGB(255, 50, 50)
    IconBg.BorderSizePixel  = 0
    Instance.new("UICorner", IconBg).CornerRadius = UDim.new(0, 8)

    local IconLbl = Instance.new("TextLabel", IconBg)
    IconLbl.Size             = UDim2.new(1, 0, 1, 0)
    IconLbl.BackgroundTransparency = 1
    IconLbl.Text             = iconEmoji or "⚡"
    IconLbl.TextSize         = 18

    local Name = Instance.new("TextLabel", Card)
    Name.Size             = UDim2.new(1, -120, 0, 20)
    Name.Position         = UDim2.new(0, 56, 0, 10)
    Name.BackgroundTransparency = 1
    Name.Text             = labelText
    Name.TextColor3       = Color3.fromRGB(240, 240, 255)
    Name.TextSize         = 13
    Name.Font             = Enum.Font.GothamBold
    Name.TextXAlignment   = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Card)
    Desc.Size             = UDim2.new(1, -120, 0, 16)
    Desc.Position         = UDim2.new(0, 56, 0, 32)
    Desc.BackgroundTransparency = 1
    Desc.Text             = descText
    Desc.TextColor3       = Color3.fromRGB(150, 150, 160)
    Desc.TextSize         = 10
    Desc.Font             = Enum.Font.Gotham
    Desc.TextXAlignment   = Enum.TextXAlignment.Left

    local TBg = Instance.new("Frame", Card)
    TBg.Size             = UDim2.new(0, 42, 0, 22)
    TBg.Position         = UDim2.new(1, -52, 0.5, -11)
    TBg.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
    TBg.BorderSizePixel  = 0
    Instance.new("UICorner", TBg).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", TBg)
    Knob.Size             = UDim2.new(0, 18, 0, 18)
    Knob.Position         = UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
    Knob.BorderSizePixel  = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local TBtn = Instance.new("TextButton", TBg)
    TBtn.Size             = UDim2.new(1, 0, 1, 0)
    TBtn.BackgroundTransparency = 1
    TBtn.Text             = ""

    local isOn = false
    local function setState(state, anim)
        isOn = state
        local kPos    = state and UDim2.new(0, 22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local bgCol   = state and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(45, 45, 62)
        if anim then
            TweenService:Create(Knob, TweenInfo.new(0.15), {Position = kPos}):Play()
            TweenService:Create(TBg, TweenInfo.new(0.15), {BackgroundColor3 = bgCol}):Play()
        else
            Knob.Position         = kPos
            TBg.BackgroundColor3  = bgCol
        end
    end

    return TBtn, function() return isOn end, setState
end

-- ══════════════════════════════════════════════
--              CRIAR CARDS NA UI
-- ══════════════════════════════════════════════

createSection("COMBATE", 1)
local TeleguiadBtn, getTeleguiad, setTeleguiad = createCard("Teleguiad", "Mira automática na câmera", "🎯", nil, 2)
local HitboxBtn, getHitbox, setHitbox = createCard("Hitbox+", "Aumenta hitbox inimiga", "💥", nil, 3)

createSection("MOVIMENTO", 4)
local BoosterBtn, getBooster, setBooster = createCard("Booster", "Velocidade e Pulo", "👟", nil, 5)

createSection("UTILITÁRIOS", 6)
local AntiKnockBtn, getAntiKnock, setAntiKnock = createCard("Anti Ragdoll", "Remove efeito de queda (Lag Fix)", "🛡️", nil, 7)
local SuperBypassBtn, getSuperBypass, setSuperBypass = createCard("Anti-Kick", "Bypass de kick do servidor", "👻", nil, 8)

-- ══════════════════════════════════════════════
--        LÓGICA: SUPER BYPASS ANTI-KICK
-- ══════════════════════════════════════════════

local function EnableAntiKick()
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(...)
            local args = {...}
            local method = getnamecallmethod()
            if method:lower() == "kick" then
                return nil
            end
            return oldNamecall(...)
        end)
        
        antikickConnections["Bypass"] = function()
            setreadonly(mt, false)
            mt.__namecall = oldNamecall
            setreadonly(mt, true)
        end
    end)
end

local function DisableAntiKick()
    if antikickConnections["Bypass"] then
        antikickConnections["Bypass"]()
        antikickConnections["Bypass"] = nil
    end
end

-- ══════════════════════════════════════════════
--     LÓGICA: ANTI RAGDOLL (Otimizado p/ menos lag)
-- ══════════════════════════════════════════════

local function OptimizedAntiRagdoll(char)
    pcall(function()
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
end

local function EnableAntiRagdoll()
    AntiRagdollActive = true
    local char = LocalPlayer.Character
    if char then OptimizedAntiRagdoll(char) end
    table.insert(AntiRagdollConnections, LocalPlayer.CharacterAdded:Connect(OptimizedAntiRagdoll))
end

local function DisableAntiRagdoll()
    AntiRagdollActive = false
    for _, conn in ipairs(AntiRagdollConnections) do conn:Disconnect() end
    AntiRagdollConnections = {}
end

-- ══════════════════════════════════════════════
--         LÓGICA: BOOSTER (UCT)
-- ══════════════════════════════════════════════

pcall(function()
    local mt = getrawmetatable(Workspace)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if key == "Gravity" then return CurrentGravity end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

local function UpdateBooster(enabled)
    CurrentGravity = enabled and BoostGravity or DefaultGravity
    Workspace.Gravity = CurrentGravity
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = enabled and BoostJumpPower or DefaultJumpPower
    end
    if BoosterConnection then BoosterConnection:Disconnect() end
    if JumpBoostConnection then JumpBoostConnection:Disconnect() end
    BoosterConnection = nil
    JumpBoostConnection = nil
    if enabled then
        BoosterConnection = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.MoveDirection.Magnitude > 0 then
                hrp.Velocity = Vector3.new(h.MoveDirection.X * SpeedMultiplier, hrp.Velocity.Y, h.MoveDirection.Z * SpeedMultiplier)
            end
        end)
        JumpBoostConnection = UserInputService.JumpRequest:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if hrp and h then hrp.Velocity = Vector3.new(hrp.Velocity.X, h.JumpPower, hrp.Velocity.Z) end
        end)
    end
end

-- ══════════════════════════════════════════════
--         LÓGICA: HITBOX EXPANDER
-- ══════════════════════════════════════════════

local function UpdateHitbox(enabled)
    if HitboxConnection then HitboxConnection:Disconnect(); HitboxConnection = nil end
    if enabled then
        HitboxConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(12, 12, 12)
                        hrp.Transparency = 0.6
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = true end
            end
        end
    end
end

-- ══════════════════════════════════════════════
--         LÓGICA: TELEGUIAD
-- ══════════════════════════════════════════════

local function ActivateTeleguiad()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TeleguiadBV"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    teleguiadConn = RunService.Heartbeat:Connect(function()
        if not teleguiadAtivo then return end
        local c2 = LocalPlayer.Character
        if not c2 then return end
        local h2 = c2:FindFirstChild("HumanoidRootPart")
        local bv2 = h2 and h2:FindFirstChild("TeleguiadBV")
        if not h2 or not bv2 then return end
        bv2.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 26.7
    end)
end

local function DeactivateTeleguiad()
    if teleguiadConn then teleguiadConn:Disconnect(); teleguiadConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("TeleguiadBV")
            if bv then bv:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- ══════════════════════════════════════════════
--          CONECTAR TOGGLES AOS BOTÕES
-- ══════════════════════════════════════════════

TeleguiadBtn.MouseButton1Click:Connect(function()
    teleguiadAtivo = not teleguiadAtivo
    setTeleguiad(teleguiadAtivo, true)
    if teleguiadAtivo then ActivateTeleguiad() else DeactivateTeleguiad() end
end)

BoosterBtn.MouseButton1Click:Connect(function()
    local new = not getBooster()
    setBooster(new, true)
    UpdateBooster(new)
end)

AntiKnockBtn.MouseButton1Click:Connect(function()
    local new = not getAntiKnock()
    setAntiKnock(new, true)
    if new then EnableAntiRagdoll() else DisableAntiRagdoll() end
end)

HitboxBtn.MouseButton1Click:Connect(function()
    local new = not getHitbox()
    setHitbox(new, true)
    UpdateHitbox(new)
end)

SuperBypassBtn.MouseButton1Click:Connect(function()
    local new = not getSuperBypass()
    setSuperBypass(new, true)
    if new then EnableAntiKick() else DisableAntiKick() end
end)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/4RmZv2GyBx") end)
    local originalText = CopyBtn.Text
    CopyBtn.Text = "Copiado!"
    task.wait(1.5)
    CopyBtn.Text = originalText
end)

CloseBtn.MouseButton1Click:Connect(function()
    DeactivateTeleguiad()
    UpdateBooster(false)
    DisableAntiRagdoll()
    UpdateHitbox(false)
    DisableAntiKick()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- ══════════════════════════════════════════════
--           ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════

MainFrame.Size     = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size     = UDim2.new(0, 280, 0, 420),
    Position = UDim2.new(0.5, -140, 0.5, -210)
}):Play()

print("[branzZ Hub v3] Carregado! Otimizado para Mobile.")
