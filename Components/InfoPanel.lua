--[[
    Components/InfoPanel.lua
    Tab:CreateInfoPanel({ Executor?, ExecutorVersion?, FetchJoinDate? }) -> Holder

    การ์ดโปรไฟล์ผู้เล่น: รูปโปรไฟล์ (avatar) + ชื่อ/username + จุดสถานะออนไลน์ + เวลา
    ตามด้วยกล่องข้อมูลผู้ใช้ (User Information) และข้อมูลระบบ (System Information)
    คล้ายหน้า "INFO" ของ hub ตัวอย่าง

    หมายเหตุความถูกต้องของข้อมูล (สำคัญ อ่านก่อนใช้):
    - User ID / Account Age / Platform: ดึงจาก LocalPlayer ตรงๆ ถูกต้อง 100% ไม่ต้องพึ่ง network
    - Join Date: ยิง HTTP ไปที่ Roblox public API (users.roblox.com) เพื่อเอาวันที่สมัครจริง
      ถ้า executor ที่ใช้บล็อกโดเมนนี้ หรือปิด HttpGet ไว้ จะ fallback เป็น "N/A" (ไม่ error)
    - Executor / Version: ลองเรียก identifyexecutor()/getexecutorname() ถ้ามีในสภาพแวดล้อม
      ไม่ใช่ทุก executor ที่มีฟังก์ชันนี้ ถ้าไม่มีจะ fallback เป็น "Unknown" — ใส่ค่าคงที่เองผ่าน
      config.Executor / config.ExecutorVersion ได้เสมอถ้าอยากบังคับข้อความ
    - Last Login: Roblox ไม่มี API ให้ client ดึง "เวลา login ล่าสุดจริง" ได้ ช่องนี้จึงแสดงเวลา
      ปัจจุบันตอนเปิด panel (เวลาที่ "session" นี้เริ่ม) ไม่ใช่ประวัติการล็อกอินจริงจากฐานข้อมูล Roblox
]]

