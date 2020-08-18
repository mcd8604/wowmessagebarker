SaleMessageTemplateMixin = {}

function SaleMessageTemplateMixin:UpdateLayout()
	self.SaleScrollFrame:UpdateLayout()
end

function SaleMessageTemplateMixin:SetMessage(message)
	MessageTemplateMixin.SetMessage(self, message)
	self.SaleScrollFrame.message = message
	self.PrefixEditBox:SetText(self.message.content.prefix)
	self.SuffixEditBox:SetText(self.message.content.suffix)
	self.SaleScrollFrame:Update()
end

function SaleMessageTemplateMixin:AddItem(itemId, itemLink)
	table.insert(self.message.content.items, MessageFactory:CreateItemContent(itemId, itemLink))
	self.SaleScrollFrame:Update()
end

function SaleMessageTemplateMixin:DeleteItem(item)
	tDeleteItem(self.message.content.items, item)
	self.SaleScrollFrame:Update()
end

SaleScrollFrameMixin = {}

function SaleScrollFrameMixin:GetRowData(index)
	return self.message.content.items[index]
end

function SaleScrollFrameMixin:GetNumItems()
	-- Add 1 to display an empty row for creating a new item
	return #self.message.content.items + 1
end

function SaleScrollFrameMixin:ResetItemRow(row)
	row.itemData = nil
	row.Item.IconTexture:Hide()
	row.Name:SetText("Place item to add")
	row.Price:SetText('')
	row.Price:Hide()
	row.DeleteButton:Hide()
end

function SaleScrollFrameMixin:SetRowData(row, item)
	if item then
		row.itemData = item
		if item.icon then
			row.Item.IconTexture:SetTexture(item.icon)
			row.Item.IconTexture:Show()
		end
		row.Name:SetText(item.name)
		row.Price:SetText(item.price)
		row.Price:Show()
		row.DeleteButton:Show()
	else
		-- Empty row for creating a new item
		self:ResetItemRow(row)
	end
end