--
-- Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
-- Licensed under the MIT license. See LICENSE file in the project root for details.
--

---@type SecondPlayerUi
local SecondPlayerUi = ModRequire "../SecondPlayerUI.lua"
---@type CombinedTraitsUI
local CombinedTraitsUI = ModRequire "../CombinedTraitsUI.lua"
---@type CoopPlayers
local CoopPlayers = ModRequire "../CoopPlayers.lua"
---@type HeroContext
local HeroContext = ModRequire "../HeroContext.lua"
---@type HookUtils
local HookUtils = ModRequire "../HookUtils.lua"
---@type RunEx
local RunEx = ModRequire "../RunEx.lua"

---@class UIHooks
local UIHooks = {}

---@private
---@param hero table?
function UIHooks.ShouldBeUiVisibleFor(hero)
    return hero and (RunEx.IsRunEnded() or not hero.IsDead)
end

---@private
---@param funcName string
function UIHooks.CreateSimpleHook(funcName)
    local orig = _G[funcName]
    _G[funcName] = function(...)
        local mainHero = CoopPlayers.GetMainHero()
        HeroContext.RunWithHeroContext(mainHero, orig, ...)
        SecondPlayerUi.ForEach(funcName, ...)
    end
end

---@private
---@param funcName string
function UIHooks.SimpleHookWithVisibilityCheck(funcName)
    local orig = _G[funcName]
    _G[funcName] = function(...)
        local mainHero = CoopPlayers.GetMainHero()
        if UIHooks.ShouldBeUiVisibleFor(mainHero) then
            HeroContext.RunWithHeroContext(mainHero, orig, ...)
        end
        for playerId = 2, CoopPlayers.GetPlayersCount() do
            local hero = CoopPlayers.GetHero(playerId)
            if UIHooks.ShouldBeUiVisibleFor(hero) then
                HeroContext.RunWithHeroContext(hero, SecondPlayerUi.ForPlayer(playerId)[funcName], ...)
            end
        end
    end
end

---@private
function UIHooks.SimpleCurrentTraitWrapper(funcName)
    HookUtils.wrap(funcName, function(baseFun, ...)
        HeroContext.RunWithHeroContext(CombinedTraitsUI.GetCurrentTraitHero(), baseFun, ...)
    end)
end

