
AddCSLuaFile()

SWEP.PrintName = "Energon Speed Dark"
SWEP.Author = "Spok"
SWEP.Purpose = "RMB - heal yourself, LMB - heal someone else."

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.DrawAmmo = true	
SWEP.Category = "Disposable Transformers"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/megarexfoc/viewmodels/c_dark_energon_injector_stim.mdl" )
SWEP.WorldModel = Model( "models/megarexfoc/w_dark_injector.mdl" )
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
self.Weapon:EmitSound(HealSound)
	if ( CLIENT ) then return end

		self:TakePrimaryAmmo( 1 )
		
		timer.Simple(2, function()
	
      	if (CLIENT) then return end
			local rockett = ents.Create("npc_fastzombie")
			local ply_Ang = self:GetOwner():GetAimVector():Angle()
			local ply_Pos = self:GetOwner():GetShootPos() + ply_Ang:Forward()*24 + ply_Ang:Up()*-10 + ply_Ang:Right()*0
			if self:GetOwner():IsPlayer() then rockett:SetPos(ply_Pos) else rockett:SetPos(self:GetNWVector()) end
			if self:GetOwner():IsPlayer() then rockett:SetAngles(ply_Ang) else rockett:SetAngles(self:GetOwner():GetAngles()) end
			rockett:SetOwner(self:GetOwner())
			rockett:Activate()
			rockett:Spawn()    
    		local phys = rockett:GetPhysicsObject()
    		if (phys:IsValid()) then
    
    end

		self.Owner:Kill()
		end)
		 

		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )

		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration() + 1 )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 1, function() if ( IsValid( self ) ) and  self:Clip1() >= 1  then self:SendWeaponAnim( ACT_VM_IDLE ) self.Owner:Kill() else self:Remove () end end )


		self:SetNextSecondaryFire( CurTime() + 1 )

end

function SWEP:OnRemove()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )

	return true

end


		




