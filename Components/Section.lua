--[[
    Components/Section.lua
    Tab:CreateSection({ Title }) — หัวข้อย่อย/เส้นคั่น ใช้จัดกลุ่ม component ในแท็บ
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new = Utils.new

    function MyUI:CreateSection(config)
        config = config or {}
        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = self.Page,
        })
        new("TextLabel", {
            Text = string.upper(config.Title or "Section"),
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(4, 0),
            Size = UDim2.new(1, -8, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        new("Frame", {
            Size = UDim2.new(1, -8, 0, 1),
            Position = UDim2.fromOffset(4, 22),
            BackgroundColor3 = Theme.Stroke,
            BorderSizePixel = 0,
            Parent = Holder,
        })
        return Holder
    end
end
