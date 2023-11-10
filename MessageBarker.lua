MessageBarker = LibStub("AceAddon-3.0"):NewAddon("MessageBarker")
MessageBarker = Mixin(MessageBarker, CallbackRegistryBaseMixin, MessageFactory);
MessageBarker.callbackRegistry = {};
MessageBarkerEvent = {
	Initialized = 1,
	MessageAdded = 2,
	MessageDeleted = 3,	
}

function MessageBarker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MessageBarkerDB", {
		factionrealm = self:GetDefaultFactionRealmDB(),
		char = {
			minimapButton = {hide = false},
			testOutputMode = false
		}
	}, true)
	MessageBarkerCommands:InitMinimapIcon();
	self:TriggerEvent(MessageBarkerEvent.Initialized)
end

function MessageBarker:BarkMessage(messageId)
	if messageId then
		local message = self:GetMessageById(messageId)
		if message and message.outputs then
			for _, output in pairs(message.outputs) do
				if self.db.char.testOutputMode then
					self:TestMessageOutput(message, output)
				else					
					if output.chatType == "CHANNEL" then
						local channelId = self:LookupChannelID(output.channel) or 0
						if channelId > 0 then
							SendChatMessage(self:GenerateText(message), output.chatType, nil, channelId)
						end
					else
						SendChatMessage(self:GenerateText(message), output.chatType)
					end
				end
			end
		end
	end
end

function MessageBarker:TestMessageOutput(message, output)
	local messageToPrint = nil
	if output.channel ~= nil then
		messageToPrint = format("[%s(%i)]: %s", _G[output.chatType], self:LookupChannelID(output.channel), self:GenerateText(message))
	else 
		messageToPrint = format("[%s]: %s", _G[output.chatType], self:GenerateText(message))
	end
	print(messageToPrint)
end

function MessageBarker:LookupChannelID(channelName)
	local id = 0
	if channelName then
		id, _, _ = GetChannelName(channelName)
	end
	return id
end

-- Ensures the messages table is never nil
function MessageBarker:EnsureDB()
	--if not MessageBarkerDB.factionrealm then
	--	MessageBarkerDB.factionrealm = self:GetDefaultFactionRealmDB()
	--end
	--if not MessageBarkerDB.factionrealm.messages then
	--	MessageBarkerDB.factionrealm.messages = {}
	--end
end

function MessageBarker:GetDefaultFactionRealmDB()
	return {
		messages = {},
		sequences = {},
		nextId = 1
	}
end

function MessageBarker:GetMessages()
	self:EnsureDB()
	return self.db.factionrealm.messages
end

function MessageBarker:GetMessageById(messageId)
	self:EnsureDB()
	return self.db.factionrealm.messages[tonumber(messageId)]
end

function MessageBarker:SaveMessage(message)
	if message and message.id then
		self:EnsureDB()
		self.db.factionrealm.messages[message.id] = message
	end
end

function MessageBarker:DeleteMessage(message)
	if message and message.id then
		local messages = self:GetMessages()
		messages[message.id] = nil
		self:TriggerEvent(MessageBarkerEvent.MessageDeleted, message.id)
	end
end

-- NOTE: Doesn't account for number overflow, though is highly unlikely
function MessageBarker:GetNextMessageID()
	if not self.db.factionrealm.nextId then
		self.db.factionrealm.nextId = 1
	end
	local newId = self.db.factionrealm.nextId
	-- make sure new Id is max in case the sequence was altered inappropriately
	local maxId = self:GetMaxMessageID()
	if newId <= maxId then
		newId = maxId + 1
	end
	self.db.factionrealm.nextId = newId + 1
	return newId
end

function MessageBarker:GetMaxMessageID()
	local maxId = -1
	for id, message in pairs(self:GetMessages()) do
		if id > maxId then
			maxId = id
		end
	end
	return maxId
end

function MessageBarker:AddNewMessage(message)
	assert(message, "Tried to add a nil message")
	local messages = MessageBarker:GetMessages()
	-- prevent adding an existing message
	if not tContains(messages, message) then
		messages[message.id] = message
		self:TriggerEvent(MessageBarkerEvent.MessageAdded, message)
	end
end