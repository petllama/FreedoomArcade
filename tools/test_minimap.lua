local M = dofile("tools/mock_wow.lua")
M.LoadAddon("build/WoWDoom", "WoWDoom.toc")
local D = DOOM
WoWDoomDB = nil
-- simulate ADDON_LOADED through the real event handler
for _, f in ipairs(M.Frames()) do
	local h = f.scripts.OnEvent
	if h then h(f, "ADDON_LOADED", "WoWDoom") end
end
local b = WoWDoomMinimapButton
local fails = 0
local function check(c, m) print((c and "PASS " or "FAIL ") .. m); if not c then fails = fails + 1 end end
check(b ~= nil and b.visible, "minimap button created and shown")
check(math.abs(b.px) > 50 or math.abs(b.py) > 50, string.format("positioned on the rim (%.0f, %.0f)", b.px, b.py))
b.scripts.OnClick(b, "LeftButton")
check(WoWDoomFrame and WoWDoomFrame:IsShown(), "left-click opens the game")
b.scripts.OnClick(b, "LeftButton")
check(not WoWDoomFrame:IsShown(), "left-click again closes it")
-- drag: cursor to the right of the minimap -> angle ~0
local gcp = GetCursorPosition
GetCursorPosition = function() return 1100, 540 end
b.scripts.OnDragStart(b); b.scripts.OnUpdate(b, 0.1); b.scripts.OnDragStop(b)
GetCursorPosition = gcp
check(math.abs(WoWDoomDB.minimapPos) < 1 and b.px > 70, "drag moves it (pos " .. WoWDoomDB.minimapPos .. ")")
SlashCmdList.WOWDOOM("minimap")
check(not b.visible and WoWDoomDB.minimapHidden, "/doom minimap hides it")
SlashCmdList.WOWDOOM("minimap")
check(b.visible, "and shows it again")
WoWDoom_OnAddonCompartmentClick()
check(WoWDoomFrame:IsShown(), "addon compartment click opens the game")
-- right-click menu
local G, P = D.G, D.P
b.scripts.OnClick(b, "RightButton")
check(WoWDoomMinimapMenu and WoWDoomMinimapMenu:IsShown(), "right-click opens the menu")
check(D.Minimap._ClickRow("1.  ") == false, "save slot disabled before a game is running")
G.InitNew(2, 1, 1)
for i = 1, 60 do G.input.forward = true; G.Ticker() end
G.input.forward = false
local x1, y1 = G.player.mo.x, G.player.mo.y
D.Minimap.ShowMenu()
check(D.Minimap._ClickRow("1.  ") == true, "save to slot 1")
check(WoWDoomDB.saves and WoWDoomDB.saves[1] and WoWDoomDB.saves[1].map == 1, "slot 1 stored")
check(not WoWDoomMinimapMenu:IsShown(), "menu closes after choosing")
for i = 1, 60 do G.input.right = true; G.input.forward = true; G.Ticker() end
G.input.right, G.input.forward = false, false
D.Minimap.ShowMenu()
D.Minimap._ClickRow("Quick save")
local qx, qy = G.player.mo.x, G.player.mo.y
check(WoWDoomDB.quicksave ~= nil and (qx ~= x1 or qy ~= y1), "quick save from the menu")
for i = 1, 60 do G.input.forward = true; G.Ticker() end
G.input.forward = false
D.Minimap.ShowMenu()
-- load rows come after the "Load slot" header; the second "1.  " row is the load entry
local loadIndex
for i, row in ipairs(D.Minimap.menuRows) do
	if row.kind == "header" and row.text == "Load slot" then loadIndex = i + 1 end
end
WoWDoomMinimapMenu.rows[loadIndex]:GetScript("OnClick")(WoWDoomMinimapMenu.rows[loadIndex])
check(G.player.mo.x == x1 and G.player.mo.y == y1, "load slot 1 restores that position")
check(WoWDoomFrame:IsShown(), "loading opens the game window")
local emptyRow = D.Minimap.menuRows[loadIndex + 1]
D.Minimap.ShowMenu()
check(D.Minimap.menuRows[loadIndex + 1].enabled == false, "empty load slot 2 is disabled")
D.Minimap._ClickRow("Quick load")
check(G.player.mo.x == qx and G.player.mo.y == qy, "quick load from the menu")
SlashCmdList.WOWDOOM("save 3")
check(WoWDoomDB.saves[3] ~= nil, "/doom save 3")
SlashCmdList.WOWDOOM("load 1")
check(G.player.mo.x == x1, "/doom load 1")
print(fails == 0 and "ALL OK" or fails .. " failures")
