
CallbackRegistryBaseMixin = {};

function CallbackRegistryBaseMixin:OnLoad()
	self.callbackRegistry = {};
end

function CallbackRegistryBaseMixin:RegisterCallback(event, callback)
	if not self.callbackRegistry[event] then
		self.callbackRegistry[event] = {};
	end

	self.callbackRegistry[event][callback] = true;
end

function CallbackRegistryBaseMixin:UnregisterCallback(event, callback)
	if self.callbackRegistry[event] then
		self.callbackRegistry[event][callback] = nil;
	end
end

function CallbackRegistryBaseMixin:TriggerEvent(event, ...)
	local registry = self.callbackRegistry[event];
	if registry then
		for callback in pairs(registry) do
			callback(event, ...);
		end
	end
end

--[[static]] function CallbackRegistryBaseMixin:GenerateCallbackEvents(events)
	self.Event = tInvert(events);
end