ItemListScrollFrameMixin = {}

function ItemListScrollFrameMixin:OnLoad()
	self:InitializeKeyValues()
	self.layoutComplete = false
end

function ItemListScrollFrameMixin:InitializeKeyValues()
	self:InitializeItemRowNamePrefix()
	self.itemRowSpacing = self.itemRowSpacing or 0
	self.itemRowFrameType = self.itemRowFrameType or "Frame"
end

function ItemListScrollFrameMixin:InitializeItemRowNamePrefix()
	if not self.itemRowNamePrefix then 
		local parent = self:GetParent()
		if parent then
			local parentName = parent:GetName()
			if parentName then
				self.itemRowNamePrefix = parentName.."_ItemList_".."ItemRow"
			end
		end 
	end
end

function ItemListScrollFrameMixin:UpdateLayout()
	-- NOTE: for now, only allow layout to happen one time in order to prevent creation of frames every layout
	-- In the future, add code to re-use existing frames, hide unneeded frames, and only create new frames when necessary
	-- otherwise, there will be a memory leak
	-- This will be necessary for resizing the container (b/c the number of visible items may change)
	if not self.layoutComplete then
		self:InitializeItemRowFrames()
		self.layoutComplete = true
	end
end

function ItemListScrollFrameMixin:InitializeItemRowFrames()
	self.itemRows = { self:CreateItemRow(1) }
	self.itemRowHeight = self.itemRows[1]:GetHeight()
	self.itemRows[1]:SetPoint("TOPLEFT", self);
	self:CalculateMaxNumButtonsVisible()
	for i = 2, self.maxNumButtonsVisible do
		local row = self:CreateItemRow(i)
		row:SetPoint("TOPLEFT", self.itemRows[i-1], "BOTTOMLEFT", 0, -self.itemRowSpacing);
		table.insert(self.itemRows, row)
	end
end

function ItemListScrollFrameMixin:CreateItemRow(i)
	local name = nil
	if self.itemRowNamePrefix then
		name = format("%s%i", self.itemRowNamePrefix, i)
	end
	local row = CreateFrame(self.itemRowFrameType, name, self:GetParent(), self.itemRowTemplate);
	return row
end

function ItemListScrollFrameMixin:CalculateMaxNumButtonsVisible()
	local totalButtonHeight = (self.itemRowHeight + self.itemRowSpacing)
	self.maxNumButtonsVisible = 1
	if totalButtonHeight ~= 0 then
		self.ScrollBar.scrollStep = totalButtonHeight;
		self.maxNumButtonsVisible = floor(self:GetHeight() / totalButtonHeight)
	end
end

function ItemListScrollFrameMixin:Update()
	if self.GetNumItems and self.maxNumButtonsVisible and self.itemRows then
		local numItems = self:GetNumItems()
		-- iterate the row buttons and update the data and visibility
		for i = 1, self.maxNumButtonsVisible do
			-- offset is the (0-based) index of the first visible item
			local index = (self.offset or 0) + i
			local row = self.itemRows[i]
			if index <= numItems then
				if self.SetRowData then
					self:SetRowData(row, self:GetRowData(index))
				end
				row:Show() 
			else
				if self.ResetItemRow then
					self:ResetItemRow(row)
				end
				row:Hide()
			end
		end
		local smallWidth = self:GetWidth()
		local bigWidth = self:GetWidth() + self.ScrollBar:GetWidth()
		FauxScrollFrame_Update(self, numItems, self.maxNumButtonsVisible, self.itemRowHeight, self.itemRowNamePrefix, smallWidth, bigWidth)
	end
end