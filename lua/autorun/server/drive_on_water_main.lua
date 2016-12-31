// Made by Hackcraft STEAM_0:1:50714411

//if !SERVER then return end
util.AddNetworkString("DriveonWaterChatMessage")

local hullDesignator = file.Exists("autorun/gravityhull_init.lua", "LUA")
local isSinglePlayer = game.SinglePlayer()
local canWater = {} // Players who have the drive on water SWEP
local waterEnts = {} // The props which hold the car up
local enabledEnt = {} // Players who have drive on water turned on
local carPoints = {} // Positions of car stuff
local spammyFix = {} // Helps lock z axis better (so the platform's z axis doesn't unlock if it lifts up for a second)
spammyFix.Things = {}
spammyFix.LastChecked = {}
local driveable = {
	["prop_vehicle_prisoner_pod"] = true,
	["prop_vehicle_jeep"] = true
}

local meta = FindMetaTable("Player")

local function printDisabled(ply)
	ply:ChatPrint("Drive on Water has been disabled. Incompatible with Gravity Hull Designator!")
end

function meta:EnableCanDriveOnWater()
	if hullDesignator then 
		printDisabled(self)
	else
		canWater[self] = true
		enabledEnt[self] = true
		if self:GetVehicle() then
			self:AddPlayersAbilityToVehicle()
		end
	end
end

function meta:DisableCanDriveOnWater()
	if hullDesignator then 
		printDisabled(self)
	else
		canWater[self] = nil
		enabledEnt[self] = nil
		if self:GetVehicle() then
			self:RemovePlayersAbilityFromVehicle()
		end
	end
end

function meta:CanDriveOnWater()
	return canWater[self] != nil
end
 
function meta:DisableWaterDrive()
	if hullDesignator then 
		printDisabled(self)
	else
		enabledEnt[self] = false
		if self:GetVehicle() then
			self:RemovePlayersAbilityFromVehicle()
		end
	end
end

function meta:EnableWaterDrive()
	if hullDesignator then 
		printDisabled(self)
	else
		enabledEnt[self] = true
		if self:GetVehicle() then
			self:AddPlayersAbilityToVehicle()
		end
	end
end

function meta:CanWaterDrive()
	return enabledEnt[self] 
end

// Left
function meta:AddPlayersAbilityToVehicle()
	local veh = self:GetVehicle()
	if !veh or !IsValid(veh) then return end
	if veh:GetClass() != "prop_vehicle_jeep" then return end
	if self:CanDriveOnWater() and self:CanWaterDrive() then // If they're allowed and they've turned it on

		if carPoints[veh] == nil then // If not already worked out, workout the positions!
			carPoints[veh] = {}
			local diff = veh:OBBMaxs() - veh:OBBMins() 
			carPoints[veh].height = math.Round(diff.z / 2, 2)																		// always going to be dividing by 2
			carPoints[veh].length = diff.x > diff.y and math.Round(diff.x / 4, 2) or diff.x < diff.y and math.Round(diff.y / 4, 2)	// always going to be dividing by 2
			carPoints[veh].width = diff.x < diff.y and math.Round(diff.x / 2, 2) or diff.x > diff.y and math.Round(diff.y / 2, 2)	// always going to be dividing by 2
			carPoints[veh].center = veh:OBBCenter()
			carPoints[veh].mins = veh:OBBMins() 
			carPoints[veh].maxs = veh:OBBMaxs()

			// Lets say x is forward, y is left and right, z up and down
			carPoints[veh].br = Vector(carPoints[veh].center.x - carPoints[veh].length - (carPoints[veh].length*0.6), carPoints[veh].center.y + carPoints[veh].width + (carPoints[veh].width*0.6), carPoints[veh].center.z - carPoints[veh].height)
			carPoints[veh].bl = Vector(carPoints[veh].center.x - carPoints[veh].length - (carPoints[veh].length*0.6), carPoints[veh].center.y - carPoints[veh].width - (carPoints[veh].width*0.6), carPoints[veh].center.z - carPoints[veh].height)

			carPoints[veh].fr = Vector(carPoints[veh].center.x + carPoints[veh].length + (carPoints[veh].length*0.6), carPoints[veh].center.y + carPoints[veh].width + (carPoints[veh].width*0.6), carPoints[veh].center.z - carPoints[veh].height)
			carPoints[veh].fl = Vector(carPoints[veh].center.x + carPoints[veh].length + (carPoints[veh].length*0.6), carPoints[veh].center.y - carPoints[veh].width - (carPoints[veh].width*0.6), carPoints[veh].center.z - carPoints[veh].height)

			carPoints[veh].lockZ = false
		end

		carPoints[veh].count = carPoints[veh].count != nil and carPoints[veh].count + 1 or 1 // Add (incase multiple people have the swep and stay in the car when one leaves
	end
