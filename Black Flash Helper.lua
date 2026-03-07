-- Сервисы
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- Функция TP Behind
local function tpBehind()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        warn("Персонаж не найден")
        return
    end

    local closestPlayer = nil
    local closestDistance = math.huge
    local myPos = character.HumanoidRootPart.Position

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < closestDistance then
                closestDistance = dist
                closestPlayer = plr
            end
        end
    end

    if closestPlayer then
        local targetChar = closestPlayer.Character
        local targetRoot = targetChar.HumanoidRootPart
        local lookVector = targetRoot.CFrame.LookVector
        local behindPos = targetRoot.Position - lookVector * 5
        character.HumanoidRootPart.CFrame = CFrame.new(behindPos) * CFrame.Angles(0, targetRoot.Orientation.Y * math.pi/180, 0)
        print("TP Behind to " .. closestPlayer.Name)
    else
        warn("Нет других игроков")
    end
end

-- Уведомление о загрузке
local notification = Instance.new("Hint")
notification.Parent = player.PlayerGui
notification.Text = "BFH готов"
task.wait(2)
notification:Destroy()

-- Назначение клавиши E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        tpBehind()
    end
end)

print("BFH: скрипт активирован. Нажмите E для TP Behind.")
