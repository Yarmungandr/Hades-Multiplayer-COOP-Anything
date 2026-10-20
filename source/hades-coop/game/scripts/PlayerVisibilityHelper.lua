-- World-space markers: native UI sprite plus a readable player number.
local Config = ModRequire "config.lua"
local PlayerVisibilityHelper = {}
local markers = {}
local markerRoom

local function CurrentMarkers()
    local room = CurrentRun and CurrentRun.CurrentRoom
    if room ~= markerRoom then
        -- Engine destroys world obstacles on a map change. Do not destroy old
        -- IDs after loading another map, where IDs can have been reused.
        markers = {}
        markerRoom = room
    end
    return markers
end

function PlayerVisibilityHelper.RemovePlayerMarkers(playerId)
    local ids = CurrentMarkers()
    if ids[playerId] then
        Destroy({ Id = ids[playerId] })
        ids[playerId] = nil
    end
end

function PlayerVisibilityHelper.AddPlayerMarkers(playerId, unit)
    PlayerVisibilityHelper.RemovePlayerMarkers(playerId)
    local outline = Config["Player" .. playerId .. "Outline"]
    if Config["Player" .. playerId .. "HasOutline"] then
        AddOutline(MergeTables(outline, { Id = unit }))
    end
    if not Config.TextAbovePlayersEnabled then return end
    local color = { outline.R, outline.G, outline.B, 255 }
    local id = SpawnObstacle({ Name = "BlankObstacleWorldGUI", Group = "Combat_UI_World",
        DestinationId = unit })
    CurrentMarkers()[playerId] = id
    Attach({ Id = id, DestinationId = unit, OffsetY = -130 })
    SetAnimation({ DestinationId = id, Name = "CodexButton_Down" })
    SetColor({ Id = id, Color = color })
    SetScale({ Id = id, Fraction = 0.8 })
    CreateTextBox(MergeTables(Config.TextAbovePlayersParams, {
        Id = id, Text = "P" .. playerId, Color = color,
        OffsetY = -28, FontSize = 28,
    }))
end

return PlayerVisibilityHelper
