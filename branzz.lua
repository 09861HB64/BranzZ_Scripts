-- branzZ Hub v1 | Key System
-- Compativel com: Delta, Arceus X, KRNL, Synapse, Fluxus, Studio Lite

local WEBHOOK_URL = "https://discord.com/api/webhooks/1481338703233417379/VDo_2imj-8XcT9KJnAJAyULXLxa33HEdOOy5A4BOKPUSg75lF5sn4jxNP7ylj_RbS6xo"
local SCRIPT_NAME = "branzZ Hub MetodoDos"
local HUB_VERSION = "branzZ Hub v1"
local KEY_FILE    = "branzzHub_v1.json"

--[[
    ╔══════════════════════════════════════════╗
    ║        COMANDOS DE ATIVAÇÃO DE KEY       ║
    ║                                          ║
    ║  Digite no CHAT do Roblox:               ║
    ║                                          ║
    ║  /key1   →  Ativa Key 1 Day  (24h)       ║
    ║  /key2   →  Ativa Key 5 Days             ║
    ║  /key3   →  Ativa Key 18 Days            ║
    ║  /key4   →  Ativa Key 30 Days            ║
    ║  /key5   →  Ativa Key Permanente         ║
    ║                                          ║
    ║  Só funciona para o dono (seu usuario)   ║
    ╚══════════════════════════════════════════╝
]]

-- ══ SEU USERNAME (dono) — só você pode usar os comandos ══
local OWNER_NAME = "botzinYT12"

-- ══ Gamepasses ══
local GAMEPASSES = {
    [1] = { name = "1 Day",   id = 1736759700, duration = 86400,     icon = "⚡", color = Color3.fromRGB(60, 200, 100)  },
    [2] = { name = "5 Days",  id = 1738612375, duration = 432000,    icon = "🔥", color = Color3.fromRGB(255, 160, 0)   },
    [3] = { name = "18 Days", id = 1737684588, duration = 1555200,   icon = "💎", color = Color3.fromRGB(80, 140, 255)  },
    [4] = { name = "30 Days", id = 1738094497, duration = 2592000,   icon = "👑", color = Color3.fromRGB(200, 60, 255)  },
    [5] = { name = "Perm",    id = 1736741709, duration = math.huge, icon = "♾",  color = Color3.fromRGB(255, 80, 0)    },
}

-- ══ Serviços ══
local Players     = game:GetService("Players")
local MPS         = game:GetService("MarketplaceService")
local HttpSvc     = game:GetService("HttpService")
local TweenSvc    = game:GetService("TweenService")
local CoreGui     = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══ Salvar / Carregar Key ══
local function saveKey(name, expireTime)
    if writefile then
        writefile(KEY_FILE, HttpSvc:JSONEncode({ key = name, exp = expireTime }))
    end
end

local function loadKey()
    if readfile and isfile and isfile(KEY_FILE) then
        local ok, d = pcall(function() return HttpSvc:JSONDecode(readfile(KEY_FILE)) end)
        if ok and d then return d end
    end
    return nil
end

local function clearKey()
    if delfile and isfile and isfile(KEY_FILE) then pcall(delfile, KEY_FILE) end
end

-- ══ Webhook ══
local function GetAvatar(uid)
    local url = string.format(
        "https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=%d&size=420x420&format=Png&isCircular=false",
        uid
    )
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and res then
        local parsed = HttpSvc:JSONDecode(res)
        if parsed and parsed.data and parsed.data[1] then
            return parsed.data[1].imageUrl
        end
    end
    return "https://tr.rbxcdn.com/placeholder/420/420/Image/Png"
end

