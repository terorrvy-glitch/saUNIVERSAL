local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

-- Настройки ESP
local ESP = {
 Enabled = true,
 HighlightColor = Color3.fromRGB(255, 0, 0),
 OutlineColor = Color3.fromRGB(255, 255, 255),
 NPCEnabled = true,
 PlayerEnabled = true,
 ShowDistance = true,
 MaxDistance = 500,
 ShowFPS = true
}

-- Ждем загрузки игрока
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESP_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- ===== FPS СЧЕТЧИК (ПЕРЕТАСКИВАЕМЫЙ) =====
local FPSFrame = Instance.new("Frame")
FPSFrame.Name = "FPSFrame"
FPSFrame.Size = UDim2.new(0, 90, 0, 35)
FPSFrame.Position = UDim2.new(1, -100, 0, 10)
FPSFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
FPSFrame.BackgroundTransparency = 0.15
FPSFrame.BorderSizePixel = 0
FPSFrame.Parent = ScreenGui

local FPSStroke = Instance.new("UIStroke")
FPSStroke.Thickness = 1
FPSStroke.Color = Color3.fromRGB(255, 75, 75)
FPSStroke.Transparency = 0.5
FPSStroke.Parent = FPSFrame

local FPSCorner = Instance.new("UICorner")
FPSCorner.CornerRadius = UDim.new(0, 8)
FPSCorner.Parent = FPSFrame

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSLabel"
FPSLabel.Size = UDim2.new(1, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 0"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextSize = 15
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Parent = FPSFrame

-- Переменные для FPS
local fpsHistory = {}
local fpsUpdateTime = 0
local currentFPS = 0

local function updateFPS(deltaTime)
 if deltaTime > 0 then
  local fps = math.floor(1 / deltaTime)
  table.insert(fpsHistory, fps)
  if #fpsHistory > 20 then table.remove(fpsHistory, 1) end
  local total = 0
  for _, v in ipairs(fpsHistory) do total = total + v end
  currentFPS = math.floor(total / #fpsHistory)
 end
 if tick() - fpsUpdateTime > 0.2 then
  fpsUpdateTime = tick()
  if currentFPS >= 60 then
   FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
  elseif currentFPS >= 30 then
   FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
  else
   FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
  end
  FPSLabel.Text = "FPS: " .. currentFPS
 end
end

-- Перетаскивание FPS счетчика
local fpsDragging = false
local fpsDragStart = nil
local fpsStartPos = nil

FPSFrame.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  fpsDragging = true
  fpsDragStart = input.Position
  fpsStartPos = FPSFrame.Position
 end
end)

UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  fpsDragging = false
 end
end)

UserInputService.InputChanged:Connect(function(input)
 if fpsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
  local delta = input.Position - fpsDragStart
  FPSFrame.Position = UDim2.new(
   fpsStartPos.X.Scale,
   fpsStartPos.X.Offset + delta.X,
   fpsStartPos.Y.Scale,
   fpsStartPos.Y.Offset + delta.Y
  )
 end
end)

-- ===== ГЛАВНОЕ МЕНЮ (ШИРЕ - 400px) =====
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 560)
MainFrame.Position = UDim2.new(0, 10, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(255, 75, 75)
MainStroke.Transparency = 0.6
MainStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
TitleBar.BackgroundTransparency =


0.15
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
})
TitleGradient.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ ESP CONTROL V2.5"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 17
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -40, 0, 7)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.BackgroundTransparency = 0.85
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 22
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

-- Вкладки
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 35)
TabFrame.Position = UDim2.new(0, 0, 0, 45)
TabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local FpsTab = Instance.new("TextButton")
FpsTab.Size = UDim2.new(0.33, -2, 1, 0)
FpsTab.Position = UDim2.new(0, 0, 0, 0)
FpsTab.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
FpsTab.BackgroundTransparency = 0.3
FpsTab.Text = "📊 FPS"
FpsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
FpsTab.TextSize = 14
FpsTab.Font = Enum.Font.GothamBold
FpsTab.Parent = TabFrame

local InfoTab = Instance.new("TextButton")
InfoTab.Size = UDim2.new(0.33, -2, 1, 0)
InfoTab.Position = UDim2.new(0.33, 2, 0, 0)
InfoTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
InfoTab.Text = "ℹ️ INFO"
InfoTab.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoTab.TextSize = 14
InfoTab.Font = Enum.Font.GothamBold
InfoTab.Parent = TabFrame

local SettingsTab = Instance.new("TextButton")
SettingsTab.Size = UDim2.new(0.34, 0, 1, 0)
SettingsTab.Position = UDim2.new(0.66, 4, 0, 0)
SettingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
SettingsTab.Text = "⚙️ SETTINGS"
SettingsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsTab.TextSize = 14
SettingsTab.Font = Enum.Font.GothamBold
SettingsTab.Parent = TabFrame

