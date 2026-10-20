-- Based on the MIT-licensed co-op menu by Uladzislau Nikalayevich.
-- Copyright (c) Uladzislau Nikalayevich. See LICENSE.
-- Based on the MIT-licensed co-op menu by Uladzislau Nikalayevich.
-- Copyright (c) Uladzislau Nikalayevich. See LICENSE.
-- Based on the MIT-licensed co-op menu by Uladzislau Nikalayevich.
-- Copyright (c) Uladzislau Nikalayevich. See LICENSE.
-- Controller selection for one to four local/Parsec players.
local function CurrentControl()
    if GetConfigOptionValue { Name = "UseMouse" } or not GetConfigOptionValue { Name = "UseGamepadGlyphs" } then
        return { Device = "Keyboard", ControllerId = -1 }
    end
    return { Device = "Gamepad", ControllerId = CoopGetPlayerGamepad(1) }
end
local function NewMenu()
    local menu = CreateMenuScreen()
    menu:CreateBack(0.8)
    menu:CreateBackground("")
    menu:CreateTitleText()
    menu:SetLowerInputBlock(true)
    menu:CreateCancelButton(function()
        SetTempRuntimeData("Gamemode", nil)
        menu:ExitScreen()
    end)
    return menu
end
local function SelectControls(name, count)
    local menu = NewMenu()
    local selected = {}
    local message = CreateGUIComponentTextBox(menu)
    local button = CreateGUIComponentButton(menu)
    menu:AddReflection("mMessageText", message)
    menu:AddReflection("mControllerPress", button)
    local function Refresh(errorText)
        local lines = {}
        for id, control in ipairs(selected) do
            lines[#lines + 1] = "P" .. id .. ": " .. (control.Device == "Keyboard" and "Keyboard and mouse" or "Controller " .. control.ControllerId)
        end
        lines[#lines + 1] = errorText or "Each player must use a different controller."
        message:SetText(table.concat(lines, "\n"))
        button:SetText(#selected == count and "Play" or "P" .. (#selected + 1) .. ": press to assign controller")
    end
    button:AddActivationHandler(function()
        if #selected == count then
            SetTempRuntimeData("TN_Coop:control", selected)
            SetTempRuntimeData("TN_Coop:count", count)
            SetTempRuntimeData("Gamemode", count > 1 and name or nil)
            if count == 1 then
                CoopSetPlayerGamepad(1, selected[1].ControllerId)
                SetConfigOption { Name = "UseMouse", Value = selected[1].Device == "Keyboard" }
            end
            MainMenuOpenProfiles()
            return
        end
        local control = CurrentControl()
        if control.Device == "Keyboard" and #selected > 0 then
            Refresh("Only P1 can use keyboard and mouse.")
            return
        end
        if control.Device == "Gamepad" and (control.ControllerId < 0 or control.ControllerId > 3) then
            Refresh("Controller unavailable. Connect it and try again.")
            return
        end
        for _, previous in ipairs(selected) do
            if previous.Device == control.Device and previous.ControllerId == control.ControllerId then
                Refresh("This controller is already assigned to another player.")
                return
            end
        end
        selected[#selected + 1] = control
        Refresh()
    end)
    Refresh()
    menu:LoadDefenitions("../Mods/TN_CoopMod/ControllerSelectionMenuScreen.sjson")
end
MainMenuAPIAddGamemode("Coop", function(name)
    SetConfigOption { Name = "AllowControlHotSwap", Value = true }
    local menu = NewMenu()
    local message = CreateGUIComponentTextBox(menu)
    message:SetText("Co-op v3 - How many players?")
    menu:AddReflection("mMessageText", message)
    for count = 1, 4 do
        local playerCount = count
        local button = CreateGUIComponentButton(menu)
        button:SetText(count == 1 and "1 player" or count .. " players")
        button:AddActivationHandler(function()
            if playerCount > (CoopGetMaxPlayers and CoopGetMaxPlayers() or 2) then
                message:SetText("The installed DLL does not support this player count.")
                return
            end
            menu:ExitScreen()
            SelectControls(name, playerCount)
        end)
        menu:AddReflection("mPlayerCount" .. count, button)
    end
    menu:LoadDefenitions("../Mods/TN_CoopMod/PlayerCountMenuScreen.sjson")
end)
