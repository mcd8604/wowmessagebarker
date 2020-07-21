MessageBarkerFrameMixin = {};

function MessageBarkerFrameMixin:OnLoad()
	self:InitializeDB();
	self:DrawMinimapIcon();
	self.MessageList:AddSelectionListener(function(message)
		self.MessageEditor:SetMessage(message)
		--self:MarkDirty("UpdateAll");
	end)
	self.MessageEditor:RegisterCallback(MessageEditorEvent.Saving, function(event, message)
		self:SaveMessage(message)
		self:MarkDirty("UpdateAll");
	end)
	self.MessageList:SetMessages(self:GetMessages());
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

function MessageBarkerFrameMixin:InitializeDB()
	MessageBarkerDB = LibStub("AceDB-3.0"):New("MessageBarkerDB", {
		factionrealm = self:GetDefaultFactionRealmDB(),
		char = {
			minimapButton = {hide = false},
		}
	}, true)
end

function MessageBarkerFrameMixin:GetDefaultFactionRealmDB()
	return {
		messages = {},
		sequences = {},
		nextId = 1
	}
end

-- Ensures the messages table is never nil
function MessageBarkerFrameMixin:EnsureDB()
	if not MessageBarkerDB then
		self.InitializeDB()
	end
	if not MessageBarkerDB.factionrealm then
		MessageBarkerDB.factionrealm = self:GetDefaultFactionRealmDB()
	end
	if not MessageBarkerDB.factionrealm.messages then
		MessageBarkerDB.factionrealm.messages = {}
	end
end

function MessageBarkerFrameMixin:GetMessages()
	self:EnsureDB()
	return MessageBarkerDB.factionrealm.messages
end

function MessageBarkerFrameMixin:SaveMessage(message)
	if message and message.id then
		self:EnsureDB()
		MessageBarkerDB.factionrealm.messages[message.id] = message
	end
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
			self.MessageList:SetMessages(self:GetMessages());
		end
		--if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateMessageEditor) then
		--	self.MessageEditor:Update();
		--end
		self.DirtyFlags:MarkClean();
	end
end

function MessageBarkerFrameMixin:AddNewMessage()
	local newMessage = {
		id = self:GetNextMessageID(),
		name = "Test Message",
		text = "Message Text",
		outputs = {}
	}
	local messages = self:GetMessages()
	messages[newMessage.id] = newMessage
	self.MessageList:SetMessages(messages);
	--self:MarkDirty("UpdateAll");
end

-- NOTE: Doesn't account for number overflow, though is highly unlikely
function MessageBarkerFrameMixin:GetNextMessageID()
	if not MessageBarkerDB.factionrealm.nextId then
		MessageBarkerDB.factionrealm.nextId = 1
	end
	local newId = MessageBarkerDB.factionrealm.nextId
	-- make sure new Id is max in case the sequence was altered inappropriately
	local maxId = self:GetMaxMessageID()
	if newId <= maxId then
		newId = maxId + 1
	end
	MessageBarkerDB.factionrealm.nextId = newId + 1
	return newId
end

function MessageBarkerFrameMixin:GetMaxMessageID()
	local maxId = -1
	for id, message in pairs(self:GetMessages()) do
		if id > maxId then
			maxId = id
		end
	end
	return maxId
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
