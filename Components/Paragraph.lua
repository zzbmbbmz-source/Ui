--[[
    Components/Paragraph.lua
    Tab:CreateParagraph({ Title, Content }) — ข้อความยาวๆ ปรับความสูงอัตโนมัติตามเนื้อหา
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, corner, stroke = Utils.new, Utils.corner, Utils.stroke

    function MyUI:CreateParagraph(config)
        config = config or {}
        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
            Parent = Holder,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = Holder })

        new("TextLabel", {
            Text = string.upper(config.Title or "Paragraph"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,
            Parent = Holder,
        })
        new("TextLabel", {
            Text = config.Content or "",
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
            Parent = Holder,
        })
        return Holder
    end
end
