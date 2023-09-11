AddCSLuaFile()


SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = Model( "models/MaxOfS2D/camera.mdl" )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


SWEP.PrintName	= "#SCPRP_Camera"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.Spawnable		= true

SWEP.ShootSound = Sound( "NPC_CScanner.TakePhoto" )
--
-- Network/Data Tables
--
function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "Zoom" )
	self:NetworkVar( "Float", 1, "Roll" )

	if ( SERVER ) then
		self:SetZoom( 70 )
		self:SetRoll( 0 )
	end

end

--
-- Initialize Stuff
--
function SWEP:Initialize()

	self:SetHoldType( "camera" )

end

--
-- Reload resets the FOV and Roll
--
function SWEP:Reload()

	local owner = self:GetOwner()

	if ( !owner:KeyDown( IN_ATTACK2 ) ) then self:SetZoom( owner:IsBot() && 75 || owner:GetInfoNum( "fov_desired", 75 ) ) end
	self:SetRoll( 0 )


end

--
-- RMB Action - make a screenshot
--
function SWEP:PrimaryAttack()

	self:DoShootEffect()

	-- If multiplayer this can be done totally clientside
	if ( !game.SinglePlayer() && SERVER ) then return end
	if ( CLIENT && !IsFirstTimePredicted() ) then return end

	self:GetOwner():ConCommand( "jpeg" )

end


function SWEP:SecondaryAttack()
end

--
-- LMB Action - Change camera view
--
function SWEP:Tick()

	local owner = self:GetOwner()

	if ( CLIENT && owner != LocalPlayer() ) then return end -- If someone is spectating a player holding this weapon, bail

	local cmd = owner:GetCurrentCommand()

	if ( !cmd:KeyDown( IN_ATTACK2 ) ) then return end -- Not holding Mouse 2, bail

	self:SetZoom( math.Clamp( self:GetZoom() + cmd:GetMouseY() * FrameTime() * 6.6, 0.1, 175 ) ) -- Handles zooming
	self:SetRoll( self:GetRoll() + cmd:GetMouseX() * FrameTime() * 1.65 ) -- Handles rotation

end


function SWEP:TranslateFOV( current_fov )

	return self:GetZoom()

end

nightvision = hook
nvtoggle = false
function SWEP:Deploy()
	
	nightvision.Add( "KeyPress", "keypress_use_nv", function( ply, key )
		if ( key == IN_USE && nvtoggle == false ) then
			self:GetOwner():ConCommand( "nv_togg" )
			nvtoggle = true
		elseif ( key == IN_USE && nvtoggle == true) then
			self:GetOwner():ConCommand("nv_togg")
			nvtoggle = false
		end
	end )

	return true

end

--
-- Set FOV to players desired FOV
--
function SWEP:Equip()

	local owner = self:GetOwner()

	if ( self:GetZoom() == 70 && owner:IsPlayer() && !owner:IsBot() ) then
		self:SetZoom( owner:GetInfoNum( "fov_desired", 75 ) )
	end

end



function SWEP:Holster()
	NV_Status = false
	nightvision.Remove("KeyPress", "keypress_use_nv")
	nvtoggle = false

	return true
end

function SWEP:ShouldDropOnDie() return false end

--
-- The effect when a weapon is fired successfully
--
function SWEP:DoShootEffect()

	local owner = self:GetOwner()

	self:EmitSound( self.ShootSound )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	owner:SetAnimation( PLAYER_ATTACK1 )

	if ( SERVER && !game.SinglePlayer() ) then

		--
		-- Note that the flash effect is only
		-- shown to other players!
		--

		local vPos = owner:GetShootPos()
		local vForward = owner:GetAimVector()

		local trace = {}
		trace.start = vPos
		trace.endpos = vPos + vForward * 256
		trace.filter = owner

		local tr = util.TraceLine( trace )

		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		util.Effect( "camera_flash", effectdata, true )

	end

end

if ( SERVER ) then return end

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_camera" )

function SWEP:DrawHUD()//DrawHUD
	
	local MySelf = LocalPlayer()
	local light = Entity(0):GetDTEntity(0)
	local light_small = Entity(0):GetDTEntity(1)
	
	local w,h = ScrW(), ScrH()
	local gap = w/100
	
	surface.SetDrawColor(Color(255,255,255))
		
	-- FRAME -- 
	surface.DrawRect(gap*0.8+2, gap, w-2*(gap*0.8), 2)
	surface.DrawRect(gap*0.8, h-gap, w-2*(gap*0.8), 2)
	surface.DrawRect(gap*0.8, gap, 2,  h-2*gap)
	surface.DrawRect(w-gap*0.8, gap+2, 2,  h-2*gap)

	-- TOP RIGHT CORNER TEXT --
	local txt = "SITE 73"
	local red = 215
	local green = 15
		
	local date = string.format("%02i-%02i-%d", os.date("%m"), os.date("%d"), os.date("%Y"))
	local time = string.format("UTC %d:%02i:%02i %s", os.date("!%I"), os.date("%M"), os.date("%S"), os.date("%p"))
	draw.SimpleText(txt, "Tahoma_lines50",w-gap*1.3, gap*1.2, Color(255,0,0,100), TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(date, "Tahoma_lines18",w-gap*1.3, gap*1.2+50, Color(255,0,0,100), TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(time, "Tahoma_lines18",w-gap*1.3, gap*1.2+70, Color(255,0,0,100), TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		
end

function SWEP:HUDShouldDraw( name )
	
	local NotToDraw = {"CHudHealth","CHudBattery","CHudAmmo","CHudSecondaryAmmo","CHudZoom","CHUDQuickInfo"}

	for k,v in pairs(NotToDraw) do
		if (v == name) then 
			return false
		else
			return true
		end
	end

end

function SWEP:FreezeMovement()

	local owner = self:GetOwner()

	if ( owner:KeyDown( IN_ATTACK2 ) || owner:KeyReleased( IN_ATTACK2 ) ) then
		return true
	end

	return false

end

function SWEP:CalcView( ply, origin, angles, fov )

	if ( self:GetRoll() != 0 ) then
		angles.Roll = self:GetRoll()
	end

	return origin, angles, fov

end

function SWEP:AdjustMouseSensitivity()

	if ( self:GetOwner():KeyDown( IN_ATTACK2 ) ) then return 1 end

	return self:GetZoom() / 80

end