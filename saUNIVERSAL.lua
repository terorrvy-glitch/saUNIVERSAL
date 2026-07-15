--[[
    STANDALONE SCRIPT V4.1 - RAINBOW COLOR PICKER UPDATE
    Features: Built-in UI Gradient Color Picker, Responsive Drag, Sliders.
    Press 'INSERT' to Toggle UI
]]

-- Стираем старую версию интерфейса при перезапуске
local oldUI = game:GetService("CoreGui"):FindFirstChild("RobloxUniversalScriptUI") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("RobloxUniversalScriptUI")
if oldUI then oldUI:Destroy() end

-- =========================================================================
-- 1. НАСТРОЙКИ (КОНФИГУРАЦИЯ)
-- =========================================================================
local config = {
    aimbot = false,
    aimKey = Enum.KeyCode.K,
    aimPart = "HumanoidRootPart",
    prediction = 0,
    smoothness = 0.1,
    fovRadius = 150,
    showFov = true,
    teamCheck = false,
    wallCheck = false,
    
    -- НОВЫЕ ПАРАМЕТРЫ
    silentAim = false,
    espHealthBar = false,
    distanceCulling = 1000,
    
    esp = false,
    espBoxes = false,
    espNames = false,
    espPercentHp = false,
    espDist = false,
    espTracers = false,
    espChams = false,
    espColor = Color3.fromRGB(255, 50, 50),
    tracerColor = Color3.fromRGB(255, 255, 255),
    
    -- ДОБАВЛЕНИЕ ДЛЯ КЕЙБИНДОВ
    keybinds = {}
}

-- ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local currentTarget = nil
local espCache = {}

-- Функция сохранения и загрузки
local function saveConfig()
    local success, encoded = pcall(function() return HttpService:JSONEncode(config) end)
    if success then writefile("UniversalHack_Config.json", encoded) end
end

local function loadConfig()
    if isfile("UniversalHack_Config.json") then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile("UniversalHack_Config.json")) end)
        if success then for k, v in pairs(decoded) do if config[k] ~= nil then config[k] = v end end end
    end
end
loadConfig()

-- Отрисовка FOV круга
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = config.showFov
fovCircle.Radius = config.fovRadius
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1.5
fovCircle.Filled = false
fovCircle.Transparency = 1

-- =========================================================================
-- 2. ANIMATION HELPER FUNCTIONS (ДОБАВЛЕНО)
-- =========================================================================
local function ApplyHover(obj)
    obj.MouseEnter:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = obj.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.2)}):Play()
    end)
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = obj.BackgroundColor3}):Play()
    end)
end

local function StartPulse(obj)
    task.spawn(function()
        while true do
            TweenService:Create(obj, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Size = obj.Size + UDim2.new(0, 5, 0, 5)}):Play()
            task.wait(1.5)
            TweenService:Create(obj, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Size = obj.Size}):Play()
            task.wait(1.5)
        end
    end)
end

local function CreateAnimatedBackground(parent)
    local bg = Instance.new("Frame", parent)
    bg.Name = "AnimatedBG"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.ZIndex = 0
    local grad = Instance.new("UIGradient", bg)
    grad.Rotation = 0
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))})
    task.spawn(function()
        while true do
            for i = 0, 360, 2 do
                grad.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    return bg
end

-- =========================================================================
-- 3. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ UI BUILDER
-- =========================================================================
local function create(instanceType, properties, parent)
    local inst = Instance.new(instanceType)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

-- Создаем ScreenGui
local UI = create("ScreenGui", {Name = "RobloxUniversalScriptUI", ResetOnSpawn = false})
pcall(function() UI.Parent = CoreGui end)
if not UI.Parent then UI.Parent = player:WaitForChild("PlayerGui") end

-- ДОБАВЛЕНИЕ: Keybinds UI
local KeybindsUI = create("Frame", {
    Name = "KeybindsUI",
    Size = UDim2.new(0, 200, 0, 250),
    Position = UDim2.new(0, 50, 0, 50),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BackgroundTransparency = 0.5,
    Visible = true
}, UI)
create("UICorner", {CornerRadius = UDim.new(0, 8)}, KeybindsUI)
create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5}, KeybindsUI)

local KeybindsTitle = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Active Keybinds",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
}, KeybindsUI)

local KeybindsList = create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -40),
    Position = UDim2.new(0, 5, 0, 35),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2
}, KeybindsUI)
create("UIListLayout", {Padding = UDim.new(0, 5)}, KeybindsList)

