MessageRowMixin = {}

function MessageRowMixin:Setup(message)
	self.message = message
end

function MessageRowMixin:Reset()
	--self:Enable();
end

function MessageRowMixin:Update()
    --self.Text:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(self:GetMessage()));
	self:Show();
end