-- Контейнеры для контента вкладок
local FpsContent = Instance.new("Frame")
FpsContent.Size = UDim2.new(1, -40, 1, -110)
FpsContent.Position = UDim2.new(0, 20, 0, 85)
FpsContent.BackgroundTransparency = 1
FpsContent.Visible = true
FpsContent.Parent = MainFrame

local InfoContent = Instance.new("Frame")
InfoContent.Size = UDim2.new(1, -40, 1, -110)
InfoContent.Position = UDim2.new(0, 20, 0, 85)
InfoContent.BackgroundTransparency = 1
InfoContent.Visible = false
InfoContent.Parent = MainFrame

local SettingsContent = Instance.new("Frame")
SettingsContent.Size = UDim2.new(1, -40, 1, -110)
SettingsContent.Position = UDim2.new(0, 20, 0, 85)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = MainFrame

-- ===== ВКЛАДКА FPS =====
local FpsSectionLabel = Instance.new("TextLabel")
FpsSectionLabel.Size = UDim2.new(1, 0, 0, 25)
FpsSectionLabel.Position = UDim2.new(0, 0, 0, 5)
FpsSectionLabel.BackgroundTransparency = 1
FpsSectionLabel.Text = "📡 MAX RENDER DISTANCE"
FpsSectionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
FpsSectionLabel.TextSize = 13
FpsSectionLabel.Font = Enum.Font.GothamBlack
FpsSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsSectionLabel.Parent = FpsContent

local RangeValueLabel = Instance.new("TextLabel")
RangeValueLabel.Size = UDim2.new(1, 0, 0, 30)
RangeValueLabel.Position = UDim2.new(0, 0, 0, 32)
RangeValueLabel.BackgroundTransparency =


1
RangeValueLabel.Text = ESP.MaxDistance .. " METERS"
RangeValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeValueLabel.TextSize = 16
RangeValueLabel.Font = Enum.Font.GothamBold
RangeValueLabel.Parent = FpsContent

-- Кнопки дистанции (шире)
local DecreaseButton = Instance.new("TextButton")
DecreaseButton.Size = UDim2.new(0, 80, 0, 35)
DecreaseButton.Position = UDim2.new(0, 5, 0, 70)
DecreaseButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
DecreaseButton.BackgroundTransparency = 0.3
DecreaseButton.Text = "-50"
DecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseButton.TextSize = 14
DecreaseButton.Font = Enum.Font.GothamBold
DecreaseButton.Parent = FpsContent

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 6)
DecreaseCorner.Parent = DecreaseButton

local Preset100Button = Instance.new("TextButton")
Preset100Button.Size = UDim2.new(0, 85, 0, 35)
Preset100Button.Position = UDim2.new(0, 92, 0, 70)
Preset100Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Preset100Button.Text = "100m"
Preset100Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset100Button.TextSize = 14
Preset100Button.Font = Enum.Font.GothamBold
Preset100Button.Parent = FpsContent

local Preset100Corner = Instance.new("UICorner")
Preset100Corner.CornerRadius = UDim.new(0, 6)
Preset100Corner.Parent = Preset100Button

local Preset250Button = Instance.new("TextButton")
Preset250Button.Size = UDim2.new(0, 85, 0, 35)
Preset250Button.Position = UDim2.new(0, 184, 0, 70)
Preset250Button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Preset250Button.Text = "250m"
Preset250Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Preset250Button.TextSize = 14
Preset250Button.Font = Enum.Font.GothamBold
Preset250Button.Parent = FpsContent

local Preset250Corner = Instance.new("UICorner")
Preset250Corner.CornerRadius = UDim.new(0, 6)
Preset250Corner.Parent = Preset250Button

local IncreaseButton = Instance.new("TextButton")
IncreaseButton.Size = UDim2.new(0, 80, 0, 35)
IncreaseButton.Position = UDim2.new(0, 276, 0, 70)
IncreaseButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
IncreaseButton.BackgroundTransparency = 0.3
IncreaseButton.Text = "+50"
IncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseButton.TextSize = 14
IncreaseButton.Font = Enum.Font.GothamBold
IncreaseButton.Parent = FpsContent

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 6)
IncreaseCorner.Parent = IncreaseButton

local UnlimitedButton = Instance.new("TextButton")
UnlimitedButton.Size = UDim2.new(1, -10, 0, 35)
UnlimitedButton.Position = UDim2.new(0, 5, 0, 115)
UnlimitedButton.BackgroundColor3 = Color3.fromRGB(255, 128, 0)
UnlimitedButton.BackgroundTransparency = 0.3
UnlimitedButton.Text = "♾️ UNLIMITED"
UnlimitedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlimitedButton.TextSize = 14
UnlimitedButton.Font = Enum.Font.GothamBold
UnlimitedButton.Parent = FpsContent

