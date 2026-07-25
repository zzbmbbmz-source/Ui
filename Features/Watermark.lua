--[[
    Features/Watermark.lua
    Window:CreateWatermark({ Text = "MyUI", ShowFPS = true }) — ป้ายลอยมุมจอ แสดงข้อความ + FPS ได้
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, corner, stroke = Utils.new, Utils.corner, Utils.stroke
    local PlayerGui = Services.PlayerGui
    local RunService = Services.RunService

    function MyUI:CreateWatermark(config)
        config = config or {}
        local ScreenGui = PlayerGui:FindFirstChild("MyUI")
        if not ScreenGui then return end

        local Watermark = new("Frame", {
            Size = UDim2.fromOffset(0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.fromOffset(20, 76),
            BackgroundColor3 = Theme.Secondary,
            Parent = ScreenGui,
        }, { corner(6), stroke(Theme.Accent, 1) })

        new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = Watermark })

        local Label = new("TextLabel", {
            Text = config.Text or "MyUI",
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            Parent = Watermark,
        })

        if config.ShowFPS then
            local frames, elapsed = 0, 0
            RunService.RenderStepped:Connect(function(dt)
                frames += 1
                elapsed += dt
                if elapsed >= 0.5 then
                    Label.Text = string.format("%s | %d FPS", config.Text or "MyUI", math.floor(frames / elapsed))
                    frames, elapsed = 0, 0
                end
            end)
        end

        return Watermark
    end
end
