--[[
    Components/ProgressBar.lua
    local bar = Tab:CreateProgressBar({ Title = "Loading", Max = 100, Default = 0 })
    bar:Set(50)
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke

    function MyUI:CreateProgressBar(config)
        config = config or {}
        local min = config.Min or 0
        local max = config.Max or 100
        local value = config.Default or min

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 54),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Progress"),
            Font = Theme.FontBold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 8),
            Size = UDim2.new(1, -70, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local PercentLabel = new("TextLabel", {
            Text = string.format("%d%%", math.floor((value - min) / math.max(max - min, 1) * 100)),
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -60, 0, 8),
            Size = UDim2.fromOffset(46, 18),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = Holder,
        })

        local Track = new("Frame", {
            Size = UDim2.new(1, -32, 0, 8),
            Position = UDim2.new(0, 16, 1, -18),
            BackgroundColor3 = Theme.Background,
            Parent = Holder,
        }, { corner(4) })

        local Fill = new("Frame", {
            Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            Parent = Track,
        }, { corner(4) })
        local grad = new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.Accent2),
            }),
        })
        grad.Parent = Fill

        local api = {}
        function api:Set(newValue)
            value = math.clamp(newValue, min, max)
            local rel = (value - min) / math.max(max - min, 1)
            tween(Fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.2)
            PercentLabel.Text = string.format("%d%%", math.floor(rel * 100))
        end
        return api
    end
end
