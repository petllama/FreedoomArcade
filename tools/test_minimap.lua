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
print(fails == 0 and "ALL OK" or fails .. " failures")
