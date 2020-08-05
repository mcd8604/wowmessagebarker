BasicMessageTemplateMixin = {}

function BasicMessageTemplateMixin:Load() end

function BasicMessageTemplateMixin:SetMessage(message)
	MessageTemplateMixin.SetMessage(self, message)
	-- TODO test moving the anchors to Load
	self.MessageScrollFrame.MessageEditBox:SetPoint("LEFT")
	self.MessageScrollFrame.MessageEditBox:SetPoint("RIGHT")
	self.MessageScrollFrame.MessageEditBox:SetText(message.content or '')
end

function BasicMessageTemplateMixin:OnTextChanged()
	self.message.content = self.MessageScrollFrame.MessageEditBox:GetText()
end