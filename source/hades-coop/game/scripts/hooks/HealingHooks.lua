-- Share each healing event with living teammates, including fountains/items.
local Players = ModRequire "../CoopPlayers.lua"
local Context = ModRequire "../HeroContext.lua"
local Hooks = ModRequire "../HookUtils.lua"
local HealingHooks = {}
local installed = false
function HealingHooks.InitHooks()
    if installed then return end
    installed = true
Hooks.wrap("Heal", function(base, victim, args)
    if not victim or not Players.GetPlayerByHero(victim) then
        return base(victim, args)
    end
    if victim.IsDead then return end
    -- Heal writes HealAmount/ActualHealAmount into its argument table. Preserve
    -- the original fraction for teammates with different maximum health.
    local original = DeepCopyTable(args)
    local result = base(victim, args)
    for _, hero in ipairs(Players.GetAliveHeroes()) do
        if hero ~= victim then
            Context.RunWithHeroContext(hero, base, hero, DeepCopyTable(original))
        end
    end
    return result
end)

end
return HealingHooks
