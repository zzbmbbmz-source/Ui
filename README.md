# MyUI

ไลบรารี UI แบบ Sci-Fi (โทนสี Cyan/Purple) สำหรับ Roblox executor โหลดแบบ remote ผ่าน
`loadstring(game:HttpGet(...))` — แยกไฟล์เป็นโมดูลย่อยตามหน้าที่ (Core / Components / Features)
แล้วประกอบเข้าด้วยกันเป็นตาราง `MyUI` ตัวเดียวโดย loader (`Ui-1.lua`)

> ⚠️ **หมายเหตุสำคัญ**: `Core/Window.lua` ในโปรเจกต์นี้มีแท็บตัวอย่าง (preset tabs) ที่ผูกฟีเจอร์
> จำพวก game-modification เข้ามาโดยอัตโนมัติทุกครั้งที่เรียก `CreateWindow` (ดูหัวข้อ
> [Preset Tabs](#preset-tabs-ที่ผูกมากับ-createwindow-อัตโนมัติ) ด้านล่าง) ฟีเจอร์เหล่านี้
> อาจขัดกับข้อกำหนดการใช้งาน (Terms of Service) ของเกมที่นำไปใช้ ผู้ใช้ควรตรวจสอบและ
> รับผิดชอบการใช้งานด้วยตัวเอง เอกสารนี้อธิบายเฉพาะว่ามีแท็บอะไรบ้างในระดับสูง
> ไม่ลงรายละเอียดกลไกภายใน

---

## ติดตั้ง / เริ่มใช้งาน

```lua
local MyUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/zzbmbbmz-source/Ui/refs/heads/main/Ui-1.lua"))()

local Window = MyUI:CreateWindow({
    Title = "My Hub",
    SubTitle = "v1.0",
    Scale = 0.7,
})

local Tab = Window:CreateTab("Main")
Tab:CreateButton({ Title = "Click me", Callback = function() print("clicked") end })
```

`Ui-1.lua` จะ `HttpGet` ไฟล์โมดูลทั้งหมดจาก repo ตามลำดับใน `MODULE_PATHS` แล้ว "แนบ" เมธอด
เข้ากับตาราง `MyUI` ตัวเดียว ลำดับการโหลดไม่มีผลต่อการทำงาน เพราะทุกไฟล์แค่แนบฟังก์ชัน
ไม่ได้เรียกใช้งานทันที

---

## สารบัญ

- [Core: Window](#core-window)
  - [`MyUI:CreateWindow(config)`](#myuicreatewindowconfig)
  - [`MyUI:CreateTab(name, icon)`](#myuicreatetabname-icon)
  - [`MyUI:SetScale(scale, animate)`](#myuisetscalescale-animate)
  - [`MyUI:SetTheme(colors)`](#myuisetthemecolors)
- [Components (เรียกผ่าน `Tab:Create...`)](#components-เรียกผ่าน-tabcreate)
  - [CreateButton](#tabcreatebuttonconfig)
  - [CreateToggle](#tabcreatetoggleconfig)
  - [CreateSlider](#tabcreatesliderconfig)
  - [CreateDropdown](#tabcreatedropdownconfig)
  - [CreateInput](#tabcreateinputconfig)
  - [CreateSection](#tabcreatesectionconfig)
  - [CreateParagraph](#tabcreateparagraphconfig)
  - [CreateLabel](#tabcreatelabelconfig)
  - [CreateKeybind](#tabcreatekeybindconfig)
  - [CreateColorpicker](#tabcreatecolorpickerconfig)
  - [CreateProgressBar](#tabcreateprogressbarconfig)
  - [CreateConfirm](#windowcreateconfirmconfig)
  - [CreateInfoPanel](#tabcreateinfopanelconfig)
  - [CreateLogEntry](#tabcreatelogentryconfig)
- [Features](#features)
  - [CreateWatermark](#windowcreatewatermarkconfig)
  - [Notify](#myuinotifyconfig)
- [Core: Theme & Utils (สำหรับนักพัฒนาที่ fork)](#core-theme--utils-สำหรับนักพัฒนาที่-fork)
- [Preset Tabs ที่ผูกมากับ CreateWindow อัตโนมัติ](#preset-tabs-ที่ผูกมากับ-createwindow-อัตโนมัติ)
- [โครงสร้างไฟล์](#โครงสร้างไฟล์)

---

## Core: Window

โมดูล `Core/Window.lua` แนบเมธอดหลักของ `MyUI` เข้ามา: `CreateWindow`, `CreateTab`,
`SetScale`, `SetTheme`

### `MyUI:CreateWindow(config)`

สร้างหน้าต่างหลัก (ล้าง ScreenGui ชื่อ `MyUI` เก่าทิ้งก่อนเสมอ กันเปิดซ้อนกันถ้ารันสคริปต์ซ้ำ)
คืนค่าเป็น `Window` object ที่ใช้เรียก `CreateTab` และเมธอดอื่นๆ ต่อได้

**Parameters (config table):**

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"MyUI"` | หัวข้อหลัก แสดงตัวพิมพ์ใหญ่บน TopBar |
| `SubTitle` | string | `""` | ข้อความรองใต้หัวข้อ |
| `Size` | UDim2 | `UDim2.fromOffset(760, 460)` | ขนาดหน้าต่าง |
| `Scale` | number | `0.7` | ตัวคูณขนาด UI ทั้งหมดตอนเปิดครั้งแรก เช่น `0.5` = ครึ่งหนึ่ง |
| `PresetTabs` | table | `{}` (= เปิดหมด) | เปิด/ปิดแท็บสำเร็จรูปแต่ละตัว เช่น `{ Loop = false, RSPY = false }` — key ที่ไม่ระบุ = เปิด (`true`) โดย default ดูรายชื่อ key ที่ใช้ได้ใน [Preset Tabs](#preset-tabs-ที่ผูกมากับ-createwindow-อัตโนมัติ) |

**คืนค่า:** `Window` object (มี `Main`, `TabList`, `PagesContainer`, `Tabs`, ฯลฯ และรับเมธอดทุกตัวของ `MyUI`)

**พฤติกรรมเพิ่มเติม:**
- มีปุ่มลอย (hamburger/close) มุมซ้ายบน ลากได้อิสระ กดเพื่อเปิด/ปิดหน้าต่าง
- ปุ่มปิดรูปเพชรมุมขวาบนของ TopBar ก็ปิดหน้าต่างได้เช่นกัน (ไม่ทำลาย object เพียงซ่อน)
- ลาก TopBar เพื่อย้ายตำแหน่งหน้าต่างได้

```lua
local Window = MyUI:CreateWindow({
    Title = "My Hub",
    SubTitle = "v1.0",
    Size = UDim2.fromOffset(700, 440),
    Scale = 1,
})
```

### `MyUI:CreateTab(name, icon)`

สร้างแท็บใหม่ในแถบด้านซ้าย คืนค่าเป็น `Tab` object ที่ใช้เรียกทุกเมธอด `Create...`
ของ component ต่อได้ (Tab ใช้ metatable `{ __index = MyUI }` จึงเรียก `Tab:CreateButton(...)`
ได้เหมือนเรียกจาก `MyUI` โดยตรง แต่ component จะถูกวางลงใน `Tab.Page` ของแท็บนั้น)

**Parameters:**

| พารามิเตอร์ | ชนิด | จำเป็น | คำอธิบาย |
|---|---|---|---|
| `name` | string | ใช่ | ชื่อแท็บ (แสดงตัวพิมพ์ใหญ่) |
| `icon` | string | ไม่ | `rbxassetid://...` ถ้าไม่ใส่จะใช้จุดสี่เหลี่ยมเล็กแทน |

**คืนค่า:** `Tab` object

```lua
local Tab = Window:CreateTab("Main")
local TabWithIcon = Window:CreateTab("Combat", "rbxassetid://1234567890")
```

### `MyUI:SetScale(scale, animate)`

ปรับขนาด UI ทั้งหน้าต่างตอน runtime

| พารามิเตอร์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `scale` | number | — | ตัวคูณขนาดใหม่ |
| `animate` | boolean | `true` | `true` = tween ให้ลื่นไหล, `false` = เปลี่ยนทันที |

```lua
Window:SetScale(0.5)        -- ย่อครึ่งหนึ่งแบบ tween
Window:SetScale(1, false)   -- คืนขนาดปกติทันที ไม่มี animation
```

### `MyUI:SetTheme(colors)`

สลับชุดสีของ UI ทั้งหมด — **มีผลกับ component ที่สร้าง "หลังจากนี้" เท่านั้น** (component ที่
สร้างไปแล้วจะไม่เปลี่ยนสีย้อนหลัง)

| พารามิเตอร์ | ชนิด | คำอธิบาย |
|---|---|---|
| `colors` | table | key ต้องตรงกับ key ใน `Theme` (`Background`, `Secondary`, `Stroke`, `Accent`, `Accent2`, `Text`, `SubText`, `Font`, `FontBold`, `FontBlack`) |

```lua
MyUI:SetTheme({
    Accent  = Color3.fromRGB(255, 70, 90),
    Accent2 = Color3.fromRGB(255, 190, 60),
})
```

---

## Components (เรียกผ่าน `Tab:Create...`)

ทุก component ด้านล่างเรียกผ่าน `Tab` object ที่ได้จาก `Window:CreateTab(...)` และจะถูกวางลง
ใน `self.Page` (พื้นที่เนื้อหาของแท็บนั้น) โดยอัตโนมัติ `Callback` ทุกตัวถูกห่อด้วย `pcall`
ภายใน component เอง ดังนั้น error ใน callback จะไม่ทำให้ UI ทั้งชุดพัง

### `Tab:CreateButton(config)`

ปุ่มกดทั่วไป

| ฟิลด์ | ชนิด | จำเป็น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | ไม่ (default `"Button"`) | ข้อความบนปุ่ม |
| `SubTitle` | string | ไม่ | ข้อความอธิบายเพิ่มเติมใต้ Title |
| `Callback` | function | ไม่ | เรียกเมื่อกดปุ่ม ไม่มี argument |

**คืนค่า:** `Button` (GuiObject)

```lua
Tab:CreateButton({
    Title = "Reset Character",
    SubTitle = "รีเซ็ตตัวละครกลับจุดเกิด",
    Callback = function()
        print("button pressed")
    end,
})
```

### `Tab:CreateToggle(config)`

สวิตช์เปิด/ปิด

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Toggle"` | หัวข้อ |
| `SubTitle` | string | — | ข้อความรอง |
| `Default` | boolean | `false` | สถานะเริ่มต้น |
| `Callback` | function(state: boolean) | — | เรียกทุกครั้งที่สลับสถานะ |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})
```

### `Tab:CreateSlider(config)`

แถบเลื่อนเลือกค่าตัวเลข

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Slider"` | หัวข้อ |
| `SubTitle` | string | — | ข้อความรอง |
| `Min` | number | `0` | ค่าต่ำสุด |
| `Max` | number | `100` | ค่าสูงสุด |
| `Step` | number | `1` | ระยะขั้นของการเลื่อน |
| `Default` | number | `Min` | ค่าเริ่มต้น |
| `Callback` | function(value: number) | — | เรียกทุกครั้งที่ค่าปลี่ยน |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateSlider({
    Title = "WalkSpeed",
    Min = 16, Max = 250, Step = 1, Default = 16,
    Callback = function(value)
        print("WalkSpeed:", value)
    end,
})
```

### `Tab:CreateDropdown(config)`

เมนูดรอปดาวน์เลือกตัวเลือก รองรับโหมดดึงรายชื่อผู้เล่นในเซิร์ฟเวอร์อัตโนมัติ

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Dropdown"` | หัวข้อ |
| `SubTitle` | string | — | ข้อความรอง |
| `Options` | table (array of string) | `{}` | รายการตัวเลือก |
| `Default` | string | `Options[1]` | ตัวเลือกเริ่มต้น |
| `Callback` | function(option: string) | — | เรียกเมื่อเลือกตัวเลือก |
| `AutoPlayerList` | boolean | `false` | `true` = ทุกครั้งที่เปิดดรอปดาวน์จะดึงรายชื่อผู้เล่นในเซิร์ฟเวอร์ปัจจุบันมาแทน `Options` อัตโนมัติ |
| `ExcludeSelf` | boolean | `false` | ใช้ร่วมกับ `AutoPlayerList` — `true` = ไม่แสดงชื่อ LocalPlayer เองในลิสต์ |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateDropdown({
    Title = "เลือกผู้เล่น",
    Options = {},
    AutoPlayerList = true,
    ExcludeSelf = true,
    Callback = function(name)
        print("selected:", name)
    end,
})
```

### `Tab:CreateInput(config)`

กล่องกรอกข้อความ

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Input"` | หัวข้อ |
| `SubTitle` | string | — | ข้อความรอง |
| `Placeholder` | string | `"..."` | ข้อความจางๆ ตอนยังไม่พิมพ์ |
| `Default` | string | `""` | ข้อความเริ่มต้น |
| `Callback` | function(text: string, enterPressed: boolean) | — | เรียกเมื่อกล่องข้อความเปลี่ยน/กด Enter |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateInput({
    Title = "Script",
    Placeholder = "print('hello')",
    Default = "",
    Callback = function(text, enterPressed)
        print(text, enterPressed)
    end,
})
```

### `Tab:CreateSection(config)`

หัวข้อย่อย/เส้นคั่น ใช้จัดกลุ่ม component ในแท็บ ไม่มี callback

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Section"` | ข้อความหัวข้อย่อย |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateSection({ Title = "Movement" })
```

### `Tab:CreateParagraph(config)`

ข้อความยาวๆ ปรับความสูงอัตโนมัติตามเนื้อหา

| ฟิลด์ | ชนิด | คำอธิบาย |
|---|---|---|
| `Title` | string (default `"Paragraph"`) | หัวข้อ |
| `Content` | string | เนื้อหาข้อความยาว |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateParagraph({
    Title = "หมายเหตุ",
    Content = "คำอธิบายยาวๆ ที่ต้องการแสดงในแท็บ จะตัดบรรทัดและปรับความสูงให้อัตโนมัติ",
})
```

### `Tab:CreateLabel(config)`

ป้ายข้อความสถานะ รองรับสีตามสถานะสำเร็จรูป และเอฟเฟกต์เรืองแสง

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Label"` | ข้อความหลัก |
| `Content` | string | — | ข้อความรอง (ถ้ามี) |
| `Type` | `"Info"` \| `"Success"` \| `"Warning"` \| `"Error"` | — | กำหนดสีขอบ/accent ตาม `StatusColors` |
| `Color` | Color3 | — | บังคับสีเอง (สำคัญกว่า `Type`) |
| `Align` | `"Left"` \| `"Center"` | `"Left"` | การจัดวางข้อความ |
| `Glow` | boolean | `false` | `true` = ใช้กรอบเรืองแสงแทนเส้นขอบสีเรียบ |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateLabel({
    Title = "⚡ CreateBy: YourName ⚡",
    Align = "Center",
    Glow = true,
})

Tab:CreateLabel({ Title = "เชื่อมต่อสำเร็จ", Type = "Success" })
```

### `Tab:CreateKeybind(config)`

ปุ่มผูกคีย์ลัด กดเพื่อเข้าโหมด "ฟัง" แล้วกดปุ่มบนคีย์บอร์ดเพื่อตั้งค่าใหม่

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Keybind"` | หัวข้อ |
| `Default` | `Enum.KeyCode` | `Enum.KeyCode.RightControl` | ปุ่มเริ่มต้น |
| `Callback` | function(key: Enum.KeyCode) | — | เรียกเมื่อผูกปุ่มใหม่สำเร็จ |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateKeybind({
    Title = "เปิด/ปิดเมนู",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Bound to:", key.Name)
    end,
})
```

### `Tab:CreateColorpicker(config)`

ตัวเลือกสีแบบพาเลตสำเร็จรูป กดที่แถบเพื่อขยาย/ยุบพาเลต

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Color"` | หัวข้อ |
| `Default` | Color3 | `Theme.Accent` | สีเริ่มต้น |
| `Palette` | table (array of Color3) | ชุดสี cyan/purple/green/yellow/red/white ในตัว | รายการสีให้เลือก |
| `Callback` | function(color: Color3) | — | เรียกเมื่อเลือกสีใหม่ |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateColorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(0, 220, 255),
    Callback = function(color)
        print(color)
    end,
})
```

### `Tab:CreateProgressBar(config)`

แถบแสดงความคืบหน้า พร้อม object สำหรับอัปเดตค่าภายหลัง

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Progress"` | หัวข้อ |
| `Min` | number | `0` | ค่าต่ำสุด |
| `Max` | number | `100` | ค่าสูงสุด |
| `Default` | number | `Min` | ค่าเริ่มต้น |

**คืนค่า:** `api` table ที่มีเมธอด

- **`api:Set(newValue)`** — อัปเดตค่า (clamp ให้อยู่ในช่วง `Min..Max` อัตโนมัติ) พร้อม tween แถบและอัปเดต % ให้

```lua
local bar = Tab:CreateProgressBar({ Title = "Loading", Max = 100, Default = 0 })
bar:Set(50) -- แถบขยับไป 50%
```

### `Window:CreateConfirm(config)`

กล่องยืนยัน/ยกเลิกแบบ overlay ทับหน้าจอทั้งหมด **ต้องเรียกหลังจากมี Window อยู่แล้ว**
(ฟังก์ชันหา ScreenGui ชื่อ `"MyUI"` ที่มีอยู่ก่อน ถ้ายังไม่มี `CreateWindow` มาก่อนจะไม่ทำอะไรและคืนค่า `nil`)

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Confirm"` | หัวข้อ |
| `Content` | string | `""` | ข้อความคำถาม/รายละเอียด |
| `ConfirmText` | string | `"Confirm"` | ข้อความปุ่มยืนยัน |
| `CancelText` | string | `"Cancel"` | ข้อความปุ่มยกเลิก |
| `OnConfirm` | function | — | เรียกเมื่อกดยืนยัน |
| `OnCancel` | function | — | เรียกเมื่อกดยกเลิก |

**คืนค่า:** `Overlay` (GuiObject) หรือ `nil` ถ้ายังไม่มี Window

```lua
Window:CreateConfirm({
    Title = "ล้างข้อมูล?",
    Content = "การกระทำนี้ไม่สามารถย้อนกลับได้",
    ConfirmText = "ลบเลย",
    CancelText = "ยกเลิก",
    OnConfirm = function() print("confirmed") end,
    OnCancel = function() print("cancelled") end,
})
```

### `Tab:CreateInfoPanel(config)`

แผงข้อมูลระบบ: ชื่อ/เวอร์ชัน executor, แพลตฟอร์ม, FPS แบบเรียลไทม์, และวันสมัคร Roblox
ของผู้เล่น (ถ้าเปิด `FetchJoinDate`)

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Executor` | string | ตรวจจับอัตโนมัติจากฟังก์ชัน `identifyexecutor` ของ executor | บังคับข้อความชื่อ executor เอง |
| `ExecutorVersion` | string | ตรวจจับอัตโนมัติ | บังคับข้อความเวอร์ชัน executor เอง |
| `FetchJoinDate` | boolean | `true` | `false` = ปิดการยิง HTTP request ไป Roblox API เพื่อดึงวันที่สมัครบัญชี |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateInfoPanel({
    FetchJoinDate = true,
})
```

### `Tab:CreateLogEntry(config)`

รายการ log พร้อมปุ่มคัดลอกข้อความ (ใช้ `setclipboard` ของ executor ถ้ามี)

| ฟิลด์ | ชนิด | คำอธิบาย |
|---|---|---|
| `Title` | string (default `"Log"`) | หัวข้อรายการ |
| `Content` | string | เนื้อหาที่แสดง |
| `CopyText` | string | ข้อความที่จะถูกคัดลอกเมื่อกดปุ่มคัดลอก (ถ้าไม่ใส่ ปุ่มคัดลอกจะไม่แสดง) |
| `Callback` | function | เรียกเมื่อกด entry (นอกเหนือจากปุ่มคัดลอก) |

**คืนค่า:** `Holder` (GuiObject)

```lua
Tab:CreateLogEntry({
    Title = "Log #1",
    Content = "รายละเอียด event",
    CopyText = "-- โค้ดที่จะคัดลอก",
})
```

---

## Features

### `Window:CreateWatermark(config)`

ป้ายลอยมุมจอ แสดงข้อความ + FPS แบบเรียลไทม์ได้ (เหมือน `CreateConfirm` ต้องมี Window
อยู่ก่อนแล้ว — ถ้ายังไม่มีจะคืนค่า `nil`)

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Text` | string | `"MyUI"` | ข้อความที่แสดง |
| `ShowFPS` | boolean | `false` | `true` = ต่อท้ายข้อความด้วย FPS ปัจจุบัน อัปเดตทุกวินาที |

**คืนค่า:** `Watermark` (GuiObject) หรือ `nil` ถ้ายังไม่มี Window

```lua
Window:CreateWatermark({ Text = "My Hub | v1.0", ShowFPS = true })
```

### `MyUI:Notify(config)`

แจ้งเตือนมุมขวาล่างของจอ หายไปเองอัตโนมัติตามเวลาที่กำหนด (ต้องมี Window อยู่ก่อนแล้วเช่นกัน)

| ฟิลด์ | ชนิด | ค่าเริ่มต้น | คำอธิบาย |
|---|---|---|---|
| `Title` | string | `"Notification"` | หัวข้อ |
| `Content` | string | `""` | เนื้อหา |
| `Type` | `"Info"` \| `"Success"` \| `"Warning"` \| `"Error"` | — | สีตามสถานะ |
| `Color` | Color3 | — | บังคับสีเอง (สำคัญกว่า `Type`) |
| `Duration` | number | `3` | วินาทีก่อนแจ้งเตือนหายไปเอง |

**คืนค่า:** `Notif` (GuiObject) หรือ `nil` ถ้ายังไม่มี Window

```lua
MyUI:Notify({
    Title = "สำเร็จ",
    Content = "บันทึกการตั้งค่าแล้ว",
    Type = "Success",
    Duration = 2,
})
```

---

## Core: Theme & Utils (สำหรับนักพัฒนาที่ fork)

ไม่ใช่ API สาธารณะสำหรับผู้ใช้ทั่วไป แต่มีประโยชน์ถ้าจะเขียน component เพิ่มเอง

**`Core/Theme.lua`** คืนค่า `{ Theme = {...}, StatusColors = {...} }`
- `Theme`: `Background`, `Secondary`, `Stroke`, `Accent`, `Accent2`, `Text`, `SubText`, `Font`, `FontBold`, `FontBlack`
- `StatusColors`: `Info`, `Success`, `Warning`, `Error` (ใช้กับ `Type` ของ `CreateLabel`/`Notify`)

**`Core/Utils.lua`** คืนค่าเป็น `function(Theme, Services) -> Utils table` ต้องเรียกใช้อีกที
(`load("Core/Utils.lua")(Theme, Services)`) มีฟังก์ชันช่วยดังนี้:

| ฟังก์ชัน | คำอธิบาย |
|---|---|
| `Utils.new(class, props, children)` | สร้าง Instance แบบสั้น พร้อมตั้ง properties และแนบลูก (เช่น corner/stroke) ในคำสั่งเดียว |
| `Utils.tween(obj, props, time, style, dir)` | ทวีนพร็อพเพอร์ตี้ (ค่าเริ่มต้น 0.2s, Quad, Out) |
| `Utils.corner(radius)` | สร้าง `UICorner` |
| `Utils.stroke(color, thickness, transparency)` | สร้าง `UIStroke` |
| `Utils.glowStroke(thickness)` | เส้นขอบเรืองแสง (gradient accent → accent2) |
| `Utils.addCornerBrackets(parent, length, thickness)` | มุมกรอบสไตล์ sci-fi ที่มุมทั้ง 4 |
| `Utils.addStripeDecor(parent, alignment)` | ลายเส้นตกแต่งซ้าย/ขวา |
| `Utils.makeDraggable(topBar, frame)` | ทำให้ `frame` ลากได้โดยจับที่ `topBar` |
| `Utils.makeDraggableButton(button, onClick)` | ปุ่มที่ลากได้ + แยกแยะจากการคลิก |
| `Utils.setIconColor(icon, color, transparency)` | ตั้งสีไอคอน (รองรับทั้ง `ImageLabel` และ `Frame`) |
| `Utils.addSubtitle(parent, text, yOffset, widthOffset)` | เพิ่มป้าย subtitle เล็กใต้หัวข้อ (ใช้ซ้ำในแทบทุก component) |

**เพิ่ม component ใหม่:** เขียนไฟล์ใหม่ในรูปแบบ
`return function(MyUI, Theme, StatusColors, Utils, Services) function MyUI:CreateXxx(config) ... end end`
วางในโฟลเดอร์ `Components/` หรือ `Features/` แล้วเพิ่ม path เข้า `MODULE_PATHS` ใน `Ui-1.lua`
ไม่ต้องแก้ไฟล์อื่น

---

## Preset Tabs ที่ผูกมากับ `CreateWindow` อัตโนมัติ

`Core/Window.lua` ในโปรเจกต์นี้ (นอกเหนือจาก `CreateWindow`/`CreateTab`/`SetScale`/`SetTheme`
ที่เป็น API หลักของไลบรารี) ยังมีฟังก์ชันเสริมที่ถูก**เรียกอัตโนมัติทุกครั้งท้าย `CreateWindow`**
เพื่อสร้างแท็บตัวอย่างสำเร็จรูป:

- `MyUI:EnableInfoTab()` — เพิ่มแท็บ "Info" (InfoPanel + label เครดิต)
- `MyUI:EnablePlayerTab()` — เพิ่มแท็บ "PLAYER" รวมตัวปรับแต่งตัวละคร/โลกเกมหลายรายการ
  (เช่น ความเร็วเดิน, การกระโดด, การชนวัตถุ, แสงในฉาก, การเทเลพอร์ตหาผู้เล่น)
- `MyUI:EnableLoopTab()` — เพิ่มแท็บ "Loop" ที่ให้ผู้ใช้กรอกโค้ด Lua เองแล้วรันซ้ำเป็นรอบๆ ได้
- `MyUI:EnableRemoteSpy()` — เพิ่มแท็บ "RSPY" ที่ดักฟัง/บันทึกการเรียก RemoteEvent/RemoteFunction ของเกม
  (ต้องใช้ `hookmetamethod`/`getnamecallmethod` ของ executor — ถ้า executor ไม่รองรับ จะแสดง label
  แจ้งเตือนแทนโดยไม่ทำให้หน้าต่างทั้งหมดพัง)

ฟังก์ชันเหล่านี้ไม่ได้อยู่ในสารบัญ API ด้านบนเพราะเป็น**เนื้อหาตัวอย่างที่ hardcode ไว้ในไฟล์
เทมเพลตนี้โดยเฉพาะ** ไม่ใช่ส่วนของไลบรารี UI ที่นำกลับมาใช้ซ้ำได้ทั่วไป — ถ้า fork ไปทำ Hub
ของตัวเองและไม่ต้องการฟีเจอร์เหล่านี้ ให้ลบการเรียก `Window:EnableInfoTab()` ฯลฯ ที่ท้าย
`CreateWindow` ใน `Core/Window.lua` ออก แล้วเขียนแท็บของตัวเองแทนโดยใช้ Component API ด้านบน

**เปิด/ปิดทีละแท็บโดยไม่ต้องแก้โค้ด** ผ่าน `PresetTabs` ใน `CreateWindow` (key ที่ใช้ได้คือ
`Info`, `Player`, `Loop`, `RSPY` — ไม่ระบุ key ไหน = เปิดแท็บนั้นตามปกติ):

```lua
local Window = MyUI:CreateWindow({
    Title = "My Hub",
    PresetTabs = {
        Loop = false,  -- ปิดแท็บ Loop
        RSPY = false,  -- ปิดแท็บ RSPY
        -- Info และ Player ไม่ระบุ = เปิดตามปกติ
    },
})
```

ฟีเจอร์บางตัวในกลุ่มนี้ (โดยเฉพาะการปรับแต่งพฤติกรรมตัวละคร/โลกเกม และการดักฟัง remote)
อาจขัดกับข้อกำหนดการใช้งานของเกมที่นำไปใช้งาน โปรดตรวจสอบก่อนใช้

---

## โครงสร้างไฟล์

```
Ui-1.lua                   <- loader หลัก (ไฟล์ที่ผู้ใช้ loadstring)
Core/
  Theme.lua                <- สีธีม + สีสถานะ
  Utils.lua                <- helper: new/tween/corner/stroke/glow/drag ฯลฯ
  Window.lua                <- CreateWindow, CreateTab, SetScale, SetTheme + preset tabs
Components/
  Button.lua
  Toggle.lua
  Slider.lua
  Dropdown.lua
  Input.lua
  Section.lua
  Paragraph.lua
  Label.lua
  Keybind.lua
  Colorpicker.lua
  ProgressBar.lua
  Confirm.lua
  InfoPanel.lua
  LogEntry.lua
Features/
  Watermark.lua
  Notify.lua
test.lua                   <- ตัวอย่างการใช้งานสั้นๆ
CHANGELOG.md                <- ประวัติการแก้ไข path/โครงสร้าง
```

ทุก path ในตารางนี้ตรงกับที่ `Ui-1.lua` เรียกผ่าน `game:HttpGet(BASE_URL .. path)` — ถ้าย้าย
หรือเปลี่ยนชื่อไฟล์ ต้องแก้ `MODULE_PATHS` ใน `Ui-1.lua` ให้ตรงกันด้วยเสมอ
