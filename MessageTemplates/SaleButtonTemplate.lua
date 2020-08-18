SaleButtonTemplateMixin = {}

function SaleButtonTemplateMixin:OnClick()
	local objectType, itemId, itemLink = GetCursorInfo()
	if objectType == "item" and not self.itemData then
		ClearCursor()
		-- TODO should probably replace this with event pattern
		self:GetParent():AddItem(itemId, itemLink)
	end
end

function SaleButtonTemplateMixin:OnPriceChanged(userInput)
	if userInput then
		self.itemData.price = self.Price:GetText()
	end
end

function SaleButtonTemplateMixin:DeleteButtonClicked()
	-- TODO should probably replace this with event pattern
	self:GetParent():DeleteItem(self.itemData)
end