local UnlimitedCorner = Instance.new("UICorner")
UnlimitedCorner.CornerRadius = UDim.new(0, 6)
UnlimitedCorner.Parent = UnlimitedButton

-- Разделитель во вкладке FPS
local fpsDivider = Instance.new("Frame")
fpsDivider.Size = UDim2.new(1, 0, 0, 2)
fpsDivider.Position = UDim2.new(0, 0, 0, 165)
fpsDivider.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
fpsDivider.BackgroundTransparency = 0.6
fpsDivider.BorderSizePixel = 0
fpsDivider.Parent = FpsContent

-- FPS Counter в меню
local FpsMenuLabel = Instance.new("TextLabel")
FpsMenuLabel.Size = UDim2.new(1, 0, 0, 25)
FpsMenuLabel.Position = UDim2.new(0, 0, 0, 175)
FpsMenuLabel.BackgroundTransparency = 1
FpsMenuLabel.Text = "📊 FPS COUNTER"
FpsMenuLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
FpsMenuLabel.TextSize = 13
FpsMenuLabel.Font = Enum.Font.GothamBlack
FpsMenuLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsMenuLabel.Parent = FpsContent

local FpsValueLabel = Instance.new("TextLabel")
FpsValueLabel.Size = UDim2.new(1, 0, 0, 40)
FpsValueLabel.Position = UDim2.new(0, 0, 0, 205)
FpsValueLabel.BackgroundTransparency = 1
FpsValueLabel.Text = "60


FPS"
FpsValueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
FpsValueLabel.TextSize = 28
FpsValueLabel.Font = Enum.Font.GothamBlack
FpsValueLabel.Parent = FpsContent

local FPSToggleInMenu = Instance.new("TextButton")
FPSToggleInMenu.Size = UDim2.new(1, 0, 0, 35)
FPSToggleInMenu.Position = UDim2.new(0, 0, 0, 255)
FPSToggleInMenu.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
FPSToggleInMenu.BackgroundTransparency = 0.3
FPSToggleInMenu.Text = "FPS OVERLAY: ON"
FPSToggleInMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSToggleInMenu.TextSize = 14
FPSToggleInMenu.Font = Enum.Font.GothamBold
FPSToggleInMenu.Parent = FpsContent

local FPSToggleCorner2 = Instance.new("UICorner")
FPSToggleCorner2.CornerRadius = UDim.new(0, 6)
FPSToggleCorner2.Parent = FPSToggleInMenu

-- ===== ВКЛАДКА INFO =====
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 90, 0, 90)
AvatarFrame.Position = UDim2.new(0.5, -45, 0, 15)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
AvatarFrame.BackgroundTransparency = 0.5
AvatarFrame.BorderSizePixel = 0
AvatarFrame.Parent = InfoContent

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 45)
AvatarCorner.Parent = AvatarFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Name = "AvatarImage"
AvatarImage.Size = UDim2.new(1, -6, 1, -6)
AvatarImage.Position = UDim2.new(0, 3, 0, 3)
AvatarImage.BackgroundTransparency = 1
AvatarImage.BorderSizePixel = 0
AvatarImage.Parent = AvatarFrame

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(0, 42)
AvatarImageCorner.Parent = AvatarImage

-- Загрузка аватара
coroutine.wrap(function()
 pcall(function()
  local userId = localPlayer.UserId
  local thumbType = Enum.ThumbnailType.HeadShot
  local thumbSize = Enum.ThumbnailSize.Size420x420
  local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
  AvatarImage.Image = content
 end)
end)()

-- Никнейм
local NicknameLabel = Instance.new("TextLabel")
NicknameLabel.Size = UDim2.new(1, 0, 0, 30)
NicknameLabel.Position = UDim2.new(0, 0, 0, 120)
NicknameLabel.BackgroundTransparency = 1
NicknameLabel.Text = localPlayer.Name
NicknameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NicknameLabel.TextSize = 22
NicknameLabel.Font = Enum.Font.GothamBlack
NicknameLabel.Parent = InfoContent

-- Welcome
local WelcomeLabel = Instance.new("TextLabel")
WelcomeLabel.Size = UDim2.new(1, 0, 0, 25)
WelcomeLabel.Position = UDim2.new(0, 0, 0, 155)
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Text = "WELCOME!"
WelcomeLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
WelcomeLabel.TextSize = 18
WelcomeLabel.Font = Enum.Font.GothamBold
WelcomeLabel.Parent = InfoContent

-- Разделитель в INFO
local infoDivider = Instance.new("Frame")
infoDivider.Size = UDim2.new(1, 0, 0, 2)
infoDivider.Position = UDim2.new(0, 0, 0, 195)
infoDivider.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
infoDivider.BackgroundTransparency = 0.6
infoDivider.BorderSizePixel = 0
infoDivider.Parent = InfoContent

