-- Compatibility facade: each additional hero owns an independent HUD.
local CreatePlayerUI = ModRequire "AdditionalPlayerUI.lua"
local CoopPlayers = ModRequire "CoopPlayers.lua"
local HeroContext = ModRequire "HeroContext.lua"
local UI = {}
local instances = {}

function UI.ForPlayer(playerId)
    assert(playerId >= 2 and playerId <= 4, "Additional HUD player out of range")
    if not instances[playerId] then instances[playerId] = CreatePlayerUI(playerId) end
    return instances[playerId]
end

function UI.CurrentPlayerId()
    local hero = HeroContext.GetCurrentHeroContext()
    for playerId = 2, CoopPlayers.GetPlayersCount() do
        if hero and hero == CoopPlayers.GetHero(playerId) then return playerId end
    end
end

function UI.ForEach(funcName, ...)
    for playerId = 2, CoopPlayers.GetPlayersCount() do
        local hero = CoopPlayers.GetHero(playerId)
        if hero then
            HeroContext.RunWithHeroContext(hero, UI.ForPlayer(playerId)[funcName], ...)
        end
    end
end

function UI.Refresh()
    UI.ForEach("Refresh")
end

return setmetatable(UI, { __index = function(_, key)
    if key == "ScreenAnchors" then
        return UI.ForPlayer(UI.CurrentPlayerId() or 2).ScreenAnchors
    end
    local method = function(...)
        local playerId = UI.CurrentPlayerId()
        if playerId then
            return UI.ForPlayer(playerId)[key](...)
        end
        return UI.ForEach(key, ...)
    end
    rawset(UI, key, method)
    return method
end })
