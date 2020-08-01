MessageTypeTemplateMixin = {}

function MessageTypeTemplateMixin:SetMessage(message)
end

BasicMessageTypeTemplateMixin = {}

function BasicMessageTypeTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
	self.MessageScrollFrame.MessageEditBox:SetText(message.content.text or '')
end

function BasicMessageTypeTemplateMixin:OnTextChanged()
	self.message.content.text = self.MessageScrollFrame.MessageEditBox:GetText()
end

SaleMessageTypeTemplateMixin = {}

function SaleMessageTypeTemplateMixin:SetMessage(message)
end