-- Shared wallet: credit twice the normal reward for each selected player.
local Hooks = ModRequire "../HookUtils.lua"
local Players = ModRequire "../CoopPlayers.lua"
local MoneyHooks = {}
local installed = false
function MoneyHooks.InitHooks()
    if installed then return end
    installed = true
Hooks.wrap("AddMoney", function(base, amount, source)
    if type(amount) == "number" and round(amount) > 0 then
        amount = round(amount) * 2 * Players.GetPlayersCount()
    end
    return base(amount, source)
end)

end
return MoneyHooks