-- Статистика
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 25)
StatsLabel.Position = UDim2.new(0, 0, 0, 205)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "📋 STATISTICS"
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
StatsLabel.TextSize = 14
StatsLabel.Font = Enum.Font.GothamBlack
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = InfoContent

local PlayersCountLabel = Instance.new("TextLabel")
PlayersCountLabel.Size = UDim2.new(1, 0, 0, 25)
PlayersCountLabel.Position = UDim2.new(0, 0, 0, 235)
PlayersCountLabel.BackgroundTransparency = 1
PlayersCountLabel.Text = "👥 Players in game: " .. #Players:GetPlayers()
PlayersCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayersCountLabel.TextSize = 14
PlayersCountLabel.Font = Enum.Font.Gotham
PlayersCountLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayersCountLabel.Parent = InfoContent

-- Время игры
local GameTimeLabel = Instance.new("TextLabel")
GameTimeLabel.Size = UDim2.new(1, 0, 0,


25)
GameTimeLabel.Position = UDim2.new(0, 0, 0, 263)
GameTimeLabel.BackgroundTransparency = 1
GameTimeLabel.Text = "⏱ Time in game: 0s"
GameTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTimeLabel.TextSize = 14
GameTimeLabel.Font = Enum.Font.Gotham
GameTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
GameTimeLabel.Parent = InfoContent

-- ===== ВКЛАДКА SETTINGS =====
local ColorSectionLabel = Instance.new("TextLabel")
ColorSectionLabel.Size = UDim2.new(1, 0, 0, 25)
ColorSectionLabel.Position = UDim2.new(0, 0, 0, 5)
ColorSectionLabel.BackgroundTransparency = 1
ColorSectionLabel.Text = "🎨 HIGHLIGHT COLOR"
ColorSectionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
ColorSectionLabel.TextSize = 14
ColorSectionLabel.Font = Enum.Font.GothamBlack
ColorSectionLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorSectionLabel.Parent = SettingsContent

local colors = {
 {name = "Red", color = Color3.fromRGB(255, 0, 0)},
 {name = "Blue", color = Color3.fromRGB(0, 100, 255)},
 {name = "Green", color = Color3.fromRGB(0, 255, 0)},
 {name = "Purple", color = Color3.fromRGB(138, 43, 226)},
 {name = "Yellow", color = Color3.fromRGB(255, 255, 0)},
 {name = "Orange", color = Color3.fromRGB(255, 128, 0)},
 {name = "Pink", color = Color3.fromRGB(255, 20, 147)},
 {name = "Cyan", color = Color3.fromRGB(0, 255, 255)}
}

for i, colorData in ipairs(colors) do
 local row = math.floor((i-1) / 4)
 local col = (i-1) % 4

 local colorButton = Instance.new("TextButton")
 colorButton.Size = UDim2.new(0, 78, 0, 32)
 colorButton.Position = UDim2.new(0, 5 + (col * 86), 0, 35 + (row * 40))
 colorButton.BackgroundColor3 = colorData.color
 colorButton.Text = ""
 colorButton.BorderSizePixel = 0
 colorButton.Parent = SettingsContent

 local btnCorner = Instance.new("UICorner")
 btnCorner.CornerRadius = UDim.new(0, 5)
 btnCorner.Parent = colorButton

 local stroke = Instance.new("UIStroke")
 stroke.Thickness = 0
 stroke.Color = Color3.fromRGB(255, 255, 255)
 stroke.Parent = colorButton

 if colorData.name == "Red" then
  stroke.Thickness = 2.5
 end

 colorButton.MouseButton1Click:Connect(function()
  ESP.HighlightColor = colorData.color
  for _, child in ipairs(SettingsContent:GetChildren()) do
   if child:IsA("TextButton") and child ~= PlayersToggle and child ~= NPCToggle and child ~= DistanceToggle and child ~= ESPToggleButton then
    local childStroke = child:FindFirstChildOfClass("UIStroke")
    if childStroke then childStroke.Thickness = 0 end
   end
  end
  stroke.Thickness = 2.5
  updateAllHighlights()
 end)
end

-- Разделитель в Settings
local settingsDivider = Instance.new("Frame")
settingsDivider.Size = UDim2.new(1, 0, 0, 2)
settingsDivider.Position = UDim2.new(0, 0, 0, 120)
settingsDivider.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
settingsDivider.BackgroundTransparency = 0.6
settingsDivider.BorderSizePixel = 0
settingsDivider.Parent = SettingsContent