local function updateKeybindDisplay(name, key, state)
    local existing = KeybindsList:FindFirstChild(name)
    if not existing then
        existing = create("TextLabel", {Name = name, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextSize = 13, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left}, KeybindsList)
    end
    existing.Text = " [" .. key.Name .. "] " .. name .. ": " .. (state and "ON" or "OFF")
    existing.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
end

-- Логика перетаскивания для KeybindsUI
local draggingKB, dragStartKB, startPosKB
KeybindsUI.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingKB = true
        dragStartKB = input.Position
        startPosKB = KeybindsUI.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingKB and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartKB
        KeybindsUI.Position = UDim2.new(startPosKB.X.Scale, startPosKB.X.Offset + delta.X, startPosKB.Y.Scale, startPosKB.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingKB = false end
end)

-- Главное окно
local MainFrame = create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 520, 0, 380),
    Position = UDim2.new(0.5, -260, 0.5, -190),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    ClipsDescendants = true
}, UI)
create("UICorner", {CornerRadius = UDim.new(0, 8)}, MainFrame)
create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), Thickness = 1.5}, MainFrame)

-- Применяем анимации
CreateAnimatedBackground(MainFrame)
StartPulse(MainFrame)

-- Верхняя панель (Перетаскивание)
local TopBar = create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0
}, MainFrame)
create("UICorner", {CornerRadius = UDim.new(0, 8)}, TopBar)

local Title = create("TextLabel", {
    Size = UDim2.new(1, -15, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "UNIVERSAL MULTIHACK (STANDALONE V4.1)",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

-- Логика перетаскивания (Drag)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Сайдбар вкладок (Слева)
local Sidebar = create("Frame", {
    Size = UDim2.new(0, 130, 1, -35),
    Position = UDim2.new(0, 0, 0, 35),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0
}, MainFrame)

-- Контейнер контента (Справа)
local Container = create("Frame", {
    Size = UDim2.new(1, -130, 1, -35),
    Position = UDim2.new(0, 130, 0, 35),
    BackgroundTransparency = 1
}, MainFrame)

-- Генератор вкладок
local function createTab(name, order)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -10, 0, 32),
        Position = UDim2.new(0, 5, 0, (order - 1) * 36 + 10),
        BackgroundColor3 = order == 1 and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(22, 22, 22),
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.SourceSansBold,
        TextSize = 13,
        BorderSizePixel = 0
    }, Sidebar)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)
    ApplyHover(btn) -- Hover effect

    local page = create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = order == 1
    }, Container)
    
    local layout = create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(22, 22, 22) end end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)

    return page
end

-- =========================================================================
-- 4. ВСТРОЕННЫЕ КОМПОНЕНТЫ ДЛЯ СТРАНИЦ UI
-- =========================================================================

-- Модифицированный Togge (с Bind кнопкой)
local function addToggle(parent, text, default, callback)
    local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1}, parent)
    
    create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = " " .. text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local btn = create("TextButton", {
        Size = UDim2.new(0, 45, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        BackgroundColor3 = default and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(50, 50, 50),
        Text = default and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 11,
        BorderSizePixel = 0
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, btn)
    ApplyHover(btn)
    
    -- ДОБАВЛЕНИЕ: Кнопка БИНДА
    local bindBtn = create("TextButton", {
        Size = UDim2.new(0, 45, 0, 20),
        Position = UDim2.new(0.75, 0, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = "Bind",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 11,
        BorderSizePixel = 0
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, bindBtn)
    ApplyHover(bindBtn)

    local state = default
    local currentKey = Enum.KeyCode.None

    local function updateVisuals(s)
        state = s
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 90) or Color3.fromRGB(50, 50, 50)
        btn.Text = state and "ON" or "OFF"
        callback(state)
        if currentKey ~= Enum.KeyCode.None then
            updateKeybindDisplay(text, currentKey, state)
        end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals(state)
    end)
    
    -- Логика бинда
    bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                bindBtn.Text = input.KeyCode.Name
                config.keybinds[input.KeyCode] = {name = text, state = state, cb = updateVisuals}
                updateKeybindDisplay(text, currentKey, state)
                conn:Disconnect()
            end
        end)
    end)

    return updateVisuals
end

