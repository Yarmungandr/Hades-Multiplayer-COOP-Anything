-- Individual combat timers use the owner of the current combat callback.
-- Encounter, dialogue and other shared scene timers retain their original keys.
local CoopPlayers = ModRequire "../CoopPlayers.lua"
local HeroContext = ModRequire "../HeroContext.lua"
local HookUtils = ModRequire "../HookUtils.lua"

local playerCooldowns = {
    CritSuper = true, -- Combat.lua: critical-hit super-meter gain
    BlockPerfectDash = true, -- DamageHero / Powers.lua perfect-dash eligibility
    AttackNotReady = true,
    NotReadySound = true,
    MaxCharge = true,
}
local playerCounts = {
    AttackNotReady = true,
    AmmoInEnemy = true,
    AmmoNotRetrieved = true,
}

local function ScopedName(name, allowed)
    if allowed[name] and HeroContext.IsHeroContextExplicit() then
        local playerId = CoopPlayers.GetPlayerByHero(HeroContext.GetCurrentHeroContext())
        if playerId then
            return "TN_Coop:P" .. playerId .. ":" .. name
        end
    end
    return name
end

local CooldownHooks = {}
local installed = false
function CooldownHooks.InitHooks()
    if installed then return end
    installed = true
for _, functionName in ipairs({ "CheckCooldown", "CheckCooldownNoTrigger", "TriggerCooldown" }) do
    HookUtils.wrap(functionName, function(baseFun, name, ...)
        return baseFun(ScopedName(name, playerCooldowns), ...)
    end)
end

HookUtils.wrap("CheckCountInWindow", function(baseFun, name, ...)
    return baseFun(ScopedName(name, playerCounts), ...)
end)

end
return CooldownHooks
