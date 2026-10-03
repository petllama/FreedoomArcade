-- Minimap button (no libraries): left-click opens/closes the game, drag to move it
-- around the minimap edge. Also hooks the retail addon compartment if present.
local D = DOOM
local MM = {}
D.Minimap = MM

local ICON = D.ADDON_PATH .. "tex\\icon"
local button, db

local function updatePosition()
	if not button then return end
	local angle = math.rad(db.minimapPos or 220)
	local x, y = math.cos(angle), math.sin(angle)
	local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
	if shape == "SQUARE" then
		-- push out to the square's edge
		x = math.max(-1, math.min(1, x * 1.42))
		y = math.max(-1, math.min(1, y * 1.42))
	end
	local w = Minimap:GetWidth() / 2 + 5
	local h = Minimap:GetHeight() / 2 + 5
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x * w, y * h)
end

local function onDragUpdate()
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	local atan2 = math.atan2 or math.atan
	db.minimapPos = math.deg(atan2(py - my, px - mx)) % 360
	updatePosition()
end

local function showTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:AddLine("WoWDoom")
	GameTooltip:AddLine("|cffffffffLeft-click|r to open or close", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffffffffRight-click|r to quick-load", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("|cffffffffDrag|r to move this button", 0.8, 0.8, 0.8)
	GameTooltip:AddLine("/doom minimap hides it", 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

local function create()
	button = CreateFrame("Button", "WoWDoomMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("TOPLEFT", 7, -5)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(18, 18)
	icon:SetTexture(ICON)
	icon:SetPoint("TOPLEFT", 6.5, -5.5)
	button.icon = icon

	button:SetScript("OnClick", function(_, mouse)
		if mouse == "RightButton" then
			D.UI.Open()
			D.UI.QuickLoad()
		else
			D.UI.Toggle()
		end
	end)
	button:SetScript("OnDragStart", function(self)
		self:LockHighlight()
		self:SetScript("OnUpdate", onDragUpdate)
		GameTooltip:Hide()
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
		self:UnlockHighlight()
	end)
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- press feedback like the stock minimap buttons
	button:SetScript("OnMouseDown", function() icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end)
	button:SetScript("OnMouseUp", function() icon:SetTexCoord(0, 1, 0, 1) end)
	updatePosition()
end

function MM.Init(savedDB)
	db = savedDB
	if not Minimap then return end
	if not button then create() end
	if db.minimapHidden then button:Hide() else button:Show() end
end

function MM.Toggle()
	db.minimapHidden = not db.minimapHidden
	MM.Init(db)
	D.Print("minimap button " .. (db.minimapHidden and "hidden" or "shown"))
end

-- retail addon compartment (## AddonCompartmentFunc in the toc)
function WoWDoom_OnAddonCompartmentClick()
	D.UI.Toggle()
end
