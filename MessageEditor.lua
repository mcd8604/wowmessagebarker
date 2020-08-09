MessageEditorMixin = CreateFromMixins(CallbackRegistryBaseMixin, EventRegistrationHelper);
MessageEditorEvent = {
	MessageChanged = 1,
	BindingChanged = 2,
}

function MessageEditorMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self:Hide()
	local ResetCheckButton = function(pool, checkButton)
		checkButton:SetChecked(false)
		checkButton.Text:SetText('')
		checkButton:ClearAllPoints()
	end
	self:LoadMessageTypeFrames()
	self.outputSelectorPool = CreateFramePool("CheckButton", self.OutputSelectFrame, "ChatConfigCheckButtonTemplate", ResetCheckButton);
	self.outputSelectors = {}
	self:AddEvent("CHANNEL_UI_UPDATE")
	self:CreateBindingButton()
end

-- NOTE: Message type templates should follow the naming convention: "<MessageType>MessageTemplate"
function MessageEditorMixin:LoadMessageTypeFrames()
	self.messageTypeFrames = {}
	for messageType, i in pairs(MessageBarker_MessageTypes) do		
		local key = messageType.."ContentFrame"
		local frameName = (self:GetName() or '')..key
		local templateName = messageType.."MessageTemplate"
		local frame = CreateFrame("Frame", frameName, self, templateName)
		self[key] = frame
		-- TODO move to OnLoad?
		frame:SetPoint("TOP", self.MessageTypeFontStringHeader, "BOTTOM")
		frame:SetPoint("LEFT", self, "LEFT")
		frame:SetPoint("RIGHT", self, "RIGHT")
		frame:SetPoint("BOTTOM", self.OutputSelectFrame, "TOP")
		frame:Load()
		frame:Hide()
		self.messageTypeFrames[i] = frame
	end
end

function MessageEditorMixin:CreateBindingButton()
	local bindingType = { Name = "MessageBarkerBinding", Type = "CustomBindingType", EnumValue = 1 }
	local handler = CustomBindingHandler:CreateHandler(bindingType);

	handler:SetOnBindingModeActivatedCallback(function(isActive)
		if isActive then
			--KeyBindingFrame.buttonPressed = button;
			--KeyBindingFrame_SetSelected("TOGGLE_VOICE_PUSH_TO_TALK", button);
			--KeyBindingFrame_UpdateUnbindKey();
			--KeyBindingFrame.outputText:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingName("TOGGLE_VOICE_PUSH_TO_TALK"));
		end
	end);

	handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
		if keys and #keys > 0 then
			local key = keys[1]
			for i = 2, #keys do
				key = key .. '-' .. keys[i]
			end
			-- TODO handle generalizing LEFT/RIGHT modifiers into single modifiers
			self:TriggerEvent(MessageEditorEvent.BindingChanged, self.currentMessage, key)
			--local ok = SetBindingClick(key, self.RunButton:GetName());
			--print(GetBindingByKey(key))
			--self.message.keybind = key
			-- TODO on message delete, remove binding
		else
			-- TODO clear binding text
		end
		--KeyBindingFrame_SetSelected(nil);

		--if completedSuccessfully then
		--	KeyBindingFrame.outputText:SetText(KEY_BOUND);
		--else
		--	KeyBindingFrame.outputText:SetText("");
		--end

		--if completedSuccessfully and keys then
		--	DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys);
		--end
	end);
	self.BindingButton = CustomBindingManager:RegisterHandlerAndCreateButton(handler, "CustomBindingButtonTemplateWithLabel", self)
	self.BindingButton:SetWidth(120)
	self.BindingButton.selectedHighlight:SetWidth(120)
	self.BindingButton:SetHeight(22);
	self.BindingButton:SetPoint("TOPRIGHT");
	self.BindingButton:Show();
end

function MessageEditorMixin:SetMessage(message, keyBindings)
	self.currentMessage = message
	if self.currentMessage then
		self.NameEditBox:SetText(self.currentMessage.name or '')
		if not self.currentMessage.type then
			self.currentMessage.type = MessageBarker_MessageTypes.Basic
		end
		self.currentMessageTypeString = MessageBarker:GetMessageTypeString(self.currentMessage.type)
		self.MessageTypeFontStringValue:SetText(self.currentMessageTypeString)
		self:SetKeyBindings(keyBindings)
		self:SetMessageContentFrame()
		self:SetChatOutputSelectors()
		self:Show();
	else 
		self:Hide()
	end
end

function MessageEditorMixin:SetKeyBindings(keyBindings)
	self.keyBindings = keyBindings
	local keyBindingsText = ''
	if keyBindings then
		-- TODO display additional bindings (in tooltip?)
		keyBindingsText = keyBindings
	end
	self.BindingButton:SetText(keyBindingsText)
end

function MessageEditorMixin:SetMessageContentFrame()
	for _, frame in ipairs(self.messageTypeFrames) do
		frame:Hide()
	end
	local frame = self.messageTypeFrames[self.currentMessage.type]
	assert(frame, "No frame exists for message type: "..self.currentMessageTypeString)
	frame:SetMessage(self.currentMessage)
	--self.MessageContentFrame:SetHeight(frame:GetHeight())
	frame:Show()
	--self.OutputSelectFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
