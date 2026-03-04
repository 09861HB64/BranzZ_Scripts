-- ██████╗ ██████╗  █████╗ ███╗   ██╗███████╗███████╗    ██╗  ██╗██╗   ██╗██████╗ 
-- ██╔══██╗██╔══██╗██╔══██╗████╗  ██║╚══███╔╝╚══███╔╝    ██║  ██║██║   ██║██╔══██╗
-- ██████╔╝██████╔╝███████║██╔██╗ ██║  ███╔╝   ███╔╝     ███████║██║   ██║██████╔╝
-- ██╔══██╗██╔══██╗██╔══██║██║╚██╗██║ ███╔╝   ███╔╝      ██╔══██║██║   ██║██╔══██╗
-- ██████╔╝██║  ██║██║  ██║██║ ╚████║███████╗███████╗    ██║  ██║╚██████╔╝██████╔╝
-- ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
-- branzZ MetoDos Hub v1 | by branzZ

-- ============================================================
-- CONFIGURAÇÕES GERAIS
-- ============================================================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1468460930781417492/elAaS8ZACFPUfe-FGNT2CK-0SUBEjrT6SU8B8GCXybEIfwcY2p4P03jY-myLIdXW-52S"
local SCRIPT_NAME = "branzZ Hub MetodoDos"
local HUB_VERSION = "v1"

-- IDs das Gamepasses (para abrir a página de compra no Roblox)
local GAMEPASS_IDS = {
    ["1 Day"]   = 1736759700,
    ["5 Days"]  = 1738612375,
    ["18 Days"] = 1737684588,
    ["30 Days"] = 1738094497,
    ["Perm"]    = 1736741709,
}

-- Duração em segundos de cada key (perm = 0 = infinito)
local KEY_DURATIONS = {
    ["1 Day"]   = 86400,
    ["5 Days"]  = 432000,
    ["18 Days"] = 1555200,
    ["30 Days"] = 2592000,
    ["Perm"]    = 0,
}

-- Preços em Robux (para exibir no webhook)
local KEY_PRICES = {
    ["1 Day"]   = "50 R$",
    ["5 Days"]  = "150 R$",
    ["18 Days"] = "300 R$",
    ["30 Days"] = "500 R$",
    ["Perm"]    = "1000 R$",
}

-- ============================================================
-- SERVIÇOS
-- ============================================================
local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")
local PlayerName    = LocalPlayer.Name
local PlayerDisplay = LocalPlayer.DisplayName
local UserId        = tostring(LocalPlayer.UserId)

-- ============================================================
-- SISTEMA DE STORAGE (DataStore simulado via _G e pcall)
-- ============================================================
local STORAGE_KEY = "branzZ_MetoDos_Keys_" .. UserId

local function getStorage()
    -- Usa _G como "memória de sessão" (persiste enquanto o jogo roda)
    if not _G["branzZ_KeyStorage"] then
        _G["branzZ_KeyStorage"] = {}
    end
    return _G["branzZ_KeyStorage"]
end

local function saveKeyData(keyType, purchaseTime, duration)
    local storage = getStorage()
    storage[keyType] = {
        purchaseTime = purchaseTime,
        duration     = duration,
        keyType      = keyType,
    }
end

local function getKeyData(keyType)
    local storage = getStorage()
    return storage[keyType]
end

local function isKeyValid(keyType)
    local data = getKeyData(keyType)
    if not data then return false end
    if data.duration == 0 then return true end -- Perm
    local elapsed = os.time() - data.purchaseTime
    return elapsed < data.duration
end

local function getRemainingTime(keyType)
    local data = getKeyData(keyType)
    if not data then return 0 end
    if data.duration == 0 then return math.huge end
    local remaining = data.duration - (os.time() - data.purchaseTime)
    return math.max(0, remaining)
end

local function formatTime(seconds)
    if seconds == math.huge then return "Permanente ♾️" end
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if d > 0 then
        return string.format("%dd %02dh %02dm", d, h, m)
    elseif h > 0 then
        return string.format("%02dh %02dm %02ds", h, m, s)
    else
        return string.format("%02dm %02ds", m, s)
    end
end