local function sendWebhook(keyName)
    local userId      = LocalPlayer.UserId
    local displayName = LocalPlayer.DisplayName
    local userName    = LocalPlayer.Name
    local profileUrl  = "https://www.roblox.com/users/" .. userId .. "/profile"
    local avatarUrl   = GetAvatar(userId)

    -- Nome do jogo
    local gameName = "Unknown"
    local placeId  = tostring(game.PlaceId)
    local gameId   = tostring(game.GameId)
    pcall(function() gameName = MPS:GetProductInfo(game.PlaceId).Name end)

    -- Expiração
    local expireText = "♾️  Permanente"
    for _, p in ipairs(GAMEPASSES) do
        if p.name == keyName then
            if p.duration ~= math.huge then
                expireText = "📅  " .. math.floor(p.duration / 86400) .. " dia(s)"
            end
            break
        end
    end

    -- Cor da key
    local keyColor = 0xFF4500
    for _, p in ipairs(GAMEPASSES) do
        if p.name == keyName then
            keyColor = math.floor(p.color.R*255)*65536 + math.floor(p.color.G*255)*256 + math.floor(p.color.B*255)
            break
        end
    end

    local sep = "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬"

    local body = HttpSvc:JSONEncode({
        content    = "@everyone @here",
        username   = "BranzzLoggers",
        avatar_url = avatarUrl,
        embeds = {{
            color = keyColor,
            author = {
                name     = displayName .. "  •  @" .. userName,
                url      = profileUrl,
                icon_url = avatarUrl,
            },
            title = "🔑  Nova Key Ativada!",
            description =
                sep .. "\n" ..
                "** **\n" ..
                "🎮  **Jogo:** " .. gameName .. "\n" ..
                "🔑  **Key:** `" .. keyName .. "`\n" ..
                expireText .. "\n" ..
                "** **\n" ..
                sep .. "\n" ..
                "** **\n" ..
                "👤  **[" .. displayName .. "](" .. profileUrl .. ")**\n" ..
                "`@" .. userName .. "` — ID: `" .. tostring(userId) .. "`\n" ..
                "** **\n" ..
                sep,
            fields = {
                {
                    name   = "📍  Place ID",
                    value  = "`" .. placeId .. "`",
                    inline = true,
                },
                {
                    name   = "🕐  Horário",
                    value  = "`" .. os.date("!%d/%m/%Y  %H:%M") .. " UTC`",
                    inline = true,
                },
            },
            thumbnail = { url = avatarUrl },
            image     = { url = "https://i.imgur.com/sJUiZhI.jpeg" },
            footer = {
                text     = "branzZ Hub v1  •  " .. SCRIPT_NAME,
                icon_url = avatarUrl,
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }}
    })

    -- Todos os métodos de request
    local sent = false
    if not sent and request then
        pcall(function()
            request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            sent = true
        end)
    end
    if not sent and http_request then
        pcall(function()
            http_request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            sent = true
        end)
    end
    if not sent and syn and syn.request then
        pcall(function()
            syn.request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            sent = true
        end)
    end
    if not sent and http and http.request then
        pcall(function()
            http.request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            sent = true
        end)
    end
end

-- ══ Roda o Hub principal ══
local function runHub()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/09861HB64/BranzZ_Scripts/refs/heads/main/PVPBranZZHubv1.lua.txt"))()
    end)
end

