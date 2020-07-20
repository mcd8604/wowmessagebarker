MessageEditorMixin = CreateFromMixins(EventRegistrationHelper);

function MessageEditorMixin:OnLoad()
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
	-- TODO copy data from UI into message and DB
end