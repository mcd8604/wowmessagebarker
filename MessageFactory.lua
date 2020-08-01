-- EW! Factory pattern is poop, need a more extensible way of creating objects
MessageFactory = {}

MessageBarker_MessageTypes = {
	Basic = 1,
	Sale = 2,
}

do
	local messageTypes = tInvert(MessageBarker_MessageTypes)
	function MessageFactory:GetMessageTypeString(messageType)
		return messageTypes[messageType] or 'Unknown Message Type'
	end
end

function MessageFactory:LoadFactoryMethods()
	self.MessageFactoryMethods = {
		[MessageBarker_MessageTypes.Basic]	= MessageFactory.CreateMessage_Basic,
		[MessageBarker_MessageTypes.Sale]	= MessageFactory.CreateMessage_Sale,
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

-- NOTE: Messages are persistent data objects, meaning only data is saved and the methods/functions are not.
-- This means that (since we can't use polymorphism here) the functions to generate the text for output need
-- to be separate from the data objects and we need some logic to choose functions based on the message type.
-- Unfortunately, this is another unfriendly design pattern. At the very least, we can use a lookup table
-- instead of a series of if-else statements.
-- TODO: (Another option would be to mixin the generator functions upon loading/creating the message objects)
function MessageFactory:LoadTextGenerators()
	self.TextGenerators = {
		[MessageBarker_MessageTypes.Basic]	= MessageFactory.GenerateText_Basic,
		[MessageBarker_MessageTypes.Sale]	= MessageFactory.GenerateText_Sale,
	}
end

function MessageFactory:GenerateText(message)
	assert(message)
	if not self.TextGenerators then
		self:LoadFactoryMethods()
	end	
	local generator = self.TextGenerators[message.type]
	assert(generator and type(generator) == "function", "Invalid Message Type: "..message.type)
	return generator(self, message)
end

function MessageFactory:CreateMessage_Basic()
	local newMessage = {
		id = MessageBarker:GetNextMessageID(),
		name = "New Message",
		type = MessageBarker_MessageTypes.Basic,
		content = 'Write your message content here.',
		outputs = {},
	}
	return newMessage
end

function MessageFactory:GenerateText_Basic(message)
	return message.content.text
end

function MessageFactory:CreateMessage_Sale(itemId, itemLink)
	local messageName = 'New Item Sale'
	local itemName = nil
	if itemId then
		itemName = C_Item.GetItemNameByID(itemId)
		messageName = itemName or messageName
	end
	local newMessage = {
		id = MessageBarker:GetNextMessageID(),
		name = messageName,
		type = MessageBarker_MessageTypes.Sale,
		content = {
			prefix = "WTS ",
			items = {
				{ link = itemLink, name = itemName, price = "" },
			},
			suffix = "",
		},
		outputs = {},
	}
	return newMessage
end

function MessageFactory:GenerateText_Sale(message)
	local text = ''
	if message.content.prefix then
		text = message.content.prefix .. ' '
	end
	for i, item in message.content.items do
		text = text .. '[' .. (item.link or item.name) .. (item.price or '') .. ']'
	end
	if message.content.suffix then
		text = text .. message.content.suffix
	end
	return text
end
