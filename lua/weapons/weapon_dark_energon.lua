SWEP.PrintName = "Energon Dark"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "RMB - Turn yourself into a zombie"

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.DrawAmmo = false	
SWEP.Category = "Disposable Transformers"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/megarexfoc/viewmodels/c_dark_energon_injector_stim.mdl" )
SWEP.WorldModel = Model( "models/megarexfoc/w_dark_injector.mdl" )
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local HealSound = Sound("cybertronian/energon_inject.wav")

if SERVER then
	AddCSLuaFile()
end

function SWEP:Initialize()
	self:SetHoldType("slam")
	
	if(CLIENT) then return end
end

function SWEP:PrimaryAttack() return false end -- This stops it from making the 'out of ammo' sound

function SWEP:SecondaryAttack()
	self:EmitSound(HealSound)

	if(CLIENT) then return end

	timer.Simple(2, function()
		local spawnent = ents.Create("npc_zombie")

		spawnent:SetPos(self:GetOwner():GetPos())
		spawnent:Activate()
		spawnent:Spawn()
		
		self:GetOwner():Kill()
		self:GetOwner():GetRagdollEntity():Remove()
	end)
		
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

	self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function()
		if(IsValid(self)) then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function SWEP:OnRemove()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Holster()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
	return true
end


		