-- ============================================================
-- WEBHOOK DISCORD
-- ============================================================
local function sendWebhook(keyType)
    local avatarUrl = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", UserId)
    local price = KEY_PRICES[keyType] or "?"

    local embedColor = 0x00FF88  -- Verde Matrix

    local payload = HttpService:JSONEncode({
        content = "@everyone @here new player , Caiu No Metodo @everyone @here",
        embeds = {
            {
                title = "🟢 branzZ Hub " .. HUB_VERSION,
                color = embedColor,
                fields = {
                    {
                        name = "<:player:> Player Executor",
                        value = string.format("```\n%s (@%s)\n```", PlayerDisplay, PlayerName),
                        inline = false,
                    },
                    {
                        name = "📜 Script Name",
                        value = string.format("```\n%s\n```", SCRIPT_NAME),
                        inline = false,
                    },
                    {
                        name = "💰 Amount of Robux",
                        value = string.format("```\n%s — Key %s\n```", price, keyType),
                        inline = false,
                    },
                    {
                        name = "⏱️ Key Duration",
                        value = string.format("```\n%s\n```", keyType == "Perm" and "Permanente" or keyType),
                        inline = false,
                    },
                },
                thumbnail = {
                    url = avatarUrl,
                },
                image = {
                    url = "https://i.imgur.com/K5JjQLR.gif",
                },
                footer = {
                    text = "branzZ MetoDos Hub • " .. os.date("%d/%m/%Y %H:%M"),
                    icon_url = "https://files.manuscdn.com/user_upload_by_module/session_file/310519663397723909/wfEtsLfGjjCFSDka.png",
                },
            }
        }
    })

    pcall(function()
        -- Usa syn.request ou http.request dependendo do executor
        local requestFn = syn and syn.request or (http and http.request) or (request)
        if requestFn then
            requestFn({
                Url    = WEBHOOK_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body   = payload,
            })
        end
    end)
end

-- ============================================================
-- VERIFICAR SE JÁ TEM KEY ATIVA — se sim, pula a tela
-- ============================================================
local function hasAnyValidKey()
    for keyType, _ in pairs(GAMEPASS_IDS) do
        if isKeyValid(keyType) then
            return true, keyType
        end
    end
    return false, nil
end

-- ============================================================
-- EXECUTAR SCRIPT PRINCIPAL
-- ============================================================
local function executeMainScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/09861HB64/BranzZ_Scripts/refs/heads/main/PVPBranZZHubv1.lua.txt"))()
    end)
end

