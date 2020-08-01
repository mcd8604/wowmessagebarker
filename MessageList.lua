MessageListMixin = CreateFromMixins(CallbackRegistryBaseMixin);
MessageListEvent = {
	RowSelected = 1,
}
BUTTON_SPACING = 2

function MessageListMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self.selectedRow = nil;
	local ResetMessageRow = function(pool, messageRow)
		messageRow:Reset();
	end
	self.messageRowPool = CreateFramePool("Button", self.Child, "MessageRowTemplate", ResetMessageRow);
	self.ScrollBar.Background:Hide();
	self.ScrollBar.doNotHide = true;
end

function MessageListMixin:SetMessages(messages)
	self.messageRowPool:ReleaseAll();
	self:ResetMessageRowAnchors();
	for _, message in pairs(messages) do
		local messageRow = self:CreateMessageRow(message)
		if message == self.selectedMessage then
			self.selectedRow = messageRow
			self:HighlightRow(self.selectedRow)
		end
		table.insert(self.messageRows, messageRow)
	end
	self:UpdateScrollBar();
end

function MessageListMixin:ResetMessageRowAnchors()
	self.previousMessageRow = nil;
	self.messageRows = {};
end

function MessageListMixin:CreateMessageRow(message)
	local messageRow = self.messageRowPool:Acquire();
	self:AnchorMessageRow(messageRow)
	messageRow:Setup(message)
	messageRow:SetScript("OnClick", function(editButton, event, ...)
		self:SetSelectedRow(messageRow);
	end)
	return messageRow
end

function MessageListMixin:AnchorMessageRow(messageRow)
	if self.previousMessageRow then
		messageRow:SetPoint("TOPLEFT", self.previousMessageRow, "BOTTOMLEFT", 0, -BUTTON_SPACING);
	else
		messageRow:SetPoint("TOPLEFT", self:GetScrollChild(), "TOPLEFT");
	end
	self.previousMessageRow = messageRow;
end

function MessageListMixin:SetSelectedRow(row)
	if not self:IsSelectedRow(row) then
		-- un-highlights previously selected row
		--[[ if self.selectedRow ~= nil then
			self.selectedRow:SetHighlightAtlas("voicechat-channellist-row-highlight");
			self.selectedRow:UnlockHighlight()
		end ]]
		-- un-highlight all rows
		for i, r in ipairs(self.messageRows) do
			r:SetHighlightAtlas("voicechat-channellist-row-highlight");
			r:UnlockHighlight()
		end
		self.selectedRow = row
		self.selectedMessage = row.message
		self:HighlightRow(self.selectedRow)
		self:TriggerEvent(MessageListEvent.RowSelected, row.message)
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
--[[ 	local selectedMessage = nil
	if self.selectedRow then
		selectedMessage = self.selectedRow.message
	end
	return selectedMessage ]]
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