--[[
    Components/LogEntry.lua
    Tab:CreateLogEntry({ Title, Content, CopyText?, Callback? }) -> Holder

    รายการข้อความแบบ list ที่เรียกซ้ำได้ไม่จำกัด (แต่ละครั้งได้กล่องใหม่ 1 อัน ต่อท้ายในแท็บ)
    ถ้าใส่ CopyText ไว้ จะคัดลอกข้อความนั้นลงคลิปบอร์ดอัตโนมัติเมื่อคลิกทั้งกล่อง (ต้องมี setclipboard
    ในสภาพแวดล้อมที่ใช้ ถ้าไม่มีจะข้ามการคัดลอกไปเฉยๆ ไม่ error) แล้วโชว์ข้อความยืนยันชั่วคราว 1 วิ
    Callback (optional) ถูกเรียกทุกครั้งที่คลิก เผื่ออยากทำอย่างอื่นเพิ่มเติมนอกจากคัดลอก
]]

return function(MyUI, Theme, StatusColors, Utils)
    local new, corner, stroke, tween = Utils.new, Utils.corner, Utils.stroke, Utils.tween

    function MyUI:CreateLogEntry(config)
        config = config or {}

        local Holder = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
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
            Text = string.upper(config.Title or "Log"),
            Font = Theme.FontBold,
            TextSize = 14,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 1,
            Parent = Holder,
        })

        local ContentLabel = new("TextLabel", {
            Text = config.Content or "",
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
            Parent = Holder,
        })

        if config.CopyText then
            new("TextLabel", {
                Text = "👉 คลิกเพื่อคัดลอก",
                Font = Theme.FontBold,
                TextSize = 11,
                TextColor3 = Theme.Accent2,
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 3,
                Parent = Holder,
            })
        end

        Holder.MouseEnter:Connect(function()
            tween(Holder, { BackgroundColor3 = Theme.Background }, 0.1)
        end)
        Holder.MouseLeave:Connect(function()
            tween(Holder, { BackgroundColor3 = Theme.Secondary }, 0.1)
        end)

        Holder.MouseButton1Click:Connect(function()
            if config.CopyText and setclipboard then
                pcall(setclipboard, config.CopyText)
                local original = ContentLabel.Text
                ContentLabel.Text = "✅ คัดลอกลงคลิปบอร์ดแล้ว!"
                task.delay(1, function()
                    if ContentLabel.Parent then
                        ContentLabel.Text = original
                    end
                end)
            end
            if config.Callback then
                pcall(config.Callback)
            end
        end)

        return Holder
    end
end
