--[[
    TP Behind by muqo666
    Хоткей: E
    Телепортирует за спину ближайшего игрока
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Уведомление о загрузке
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "TP Behind",
    Text = "Loaded by muqo666",
    Duration = 3
})

-- Поиск ближайшего игрока (исключая себя)
local function getNearestPlayer()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local nearest, shortestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

-- Телепортация за спину цели
local function tpBehind(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    -- Рассчитываем позицию позади цели (в 3 студиях за её спиной)
    local behindPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -3)
    myRoot.CFrame = CFrame.new(behindPos) -- можно добавить CFrame.Angles для сохранения поворота
end

-- Обработчик нажатия клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- игнорируем, если нажатие уже обработано игрой (чат и т.п.)
    if input.KeyCode == Enum.KeyCode.E then
        local target = getNearestPlayer()
        if target then
            tpBehind(target)
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "TP Behind",
                Text = "Нет цели поблизости",
                Duration = 2
            })
        end
    end
end)

-- Обновляем ссылку на персонажа после смерти/респавна
LocalPlayer.CharacterAdded:Connect(function(newChar)
    -- персонаж обновляется автоматически при обращении к LocalPlayer.Character
end)
