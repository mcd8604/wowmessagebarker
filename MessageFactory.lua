-- EW! Factory pattern is poop, need a more extensible way of creating objects
MessageFactory = {}

MessageBarker_MessageTypes = {
	Basic = 1,
	Sale = 2,
}

function MessageFactory:LoadFactoryMethods()
	self.MessageFactoryMethods = {
		[MessageBarker_MessageTypes.Basic]	= MessageBarker.CreateMessage_Basic,
		[MessageBarker_MessageTypes.Sale]	= MessageBarker.CreateMessage_Sale,
	}
end

function MessageFactory:CreateMessageByType(messageType, ...)
	if not self.MessageFactoryMethods then
		self:LoadFactoryMethods()
	end
	local factory = self.MessageFactoryMethods[messageType]
	assert(factory and type(factory) == "function", "Invalid Message Type: "..messageType)
	return factory(self, ...)
end

function MessageFactory:CreateMessage_Basic()
	local newMessage = {
		id = MessageBarker:GetNextMessageID(),
		name = "New Message",
		type = MessageBarker_MessageTypes.Basic,
		content = { text = 'Write your message content here.' },
		outputs = {},
	}
	return newMessage
end

function MessageFactory:CreateMessage_Sale(itemId, itemLink)
	local messageName = 'New Item Sale'
	if itemId then
		messageName = C_Item.GetItemNameByID(itemId) or messageName
	end
	local newMessage = {
		id = MessageBarker:GetNextMessageID(),
		name = messageName,
		type = MessageBarker_MessageTypes.Sale,
		content = {
			itemLink = itemLink,
			price = 0,
			text = "WTS "..(itemLink or '')
		},
		outputs = {},
	}
	return newMessage
end