MessageTemplateMixin = {}

function MessageTemplateMixin:UpdateLayout() end

function MessageTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
end

