local heroes = {{}, {}, {}, {}}
local players = {}
function players.GetHero(i) return heroes[i] end
function players.GetPlayerByHero(hero)
    for i,h in ipairs(heroes) do if h == hero then return i end end
end
function players.GetAliveHeroes()
    local out = {}
    for _,h in ipairs(heroes) do if not h.IsDead then out[#out+1]=h end end
    return out
end
function players.HasAlivePlayers() return #players.GetAliveHeroes()>0 end
function ModRequire(name)
    if name:match('CoopPlayers.lua$') then return players end
    if name:match('config.lua$') then return {RoomDuplicatedDelivery={}} end
    if name:match('HeroContext.lua$') then
        return {RunWithHeroContext=function(h,f) f() end}
    end
    if name:match('RunEx.lua$') then
        return {IsFinalBossDoor=function() return false end,
            IsDoorSpecial=function() return false end,
            RemoveRewardFromAllDefaultDoors=function() end}
    end
    return {}
end
CurrentRun={Hero=heroes[2]}
local loot=dofile('source/hades-coop/game/scripts/loot/LootRoomDuplicated.lua')
local reward={CoopChoosenPlayer=1}
assert(not loot.CanUseHeroLoot(reward,heroes[2]))
assert(loot.CanUseHeroLoot(reward,heroes[1]))
heroes[1].IsDead=true
for i=2,4 do assert(loot.CanUseHeroLoot(reward,heroes[i])) end
assert(not loot.CanUseHeroLoot(reward,heroes[1]))
assert(not loot.CanUseHeroLoot(reward,nil))
assert(not loot.CanUseHeroLoot({CoopChoosenPlayer=3},heroes[2]))
loot.CurrentHeroChooser=heroes[1]
assert(loot.CheckSpecialDoorRequirementWrap(function() end,{})==nil)
assert(loot.CurrentHeroChooser==heroes[2])
CurrentRun.Hero=heroes[3]
assert(loot.CheckSpecialDoorRequirementWrap(function() end,{})=='ExitNotActive')
loot.RewardChoiseInProgress=true
loot.ChosenPlayerLoot={[2]={rewardType='Boon'}}
heroes[2].IsDead=true
loot.RefreshLivingChooser()
assert(loot.CurrentHeroChooser==heroes[3])
heroes[3].IsDead=true
loot.RefreshLivingChooser()
assert(loot.CurrentHeroChooser==heroes[4])
heroes[1].IsDead=false
assert(not loot.CanUseHeroLoot(reward,heroes[4]))
print('Survivor loot regression: 14 assertions passed (mocked engine).')
