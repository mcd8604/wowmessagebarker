MessageTypeTemplateMixin = {}

function MessageTypeTemplateMixin:Load() end

function MessageTypeTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
end

BasicMessageTypeTemplateMixin = {}

function BasicMessageTypeTemplateMixin:Load() end

function BasicMessageTypeTemplateMixin:SetMessage(message)
	MessageTypeTemplateMixin.SetMessage(self, message)
	-- TODO test moving the anchors to Load
	self.MessageScrollFrame.MessageEditBox:SetPoint("LEFT")
	self.MessageScrollFrame.MessageEditBox:SetPoint("RIGHT")
	self.MessageScrollFrame.MessageEditBox:SetText(message.content or '')
end

function BasicMessageTypeTemplateMixin:OnTextChanged()
	self.message.content = self.MessageScrollFrame.MessageEditBox:GetText()
end

SaleMessageTypeTemplateMixin = {}

function SaleMessageTypeTemplateMixin:Load()
	--self.SaleScrollFrame.ScrollBar.doNotHide = true;
	-- NOTE: button height needs to match SaleButtonTemplate.. REEEE
	-- Can this be found dynamically intsead of hardcoding?
	self.saleButtonHeight = 37
	local ResetItemRow = function(pool, itemRow)
		itemRow.Item.IconTexture:Hide()
		itemRow.Name:SetText('')
		itemRow.Price:SetText('')
		itemRow:Hide()
	end
	self.itemRowPool = CreateFramePool("Button", self.SaleScrollFrame.ScrollChildFrame, "SaleButtonTemplate", ResetItemRow);
end

function SaleMessageTypeTemplateMixin:SetMessage(message)
	MessageTypeTemplateMixin.SetMessage(self, message)
	self:Update()
end

function SaleMessageTypeTemplateMixin:OnVerticalScroll()
	FauxScrollFrame_OnVerticalScroll(self, offset, saleButtonHeight, self:GetParent().Update);
end

function SaleMessageTypeTemplateMixin:Update()
	self.itemRowPool:ReleaseAll();
	self.itemRows = {}
	self.previousItemRow = nil;
	local numItems = #self.message.content.items + 1
	for i, item in ipairs(self.message.content.items) do
		local itemRow = self:CreateItemRow(item)
		table.insert(self.itemRows, itemRow)
	end
	-- Empty row for creating a new item
	local itemRow = self:CreateItemRow()
	table.insert(self.itemRows, itemRow)
	local numItemsRequiredToEnableDisplay = 0
	FauxScrollFrame_Update(self.SaleScrollFrame, numItems, numItemsRequiredToEnableDisplay, self.saleButtonHeight);
end

function SaleMessageTypeTemplateMixin:CreateItemRow(item)
	local row = self.itemRowPool:Acquire()
	self:AnchorItemRow(row)
	if item then
		if item.icon then
			row.Item.IconTexture:SetTexture(item.icon)
			row.Item.IconTexture:Show()
		end
		row.Name:SetText(item.name)
		row.Price:SetText(item.price)
	end
	row:Show()
	return row
end

function SaleMessageTypeTemplateMixin:AnchorItemRow(row)
	if self.previousItemRow then
		row:SetPoint("TOPLEFT", self.previousItemRow, "BOTTOMLEFT", 0, -BUTTON_SPACING);
	else
		row:SetPoint("TOPLEFT", self.SaleScrollFrame.ScrollChildFrame, "TOPLEFT");
	end
	self.previousItemRow = row;
end