--[[
    Core/Utils.lua
    ฟังก์ชันช่วยเหลือระดับล่างที่ทุกโมดูล (Window + Components ทั้งหมด) เรียกใช้ร่วมกัน:
    สร้าง Instance แบบสั้นๆ, ทวีน, มุมเรืองแสง, การลาก ฯลฯ

    ไฟล์นี้ไม่ได้ return table ตรงๆ แต่ return "function(Theme, Services) -> table"
    เพราะ helper บางตัว (glowStroke, addCornerBrackets, addSubtitle) ต้องอ่านสีจาก Theme
    และ (makeDraggable, makeDraggableButton) ต้องใช้ UserInputService จาก Services
    ผู้เรียก (Ui-1.lua) จึงต้อง "เรียกใช้" ค่าที่ได้อีกที เช่น:
        local Utils = load("Core/Utils.lua")(Theme, Services)
]]

return function(Theme, Services)
    local TweenService = Services.TweenService
    local UserInputService = Services.UserInputService

    local Utils = {}

    -- ทวีนพร็อพเพอร์ตี้ของ Instance แบบสั้นๆ (ค่าเริ่มต้น: 0.2s, Quad, Out)
    function Utils.tween(obj, props, time, style, dir)
        local t = TweenService:Create(obj, TweenInfo.new(
            time or 0.2,
            style or Enum.EasingStyle.Quad,
            dir or Enum.EasingDirection.Out
        ), props)
        t:Play()
        return t
    end

    -- สร้าง Instance พร้อมตั้งค่า property และใส่ children ในคำสั่งเดียว
    -- new("Frame", { Size = ... }, { corner(8), stroke() })
    function Utils.new(class, props, children)
        local inst = Instance.new(class)
        for prop, value in pairs(props or {}) do
            inst[prop] = value
        end
        for _, child in ipairs(children or {}) do
            child.Parent = inst
        end
        return inst
    end

    function Utils.corner(radius)
        return Utils.new("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
    end

    function Utils.stroke(color, thickness, transparency)
        return Utils.new("UIStroke", {
            Color = color or Theme.Stroke,
            Thickness = thickness or 1,
            Transparency = transparency or 0,
        })
    end

    -- ขอบไล่สี cyan -> purple แบบหมุนวนตลอดเวลา ใช้กับกรอบหน้าต่างหลัก/ปุ่มลอย/ป๊อปอัพ
    function Utils.glowStroke(thickness)
        local strokeInst = Utils.new("UIStroke", {
            Thickness = thickness or 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })

        local gradient = Utils.new("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Theme.Accent),
                ColorSequenceKeypoint.new(0.5,  Theme.Accent2),
                ColorSequenceKeypoint.new(1,    Theme.Accent),
            }),
        })
        gradient.Parent = strokeInst

        task.spawn(function()
            while strokeInst.Parent do
                gradient.Rotation = (gradient.Rotation + 1.5) % 360
                task.wait(0.03)
            end
        end)

        return strokeInst
    end

    -- มุมกรอบสไตล์ HUD ตัว L ทั้ง 4 มุมของเฟรม (ใช้ตกแต่งกรอบหน้าต่างหลัก)
    function Utils.addCornerBrackets(parent, length, thickness)
        length = length or 18
        thickness = thickness or 2
        local corners = {
            { anchor = Vector2.new(0, 0), pos = UDim2.new(0, 8, 0, 8),   flipH = false, flipV = false },
            { anchor = Vector2.new(1, 0), pos = UDim2.new(1, -8, 0, 8),  flipH = true,  flipV = false },
            { anchor = Vector2.new(0, 1), pos = UDim2.new(0, 8, 1, -8),  flipH = false, flipV = true  },
            { anchor = Vector2.new(1, 1), pos = UDim2.new(1, -8, 1, -8), flipH = true,  flipV = true  },
        }
        for _, c in ipairs(corners) do
            local Holder = Utils.new("Frame", {
                Size = UDim2.fromOffset(length, length),
                AnchorPoint = c.anchor,
                Position = c.pos,
                BackgroundTransparency = 1,
                ZIndex = 5,
                Parent = parent,
            })
            Utils.new("Frame", {
                Size = UDim2.new(1, 0, 0, thickness),
                Position = c.flipV and UDim2.new(0, 0, 1, -thickness) or UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = Holder,
            })
            Utils.new("Frame", {
                Size = UDim2.new(0, thickness, 1, 0),
                Position = c.flipH and UDim2.new(1, -thickness, 0, 0) or UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = Holder,
            })
        end
    end

    -- แถบขีดเฉียงตกแต่งซ้าย/ขวาของหัวข้อ (Header ของหน้า Tab)
    function Utils.addStripeDecor(parent, alignment)
        local Holder = Utils.new("Frame", {
            Size = UDim2.fromOffset(64, 16),
            AnchorPoint = Vector2.new(alignment == "left" and 0 or 1, 0.5),
            Position = alignment == "left" and UDim2.new(0, 16, 0.5, 0) or UDim2.new(1, -16, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = parent,
        })
        for i = 1, 7 do
            Utils.new("Frame", {
                Size = UDim2.fromOffset(2, 12),
                Position = UDim2.fromOffset((i - 1) * 8, 2),
                Rotation = 20,
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.15 + (i * 0.1),
                BorderSizePixel = 0,
                Parent = Holder,
            })
        end
    end

    -- ลากปุ่มลอยได้อิสระ + แยกแยะ "คลิกเฉยๆ" ออกจาก "ลาก"
    -- ใช้กับปุ่ม hamburger/close ลอยมุมจอที่ต้องลากได้ด้วยและกดเปิด/ปิดได้ด้วย
    function Utils.makeDraggableButton(button, onClick)
        local dragging = false
        local moved = false
        local dragStart, startPos

        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = button.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if delta.Magnitude > 4 then
                    moved = true
                end
                button.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                if not moved and onClick then
                    onClick()
                end
            end
        end)
    end

    -- ลากทั้งหน้าต่างด้วยการจับที่ TopBar
    function Utils.makeDraggable(topBar, frame)
        local dragging, dragStart, startPos

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- เปลี่ยนสีไอคอนแท็บตอนสลับแท็บ (รองรับทั้ง ImageLabel และ Frame สี่เหลี่ยมเล็ก)
    function Utils.setIconColor(icon, color, transparency)
        if icon:IsA("ImageLabel") then
            Utils.tween(icon, { ImageColor3 = color, ImageTransparency = transparency or 0 }, 0.15)
        else
            Utils.tween(icon, { BackgroundColor3 = color }, 0.15)
        end
    end

    -- ป้าย subtitle เล็กๆ ใต้หัวข้อ component — ใช้ซ้ำแทบทุก component ใน Components/
    function Utils.addSubtitle(parent, text, yOffset, widthOffset)
        if not text or text == "" then return end
        Utils.new("TextLabel", {
            Text = text,
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, yOffset),
            Size = UDim2.new(1, -(widthOffset or 32), 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = parent,
        })
    end

    return Utils
end
