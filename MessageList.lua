MessageListMixin = {};
selectionListeners = {}
BUTTON_SPACING = 2

function MessageListMixin:OnLoad()
	print('List:OnLoad')
	self.selectedRow = nil;
	local ResetMessageRow = function(pool, messageRow)
		messageRow:Reset();
	end
	self.messageRowPool = CreateFramePool("Button", self.Child, "MessageRowTemplate", ResetMessageRow);
	self.ScrollBar.Background:Hide();
	self.ScrollBar.doNotHide = true;
end

function MessageListMixin:SetMessages(messages)
	self.selectedRow = nil;
	self.messageRowPool:ReleaseAll();
	self:ResetMessageRowAnchors();
	for _, message in pairs(messages) do
		self:AddMessageRow(message)
	end
	self:UpdateScrollBar();
end

function MessageListMixin:ResetMessageRowAnchors()
	self.previousMessageRow = nil;
	self.messageRows = {};
end

function MessageListMixin:AddMessageRow(message)
	local messageRow = self.messageRowPool:Acquire();
	self:AnchorMessageRow(messageRow)
	messageRow:Setup(message)
	if self.selectedRow and self.selectedRow.message == message then
		messageRow:LockHighlight()
	end
	messageRow:SetScript("OnClick", function(editButton, event, ...)
		self:SetSelectedRow(messageRow);
	end)
end

function MessageListMixin:AnchorMessageRow(messageRow)
	if self.previousMessageRow then
		messageRow:SetPoint("TOPLEFT", self.previousMessageRow, "BOTTOMLEFT", 0, -BUTTON_SPACING);
	else
		messageRow:SetPoint("TOPLEFT", self:GetScrollChild(), "TOPLEFT");
	end
	self.previousMessageRow = messageRow;
	table.insert(self.messageRows, messageRow);
end

function MessageListMixin:SetSelectedRow(row)
	if not self:IsSelectedRow(row) then
		if self.selectedRow ~= nil then
			self.selectedRow:SetHighlightAtlas("voicechat-channellist-row-highlight");
			self.selectedRow:UnlockHighlight()
		end
		self.selectedRow = row
		if self.selectedRow then
			self.selectedRow:SetHighlightAtlas("voicechat-channellist-row-selected");
			self.selectedRow:LockHighlight()
		end
		self:NotifySelectionListeners(row.message)
	end
end

function MessageListMixin:IsSelectedRow(row)
	return self.selectedRow ~= nil and self.selectedRow == row
end

function MessageListMixin:AddSelectionListener(listenerCallback)
	local alreadyListening = false
	for _, sL in ipairs(selectionListeners) do
		alreadyListening = alreadyListening or sL == listenerCallback
	end
	if not alreadyListening then
		table.insert(selectionListeners, listenerCallback)
	end
end

function MessageListMixin:NotifySelectionListeners(message)
	if selectionListeners then
		for _, listenerCallback in ipairs(selectionListeners) do
			listenerCallback(message)
		end
	end
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