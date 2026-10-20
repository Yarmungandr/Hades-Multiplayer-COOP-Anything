
function round(x) return math.floor(x+0.5) end
function noop() end
PlaySound=noop; ShowResourceUIs=noop; UpdateMoneyUI=noop; CreateAnimation=noop
function thread(f,...) f(...) end
local blocked=false
function HasHeroTraitValue() return blocked end
CurrentRun={Money=10,MoneySpent=0,MoneyRecord={},CurrentRoom={},Hero={ObjectId=1}}
GameState={LifetimeResourcesGained={},LifetimeResourcesSpent={}}
function ModRequire(name)
    if name:match("CoopPlayers.lua$") then
        return { GetPlayersCount = function() return 1 end }
    end
    return dofile('source/hades-coop/game/scripts/HookUtils.lua')
end
function AddMoney( amount, source )

	if amount == nil or round( amount ) <= 0 then
		return
	end
	amount = round( amount )

	if CurrentRun.Money == nil then
		CurrentRun.Money = 0
	end
	local sound = "/SFX/GoldCoinPickup"
	if HasHeroTraitValue("BlockMoney") then
		amount = 0
		sound = "/SFX/Player Sounds/DarknessCollectionPickupSMALL"
	end
	
	if not CurrentRun.CurrentRoom.HideGoldGainFx then
		PlaySound({ Name = sound, ManagerCap = 28 })
	end

	CurrentRun.Money = CurrentRun.Money + amount
	CurrentRun.MoneyRecord[source] = (CurrentRun.MoneyRecord[source] or 0) + amount
	GameState.LifetimeResourcesGained.Money = (GameState.LifetimeResourcesGained.Money or 0) + amount
	ShowResourceUIs({ CombatOnly = not CurrentRun.Hero.IsDead, UpdateIfShowing = true })
	UpdateMoneyUI( CurrentRun.Money )
end

function SpendMoney( amount, source )

	if amount == nil or amount <= 0 then
		return
	end

	CurrentRun.Money = CurrentRun.Money - amount
	CurrentRun.MoneySpent = CurrentRun.MoneySpent + amount

	CurrentRun.MoneyRecord[source] = (CurrentRun.MoneyRecord[source] or 0) - amount
	GameState.LifetimeResourcesSpent.Money = (GameState.LifetimeResourcesSpent.Money or 0) + amount
	CreateAnimation({ Name = "SpendMoneyFx", DestinationId = CurrentRun.Hero.ObjectId })
	thread( UpdateMoneyUI, CurrentRun.Money )

end


dofile('source/hades-coop/game/scripts/hooks/MoneyHooks.lua').InitHooks()
AddMoney(100,'Drop')
assert(CurrentRun.Money==210 and CurrentRun.MoneyRecord.Drop==200)
assert(GameState.LifetimeResourcesGained.Money==200)
SpendMoney(150,'Shop')
assert(CurrentRun.Money==60 and CurrentRun.MoneySpent==150)
AddMoney(25,'Item'); assert(CurrentRun.Money==110)
AddMoney(nil,'Nil'); AddMoney(0,'Zero'); AddMoney(-10,'Negative')
assert(CurrentRun.Money==110)
AddMoney(0.2,'Fraction'); assert(CurrentRun.Money==110)
blocked=true
AddMoney(100,'Blocked'); assert(CurrentRun.Money==110)
assert(CurrentRun.MoneyRecord.Blocked==0)
print('PASS real stock money logic: 100 -> 200, purchase still 150, shared balance, accounting, invalid rewards and BlockMoney preserved.')