return function(MyUI, Theme, StatusColors, Utils, Services)
    local new, corner, stroke = Utils.new, Utils.corner, Utils.stroke
    local Players = Services.Players
    local LocalPlayer = Services.LocalPlayer
    local RunService = Services.RunService
    local UserInputService = Services.UserInputService
    local HttpService = game:GetService("HttpService")

    local function safeCall(fn, ...)
        if type(fn) ~= "function" then return nil end
        local ok, a, b = pcall(fn, ...)
        if ok then return a, b end
        return nil
    end

    -- ลองหาชื่อ/เวอร์ชัน executor จากฟังก์ชัน global ที่ executor ส่วนใหญ่มักเปิดให้ใช้
    -- (ไม่ใช่ทุกตัวจะมี ถ้าไม่มีจะคืน "Unknown" เฉยๆ ไม่ error)
    local function detectExecutor()
        if identifyexecutor then
            local name, version = safeCall(identifyexecutor)
            if name then return name, version or "" end
        end
        if getexecutorname then
            local name = safeCall(getexecutorname)
            if name then return name, "" end
        end
        return "Unknown", ""
    end

    local function getPlatform()
        local ok, platform = pcall(function() return UserInputService:GetPlatform() end)
        if ok and platform then return platform.Name end
        return "Unknown"
    end

    -- ยิง HTTP ไป Roblox public API เพื่อดึงวันที่สมัครจริง (best-effort, มี pcall กันไว้ทั้งหมด)
    --
    -- ลองใช้ฟังก์ชัน request หลายตัวตามลำดับ เพราะ executor แต่ละตัว (โดยเฉพาะบนมือถือ เช่น
    -- Delta) มักบล็อก game:HttpGet ไม่ให้ยิงไปโดเมนนอกเกม (users.roblox.com) แต่บางตัวเปิดให้
    -- ใช้ผ่านฟังก์ชัน request/http_request/syn.request แทนได้ — ถ้าทุกตัวยิงไม่สำเร็จจริงๆ จะ
    -- warn เหตุผลของความล้มเหลวล่าสุดออก console เพื่อให้ debug ได้ว่าติดที่ executor ไม่รองรับ
    -- หรือ Roblox API ตอบกลับผิดปกติ
    local function httpGet(url)
        local requestFn = (syn and syn.request) or http_request or request or fluxus_request
        if requestFn then
            local ok, res = pcall(requestFn, { Url = url, Method = "GET" })
            if ok and res and (res.StatusCode == nil or res.StatusCode == 200) and res.Body then
                return true, res.Body
            end
        end
        -- fallback สุดท้าย: game:HttpGet ตรงๆ (ใช้ได้กับ executor ส่วนใหญ่ที่อนุญาตโดเมนนี้)
        local ok, res = pcall(game.HttpGet, game, url)
        if ok then return true, res end
        return false, res
    end

    local function fetchJoinDate(userId)
        local success, body = httpGet("https://users.roblox.com/v1/users/" .. tostring(userId))
        if success then
            local ok, result = pcall(function()
                return HttpService:JSONDecode(body).created -- ISO8601 เช่น "2019-05-02T10:00:00.000Z"
            end)
            if ok and result then
                local y, m, d = result:match("(%d+)-(%d+)-(%d+)")
                if y then return string.format("%s/%s/%s", d, m, y) end
            end
            warn("[MyUI] ดึง Join Date ไม่สำเร็จ: รูปแบบข้อมูลที่ได้กลับมาไม่ตรงตามคาด (" .. tostring(body):sub(1, 120) .. ")")
        else
            warn("[MyUI] ดึง Join Date ไม่สำเร็จ: " .. tostring(body) .. " (executor นี้อาจบล็อกการยิง HTTP ไปโดเมนนอกเกม)")
        end
        return "N/A"
    end

    -- แถวข้อมูล "หัวข้อ ... ค่า" ใช้ซ้ำทั้งกล่อง User/System Information
    local function addStatRow(parent, key, value, layoutOrder)
        local Row = new("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = parent,
        })
        new("Frame", {
            Size = UDim2.fromOffset(4, 4),
            Position = UDim2.fromOffset(2, 9),
            BackgroundColor3 = Theme.Accent,
            Parent = Row,
        }, { corner(2) })
        new("TextLabel", {
            Text = key,
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(0.55, -14, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Row,
        })
        local ValueLabel = new("TextLabel", {
            Text = tostring(value),
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.55, 0, 0, 0),
            Size = UDim2.new(0.45, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = Row,
        })
        return ValueLabel
    end

    -- หัวข้อกล่องย่อย (ไอคอนสี่เหลี่ยมเล็ก + ข้อความ) ใช้กับ "USER INFORMATION" / "SYSTEM INFORMATION"
    local function addBoxHeader(parent, text)
        local Header = new("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = parent,
        })
        new("Frame", {
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.fromOffset(0, 6),
            BackgroundColor3 = Theme.Accent,
            Parent = Header,
        }, { corner(2) })
        new("TextLabel", {
            Text = string.upper(text),
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.new(1, -16, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })
    end

    function MyUI:CreateInfoPanel(config)
        config = config or {}
        local fetchJoin = (config.FetchJoinDate ~= false) -- default true

        local Holder = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = self.Page,
        })
        new("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = Holder,
        })

        -- ===== การ์ดโปรไฟล์: avatar + ชื่อ + username + เวลา =====
        local ProfileCard = new("Frame", {
            Size = UDim2.new(1, 0, 0, 96),
            BackgroundColor3 = Theme.Secondary,
            LayoutOrder = 1,
            Parent = Holder,
        }, { corner(12), stroke(Theme.Accent, 1) })

        local AvatarHolder = new("Frame", {
            Size = UDim2.fromOffset(64, 64),
            Position = UDim2.fromOffset(16, 16),
            BackgroundColor3 = Theme.Background,
            Parent = ProfileCard,
        }, { corner(32), stroke(Theme.Accent, 2) })

        local Avatar = new("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScaleType = Enum.ScaleType.Crop,
            Image = "",
            Parent = AvatarHolder,
        }, { corner(32) })

        -- โหลดรูปโปรไฟล์แบบ async (GetUserThumbnailAsync yield ได้ ต้องเรียกใน task.spawn กันหน้าจอค้าง)
        task.spawn(function()
            local ok, content = pcall(function()
                local c = Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150
                )
                return c
            end)
            if ok and content then
                Avatar.Image = content
            end
        end)

        -- จุดสถานะออนไลน์ มุมล่างขวาของ avatar
        new("Frame", {
            Size = UDim2.fromOffset(14, 14),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 2, 1, 2),
            BackgroundColor3 = StatusColors.Success,
            Parent = AvatarHolder,
        }, { corner(7), stroke(Theme.Secondary, 3) })

        -- แถวชื่อ: "Welcome, " (สีปกติ) + DisplayName (สีเน้น) เรียงแนวนอนอัตโนมัติ
        local NameRow = new("Frame", {
            Size = UDim2.new(1, -180, 0, 22),
            Position = UDim2.fromOffset(96, 16),
            BackgroundTransparency = 1,
            Parent = ProfileCard,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = NameRow,
        })
        new("TextLabel", {
            Text = "Welcome, ",
            Font = Theme.FontBlack,
            TextSize = 19,
            TextColor3 = Theme.Text,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            LayoutOrder = 1,
            Parent = NameRow,
        })
        new("TextLabel", {
            Text = LocalPlayer.DisplayName,
            Font = Theme.FontBlack,
            TextSize = 19,
            TextColor3 = Theme.Accent2,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            LayoutOrder = 2,
            Parent = NameRow,
        })

        new("TextLabel", {
            Text = "@" .. LocalPlayer.Name,
            Font = Theme.FontBold,
            TextSize = 13,
            TextColor3 = Theme.Accent2,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(96, 40),
            Size = UDim2.new(1, -180, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ProfileCard,
        })

        local ClockLabel = new("TextLabel", {
            Text = os.date("%H:%M"),
            Font = Theme.Font,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(96, 62),
            Size = UDim2.new(1, -180, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ProfileCard,
        })

        -- อัปเดตนาฬิกาให้เดินจริงแบบเรียลไทม์ (ของเดิม os.date() รันครั้งเดียวตอนสร้าง panel
        -- แล้วค้างอยู่ค่านั้นตลอด เพราะไม่มี loop มาเซ็ต .Text ซ้ำ) เช็คทุก 1 วิ แต่เขียน .Text
        -- เฉพาะตอนค่าที่แสดงเปลี่ยนจริง (เปลี่ยนนาที) กัน set ค่าเดิมซ้ำโดยไม่จำเป็น
        task.spawn(function()
            local lastText = ClockLabel.Text
            while ClockLabel.Parent do
                local nowText = os.date("%H:%M")
                if nowText ~= lastText then
                    ClockLabel.Text = nowText
                    lastText = nowText
                end
                task.wait(1)
            end
        end)

        -- ===== แถวสองกล่อง: User Information | System Information =====
        local InfoRow = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Parent = Holder,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = InfoRow,
        })

        local UserBox = new("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Secondary,
            LayoutOrder = 1,
            Parent = InfoRow,
        }, { corner(10), stroke(Theme.Stroke, 1) })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
            Parent = UserBox,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = UserBox })

        local SystemBox = new("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Secondary,
            LayoutOrder = 2,
            Parent = InfoRow,
        }, { corner(10), stroke(Theme.Stroke, 1) })
        new("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
            Parent = SystemBox,
        })
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = SystemBox })

        addBoxHeader(UserBox, "User Information")
        addStatRow(UserBox, "User ID", LocalPlayer.UserId, 1)

        local accountAgeYears = math.floor((LocalPlayer.AccountAge or 0) / 365)
        addStatRow(UserBox, "Account Age", accountAgeYears .. (accountAgeYears == 1 and " Year" or " Years"), 2)

        local JoinDateValue = addStatRow(UserBox, "Join Date", fetchJoin and "..." or "N/A", 3)
        addStatRow(UserBox, "Last Login", os.date("%d/%m/%Y %H:%M"), 4)

        if fetchJoin then
            task.spawn(function()
                JoinDateValue.Text = fetchJoinDate(LocalPlayer.UserId)
            end)
        end

        addBoxHeader(SystemBox, "System Information")

        local execName, execVersion = config.Executor, config.ExecutorVersion
        if not execName then
            execName, execVersion = detectExecutor()
        end
        addStatRow(SystemBox, "Executor", execName, 1)
        addStatRow(SystemBox, "Version", (execVersion and execVersion ~= "") and execVersion or "N/A", 2)
        addStatRow(SystemBox, "Platform", getPlatform(), 3)

        local FPSValue = addStatRow(SystemBox, "FPS", "...", 4)
        local frames, elapsed = 0, 0
        RunService.RenderStepped:Connect(function(dt)
            if not FPSValue.Parent then return end -- Holder ถูกลบไปแล้ว หยุดนับ
            frames += 1
            elapsed += dt
            if elapsed >= 0.5 then
                FPSValue.Text = tostring(math.floor(frames / elapsed))
                frames, elapsed = 0, 0
            end
        end)

        return Holder
    end
end