-- Переключатели в Settings
local TargetsLabel = Instance.new("TextLabel")
TargetsLabel.Size = UDim2.new(1, 0, 0, 25)
TargetsLabel.Position = UDim2.new(0, 0, 0, 128)
TargetsLabel.BackgroundTransparency = 1
TargetsLabel.Text = "🎯 TARGETS"
TargetsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
TargetsLabel.TextSize = 14
TargetsLabel.Font = Enum.Font.GothamBlack
TargetsLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetsLabel.Parent = SettingsContent

local ESPToggleButton = Instance.new("TextButton")
ESPToggleButton.Size = UDim2.new(1, 0, 0, 35)
ESPToggleButton.Position = UDim2.new(0, 0, 0, 158)
ESPToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
ESPToggleButton.BackgroundTransparency = 0.3
ESPToggleButton.Text = "🔴 ESP: ON"
ESPToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleButton.TextSize = 14
ESPToggleButton.Font = Enum.Font.GothamBold
ESPToggleButton.TextXAlignment = Enum.TextXAlignment.Left
ESPToggleButton.Parent = SettingsContent

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0, 6)
ESPToggleCorner.Parent = ESPToggleButton

local PlayersToggle = Instance.new("TextButton")
PlayersToggle.Size =


UDim2.new(1, 0, 0, 35)
PlayersToggle.Position = UDim2.new(0, 0, 0, 198)
PlayersToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
PlayersToggle.BackgroundTransparency = 0.3
PlayersToggle.Text = "👤 PLAYERS: ON"
PlayersToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayersToggle.TextSize = 14
PlayersToggle.Font = Enum.Font.GothamBold
PlayersToggle.TextXAlignment = Enum.TextXAlignment.Left
PlayersToggle.Parent = SettingsContent

local PlayersToggleCorner = Instance.new("UICorner")
PlayersToggleCorner.CornerRadius = UDim.new(0, 6)
PlayersToggleCorner.Parent = PlayersToggle

local NPCToggle = Instance.new("TextButton")
NPCToggle.Size = UDim2.new(1, 0, 0, 35)
NPCToggle.Position = UDim2.new(0, 0, 0, 238)
NPCToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
NPCToggle.BackgroundTransparency = 0.3
NPCToggle.Text = "🤖 NPC: ON"
NPCToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NPCToggle.TextSize = 14
NPCToggle.Font = Enum.Font.GothamBold
NPCToggle.TextXAlignment = Enum.TextXAlignment.Left
NPCToggle.Parent = SettingsContent

local NPCToggleCorner = Instance.new("UICorner")
NPCToggleCorner.CornerRadius = UDim.new(0, 6)
NPCToggleCorner.Parent = NPCToggle

local DistanceToggle = Instance.new("TextButton")
DistanceToggle.Size = UDim2.new(1, 0, 0, 35)
DistanceToggle.Position = UDim2.new(0, 0, 0, 278)
DistanceToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
DistanceToggle.BackgroundTransparency = 0.3
DistanceToggle.Text = "📏 DISTANCE: ON"
DistanceToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceToggle.TextSize = 14
DistanceToggle.Font = Enum.Font.GothamBold
DistanceToggle.TextXAlignment = Enum.TextXAlignment.Left
DistanceToggle.Parent = SettingsContent

local DistanceToggleCorner = Instance.new("UICorner")
DistanceToggleCorner.CornerRadius = UDim.new(0, 6)
DistanceToggleCorner.Parent = DistanceToggle

-- ===== ПОДПИСЬ =====
local CreditsFrame = Instance.new("Frame")
CreditsFrame.Size = UDim2.new(1, 0, 0, 35)
CreditsFrame.Position = UDim2.new(0, 0, 1, -35)
CreditsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
CreditsFrame.BackgroundTransparency = 0.3
CreditsFrame.BorderSizePixel = 0
CreditsFrame.Parent = MainFrame

local CreditsCorner = Instance.new("UICorner")
CreditsCorner.CornerRadius = UDim.new(0, 12)
CreditsCorner.Parent = CreditsFrame

