--[[
    Core/Window.lua
    โครงหลักของ MyUI: หน้าต่าง (Window), แถบแท็บด้านซ้าย (CreateTab), ปุ่มลอยเปิด/ปิด,
    การปรับขนาด UI ทั้งหมด (SetScale) และการสลับธีมสี (SetTheme)

    ไฟล์นี้ return "function(MyUI, Theme, StatusColors, Utils, Services)" แล้วแนบเมธอด
    MyUI:CreateWindow / MyUI:SetScale / MyUI:CreateTab / MyUI:SetTheme เข้ากับ MyUI ที่ส่งมา
    (ดูวิธีประกอบโมดูลทั้งหมดใน Ui-1.lua)
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local PlayerGui = Services.PlayerGui

    local new, tween = Utils.new, Utils.tween
    local corner, stroke, glowStroke = Utils.corner, Utils.stroke, Utils.glowStroke
    local addCornerBrackets, addStripeDecor = Utils.addCornerBrackets, Utils.addStripeDecor
    local makeDraggable, makeDraggableButton = Utils.makeDraggable, Utils.makeDraggableButton
    local setIconColor = Utils.setIconColor

    -- ล้าง ScreenGui เก่าชื่อ "MyUI" ทิ้ง (กันเปิดซ้อนกันถ้ารันสคริปต์ซ้ำ) แล้วสร้างใหม่
    --
    -- DisplayOrder = 2147483647 (ค่าสูงสุดของ Int32 ที่ Roblox รองรับ) ตั้งไว้เพื่อบังคับให้
    -- ScreenGui ของเราเรนเดอร์ทับ ScreenGui อื่นทุกตัวใน PlayerGui เสมอ — ถ้าไม่ตั้งค่านี้
    -- DisplayOrder จะเป็น 0 (ค่า default) เท่ากับ GUI ส่วนใหญ่ของเกม ทำให้ popup/หน้าต่างอื่นๆ
    -- ของเกม (เช่น gacha, event popup) ที่ตั้ง DisplayOrder ไว้สูงกว่า สามารถมาแสดงทับ MyUI ได้
    local function getScreenGui()
        local existing = PlayerGui:FindFirstChild("MyUI")
        if existing then existing:Destroy() end
        return new("ScreenGui", {
            Name = "MyUI",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 2147483647,
            Parent = PlayerGui,
        })
    end

    -- ===== Window =====
    -- MyUI:CreateWindow({ Title, SubTitle, Size, Scale, PresetTabs })
    function MyUI:CreateWindow(config)
        config = config or {}
        local title = config.Title or "MyUI"
        local subTitle = config.SubTitle or ""
        local size = config.Size or UDim2.fromOffset(760, 460)
        -- Scale = ตัวคูณขนาด UI ทั้งหมด ค่า default คือ 0.7 (เหมาะกับจอมือถือ) เช่น
        -- 0.5 = ครึ่งหนึ่งของขนาดเดิม, 1 = ขนาดเต็ม, ไม่ใส่ Scale ใน config จะได้ 0.7 อัตโนมัติ
        local targetScale = config.Scale or 0.7

        local ScreenGui = getScreenGui()

        local Main = new("Frame", {
            Name = "Main",
            Size = size,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Theme.Background,
            Parent = ScreenGui,
        }, { corner(12), glowStroke(2) })

        addCornerBrackets(Main, 20, 2)

        -- ขับเคลื่อนอนิเมชันย่อ/ขยายตอนเปิด-ปิด เริ่มต้นที่ targetScale เลย ทำให้ทุกอย่างในหน้าต่าง
        -- ย่อ/ขยายตามอัตราส่วนเดียวกันทันที ตอนปิดจะ tween ลงไปที่ 0 ตอนเปิดจะ tween กลับไปที่ targetScale
        local WindowScale = new("UIScale", { Scale = targetScale, Parent = Main })

        -- ===== Top bar =====
        local TopBar = new("Frame", {
            Name = "TopBar",
            Size = UDim2.new(1, 0, 0, 74),
            BackgroundColor3 = Theme.Secondary,
            Parent = Main,
        }, { corner(12) })

        new("Frame", { -- ปิดมุมโค้งด้านล่างของ TopBar ให้โค้งแค่ด้านบน
            Size = UDim2.new(1, 0, 0, 12),
            Position = UDim2.new(0, 0, 1, -12),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Parent = TopBar,
        })

        new("TextLabel", {
            Text = string.upper(title),
            Font = Theme.FontBlack,
            TextSize = 26,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(24, 14),
            Size = UDim2.new(1, -120, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TopBar,
        })

        new("TextLabel", {
            Text = subTitle,
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(25, 42),
            Size = UDim2.new(1, -120, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TopBar,
        })

        -- ปุ่มปิดรูปเพชร (สี่เหลี่ยมหมุน 45 องศา) มุมขวาบน
        local CloseBtn = new("TextButton", {
            Text = "",
            Rotation = 45,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -26, 0, 30),
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = Theme.Background,
            AutoButtonColor = false,
            Parent = TopBar,
        }, { corner(6), stroke(Theme.Accent, 1) })

        new("Frame", {
            Size = UDim2.new(0.6, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = -45,
            BackgroundColor3 = Theme.Accent,
            Parent = CloseBtn,
        })

        makeDraggable(TopBar, Main)

        -- ===== ปุ่มลอย hamburger/close (ลากได้อิสระ เปิด/ปิดหน้าต่างได้) =====
        -- สร้างจาก Frame ธรรมดาแทนตัวอักษร เพราะฟอนต์ Gotham ไม่มีสัญลักษณ์บางตัว
        -- (จะเรนเดอร์เป็นกล่องว่างๆ "tofu" ถ้าใช้ glyph)
        local ToggleButton = new("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.fromOffset(44, 44),
            Position = UDim2.fromOffset(20, 20),
            BackgroundColor3 = Theme.Secondary,
            Text = "",
            AutoButtonColor = false,
            Parent = ScreenGui,
        }, { corner(22), glowStroke(2) })

        local HamburgerHolder = new("Frame", {
            Size = UDim2.fromOffset(20, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ToggleButton,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            Parent = HamburgerHolder,
        })
        for i = 1, 3 do
            new("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = Theme.Accent,
                LayoutOrder = i,
                Parent = HamburgerHolder,
            }, { corner(1) })
        end

        local CloseHolder = new("Frame", {
            Size = UDim2.fromOffset(18, 18),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Visible = true,
            Parent = ToggleButton,
        })
        new("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 45,
            BackgroundColor3 = Theme.Accent,
            Parent = CloseHolder,
        }, { corner(1) })
        new("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = -45,
            BackgroundColor3 = Theme.Accent,
            Parent = CloseHolder,
        }, { corner(1) })

        local isOpen = true

        local function setOpen(open)
            isOpen = open
            if open then
                Main.Visible = true
                CloseHolder.Visible = true
                HamburgerHolder.Visible = false
                tween(WindowScale, { Scale = targetScale }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                CloseHolder.Visible = false
                HamburgerHolder.Visible = true
                tween(WindowScale, { Scale = 0 }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.25, function()
                    if not isOpen then
                        Main.Visible = false
                    end
                end)
            end
        end

        CloseBtn.MouseButton1Click:Connect(function()
            setOpen(false)
        end)

        makeDraggableButton(ToggleButton, function()
            setOpen(not isOpen)
        end)

        -- ===== Sidebar (รายการแท็บ) =====
        local TabList = new("Frame", {
            Name = "TabList",
            Size = UDim2.new(0, 190, 1, -90),
            Position = UDim2.new(0, 12, 0, 82),
            BackgroundColor3 = Theme.Secondary,
            Parent = Main,
        }, { corner(10) })

        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabList,
        })

        new("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = TabList,
        })

        -- ===== Content area =====
        local PageHolder = new("Frame", {
            Name = "PageHolder",
            Size = UDim2.new(1, -226, 1, -90),
            Position = UDim2.new(0, 214, 0, 82),
            BackgroundTransparency = 1,
            Parent = Main,
        })

        local Header = new("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = Theme.Secondary,
            Parent = PageHolder,
        }, { corner(8) })

        local HeaderLabel = new("TextLabel", {
            Text = "",
            Font = Theme.FontBlack,
            TextSize = 22,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = Header,
        })

        addStripeDecor(Header, "left")
        addStripeDecor(Header, "right")

        local PagesContainer = new("Frame", {
            Name = "PagesContainer",
            Size = UDim2.new(1, 0, 1, -54),
            Position = UDim2.new(0, 0, 0, 54),
            BackgroundTransparency = 1,
            Parent = PageHolder,
        })

        local Window = setmetatable({
            Main = Main,
            TabList = TabList,
            PagesContainer = PagesContainer,
            HeaderLabel = HeaderLabel,
            Tabs = {},
            _firstTab = true,
            _windowScale = WindowScale,
            _targetScale = targetScale,
            _isOpen = true,
        }, { __index = MyUI })

        

    function MyUI:EnableInfoTab()
        local TabInfo = self:CreateTab("Info")

        TabInfo:CreateInfoPanel({
            -- Executor = "Infinite Yield FE",   -- ใส่เองได้ถ้าอยากบังคับข้อความแทนการ auto-detect
            -- ExecutorVersion = "v6.4.2",
               FetchJoinDate = true,             -- false = ปิดการยิง HTTP ไป Roblox API เพื่อดึงวันสมัคร
        })

        TabInfo:CreateLabel({
            Title = "⚡ CreateBy: ---->3A1TR<---- ⚡",
            Align = "Center",
            Glow = true,
        })
    end

    function MyUI:EnablePlayerTab()
        local TabPlayer = self:CreateTab("PLAYER")

        TabPlayer:CreateSection({ Title = "Movement" })

        TabPlayer:CreateSlider({
            Title = "WalkSpeed", SubTitle = "ปรับความเร็วในการเดินพื้นฐาน",
            Min = 16, Max = 250, Default = 16, 
            Callback = function(v)
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
                end
            end
        })

        TabPlayer:CreateToggle({
            Title = "Infinite Jump", SubTitle = "กระโดดได้เรื่อยๆ บนอากาศ",
            Default = false,
            Callback = function(v)
                _G.InfJump = v
                self:Notify({
                    Title = "Infinite Jump",
                    Content = v and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว",
                    Type = v and "Success" or "Warning",
                    Duration = 2,
                })
                if not _G.InfJumpConnected then
                    _G.InfJumpConnected = true
                    game:GetService("UserInputService").JumpRequest:Connect(function()
                        if _G.InfJump and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                            game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                        end
                    end)
                end
            end
        })

        TabPlayer:CreateToggle({
            Title = "Noclip", SubTitle = "เดินทะลุกำแพง/สิ่งกีดขวาง",
            Default = false,
            Callback = function(v)
                _G.Noclip = v
                self:Notify({
                    Title = "Noclip",
                    Content = v and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว",
                    Type = v and "Success" or "Warning",
                    Duration = 2,
                })
                if not _G.NoclipConnected then
                    _G.NoclipConnected = true
                    game:GetService("RunService").Stepped:Connect(function()
                        if _G.Noclip and game.Players.LocalPlayer.Character then
                            for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end)
                end
            end
        })

        TabPlayer:CreateSection({ Title = "Visual" })

        TabPlayer:CreateToggle({
            Title = "Player ESP", SubTitle = "มองเห็นผู้เล่นทะลุกำแพง (Highlight)",
            Default = false,
            Callback = function(v)
                _G.EspActive = v
                self:Notify({
                    Title = "Player ESP",
                    Content = v and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว",
                    Type = v and "Success" or "Warning",
                    Duration = 2,
                })
                local function applyESP(player)
                    if player ~= game.Players.LocalPlayer and player.Character then
                        if _G.EspActive then
                            local hl = player.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", player.Character)
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        else
                            local hl = player.Character:FindFirstChildOfClass("Highlight")
                            if hl then hl:Destroy() end
                        end
                    end
                end
                for _, p in pairs(game.Players:GetPlayers()) do applyESP(p) end
            end
        })


        TabPlayer:CreateSection({ Title = "Interaction" })

        do
            -- เก็บ HoldDuration เดิมของแต่ละ ProximityPrompt ไว้ (คีย์ด้วยตัว instance เอง)
            -- เพื่อคืนค่ากลับให้ถูกต้องตอนปิดใช้งาน แทนที่จะ hardcode เป็น 0.5 เพราะแต่ละเกม
            -- อาจตั้งค่าเริ่มต้นไม่เท่ากัน
            _G.OriginalHoldDurations = _G.OriginalHoldDurations or {}

            local function applyInstantPrompt(obj)
                if not obj:IsA("ProximityPrompt") then return end
                if _G.InstantPrompt then
                    if _G.OriginalHoldDurations[obj] == nil then
                        _G.OriginalHoldDurations[obj] = obj.HoldDuration
                    end
                    obj.HoldDuration = 0
                elseif _G.OriginalHoldDurations[obj] ~= nil then
                    obj.HoldDuration = _G.OriginalHoldDurations[obj]
                    _G.OriginalHoldDurations[obj] = nil
                end
            end

            TabPlayer:CreateToggle({
                Title = "Instant ProximityPrompt", SubTitle = "กดปุ่มโต้ตอบ (Interact) แล้วติดทันที ไม่ต้องกดค้าง",
                Default = false,
                Callback = function(v)
                    _G.InstantPrompt = v
                    self:Notify({
                        Title = "Instant ProximityPrompt",
                        Content = v and "เปิดใช้งานแล้ว" or "คืนค่าเดิมแล้ว",
                        Type = v and "Success" or "Info",
                        Duration = 2,
                    })

                    -- ใช้กับ ProximityPrompt ที่มีอยู่แล้วในโลกเกมตอนนี้ทันที
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            applyInstantPrompt(obj)
                        end
                    end)

                    -- ดัก ProximityPrompt ใหม่ที่ถูกสร้างเพิ่มทีหลัง (เช่น NPC/ของเก็บที่ spawn
                    -- ใหม่ระหว่างเล่น) เชื่อมต่อครั้งเดียวพอ ใช้ flag _G.InstantPrompt คุมพฤติกรรม
                    if not _G.InstantPromptConnected then
                        _G.InstantPromptConnected = true
                        workspace.DescendantAdded:Connect(function(obj)
                            task.defer(applyInstantPrompt, obj)
                        end)
                    end
                end
            })
        end

        TabPlayer:CreateSection({ Title = "World" })

        TabPlayer:CreateParagraph({
            Title = "หมายเหตุ",
            Content = "FullBright จะบันทึกค่าแสงเดิมไว้อัตโนมัติ และคืนค่ากลับให้เมื่อปิดใช้งาน",
        })

        local Lighting = game:GetService("Lighting")

        local function ResetLighting()
            if _G.DefaultLighting then
                Lighting.Brightness = _G.DefaultLighting.Brightness
                Lighting.ClockTime = _G.DefaultLighting.ClockTime
                Lighting.FogEnd = _G.DefaultLighting.FogEnd
                Lighting.GlobalShadows = _G.DefaultLighting.GlobalShadows
                Lighting.Ambient = _G.DefaultLighting.Ambient
                Lighting.OutdoorAmbient = _G.DefaultLighting.OutdoorAmbient
            end
        end

        TabPlayer:CreateToggle({
            Title = "FullBright", SubTitle = "ปรับแสงสว่างเต็มที่ตัดหมอกและเงา",
            Default = false,
            Callback = function(v)
                _G.FullBright = v
                self:Notify({
                    Title = "FullBright",
                    Content = v and "เปิดใช้งานแล้ว" or "คืนค่าแสงเดิมแล้ว",
                    Type = v and "Success" or "Info",
                    Duration = 2,
                })

                if _G.FullBright then
                    if not _G.DefaultLighting then
                        _G.DefaultLighting = {
                            Brightness = Lighting.Brightness,
                            ClockTime = Lighting.ClockTime,
                            FogEnd = Lighting.FogEnd,
                            GlobalShadows = Lighting.GlobalShadows,
                            Ambient = Lighting.Ambient,
                            OutdoorAmbient = Lighting.OutdoorAmbient
                        }
                    end

                    if not _G.FullBrightConnected then
                        _G.FullBrightConnected = true
                        game:GetService("RunService").RenderStepped:Connect(function()
                            if _G.FullBright then
                                Lighting.Brightness = 2
                                Lighting.ClockTime = 14
                                Lighting.FogEnd = 999999
                                Lighting.GlobalShadows = false
                                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                            end
                        end)
                    end
                else
                    ResetLighting()
                end
            end
        })


        TabPlayer:CreateSection({ Title = "Teleport" })

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local SelectedPlayerName = nil

        TabPlayer:CreateDropdown({
            Title = "เลือกผู้เล่น",
            SubTitle = "กดเพื่อดูรายชื่อล่าสุดในเซิร์ฟเวอร์",
            Options = {},
            AutoPlayerList = true,
            ExcludeSelf = true,
            Callback = function(name)
                SelectedPlayerName = name
            end
        })

        TabPlayer:CreateToggle({
            Title = "Teleport to Player",
            SubTitle = "วาปไปหาผู้เล่นที่เลือกไว้ (ติดตามต่อเนื่องจนกว่าจะปิด)",
            Default = false,
            Callback = function(v)
                _G.TeleportFollow = v
                if v then
                    task.spawn(function()
                        while _G.TeleportFollow do
                            local ok = pcall(function()
                                local targetPlayer = SelectedPlayerName and Players:FindFirstChild(SelectedPlayerName)
                                local char = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character

                                if char and char:FindFirstChild("HumanoidRootPart")
                                    and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                    char.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                end
                            end)
                            if not ok then
                                _G.TeleportFollow = false
                            end
                            task.wait(0.5)
                        end
                    end)
                end
            end
        })
    end

    function MyUI:EnableLoopTab()
        local TabLoop = self:CreateTab("Loop")

        -- แต่ละ "ชุด loop" มี Script/ความเร็ว/Toggle เป็นของตัวเอง แยกอิสระจากชุดอื่น รันพร้อมกันได้หลายชุด
        local loopCount = 0

        local function createLoopEntry()
            loopCount += 1
            local index = loopCount

            TabLoop:CreateSection({ Title = "Loop #" .. index })

            TabLoop:CreateInput({
                Title = "Script",
                SubTitle = "ใส่โค้ดที่จะลูป (ชุดที่ " .. index .. ")",
                Placeholder = "print('hello')",
                Default = "",
                Callback = function(text, enterPressed)
                    self:SetState("LoopScript_" .. index, text)
                end
            })

            TabLoop:CreateSlider({
                Title = "ความเร็ว (วินาที)",
                SubTitle = "ระยะเวลาหน่วงระหว่างการลูปแต่ละรอบ (ชุดที่ " .. index .. ")",
                Min = 0.1, Max = 20, Step = 0.1, Default = 0.5,
                Callback = function(value)
                    self:SetState("LoopSpeed_" .. index, value)
                end
            })

            TabLoop:CreateToggle({
                Title = "เริ่มลูป / หยุดลูป",
                SubTitle = "เปิดเพื่อรันโค้ดชุดที่ " .. index .. " ซ้ำ ๆ",
                Default = false,
                Callback = function(v)
                    self:SetState("LoopRunning_" .. index, v)
                    if v then
                        task.spawn(function()
                            while self:GetState("LoopRunning_" .. index) do
                                local ok, err = pcall(function()
                                    local f = loadstring(self:GetState("LoopScript_" .. index) or "")
                                    if f then f() end
                                end)
                                if not ok then
                                    warn(("Loop #%d error:"):format(index), err)
                                end
                                task.wait(self:GetState("LoopSpeed_" .. index) or 1)
                            end
                        end)
                    end
                end
            })
        end

        createLoopEntry() -- สร้างชุดแรกให้อัตโนมัติ

        TabLoop:CreateSection({ Title = "จัดการ Loop" })

        TabLoop:CreateButton({
            Title = "+ เพิ่ม Loop ใหม่",
            SubTitle = "เพิ่มชุด Script/ความเร็ว/Toggle ใหม่ต่อท้าย รันพร้อมกับชุดเดิมได้พร้อมกันไม่จำกัดจำนวน",
            Callback = function()
                createLoopEntry()
            end
        })
    end

