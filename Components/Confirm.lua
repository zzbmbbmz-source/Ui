--[[
    Components/Confirm.lua
    Window:CreateConfirm({ Title, Content, ConfirmText?, CancelText?, OnConfirm?, OnCancel? })
    ป๊อปอัพถาม Yes/No ก่อนทำ action สำคัญ
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, corner, glowStroke = Utils.new, Utils.corner, Utils.glowStroke
    local PlayerGui = Services.PlayerGui

    function MyUI:CreateConfirm(config)
        config = config or {}
        local ScreenGui = PlayerGui:FindFirstChild("MyUI")
        if not ScreenGui then return end

        local Overlay = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            ZIndex = 50,
            Parent = ScreenGui,
        })

        local Box = new("Frame", {
            Size = UDim2.fromOffset(320, 160),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundColor3 = Theme.Secondary,
            ZIndex = 51,
            Parent = Overlay,
        }, { corner(12), glowStroke(2) })

        new("TextLabel", {
            Text = string.upper(config.Title or "Confirm"),
            Font = Theme.FontBold,
            TextSize = 18,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(20, 16),
            Size = UDim2.new(1, -40, 0, 24),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = Box,
        })
        new("TextLabel", {
            Text = config.Content or "",
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(20, 46),
            Size = UDim2.new(1, -40, 0, 60),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = Box,
        })

        local function makeBtn(text, color, xOffset)
            return new("TextButton", {
                Text = string.upper(text),
                Font = Theme.FontBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundColor3 = color,
                AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, xOffset, 1, -16),
                Size = UDim2.fromOffset(110, 34),
                AutoButtonColor = false,
                ZIndex = 52,
                Parent = Box,
            }, { corner(8) })
        end

        local ConfirmBtn = makeBtn(config.ConfirmText or "Confirm", StatusColors.Success, -16)
        local CancelBtn = makeBtn(config.CancelText or "Cancel", Theme.Background, -136)

        ConfirmBtn.MouseButton1Click:Connect(function()
            if config.OnConfirm then pcall(config.OnConfirm) end
            Overlay:Destroy()
        end)
        CancelBtn.MouseButton1Click:Connect(function()
            if config.OnCancel then pcall(config.OnCancel) end
            Overlay:Destroy()
        end)

        return Overlay
    end
end
