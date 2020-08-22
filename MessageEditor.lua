MessageEditorMixin = CreateFromMixins(CallbackRegistryBaseMixin, EventRegistrationHelper);
MessageEditorEvent = {
	MessageChanged = 1,
	BindingChanged = 2,
}

function MessageEditorMixin:Load()
	self:OnLoad() -- for CallbackRegistryBaseMixin:OnLoad
	self:Hide()
	self:LoadMessageTypeFrames()
	self:CreateBindingButton()
	self.OutputSelectFrame:UpdateLayout()
end

-- NOTE: Message type templates should follow the naming convention: "<MessageType>MessageTemplate"
function MessageEditorMixin:LoadMessageTypeFrames()
	self.messageTypeFrames = {}
	for messageType, i in pairs(MessageBarker_MessageTypes) do		
		local key = messageType.."ContentFrame"
		local frameName = (self:GetName() or '')..key
		local templateName = messageType.."MessageTemplate"
		local frame = CreateFrame("Frame", frameName, self, templateName)
		self[key] = frame
		frame:SetPoint("TOP", self.NameEditBox, "BOTTOM")
		frame:SetPoint("LEFT", self, "LEFT")
		frame:SetPoint("RIGHT", self.OutputSelectFrame, "LEFT")
		frame:SetPoint("BOTTOM", self, "BOTTOM")
		frame:UpdateLayout()
		frame:Hide()
		self.messageTypeFrames[i] = frame
	end
end

function MessageEditorMixin:CreateBindingButton()
	local bindingType = { Name = "MessageBarkerBinding", Type = "CustomBindingType", EnumValue = 1 }
	local handler = CustomBindingHandler:CreateHandler(bindingType);
	handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
		if completedSuccessfully then
			if keys and #keys > 0 then
				for i, k in ipairs(keys) do
					if IsMetaKey(k) then
						-- Generalizes LEFT/RIGHT modifiers
						keys[i] = k:sub(2)
					end
				end			
				local key = table.concat(keys, "-");
				self:TriggerEvent(MessageEditorEvent.BindingChanged, self.currentMessage, key)
			else
				self:ResetKeyBindingButton()
			end
		else
			self:ResetKeyBindingButton()
		end
	end);
	self.BindingButton = CustomBindingManager:RegisterHandlerAndCreateButton(handler, "CustomBindingButtonTemplateWithLabel", self)
	self.BindingButton:SetWidth(120)
	self.BindingButton.selectedHighlight:SetWidth(120)
	self.BindingButton:SetHeight(22);
	self.BindingButton:SetPoint("TOPRIGHT", self.OutputSelectFrame, "TOPLEFT");
	self.BindingButton:Show();
	self.KeyBindingFontString:SetPoint("RIGHT", self.BindingButton, "LEFT")
end

function MessageEditorMixin:SetMessage(message, keyBindings)
	self.currentMessage = message
	if self.currentMessage then
		self.NameEditBox:SetText(self.currentMessage.name or '')
		if not self.currentMessage.type then
			self.currentMessage.type = MessageBarker_MessageTypes.Basic
		end
		self.currentMessageTypeString = MessageBarker:GetMessageTypeString(self.currentMessage.type)
		--self.MessageTypeFontStringValue:SetText(self.currentMessageTypeString)
		self:UpdateKeyBindings(keyBindings)
		self:SetMessageContentFrame()
		self.OutputSelectFrame:SetMessage(self.currentMessage)
		self:Show();
	else 
		self:Hide()
	end
end

function MessageEditorMixin:UpdateKeyBindings(keyBindings)
	self.keyBindings = keyBindings
	local keyBindingsText = ''
	if keyBindings then
		-- TODO display additional bindings (in tooltip?)
		keyBindingsText = keyBindings
	end
	self.BindingButton:SetText(keyBindingsText)
end

function MessageEditorMixin:ResetKeyBindingButton()
	self:UpdateKeyBindings(self.keyBindings)
end

function MessageEditorMixin:SetMessageContentFrame()
	for _, frame in ipairs(self.messageTypeFrames) do
		frame:Hide()
	end
	local frame = self.messageTypeFrames[self.currentMessage.type]
	assert(frame, "No frame exists for message type: "..self.currentMessageTypeString)
	frame:SetMessage(self.currentMessage)
	frame:Show()
end

--[[ function MessageEditorMixin:CancelMessageEdit()
	local text = ''
	if self.currentMessage then
		text = self.currentMessage.message or ''
	end
	--self.MessageEditBox:SetText(text)
end ]]

--[[ function MessageEditorMixin:SaveMessage()
	if self.currentMessage then
		self.currentMessage.name = self.NameEditBox:GetText()
		self:TriggerEvent(MessageEditorEvent.Saving, self.currentMessage)
	end
end ]]

function MessageEditorMixin:OnNameChanged()
	self.currentMessage.name = self.NameEditBox:GetText()
	self:TriggerEvent(MessageEditorEvent.MessageChanged, self.currentMessage)
end

function MessageEditorMixin:OnShow()
	self:SetEventsRegistered(true);
end

function MessageEditorMixin:OnHide()
	self:SetEventsRegistered(false);
end