-- ============================================================
-- CONSTRUÇÃO DA GUI
-- ============================================================
local function buildGui()
    -- Remove GUI antiga se existir
    local old = PlayerGui:FindFirstChild("branzZ_MetoDos_ScreenGui")
    if old then old:Destroy() end

    -- ScreenGui raiz
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "branzZ_MetoDos_ScreenGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    -- Fundo escuro semi-transparente
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.45
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10
    Overlay.Parent = ScreenGui

    -- Partículas Matrix (canvas de chars verdes)
    local Canvas = Instance.new("Frame")
    Canvas.Size = UDim2.fromScale(1, 1)
    Canvas.BackgroundTransparency = 1
    Canvas.ZIndex = 11
    Canvas.Parent = ScreenGui

    -- Janela principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 620, 0, 540)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 5)
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 20
    MainFrame.Parent = ScreenGui

    -- Borda verde brilhante
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 255, 80)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    -- Gradiente no fundo da janela
    local UIGrad = Instance.new("UIGradient")
    UIGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 18, 5)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 5, 0)),
    })
    UIGrad.Rotation = 135
    UIGrad.Parent = MainFrame

    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 52)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 21
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    -- Patch no canto inferior da titlebar (para ficar reto embaixo)
    local TitlePatch = Instance.new("Frame")
    TitlePatch.Size = UDim2.new(1, 0, 0, 14)
    TitlePatch.Position = UDim2.new(0, 0, 1, -14)
    TitlePatch.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
    TitlePatch.BorderSizePixel = 0
    TitlePatch.ZIndex = 21
    TitlePatch.Parent = TitleBar

    -- Ícone / Logo no título
    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Size = UDim2.new(0, 44, 0, 44)
    TitleIcon.Position = UDim2.new(0, 8, 0.5, -22)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Text = "⬡"
    TitleIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
    TitleIcon.TextScaled = true
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.ZIndex = 22
    TitleIcon.Parent = TitleBar

    -- Texto do título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -110, 1, 0)
    TitleLabel.Position = UDim2.new(0, 58, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "branzZ  MetoDos  Hub  " .. HUB_VERSION
    TitleLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.TextScaled = false
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 22
    TitleLabel.Parent = TitleBar

    -- Sub-texto do título
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -110, 0, 14)
    SubLabel.Position = UDim2.new(0, 58, 0, 30)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Selecione sua Key para continuar"
    SubLabel.TextColor3 = Color3.fromRGB(0, 40, 0)
    SubLabel.TextScaled = false
    SubLabel.TextSize = 11
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.ZIndex = 22
    SubLabel.Parent = TitleBar

    -- Botão Fechar (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -18)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(0, 255, 80)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 23
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    -- Scroll da área de keys
    local KeyScroll = Instance.new("ScrollingFrame")
    KeyScroll.Size = UDim2.new(1, -24, 1, -100)
    KeyScroll.Position = UDim2.new(0, 12, 0, 62)
    KeyScroll.BackgroundTransparency = 1
    KeyScroll.BorderSizePixel = 0
    KeyScroll.ScrollBarThickness = 4
    KeyScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 80)
    KeyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    KeyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    KeyScroll.ZIndex = 21
    KeyScroll.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = KeyScroll

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0, 8)
    ListPadding.PaddingLeft = UDim.new(0, 4)
    ListPadding.PaddingRight = UDim.new(0, 4)
    ListPadding.Parent = KeyScroll

    -- Rodapé
    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 28)
    Footer.Position = UDim2.new(0, 0, 1, -30)
    Footer.BackgroundTransparency = 1
    Footer.Text = "⚡  branzZ MetoDos Hub  •  Powered by branzZ  ⚡"
    Footer.TextColor3 = Color3.fromRGB(0, 160, 50)
    Footer.TextSize = 11
    Footer.Font = Enum.Font.Gotham
    Footer.ZIndex = 21
    Footer.Parent = MainFrame

    -- ============================================================
    -- CONSTRUIR CARDS DAS KEYS
    -- ============================================================
    local keyOrder = {"1 Day", "5 Days", "18 Days", "30 Days", "Perm"}
    local keyLabels = {
        ["1 Day"]   = "Key 1 Day",
        ["5 Days"]  = "Key 5 Days",
        ["18 Days"] = "Key 18 Days",
        ["30 Days"] = "Key 30 Days",
        ["Perm"]    = "Key Permanente ♾️",
    }
    local keyColors = {
        ["1 Day"]   = Color3.fromRGB(0, 200, 60),
        ["5 Days"]  = Color3.fromRGB(0, 220, 100),
        ["18 Days"] = Color3.fromRGB(0, 240, 140),
        ["30 Days"] = Color3.fromRGB(60, 255, 160),
        ["Perm"]    = Color3.fromRGB(255, 215, 0),  -- Dourado
    }

    local timerLabels = {}  -- para atualizar timers depois

    for i, keyType in ipairs(keyOrder) do
        local valid = isKeyValid(keyType)
        if valid then
            -- Se já tem key ativa, não exibe o card
            -- (ou exibe como "ativa" — vamos exibir como ativa com timer)
        end

        -- Card container
        local Card = Instance.new("Frame")
        Card.Name = "Card_" .. keyType:gsub(" ", "_")
        Card.Size = UDim2.new(1, 0, 0, 72)
        Card.BackgroundColor3 = Color3.fromRGB(8, 20, 8)
        Card.BorderSizePixel = 0
        Card.LayoutOrder = i
        Card.ZIndex = 22
        Card.Parent = KeyScroll

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = valid and Color3.fromRGB(0, 255, 80) or Color3.fromRGB(0, 80, 25)
        CardStroke.Thickness = valid and 1.5 or 1
        CardStroke.Parent = Card

        -- Barra lateral colorida
        local SideBar = Instance.new("Frame")
        SideBar.Size = UDim2.new(0, 5, 1, -16)
        SideBar.Position = UDim2.new(0, 8, 0, 8)
        SideBar.BackgroundColor3 = keyColors[keyType]
        SideBar.BorderSizePixel = 0
        SideBar.ZIndex = 23
        SideBar.Parent = Card
        Instance.new("UICorner", SideBar).CornerRadius = UDim.new(1, 0)

        -- Nome da key
        local KeyNameLabel = Instance.new("TextLabel")
        KeyNameLabel.Size = UDim2.new(0.55, 0, 0, 26)
        KeyNameLabel.Position = UDim2.new(0, 22, 0, 10)
        KeyNameLabel.BackgroundTransparency = 1
        KeyNameLabel.Text = keyLabels[keyType]
        KeyNameLabel.TextColor3 = keyColors[keyType]
        KeyNameLabel.TextSize = 17
        KeyNameLabel.Font = Enum.Font.GothamBold
        KeyNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        KeyNameLabel.ZIndex = 23
        KeyNameLabel.Parent = Card

        -- Preço
        local PriceLabel = Instance.new("TextLabel")
        PriceLabel.Size = UDim2.new(0.55, 0, 0, 18)
        PriceLabel.Position = UDim2.new(0, 22, 0, 36)
        PriceLabel.BackgroundTransparency = 1
        PriceLabel.Text = "💎 " .. (KEY_PRICES[keyType] or "?")
        PriceLabel.TextColor3 = Color3.fromRGB(140, 255, 140)
        PriceLabel.TextSize = 12
        PriceLabel.Font = Enum.Font.Gotham
        PriceLabel.TextXAlignment = Enum.TextXAlignment.Left
        PriceLabel.ZIndex = 23
        PriceLabel.Parent = Card

        -- Timer label
        local TimerLabel = Instance.new("TextLabel")
        TimerLabel.Name = "TimerLabel"
        TimerLabel.Size = UDim2.new(0.55, 0, 0, 14)
        TimerLabel.Position = UDim2.new(0, 22, 0, 54)
        TimerLabel.BackgroundTransparency = 1
        TimerLabel.Text = valid and ("⏱ " .. formatTime(getRemainingTime(keyType))) or ""
        TimerLabel.TextColor3 = Color3.fromRGB(0, 200, 60)
        TimerLabel.TextSize = 10
        TimerLabel.Font = Enum.Font.Gotham
        TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
        TimerLabel.ZIndex = 23
        TimerLabel.Parent = Card
        timerLabels[keyType] = TimerLabel

        -- Botão
        local BtnText = valid and "✅  ATIVA" or "🛒  COMPRAR"
        local BtnColor = valid and Color3.fromRGB(0, 50, 15) or keyColors[keyType]
        local BtnTextColor = valid and Color3.fromRGB(0, 255, 80) or Color3.fromRGB(0, 0, 0)

        local BuyBtn = Instance.new("TextButton")
        BuyBtn.Name = "BuyBtn"
        BuyBtn.Size = UDim2.new(0, 130, 0, 40)
        BuyBtn.Position = UDim2.new(1, -142, 0.5, -20)
        BuyBtn.BackgroundColor3 = BtnColor
        BuyBtn.Text = BtnText
        BuyBtn.TextColor3 = BtnTextColor
        BuyBtn.TextSize = 14
        BuyBtn.Font = Enum.Font.GothamBold
        BuyBtn.BorderSizePixel = 0
        BuyBtn.ZIndex = 23
        BuyBtn.AutoButtonColor = false
        BuyBtn.Parent = Card

        Instance.new("UICorner", BuyBtn).CornerRadius = UDim.new(0, 8)

        local BuyStroke = Instance.new("UIStroke")
        BuyStroke.Color = keyColors[keyType]
        BuyStroke.Thickness = 1
        BuyStroke.Parent = BuyBtn

        if not valid then
            -- Hover effect
            BuyBtn.MouseEnter:Connect(function()
                TweenService:Create(BuyBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(
                        math.min(keyColors[keyType].R * 255 + 30, 255),
                        math.min(keyColors[keyType].G * 255 + 30, 255),
                        math.min(keyColors[keyType].B * 255 + 30, 255)
                    )
                }):Play()
            end)
            BuyBtn.MouseLeave:Connect(function()
                TweenService:Create(BuyBtn, TweenInfo.new(0.15), {BackgroundColor3 = keyColors[keyType]}):Play()
            end)

            -- Clique no botão de comprar
            BuyBtn:GetPropertyChangedSignal("Active")  -- dummy
            BuyBtn.MouseButton1Click:Connect(function()
                -- Prompt de compra da gamepass no Roblox
                local gpId = GAMEPASS_IDS[keyType]
                if gpId then
                    local success, err = pcall(function()
                        MarketplaceService:PromptGamePassPurchase(LocalPlayer, gpId)
                    end)

                    -- Aguardar confirmação de compra
                    local conn
                    conn = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
                        if player == LocalPlayer and passId == gpId and purchased then
                            conn:Disconnect()

                            -- Salvar key
                            local now = os.time()
                            local dur = KEY_DURATIONS[keyType]
                            saveKeyData(keyType, now, dur)

                            -- Enviar webhook
                            task.spawn(sendWebhook, keyType)

                            -- Atualizar botão
                            BuyBtn.Text = "✅  ATIVA"
                            BuyBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 15)
                            BuyBtn.TextColor3 = Color3.fromRGB(0, 255, 80)
                            CardStroke.Color = Color3.fromRGB(0, 255, 80)
                            CardStroke.Thickness = 1.5

                            -- Fechar GUI e executar script principal
                            task.delay(1.5, function()
                                TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                                    Position = UDim2.new(0.5, 0, 1.5, 0),
                                    BackgroundTransparency = 1,
                                }):Play()
                                task.delay(0.6, function()
                                    ScreenGui:Destroy()
                                    executeMainScript()
                                end)
                            end)
                        elseif player == LocalPlayer and passId == gpId and not purchased then
                            conn:Disconnect()
                        end
                    end)
                end
            end)
        else
            -- Key já ativa: ao clicar executa o script
            BuyBtn.MouseButton1Click:Connect(function()
                TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                    Position = UDim2.new(0.5, 0, 1.5, 0),
                }):Play()
                task.delay(0.6, function()
                    ScreenGui:Destroy()
                    executeMainScript()
                end)
            end)
        end
    end

    -- ============================================================
    -- ARRASTAR JANELA (drag)
    -- ============================================================
    local dragging, dragInput, dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ============================================================
    -- BOTÃO FECHAR
    -- ============================================================
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.delay(0.45, function() ScreenGui:Destroy() end)
    end)

    -- ============================================================
    -- ANIMAÇÃO DE ENTRADA
    -- ============================================================
    MainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }):Play()

    -- ============================================================
    -- ATUALIZAR TIMERS EM TEMPO REAL
    -- ============================================================
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            for keyType, lbl in pairs(timerLabels) do
                if lbl and lbl.Parent then
                    if isKeyValid(keyType) then
                        local rem = getRemainingTime(keyType)
                        lbl.Text = "⏱ " .. formatTime(rem)
                        -- Se expirou, esconder o card inteiro
                        if rem == 0 then
                            local card = KeyScroll:FindFirstChild("Card_" .. keyType:gsub(" ", "_"))
                            if card then card:Destroy() end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)

    -- ============================================================
    -- EFEITO MATRIX NO FUNDO (labels caindo)
    -- ============================================================
    task.spawn(function()
        local chars = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ01"
        local charList = {}
        for i = 1, #chars, 1 do
            local c = chars:sub(i, i)
            if c ~= "" then table.insert(charList, c) end
        end

        local columns = 20
        local drops = {}
        local labels = {}

        for col = 1, columns do
            drops[col] = math.random(1, 30)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 20, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(0, 255, 70)
            lbl.TextSize = 14
            lbl.Font = Enum.Font.Code
            lbl.ZIndex = 12
            lbl.Parent = Canvas
            labels[col] = lbl
        end

        while Canvas and Canvas.Parent do
            local vp = workspace.CurrentCamera.ViewportSize
            for col = 1, columns do
                local x = (col - 1) * (vp.X / columns)
                local y = drops[col] * 20
                labels[col].Position = UDim2.new(0, x, 0, y)
                labels[col].Text = charList[math.random(#charList)]
                labels[col].TextTransparency = math.random() * 0.4

                if y > vp.Y and math.random() > 0.975 then
                    drops[col] = 0
                else
                    drops[col] = drops[col] + 1
                end
            end
            task.wait(0.06)
        end
    end)
end

-- ============================================================
-- PONTO DE ENTRADA
-- ============================================================
local hasKey, activeKey = hasAnyValidKey()

if hasKey then
    -- Já tem key ativa — pular tela e executar diretamente
    -- (mas mostrar uma tela rápida confirmando)
    task.spawn(function()
        -- Pequena notificação de "Key ativa"
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "branzZ_Notif"
        notifGui.ResetOnSpawn = false
        notifGui.ZIndex = 100
        notifGui.Parent = PlayerGui

        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 340, 0, 64)
        notif.Position = UDim2.new(0.5, -170, 0, -80)
        notif.BackgroundColor3 = Color3.fromRGB(5, 18, 5)
        notif.BorderSizePixel = 0
        notif.ZIndex = 101
        notif.Parent = notifGui

        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
        local ns = Instance.new("UIStroke", notif)
        ns.Color = Color3.fromRGB(0, 255, 80)
        ns.Thickness = 1.5

        local nt = Instance.new("TextLabel")
        nt.Size = UDim2.fromScale(1, 1)
        nt.BackgroundTransparency = 1
        nt.Text = "✅  Key " .. activeKey .. " ativa — Carregando Hub..."
        nt.TextColor3 = Color3.fromRGB(0, 255, 80)
        nt.TextSize = 15
        nt.Font = Enum.Font.GothamBold
        nt.ZIndex = 102
        nt.Parent = notif

        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -170, 0, 12)
        }):Play()

        task.delay(2.5, function()
            TweenService:Create(notif, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -170, 0, -80)
            }):Play()
            task.delay(0.35, function()
                notifGui:Destroy()
            end)
        end)

        task.delay(0.5, executeMainScript)
    end)
else
    -- Mostrar tela de keys
    buildGui()
end
