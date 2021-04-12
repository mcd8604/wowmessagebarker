MessageBarker = LibStub("AceAddon-3.0"):NewAddon("MessageBarker")

CallbackRegistryBaseMixin = {};

function CallbackRegistryBaseMixin:OnLoad()
	self.callbackRegistry = {};
end

function CallbackRegistryBaseMixin:RegisterCallback(event, callback)
	if not self.callbackRegistry[event] then
		self.callbackRegistry[event] = {};
	end

	self.callbackRegistry[event][callback] = true;
end

function CallbackRegistryBaseMixin:UnregisterCallback(event, callback)
	if self.callbackRegistry[event] then
		self.callbackRegistry[event][callback] = nil;
	end
end

function CallbackRegistryBaseMixin:TriggerEvent(event, ...)
	local registry = self.callbackRegistry[event];
	if registry then
		for callback in pairs(registry) do
			callback(event, ...);
		end
	end
end

--[[static]] function CallbackRegistryBaseMixin:GenerateCallbackEvents(events)
	self.Event = tInvert(events);
end

MessageBarker = Mixin(MessageBarker, CallbackRegistryBaseMixin, MessageFactory);
MessageBarker.callbackRegistry = {};
MessageBarkerEvent = {
	Initialized = 1,
	MessageAdded = 2,
	MessageDeleted = 3,	
}

-- Slash Commands
SLASH_MESSAGEBARKER1, SLASH_MESSAGEBARKER2, SLASH_MESSAGEBARKER3 = "/bm", "/barkmsg", "/barkmessage"
SlashCmdList.MESSAGEBARKER = function(msg, editBox)
	MessageBarker:BarkMessage(msg, MessageBarker.db.char.testOutputMode or false)
end

function MessageBarker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MessageBarkerDB", {
		factionrealm = self:GetDefaultFactionRealmDB(),
		char = {
			minimapButton = {hide = false},
			testOutputMode = false
		}
	}, true)
	self:TriggerEvent(MessageBarkerEvent.Initialized)
end

function MessageBarker:BarkMessage(messageId, testOutput)
	if messageId then
		if testOutput == nil then
			testOutput = self.db.char.testOutputMode
		end
		local message = self:GetMessageById(messageId)
		if message and message.outputs then
			for _, output in pairs(message.outputs) do
				if testOutput then
					self:TestMessageOutput(message, output)
				else
					SendChatMessage(self:GenerateText(message), output.chatType, nil, self:LookupChannelID(output.channel) or 0)
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