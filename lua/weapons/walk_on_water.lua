// Made by Hackcraft STEAM_0:1:50714411
SWEP.PrintName			= "Walk On Water!" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "Hackcraft" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Instructions		= "Left click to enable, right click to disable!"

SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel(viewmodel)
    return true
end

function SWEP:PrimaryAttack()
	if SERVER then
		if self.Owner:CanWaterEnt() then self.Owner:WalkonWaterMessage(2) return end
		self.Owner:EnableWaterEnt()
		self.Owner:WalkonWaterMessage(1) 
	end
		//chat.AddText(Color(255,91,0), "Walk on Water enabled my lord!")
end
 
function SWEP:SecondaryAttack()
	if SERVER then
		if !self.Owner:CanWaterEnt() then self.Owner:WalkonWaterMessage(4) return end
		self.Owner:DisableWaterEnt()
		self.Owner:WalkonWaterMessage(3) 
	end
		//chat.AddText(Color(255,91,0), "Walk on Water disabled my lord!")
end

if SERVER then
	function SWEP:Equip( NewOwner )
		if NewOwner:IsPlayer() then
			NewOwner:EnableCanWalkOnWater()
			self.Owner:WalkonWaterMessage(5)
		end
	end
	function SWEP:OnDrop()
		if self.Owner:IsPlayer() then
			self.Owner:DisableCanWalkOnWater()
		end
	end
end
