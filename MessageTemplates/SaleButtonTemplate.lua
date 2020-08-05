SaleButtonTemplateMixin = {}

function SaleButtonTemplateMixin:OnClick()
	local objectType, itemId, itemLink = GetCursorInfo()
	if objectType == "item" and not self.itemData then
		ClearCursor()
		-- TODO should probably replace this with event pattern
		local saleMessageTemplate = self:GetParent()
		table.insert(saleMessageTemplate.message.content.items, MessageFactory:CreateItemContent(itemId, itemLink))
		saleMessageTemplate:Update()
	end
end

function SaleButtonTemplateMixin:OnPriceChanged(userInput)
	if userInput then
		self.itemData.price = self.Price:GetText()
	end
end

function SaleButtonTemplateMixin:DeleteButtonClicked()
	-- TODO should probably replace this with event pattern
	local saleMessageTemplate = self:GetParent()
	tDeleteItem(saleMessageTemplate.message.content.items, self.itemData)
	saleMessageTemplate:Update()
end