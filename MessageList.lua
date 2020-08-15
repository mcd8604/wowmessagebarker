MessageListMixin = CreateFromMixins(CallbackRegistryBaseMixin);
MessageListEvent = {
	RowSelected = 1,
}
BUTTON_SPACING = 2

function MessageListMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self.selectedRow = nil;
	self.messageRows = {};
	self.ScrollBar.Background:Hide();
	self.ScrollBar.doNotHide = true;
end

function MessageListMixin:SetMessages(messages)
	for _, message in pairs(messages) do
		local messageRow = self:GetMessageRow(message)
		if message == self.selectedMessage then
			self.selectedRow = messageRow
			self:HighlightRow(self.selectedRow)
		end
	end
	table.sort(self.messageRows, function(a, b) return a.message.id < b.message.id end)
	self:ResetMessageRowAnchors()
	self:UpdateScrollBar();
end

function MessageListMixin:GetMessageRow(message)
	local rowIndex, messageRow = self:FindMessageRow(message.id)
	if not rowIndex then
		messageRow = self:CreateMessageRow(message)
		table.insert(self.messageRows, messageRow)
	end
	messageRow:Setup(message)
	return messageRow
end

function MessageListMixin:FindMessageRow(messageId)
	return FindInTableIf(self.messageRows, function(row) return row.message.id == messageId end)
end

function MessageListMixin:CreateMessageRow(message)
	local name = self:GetName().."MessageRow"..message.id
	local messageRow = CreateFrame("Button", name, self.Child, "MessageRowTemplate")
	messageRow:SetScript("OnClick", function(editButton, event, ...)
		self:SetSelectedRow(messageRow);
	end)
	return messageRow
end

function MessageListMixin:ResetMessageRowAnchors()
	local previousMessageRow = nil;	
	for _, messageRow in ipairs(self.messageRows) do
		messageRow:ClearAllPoints()
	end
	for _, messageRow in ipairs(self.messageRows) do
		if previousMessageRow then
			messageRow:SetPoint("TOPLEFT", previousMessageRow, "BOTTOMLEFT", 0, -BUTTON_SPACING);
		else
			messageRow:SetPoint("TOPLEFT");
		end
		previousMessageRow = messageRow;
	end
end

function MessageListMixin:SetSelectedRow(row)
	self:UnhighlightAllRows()
	if not self:IsSelectedRow(row) then
		self.selectedRow = row
		if self.selectedRow then
			self.selectedMessage = row.message
			self:HighlightRow(self.selectedRow)
			self:TriggerEvent(MessageListEvent.RowSelected, row.message, row.keyBindings)
		else
			self:TriggerEvent(MessageListEvent.RowSelected)
		end
	end
end

function MessageListMixin:UnhighlightAllRows()
	for _, r in ipairs(self.messageRows) do
		r:SetHighlightAtlas("voicechat-channellist-row-highlight");
		r:UnlockHighlight()
	end
end

function MessageListMixin:HighlightRow(row)
	self.selectedRow:SetHighlightAtlas("voicechat-channellist-row-selected");
	self.selectedRow:LockHighlight()
end

function MessageListMixin:IsSelectedRow(row)
	return self.selectedRow ~= nil and self.selectedRow == row
end

function MessageListMixin:GetSelectedMessage()
	return self.selectedMessage
end

function MessageListMixin:UpdateScrollBar()
	self.Child:SetHeight(self:GetScrollFrameHeight());
	--self.scrolling = frameHeight > self:GetHeight();
	--self.ScrollBar:SetShown(self.scrolling);
end

function MessageListMixin:GetScrollFrameHeight()
	local totalButtonHeight = 0
	for _, messageRow in ipairs(self.messageRows) do
		totalButtonHeight = totalButtonHeight + messageRow:GetHeight()
	end
	local totalButtonSpacing = BUTTON_SPACING * (#self.messageRows - 1)
	return totalButtonHeight + totalButtonSpacing
end

function MessageListMixin:DeleteMessageRow(messageId)
	local rowIndex, messageRow = self:FindMessageRow(messageId)
	if rowIndex then
		if self:IsSelectedRow(messageRow) then
			self:SetSelectedRow()
		end
		table.remove(self.messageRows, rowIndex)
		--local name = messageRow:GetName()
		--if name and _G[name] then
		--	_G[name] = nil
		--end
		-- This frame will never actually be removed, so hide it
		messageRow:Hide()
		-- TODO delete keybind
		self:ResetMessageRowAnchors()
	end
end

function MessageListMixin:UpdateKeyBindings()
	if self.messageRows then
		for _, row in ipairs(self.messageRows) do
			row:UpdateKeyBindings()
		end
	end
end