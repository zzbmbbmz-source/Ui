--[[
    Components/Dropdown.lua
    Tab:CreateDropdown({ Title, SubTitle?, Options, Default, Callback, AutoPlayerList?, ExcludeSelf? })
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, tween, corner, stroke = Utils.new, Utils.tween, Utils.corner, Utils.stroke
    local addSubtitle = Utils.addSubtitle
    local Players = Services.Players

    function MyUI:CreateDropdown(config)
        config = config or {}
        local options = config.Options or {}
        local selected = config.Default or options[1]
        local open = false
        local hasSub = config.SubTitle ~= nil
        local baseHeight = hasSub and 78 or 64

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, baseHeight),
            BackgroundColor3 = Theme.Secondary,
            ClipsDescendants = true,
            Parent = self.Page,
        }, { corner(10), stroke(Theme.Accent, 1) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Dropdown"),
            Font = Theme.FontBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 8),
            Size = UDim2.new(0.5, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })
        addSubtitle(Holder, config.SubTitle, 28, 200)

        -- กล่อง "ค่าที่เลือก + ลูกศร" ยึดไว้ทางขวาของแถว
        local Box = new("TextButton", {
            Text = "",
            BackgroundColor3 = Theme.Background,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -16, 0, 13),
            Size = UDim2.fromOffset(160, 38),
            AutoButtonColor = false,
            Parent = Holder,
        }, { corner(8), stroke(Theme.Accent, 1) })

        local SelectedLabel = new("TextLabel", {
            Text = string.upper(tostring(selected or "Select")),
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -34, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Box,
        })

        local Arrow = new("TextLabel", {
            Text = "V",
            Font = Theme.FontBold,
            TextSize = 12,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -26, 0, 0),
            Size = UDim2.fromOffset(20, 38),
            Parent = Box,
        })

        local OptionsFrame = new("Frame", {
            Position = UDim2.new(0, 16, 0, baseHeight),
            Size = UDim2.new(1, -32, 0, #options * 30),
            BackgroundTransparency = 1,
            Parent = Holder,
        })

        local ListLayout = new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
        ListLayout.Parent = OptionsFrame

        local function populateOptions(list)
            -- ล้างปุ่มเก่าทิ้งก่อนสร้างใหม่
            for _, child in ipairs(OptionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            for _, option in ipairs(list) do
                local OptButton = new("TextButton", {
                    Text = "  " .. tostring(option),
                    Font = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.SubText,
                    BackgroundColor3 = Theme.Background,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = OptionsFrame,
                }, { corner(6) })

                OptButton.MouseEnter:Connect(function()
                    tween(OptButton, { BackgroundTransparency = 0, TextColor3 = Theme.Accent }, 0.1)
                end)
                OptButton.MouseLeave:Connect(function()
                    tween(OptButton, { BackgroundTransparency = 1, TextColor3 = Theme.SubText }, 0.1)
                end)

                OptButton.MouseButton1Click:Connect(function()
                    selected = option
                    SelectedLabel.Text = string.upper(tostring(option))
                    if config.Callback then pcall(config.Callback, option) end

                    -- ปิด dropdown อัตโนมัติหลังเลือก
                    open = false
                    tween(Holder, { Size = UDim2.new(1, 0, 0, baseHeight) }, 0.2)
                    tween(Arrow, { Rotation = 0 }, 0.2)
                end)
            end

            OptionsFrame.Size = UDim2.new(1, -32, 0, #list * 30)
        end

        populateOptions(options)

        Box.MouseButton1Click:Connect(function()
            -- กำลังจะ "เปิด" และเปิดโหมดดึงรายชื่อผู้เล่นอัตโนมัติ -> รีเฟรช list ก่อน
            if config.AutoPlayerList and not open then
                local list = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if not (config.ExcludeSelf and plr == Players.LocalPlayer) then
                        table.insert(list, plr.Name)
                    end
                end
                options = list
                populateOptions(options)
            end

            open = not open
            local targetHeight = open and (baseHeight + #options * 30 + 8) or baseHeight
            tween(Holder, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.2)
            tween(Arrow, { Rotation = open and 180 or 0 }, 0.2)
        end)

        return Holder
    end
end
