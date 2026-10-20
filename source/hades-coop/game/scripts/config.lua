--
-- Copyright (c) Uladzislau Nikalayevich <thenormalnij@gmail.com>. All rights reserved.
-- Licensed under the MIT license. See LICENSE file in the project root for details.
--

---@class CoopModConfig
local Config = {
    -- A surviving teammate brings dead players back in the next chamber.
    RespawnAtNextChamber = true,
    -- Fraction of maximum health on revival (1 = full health).
    ChamberRespawnHealthFraction = 1.0,
    -- Choose loot delivery type here
    -- Possible values: "Shared", "RoomDuplicated"
    --
    -- Shared - rooms generate one reward. Only one player can pick it up.
    -- The game has a query that select a player context for a reward.
    -- E.g. Player 1 boon room, meta progress room, Player 2 boon room, Player 1 boon room...
    --
    -- RoomDuplicated - rooms generate two reward for each player.
    LootDelivery = "RoomDuplicated",

    -- This config is used for the "RoomDuplicated" loot delivery option
    RoomDuplicatedDelivery = {
        -- Enables duplication of the Chaos boons.
        DuplicateChaosBoon = false;
    },
    Player1HasOutline = true;
    Player1Outline = {
        R = 70,
        G = 140,
        B = 255,
        Opacity = 0.6,
        Thickness = 2,
        Threshold = 0.6,
    };
    Player2HasOutline = true,
    Player2Outline = {
        R = 80,
        G = 225,
        B = 110,
        Opacity = 0.6,
        Thickness = 2,
        Threshold = 0.6,
    };
    Player3HasOutline = true,
    Player3Outline = { R = 175, G = 100, B = 255, Opacity = 0.6, Thickness = 2, Threshold = 0.6 },
    Player4HasOutline = true,
    Player4Outline = { R = 50, G = 225, B = 235, Opacity = 0.6, Thickness = 2, Threshold = 0.6 },
    TextAbovePlayersEnabled = true;
    TextAbovePlayersParams = {
        -- CreateTextBox params
        OffsetX = 0,
        OffsetY = -150,
        FontSize = 28,
        Color = { 255, 255, 255, 255 },
        ShadowColor = { 0, 0, 0, 240 },
        ShadowOffset = { 0, 2 },
        ShadowBlur = 0,
        OutlineThickness = 3,
        OutlineColor = { 0, 0, 0, 1 },
        Font = "AlegreyaSansSCRegular",
        Justification = "Center"
    },
    Debug = {
        OneHit = false,
        P1GodMode = false,
        P2GodMode = false,
    }
}

return Config
