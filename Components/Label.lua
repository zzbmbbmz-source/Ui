--[[
    Components/Label.lua
    Tab:CreateLabel({ Title, Content?, Type?, Color?, Align?, Glow? })
    รองรับ Type: "Info" | "Success" | "Warning" | "Error"
    ตัวอย่างจัดกึ่งกลาง + ขอบไล่สีโดดเด่น (เหมาะกับเครดิตผู้พัฒนา):
        Tab:CreateLabel({ Title = "⚡ CreateBy: YourName ⚡", Align = "Center", Glow = true })
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, corner, stroke, glowStroke = Utils.new, Utils.corner, Utils.stroke, Utils.glowStroke

    function MyUI:CreateLabel(config)
        config = config or {}
        local statusType = config.Type -- "Info" | "Success" | "Warning" | "Error" | nil
        local accentColor = config.Color or StatusColors[statusType] or Theme.Accent
        local hasContent = config.Content ~= nil and config.Content ~= ""
        local align = (config.Align == "Center") and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left

        local border = config.Glow and glowStroke(1.5) or stroke(accentColor, 1)

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, hasContent and 56 or 36),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(8), border })

        -- แถบสีด้านซ้าย ให้ดูเป็นการ์ดแจ้งเตือน (ซ่อนไว้ถ้าจัดกึ่งกลาง เพราะจะดูเบี้ยว)
        if align == Enum.TextXAlignment.Left then
            new("Frame", {
                Size = UDim2.new(0, 3, 1, -12),
                Position = UDim2.fromOffset(0, 6),
                BackgroundColor3 = accentColor,
                Parent = Holder,
            }, { corner(2) })
        end

        new("TextLabel", {
            Text = config.Title or "Label",
            Font = Theme.FontBold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, hasContent and 6 or 0),
            Size = UDim2.new(1, -32, 0, hasContent and 18 or 36),
            TextXAlignment = align,
            TextYAlignment = hasContent and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            Parent = Holder,
        })

        if hasContent then
            new("TextLabel", {
                Text = config.Content,
                Font = Theme.Font,
                TextSize = 12,
                TextColor3 = Theme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(16, 26),
                Size = UDim2.new(1, -32, 0, 24),
                TextWrapped = true,
                TextXAlignment = align,
                Parent = Holder,
            })
        end

        return Holder
    end
end
