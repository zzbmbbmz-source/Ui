--[[
    Components/Input.lua
    Tab:CreateInput({ Title, SubTitle?, Placeholder, Default, Callback })
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, corner, stroke = Utils.new, Utils.corner, Utils.stroke
    local addSubtitle = Utils.addSubtitle

    function MyUI:CreateInput(config)
        config = config or {}
        local hasSub = config.SubTitle ~= nil

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, hasSub and 64 or 44),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Input"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, hasSub and 10 or 0),
            Size = UDim2.new(0.4, 0, hasSub and 0 or 1, hasSub and 20 or 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        addSubtitle(Holder, config.SubTitle, 32, 300)

        local Box = new("TextBox", {
            Text = config.Default or "",
            PlaceholderText = config.Placeholder or "...",
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Background,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(180, 30),
            ClearTextOnFocus = false,
            Parent = Holder,
        }, { corner(8) })

        Box.FocusLost:Connect(function(enterPressed)
            if config.Callback then
                pcall(config.Callback, Box.Text, enterPressed)
            end
        end)

        return Holder
    end
end
