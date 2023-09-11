include( 'shared.lua' )
include( 'nvscript.lua')

surface.CreateFont( "Tahoma_lines50", { font = "Tahoma", size = 50, weight = 500, scanlines = 3, antialias = true} )
surface.CreateFont( "Tahoma_lines30", { font = "Tahoma", size = 30, weight = 700, scanlines = 3, antialias = true} )
surface.CreateFont( "Tahoma_lines18", { font = "Tahoma", size = 18, weight = 700, scanlines = 2, antialias = true} )
surface.CreateFont( "Tahoma_lines23", { font = "Tahoma", size = 23, weight = 700, scanlines = 2, antialias = true} )

surface.CreateFont( "Tahoma_lines60", { font = "Tahoma", size = 60, weight = 700, scanlines = 3, antialias = true} )
surface.CreateFont( "Tahoma_lines80", { font = "Tahoma", size = 80, weight = 700, scanlines = 3, antialias = true} )
surface.CreateFont( "Tahoma_lines130", { font = "Tahoma", size = 130, weight = 700, scanlines = 3, antialias = true} )

SWEP.PrintName = "Foundation Camera"
SWEP.Author	= "xTheTempest"
SWEP.Instructions = "RMB to Take Picture\nLMB + Drag to Change FOV or ROLL\n E for Nightvision"

SWEP.Slot             = 0
SWEP.SlotPos          = 0

SWEP.DrawAmmo         = false
SWEP.DrawCrosshair    = true