// Made by Hackcraft STEAM_0:1:50714411

if !CLIENT then return end

// I'll probably change this later on, feel free to make the chat fancier for your server if you want
local ChatMessages = {}
ChatMessages[1] = function() chat.AddText(Color(255,114,0), "Drive on Water activated, my Lord!") surface.PlaySound("HL1/fvox/activated.wav") end
ChatMessages[2] = function() chat.AddText(Color(255,114,0), "Drive on Water is already activated, my Lord!") end
ChatMessages[3] = function() chat.AddText(Color(255,114,0), "Drive on Water deactivated, my Lord!") surface.PlaySound("HL1/fvox/deactivated.wav") end
ChatMessages[4] = function() chat.AddText(Color(255,114,0), "Drive on Water is already deactivated, my Lord!") end
ChatMessages[5] = function() surface.PlaySound("items/battery_pickup.wav") end -- it's this or send lua

net.Receive("DriveonWaterChatMessage", function()
	local num = net.ReadInt(16)
	if ChatMessages[num] == nil then return end
	ChatMessages[num]()
end) 