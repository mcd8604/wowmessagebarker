MessageTypeTemplateMixin = {}

function MessageTypeTemplateMixin:SetMessage(message)
end

BasicMessageTypeTemplateMixin = {}

function BasicMessageTypeTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
	self.MessageEditBox:SetText(message.content or '')
end

function BasicMessageTypeTemplateMixin:OnTextChanged()
	self.message.content = self.MessageEditBox:GetText()
end

SaleMessageTypeTemplateMixin = {}

function SaleMessageTypeTemplateMixin:SetMessage(message)
end