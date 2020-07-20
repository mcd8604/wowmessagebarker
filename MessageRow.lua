MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
	if self.message then
		if self.message.name then
			self.name:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self.message.name));
		end
		if self.message.message then
			self.info:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self.message.message));
		end
	end
	self:Show();
end

function MessageRowMixin:Reset()
	self:SetHighlightAtlas("voicechat-channellist-row-highlight");
	self:UnlockHighlight()
	self:Enable();
end

function MessageRowMixin:OnClick()
	print('click')
end