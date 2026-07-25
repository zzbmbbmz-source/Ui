--[[
    Components/Button.lua
    Tab:CreateButton({ Title, SubTitle?, Callback })
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local addSubtitle = Utils.addSubtitle

    function MyUI:CreateButton(config)
        config = config or {}
        local hasSub = config.SubTitle ~= nil

        local Button = new("TextButton", {
            Text = "",
            BackgroundColor3 = Theme.Secondary,
            Size = UDim2.new(1, 0, 0, hasSub and 60 or 44),
            AutoButtonColor = false,
            Parent = self.Page,
        }, { corner(8), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Button"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, hasSub and 8 or 0),
            Size = UDim2.new(1, -32, 0, hasSub and 20 or 44),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = hasSub and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            Parent = Button,
        })
        addSubtitle(Button, config.SubTitle, 30)

        Button.MouseButton1Click:Connect(function()
            tween(Button, { BackgroundColor3 = Theme.Accent }, 0.1)
            task.wait(0.1)
            tween(Button, { BackgroundColor3 = Theme.Secondary }, 0.15)
            if config.Callback then
                local ok, err = pcall(config.Callback)
                if not ok then warn("[MyUI] Button callback error: " .. tostring(err)) end
            end
        end)

        return Button
    end
end
