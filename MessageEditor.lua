MessageEditorMixin = CreateFromMixins(CallbackRegistryBaseMixin);
MessageEditorEvent = {
	Saving = 1,
}

function MessageEditorMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self:Hide()
	local ResetCheckButton = function(pool, checkButton)
		checkButton:SetChecked(false)
		checkButton.Text:SetText('')
		checkButton:ClearAllPoints()
	end
	self.outputSelectorPool = CreateFramePool("CheckButton", self.OutputSelectFrame, "ChatConfigCheckButtonTemplate", ResetCheckButton);
	self.outputSelectors = {}
end

function MessageEditorMixin:SetMessage(message)
	self.currentMessage = message
	if self.currentMessage then
		self.NameEditBox:SetText(self.currentMessage.name or '')
		self.MessageEditBox:SetText(self.currentMessage.message or '')
		self:SetChatOutputSelectors()
		self:Show();
	else 
		self:Hide()
	end
end

-- SendChatMessage(msg [, chatType, languageID, target])
function MessageEditorMixin:GetDefaultChatOutputs()
	return {
		{ chatType = SAY },
		{ chatType = YELL },
		{ chatType = RAID },
		{ chatType = RAID_WARNING },
		{ chatType = INSTANCE_CHAT },
		{ chatType = GUILD },
	}
end

function MessageEditorMixin:GetCurrentChannelOutputs()
	local channelOutputs = {}
	local channelList = GetChannelList()
	for i=1, select("#", channelList), 3 do
		local channelID = select(i, channelList);
		local channel = select(i+1, channelList);
		local disabled = select(i+2, channelList);
		table.insert(channelOutputs, { chatType = CHANNEL, target = channelID, channel = channel })
	end
	return channelOutputs
end

function MessageEditorMixin:SetChatOutputSelectors()
	self.outputSelectorPool:ReleaseAll()
	self.outputSelectors = {}
	local prevCheckBox = nil
	for _, output in ipairs(self:GetDefaultChatOutputs()) do
		local checkBox = self.outputSelectorPool:Acquire()
		local checkBoxName = output.chatType
		checkBox.Text:SetText(checkBoxName);
		local checked = self:IndexOfMessageOutput(output) ~= nil
		checkBox:SetChecked(checked)
		checkBox.output = output
		if prevCheckBox then
			checkBox:SetPoint("TOPLEFT", prevCheckBox, "BOTTOMLEFT", 0, 0);
		else
			checkBox:SetPoint("TOPLEFT", self.OutputSelectFrame, "TOPLEFT", 4, -4);
		end
		checkBox:Show();
		prevCheckBox = checkBox
		table.insert(self.outputSelectors, checkBox)
	end
end

function MessageEditorMixin:AddMessageOutput(output)
	if not self:IndexOfMessageOutput(output) then
		table.insert(self.currentMessage.outputs, output)
	end
end

function MessageEditorMixin:RemoveMessageOutput(output)
	local index = self:IndexOfMessageOutput(output)
	if index then
		self.currentMessage.outputs[index] = nil
	end
end

function MessageEditorMixin:IndexOfMessageOutput(output)
	local index = nil
	if self:EnsureMessageOutputs() and output then
		index, _ = FindInTableIf(self.currentMessage.outputs, function(other) 
			return output.chatType == other.chatType and
				(output.chatType ~= CHANNEL or (output.channel == other.channel))
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

function MessageEditorMixin:SaveMessage()
	if self.currentMessage then
		self.currentMessage.name = self.NameEditBox:GetText()
		self.currentMessage.message = self.MessageEditBox:GetText()
		for i, outputSelector in ipairs(self.outputSelectors) do
			if outputSelector:GetChecked() then
				self:AddMessageOutput(outputSelector.output)
			else
				self:RemoveMessageOutput(outputSelector.output)
			end
		end
		self:TriggerEvent(MessageEditorEvent.Saving, self.currentMessage)
	end
end