-- ══ Notificação flutuante ══
local notifGui
local function showNotif(msg, r, g, b)
    pcall(function()
        if notifGui then notifGui:Destroy() end

        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "BranzZNotif"
        notifGui.DisplayOrder = 99999
        notifGui.ResetOnSpawn = false
        pcall(function() notifGui.Parent = CoreGui end)
        if not notifGui.Parent or notifGui.Parent ~= CoreGui then
            notifGui.Parent = PlayerGui
        end

        local Box = Instance.new("Frame", notifGui)
        Box.Size = UDim2.new(0, 280, 0, 44)
        Box.Position = UDim2.new(0.5, -140, 0, -50)
        Box.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
        Box.BorderSizePixel = 0
        Box.ZIndex = 2
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

        local BS = Instance.new("UIStroke", Box)
        BS.Color = Color3.fromRGB(r, g, b)
        BS.Thickness = 1.5
        BS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local Lbl = Instance.new("TextLabel", Box)
        Lbl.Size = UDim2.new(1,-16,1,0)
        Lbl.Position = UDim2.new(0,8,0,0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = msg
        Lbl.TextColor3 = Color3.fromRGB(r, g, b)
        Lbl.TextSize = 13
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextXAlignment = Enum.TextXAlignment.Center
        Lbl.ZIndex = 3

        -- Slide down
        TweenSvc:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -140, 0, 18)
        }):Play()

        -- Slide up e destroi
        task.delay(2.8, function()
            TweenSvc:Create(Box, TweenInfo.new(0.25), {
                Position = UDim2.new(0.5, -140, 0, -50)
            }):Play()
            task.wait(0.3)
            pcall(function() notifGui:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════
--     SISTEMA DE COMANDOS NO CHAT
-- ══════════════════════════════════════════
local function setupChatCommands(onActivate)
    -- Mapa de comandos
    local commands = {
        ["/key1"] = 1,
        ["/key2"] = 2,
        ["/key3"] = 3,
        ["/key4"] = 4,
        ["/key5"] = 5,
    }

    local function handleChat(msg)
        msg = msg:lower():gsub("%s+", "")  -- lowercase e remove espaços

        local keyNum = commands[msg]
        if not keyNum then return end

        -- Só o dono pode usar
        if LocalPlayer.Name ~= OWNER_NAME then
            showNotif("❌ Sem permissão!", 255, 80, 80)
            return
        end

        local plan = GAMEPASSES[keyNum]
        if plan then
            onActivate(plan)
        end
    end

    -- Tenta conectar no chat (compatível com vários executores)
    pcall(function()
        local Chat = game:GetService("Chat")

        -- Método 1: StarterGui SetCore (mais compatível)
        LocalPlayer.Chatted:Connect(function(msg)
            handleChat(msg)
        end)
    end)
end

-- ══ GUI ══
local activeScreenGui = nil

local function createUI()
    pcall(function()
        if CoreGui:FindFirstChild("BranzZKey") then CoreGui:FindFirstChild("BranzZKey"):Destroy() end
        if PlayerGui:FindFirstChild("BranzZKey") then PlayerGui:FindFirstChild("BranzZKey"):Destroy() end
    end)

    local SG = Instance.new("ScreenGui")
    SG.Name           = "BranzZKey"
    SG.ResetOnSpawn   = false
    SG.DisplayOrder   = 9999
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = pcall(function() SG.Parent = CoreGui end)
    if not ok or SG.Parent ~= CoreGui then SG.Parent = PlayerGui end
    activeScreenGui = SG

    -- Fundo escuro
    local OV = Instance.new("Frame", SG)
    OV.Size = UDim2.new(1,0,1,0)
    OV.BackgroundColor3 = Color3.fromRGB(0,0,0)
    OV.BackgroundTransparency = 0.5
    OV.BorderSizePixel = 0
    OV.ZIndex = 1

    -- Janela compacta
    local W = Instance.new("Frame", SG)
    W.Name = "Window"
    W.Size = UDim2.new(0, 370, 0, 385)
    W.Position = UDim2.new(0.5, -185, 0.5, -210)
    W.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    W.BorderSizePixel = 0
    W.ZIndex = 2
    Instance.new("UICorner", W).CornerRadius = UDim.new(0, 10)

    local WS = Instance.new("UIStroke", W)
    WS.Color = Color3.fromRGB(255, 85, 0)
    WS.Thickness = 1.5
    WS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Topbar
    local TB = Instance.new("Frame", W)
    TB.Size = UDim2.new(1,0,0,42)
    TB.BackgroundColor3 = Color3.fromRGB(18, 10, 4)
    TB.BorderSizePixel = 0
    TB.ZIndex = 3
    Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 10)

    local TG = Instance.new("UIGradient", TB)
    TG.Color = ColorSequence.new(Color3.fromRGB(255,85,0), Color3.fromRGB(14,8,2))
    TG.Rotation = 90
    TG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(1, 1),
    })

    local TitleLbl = Instance.new("TextLabel", TB)
    TitleLbl.Size = UDim2.new(1,-48,1,0)
    TitleLbl.Position = UDim2.new(0,12,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "🔥  branzZ Hub  |  Key System"
    TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLbl.TextSize = 13
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 4

    -- Botão fechar
    local X = Instance.new("TextButton", W)
    X.Size = UDim2.new(0,26,0,26)
    X.Position = UDim2.new(1,-34,0,8)
    X.BackgroundColor3 = Color3.fromRGB(180,30,30)
    X.Text = "✕"
    X.TextColor3 = Color3.fromRGB(255,255,255)
    X.TextSize = 12
    X.Font = Enum.Font.GothamBold
    X.ZIndex = 10
    Instance.new("UICorner", X).CornerRadius = UDim.new(0,5)
    X.MouseButton1Click:Connect(function() SG:Destroy() end)
    X.MouseEnter:Connect(function() X.BackgroundColor3 = Color3.fromRGB(255,50,50) end)
    X.MouseLeave:Connect(function() X.BackgroundColor3 = Color3.fromRGB(180,30,30) end)

    -- Sub
    local Sub = Instance.new("TextLabel", W)
    Sub.Size = UDim2.new(1,-16,0,14)
    Sub.Position = UDim2.new(0,8,0,46)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Escolha seu plano e clique em Comprar"
    Sub.TextColor3 = Color3.fromRGB(130,130,150)
    Sub.TextSize = 10
    Sub.Font = Enum.Font.Gotham
    Sub.TextXAlignment = Enum.TextXAlignment.Center
    Sub.ZIndex = 3

    -- Divisória
    local Div = Instance.new("Frame", W)
    Div.Size = UDim2.new(1,-28,0,1)
    Div.Position = UDim2.new(0,14,0,64)
    Div.BackgroundColor3 = Color3.fromRGB(255,85,0)
    Div.BackgroundTransparency = 0.72
    Div.BorderSizePixel = 0
    Div.ZIndex = 3

    -- Container
    local CT = Instance.new("Frame", W)
    CT.Size = UDim2.new(1,-18,0,285)
    CT.Position = UDim2.new(0,9,0,72)
    CT.BackgroundTransparency = 1
    CT.ZIndex = 3
    local ULL = Instance.new("UIListLayout", CT)
    ULL.Padding = UDim.new(0,6)
    ULL.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Status
    local Status = Instance.new("TextLabel", W)
    Status.Size = UDim2.new(1,-16,0,16)
    Status.Position = UDim2.new(0,8,1,-22)
    Status.BackgroundTransparency = 1
    Status.Text = "Selecione um plano para continuar"
    Status.TextColor3 = Color3.fromRGB(110,110,130)
    Status.TextSize = 10
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Center
    Status.ZIndex = 4

    local function setStatus(txt, r, g, b)
        Status.Text = txt
        Status.TextColor3 = Color3.fromRGB(r or 110, g or 110, b or 130)
    end

    -- Função de ativação de key (usada tanto pelo botão quanto pelo chat)
    local function activatePlan(plan)
        local exp = (plan.duration == math.huge) and math.huge or (os.time() + plan.duration)
        saveKey(plan.name, exp)
        pcall(sendWebhook, plan.name)
        setStatus("✅ Key " .. plan.name .. " ativada! Carregando Hub...", 60, 220, 100)
        showNotif("✅  Key " .. plan.name .. " ativada!", 60, 220, 100)
        task.wait(1.2)
        SG:Destroy()
        runHub()
    end

    -- Linhas de plano
    local function makeRow(plan, index)
        local Row = Instance.new("Frame", CT)
        Row.Size = UDim2.new(1,0,0,50)
        Row.BackgroundColor3 = Color3.fromRGB(16,16,28)
        Row.BorderSizePixel = 0
        Row.ZIndex = 4
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0,8)

        local RS = Instance.new("UIStroke", Row)
        RS.Color = plan.color
        RS.Transparency = 0.7
        RS.Thickness = 1.2
        RS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Ícone
        local Ico = Instance.new("TextLabel", Row)
        Ico.Size = UDim2.new(0,34,1,0)
        Ico.Position = UDim2.new(0,6,0,0)
        Ico.BackgroundTransparency = 1
        Ico.Text = plan.icon
        Ico.TextSize = 18
        Ico.Font = Enum.Font.GothamBold
        Ico.TextXAlignment = Enum.TextXAlignment.Center
        Ico.ZIndex = 5

        -- Nome
        local Nm = Instance.new("TextLabel", Row)
        Nm.Size = UDim2.new(0,120,0,20)
        Nm.Position = UDim2.new(0,46,0,7)
        Nm.BackgroundTransparency = 1
        Nm.Text = "Key " .. plan.name
        Nm.TextColor3 = Color3.fromRGB(235,235,235)
        Nm.TextSize = 12
        Nm.Font = Enum.Font.GothamBold
        Nm.TextXAlignment = Enum.TextXAlignment.Left
        Nm.ZIndex = 5

        -- Duração
        local Desc = Instance.new("TextLabel", Row)
        Desc.Size = UDim2.new(0,155,0,14)
        Desc.Position = UDim2.new(0,47,0,27)
        Desc.BackgroundTransparency = 1
        Desc.Text = plan.duration == math.huge and "Acesso permanente ♾" or
            (tostring(math.floor(plan.duration / 86400)) .. " dias de acesso")
        Desc.TextColor3 = Color3.fromRGB(110,110,130)
        Desc.TextSize = 10
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.ZIndex = 5

        -- Botão Comprar
        local Btn = Instance.new("TextButton", Row)
        Btn.Size = UDim2.new(0,88,0,30)
        Btn.Position = UDim2.new(1,-96,0.5,-15)
        Btn.BackgroundColor3 = plan.color
        Btn.Text = "Comprar"
        Btn.TextColor3 = Color3.fromRGB(255,255,255)
        Btn.TextSize = 12
        Btn.Font = Enum.Font.GothamBold
        Btn.ZIndex = 6
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

        Btn.MouseEnter:Connect(function()
            TweenSvc:Create(Btn, TweenInfo.new(0.1), { BackgroundColor3 = plan.color:lerp(Color3.new(1,1,1),0.2) }):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenSvc:Create(Btn, TweenInfo.new(0.1), { BackgroundColor3 = plan.color }):Play()
        end)

        local busy = false
        Btn.MouseButton1Click:Connect(function()
            if busy then return end
            busy = true
            Btn.Text = "..."
            setStatus("⏳ Aguardando compra...", 255, 200, 0)

            local ok2, errMsg = pcall(function()
                MPS:PromptGamePassPurchase(LocalPlayer, plan.id)
            end)

            if not ok2 then
                setStatus("❌ Erro ao abrir prompt!", 255, 80, 80)
                Btn.Text = "Comprar"
                busy = false
                return
            end

            local conn
            conn = MPS.PromptGamePassPurchaseFinished:Connect(function(plr, gpId, wasBought)
                if plr ~= LocalPlayer or gpId ~= plan.id then return end
                conn:Disconnect()
                if wasBought then
                    activatePlan(plan)
                else
                    setStatus("❌ Compra cancelada.", 255, 80, 80)
                    Btn.Text = "Comprar"
                    busy = false
                end
            end)

            task.delay(35, function()
                if busy then
                    pcall(function() conn:Disconnect() end)
                    setStatus("⏱ Tempo esgotado. Tente novamente.", 200, 120, 0)
                    Btn.Text = "Comprar"
                    busy = false
                end
            end)
        end)
    end

    for i, plan in ipairs(GAMEPASSES) do
        makeRow(plan, i)
    end

    -- Registra os comandos de chat (passa activatePlan)
    setupChatCommands(function(plan)
        activatePlan(plan)
    end)

    -- Animação entrada
    W.BackgroundTransparency = 1
    W.Position = UDim2.new(0.5,-185,0.42,-210)
    TweenSvc:Create(W, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5,-185,0.5,-210),
    }):Play()
end

-- ══ INICIO ══
local saved = loadKey()
if saved then
    if saved.exp == math.huge or (saved.exp and os.time() < saved.exp) then
        runHub()
    else
        clearKey()
        createUI()
    end
else
    createUI()
end
