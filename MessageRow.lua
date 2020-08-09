MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
	if self.message then
		self:SetID(message.id)
		if self.message.name then
			local nameText = format("%s (%s)", self.message.name, self.message.id)
			self.name:SetText(nameText);
		end
		if self.message.type then
			local typeStr = MessageBarker:GetMessageTypeString(self.message.type)
			self.info:SetText(typeStr);
		end
		--key1, key2 = GetBindingKey(command)
		--if self.message.keybind then
		--	local ok = SetBindingClick(self.message.keybind, self.RunButton:GetName());
			--print(GetBindingByKey(self.message.keybind))
		--	self.keybind:SetText(self.message.keybind)
		--end
		self:GetKeyBindings()
	else
		self:ResetDisplay()
	end
	self:Show();
end

function MessageRowMixin:GetKeyBindings()
	local command = "CLICK "..self.RunButton:GetName()
	self.keyBindings = GetBindingKey(command)
	if self.keyBindings then
		self.keybind:SetText(self.keyBindings[1])
	else
		self.keybind:SetText('')
	end
end

--[[ function MessageRowMixin:Reset()
	self:ResetDisplay()
	self:Hide();
	self:SetHighlightAtlas("voicechat-channellist-row-highlight");	
	self:UnlockHighlight()
	self:Enable();
end ]]

function MessageRowMixin:ResetDisplay()
	self.name:SetText('');
	self.info:SetText('');
end

function MessageRowMixin:OnClick()
	print('click')
end

function MessageRowMixin:RunClicked()
	MessageBarker:BarkMessage(self.message.id)
end