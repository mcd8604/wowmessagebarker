MessageListMixin = {};
selectionListeners = {}

function MessageListMixin:OnLoad()
	self.selectedRowIndex = nil;
	local ResetMessageRow = function(pool, messageRow)
		messageRow:Reset();
	end
	self.messageRowPool = CreateFramePool("Button", self.Child, "MessageRowTemplate", ResetMessageRow);
	self.ScrollBar.Background:Hide();
	self.ScrollBar.doNotHide = true;
end

function MessageListMixin:AddSelectionListener(listenerCallback)
	print("MessageListMixin:AddSelectionListener")
	local alreadyListening = false
	for _, sL in ipairs(selectionListeners) do
		alreadyListening = alreadyListening or sL == listenerCallback
	end
	if not alreadyListening then
		table.insert(selectionListeners, listenerCallback)
	end
end

function MessageListMixin:NotifySelectionListeners(selectedIndex)
	print("MessageListMixin:NotifySelectionListeners")
	if selectionListeners then
		for _, listenerCallback in ipairs(selectionListeners) do
			listenerCallback(selectedIndex)
		end
	end
end

function MessageListMixin:ResetMessageRowAnchors()
	self.previousMessageRow = nil;
	self.messageRows = {};
end

function MessageListMixin:AddMessageRow(rowIndex, message)
	local messageRow = self.messageRowPool:Acquire();
	self:AnchorMessageRow(messageRow)
	messageRow:Setup(message)
	if self.selectedRowIndex == rowIndex then
		messageRow:LockHightlight()
	end
	messageRow:SetScript("OnClick", function(editButton, event, ...)
		MessageListMixin:SetSelectedRow(rowIndex, messageRow);
	end)
end

function MessageListMixin:AnchorMessageRow(messageRow)
	if self.previousMessageRow then
		messageRow:SetPoint("TOPLEFT", self.previousMessageRow, "BOTTOMLEFT", 0, -2);
	else
		messageRow:SetPoint("TOPLEFT", self:GetScrollChild(), "TOPLEFT");
	end
	self.previousMessageRow = messageRow;
	table.insert(self.messageRows, messageRow);
end

function MessageListMixin:SetSelectedRow(rowIndex, messageRow)
	if not self.IsSelectedRow(messageRow) then
		if self.selectedRowIndex ~= nil then
			-- TODO remove highlight/selection
		end
		-- TODO set highlight/selection
		-- messageRow.HighlightTexture:SetColorTexture(1, 1, 1, 0.6)
		--messageRow:SetBackdropColor(0,1,1)
		--messageRow:SetBackdropBorderColor(1,0,0)
		-- TODO update MessageEditor
		self.selectedRowIndex = rowIndex
		MessageEditorMixin:SetMessage(messageRow.message)
		self:NotifySelectionListeners(rowIndex)
	end
end

function MessageListMixin:IsSelectedRow(messageRowIndex)
	return self.selectedRowIndex ~= nil and self.selectedRowIndex == messageRowIndex
end

function MessageListMixin:Update()
	print("MessageListMixin:Update")
	self.messageRowPool:ReleaseAll();
	self:ResetMessageRowAnchors();
	print("Selected Row: "..(self.selectedRowIndex or 'nil'))
	local messages = MessageBarkerFrameMixin:GetMessages()
	for i, message in ipairs(messages) do
		self:AddMessageRow(i, message)
	end
	self:UpdateScrollBar();
end

function MessageListMixin:UpdateScrollBar()
	local frameHeight = 10 * #self.messageRows
	self.Child:SetHeight(frameHeight);
	--self.scrolling = frameHeight > self:GetHeight();
	--self.ScrollBar:SetShown(self.scrolling);
end