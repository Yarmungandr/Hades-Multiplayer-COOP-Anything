local root='source/hades-coop/game/scripts/'
local hero={ObjectId=1,IsDead=true,Health=0,MaxHealth=125,Traits={{Name='Boon'}},Weapons={Sword=true},LastStands={}}
local ally={ObjectId=2,Health=30,MaxHealth=100}
local count=4
local players={GetMainHero=function() return hero end,GetPlayersCount=function() return count end,
    HasAlivePlayers=function() return not ally.IsDead end,GetAliveHeroes=function() return ally.IsDead and {} or {ally} end}
local defaultHero=ally
local context={SetDefaultHero=function(h) defaultHero=h end,
    RunWithHeroContextReturn=function(h,f) return f() end}
local restored,marker,equipped,closed=0,0,0,nil
function ModRequire(name)
    if name=='CoopPlayers.lua' then return players end
    if name=='HeroContext.lua' then return context end
    if name=='CoopCamera.lua' then return {SetHeroIgnored=function() end,ForceFocus=function() end} end
    if name=='PlayerVisibilityHelper.lua' then return {AddPlayerMarkers=function(i,id) assert(i==1 and id==1);marker=marker+1 end} end
    if name=='HeroEx.lua' then return {ShowHero=function(h,id) assert(h==hero and id==2);restored=restored+1 end} end
end
function ClearEffect(a) assert(a.Id==1) end
function GatherAndEquipWeapons() equipped=equipped+1 end
function SetHeroProperties() end
function SwitchActiveUnit(a) assert(a.PlayerIndex==1 and a.Id==1) end
function UpdateHealthUI() end
function OnMenuCloseFinished(a) assert(a[1]=='PauseScreen');closed=a[2] end
function thread(f) f() end
CurrentRun={CurrentRoom={RoomSetName='Tartarus'}}
local room=CurrentRun.CurrentRoom
local recovery=dofile(root..'EmergencyRespawn.lua')
assert(TN_CoopCanReviveP1())
assert(TN_CoopQueueReviveP1() and not TN_CoopQueueReviveP1())
assert(hero.IsDead and restored==0) -- no world mutation while paused
closed()
assert(not hero.IsDead and hero.Health==125 and defaultHero==hero)
assert(marker==1 and equipped==1 and ally.Health==30 and CurrentRun.CurrentRoom==room)
assert(hero.Traits[1].Name=='Boon' and hero.Weapons.Sword and #hero.LastStands==0)
assert(not TN_CoopCanReviveP1() and not recovery.Revive())
hero.IsDead=true;ally.IsDead=true
assert(not recovery.CanRevive())
ally.IsDead=false;count=1;assert(not recovery.CanRevive())
count=4;CurrentRun.EndingMoney=0;assert(not recovery.CanRevive())
CurrentRun.EndingMoney=nil;assert(TN_CoopQueueReviveP1())
CurrentRun.CurrentRoom={};closed();assert(hero.IsDead) -- stale request discarded
CurrentRun.CurrentRoom={RoomSetName='Surface'};assert(not recovery.CanRevive())
print('PASS manual revival: pause deferral, duplicate clicks, living teammate, full HP, build preserved, solo/wipe/end guards, room-change cancellation.')
