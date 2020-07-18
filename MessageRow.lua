MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
	self:Update()
end

function MessageRowMixin:Reset()
	self:Enable();
end

function MessageRowMixin:Update()
	if self.message then
		if self.message.name then
			self.name:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self.message.name));
		end
	end
	self:Show();
end

function MessageRowMixin:OnClick()
	print('click')
end