end

-- SendChatMessage(msg [, chatType, languageID, target])
function MessageEditorMixin:GetDefaultChatOutputs()
	return {
		{ chatType = "SAY", 			display = SAY },
		{ chatType = "YELL", 			display = YELL },
		{ chatType = "RAID", 			display = RAID },
		{ chatType = "RAID_WARNING", 	display = RAID_WARNING },
		{ chatType = "INSTANCE_CHAT", 	display = INSTANCE_CHAT },
		{ chatType = "GUILD", 			display = GUILD },
	}
end

function MessageEditorMixin:GetChannelOutputs()
	-- Union the the player's currently joined channels with the message's existing channel outputs
	local channelOutputs = self:ConvertChannelList(GetChannelList())
	self:EnsureMessageOutputs()
	for _, output in ipairs(self.currentMessage.outputs) do
		if output.chatType == "CHANNEL" then
			-- check if output exists in channelOutputs
			if not self:IndexOfMessageOutput(channelOutputs, output) then
				table.insert(channelOutputs, output)
			end
		end
	end
	return channelOutputs
end

function MessageEditorMixin:ConvertChannelList(...)
	local channelOutputs = {}
	for i=1, select("#", ...), 3 do
		--local channelID = select(i, ...);
		local channel = select(i+1, ...);
		--local disabled = select(i+2, ...);
		table.insert(channelOutputs, { chatType = "CHANNEL", channel = channel })
	end
	return channelOutputs
end

function MessageEditorMixin:SetChatOutputSelectors()
	self.outputSelectorPool:ReleaseAll()
	self.outputSelectors = {}
	self:AddOutputSelectorCheckboxes(self:GetDefaultChatOutputs(), 1)
	self:AddOutputSelectorCheckboxes(self:GetChannelOutputs(), 2)
end

-- TODO refactor this - break down into named chunks/functions
function MessageEditorMixin:AddOutputSelectorCheckboxes(outputs, columnNumber)
	local prevCheckBox = nil
	for _, output in ipairs(outputs) do
		local checkBox = self.outputSelectorPool:Acquire()
		local checkBoxName = output.display or output.channel
		checkBox.Text:SetText(checkBoxName);
		local checked = self:IndexOfMessageOutput(self.currentMessage.outputs, output) ~= nil
		checkBox:SetChecked(checked)
		checkBox.output = output
		if prevCheckBox then
			checkBox:SetPoint("TOPLEFT", prevCheckBox, "BOTTOMLEFT", 0, 0);
		else
			local x = 4
			if columnNumber > 1 then
				x = 4 + self.OutputSelectFrame:GetWidth() / 2
			end
			checkBox:SetPoint("TOPLEFT", self.OutputSelectFrame, "TOPLEFT", x, -4);
		end
		checkBox:Show();
		checkBox:SetScript("OnClick", function(...) 
			if checkBox:GetChecked() then
				self:AddMessageOutput(checkBox.output)
			else
				self:RemoveMessageOutput(checkBox.output)
			end
		end)
		prevCheckBox = checkBox
		table.insert(self.outputSelectors, checkBox)
	end
end

function MessageEditorMixin:AddMessageOutput(output)
	self:EnsureMessageOutputs()
	if not self:IndexOfMessageOutput(self.currentMessage.outputs, output) then
		table.insert(self.currentMessage.outputs, output)
	end
end

function MessageEditorMixin:RemoveMessageOutput(output)
	self:EnsureMessageOutputs()
	local index = self:IndexOfMessageOutput(self.currentMessage.outputs, output)
	if index then
		self.currentMessage.outputs[index] = nil
	end
end

function MessageEditorMixin:IndexOfMessageOutput(outputs, output)
	local index = nil
	if output then
		index, _ = FindInTableIf(outputs, function(other) 
			return output.chatType == other.chatType and
				(output.chatType ~= "CHANNEL" or (output.channel and output.channel == other.channel))
		end)
	end
	return index
end

function MessageEditorMixin:EnsureMessageOutputs()
	local ensured = false
	if self.currentMessage then
		if not self.currentMessage.outputs then
			self.currentMessage.outputs = {}
		end
		ensured = true
	end
	return ensured
end

--[[ function MessageEditorMixin:CancelMessageEdit()
	local text = ''
	if self.currentMessage then
		text = self.currentMessage.message or ''
	end
	--self.MessageEditBox:SetText(text)
end ]]

--[[ function MessageEditorMixin:SaveMessage()
	if self.currentMessage then
		self.currentMessage.name = self.NameEditBox:GetText()
		self:TriggerEvent(MessageEditorEvent.Saving, self.currentMessage)
	end
end ]]

function MessageEditorMixin:OnNameChanged()
	self.currentMessage.name = self.NameEditBox:GetText()
	self:TriggerEvent(MessageEditorEvent.MessageChanged, self.currentMessage)
end

function MessageEditorMixin:OnEvent(event, ...)
	if event == "CHANNEL_UI_UPDATE" then
		self:SetChatOutputSelectors()
	end
end

function MessageEditorMixin:OnShow()
	self:SetEventsRegistered(true);
end

function MessageEditorMixin:OnHide()
	self:SetEventsRegistered(false);
end