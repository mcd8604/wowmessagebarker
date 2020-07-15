MessageRowMixin = {}

function MessageRowMixin:GetMessage()
	return self.name;
end

function MessageRowMixin:SetMessage(name)
	self.name = name;
end

function MessageRowMixin:Setup(message)
	self:SetMessage(message.name);
end

function MessageRowMixin:Reset()
	self:Enable();
end

function MessageRowMixin:Update()
    self.Text:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self:GetMessage()));
	self:Show();
end