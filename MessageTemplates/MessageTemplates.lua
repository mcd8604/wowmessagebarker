MessageTemplateMixin = {}

function MessageTemplateMixin:Load() end

function MessageTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
end

