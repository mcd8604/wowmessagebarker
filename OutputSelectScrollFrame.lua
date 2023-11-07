OutputSelectScrollFrameMixin = {}

local dynamicEvents = {
	"CHANNEL_UI_UPDATE",
	"CHANNEL_LEFT",
};

function OutputSelectScrollFrameMixin:OnLoad()
	ItemListScrollFrameMixin.OnLoad(self)
end

function OutputSelectScrollFrameMixin:OnEvent(event, ...)
	if event == "CHANNEL_UI_UPDATE" then
		self:UpdateOutputs()
	end
end

function OutputSelectScrollFrameMixin:SetMessage(message)
	self.message = message
	self:UpdateOutputs()
end

function OutputSelectScrollFrameMixin:UpdateOutputs()
	self.outputs = self:GetDefaultChatOutputs()
	tAppendAll(self.outputs, self:GetChannelOutputs())
	self:Update()
end

function OutputSelectScrollFrameMixin:GetRowData(index)
	return self.outputs[index]
end

function OutputSelectScrollFrameMixin:GetNumItems()
	return #self.outputs
end

function OutputSelectScrollFrameMixin:CreateItemRow(i)
	local row = ItemListScrollFrameMixin.CreateItemRow(self, i)
	row.CheckButton:SetScript("OnClick", function(checkButton, ...)
		if row.CheckButton:GetChecked() then
			self:AddMessageOutput(row.output)
		else
			self:RemoveMessageOutput(row.output)
		end
	end)
	return row
end

function OutputSelectScrollFrameMixin:ResetItemRow(row)
	row.CheckButton:SetChecked(false)
	row.CheckButton.Text:SetText('');
end

function OutputSelectScrollFrameMixin:SetRowData(row, item)
	if item then
		local outputName = item.display or item.channel
		row.CheckButton.Text:SetText(outputName);
		local checked = self:IndexOfMessageOutput(self.message.outputs, item) ~= nil
		row.CheckButton:SetChecked(checked)
		row.output = item
	end
end

-- SendChatMessage(msg [, chatType, languageID, target])
function OutputSelectScrollFrameMixin:GetDefaultChatOutputs()
	return {
		{ chatType = "SAY", 			display = SAY },
		{ chatType = "EMOTE", 			display = EMOTE },
		{ chatType = "YELL", 			display = YELL },
		{ chatType = "PARTY", 			display = PARTY },
		{ chatType = "RAID", 			display = RAID },
		{ chatType = "RAID_WARNING", 	display = RAID_WARNING },
		{ chatType = "INSTANCE_CHAT", 	display = INSTANCE_CHAT },
		{ chatType = "GUILD", 			display = GUILD },
		{ chatType = "OFFICER", 		display = OFFICER },
	}
end

function OutputSelectScrollFrameMixin:GetChannelOutputs()
	-- Union the the player's currently joined channels with the message's existing channel outputs
	local channelOutputs = self:ConvertChannelList(GetChannelList())
	self:EnsureMessageOutputs()
	for _, output in ipairs(self.message.outputs) do
		if output.chatType == "CHANNEL" then
			-- check if output exists in channelOutputs
			if not self:IndexOfMessageOutput(channelOutputs, output) then
				table.insert(channelOutputs, output)
			end
		end
	end
	return channelOutputs
end

function OutputSelectScrollFrameMixin:ConvertChannelList(...)
	local channelOutputs = {}
	for i=1, select("#", ...), 3 do
		--local channelID = select(i, ...);
		local channel = select(i+1, ...);
		--local disabled = select(i+2, ...);
		table.insert(channelOutputs, { chatType = "CHANNEL", channel = channel })
	end
	return channelOutputs
end

function OutputSelectScrollFrameMixin:AddMessageOutput(output)
	self:EnsureMessageOutputs()
	if not self:IndexOfMessageOutput(self.message.outputs, output) then
		table.insert(self.message.outputs, output)
		self:UpdateOutputs()
	end
end

function OutputSelectScrollFrameMixin:RemoveMessageOutput(output)
	self:EnsureMessageOutputs()
	local index = self:IndexOfMessageOutput(self.message.outputs, output)
	if index then
		self.message.outputs[index] = nil
		self:UpdateOutputs()
	end
end

function OutputSelectScrollFrameMixin:IndexOfMessageOutput(outputs, output)
	local index = nil
	if output then
		index, _ = FindInTableIf(outputs, function(other) 
			return output.chatType == other.chatType and
				(output.chatType ~= "CHANNEL" or (output.channel and output.channel == other.channel))
		end)
	end
	return index
end

function OutputSelectScrollFrameMixin:EnsureMessageOutputs()
	local ensured = false
	if self.message then
		if not self.message.outputs then
			self.message.outputs = {}
		end
		ensured = true
	end
	return ensured
end

function OutputSelectScrollFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, dynamicEvents);
end

function OutputSelectScrollFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, dynamicEvents);
end