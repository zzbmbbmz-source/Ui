
local MyUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/zzbmbbmz-source/Ui/refs/heads/main/Ui-1.lua"))()

local Window = MyUI:CreateWindow({
    Title = HubTitle,
    SubTitle = HubSubTitle,
    Scale = 0.7,
})

return Window, MyUI
