MessageListMixin = {};

function MessageListMixin:OnLoad()
	self.selectedRow = nil;
	local ResetMessageRow = function(pool, messageRow)
		messageRow:Reset();
	end
	self.messageRowPool = CreateFramePool("Frame", self.Child, "MessageRowTemplate", ResetMessageRow);
	self.ScrollBar.Background:Hide();
end

function MessageListMixin:ResetMessageRowAnchors()
	self.previousMessageRow = nil;
	self.messageRows = {};
end

function MessageListMixin:AddMessageRow(message)
	local messageRow = self.messageRowPool:Acquire();
	self:AnchorMessageRow(messageRow)
	messageRow:Setup(message)	
	messageRow.EditButton:SetScript("OnClick", function(editButton, event, ...)
		MessageListMixin:SetSelectedRow(messageRow)
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

function MessageListMixin:SetSelectedRow(messageRow)
	if not self.IsSelectedRow(messageRow) then
		if self.selectedRow ~= nil then
			-- TODO remove highlight/selection
		end
		-- TODO set highlight/selection
		-- TODO update MessageEditor
		
		self.selectedRow = messageRow
	end
end

function MessageListMixin:IsSelectedRow(messageRow)
	return self.selectedRow ~= nil and self.selectedRow == messageRow
end

function MessageListMixin:Update()
	self.messageRowPool:ReleaseAll();
	self:ResetMessageRowAnchors();    
	local messages = MessageBarkerFrameMixin:GetMessages()
	for _, message in ipairs(messages) do
		self:AddMessageRow(message)
	end
	self:UpdateScrollBar();
end

function MessageListMixin:UpdateScrollBar()
	local frameHeight = 10 * #self.messageRows
	self.Child:SetHeight(frameHeight);
	self.scrolling = frameHeight > self:GetHeight();
	self.ScrollBar:SetShown(self.scrolling);
end