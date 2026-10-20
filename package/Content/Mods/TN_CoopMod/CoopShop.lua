-- Personal stock at Charon's world shop. Persist purchase ledgers with the room.
local Players = ModRequire "CoopPlayers.lua"
local Hooks = ModRequire "HookUtils.lua"
local Shop = {}
local spawning = setmetatable({}, { __mode = "k" })

function Shop.CanUse(item, hero)
    if not item.CoopShopSlot then return true end
    if item.CoopShopInUse then return false end
    local id = Players.GetPlayerByHero(hero)
    local store = CurrentRun.CurrentRoom.Store
    local slot = store and store.CoopStock and store.CoopStock[item.CoopShopSlot]
    return id ~= nil and not hero.IsDead and slot ~= nil and not slot.Bought[id]
end

local function Complete(slot)
    for id = 1, Players.GetPlayersCount() do
        if not slot.Bought[id] then return false end
    end
    return true
end

function Shop.InitHooks()
    Hooks.wrap("SpawnStoreItemInWorld", function(base, data, kitId)
        local store = CurrentRun.CurrentRoom.Store
        local index
        for i, option in pairs(store.StoreOptions) do
            if option == data then index = i; break end
        end
        if not index then return base(data, kitId) end
        store.CoopStock = store.CoopStock or {}
        local slot = store.CoopStock[index]
        if not slot then
            slot = { Bought = {}, KitId = kitId }
            store.CoopStock[index] = slot
        end
        if Complete(slot) then return end
        local co = coroutine.running()
        local previous = spawning[co]
        spawning[co] = index
        local result = base(DeepCopyTable(data), kitId)
        spawning[co] = previous
        return result
    end)
    for _, name in ipairs({ "CreateLoot", "CreateConsumableItemFromData" }) do
        Hooks.wrap(name, function(base, ...)
            local item = base(...)
            local index = spawning[coroutine.running()]
            if item and index then
                item.CoopShopSlot = index
                local slot = CurrentRun.CurrentRoom.Store.CoopStock[index]
                local labels = {}
                for id = 1, Players.GetPlayersCount() do
                    if not slot.Bought[id] then labels[#labels + 1] = "P" .. id end
                end
                CreateTextBox({ Id = item.ObjectId, Text = table.concat(labels, "  "),
                    Font = "AlegreyaSansSCBold", FontSize = 18, OffsetY = 95,
                    Color = {255,255,255,255}, Justification = "Center" })
            end
            return item
        end)
    end
    Hooks.wrap("RemoveStoreItem", function(base, args)
        local purchase = Shop.PendingPurchase[coroutine.running()]
        if not purchase then return base(args) end
        purchase.Slot.Bought[purchase.Player] = true
        purchase.Paid = true
        CurrentRun.CurrentRoom.StoreItemsPurchased = (CurrentRun.CurrentRoom.StoreItemsPurchased or 0) + 1
        if Complete(purchase.Slot) then
            CurrentRun.CurrentRoom.Store.StoreOptions[purchase.Index] = nil
        end
    end)
end

-- Wrap the complete OnUsed callback, including payment before the boon menu.
Shop.PendingPurchase = setmetatable({}, { __mode = "k" })
function Shop.Use(hero, callback, args)
    local item = args.AttachedTable
    if not item.CoopShopSlot then return callback(args) end
    if not Shop.CanUse(item, hero) then return end
    local co = coroutine.running()
    local room = CurrentRun.CurrentRoom
    local store = room.Store
    local index = item.CoopShopSlot
    local slot = store.CoopStock[index]
    local pending = { Slot = slot, Player = Players.GetPlayerByHero(hero), Index = index }
    item.CoopShopInUse = true
    Shop.PendingPurchase[co] = pending
    callback(args)
    Shop.PendingPurchase[co] = nil
    item.CoopShopInUse = nil
    if pending.Paid and CurrentRun.CurrentRoom == room and not Complete(slot) then
        SpawnStoreItemInWorld(store.StoreOptions[index], slot.KitId)
    end
end

return Shop