-- Компонент: Кнопка (Button)
local function addButton(parent, text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(0, 120, 200),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 13,
        BorderSizePixel = 0
    }, parent)
    create("UICorner", {CornerRadius = UDim.new(0, 5)}, btn)
    ApplyHover(btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Компонент: Слайдер (Slider)
local function addSlider(parent, text, min, max, default, callback)
    local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1}, parent)
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = " " .. text .. ": " .. tostring(default),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local sliderBg = create("Frame", {
        Size = UDim2.new(1, -10, 0, 8),
        Position = UDim2.new(0, 5, 0, 26),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Active = true,
        BorderSizePixel = 0
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, sliderBg)

    local sliderFill = create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 120, 200),
        BorderSizePixel = 0
    }, sliderBg)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, sliderFill)

    local dragging = false

    local function updateSlider(input)
        local relativeX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
        local percent = relativeX / sliderBg.AbsoluteSize.X
        local value = min + (percent * (max - min))
        local roundedValue = math.round(value)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = " " .. text .. ": " .. tostring(roundedValue)
        callback(roundedValue)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

-- Компонент: Радужная палитра цвета
local function addColorPicker(parent, text, defaultColor, callback)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30), 
        BackgroundTransparency = 1
    }, parent)

    create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = " " .. text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)

    local colorPreview = create("TextButton", {
        Size = UDim2.new(0, 35, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        BackgroundColor3 = defaultColor,
        Text = "",
        BorderSizePixel = 0
    }, frame)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, colorPreview)
    create("UIStroke", {Color = Color3.fromRGB(60, 60, 60), Thickness = 1}, colorPreview)
    ApplyHover(colorPreview)

    local pickerDropdown = create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Visible = false,
        LayoutOrder = parent:GetChildren() and #parent:GetChildren() or 100
    }, parent)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, pickerDropdown)
    create("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Thickness = 1}, pickerDropdown)

    local colorWheel = create("Frame", {
        Size = UDim2.new(1, -20, 0, 15),
        Position = UDim2.new(0, 10, 0.5, -7),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    }, pickerDropdown)
    create("UICorner", {CornerRadius = UDim.new(0, 4)}, colorWheel)

    local gradient = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    }, colorWheel)

    local selectionMarker = create("Frame", {
        Size = UDim2.new(0, 6, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BorderSizePixel = 0,
        ZIndex = 5
    }, colorWheel)
    create("UICorner", {CornerRadius = UDim.new(0, 2)}, selectionMarker)
    create("UIStroke", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5}, selectionMarker)

    local picking = false

    local function updateColor(input)
        local wheelSize = colorWheel.AbsoluteSize
        local wheelPos = colorWheel.AbsolutePosition
        local inputPos = Vector2.new(input.Position.X, input.Position.Y)
        local percent = math.clamp((inputPos.X - wheelPos.X) / wheelSize.X, 0, 1)
        selectionMarker.Position = UDim2.new(percent, 0, 0.5, 0)
        local finalColor = Color3.fromHSV(percent, 1, 1)
        colorPreview.BackgroundColor3 = finalColor
        callback(finalColor)
    end

    colorPreview.MouseButton1Click:Connect(function()
        pickerDropdown.Visible = not pickerDropdown.Visible
    end)

    colorWheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            picking = true
            updateColor(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            picking = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if picking and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateColor(input)
        end
    end)
end

-- =========================================================================
-- 5. СОЗДАНИЕ СТРАНИЦ И СВЯЗЫВАНИЕ ПАРАМЕТРОВ
-- =========================================================================
local pAimbot = createTab("Aimbot", 1)
local pVisuals = createTab("Visuals", 2)
local pSettings = createTab("Settings", 3)

-- Вкладка: Aimbot
local updateAimToggle = addToggle(pAimbot, "Enable Aimbot", config.aimbot, function(v) config.aimbot = v if not v then currentTarget = nil end end)
addToggle(pAimbot, "Silent Aim", config.silentAim, function(v) config.silentAim = v end)

local partBtn
partBtn = addButton(pAimbot, "Target Part: " .. config.aimPart, function()
    if config.aimPart == "HumanoidRootPart" then config.aimPart = "Head"
    elseif config.aimPart == "Head" then config.aimPart = "Torso"
    else config.aimPart = "HumanoidRootPart" end
    partBtn.Text = "Target Part: " .. config.aimPart
end)

addSlider(pAimbot, "Smoothness (%)", 1, 100, math.round(config.smoothness * 100), function(v) 
    config.smoothness = v / 100
end)

