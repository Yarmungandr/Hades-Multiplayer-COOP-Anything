local count = 4
function ModRequire(name)
    if name:match("CoopPlayers.lua$") then
        return { GetPlayersCount = function() return count end }
    end
    return dofile("source/hades-coop/game/scripts/HookUtils.lua")
end
function round(n) return math.floor(n + 0.5) end
local balance, received, lastSource = 0, 0, nil
function AddMoney(amount, source)
    if amount == nil or round(amount) <= 0 then return end
    balance = balance + round(amount)
    received = round(amount)
    lastSource = source
end
dofile("source/hades-coop/game/scripts/hooks/MoneyHooks.lua").InitHooks()
for n = 1, 4 do
    count = n
    AddMoney(100, "Drop")
    assert(received == 200 * n and lastSource == "Drop")
end
assert(balance == 2000)
count = 4
AddMoney(25, "Item")
assert(received == 200 and balance == 2200)
AddMoney(0, "Zero"); AddMoney(nil, "Nil"); AddMoney(-10, "Negative")
assert(balance == 2200)
print("PASS: 100 gold credits 200/400/600/800 for 1/2/3/4 selected players; single shared credit, other rewards and invalid amounts.")
