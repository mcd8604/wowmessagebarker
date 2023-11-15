MessageBarkerFrameMixin = {};

function MessageBarkerFrameMixin:OnLoad()
	self:RegisterCallbacks();
	self:LoadDirtyFlags();
	self:RegisterForDrag("LeftButton")
end

function MessageBarkerFrameMixin:RegisterCallbacks()
	MessageBarker:RegisterCallback(MessageBarkerEvent.Initialized, function(event) self:Initialize() end)
	MessageBarker:RegisterCallback(MessageBarkerEvent.MessageAdded, function(event, newMessage) self:HandleMessageAdded(newMessage) end)
	MessageBarker:RegisterCallback(MessageBarkerEvent.MessageDeleted, function(event, messageId) self.MessageList:DeleteMessageRow(messageId) end)
	self.MessageList:RegisterCallback(MessageListEvent.RowSelected, function(event, message, keyBindings) self:HandleMessageSelected(message, keyBindings) end)
	self.MessageEditor:RegisterCallback(MessageEditorEvent.MessageChanged, function(event, message) self:MarkDirty("UpdateAll"); end)
	self.MessageEditor:RegisterCallback(MessageEditorEvent.BindingChanged, function(event, message, key) self:HandleKeyBindingChange(message, key) end)
	self:RegisterEvent("UPDATE_BINDINGS")
end

function MessageBarkerFrameMixin:Initialize()
	self.MessageList:SetMessages(MessageBarker:GetMessages());
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

function MessageBarkerFrameMixin:OnShow()
end

function MessageBarkerFrameMixin:HandleMessageAdded(newMessage)
	self.MessageList:SetMessages(MessageBarker:GetMessages());
	self.MessageList:SelectMessage(newMessage)
end

function MessageBarkerFrameMixin:HandleMessageSelected(message, keyBindings)
	if message then
		self.InstructionsFrame:Hide()
	else
		self.InstructionsFrame:Show()
	end
	self.MessageEditor:SetMessage(message, keyBindings)
end

function MessageBarkerFrameMixin:OnEvent(event, ...)
	if event == "UPDATE_BINDINGS" then
		self:UpdateKeyBindings()
	end
end

function MessageBarkerFrameMixin:UpdateKeyBindings()
	self.MessageList:UpdateKeyBindings()
	if self.MessageList.selectedRow then
		self.MessageEditor:UpdateKeyBindings(self.MessageList.selectedRow.keyBindings)
	end
end

CONFIRM_OVERWRITE_KEYBINDING = "%s is already bound to %s. Overwrite?"
StaticPopupDialogs["CONFIRM_OVERWRITE_KEYBINDING"] = {
	text = CONFIRM_OVERWRITE_KEYBINDING,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_, data)
		data.messageBarkerFrame:SetKeyBindingToSelectedRow(data.key)
	end,
	OnCancel = function(_, data)
		data.messageBarkerFrame.MessageEditor:ResetKeyBindingButton()
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

CONFIRM_REMOVE_KEYBINDING = "Remove key binding for message: '%s'?"
StaticPopupDialogs["CONFIRM_REMOVE_KEYBINDING"] = {
	text = CONFIRM_REMOVE_KEYBINDING,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_, data)
		local rowIndex, messageRow = data.messageBarkerFrame.MessageList:FindMessageRow(data.message.id)
		if messageRow then
			messageRow:RemoveKeyBindings()
		end
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

function MessageBarkerFrameMixin:HandleKeyBindingChange(message, key)
	if key then
		-- TODO ignore selectedMessage, just use the given one and find the send button for it
		if self.MessageList.selectedMessage == message then
			-- Add new key binding
			local action = GetBindingAction(key);
			if action and action ~= '' then
				StaticPopup_Show("CONFIRM_OVERWRITE_KEYBINDING", key, action, { messageBarkerFrame = self, key = key })
			else
				self:SetKeyBindingToSelectedRow(key)
			end
		end
	else
		-- Remove key bindings
		StaticPopup_Show("CONFIRM_REMOVE_KEYBINDING", message.name, '', { messageBarkerFrame = self, message = message })
	end
end

