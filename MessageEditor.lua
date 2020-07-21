MessageEditorMixin = CreateFromMixins(CallbackRegistryBaseMixin);
MessageEditorEvent = {
	Saving = 1,
}

function MessageEditorMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self:Hide()
end

function MessageEditorMixin:SetMessage(message)
	self.currentMessage = message
	if self.currentMessage then
		self.NameEditBox:SetText(self.currentMessage.name or '')
		self.MessageEditBox:SetText(self.currentMessage.message or '')
		self:Show();
	else 
		self:Hide()
	end
end

function MessageEditorMixin:SaveMessage()
	if self.currentMessage then
		self.currentMessage.name = self.NameEditBox:GetText()
		self.currentMessage.message = self.MessageEditBox:GetText()
		self:TriggerEvent(MessageEditorEvent.Saving, self.currentMessage)
	end
end