local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Size = UDim2.new(1, 0, 1, 0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "By simsoni228  •  V2.5"
CreditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsLabel.TextTransparency = 0.5
CreditsLabel.TextSize = 14
CreditsLabel.Font = Enum.Font.GothamBlack
CreditsLabel.Parent = CreditsFrame

-- ===== СВОРАЧИВАНИЕ МЕНЮ =====
local isMinimized = false

MinimizeButton.MouseButton1Click:Connect(function()
 isMinimized = not isMinimized
 if isMinimized then
  TabFrame.Visible = false
  FpsContent.Visible = false
  InfoContent.Visible = false
  SettingsContent.Visible = false
  CreditsFrame.Visible = false
  MainFrame.Size = UDim2.new(0, 400, 0, 45)
  MinimizeButton.Text = "+"
 else
  TabFrame.Visible = true
  CreditsFrame.Visible = true
  MainFrame.Size = UDim2.new(0, 400, 0, 560)
  MinimizeButton.Text = "—"
  -- Восстанавливаем видимость текущей вкладки
  if currentTab == "FPS" then
   FpsContent.Visible = true
  elseif currentTab == "INFO" then
   InfoContent.Visible = true
  elseif currentTab == "SETTINGS" then
   SettingsContent.Visible = true
  end
 end
end)

-- ===== ФУНКЦИОНАЛ ВКЛАДОК =====
local currentTab = "FPS"

local function switchTab(tab)
 FpsContent.Visible = false
 InfoContent.Visible = false
 SettingsContent.Visible = false

 FpsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
 InfoTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
 SettingsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)

 FpsTab.TextColor3 = Color3.fromRGB(200, 200, 200)
 InfoTab.TextColor3 = Color3.fromRGB(200, 200, 200)
 SettingsTab.TextColor3 = Color3.fromRGB(200, 200, 200)

 if tab == "FPS" then
  FpsContent.Visible = true
  FpsTab.BackgroundColor3 = Color3.fromRGB(255, 75,


75)
  FpsTab.BackgroundTransparency = 0.3
  FpsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
 elseif tab == "INFO" then
  InfoContent.Visible = true
  InfoTab.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
  InfoTab.BackgroundTransparency = 0.3
  InfoTab.TextColor3 = Color3.fromRGB(255, 255, 255)
  PlayersCountLabel.Text = "👥 Players in game: " .. #Players:GetPlayers()
 elseif tab == "SETTINGS" then
  SettingsContent.Visible = true
  SettingsTab.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
  SettingsTab.BackgroundTransparency = 0.3
  SettingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
 end
 currentTab = tab
end

FpsTab.MouseButton1Click:Connect(function() switchTab("FPS") end)
InfoTab.MouseButton1Click:Connect(function() switchTab("INFO") end)
SettingsTab.MouseButton1Click:Connect(function() switchTab("SETTINGS") end)

-- ===== ФУНКЦИОНАЛ КНОПОК =====
local function updateRangeDisplay()
 RangeValueLabel.Text = ESP.MaxDistance .. " METERS"
 updateAllHighlights()
end

DecreaseButton.MouseButton1Click:Connect(function()
 ESP.MaxDistance = math.max(50, ESP.MaxDistance - 50)
 updateRangeDisplay()
end)

IncreaseButton.MouseButton1Click:Connect(function()
 ESP.MaxDistance = ESP.MaxDistance + 50
 updateRangeDisplay()
end)

Preset100Button.MouseButton1Click:Connect(function()
 ESP.MaxDistance = 100
 updateRangeDisplay()
end)

Preset250Button.MouseButton1Click:Connect(function()
 ESP.MaxDistance = 250
 updateRangeDisplay()
end)

UnlimitedButton.MouseButton1Click:Connect(function()
 ESP.MaxDistance = math.huge
 RangeValueLabel.Text = "UNLIMITED"
 updateAllHighlights()
end)

FPSToggleInMenu.MouseButton1Click:Connect(function()
 ESP.ShowFPS = not ESP.ShowFPS
 if ESP.ShowFPS then
  FPSToggleInMenu.Text = "FPS OVERLAY: ON"
  FPSToggleInMenu.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
  FPSFrame.Visible = true
 else
  FPSToggleInMenu.Text = "FPS OVERLAY: OFF"
  FPSToggleInMenu.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
  FPSFrame.Visible = false
 end
end)

ESPToggleButton.MouseButton1Click:Connect(function()
 ESP.Enabled = not ESP.Enabled
 if ESP.Enabled then
  ESPToggleButton.Text = "🔴 ESP: ON"
  ESPToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
 else
  ESPToggleButton.Text = "⚫ ESP: OFF"
  ESPToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
 end
 updateAllHighlights()
end)

PlayersToggle.MouseButton1Click:Connect(function()
 ESP.PlayerEnabled = not ESP.PlayerEnabled
 if ESP.PlayerEnabled then
  PlayersToggle.Text = "👤 PLAYERS: ON"
  PlayersToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
 else
  PlayersToggle.Text = "👤 PLAYERS: OFF"
  PlayersToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
 end
 updateAllHighlights()
end)

NPCToggle.MouseButton1Click:Connect(function()
 ESP.NPCEnabled = not ESP.NPCEnabled
 if ESP.NPCEnabled then
  NPCToggle.Text = "🤖 NPC: ON"
  NPCToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
 else
  NPCToggle.Text = "🤖 NPC: OFF"
  NPCToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
 end
 updateAllHighlights()
end)

