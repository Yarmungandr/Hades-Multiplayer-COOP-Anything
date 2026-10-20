local config=dofile('source/hades-coop/game/scripts/config.lua')
function ModRequire() return config end
function MergeTables(a,b) local c={} for k,v in pairs(a) do c[k]=v end for k,v in pairs(b) do c[k]=v end return c end
local created,destroyed,attached,texts,colors={},{},{},{},{}
local nextId=100
function SpawnObstacle(a)
    assert(a.Name == "BlankObstacleWorldGUI", "Markers need a visible world GUI obstacle")
    nextId=nextId+1; created[nextId]=a; return nextId
end
function Destroy(a) destroyed[a.Id]=true end
function Attach(a) attached[a.Id]=a.DestinationId end
function SetAnimation(a) assert(a.Name=='CodexButton_Down') end
function SetColor(a) colors[a.Id]=a.Color end
function SetScale() end
function AddOutline() end
function CreateTextBox(a) texts[a.Id]=a.Text end
CurrentRun={CurrentRoom={}}
local markers=dofile('source/hades-coop/game/scripts/PlayerVisibilityHelper.lua')
for i=1,4 do
    markers.AddPlayerMarkers(i,i)
    assert(texts[100+i]=='P'..i and attached[100+i]==i)
    local c=colors[100+i]
    assert(c[3]>=c[1] or c[2]>c[1])
end
markers.AddPlayerMarkers(1,1)
assert(destroyed[101] and texts[105]=='P1')
markers.RemovePlayerMarkers(2)
assert(destroyed[102])
CurrentRun.CurrentRoom={}
markers.AddPlayerMarkers(3,30)
assert(not destroyed[103] and attached[106]==30)
print('PASS markers: four labels/colors, attachment, replacement, death cleanup, room ID isolation (mocked engine).')
