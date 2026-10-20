local root='source/hades-coop/game/scripts/'
function DeepCopyTable(t)
    if type(t)~='table' then return t end
    local r={} for k,v in pairs(t) do r[k]=DeepCopyTable(v) end return r
end
local heroes={{Health=50,MaxHealth=100},{Health=20,MaxHealth=200},{Health=0,MaxHealth=100,IsDead=true},{Health=100,MaxHealth=100}}
local players={GetPlayersCount=function() return 4 end}
function players.GetPlayerByHero(h) for i,v in ipairs(heroes) do if v==h then return i end end end
function players.GetAliveHeroes() local r={} for _,h in ipairs(heroes) do if not h.IsDead then r[#r+1]=h end end return r end
local hooks=dofile(root..'HookUtils.lua')
local context={RunWithHeroContext=function(h,f,...) local old=CurrentRun.Hero;CurrentRun.Hero=h;f(...);CurrentRun.Hero=old end}
function ModRequire(n)
    if n:match('CoopPlayers.lua$') then return players end
    if n:match('HookUtils.lua$') then return hooks end
    if n:match('HeroContext.lua$') then return context end
end
CurrentRun={Hero=heroes[1],CurrentRoom={Store={StoreOptions={{Name='Boon'},{Name='Food'},{Name='Pom'}}}}}
local live,spawnCount,baseRemovals={},0,0
function CreateTextBox() end
function CreateLoot(a) return {ObjectId=spawnCount,Name=a.Name} end
function CreateConsumableItemFromData(a) return {ObjectId=spawnCount,Name=a.Name} end
function SpawnStoreItemInWorld(data,kit)
    spawnCount=spawnCount+1
    live[kit]=(data.Name=='Food' and CreateConsumableItemFromData or CreateLoot)(data)
end
function RemoveStoreItem() baseRemovals=baseRemovals+1 end
local shop=dofile(root..'CoopShop.lua');shop.InitHooks()
local store=CurrentRun.CurrentRoom.Store
for i=1,3 do SpawnStoreItemInWorld(store.StoreOptions[i],i) end
assert(spawnCount==3)
shop.Use(heroes[1],function() end,{AttachedTable=live[1]})
assert(not store.CoopStock[1].Bought[1] and spawnCount==3)
heroes[3].IsDead=false
local purchases=0
for i=1,3 do
    for player=1,4 do
        CurrentRun.Hero=heroes[player]
        local item=live[i]
        assert(shop.CanUse(item,heroes[player]))
        shop.Use(heroes[player],function()
            RemoveStoreItem({Name=item.Name}) -- payment before boon selection
            purchases=purchases+1
        end,{AttachedTable=item})
        assert(not shop.CanUse(live[i],heroes[player]))
        if player<4 then assert(store.StoreOptions[i] and live[i]~=item) end
    end
    assert(not store.StoreOptions[i])
end
assert(purchases==12 and spawnCount==12 and baseRemovals==0)
assert(CurrentRun.CurrentRoom.StoreItemsPurchased==12)
-- A saved room retains who has bought; returning cannot refill spent stock.
CurrentRun.CurrentRoom=DeepCopyTable(CurrentRun.CurrentRoom)
assert(CurrentRun.CurrentRoom.Store.CoopStock[1].Bought[4])
shop.Use(heroes[1],function() RemoveStoreItem({}) end,{AttachedTable={}})
assert(baseRemovals==1)
function Heal(v,a)
    if v.Health==v.MaxHealth then return end
    if a.HealFraction then a.HealAmount=math.floor(v.MaxHealth*a.HealFraction) end
    v.Health=math.min(v.MaxHealth,v.Health+a.HealAmount)
    a.ActualHealAmount=a.HealAmount
end
dofile(root..'hooks/HealingHooks.lua').InitHooks()
heroes[3].IsDead=true
local args={HealFraction=0.1}
Heal(heroes[4],args) -- initiator full, others must still heal
assert(heroes[1].Health==60 and heroes[2].Health==40 and heroes[3].Health==0)
assert(args.HealAmount==nil)
Heal(heroes[1],{HealAmount=15})
assert(heroes[1].Health==75 and heroes[2].Health==55 and heroes[4].Health==100)
local enemy={Health=10,MaxHealth=50}
Heal(enemy,{HealAmount=5})
assert(enemy.Health==15 and heroes[1].Health==75)
print('PASS: 12 personal purchases, no repeat purchases, failed payment, persistent ledger, non-shop passthrough; shared flat/fraction heals, full initiator, dead allies, enemies.')