function MyUI:EnableRemoteSpy()
    local Tabrspy = self:CreateTab("RSPY") 

    local isRspyEnabled = false
    local maxLogs = 15 
    local activeLogInstances = {} 
    local logCounter = 0 

    local function clearAllLogs()
        for _, logUi in ipairs(activeLogInstances) do
            if logUi and logUi.Destroy then pcall(function() logUi:Destroy() end) end
        end
        activeLogInstances = {}
        logCounter = 0
    end

    local function formatArgs(args)
        if type(args) ~= "table" then return tostring(args) end
        local str = "{"
        for k, v in pairs(args) do
            str = str .. string.format("[%s] = %s, ", tostring(k), tostring(v))
        end
        if #str > 1 then str = string.sub(str, 1, #str - 2) end
        return str .. "}"
    end

    -- 1. ส่วนควบคุมคอนโทรล
    local SectionControl = Tabrspy:CreateSection({ Title = "Remote Spy Control" })
    if SectionControl and SectionControl:IsA("GuiObject") then SectionControl.LayoutOrder = -999999 end

    local ToggleCtrl = Tabrspy:CreateToggle({
        Title = "Enable Remote Spy",
        SubTitle = "เปิดเพื่อดักจับและสแกนข้อมูลจาก Remote ในเกม",
        Default = false,
        Callback = function(value)
            isRspyEnabled = value
            if not isRspyEnabled then clearAllLogs() end
        end
    })
    if ToggleCtrl and ToggleCtrl:IsA("GuiObject") then ToggleCtrl.LayoutOrder = -999998 end

    local ButtonCtrl = Tabrspy:CreateButton({
        Title = "Clear Logs",
        SubTitle = "ล้างประวัติการดักจับทั้งหมดบนหน้าจอ",
        Callback = function() clearAllLogs() end
    })
    if ButtonCtrl and ButtonCtrl:IsA("GuiObject") then ButtonCtrl.LayoutOrder = -999997 end

    local SectionLogs = Tabrspy:CreateSection({ Title = "Remote Logs" })
    if SectionLogs and SectionLogs:IsA("GuiObject") then SectionLogs.LayoutOrder = -999996 end

    -- 2. ฟังก์ชันวาดกล่องข้อความ Log
    local function createRemoteLogUI(remoteType, path, argsText, scriptName)
        local timestamp = os.date("%X")
        
        local formattedCopyText = string.format([[
-- [%s] GALAXY HUB - Premium RSPY Script
-- Origin Script: %s

local Remote = %s
local RawArgs = %s

local FinalArgs = {}
for k, v in pairs(RawArgs) do
    FinalArgs[k] = v
end

if Remote then
    local method = "%s" == "Event" and "FireServer" or "InvokeServer"
    local success, err = pcall(function()
        local tbl = {}
        local maxIndex = 0
        for k, v in pairs(FinalArgs) do
            if type(k) == "number" and k > maxIndex then maxIndex = k end
            tbl[k] = v
        end
        local packed = {}
        for i = 1, maxIndex do packed[i] = tbl[i] end
        Remote[method](Remote, table.unpack(packed, 1, maxIndex))
    end)
    if not success then warn("ยิงรีโมทไม่สำเร็จ:", tostring(err)) end
end
]], timestamp, scriptName, path, argsText, remoteType)

        local displayContent = string.format("Path: %s\nArgs: %s\nScript: %s", path, argsText, scriptName)

        local LogEntry = Tabrspy:CreateLogEntry({
            Title = string.format("[%s] ⚡ [%s] %s", timestamp, remoteType, string.match(path, "[^%.]+$") or "Remote"),
            Content = displayContent,
            CopyText = formattedCopyText
        })

        if LogEntry then
            logCounter = logCounter + 1
            if type(LogEntry) == "table" and LogEntry.LayoutOrder then
                LogEntry.LayoutOrder = -999996 + logCounter
            elseif LogEntry:IsA("GuiObject") then
                LogEntry.LayoutOrder = -999996 + logCounter
            end
        end

        table.insert(activeLogInstances, LogEntry)

        if #activeLogInstances > maxLogs then
            local oldestLog = table.remove(activeLogInstances, 1)
            if oldestLog and oldestLog.Destroy then pcall(function() oldestLog:Destroy() end) end
        end
    end

    -- 3. Core Logic Hooking
    --
    -- ⚠️ hookmetamethod / getnamecallmethod เป็นฟังก์ชันเฉพาะของ executor ไม่ใช่ทุกตัวจะมี
    -- (โดยเฉพาะ executor บนมือถือบางตัว) เดิมโค้ดส่วนนี้เรียก hookmetamethod ตรงๆ โดยไม่เช็คก่อน
    -- ถ้า executor ไม่มีฟังก์ชันนี้ จะ error ทันทีตอนเปิด UI (EnableRemoteSpy ถูกเรียกอัตโนมัติ
    -- ท้าย CreateWindow) ทำให้ "ทั้งหน้าต่าง MyUI ไม่ขึ้นเลย" ไม่ใช่แค่แท็บ RSPY ใช้ไม่ได้
    -- จึงเช็ค hookmetamethod ก่อนใช้งานเสมอ และห่อ getnamecallmethod() ด้วย pcall เพราะฟังก์ชันนี้
    -- ถูกเรียกทุกครั้งที่มีการ __namecall ทั้งเกม (ทุก service call/remote call) ถ้าพังโดยไม่มี
    -- pcall จะทำให้ทุกการเรียก API ของเกมพังไปด้วย ไม่ใช่แค่ RSPY
    if not hookmetamethod then
        warn("[MyUI] Remote Spy: executor นี้ไม่รองรับ hookmetamethod ปิดใช้งาน Remote Spy อัตโนมัติ")
        Tabrspy:CreateLabel({
            Title = "Remote Spy ใช้งานไม่ได้บน executor นี้",
            Content = "executor ที่ใช้อยู่ไม่รองรับ hookmetamethod",
            Type = "Warning",
        })
        return
    end

    local oldFireServer
    local oldInvokeServer

    local hookOk, hookErr = pcall(function()
        oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
            local nsOk, method = pcall(getnamecallmethod)
            local args = {...}

            if nsOk and isRspyEnabled and method == "FireServer" and self:IsA("RemoteEvent") then
                pcall(function()
                    local path = "game." .. self:GetFullName()
                    local callingScript = "Unknown Script"
                    local srcSuccess, srcObj = pcall(getcallingscript)
                    if srcSuccess and srcObj then pcall(function() callingScript = srcObj:GetFullName() end) end
                    local argsText = formatArgs(args)

                    task.defer(createRemoteLogUI, "Event", path, argsText, callingScript)
                end)
            end
            return oldFireServer(self, ...)
        end)

        oldInvokeServer = hookmetamethod(game, "__namecall", function(self, ...)
            local nsOk, method = pcall(getnamecallmethod)
            local args = {...}

            if nsOk and isRspyEnabled and method == "InvokeServer" and self:IsA("RemoteFunction") then
                pcall(function()
                    local path = "game." .. self:GetFullName()
                    local callingScript = "Unknown Script"
                    local srcSuccess, srcObj = pcall(getcallingscript)
                    if srcSuccess and srcObj then pcall(function() callingScript = srcObj:GetFullName() end) end
                    local argsText = formatArgs(args)

                    task.defer(createRemoteLogUI, "Function", path, argsText, callingScript)
                end)
            end
            return oldInvokeServer(self, ...)
        end)
    end)

    if not hookOk then
        warn("[MyUI] Remote Spy: hook ไม่สำเร็จ: " .. tostring(hookErr))
    end
