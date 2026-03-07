-- Скрипт для Xeno: телепорт за спину цели с поворотом лица к ней
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Функция для получения ближайшего игрока (кроме себя)
local function getNearestPlayer()
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    myPos = myPos.Position
    
    local nearest = nil
    local minDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - myPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- Функция телепортации за спину цели
local function tpBehind(targetPlayer)
    if not targetPlayer then return end
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    -- Направление взгляда цели
    local lookVector = targetRoot.CFrame.LookVector
    -- Расстояние позади цели (можешь изменить)
    local distance = 5
    -- Позиция позади цели
    local behindPos = targetRoot.Position - lookVector * distance
    
    -- Устанавливаем персонажа на behindPos и поворачиваем лицом к цели
    local newCFrame = CFrame.lookAt(behindPos, targetRoot.Position)
    myRoot.CFrame = newCFrame
end

-- Привязываем телепорт к нажатию клавиши "T"
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        local target = getNearestPlayer()
        if target then
            tpBehind(target)
        else
            print("Нет цели поблизости")
        end
    end
end)

print("Скрипт загружен. Нажми T для телепортации за спину ближайшего игрока.")