end

// Entered
function meta:RemovePlayersAbilityFromVehicle()
	if self:GetVehicle() then
		local veh = self:GetVehicle()
		if carPoints[veh] == nil then return end
		carPoints[veh].count = carPoints[veh].count != nil and carPoints[veh].count - 1 or 0
		if carPoints[veh].count >= 0 then
			carPoints[veh] = nil
//			print("Removed car info")
		end
	end
end


function meta:DriveonWaterMessage(i)
	if !isnumber(i) then return end
	net.Start("DriveonWaterChatMessage")
	net.WriteInt(i, 16) 
	net.Send(self)
end


hook.Add("PostPlayerDeath", "RemoveCanWalkOnWater_Drive", function(ply) 
	ply:DisableCanDriveOnWater()
end)

hook.Add("PlayerDisconnected", "RemoveCanWalkOnWater_Drive", function(ply) 
	ply:DisableCanDriveOnWater()
end)

hook.Add("PhysgunPickup", "PreventSpazzmOfWaterProp_Drive", function(ply, ent)
	if waterEnts[ent] then
		return false
	end
end)

hook.Add("CanTool", "OiDontRemoveMeMeany_Drive", function(ply, tr, tool)
	if waterEnts[tr.Entity] then
		return false
	end
end)


hook.Add("ShouldCollide", "WaterPropCollision_Drive", function(ent1, ent2)
	// If ent1 is the car
	if carPoints[ent1] then
		// See if it's a prop used for driving
		return waterEnts[ent2] != nil 
	// If ent2 is the car
	elseif carPoints[ent2] then	
		// See if it's a prop used for driving
		return waterEnts[ent1] != nil 
	end
end)

// Enter vehicle handler
hook.Add("PlayerEnteredVehicle", "DriveOnWater", function(ply, veh, role)
	// If not a car then do nothing! -- scar fix
	if veh:GetClass() != "prop_vehicle_jeep" then return end //and string.Left(veh:GetClass(), 17) != "sent_sakarias_car" then print("false") return end
	if ply:CanDriveOnWater() and ply:CanWaterDrive() then // If they're allowed and they've turned it on
		// Remove the hull from the vehicle! - didn't do anything xD
//		GravHull.UnHull(veh)
		ply:AddPlayersAbilityToVehicle()
	end
end)

// Leave vehicle handler
hook.Add("PlayerLeaveVehicle", "DriveOnWater", function(ply, veh)
	// Check to see if on water, if so then leave the car above water but if the next person cannot drive on water then sink the car!
	if carPoints[veh] then
		ply:RemovePlayersAbilityFromVehicle()
	end
end)

// Create our laggy prop
local function CreateBelow(ply, pos, ang)

	// Props don't get removed when console is open, so disable the spawning!
	//if isSinglePlayer and CLIENT and gui.IsConsoleVisible() then return end

	local ent 
	ent = ents.Create( "prop_physics" )
