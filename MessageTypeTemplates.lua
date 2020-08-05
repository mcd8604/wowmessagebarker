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
	self:LoadButtonRows()
	self.SaleScrollFrame.scrollBarHideable = 1;
	ScrollFrame_OnLoad(self.SaleScrollFrame);
	ScrollFrame_OnScrollRangeChanged(self.SaleScrollFrame);
end

function SaleMessageTypeTemplateMixin:LoadButtonRows()
	self.buttonNamePrefix = (self:GetName() or "SaleMessageFrame").."SaleButton"
	self.buttonRows = { self:CreateRow(1) }
	self.saleButtonHeight = self.buttonRows[1]:GetHeight()
	self.buttonRows[1]:SetPoint("TOPLEFT", self.SaleScrollFrame);
	self:LoadButtonSizes()
	for i = 2, self.maxNumButtonsVisible do
		local row = self:CreateRow(i)
		row:SetPoint("TOPLEFT", self.buttonRows[i-1], "BOTTOMLEFT", 0, -self.saleButtonSpacing);
		table.insert(self.buttonRows, row)
	end
end

function SaleMessageTypeTemplateMixin:CreateRow(i)
	local name = format("%s%i", self.buttonNamePrefix, i)
	local row = CreateFrame("Button", name, self, "SaleButtonTemplate");
	row:SetPoint("RIGHT", self.SaleScrollFrame);
	return row
end

function SaleMessageTypeTemplateMixin:LoadButtonSizes()
	-- TODO move button spacing to keyvalue xml?
	self.saleButtonSpacing = 2
	local totalButtonHeight = (self.saleButtonHeight + self.saleButtonSpacing)
	self.maxNumButtonsVisible = 1
	if totalButtonHeight ~= 0 then
		self.SaleScrollFrame.ScrollBar.scrollStep = totalButtonHeight;
		self.maxNumButtonsVisible = floor(self.SaleScrollFrame:GetHeight() / totalButtonHeight)
	end
end

function SaleMessageTypeTemplateMixin:SetMessage(message)
	MessageTypeTemplateMixin.SetMessage(self, message)
	self:Update()
end

function SaleMessageTypeTemplateMixin:OnVerticalScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self.SaleScrollFrame, offset, self.saleButtonHeight, SaleScrollFrame_Update);
end

function SaleScrollFrame_Update(self)
	self:GetParent():Update()
end

function SaleMessageTypeTemplateMixin:GetRowData(index)
	return self.message.content.items[index]
end

function SaleMessageTypeTemplateMixin:GetNumItems()
	-- Add 1 to display an empty row for creating a new item
	return #self.message.content.items + 1
end

function SaleMessageTypeTemplateMixin:Update()
	local numItems = self:GetNumItems()
	-- iterate the row buttons and update the data and visibility
	for i = 1, self.maxNumButtonsVisible do
		-- offset is the (0-based) index of the first visible item
		local index = self.SaleScrollFrame.offset + i
		local row = self.buttonRows[i]
		if index <= numItems then
			self:SetRowData(row, self:GetRowData(index))
			row:Show() 
		else
			self:ResetItemRow(row)
			row:Hide()
		end
	end
	-- temporary width values until this is working
	local smallWidth = 200
	local bigWidth = 220
	FauxScrollFrame_Update(self.SaleScrollFrame, numItems, self.maxNumButtonsVisible, self.saleButtonHeight, self.buttonNamePrefix, smallWidth, bigWidth)
end

function SaleMessageTypeTemplateMixin:ResetItemRow(row)
	row.itemData = nil
	row.Item.IconTexture:Hide()
	row.Name:SetText("Place item to add")
	row.Price:SetText('')
end

function SaleMessageTypeTemplateMixin:SetRowData(row, item)
	if item then
		row.itemData = item
		if item.icon then
			row.Item.IconTexture:SetTexture(item.icon)
			row.Item.IconTexture:Show()
		end
		row.Name:SetText(item.name)
		row.Price:SetText(item.price)
	else
		-- Empty row for creating a new item
		self:ResetItemRow(row)
	end
end

SaleButtonTemplateMixin = {}

function SaleButtonTemplateMixin:OnClick()
	local objectType, itemId, itemLink = GetCursorInfo()
	print(self:GetName())
	if objectType == "item" and not self.itemData then
		ClearCursor()
		-- TODO should probably replace this with event pattern
		local saleMessageTypeTemplate = self:GetParent()
		table.insert(saleMessageTypeTemplate.message.content.items, MessageFactory:CreateItemContent(itemId, itemLink))
		saleMessageTypeTemplate:Update()
	end
end