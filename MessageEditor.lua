MessageEditorMixin = CreateFromMixins(EventRegistrationHelper);

function MessageEditorMixin:OnLoad()
	print('MessageEditorMixin:OnLoad')
end

function MessageEditorMixin:SetMessage(message)
	self.currentMessage = message
	print('MessageEditorMixin:SetMessage')
end

function MessageEditorMixin:OnUpdate()
	self:Update()
end

function MessageEditorMixin:Update()
	print(" MessageEditorMixin:Update")
	print(self.currentMessage)
	if self.currentMessage then
		self.NameEditBox:SetText(self.currentMessage.name)
		self.MessageEditBox:SetText(self.currentMessage.message)
		self:Show();
	else 
		self:Hide()
	end
end

function MessageEditorMixin:SaveMessage()
	-- TODO copy data from UI into message and DB
end