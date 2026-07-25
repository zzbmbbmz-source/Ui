--[[
    Components/Toggle.lua
    Tab:CreateToggle({ Title, SubTitle?, Default, Callback })
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local addSubtitle = Utils.addSubtitle

    function MyUI:CreateToggle(config)
        config = config or {}
        local state = config.Default or false
        local hasSub = config.SubTitle ~= nil

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, hasSub and 64 or 44),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Toggle"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, hasSub and 10 or 0),
            Size = UDim2.new(1, -90, hasSub and 0 or 1, hasSub and 20 or 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        addSubtitle(Holder, config.SubTitle, 32, 90)

        local Switch = new("Frame", {
            Size = UDim2.fromOffset(52, 26),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            BackgroundColor3 = state and Theme.Accent or Theme.Background,
            Parent = Holder,
        }, { corner(13), stroke(Theme.Stroke, 1) })

        local Knob = new("Frame", {
            Size = UDim2.fromOffset(20, 20),
            Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Switch,
        }, { corner(10) })

        local ClickArea = new("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        ClickArea.MouseButton1Click:Connect(function()
            state = not state
            tween(Switch, { BackgroundColor3 = state and Theme.Accent or Theme.Background }, 0.15)
            tween(Knob, { Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) }, 0.15)
            if config.Callback then
                pcall(config.Callback, state)
            end
        end)

        return Holder
    end
end
