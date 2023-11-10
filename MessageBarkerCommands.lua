MessageBarkerCommands = {}

-- Slash Commands
SLASH_MESSAGEBARKER1, SLASH_MESSAGEBARKER2 = "/mb", "/messagebarker"
SlashCmdList.MESSAGEBARKER = function(msg, editBox)
	MessageBarkerFrame:Toggle();
end

SLASH_MESSAGEBARKER_BARK1, SLASH_MESSAGEBARKER_BARK2, SLASH_MESSAGEBARKER_BARK3 = "/bm", "/barkmsg", "/barkmessage"
SlashCmdList.MESSAGEBARKER_BARK = function(msg, editBox)
	MessageBarker:BarkMessage(msg, MessageBarker.db.char.testOutputMode or false)
end

local DB_ICON_NAME = "MessageBarkerDBIcon"

SLASH_MESSAGEBARKER_MM_HIDE1 = "/messagebarker_minimap_hide"
SlashCmdList.MESSAGEBARKER_MM_HIDE = function(msg, editBox)
	MessageBarker.db.char.minimapButton.hide = true
	LibStub("LibDBIcon-1.0"):Hide(DB_ICON_NAME)
end

SLASH_MESSAGEBARKER_MM_SHOW1 = "/messagebarker_minimap_show"
SlashCmdList.MESSAGEBARKER_MM_SHOW = function(msg, editBox)
	MessageBarker.db.char.minimapButton.hide = false
	LibStub("LibDBIcon-1.0"):Show(DB_ICON_NAME)
end

function MessageBarkerCommands:InitMinimapIcon()
	LibStub("LibDBIcon-1.0"):Register(DB_ICON_NAME, LibStub("LibDataBroker-1.1"):NewDataObject("MessageBarkerFrame",
	{
		type = "data source",
		text = "Message Barker",
		icon = "Interface\\Icons\\Ability_mount_whitedirewolf",
		OnClick = function(self, button) 
			--if (button == "RightButton") then
			--elseif (button == "MiddleButton") then
			MessageBarkerFrame:Toggle();
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(format("%s", "Message Barker"));
			tooltip:AddLine("|cFFCFCFCFLeft Click: |rOpen Message Barker");
		end
	}), MessageBarker.db.char.minimapButton);
end