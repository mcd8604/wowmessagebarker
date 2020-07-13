local GUI = {}
_G["MessageBarkerGUI"] = GUI

local AceGUI = LibStub("AceGUI-3.0")

LibStub("AceHook-3.0"):Embed(GUI)

function GUI:Create()
    self:DrawMinimapIcon();
    self:InitMainFrame();
end

function GUI:InitMainFrame()
	self.mainFrame = AceGUI:Create("Frame")
	self.mainFrame:Hide()
	_G["MessageBarkerGUI_MainFrame"] = self.mainFrame
	tinsert(UISpecialFrames, "MessageBarkerGUI_MainFrame")	-- allow ESC close
	self.mainFrame:SetTitle("Message Barker")
	self.mainFrame:SetWidth(600)
	self.mainFrame:SetLayout("Fill")
end

function GUI:Show(skipUpdate, sort_column)
	self.mainFrame:Show()
end

function GUI:Hide()
	if (self.mainFrame) then
		self.mainFrame:Hide()
	end
end

function GUI:Toggle()
	if (self.mainFrame and self.mainFrame:IsShown()) then
		GUI:Hide()
	else
		GUI:Show()
	end
end

-- Minimap icon
function GUI:DrawMinimapIcon()
	LibStub("LibDBIcon-1.0"):Register("MessageBarker", LibStub("LibDataBroker-1.1"):NewDataObject("MessageBarker",
	{
		type = "data source",
		text = "MessageBarker",
		icon = "Interface\\Icons\\Ability_mount_whitedirewolf",
		OnClick = function(self, button) 
			--if (button == "RightButton") then
			--elseif (button == "MiddleButton") then
			GUI:Toggle()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(format("%s", "MessageBarker"));
			tooltip:AddLine("|cFFCFCFCFLeft Click: |rOpen Message Barker");
		end
	}), MessageBarker.db.char.minimapButton);
end