
AddCSLuaFile()

SWEP.PrintName = "Energon Red"
SWEP.Author = "Spok"
SWEP.Purpose = "RMB - heal yourself, LMB - heal someone else."

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.DrawAmmo = true	
SWEP.Category = "Disposable Transformers"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/megarexfoc/viewmodels/c_red_energon_injector_stim.mdl" )
SWEP.WorldModel = Model( "models/megarexfoc/w_red_injector.mdl" )
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 15 -- Maximum heal amount per use
SWEP.MaxAmmo = 10 -- Maxumum ammo

local HealSound = Sound( "cybertronian/energon_inject.wav" )

function SWEP:Initialize()

	self:SetHoldType( "slam" )
	

	if ( CLIENT ) then return end
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

	if ( CLIENT ) then return end

		self:TakePrimaryAmmo( 1 )
		self.Owner:SetRunSpeed( 2000 )

		 self.Weapon:EmitSound(HealSound)

		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration() + 1 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) and  self:Clip1() >= 1  then self:SendWeaponAnim( ACT_VM_IDLE ) else self:Remove () end end )


		self:SetNextSecondaryFire( CurTime() + 1 )

end

function SWEP:OnRemove()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

	return true

end


		




