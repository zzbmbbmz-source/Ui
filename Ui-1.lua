--[[
    Ui-1.lua — MyUI Loader (ไฟล์ "หลัก" ที่ผู้ใช้ทั่วไป loadstring)
    ----------------------------------------------------------------
    ไฟล์นี้ "ไม่มี" โค้ด UI ตรงๆ อีกต่อไป — มันแค่เป็นตัวโหลดที่ดึงทุกโมดูล
    จาก repo นี้ (ผ่าน game:HttpGet เพราะสภาพแวดล้อม executor ไม่มี require
    สำหรับไฟล์ระยะไกล) แล้วประกอบเข้าด้วยกันเป็นตาราง MyUI ตัวเดียว ก่อน return กลับไป

    โครงสร้างไฟล์ (ตรงกับ root ของ repo — ไม่มีโฟลเดอร์ Ui/ ครอบอีกชั้น):
        Ui-1.lua                    <- ไฟล์นี้ (loader)
        Core/Theme.lua               <- สีธีม + สีสถานะ
        Core/Utils.lua                <- helper: new/tween/corner/stroke/glow/drag ฯลฯ
        Core/Window.lua               <- CreateWindow, CreateTab, SetScale, SetTheme
        Components/*.lua             <- Button, Toggle, Slider, Dropdown, Input,
                                         Section, Paragraph, Label, Keybind,
                                         Colorpicker, ProgressBar, Confirm
        Features/*.lua                <- Watermark, Notify

    การใช้งาน (เหมือนเดิมทุกประการ ไม่กระทบผู้ใช้ปลายทาง):
        local MyUI = loadstring(game:HttpGet("URL_TO_THIS_FILE"))()
        local Window = MyUI:CreateWindow({ Title = "My Hub", SubTitle = "v1.0" })
        local Tab = Window:CreateTab("Main")
        Tab:CreateButton({ Title = "Click me", Callback = function() print("clicked") end })

    ผู้พัฒนาที่ fork ไปทำ Hub ของตัวเอง: ถ้าจะเพิ่ม component ใหม่ ให้เพิ่มไฟล์ในโฟลเดอร์
    Components/ (หรือ Features/) ตามรูปแบบไฟล์อื่นๆ ในโฟลเดอร์เดียวกัน แล้วเพิ่ม path
    เข้า MODULE_PATHS ด้านล่าง — ไม่ต้องแก้ไฟล์นี้ส่วนอื่นเลย
    ดูรายละเอียดเพิ่มเติมใน README.md
]]

-- ★ แก้ตรงนี้ให้ตรงกับ user/repo/branch ของคุณเองถ้า fork ไปใช้ ★
local BASE_URL = "https://raw.githubusercontent.com/zzbmbbmz-source/Ui/refs/heads/main/"

-- โหลดไฟล์ Lua จาก repo แล้ว execute ทันที (เทียบเท่า require แบบ remote)
local function load(path)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if not ok then
        error(("[MyUI] โหลดโมดูลไม่สำเร็จ: %s\nสาเหตุ: %s"):format(path, tostring(result)), 0)
    end
    return result
end

-- ===== Services ตัวเดียวที่แชร์ร่วมกันทุกโมดูล (กัน GetService ซ้ำซ้อนหลายรอบ) =====
local Services = {
    TweenService     = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players          = game:GetService("Players"),
    RunService       = game:GetService("RunService"),
}
Services.LocalPlayer = Services.Players.LocalPlayer
Services.PlayerGui   = Services.LocalPlayer:WaitForChild("PlayerGui")

-- ===== Core: ธีมสี + helper ระดับล่าง =====
local Core   = load("Core/Theme.lua")
local Theme       = Core.Theme
local StatusColors = Core.StatusColors

local Utils = load("Core/Utils.lua")(Theme, Services)

-- ===== ตาราง MyUI หลัก — ทุกโมดูลด้านล่างจะแนบเมธอด (CreateWindow, CreateButton, ...) เข้ามาที่นี่ =====
local MyUI = {}
MyUI.__index = MyUI

-- รายชื่อโมดูลที่ต้องโหลด เรียงตามลำดับที่เหมาะสม (Window ก่อน เพราะ component อื่นพึ่งพา self.Page
-- ที่มาจาก Tab ซึ่งสร้างใน Window.lua — แต่จริงๆ ลำดับไม่มีผลเพราะทุกไฟล์แค่ "แนบเมธอด" ไม่ได้เรียกใช้ทันที)
local MODULE_PATHS = {
    "Core/Window.lua",

    "Components/Button.lua",
    "Components/Toggle.lua",
    "Components/Slider.lua",
    "Components/Dropdown.lua",
    "Components/Input.lua",
    "Components/Section.lua",
    "Components/Paragraph.lua",
    "Components/Label.lua",
    "Components/Keybind.lua",
    "Components/Colorpicker.lua",
    "Components/ProgressBar.lua",
    "Components/Confirm.lua",
    "Components/InfoPanel.lua",
    "Components/LogEntry.lua",

    "Features/Watermark.lua",
    "Features/Notify.lua",
}

for _, path in ipairs(MODULE_PATHS) do
    local attach = load(path)
    attach(MyUI, Theme, StatusColors, Utils, Services)
end

return MyUI
