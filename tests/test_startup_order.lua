-- Model the loader's observed sequence: mod init BEFORE Main.lua, then
-- first OnPreThingCreation after the stock Lua functions are defined.
local root = "source/hades-coop/game/scripts/"
local hooks = dofile(root .. "HookUtils.lua")
local cache, loaded = {}, {}
local noop = function() end
local heroes = {{Health=50,MaxHealth=100},{Health=10,MaxHealth=100}}
local players = {
    CoopInit=noop,
    GetPlayersCount=function() return 4 end,
    GetPlayerByHero=function(h) for i,v in ipairs(heroes) do if v==h then return i end end end,
    GetAliveHeroes=function() return heroes end,
}
local context = {
    IsHeroContextExplicit=function() return false end,
    RunWithHeroContext=function(h,f,...) return f(...) end,
}
local real = {["hooks/CooldownHooks.lua"]=true,["hooks/HealingHooks.lua"]=true,["hooks/MoneyHooks.lua"]=true}
function ModRequire(path)
    path=path:gsub("^%.%./","")
    if path=="HookUtils.lua" then return hooks end
    if path=="CoopPlayers.lua" then return players end
    if path=="HeroContext.lua" then return context end
    if real[path] then
        if not cache[path] then
            local _, main = coroutine.running()
            assert(main, "Loader cannot first-load a module from a gameplay coroutine")
            loaded[path]=(loaded[path] or 0)+1
            cache[path]=dofile(root..path) or true
        end
        return cache[path]
    end
    return {InitHooks=noop}
end
local firstThing
function OnPreThingCreation(args) firstThing=args[1] end
OnAnyLoad=noop; OnMenuOpened=noop
assert(Heal==nil and AddMoney==nil and CheckCooldown==nil)
dofile(root.."GamemodeInit.lua")
assert(Heal==nil and AddMoney==nil and CheckCooldown==nil, "Gameplay wrappers installed before Main.lua")
for path in pairs(real) do assert(loaded[path]==1, "Module must preload on main Lua state") end
-- These functions become available only when the game loads its scripts.
function round(n) return math.floor(n+0.5) end
function DeepCopyTable(t) local r={} for k,v in pairs(t) do r[k]=v end return r end
local money=0
function AddMoney(n) money=money+n end
function Heal(h,a) h.Health=math.min(h.MaxHealth,h.Health+a.HealAmount) end
function CheckCooldown(n) return n end
CheckCooldownNoTrigger=CheckCooldown; TriggerCooldown=CheckCooldown; CheckCountInWindow=CheckCooldown
local function enterWorld()
    local ok,err=coroutine.resume(coroutine.create(firstThing))
    assert(ok,err)
end
enterWorld()
local wrappedMoney=AddMoney
enterWorld()
assert(wrappedMoney==AddMoney, "Initialization installed the wrappers twice")
for path in pairs(real) do assert(loaded[path]==1,path) end
AddMoney(100,"Drop")
assert(money==800,"Gold multiplier did not survive startup")
Heal(heroes[1],{HealAmount=10})
assert(heroes[1].Health==60 and heroes[2].Health==20,"Team healing not active after startup")
assert(CheckCooldown("Encounter")=="Encounter")
print("PASS loader order: no Lua gameplay hooks before Main; first-world-object init installs money/healing/cooldowns once; 100 -> 800 and team heal active.")
