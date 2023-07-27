SWEP.PrintName = "Energon Red"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "RMB - Increase your speed massively"

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Category = "Disposable Transformers"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/megarexfoc/viewmodels/c_red_energon_injector_stim.mdl")
SWEP.WorldModel = Model("models/megarexfoc/w_red_injector.mdl")
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.DrawAmmo = true	

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SpeedInc = 1000 -- How fast you will go
SWEP.MaxAmmo = 10 -- Maxumum ammo

local HealSound = Sound("cybertronian/energon_inject.wav")

function SWEP:Initialize()
	self:SetHoldType("slam")

	if(CLIENT) then return end
end

function SWEP:PrimaryAttack() return false end

function SWEP:SecondaryAttack()
	if(SERVER) then
		timer.Create("SpeedWait" .. self:EntIndex(),2,1,function()
			self:GetOwner():SetNWInt("EnergonSpeed",self:GetOwner():GetRunSpeed())
			self:GetOwner():SetRunSpeed(self.SpeedInc)
		end)
	end
	
	self:EmitSound(HealSound)

	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

	self:SetNextSecondaryFire(CurTime() + self:SequenceDuration() + 1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function() 
		if(IsValid(self)) then 
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())
	return true
end