--[[
    Core/Theme.lua
    ธีมสี Sci-Fi Cyan/Purple ของ MyUI — ทุก component ในไลบรารีอ้างอิงสีจากตารางนี้ตัวเดียวกัน
    ปรับได้ตอน runtime ผ่าน MyUI:SetTheme({ Accent = Color3.fromRGB(255,0,0), ... }) (ดู Core/Window.lua)

    คืนค่า: { Theme = <table สีหลัก>, StatusColors = <table สีตามสถานะ> }
]]

local Theme = {
    Background = Color3.fromRGB(6, 9, 16),
    Secondary  = Color3.fromRGB(13, 17, 28),
    Stroke     = Color3.fromRGB(40, 50, 70),
    Accent     = Color3.fromRGB(0, 220, 255),   -- cyan
    Accent2    = Color3.fromRGB(170, 80, 255),  -- purple
    Text       = Color3.fromRGB(235, 244, 255),
    SubText    = Color3.fromRGB(130, 145, 170),
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
    FontBlack  = Enum.Font.GothamBlack,
}

-- ใช้กับ Tab:CreateLabel({ Type = "Success" }) และ Window:Notify({ Type = "Error" }) เป็นต้น
local StatusColors = {
    Info    = Theme.Accent,
    Success = Color3.fromRGB(70, 220, 130),
    Warning = Color3.fromRGB(255, 190, 60),
    Error   = Color3.fromRGB(255, 70, 90),
}

return { Theme = Theme, StatusColors = StatusColors }
