MessageTypeTemplateMixin = {}

function MessageTypeTemplateMixin:SetMessage(message)
end

BasicMessageTypeTemplateMixin = {}

function BasicMessageTypeTemplateMixin:SetMessage(message)
	assert(message)
	self.MessageEditBox:SetText(message.content or '')
end

SaleMessageTypeTemplateMixin = {}

function SaleMessageTypeTemplateMixin:SetMessage(message)
end