//	ent:SetModel( "models/hunter/blocks/cube4x8x025.mdl" ) // 1.54 // -8
	ent:SetModel("models/hunter/plates/plate5x8.mdl") //
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:Spawn()
	if !IsValid(ent) then return end
	ent:SetColor( Color( 0, 0, 0, 0 ) )
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.pos = true
	ent.lockz = false
	ent:Activate()
	ent:PhysWake()
	waterEnts[ent] = true
	local obj = ent:GetPhysicsObject()
	obj:EnableMotion(false)

	// Remove prop after 0.2 sec
	timer.Simple(0.2, function()
		waterEnts[ent] = nil
		if IsValid(ent) then
			ent:Remove()
		end
	end)

end

// Z axis unlocking by accident fix
timer.Create("SpammWaterZToggleFix", 2, 0, function()
	//spammyFix.Things = {}
	//spammyFix.LastChecked = {}
	local cur = CurTime()
	for k, v in pairs(spammyFix.Things) do
		if spammyFix.LastChecked[k] == nil then
			spammyFix.LastChecked[k] = cur + 2
		else
			if spammyFix.LastChecked[k] > cur then
				spammyFix.LastChecked[k] = cur + 2
				if carPoints[k] != nil then
					spammyFix.Things[k] = nil
					carPoints[k].lockZ = false
				end
			end
		end
	end
end)

// Trace hitpos too deep under water fix
local function GetWaterSurface(pos)
	for i=1, 20 do
		local tr2 = util.TraceLine( {
			start = pos + Vector(0,0,i),
			endpos = pos + Vector(0,0,i),
			mask = MASK_WATER, 
		} )
		if !tr2.Hit then 
			return tr2.HitPos.z - 2
		end
	end
	return false
end
 
// Only do stuff to driving cars
hook.Add("VehicleMove", "walkOnWater_Drive", function(ply, veh, mv)

	if carPoints[veh] == nil then return end // If it has points set then someone with the SWEP is inside - although, I don't know who vcmod etc handles seats so you might have to be the driver, idk
	if veh:WaterLevel() > 1 then return end

	local pos = mv:GetOrigin()
	local ang = veh:GetAngles() // [2] for y rotate
	local bottom = pos - Vector(0,0,carPoints[veh].height)

	local points = {}

	points[1] = carPoints[veh].br
	points[2] = carPoints[veh].bl
	points[3] = carPoints[veh].fr
	points[4] = carPoints[veh].fl

	points[1]:Rotate(ang)
	points[2]:Rotate(ang)
	points[3]:Rotate(ang)
	points[4]:Rotate(ang)

	points[1] = points[1] + pos + Vector(0,0,5)
	points[2] = points[2] + pos + Vector(0,0,5)
	points[3] = points[3] + pos + Vector(0,0,5)
	points[4] = points[4] + pos + Vector(0,0,5)

	local lowest = 1
	for i=1, 4 do
		if points[lowest].z > points[i].z then
			lowest = i
		end
	end
	lowest = points[lowest]

	//carPoints[veh].lockZ = {pos = false, time = CurTime()}

	local tr = util.TraceLine( {
		start = lowest,
		endpos = lowest - Vector(0,0,15),
		mask = MASK_WATER, 
	} )
	if tr.Hit then
		if !carPoints[veh].lockZ then
			local tr2 = util.TraceLine( {
				start = lowest + Vector(0,0,5),
				endpos = lowest + Vector(0,0,6),
				mask = MASK_WATER, 
			} )
			if tr2.Hit then 
				// If out hit failed, the hit will be underwater so we need to find the surface!
				local pos2 = GetWaterSurface(tr.HitPos)
				if !pos2 then return end
				carPoints[veh].lockZ = pos2
				print("Car trace failed, looking for water's surface!")
			else
				carPoints[veh].lockZ = tr.HitPos.z
			end
//			carPoints[veh].InWater = true
		end

		// Handle prop stuff
		CreateBelow(ply, Vector(bottom.x, bottom.y, carPoints[veh].lockZ - 2.5), Angle(0,ang[2],0))
		spammyFix.Things[veh] = nil
	else
		spammyFix.Things[veh] = true
	end

end)
