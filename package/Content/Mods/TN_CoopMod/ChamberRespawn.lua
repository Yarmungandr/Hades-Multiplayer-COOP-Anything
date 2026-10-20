-- Local extension for TheNormalnij's HadesCoopMod v0.4.3.
-- Revive existing heroes through the normal next-room setup, preserving builds.
local CoopPlayers = ModRequire "CoopPlayers.lua"
local HeroContext = ModRequire "HeroContext.lua"
local CoopCamera = ModRequire "CoopCamera.lua"
local Config = ModRequire "config.lua"

local ChamberRespawn = {}

function ChamberRespawn.Queue(run, door)
    local nextRoom = door and door.Room
    if not Config.RespawnAtNextChamber or not nextRoom or not run.CurrentRoom
        or run.EndingMoney ~= nil or run.CurrentRoom.SkipLoadNextMap
        or nextRoom == run.CurrentRoom or nextRoom.RoomSetName == "Surface"
        or CoopPlayers.GetPlayersCount() < 2 or not CoopPlayers.HasAlivePlayers() then
        return
    end

    -- Store only player indices on the destination room. This survives a
    -- transition checkpoint without reviving on a reload of the death chamber.
    local pending = {}
    for playerId, hero in CoopPlayers.PlayersIterator() do
        if hero.IsDead then
            pending[playerId] = true
        end
    end
    nextRoom.CoopChamberRespawn = next(pending) and pending or nil
end

function ChamberRespawn.Apply(run, room)
    local pending = room.CoopChamberRespawn
    room.CoopChamberRespawn = nil
    if not pending or not Config.RespawnAtNextChamber or run.EndingMoney ~= nil
        or room.RoomSetName == "Surface" or CoopPlayers.GetPlayersCount() < 2
        or not CoopPlayers.HasAlivePlayers() then
        return
    end

    local fraction = tonumber(Config.ChamberRespawnHealthFraction) or 1
    fraction = math.max(0, math.min(1, fraction))
    for playerId, hero in CoopPlayers.PlayersIterator() do
        if pending[playerId] and hero.IsDead then
            hero.Health = math.max(1, math.ceil((hero.MaxHealth or 50) * fraction))
            hero.IsDead = false
            CoopCamera.SetHeroIgnored(hero, false)
            if playerId == 1 then
                HeroContext.SetDefaultHero(hero)
            end
            -- StartRoom's existing SetupHeroObject / InitCoopUnit paths restore
            -- weapons, input, status effects, visibility and the second unit.
        end
    end
end

return ChamberRespawn
