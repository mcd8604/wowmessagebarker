MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
	if self.message then
		if self.message.name then
			local nameText = format("%s (%s)", self.message.name, self.message.id)
			self.name:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(nameText));
		end
		if self.message.message then
			self.info:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self.message.message));
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
	MessageBarker:BarkMessage(self.message.id, true)
end