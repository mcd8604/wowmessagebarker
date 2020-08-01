MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
	if self.message then
		if self.message.name then
			local nameText = format("%s (%s)", self.message.name, self.message.id)
			self.name:SetText(nameText);
		end
		if self.message.type then
			local typeStr = MessageBarker:GetMessageTypeString(self.message.type)
			self.info:SetText(typeStr);
		end
	else
		self:ResetDisplay()
	end
	self:Show();
end

function MessageRowMixin:Reset()
	self:ResetDisplay()
	self:Hide();
	self:SetHighlightAtlas("voicechat-channellist-row-highlight");	
	self:UnlockHighlight()
	self:Enable();
end

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