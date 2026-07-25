--[[
    Features/Notify.lua
    MyUI:Notify({ Title, Content, Type?, Duration? }) — แจ้งเตือนมุมขวาล่างของจอ
    (ไม่ผูกกับแท็บ เรียกจาก Window/MyUI ตรงๆ ก็ได้เพราะ Window สืบทอด __index จาก MyUI)
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local PlayerGui = Services.PlayerGui

    function MyUI:Notify(config)
        config = config or {}
        local ScreenGui = PlayerGui:FindFirstChild("MyUI")
        if not ScreenGui then return end

        local accentColor = config.Color or StatusColors[config.Type] or Theme.Accent

        local Notif = new("Frame", {
            Size = UDim2.fromOffset(280, 64),
            Position = UDim2.new(1, -300, 1, -84),
            BackgroundColor3 = Theme.Secondary,
            Parent = ScreenGui,
        }, { corner(10), stroke(accentColor, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Notification"),
            Font = Theme.FontBold,
            TextSize = 14,
            TextColor3 = accentColor,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 8),
            Size = UDim2.new(1, -28, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif,
        })

        new("TextLabel", {
            Text = config.Content or "",
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 30),
            Size = UDim2.new(1, -28, 0, 28),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notif,
        })

        task.delay(config.Duration or 3, function()
            tween(Notif, { Position = UDim2.new(1, 20, 1, -84) }, 0.3)
            task.wait(0.3)
            Notif:Destroy()
        end)

        return Notif
    end
end
