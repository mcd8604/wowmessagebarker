MessageBarker = {}

-- Slash Commands
SLASH_MESSAGEBARKER1, SLASH_MESSAGEBARKER2, SLASH_MESSAGEBARKER3 = "/bm", "/barkmsg", "/barkmessage"
SlashCmdList.MESSAGEBARKER = function(msg, editBox)
	MessageBarker:BarkMessage(msg, MessageBarkerDB.char.testOutputMode or false)
end

function MessageBarker:BarkMessage(messageId, testOutput)
	if messageId then
		local message = self:GetMessageById(messageId)
		if message and message.outputs then
			for _, output in pairs(message.outputs) do
				if testOutput then
					self:TestMessageOutput(message, output)
				else
					SendChatMessage(message.message, output.chatType, nil, output.channelId)
				end
			end
		end
	end
end

function MessageBarker:TestMessageOutput(message, output)
	local messageToPrint = nil
	if output.channelId ~= nil then
		messageToPrint = format("[%s(%i)]: %s", _G[output.chatType], output.channelId, message.message)
	else 
		messageToPrint = format("[%s]: %s", _G[output.chatType], message.message)
	end
	print(messageToPrint)
end

-- Ensures the messages table is never nil
function MessageBarker:EnsureDB()
	if not MessageBarkerDB then
		self.InitializeDB()
	end
	if not MessageBarkerDB.factionrealm then
		MessageBarkerDB.factionrealm = self:GetDefaultFactionRealmDB()
	end
	if not MessageBarkerDB.factionrealm.messages then
		MessageBarkerDB.factionrealm.messages = {}
	end
end

function MessageBarker:InitializeDB()
	MessageBarkerDB = LibStub("AceDB-3.0"):New("MessageBarkerDB", {
		factionrealm = self:GetDefaultFactionRealmDB(),
		char = {
			minimapButton = {hide = false},
			testOutputMode = false
		}
	}, true)
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
	return MessageBarkerDB.factionrealm.messages
end

function MessageBarker:GetMessageById(messageId)
	self:EnsureDB()
	return MessageBarkerDB.factionrealm.messages[tonumber(messageId)]
end

function MessageBarker:SaveMessage(message)
	if message and message.id then
		self:EnsureDB()
		MessageBarkerDB.factionrealm.messages[message.id] = message
	end
end

function MessageBarker:DeleteMessage(message)
	if message and message.id then
		local messages = self:GetMessages()
		messages[message.id] = nil
	end
end

-- NOTE: Doesn't account for number overflow, though is highly unlikely
function MessageBarker:GetNextMessageID()
	if not MessageBarkerDB.factionrealm.nextId then
		MessageBarkerDB.factionrealm.nextId = 1
	end
	local newId = MessageBarkerDB.factionrealm.nextId
	-- make sure new Id is max in case the sequence was altered inappropriately
	local maxId = self:GetMaxMessageID()
	if newId <= maxId then
		newId = maxId + 1
	end
	MessageBarkerDB.factionrealm.nextId = newId + 1
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