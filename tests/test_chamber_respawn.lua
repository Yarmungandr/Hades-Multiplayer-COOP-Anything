local root = 'source/hades-coop/game/scripts/'
local heroes, config, run, nextRoom, defaultHero, ignored, count, post, created
local players = {}
function players.GetPlayersCount() return count end
function players.PlayersIterator() return ipairs(heroes) end
function players.GetMainHero() return heroes[1] end
function players.GetHero(i) return heroes[i] end
function players.HasAlivePlayers()
    for _, hero in ipairs(heroes) do if not hero.IsDead then return true end end
    return false
end
function players.GetAliveHeroes()
    local result = {}
    for _, hero in ipairs(heroes) do if not hero.IsDead then result[#result + 1] = hero end end
    return result
end
function players.UpdateMainHero() end
function players.InitCoopUnit(i) created[i] = true end
local context = {
    GetDefaultHero = function() return defaultHero end,
    SetDefaultHero = function(h) defaultHero = h end,
    RunWithHeroContext = function(h, f, ...) return f(...) end,
}
local flags = {LeaveRoomHandlesOnce = false}
local modules = {
    ['CoopPlayers.lua'] = players,
    ['HeroContext.lua'] = context,
    ['CoopCamera.lua'] = {
        SetHeroIgnored = function(h, value) ignored[h] = value end,
        ForceFocus = function() end,
    },
    ['CoopControl.lua'] = {ResetAllPlayers = function() end},
    ['HookUtils.lua'] = {onPostFunctionOnce = function(name, f) post[name] = f end},
    ['RunEx.lua'] = {IsRunEnded = function() return run.EndingMoney ~= nil end},
    ['SecondPlayerUI.lua'] = {Refresh = function() end},
    ['GameFlags.lua'] = flags,
}
function ModRequire(path)
    local name = path:gsub('^%.%./', '')
    if name == 'config.lua' then return config end
    return modules[name] or {}
end
config = {RespawnAtNextChamber = true, ChamberRespawnHealthFraction = 1}
local respawn = dofile(root .. 'ChamberRespawn.lua')
modules['ChamberRespawn.lua'] = respawn
local hooks = dofile(root .. 'hooks/RunHooks.lua')
function GetPreviousRoom() return nil end
function SetAlpha() end
function SwitchActiveUnit() end

local function reset(deadPlayer)
    config.RespawnAtNextChamber = true
    config.ChamberRespawnHealthFraction = 1
    count, post, created, ignored = 2, {}, {}, {}
    heroes = {
        {ObjectId=1, Health=37, MaxHealth=100, Traits={test=true}, Weapons={Sword=true}, LastStands={}},
        {ObjectId=2, Health=29, MaxHealth=80, Traits={test=true}, Weapons={Bow=true}, LastStands={}},
    }
    if deadPlayer then heroes[deadPlayer].IsDead = true; heroes[deadPlayer].Health = 0 end
    defaultHero = heroes[1].IsDead and heroes[2] or heroes[1]
    run = {CurrentRoom={Name='A', Encounter={Name='Combat'}}}
    CurrentRun = run
    nextRoom = {Name='B', RoomSetName='Tartarus', Encounter={Name='Combat'}}
end
local passed = 0
local function test(name, f)
    f()
    passed = passed + 1
    print('PASS ' .. name)
end
for deadPlayer = 1, 2 do
    test('player ' .. deadPlayer .. ' revives through room-entry hook with build intact', function()
        reset(deadPlayer)
        local dead = heroes[deadPlayer]
        local traits, weapons, stands = dead.Traits, dead.Weapons, dead.LastStands
        local survivor = heroes[3-deadPlayer]
        local survivorHealth = survivor.Health
        hooks.LeaveRoomHook(run, {Room=nextRoom})
        assert(dead.IsDead and dead.Health == 0, 'must stay dead until next room')
        run.CurrentRoom = nextRoom
        hooks.StartRoomWrapHook(function()
            assert(not dead.IsDead and dead.Health == dead.MaxHealth, 'revive before vanilla setup')
            post.RoomEntranceStandard()
        end, run, nextRoom)
        assert(created[2], 'normal entry must recreate P2 unit')
        assert(dead.Traits == traits and dead.Weapons == weapons and dead.LastStands == stands)
        assert(survivor.Health == survivorHealth, 'must not heal survivor')
        assert(defaultHero == heroes[1], 'main context must return to P1')
        assert(ignored[dead] == false)
        assert(nextRoom.CoopChamberRespawn == nil)
    end)
end
test('team wipe does not queue a revival', function()
    reset(1); heroes[2].IsDead = true
    respawn.Queue(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
end)
test('team wipe after queue does not revive either player', function()
    reset(1); respawn.Queue(run, {Room=nextRoom}); heroes[2].IsDead = true
    respawn.Apply(run, nextRoom); assert(heroes[1].IsDead and heroes[2].IsDead)
end)
test('duplicate loot selection waits for actual map transition', function()
    reset(2); run.CurrentRoom.SkipLoadNextMap = true
    hooks.LeaveRoomHook(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
    run.CurrentRoom.SkipLoadNextMap = false
    hooks.LeaveRoomHook(run, {Room=nextRoom}); assert(nextRoom.CoopChamberRespawn[2])
end)
test('reloading death room does not revive', function()
    reset(1); respawn.Queue(run, {Room=nextRoom})
    respawn.Apply(run, run.CurrentRoom); assert(heroes[1].IsDead)
end)
test('serialized destination checkpoint retains revival', function()
    reset(2); respawn.Queue(run, {Room=nextRoom})
    local restoredRoom = {Name='B', CoopChamberRespawn={[2]=true}}
    respawn.Apply(run, restoredRoom); assert(not heroes[2].IsDead)
end)
test('same room revisit cannot revive twice', function()
    reset(2); respawn.Queue(run, {Room=nextRoom}); respawn.Apply(run, nextRoom)
    heroes[2].IsDead = true; heroes[2].Health = 0
    respawn.Apply(run, nextRoom); assert(heroes[2].IsDead)
end)
test('later death can revive in another chamber', function()
    reset(1); respawn.Queue(run, {Room=nextRoom}); respawn.Apply(run, nextRoom)
    heroes[1].IsDead = true; heroes[1].Health = 0; run.CurrentRoom = nextRoom
    local thirdRoom = {Name='C'}
    respawn.Queue(run, {Room=thirdRoom}); respawn.Apply(run, thirdRoom)
    assert(not heroes[1].IsDead)
end)
test('ended run, surface ending and solo do not queue', function()
    reset(2); run.EndingMoney = 0
    respawn.Queue(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
    reset(2); nextRoom.RoomSetName = 'Surface'
    respawn.Queue(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
    reset(2); count = 1
    respawn.Queue(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
end)
test('disabled setting cancels even queued revival', function()
    reset(2); respawn.Queue(run, {Room=nextRoom}); config.RespawnAtNextChamber = false
    respawn.Apply(run, nextRoom); assert(heroes[2].IsDead)
    respawn.Queue(run, {Room=nextRoom}); assert(not nextRoom.CoopChamberRespawn)
end)
test('healthy party is unchanged', function()
    reset(); respawn.Queue(run, {Room=nextRoom}); respawn.Apply(run, nextRoom)
    assert(heroes[1].Health == 37 and heroes[2].Health == 29)
end)
test('health fraction has safe minimum and maximum', function()
    for _, value in ipairs({0, 0.5, 2}) do
        reset(2); config.ChamberRespawnHealthFraction = value
        respawn.Queue(run, {Room=nextRoom}); respawn.Apply(run, nextRoom)
        assert(heroes[2].Health == math.max(1, math.ceil(80 * math.min(1, value))))
    end
end)
test('four players: three dead revive and survivor remains unchanged', function()
    reset(1); count = 4
    heroes[2].IsDead = true; heroes[2].Health = 0
    heroes[3] = {IsDead = true, Health = 0, MaxHealth = 90}
    heroes[4] = {IsDead = false, Health = 17, MaxHealth = 100}
    defaultHero = heroes[4]
    respawn.Queue(run, {Room=nextRoom})
    assert(nextRoom.CoopChamberRespawn[1] and nextRoom.CoopChamberRespawn[2] and nextRoom.CoopChamberRespawn[3])
    respawn.Apply(run, nextRoom)
    for i=1,3 do assert(not heroes[i].IsDead and heroes[i].Health==heroes[i].MaxHealth) end
    assert(heroes[4].Health==17 and defaultHero==heroes[1])
end)
test('four-player wipe never revives', function()
    reset(1); count=4; heroes[2].IsDead=true
    heroes[3]={IsDead=true,Health=0,MaxHealth=90}; heroes[4]={IsDead=true,Health=0,MaxHealth=90}
    respawn.Queue(run, {Room=nextRoom});assert(not nextRoom.CoopChamberRespawn)
end)
print(string.format('%d tests passed; engine calls stubbed, no gameplay claimed.', passed))