end
        
        -- ห่อด้วย pcall ทีละแท็บ: ถ้าแท็บใดแท็บหนึ่ง error (เช่น executor ขาดฟังก์ชันบางตัว)
        -- จะเสียแค่แท็บนั้น ไม่ทำให้ทั้งหน้าต่าง MyUI ไม่ขึ้นเลย
        --
        -- เปิด/ปิดแต่ละแท็บได้ผ่าน config.PresetTabs ตอนเรียก CreateWindow เช่น:
        --   MyUI:CreateWindow({ PresetTabs = { Loop = false, RSPY = false } })
        -- ไม่ระบุ PresetTabs เลย หรือไม่ระบุ key ไหน = เปิดทุกแท็บเหมือนเดิม (default true ทั้งหมด)
        local presetConfig = config.PresetTabs or {}
        local presetTabs = {
            { name = "Info",   fn = Window.EnableInfoTab },
            { name = "Player", fn = Window.EnablePlayerTab },
            { name = "Loop",   fn = Window.EnableLoopTab },
            { name = "RSPY",   fn = Window.EnableRemoteSpy },
        }
        for _, preset in ipairs(presetTabs) do
            local enabled = presetConfig[preset.name]
            if enabled == nil then enabled = true end
            if enabled then
                local ok, err = pcall(preset.fn, Window)
                if not ok then
                    warn(("[MyUI] โหลดแท็บ %s ไม่สำเร็จ: %s"):format(preset.name, tostring(err)))
                end
            end
        end

        return Window
    end

    -- ปรับขนาด UI ทั้งหน้าต่างได้ตอน runtime เช่น Window:SetScale(0.5) เพื่อย่อครึ่งหนึ่ง
    -- animate = true (ค่าเริ่มต้น) จะ tween ให้ลื่นไหล, false จะเปลี่ยนทันที
    function MyUI:SetScale(scale, animate)
        self._targetScale = scale
        if animate == false then
            self._windowScale.Scale = scale
        else
            tween(self._windowScale, { Scale = scale }, 0.25)
        end
    end

    -- ===== Tab =====
    -- name: ชื่อแท็บ | icon (optional): rbxassetid:// ถ้าไม่ใส่จะใช้จุดสี่เหลี่ยมเล็กแบบเดิม
    function MyUI:CreateTab(name, icon)
        local isFirst = self._firstTab

        local TabButton = new("TextButton", {
            Text = "",
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = isFirst and 0 or 0.4,
            Size = UDim2.new(1, 0, 0, 42),
            AutoButtonColor = false,
            Parent = self.TabList,
        }, { corner(8), stroke(Theme.Accent, 1, isFirst and 0 or 1) })

        local ActiveStroke = TabButton:FindFirstChildOfClass("UIStroke")

        local IconSlot
        if icon then
            IconSlot = new("ImageLabel", {
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.fromOffset(10, 12),
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = isFirst and Theme.Accent or Theme.SubText,
                Parent = TabButton,
            })
        else
            IconSlot = new("Frame", {
                Size = UDim2.fromOffset(10, 10),
                Position = UDim2.fromOffset(14, 16),
                BackgroundColor3 = isFirst and Theme.Accent or Theme.SubText,
                Parent = TabButton,
            }, { corner(3) })
        end

        local Label = new("TextLabel", {
            Text = string.upper(name),
            Font = Theme.FontBold,
            TextSize = 14,
            TextColor3 = isFirst and Theme.Text or Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(34, 0),
            Size = UDim2.new(1, -56, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton,
        })

        local Chevron = new("TextLabel", {
            Text = ">",
            Font = Theme.FontBold,
            TextSize = 16,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -26, 0, 0),
            Size = UDim2.fromOffset(18, 42),
            Visible = isFirst,
            Parent = TabButton,
        })

        local Page = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = isFirst,
            Parent = self.PagesContainer,
        })

        new("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page,
        })

        -- ระยะขอบรอบเนื้อหา กันไม่ให้ component ชิด/ล้นทับเส้นขอบของกรอบ หรือชนแถบ scrollbar
        new("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 8),
            Parent = Page,
        })

        if isFirst then
            self._firstTab = false
            self.HeaderLabel.Text = string.upper(name)
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Page.Visible = false
                tween(t.Button, { BackgroundTransparency = 0.4 }, 0.15)
                setIconColor(t.Icon, Theme.SubText)
                tween(t.Label, { TextColor3 = Theme.SubText }, 0.15)
                tween(t.Stroke, { Transparency = 1 }, 0.15)
                t.Chevron.Visible = false
            end
            Page.Visible = true
            tween(TabButton, { BackgroundTransparency = 0 }, 0.15)
            setIconColor(IconSlot, Theme.Accent)
            tween(Label, { TextColor3 = Theme.Text }, 0.15)
            tween(ActiveStroke, { Transparency = 0 }, 0.15)
            Chevron.Visible = true
            self.HeaderLabel.Text = string.upper(name)
        end)

        local Tab = setmetatable({
            Button = TabButton,
            Page = Page,
            Icon = IconSlot,
            Label = Label,
            Chevron = Chevron,
            Stroke = ActiveStroke,
        }, { __index = MyUI })

        table.insert(self.Tabs, Tab)
        return Tab
    end

    -- ===== SetState / GetState (เก็บค่า state เล็กๆ น้อยๆ ต่อ Window instance) =====
    -- ใช้เก็บค่าที่ต้องอ่าน/เขียนข้าม callback ต่างๆ เช่น Loop tab เก็บ Script/ความเร็ว/สถานะ
    -- เปิด-ปิดของแต่ละชุดลูปไว้ที่นี่ แล้วอ่านกลับมาใช้ใน task.spawn loop ที่รันแยกต่างหาก
    -- เก็บใน self._state (per-Window instance ไม่ปนกันข้าม Window ถ้ามีหลายอัน)
    function MyUI:SetState(key, value)
        self._state = self._state or {}
        self._state[key] = value
    end

    function MyUI:GetState(key)
        self._state = self._state or {}
        return self._state[key]
    end

    -- ===== SetTheme (สลับชุดสีของ UI ทั้งหมด — มีผลกับ component ที่สร้าง "หลังจากนี้") =====
    -- ใช้งาน: MyUI:SetTheme({ Accent = Color3.fromRGB(255, 70, 90), Accent2 = Color3.fromRGB(255, 190, 60) })
    function MyUI:SetTheme(colors)
        colors = colors or {}
        for key, value in pairs(colors) do
            if Theme[key] ~= nil then
                Theme[key] = value
            end
        end
    end
end
