// Made by Hackcraft STEAM_0:1:50714411
// Credits: JSharpe on Facepunch for the method and first version

//if !SERVER then return end
util.AddNetworkString("WalkonWaterChatMessage")

local hasEnt = {}
local canWater = {}
local waterEnts = {} 
local enabledEnt = {}
local propPos = {}

local meta = FindMetaTable("Player")

function meta:EnableCanWalkOnWater()
	canWater[self] = true
	enabledEnt[self] = true
end

function meta:DisableCanWalkOnWater()
	if hasEnt[self] == nil then return end
	if hasEnt[self][1] != nil then
		table.RemoveByValue(propPos, hasEnt[self][1])
		waterEnts[hasEnt[self][1]] = nil
		hasEnt[self][1]:Remove()
	end
	// 2nd prop
	if hasEnt[self][2] != nil then
		table.RemoveByValue(propPos, hasEnt[self][2])
		waterEnts[hasEnt[self][2]] = nil
		hasEnt[self][2]:Remove()
	end
	canWater[self] = nil
	enabledEnt[self] = nil
	hasEnt[self] = nil
end

function meta:CanWalkOnWater()
	return canWater[self] != nil
end
 
function meta:DisableWaterEnt()
	enabledEnt[self] = false
	// Move it out of the way
	if !hasEnt[self][1].pos then 
		hasEnt[self][1].pos = true
		hasEnt[self].lockz = false
		hasEnt[self][1]:SetPos( Vector( 0, 0, 900 ) )
		// Little fix incase someone somehow picks up the prop (it'll spazz out)
		local obj = hasEnt[self][1]:GetPhysicsObject()
		obj:EnableMotion(false)
	end
	// 2nd ent
	if !hasEnt[self][2].pos then
		hasEnt[self][2].pos = true
		hasEnt[self].lockz = false
		hasEnt[self][2]:SetPos( Vector( 0, 0, 900 ) )
		// Little fix incase someone somehow picks up the prop (it'll spazz out)
		local obj = hasEnt[self][2]:GetPhysicsObject()
		obj:EnableMotion(false)
	end
end

function meta:EnableWaterEnt()
	enabledEnt[self] = true
end

function meta:CanWaterEnt()
	return enabledEnt[self] 
end

function meta:WalkonWaterMessage(i)
	if !isnumber(i) then return end
	net.Start("WalkonWaterChatMessage")
	net.WriteInt(i, 16) 
	net.Send(self)
end

// Was using it until I found that it made it glitchy in multiplayer, so replaced with two prop sizes for running and walking and set their alpha to 0
local function HidePropsFromPlayers(prop)
	if true then return end
	if prop:IsPlayer() then
		for k, v in pairs(hasEnt) do
			v:SetPreventTransmit(prop, true)
		end
	else
		for k, v in ipairs(player.GetHumans()) do
			prop:SetPreventTransmit(v, true)
		end
	end
end
//hook.Add("PlayerInitialSpawn", "HidePropsFromPlayers", HidePropsFromPlayers)

hook.Add("PostPlayerDeath", "RemoveCanWalkOnWater", function(ply) 
	ply:DisableCanWalkOnWater()
end)

hook.Add("PlayerDisconnected", "RemoveCanWalkOnWater", function(ply) 
	ply:DisableCanWalkOnWater()
end)

hook.Add("PhysgunPickup", "PreventSpazzmOfWaterProp", function(ply, ent)
	if waterEnts[ent] then
		return false
	end
end)

hook.Add("CanTool", "OiDontRemoveMeMeany", function(ply, tr, tool)
	if waterEnts[tr.Entity] then
		return false
	end
end)

hook.Add("ShouldCollide", "WaterPropCollision", function(ent1, ent2)
	if waterEnts[ent1] or waterEnts[ent2] then
		if hasEnt[ent1] or hasEnt[ent2] then
			return true
		else
			return false
		end
	end
end)

timer.Create("CleanUpWaterPropTablePosSystemTHingy", 60, 0, function()
	// This is incase the props get removed
	for k, v in ipairs(propPos) do
		if !IsValid(v) then
			table.remove(propPos, k)
		end
	end
end)

local function CreateEnt(ply)
	hasEnt[ply] = hasEnt[ply] or {}

	// Entity 1
	if !IsValid(hasEnt[ply][1]) then
		hasEnt[ply][1] = ents.Create( "prop_physics" )