function UIHooks.InitHooks()
    -- Health
    UIHooks.SimpleHookWithVisibilityCheck("ShowHealthUI")

    UIHooks.CreateSimpleHook("UpdateHealthUI")
    HookUtils.onPostFunction("DestroyHealthUI", function() SecondPlayerUi.ForEach("DestroyHealthUI") end)
    HookUtils.onPreFunction("HideHealthUI", function()
        thread(function() SecondPlayerUi.ForEach("HideHealthUI") end)
    end)
    HookUtils.onPostFunction("UpdateRallyHealthUI", SecondPlayerUi.UpdateRallyHealthUI)

    -- LifePipIds
    UIHooks.CreateSimpleHook("RecreateLifePips")

    HookUtils.wrap("UpdateLifePips", function(basefun, unit)
        local mainHero = CoopPlayers.GetMainHero()
        if not mainHero or not unit or mainHero == unit then
            basefun(mainHero)
        end
        if unit and unit ~= mainHero and CoopPlayers.IsPlayerHero(unit) then
            HeroContext.RunWithHeroContext(unit, SecondPlayerUi.UpdateLifePips)
        elseif not unit then
            SecondPlayerUi.ForEach("UpdateLifePips")
        end
    end)

    local _AddLastStand = AddLastStand
    AddLastStand = function(args)
        local isSecondPlayer = CoopPlayers.GetMainHero() ~= HeroContext.GetCurrentHeroContext()
        local pipsBackup = ScreenAnchors.LifePipIds
        local _CreateScreenObstacle = CreateScreenObstacle
        if isSecondPlayer then
            ScreenAnchors.LifePipIds = SecondPlayerUi.ScreenAnchors.LifePipIds
            CreateScreenObstacle = function(args)
                local adjusted = ShallowCopyTable(args)
                adjusted.X = (ScreenWidth - 80) - (args.X - 70)
                adjusted.Y = args.Y - ((SecondPlayerUi.CurrentPlayerId() or 2) - 2) * 160
                return _CreateScreenObstacle(adjusted)
            end
        end

        _AddLastStand(args)

        if isSecondPlayer then
            ScreenAnchors.LifePipIds = pipsBackup
            CreateScreenObstacle = _CreateScreenObstacle
        end
    end

    -- Ammo (red crystrals)
    UIHooks.SimpleHookWithVisibilityCheck("ShowAmmoUI")
    HookUtils.onPreFunction("HideAmmoUI", function() thread(function() SecondPlayerUi.ForEach("HideAmmoUI") end) end)
    HookUtils.onPreFunction("DestroyAmmoUI", function() SecondPlayerUi.ForEach("DestroyAmmoUI") end)

    HookUtils.wrap("StartAmmoReloadPresentation", function(baseFun, delay)
        if CoopPlayers.GetMainHero() == HeroContext.GetCurrentHeroContext() then
            baseFun(delay)
        else
            SecondPlayerUi.StartAmmoReloadPresentation(delay)
        end
    end)

    HookUtils.wrap("EndAmmoReloadPresentation", function(baseFun)
        if CoopPlayers.GetMainHero() == HeroContext.GetCurrentHeroContext() then
            baseFun()
        else
            SecondPlayerUi.EndAmmoReloadPresentation()
        end
    end)

    local _UpdateAmmoUI = UpdateAmmoUI
    UpdateAmmoUI = function()
        local mainHero = CoopPlayers.GetMainHero()
        if HeroContext.IsHeroContextExplicit() then
            if HeroContext.GetCurrentHeroContext() == mainHero then
                _UpdateAmmoUI()
            else
                SecondPlayerUi.UpdateAmmoUI()
            end
        else
            HeroContext.RunWithHeroContext(mainHero, function()
                _UpdateAmmoUI()
                SecondPlayerUi.UpdateAmmoUI()
            end)
        end
    end

    HookUtils.wrap("AddAmmoPresentation", function(baseFun, ...)
        if CoopPlayers.IsPlayerHero(CurrentRun.Hero) and CurrentRun.Hero ~= CoopPlayers.GetMainHero() then
            thread(SecondPlayerUi.UpdateAmmoUI)

            CreateAnimation({ Name = "QuickFlashRedSmall", DestinationId = CurrentRun.Hero.ObjectId, OffsetZ = -90 })

            if SecondPlayerUi.ScreenAnchors.AmmoIndicatorUI ~= nil then
                ModifyTextBox({ Id = SecondPlayerUi.ScreenAnchors.AmmoIndicatorUI, ColorTarget = Color.White, ColorDuration = 0.5, AutoSetDataProperties = false, })
                thread(PulseText,
                    { ScreenAnchorReference = "AmmoIndicatorUI", ScaleTarget = 1.3, ScaleDuration = 0.125, HoldDuration = 0.1, PulseBias = 0.2 })
            end
        else
            baseFun(...);
        end
    end)

    -- Gun
    local _ShowGunUI = ShowGunUI
    UIHooks.SimpleHookWithVisibilityCheck("ShowGunUI")

    local _HideGunUI = HideGunUI
    HideGunUI = function()
        local mainHero = CoopPlayers.GetMainHero()
        HeroContext.RunWithHeroContext(mainHero, _HideGunUI)
        SecondPlayerUi.ForEach("HideGunUI")
    end

    local _UpdateGunUI = UpdateGunUI
    UpdateGunUI = function()
        local mainHero = CoopPlayers.GetMainHero()

        if HeroContext.IsHeroContextExplicit() then
            local currentHero = HeroContext.GetCurrentHeroContext()
            if mainHero == currentHero then
                HeroContext.RunWithHeroContext(mainHero, _UpdateGunUI)
            elseif CoopPlayers.IsPlayerHero(currentHero) then
                HeroContext.RunWithHeroContext(currentHero, SecondPlayerUi.UpdateGunUI)
            end
        else
            HeroContext.RunWithHeroContext(mainHero, _UpdateGunUI)
            SecondPlayerUi.ForEach("UpdateGunUI")
        end
    end

    EquipPlayerWeaponPresentation = function(weaponData, args)
        wait(0.02)
        -- TODO: Fix hero here, maybe
        PlaySound({ Name = "/SFX/Menu Sounds/WeaponEquipChunk", Id = CurrentRun.Hero.ObjectId })
        if not args.SkipEquipLines then
            thread(PlayVoiceLines, weaponData.EquipVoiceLines, false)
        end

        local function hasHeroWeaponWithIcon(hero)
            for weaponName in pairs(hero.Weapons) do
                if WeaponData[weaponName].ActiveReloadTime then
                    return true
                end
            end
            return false
        end

        for playerId = 1, CoopPlayers.GetPlayersCount() do
            local hero = CoopPlayers.GetHero(playerId)
            if hero then
                local ui = playerId > 1 and SecondPlayerUi.ForPlayer(playerId)
                local show = ui and ui.ShowGunUI or _ShowGunUI
                local hide = ui and ui.HideGunUI or _HideGunUI
                local execFun = hasHeroWeaponWithIcon(hero) and show or hide
                thread(function() HeroContext.RunWithHeroContext(hero, execFun) end)
            end
        end
    end

    HookUtils.onPostFunction("DestroyGunUI", function() SecondPlayerUi.ForEach("DestroyGunUI") end)

    -- Super meter (God aid)
    UIHooks.SimpleHookWithVisibilityCheck("ShowSuperMeter")
    UIHooks.SimpleHookWithVisibilityCheck("UpdateSuperMeterUIReal")
    UIHooks.CreateSimpleHook("DestroySuperMeter")
    UIHooks.CreateSimpleHook("HideSuperMeter")

    local _UpdateSuperUIComponent = UpdateSuperUIComponent
    UpdateSuperUIComponent = function(...)
        local mainHero = CoopPlayers.GetMainHero()
        if not SecondPlayerUi.CurrentPlayerId() and ScreenAnchors.SuperPipBackingIds then
            HeroContext.RunWithHeroContext(mainHero, _UpdateSuperUIComponent, ...)
        end
        -- A component fill belongs to the current hero, never to another meter.
        local playerId = SecondPlayerUi.CurrentPlayerId()
        if playerId then
            local ui = SecondPlayerUi.ForPlayer(playerId)
            if ui.ScreenAnchors.SuperPipBackingIds then ui.UpdateSuperUIComponent(...) end
        end
    end

    -- Traits
    HookUtils.onPreFunction("ShowAdvancedTooltip", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUIActivateTrait", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUIDeactivateTrait", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUICreateComponent", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUIUpdateText", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUIRemove", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUICreateText", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("UpdateTraitNumber", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("UpdateAdditionalTraitHint", CombinedTraitsUI.ChangeHeroInTraitsMenu)
    HookUtils.onPreFunction("TraitUIActivateTraits", CombinedTraitsUI.ChangeHeroInTraitsMenu)

    UIHooks.SimpleCurrentTraitWrapper("CloseAdvancedTooltipScreen")
    UIHooks.SimpleCurrentTraitWrapper("PinTraitDetails")

    -- Etc
    local _PulseText = PulseText
    PulseText = function(args)
        if args.ScreenAnchorReference and SecondPlayerUi.CurrentPlayerId() ~= nil then
            local idOnSecond = SecondPlayerUi.ScreenAnchors[args.ScreenAnchorReference]
            if idOnSecond then
                args.Id = idOnSecond
            end
        end

        _PulseText(args)
    end

    HookUtils.onPostFunction("ShowUseButton", function(objectId, useTarget)
        if HeroContext.GetDefaultHero() ~= HeroContext.GetCurrentHeroContext() then
            Move({ Id = ScreenAnchors.UsePrompts[objectId], DestinationId = ScreenAnchors.UsePrompts[objectId], OffsetY = -50 })
        end
    end)
end

return UIHooks