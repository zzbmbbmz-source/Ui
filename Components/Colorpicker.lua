--[[
    Components/Colorpicker.lua
    Tab:CreateColorpicker({ Title, Default = Color3.fromRGB(0,220,255), Palette?, Callback = function(color) end })
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke

    function MyUI:CreateColorpicker(config)
        config = config or {}
        local selected = config.Default or Theme.Accent
        local palette = config.Palette or {
            Color3.fromRGB(0, 220, 255), Color3.fromRGB(170, 80, 255), Color3.fromRGB(70, 220, 130),
            Color3.fromRGB(255, 190, 60), Color3.fromRGB(255, 70, 90), Color3.fromRGB(255, 255, 255),
        }
        local open = false
        local baseHeight = 44

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, baseHeight),
            BackgroundColor3 = Theme.Secondary,
            ClipsDescendants = true,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Color"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.new(1, -80, 0, baseHeight),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Swatch = new("TextButton", {
            Text = "",
            BackgroundColor3 = selected,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 7),
            Size = UDim2.fromOffset(30, 30),
            AutoButtonColor = false,
            Parent = Holder,
        }, { corner(8), stroke(Theme.Text, 1) })

        local PaletteFrame = new("Frame", {
            Position = UDim2.new(0, 16, 0, baseHeight),
            Size = UDim2.new(1, -32, 0, 34),
            BackgroundTransparency = 1,
            Parent = Holder,
        })
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = PaletteFrame })

        for _, color in ipairs(palette) do
            local Swab = new("TextButton", {
                Text = "",
                BackgroundColor3 = color,
                Size = UDim2.fromOffset(26, 26),
                AutoButtonColor = false,
                Parent = PaletteFrame,
            }, { corner(6), stroke(Theme.Text, 1, 0.5) })

            Swab.MouseButton1Click:Connect(function()
                selected = color
                Swatch.BackgroundColor3 = color
                if config.Callback then pcall(config.Callback, color) end
            end)
        end

        Swatch.MouseButton1Click:Connect(function()
            open = not open
            local targetHeight = open and (baseHeight + 42) or baseHeight
            tween(Holder, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.2)
        end)

        return Holder
    end
end