//		hasEnt[ply][1]:SetModel( "models/props/de_inferno/flower_barrel_p10.mdl" ) // 1.20
		hasEnt[ply][1]:SetModel( "models/hunter/tubes/circle2x2.mdl") // got a bigger prop to help in multiplayer
		hasEnt[ply][1]:SetPos( Vector( 0, 0, 900 ) )
		hasEnt[ply][1]:SetAngles( Angle(0,0,0) )
		hasEnt[ply][1]:Spawn()
		if !IsValid(hasEnt[ply][1]) then
			print("re-creating secret")
			CreateEnt(ply)
			return
		end 
	//	HidePropsFromPlayers(hasEnt[ply][1])
		hasEnt[ply][1]:SetColor( Color( 0, 0, 0, 0 ) )
		hasEnt[ply][1]:SetRenderMode(RENDERMODE_TRANSALPHA)
		hasEnt[ply][1].pos = true
		hasEnt[ply].lockz = false
		waterEnts[hasEnt[ply][1]] = true
		hasEnt[ply][1]:Activate()
		hasEnt[ply][1]:PhysWake()
		local obj = hasEnt[ply][1]:GetPhysicsObject()
		obj:EnableMotion(false)
		hasEnt[ply][1]:SetCustomCollisionCheck(true)

		// Give each prop a value
		table.insert(propPos, hasEnt[ply][1])
		local pos = table.KeyFromValue(propPos, hasEnt[ply][1])
		hasEnt[ply][1].value = pos
	end

	// Entity 2
	if !IsValid(hasEnt[ply][2]) then
		hasEnt[ply][2] = ents.Create( "prop_physics" )
		hasEnt[ply][2]:SetModel( "models/hunter/tubes/circle4x4.mdl" ) // 1.57 (-0.05 extra)
		hasEnt[ply][2]:SetPos( Vector( 0, 0, 900 ) )
		hasEnt[ply][2]:SetAngles( Angle(0,0,0) )
		hasEnt[ply][2]:Spawn()
		if !IsValid(hasEnt[ply][2]) then
			print("re-creating secret")
			CreateEnt(ply)
			return
		end 
		HidePropsFromPlayers(hasEnt[ply][2])
		hasEnt[ply][2]:SetColor( Color( 0, 0, 0, 0 ) )
		hasEnt[ply][2]:SetRenderMode(RENDERMODE_TRANSALPHA)
		hasEnt[ply][2].pos = true
		hasEnt[ply].lockz = false
		waterEnts[hasEnt[ply][2]] = true
		hasEnt[ply][2]:Activate()
		hasEnt[ply][2]:PhysWake()
		local obj = hasEnt[ply][2]:GetPhysicsObject()
		obj:EnableMotion(false)
		hasEnt[ply][2]:SetCustomCollisionCheck(true)

		// Give each prop a value
		table.insert(propPos, hasEnt[ply][2])
		local pos = table.KeyFromValue(propPos, hasEnt[ply][2])
		hasEnt[ply][2].value = pos
	end
end

local function ResetPropPos(ply, num)
	if !IsValid(hasEnt[ply][num]) then return end
	hasEnt[ply][num].pos = true
	hasEnt[ply][num]:SetPos( Vector( 0, 0, 900 + (hasEnt[ply][num].value * 5) ) ) // put space between each prop so that it won't collide with its friends???
	// Little fix incase someone somehow picks up the prop (it'll spazz out)
	local obj = hasEnt[ply][1]:GetPhysicsObject()
	obj:EnableMotion(false)
end
 
hook.Add("Move", "walkOnWater", function(ply, mv)

	if canWater[ply] == nil or !enabledEnt[ply] or ply:InVehicle() then return end
	if hasEnt[ply] == nil then CreateEnt(ply) end

	local pos = mv:GetOrigin()

	local tr = util.TraceLine( {
		start = pos,
		endpos = pos - Vector(0,0,25),
		mask = MASK_WATER, 
	} )
	if tr.Hit then
		local tr2 = util.TraceLine( {
			start = pos + Vector(0,0,8),
			endpos = pos + Vector(0,0,9),
			mask = MASK_WATER, 
		} )
		if tr2.Hit then
			tr.Hit = false
		else
			pos = Vector( tr.HitPos.x, tr.HitPos.y, tr.HitPos.z - 1)//- 1 )
		end
	end

	if tr.Hit then
		// Walking
		if mv:GetVelocity():Length() < 320 then
			if hasEnt[ply][1] == nil or !hasEnt[ply][1]:IsValid() then CreateEnt(ply) end // Make sure we have a prop to stand on
			if !hasEnt[ply][2].pos then ResetPropPos(ply, 2) end // Move the other prop away
			hasEnt[ply].lockz = hasEnt[ply].lockz and hasEnt[ply].lockz or pos.z
			hasEnt[ply][1]:SetAngles( Angle(0,0,0) )
			hasEnt[ply][1]:SetPos( Vector(pos.x, pos.y, hasEnt[ply].lockz - 1.57) ) // 1.26
			hasEnt[ply][1].pos = false
		else
			// Running
			if hasEnt[ply][2] == nil or !hasEnt[ply][2]:IsValid() then CreateEnt(ply) end // Make sure we have a prop to stand on
			if !hasEnt[ply][1].pos then ResetPropPos(ply, 1) end // Move the other prop away
			hasEnt[ply].lockz = hasEnt[ply].lockz and hasEnt[ply].lockz or pos.z
			hasEnt[ply][2]:SetAngles( Angle(0,0,0) )
			hasEnt[ply][2]:SetPos( Vector(pos.x, pos.y, hasEnt[ply].lockz - 1.57) )
			hasEnt[ply][2].pos = false
		end
	else
		// Reset props
		if !hasEnt[ply][1].pos then 
			ResetPropPos(ply, 1)
			hasEnt[ply].lockz = false
		end
		if !hasEnt[ply][2].pos then 
			ResetPropPos(ply, 2)
			hasEnt[ply].lockz = false
		end
	end

end)