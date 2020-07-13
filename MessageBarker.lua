MessageBarker = LibStub("AceAddon-3.0"):NewAddon("MessageBarker", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceComm-3.0")

local addonName = GetAddOnMetadata("MessageBarker", "Title");
local commPrefix = addonName .. "1";

local playerName = UnitName("player");

function MessageBarker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MessageBarkerDB", {
		factionrealm = {
        },
        char = {
			minimapButton = {hide = false},
        }
	}, true)	
    MessageBarkerGUI:Create();
end