function MessageBarkerFrameMixin:SetKeyBindingToSelectedRow(key)
	local buttonName = self.MessageList.selectedRow.RunButton:GetName()
	local ok = SetBindingClick(key, buttonName);
	if ok then
		SaveBindings(GetCurrentBindingSet())
	else
		self.MessageEditor:ResetKeyBindingButton()
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
			-- TODO may need to refactor updates to be more granular, and possibly cache the bindings somewhere
			self.MessageList:SetMessages(MessageBarker:GetMessages());
		end
		--if self.DirtyFlags:IsDirty(self.DirtyFlags.UpdateMessageEditor) then
		--	self.MessageEditor:Update();
		--end
		self.DirtyFlags:MarkClean();
	end
end

function MessageBarkerFrameMixin:AddButtonClicked(mouseButton)
	if mouseButton == "RightButton" then
		self:ShowMessageTypeDropDown()
	else
		self:AddNewMessage()
	end
end
 
function MessageBarkerFrameMixin:ShowMessageTypeDropDown()
	self.MessageTypeDropDown.displayMode = "MENU";
	self.MessageTypeDropDown.initialize = MessageBarkerFrame_InitializeDropDown;
	ToggleDropDownMenu(1, self.NewButton, self.MessageTypeDropDown, "cursor");
end

function MessageBarkerFrame_InitializeDropDown()
	MessageBarkerFrame_AppendCreateMessageDropDownInfo()
	MessageBarkerFrame_AppendCancelDropDownInfo()
end

function MessageBarkerFrame_AppendCreateMessageDropDownInfo()
	local info = UIDropDownMenu_CreateInfo();
	info.text = "Create New Message";
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);
	for messageType, i in pairs(MessageBarker_MessageTypes) do
		info = UIDropDownMenu_CreateInfo()
		info.text = messageType
		info.value = i
		info.notCheckable = 1;
		info.func = function() MessageBarker:AddNewMessage(MessageBarker:CreateMessage(i)) end
		UIDropDownMenu_AddButton(info)
	end
end

function MessageBarkerFrame_AppendCancelDropDownInfo()
	UIDropDownMenu_AddSeparator(1);
	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
	info.notCheckable = 1;
	info.func = function() HideDropDownMenu(1); end;
	UIDropDownMenu_AddButton(info);
end

function MessageBarkerFrameMixin:AddNewMessage()
	local objectType, itemId, itemLink = GetCursorInfo()
	ClearCursor()
	local newMessage;
	if objectType == "item" then
		newMessage = MessageBarker:CreateMessage(MessageBarker_MessageTypes.Sale, itemId, itemLink)
	else
		newMessage = MessageBarker:CreateMessage(MessageBarker_MessageTypes.Basic)
	end
	MessageBarker:AddNewMessage(newMessage)
end

CONFIRM_DELETE_MESSAGE = "Delete message: %s?"
StaticPopupDialogs["CONFIRM_DELETE_MESSAGE"] = {
	text = CONFIRM_DELETE_MESSAGE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(_, data)
		data.messageRow:RemoveKeyBindings()
		MessageBarker:DeleteMessage(data.messageToDelete)
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

function MessageBarkerFrameMixin:PromptDeleteSelectedMessage()
	local selectedMessage = self.MessageList:GetSelectedMessage()
	local messageRow = self.MessageList.selectedRow
	StaticPopup_Show("CONFIRM_DELETE_MESSAGE", selectedMessage.name, nil, { messageRow = messageRow, messageToDelete = selectedMessage })
end

-- Hook ChatEdit_InsertLink
local originalChatEdit_InsertLink = nil
if not originalChatEdit_InsertLink and ChatEdit_InsertLink then
	originalChatEdit_InsertLink = ChatEdit_InsertLink
	ChatEdit_InsertLink = function(link)
		local handled = false
		-- Try handling in the MessageEditor
		if link and MessageBarkerFrame:IsShown() and MessageBarkerFrame.MessageEditor then
			handled = MessageBarkerFrame.MessageEditor:HandleInsertLink(link)
		end
		-- Fall back to original handler
		if not handled then
			if originalChatEdit_InsertLink then
				handled = originalChatEdit_InsertLink(link)
			end
		end
		return handled
	end
end