DistanceToggle.MouseButton1Click:Connect(function()
 ESP.ShowDistance = not ESP.ShowDistance
 if ESP.ShowDistance then
  DistanceToggle.Text = "📏 DISTANCE: ON"
  DistanceToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
 else
  DistanceToggle.Text = "📏 DISTANCE: OFF"
  DistanceToggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
 end
 updateAllHighlights()
end)

-- Перетаскивание меню
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  dragging = true
  dragStart = input.Position
  startPos = MainFrame.Position
 end
end)

UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  dragging = false
 end
end)

UserInputService.InputChanged:Connect(function(input)
 if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
  local delta = input.Position - dragStart
  MainFrame.Position = UDim2.new(
   startPos.X.Scale,


startPos.X.Offset + delta.X, 
   startPos.Y.Scale, 
   startPos.Y.Offset + delta.Y
  )
 end
end)

-- ===== ФУНКЦИИ ESP =====
local function getDistance(object)
 if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
 local hrp = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Torso") or object.PrimaryPart
 if not hrp then return nil end
 return math.floor((localPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude + 0.5)
end

local function isWithinRange(object)
 if ESP.MaxDistance == math.huge then return true end
 local distance = getDistance(object)
 return distance and distance <= ESP.MaxDistance
end

function updateAllHighlights()
 local allObjects = Workspace:GetDescendants()
 for _, obj in ipairs(allObjects) do
  local highlight = obj:FindFirstChild("WallHackHighlight")
  if highlight then
   highlight.FillColor = ESP.HighlightColor
   local isPlayerObj = false
   local isNPCObj = isNPC(obj)
   for _, player in ipairs(Players:GetPlayers()) do
    if player.Character == obj then isPlayerObj = true break end
   end
   local inRange = isWithinRange(obj)
   if ESP.Enabled and inRange then
    if isPlayerObj and ESP.PlayerEnabled then highlight.Enabled = true
    elseif isNPCObj and ESP.NPCEnabled then highlight.Enabled = true
    else highlight.Enabled = false end
   else highlight.Enabled = false end
  end

  local billboard = obj:FindFirstChild("WallHackBillboard")
  if billboard then
   local isPlayerObj = false
   local isNPCObj = isNPC(obj)
   for _, player in ipairs(Players:GetPlayers()) do
    if player.Character == obj then isPlayerObj = true break end
   end
   local distanceLabel = billboard:FindFirstChild("DistanceLabel")
   if distanceLabel then
    local distance = getDistance(obj)
    if distance and ESP.ShowDistance then
     distanceLabel.Text = distance .. "m"
     distanceLabel.Visible = true
    else distanceLabel.Visible = false end
   end
   local inRange = isWithinRange(obj)
   if ESP.Enabled and inRange then
    if isPlayerObj and ESP.PlayerEnabled then billboard.Enabled = true
    elseif isNPCObj and ESP.NPCEnabled then billboard.Enabled = true
    else billboard.Enabled = false end
   else billboard.Enabled = false end
  end
 end
end

local function applyHighlight(object, objectType, playerName)
 if not object then return end
 if object:FindFirstChild("WallHackHighlight") then return end

 local highlight = Instance.new("Highlight")
 highlight.Name = "WallHackHighlight"
 highlight.FillColor = ESP.HighlightColor
 highlight.FillTransparency = 0.5
 highlight.OutlineColor = ESP.OutlineColor
 highlight.OutlineTransparency = 0
 highlight.Enabled = ESP.Enabled and isWithinRange(object)
 highlight.Parent = object

 local billboard = Instance.new("BillboardGui")
 billboard.Name = "WallHackBillboard"
 billboard.Adornee = object
 billboard.Size = UDim2.new(0, 150, 0, 60)
 billboard.StudsOffset = Vector3.new(0, 2.5, 0)
 billboard.AlwaysOnTop = true
 billboard.MaxDistance = math.huge
 billboard.Enabled = ESP.Enabled and isWithinRange(object)
 billboard.Parent = object

 local textLabel = Instance.new("TextLabel")
 textLabel.Name = "InfoLabel"
 textLabel.Size = UDim2.new(1, 0, 0, 20)
 textLabel.BackgroundTransparency = 1
 textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
 textLabel.TextStrokeTransparency = 0
 textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
 textLabel.TextScaled = false
 textLabel.TextSize = 12
 textLabel.Font = Enum.Font.SourceSansBold
 textLabel.Text = objectType
 textLabel.Parent = billboard

 if playerName then
  local nameLabel = Instance.new("TextLabel")
  nameLabel.Name = "NameLabel"
  nameLabel.Size = UDim2.new(1, 0, 0, 20)
  nameLabel.Position = UDim2.new(0, 0, 0, 18)
  nameLabel.BackgroundTransparency = 1
  nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
  nameLabel.TextStrokeTransparency = 0
  nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  nameLabel.TextScaled = false
  nameLabel.TextSize = 12
  nameLabel.Font = Enum.Font.SourceSansBold
  nameLabel.Text =


playerName
  nameLabel.Parent = billboard
 end

 local distanceLabel = Instance.new("TextLabel")
 distanceLabel.Name = "DistanceLabel"
 distanceLabel.Size = UDim2.new(1, 0, 0, 20)
 distanceLabel.Position = UDim2.new(0, 0, 0, playerName and 36 or 18)
 distanceLabel.BackgroundTransparency = 1
 distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
 distanceLabel.TextStrokeTransparency = 0
 distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
 distanceLabel.TextScaled = false
 distanceLabel.TextSize = 12
 distanceLabel.Font = Enum.Font.SourceSansBold
 distanceLabel.Text = "0m"
 distanceLabel.Visible = ESP.ShowDistance
 distanceLabel.Parent = billboard
end

function isNPC(model)
 if model and model:IsA("Model") then
  local humanoid = model:FindFirstChild("Humanoid")
  local player = Players:GetPlayerFromCharacter(model)
  if humanoid and not player then return true end
 end
 return false
end

local function setupPlayer(player)
 if player ~= localPlayer then
  local character = player.Character
  if character then applyHighlight(character, "Player", player.Name) end
  player.CharacterAdded:Connect(function(char)
   task.wait(0.1)
   applyHighlight(char, "Player", player.Name)
  end)
 end
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

local function scanForNPCs()
 for _, object in ipairs(Workspace:GetDescendants()) do
  if isNPC(object) and not object:FindFirstChild("WallHackHighlight") then
   applyHighlight(object, "NPC", nil)
  end
 end
end
scanForNPCs()

Workspace.DescendantAdded:Connect(function(descendant)
 task.wait(0.5)
 if isNPC(descendant) and not descendant:FindFirstChild("WallHackHighlight") then
  applyHighlight(descendant, "NPC", nil)
 end
end)

-- Форматирование времени
local gameStartTime = tick()
local function formatTime(seconds)
 if seconds < 60 then
  return string.format("%ds", seconds)
 elseif seconds < 3600 then
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60
  return string.format("%dm %ds", minutes, secs)
 else
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  return string.format("%dh %dm %ds", hours, minutes, secs)
 end
end

-- Основной цикл
RunService.RenderStepped:Connect(function(deltaTime)
 if ESP.ShowFPS then updateFPS(deltaTime) end

 -- Обновление FPS в меню
 if currentFPS >= 60 then
  FpsValueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
 elseif currentFPS >= 30 then
  FpsValueLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
 else
  FpsValueLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
 end
 FpsValueLabel.Text = currentFPS .. " FPS"

 -- Обновление времени игры
 local elapsedTime = math.floor(tick() - gameStartTime)
 GameTimeLabel.Text = "⏱ Time in game: " .. formatTime(elapsedTime)

 -- Обновление количества игроков
 if tick() - fpsUpdateTime > 1 then
  PlayersCountLabel.Text = "👥 Players in game: " .. #Players:GetPlayers()
 end

 if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

 for _, player in ipairs(Players:GetPlayers()) do
  if player ~= localPlayer then
   local character = player.Character
   if character then
    local inRange = isWithinRange(character)
    local highlight = character:FindFirstChild("WallHackHighlight")
    if highlight then highlight.Enabled = ESP.Enabled and ESP.PlayerEnabled and inRange end
    local billboard = character:FindFirstChild("WallHackBillboard")
    if billboard then
     billboard.Enabled = ESP.Enabled and ESP.PlayerEnabled and inRange
     local distanceLabel = billboard:FindFirstChild("DistanceLabel")
     if distanceLabel then
      local distance = getDistance(character)
      if distance and ESP.ShowDistance then 
       distanceLabel.Text = distance .. "m"
       distanceLabel.Visible = true
      else 
       distanceLabel.Visible = false 
      end
     end
    end
   end
  end
 end

 for _, object in ipairs(Workspace:GetDescendants()) do
  if isNPC(object) then
   local inRange =


isWithinRange(object)
   local highlight = object:FindFirstChild("WallHackHighlight")
   if highlight then highlight.Enabled = ESP.Enabled and ESP.NPCEnabled and inRange end
   local billboard = object:FindFirstChild("WallHackBillboard")
   if billboard then
    billboard.Enabled = ESP.Enabled and ESP.NPCEnabled and inRange
    local distanceLabel = billboard:FindFirstChild("DistanceLabel")
    if distanceLabel then
     local distance = getDistance(object)
     if distance and ESP.ShowDistance then 
      distanceLabel.Text = distance .. "m"
      distanceLabel.Visible = true
     else 
      distanceLabel.Visible = false 
     end
    end
   end
  end
 end
end)

print("ESP Script by simsoni228 | V2.5 loaded successfully!")