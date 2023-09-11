AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "nvscript.lua" )

include('shared.lua')

SWEP.AutoSwitchTo   = true
SWEP.AutoSwitchFrom = false

function SWEP:GetCapabilities()
	return 0
end
