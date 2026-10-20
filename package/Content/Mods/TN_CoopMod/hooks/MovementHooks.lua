-- RamWeapon completion supplies OwnerTable (verified in the Steam engine PDB/disassembly).
local HeroContextWrapper = ModRequire "../HeroContextWrapper.lua"
local HookUtils = ModRequire "../HookUtils.lua"
HeroContextWrapper.WrapTriggerHero("OnRamWeaponComplete", "OwnerTable")

-- ToggleControl changes a global RemappableControl, not a per-player control.
-- Only intercept the two RamWeapon callbacks; shared menu/scene toggles stay global.
local ramCallback = setmetatable({}, { __mode = "k" })
for _, eventName in ipairs({ "OnWeaponFired", "OnRamWeaponComplete" }) do
    local register = _G[eventName]
    _G[eventName] = function(args)
        if args[1] ~= "RamWeapon" then return register(args) end
        local handler = args[2]
        return register { args[1], function(triggerArgs)
            local co = coroutine.running()
            local previous = ramCallback[co]
            ramCallback[co] = true
            handler(triggerArgs)
            ramCallback[co] = previous
        end }
    end
end

HookUtils.wrap("ToggleControl", function(baseFun, args)
    if not ramCallback[coroutine.running()] then return baseFun(args) end
    local hero = CurrentRun.Hero
    local remaining = {}
    for _, name in ipairs(args.Names or {}) do
        if name == "Rush" and hero and hero.ObjectId then
            if not args.Enabled then
                if hero.CoopRamRushEnabled == nil then
                    hero.CoopRamRushEnabled = GetWeaponDataValue {
                        Id = hero.ObjectId, WeaponName = "RushWeapon", Property = "Enabled"
                    }
                end
                SetWeaponProperty { DestinationId = hero.ObjectId, WeaponName = "RushWeapon", Property = "Enabled", Value = false }
            else
                local enabled = hero.CoopRamRushEnabled
                hero.CoopRamRushEnabled = nil
                if enabled ~= nil then
                    SetWeaponProperty { DestinationId = hero.ObjectId, WeaponName = "RushWeapon", Property = "Enabled", Value = enabled }
                end
            end
        else
            remaining[#remaining + 1] = name
        end
    end
    if #remaining > 0 then
        local forwarded = ShallowCopyTable(args)
        forwarded.Names = remaining
        return baseFun(forwarded)
    end
end)
