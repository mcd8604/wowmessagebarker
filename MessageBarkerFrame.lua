MessageBarkerFrameMixin = {};

function MessageBarkerFrameMixin:OnLoad()
	MessageBarker:InitializeDB();
	self:DrawMinimapIcon();
	self.MessageList:RegisterCallback(MessageListEvent.RowSelected, function(event, message)
		self.MessageEditor:SetMessage(message)
		--self:MarkDirty("UpdateAll");
	end)
	self.MessageEditor:RegisterCallback(MessageEditorEvent.Saving, function(event, message)
		MessageBarker:SaveMessage(message)
		self:MarkDirty("UpdateAll");
	end)
	self.MessageList:SetMessages(MessageBarker:GetMessages());
	self:LoadDirtyFlags();
end

do
	local dirtyFlags = {
		UpdateMessageList = 1,
		--UpdateMessageEditor = 2,
	};
	function MessageBarkerFrameMixin:LoadDirtyFlags()
		self.DirtyFlags = CreateFromMixins(DirtyFlagsMixin);
		self.DirtyFlags:OnLoad();
		self.DirtyFlags:AddNamedFlagsFromTable(dirtyFlags);
		self.DirtyFlags:AddNamedMask("UpdateAll", Flags_CreateMaskFromTable(dirtyFlags));
		self:MarkDirty("UpdateAll");
	end
end

function MessageBarkerFrameMixin:MarkDirty(maskName)
	self.DirtyFlags:MarkDirty(self.DirtyFlags[maskName]);
end


function ItemSlotClicked(itemSlot)
	local objtype, _, itemlink = GetCursorInfo()
	ClearCursor()
	if objtype == "item" then
	   print(itemlink) 
	end
end

function MessageBarkerFrameMixin:Toggle()
	ToggleFrame(MessageBarkerFrame);
end

function MessageBarkerFrameMixin:OnUpdate()
	self:Update();
end

function MessageBarkerFrameMixin:Update()
	if self.DirtyFlags:IsDirty() then
		if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateMessageList) then
			self.MessageList:SetMessages(MessageBarker:GetMessages());
		end
		--if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateMessageEditor) then
		--	self.MessageEditor:Update();
		--end
		self.DirtyFlags:MarkClean();
	end
end

function MessageBarkerFrameMixin:AddNewMessage()
	local newMessage = {
		id = MessageBarker:GetNextMessageID(),
		name = "Test Message",
		text = "Message Text",
		outputs = {}
	}
	local messages = MessageBarker:GetMessages()
	messages[newMessage.id] = newMessage
	self.MessageList:SetMessages(messages);
	--self:MarkDirty("UpdateAll");
end

function MessageBarkerFrameMixin:DeleteSelectedMessage()
	local selectedMessage = self.MessageList:GetSelectedMessage()
	MessageBarker:DeleteMessage(selectedMessage)
	self:MarkDirty("UpdateAll");
end

-- Minimap icon
function MessageBarkerFrameMixin:DrawMinimapIcon()
	LibStub("LibDBIcon-1.0"):Register("MessageBarkerFrameMixin", LibStub("LibDataBroker-1.1"):NewDataObject("MessageBarkerFrameMixin",
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
	}), MessageBarkerDB.char.minimapButton);
end
