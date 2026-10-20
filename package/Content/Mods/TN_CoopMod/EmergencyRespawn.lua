-- Opt-in recovery from the native pause menu; never restarts the chamber.
local Players = ModRequire "CoopPlayers.lua"
local Context = ModRequire "HeroContext.lua"
local Camera = ModRequire "CoopCamera.lua"
local Visibility = ModRequire "PlayerVisibilityHelper.lua"
local HeroEx = ModRequire "HeroEx.lua"
local Recovery = {}
local pendingRoom

function Recovery.CanRevive()
    local run = CurrentRun
    local hero = Players.GetMainHero()
    return run ~= nil and run.CurrentRoom ~= nil and run.EndingMoney == nil
        and run.CurrentRoom.RoomSetName ~= "Surface"
        and Players.GetPlayersCount() > 1 and hero ~= nil and hero.IsDead == true
        and hero.ObjectId ~= nil and Players.HasAlivePlayers()
end

function Recovery.Revive()
    if not Recovery.CanRevive() then return false end
    local hero = Players.GetMainHero()
    local survivor = Players.GetAliveHeroes()[1]
    if not survivor or not survivor.ObjectId then return false end
    return Context.RunWithHeroContextReturn(hero, function()
        hero.Health = hero.MaxHealth
        hero.IsDead = false
        hero.HandlingDeath = false
        hero.BlockStatusAnimations = false
        hero.Reloading = false
        hero.Frozen = false
        hero.Mute = false
        ClearEffect({ Id = hero.ObjectId, All = true })
        HeroEx.ShowHero(hero, survivor.ObjectId)
        -- HideHero unequips weapons but retains the hero and its build.
        -- Do not run full room setup: it advances trait timers and resets flags.
        GatherAndEquipWeapons(CurrentRun)
        SetHeroProperties(CurrentRun)
        SwitchActiveUnit({ PlayerIndex = 1, Id = hero.ObjectId })
        Context.SetDefaultHero(hero)
        Camera.SetHeroIgnored(hero, false)
        Camera.ForceFocus(true)
        Visibility.AddPlayerMarkers(1, hero.ObjectId)
        UpdateHealthUI()
        return true
    end)
end

function TN_CoopCanReviveP1()
    return Recovery.CanRevive()
end

function TN_CoopQueueReviveP1()
    if pendingRoom or not Recovery.CanRevive() then return false end
    pendingRoom = CurrentRun.CurrentRoom
    return true
end

OnMenuCloseFinished { "PauseScreen", function()
    local room = pendingRoom
    pendingRoom = nil
    if room and CurrentRun and CurrentRun.CurrentRoom == room then
        thread(Recovery.Revive)
    end
end }

return Recovery
