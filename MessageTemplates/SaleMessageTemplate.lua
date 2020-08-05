SaleMessageTemplateMixin = {}

function SaleMessageTemplateMixin:Load()
	self:LoadButtonRows()
	self.SaleScrollFrame.scrollBarHideable = 1;
	ScrollFrame_OnLoad(self.SaleScrollFrame);
	ScrollFrame_OnScrollRangeChanged(self.SaleScrollFrame);
end

function SaleMessageTemplateMixin:LoadButtonRows()
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

function SaleMessageTemplateMixin:CreateRow(i)
	local name = format("%s%i", self.buttonNamePrefix, i)
	local row = CreateFrame("Button", name, self, "SaleButtonTemplate");
	row:SetPoint("RIGHT", self.SaleScrollFrame);
	return row
end

function SaleMessageTemplateMixin:LoadButtonSizes()
	-- TODO move button spacing to keyvalue xml?
	self.saleButtonSpacing = 2
	local totalButtonHeight = (self.saleButtonHeight + self.saleButtonSpacing)
	self.maxNumButtonsVisible = 1
	if totalButtonHeight ~= 0 then
		self.SaleScrollFrame.ScrollBar.scrollStep = totalButtonHeight;
		self.maxNumButtonsVisible = floor(self.SaleScrollFrame:GetHeight() / totalButtonHeight)
	end
end

function SaleMessageTemplateMixin:SetMessage(message)
	MessageTemplateMixin.SetMessage(self, message)
	self.PrefixEditBox:SetText(self.message.content.prefix)
	self.SuffixEditBox:SetText(self.message.content.suffix)
	self:Update()
end

function SaleMessageTemplateMixin:OnVerticalScroll(offset)
	
end

function SaleMessageTemplateMixin:GetRowHeight()
	return self.saleButtonHeight
end

function SaleMessageTemplateMixin:GetRowData(index)
	return self.message.content.items[index]
end

function SaleMessageTemplateMixin:GetNumItems()
	-- Add 1 to display an empty row for creating a new item
	return #self.message.content.items + 1
end

function SaleMessageTemplateMixin:Update()
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

function SaleMessageTemplateMixin:ResetItemRow(row)
	row.itemData = nil
	row.Item.IconTexture:Hide()
	row.Name:SetText("Place item to add")
	row.Price:SetText('')
end

function SaleMessageTemplateMixin:SetRowData(row, item)
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