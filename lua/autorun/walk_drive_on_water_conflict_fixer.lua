
/*
	gPowers temp collision fix - 554915029
*/

//hook.Add("ShouldCollide", "gpow_ShadowWalker"



local time = false
local addedCustom = false
local havegPowers = file.Exists("weapons/gpow_shadowwalker.lua", "LUA")
local hullDesignator = file.Exists("autorun/gravityhull_init.lua", "LUA")

local function SavegPowersInfo(value)
	sql.Query( "REPLACE INTO playerpdata ( infoid, value ) VALUES ( "..SQLStr("gPowersCollisionFixedYet")..", "..SQLStr(value).." )" )
end

local function IsgPowersFixedYet()
	local val = sql.QueryValue( "SELECT value FROM playerpdata WHERE infoid = " .. SQLStr("gPowersCollisionFixedYet") .. " LIMIT 1" )
	if ( val == nil ) then return false end
	return tobool(val)
end

local function addDaHook()
	hook.Add("ShouldCollide", "gpow_ShadowWalker", function(ent1, ent2)
		if ent1:IsPlayer() and ent1:GetActiveWeapon() != nil and ent1:GetActiveWeapon():GetClass() == "gpow_shadowwalker" or 
			ent2:IsPlayer() and ent2:GetActiveWeapon() != nil and ent2:GetActiveWeapon():GetClass() == "gpow_shadowwalker" then
			return false
		end
	end)
	addedCustom = true
	print("[Walk/Drive on Water] gPowers collision hook override(fix) successful!")
end

local function checkYYYYY()
	local t = hook.GetTable()
	if t["ShouldCollide"] != nil and t["ShouldCollide"]["gpow_ShadowWalker"] != nil then
		hook.Remove("ShouldCollide", "gpow_ShadowWalker")
		timer.Simple(1, function()
			addDaHook()
		end)
	else
		timer.Simple(1, function() checkYYYYY() end)
	end
end

local function checkAddon( workshopID )
	http.Post( "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", 
		{["itemcount"] = "1",["publishedfileids[0]"] = tostring(workshopID)},
		function(json)
			local data = util.JSONToTable(json)
			if not data then
				time = nil
				return 
			end
			time = data["response"]["publishedfiledetails"][1].time_updated
		end,
		function(err)
			time = nil
			return 
		end
	)
end

checkAddon( 554915029 )

local function HandleTheRest()
	if time == 1481771583 then
		print("[Walk/Drive on Water] The current version of gPowers contains a bad hook!")
		print("[Walk/Drive on Water] Attempting to fix gPowers!")
		SavegPowersInfo(false)
		checkYYYYY()
	else
		if time == nil then
			// If the check failed, fix the hook because we have nothing saying it's fixed yet
			print("[Walk/Drive on Water] The current version of gPowers likely has a bad hook!")
			print("[Walk/Drive on Water] Attempting to fix gPowers!")
			checkYYYYY()
		else
			SavegPowersInfo(true)
			print("[Walk/Drive on Water] You are running a newer version of gPowers, the bad hook should be fixed!")
		end
	end
end

// If gPowers exists and hasn't been fixed and we don't have hull designator 
timer.Simple(5, function()
	if havegPowers and !IsgPowersFixedYet() then 
		print("[Walk/Drive on Water] gPowers found, checking when it was last updated")
		timer.Create("CheckFoResponseFromHttp", 1, 0, function()
			if time == nil or time then
				HandleTheRest()
				timer.Destroy("CheckFoResponseFromHttp")
			end
		end)
	end
end)
