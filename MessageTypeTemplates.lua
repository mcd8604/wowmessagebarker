MessageTypeTemplateMixin = {}

function MessageTypeTemplateMixin:SetMessage(message)
end

BasicMessageTypeTemplateMixin = {}

function BasicMessageTypeTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
	self.MessageScrollFrame.MessageEditBox:SetText(message.content or '')
end

function BasicMessageTypeTemplateMixin:OnTextChanged()
	self.message.content = self.MessageScrollFrame.MessageEditBox:GetText()
end

SaleMessageTypeTemplateMixin = {}

function SaleMessageTypeTemplateMixin:SetMessage(message)
end