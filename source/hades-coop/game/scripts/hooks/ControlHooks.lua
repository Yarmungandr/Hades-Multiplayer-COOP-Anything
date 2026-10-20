--
-- Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
-- Licensed under the MIT license. See LICENSE file in the project root for details.
--

---@type CoopPlayers
local CoopPlayers = ModRequire "../CoopPlayers.lua"
---@type HeroContext
local HeroContext = ModRequire "../HeroContext.lua"
---@type HookUtils
local HookUtils = ModRequire "../HookUtils.lua"
---@type GameModifed
local GameModifed = ModRequire "../GameModifed.lua"

local _OnControlPressed = OnControlPressed
OnControlPressed = function(args)
    if args[1] == "AdvancedTooltip" then
        -- override control here
        args[2] = GameModifed.AdvancedTooltipModifedHandler
    end
    _OnControlPressed {
        args[1],
        function(triggerArgs)
            local hero = CoopPlayers.GetHero(triggerArgs.mPlayerIndex)
            if hero then
                HeroContext.RunWithHeroContext(hero, args[2], triggerArgs)
            end
        end
    }
end

local function WithPlayerIndex(args, playerId)
    local copy = {}
    for key, value in pairs(args) do
        copy[key] = value
    end
    copy.PlayerIndex = playerId
    return copy
end

-- Scene/menu blocks intentionally affect everyone. Never modify the caller's
-- table: it can be reused to remove the same block later.
local function BroadcastInputBlock(baseFun, args)
    if args.PlayerIndex then
        return baseFun(args)
    else
        for playerId = 1, CoopPlayers.GetPlayersCount() do
            baseFun(WithPlayerIndex(args, playerId))
        end
    end
end

HookUtils.wrap("AddInputBlock", BroadcastInputBlock)
HookUtils.wrap("RemoveInputBlock", BroadcastInputBlock)

HookUtils.wrap("NotifyOnControlPressed", function(baseFun, argumenst)
    if argumenst.PlayerIndex then
        baseFun(argumenst)
    elseif argumenst.Notify == "FishingInput" then
        local playerId = CoopPlayers.GetPlayerByHero(CurrentRun.Hero) or 1
        baseFun(WithPlayerIndex(argumenst, playerId))
    else
        baseFun(argumenst)
    end
end)