addSlider(pAimbot, "Prediction", 0, 50, config.prediction, function(v) 
    config.prediction = v 
end)

addToggle(pAimbot, "Wall Check", config.wallCheck, function(v) config.wallCheck = v end)
addToggle(pAimbot, "Team Check", config.teamCheck, function(v) config.teamCheck = v end)


-- Вкладка: ESP
addToggle(pVisuals, "Master ESP Switch", config.esp, function(v) config.esp = v end)
addToggle(pVisuals, "Show Health Bar", config.espHealthBar, function(v) config.espHealthBar = v end)
addToggle(pVisuals, "Show 2D Boxes", config.espBoxes, function(v) config.espBoxes = v end)
addToggle(pVisuals, "Show Names", config.espNames, function(v) config.espNames = v end)
addToggle(pVisuals, "Show HP Stats", config.espPercentHp, function(v) config.espPercentHp = v end)
addToggle(pVisuals, "Show Distance", config.espDist, function(v) config.espDist = v end)
addToggle(pVisuals, "Show Tracers", config.espTracers, function(v) config.espTracers = v end)
addToggle(pVisuals, "Show Chams (Outline)", config.espChams, function(v) config.espChams = v end)
addSlider(pVisuals, "Distance Culling", 100, 5000, config.distanceCulling, function(v) config.distanceCulling = v end)

addColorPicker(pVisuals, "ESP Main Color", config.espColor, function(newColor)
    config.espColor = newColor
end)


-- Вкладка: Settings
addToggle(pSettings, "Show FOV Circular Ring", config.showFov, function(v) config.showFov = v fovCircle.Visible = v end)
addSlider(pSettings, "FOV Circular Radius", 50, 600, config.fovRadius, function(v) 
    config.fovRadius = v 
    fovCircle.Radius = v 
end)
addButton(pSettings, "Save Config", saveConfig)
addButton(pSettings, "Load Config", loadConfig)

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "Toggle Menu: INSERT key on your keyboard",
    TextColor3 = Color3.fromRGB(130, 130, 130),
    Font = Enum.Font.SourceSansItalic,
    TextSize = 13,
}, pSettings)

-- =========================================================================
-- 6. ИГРОВЫЕ СИСТЕМЫ И ЦИКЛЫ
-- =========================================================================

-- Обработка клавиш (Бинды + Menu Toggle)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Проверка динамических биндов
    if config.keybinds[input.KeyCode] then
        local data = config.keybinds[input.KeyCode]
        data.state = not data.state
        data.cb(data.state)
    end
    
    if input.KeyCode == config.aimKey then
        config.aimbot = not config.aimbot
        updateAimToggle(config.aimbot)
        if not config.aimbot then currentTarget = nil end
    elseif input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local function createEsp(p)
    if espCache[p] then return end
    espCache[p] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        Highlight = nil
    }
end

local function removeEsp(p)
    if espCache[p] then
        espCache[p].Box:Remove()
        espCache[p].Tracer:Remove()
        espCache[p].Name:Remove()
        espCache[p].Distance:Remove()
        espCache[p].HealthBar:Remove()
        if espCache[p].Highlight then espCache[p].Highlight:Destroy() end
        espCache[p] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do if p ~= player then createEsp(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= player then createEsp(p) end end)
Players.PlayerRemoving:Connect(removeEsp)

local function isVisible(targetPart)
    if not config.wallCheck then return true end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, params)
    if result and result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return not result
