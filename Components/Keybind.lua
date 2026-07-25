--[[
    Components/Keybind.lua
    Tab:CreateKeybind({ Title, Default = Enum.KeyCode.RightControl, Callback = function(key) end })
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local UserInputService = Services.UserInputService

    function MyUI:CreateKeybind(config)
        config = config or {}
        local currentKey = config.Default or Enum.KeyCode.Unknown
        local listening = false

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Keybind"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.new(1, -120, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local KeyButton = new("TextButton", {
            Text = currentKey.Name,
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent,
            BackgroundColor3 = Theme.Background,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(90, 30),
            AutoButtonColor = false,
            Parent = Holder,
        }, { corner(8), stroke(Theme.Accent, 1) })

        KeyButton.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            KeyButton.Text = "..."
            tween(KeyButton, { BackgroundColor3 = Theme.Accent }, 0.1)
        end)

        UserInputService.InputBegan:Connect(function(input)
            if not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                KeyButton.Text = currentKey.Name
                listening = false
                tween(KeyButton, { BackgroundColor3 = Theme.Background }, 0.1)
                if config.Callback then pcall(config.Callback, currentKey) end
            end
        end)

        return Holder
    end
end
