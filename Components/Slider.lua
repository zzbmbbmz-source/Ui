--[[
    Components/Slider.lua
    Tab:CreateSlider({ Title, SubTitle?, Min, Max, Step?, Default, Callback })

    Step (optional, default 1): ระยะห่างระหว่างค่าที่ลากได้ เช่น Step = 0.5 กับ Min = 0, Max = 10
    จะลากได้เฉพาะ 0, 0.5, 1, 1.5 ... 10 เท่านั้น ใส่ทศนิยมได้ (ไม่ได้ปัดเป็นจำนวนเต็มเสมอไปเหมือนเดิม)
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local addSubtitle = Utils.addSubtitle
    local UserInputService = Services.UserInputService

    function MyUI:CreateSlider(config)
        config = config or {}
        local min = config.Min or 0
        local max = config.Max or 100
        local step = config.Step or 1
        local value = config.Default or min
        local hasSub = config.SubTitle ~= nil

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, hasSub and 78 or 64),
            BackgroundColor3 = Theme.Secondary,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Stroke, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Slider"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 8),
            Size = UDim2.new(1, -80, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        addSubtitle(Holder, config.SubTitle, 28, 80)

        local ValueLabel = new("TextLabel", {
            Text = tostring(value),
            Font = Theme.FontBold,
            TextSize = 16,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -60, 0, 8),
            Size = UDim2.fromOffset(46, 20),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = Holder,
        })

        local Track = new("Frame", {
            Size = UDim2.new(1, -32, 0, 5),
            Position = UDim2.new(0, 16, 1, -20),
            BackgroundColor3 = Theme.Background,
            Parent = Holder,
        }, { corner(3) })

        local Fill = new("Frame", {
            Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            Parent = Track,
        }, { corner(3) })

        local Knob = new("Frame", {
            Size = UDim2.fromOffset(18, 18),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((value - min) / math.max(max - min, 1), 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 2,
            Parent = Track,
        }, { corner(9), stroke(Theme.Accent, 3) })

        local dragging = false

        local function setFromX(xPos)
        local rel = math.clamp((xPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * rel
              value = math.floor(raw / step + 0.5) * step
              value = math.floor(value * 1000 + 0.5) / 1000 -- กันเศษทศนิยมพลาดจาก floating point เช่น 0.799999999
        local snappedRel = (value - min) / math.max(max - min, 0.0001)
              Fill.Size = UDim2.new(snappedRel, 0, 1, 0)
             Knob.Position = UDim2.new(snappedRel, 0, 0.5, 0)
             ValueLabel.Text = tostring(value)
        if config.Callback then pcall(config.Callback, value) end
            end

        local function beginDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                tween(Knob, { Size = UDim2.fromOffset(22, 22) }, 0.1)
                setFromX(input.Position.X)
            end
        end

        Track.InputBegan:Connect(beginDrag)
        Knob.InputBegan:Connect(beginDrag)

        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                tween(Knob, { Size = UDim2.fromOffset(18, 18) }, 0.1)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end)

        return Holder
    end
end