end

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = mousePos

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local cache = espCache[p]
            if not cache then createEsp(p) cache = espCache[p] end

            local char = p.Character
            local rpart = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if config.esp and char and rpart and hum and hum.Health > 0 then
                local dist = (camera.CFrame.Position - rpart.Position).Magnitude
                if config.distanceCulling > 0 and dist > config.distanceCulling then
                    cache.Box.Visible = false cache.Name.Visible = false cache.Distance.Visible = false cache.Tracer.Visible = false cache.HealthBar.Visible = false
                    if cache.Highlight then cache.Highlight.Enabled = false end
                    continue
                end

                if config.teamCheck and p.Team == player.Team then
                    cache.Box.Visible = false cache.Name.Visible = false cache.Distance.Visible = false cache.Tracer.Visible = false cache.HealthBar.Visible = false
                    if cache.Highlight then cache.Highlight.Enabled = false end
                    continue
                end

                local pos, onScreen = camera:WorldToViewportPoint(rpart.Position)
                if onScreen then
                    local width = math.clamp(1000 / dist, 10, 150)
                    local height = math.clamp(2000 / dist, 20, 250)

                    if config.espChams then
                        if not cache.Highlight or cache.Highlight.Parent ~= char then
                            if cache.Highlight then cache.Highlight:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.Parent = char
                            hl.FillColor = config.espColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            cache.Highlight = hl
                        else
                            cache.Highlight.Enabled = true
                            cache.Highlight.FillColor = config.espColor
                        end
                    else
                        if cache.Highlight then cache.Highlight.Enabled = false end
                    end

                    if config.espBoxes then
                        cache.Box.Visible = true
                        cache.Box.Size = Vector2.new(width, height)
                        cache.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                        cache.Box.Color = config.espColor
                        cache.Box.Thickness = 1.5
                    else cache.Box.Visible = false end

                    if config.espNames then
                        local text = p.Name
                        if config.espPercentHp then text = text .. " [" .. math.round(hum.Health) .. " HP]" end
                        cache.Name.Visible = true
                        cache.Name.Text = text
                        cache.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                        cache.Name.Color = config.espColor
                        cache.Name.Center = true
                        cache.Name.Size = 13
                        cache.Name.Outline = true
                    else cache.Name.Visible = false end

                    if config.espDist then
                        cache.Distance.Visible = true
                        cache.Distance.Text = math.round(dist) .. " studs"
                        cache.Distance.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                        cache.Distance.Color = config.espColor
                        cache.Distance.Center = true
                        cache.Distance.Size = 13
                        cache.Distance.Outline = true
                    else cache.Distance.Visible = false end

                    if config.espTracers then
                        cache.Tracer.Visible = true
                        cache.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        cache.Tracer.To = Vector2.new(pos.X, pos.Y + height/2)
                        cache.Tracer.Color = config.tracerColor
                    else cache.Tracer.Visible = false end
                    
                    if config.espHealthBar then
                        cache.HealthBar.Visible = true
                        local healthPercent = hum.Health / hum.MaxHealth
                        cache.HealthBar.From = Vector2.new(pos.X - width/2 - 5, pos.Y + height/2)
                        cache.HealthBar.To = Vector2.new(pos.X - width/2 - 5, pos.Y + height/2 - (height * healthPercent))
                        cache.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                        cache.HealthBar.Thickness = 2
                    else cache.HealthBar.Visible = false end

                else
                    cache.Box.Visible = false cache.Name.Visible = false cache.Distance.Visible = false cache.Tracer.Visible = false cache.HealthBar.Visible = false
                    if cache.Highlight then cache.Highlight.Enabled = false end
                end
            else
                cache.Box.Visible = false cache.Name.Visible = false cache.Distance.Visible = false cache.Tracer.Visible = false cache.HealthBar.Visible = false
                if cache.Highlight then cache.Highlight.Enabled = false end
            end
        end
    end

    if not config.aimbot then currentTarget = nil return end

    local targetValid = false
    if currentTarget and currentTarget.Parent == Players and currentTarget.Character and currentTarget.Character:FindFirstChild(config.aimPart) then
        local hum = currentTarget.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 and not (config.teamCheck and currentTarget.Team == player.Team) then
            targetValid = true
        end
    end

    if not targetValid then currentTarget = nil end

    if not currentTarget then
        local closest = nil
        local shortestDist = config.fovRadius

        for _, other in pairs(Players:GetPlayers()) do
            if other ~= player and other.Character and other.Character:FindFirstChild(config.aimPart) and other.Character:FindFirstChild("Humanoid") and other.Character.Humanoid.Health > 0 then
                if config.teamCheck and other.Team == player.Team then continue end
                
                local part = other.Character[config.aimPart]
                if isVisible(part) then
                    local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (mousePos - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < shortestDist then
                            closest = other
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        currentTarget = closest
    end

    if currentTarget then
        local target = currentTarget.Character[config.aimPart]
        local targetPosition = target.Position
        
        if config.prediction > 0 then
            targetPosition = targetPosition + (target.Velocity * (config.prediction / 100))
        end

        if config.silentAim then
            local lookAt = CFrame.new(camera.CFrame.Position, targetPosition)
            camera.CFrame = lookAt
        else
            local lookAt = CFrame.new(camera.CFrame.Position, targetPosition)
            camera.CFrame = camera.CFrame:Lerp(lookAt, config.smoothness)
        end
    end
end)