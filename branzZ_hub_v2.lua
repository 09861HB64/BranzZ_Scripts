--[[
    branzZ Hub v2 - Key System (Compacto e Corrigido)
    - UI Redimensionada para ser menor e mais bonita.
    - Lógica de compra revisada para garantir o prompt do Roblox.
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local userId = player.UserId
local webhookUrl = "https://discord.com/api/webhooks/1468460930781417492/elAaS8ZACFPUfe-FGNT2CK-0SUBEjrT6SU8B8GCXybEIfwcY2p4P03jY-myLIdXW-52S"
local mainScriptUrl = "https://raw.githubusercontent.com/09861HB64/BranzZ_Scripts/refs/heads/main/PVPBranZZHubv1.lua.txt"

-- Configuração das Gamepasses
local keys = {
    {id = 1736759700, name = "Key 1 Day", duration = 86400},
    {id = 1738612375, name = "Key 5 Days", duration = 432000},
    {id = 1737684588, name = "Key 18 Days", duration = 1555200},
    {id = 1738094497, name = "Key 30 Days", duration = 2592000},
    {id = 1736741709, name = "Key Perm", duration = -1}
}

-- Funções de Persistência
local function saveKeyData(passId, duration)
    local data = {
        passId = passId,
        activationTime = os.time(),
        duration = duration
    }
    if writefile then
        pcall(function()
            writefile("branzZ_key.json", HttpService:JSONEncode(data))
        end)
    end
end

local function loadKeyData()
    if readfile and isfile and isfile("branzZ_key.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("branzZ_key.json"))
        end)
        if success then return result end
    end
    return nil
end

-- Função de Webhook (Discord Embed)
local function sendDiscordLog(passName, passId)
    local success, productInfo = pcall(function()
        return MarketplaceService:GetProductInfo(passId, Enum.InfoType.GamePass)
    end)
    local price = success and productInfo.PriceInRobux or "Desconhecido"
    
    local payload = {
        ["content"] = "@everyone @here new player , Caiu No Metodo @everyone @here",
        ["embeds"] = {{
            ["title"] = "branzZ Hub v1",
            ["color"] = 0x2b2d31,
            ["fields"] = {
                {["name"] = "👤 Player Executor", ["value"] = player.Name .. " (" .. player.DisplayName .. ")", ["inline"] = false},
                {["name"] = "📜 Script Name", ["value"] = "branzZ Hub MetodoDos", ["inline"] = false},
                {["name"] = "💰 Amount of Robux", ["value"] = tostring(price) .. " Robux", ["inline"] = false},
                {["name"] = "🔑 Key Type", ["value"] = passName, ["inline"] = false}
            },
            ["thumbnail"] = {["url"] = "https://files.manuscdn.com/user_upload_by_module/session_file/310519663397723909/LNvWDSXpqStpTlIM.png"},
            ["image"] = {["url"] = "https://files.manuscdn.com/user_upload_by_module/session_file/310519663397723909/wfEtsLfGjjCFSDka.png"},
            ["footer"] = {
                ["text"] = "branzZ Hub v1",
                ["icon_url"] = "https://files.manuscdn.com/user_upload_by_module/session_file/310519663397723909/LEeaDQXHJBJlDbRQ.jpg"
            }
        }}
    }

    local requestFunc = syn and syn.request or http and http.request or http_request or request
    if requestFunc then
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end
end

-- UI Compacta e Bonita
local function createUI()
    -- Remover UI antiga se existir
    if CoreGui:FindFirstChild("BranzZHub_KeySystem") then
        CoreGui:FindFirstChild("BranzZHub_KeySystem"):Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "BranzZHub_KeySystem"
    screen.Parent = CoreGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 400) -- Reduzido (era 380x480)
    main.Position = UDim2.new(0.5, -160, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    main.BorderSizePixel = 0
    main.Parent = screen
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1.5
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "branzZ Hub v1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = main

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -38, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.TextSize = 20
    close.Parent = main
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function() screen:Destroy() end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -30, 1, -80)
    scroll.Position = UDim2.new(0, 15, 0, 65)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
    scroll.Parent = main
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = scroll

    for _, k in pairs(keys) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 50) -- Botões mais compactos
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Text = "🛒 " .. k.name
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromRGB(45, 45, 45)
        bStroke.Thickness = 1
        bStroke.Parent = btn

        -- Lógica de Compra Corrigida
        btn.MouseButton1Click:Connect(function()
            print("Tentando comprar GamePass ID: " .. tostring(k.id))
            MarketplaceService:PromptGamePassPurchase(player, k.id)
        end)
    end

    -- Listener de Compra (Fora do Loop)
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, passId, wasPurchased)
        if plr == player and wasPurchased then
            for _, k in pairs(keys) do
                if k.id == passId then
                    saveKeyData(passId, k.duration)
                    sendDiscordLog(k.name, passId)
                    screen:Destroy()
                    task.wait(0.5)
                    loadstring(game:HttpGet(mainScriptUrl))()
                    break
                end
            end
        end
    end)
end

-- Lógica Principal de Verificação
local function checkAccess()
    local data = loadKeyData()
    local hasAccess = false
    
    if data then
        if data.duration == -1 then
            hasAccess = true
        else
            local timeElapsed = os.time() - data.activationTime
            if timeElapsed < data.duration then
                hasAccess = true
            end
        end
    end
    
    -- Verificação via API (se já comprou mas não tem arquivo)
    if not hasAccess then
        for _, k in pairs(keys) do
            local success, owns = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(userId, k.id)
            end)
            if success and owns then
                saveKeyData(k.id, k.duration)
                hasAccess = true
                break
            end
        end
    end
    
    if hasAccess then
        loadstring(game:HttpGet(mainScriptUrl))()
    else
        createUI()
    end
end

checkAccess()
