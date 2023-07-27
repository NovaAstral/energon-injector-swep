SWEP.PrintName = "Energon"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "LMB - Heal Target NPC or Player, RMB - Heal Yourself"

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Category = "Disposable Transformers"

SWEP.Spawnable = true

SWEP.DrawAmmo = true

SWEP.ViewModel = Model("models/megarexfoc/viewmodels/c_energon_injector_stim.mdl")
SWEP.WorldModel = Model("models/megarexfoc/w_energon_injector.mdl")
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "HelicopterGun"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 20 -- Maximum heal amount per use
SWEP.MaxAmmo = 10 -- Maxumum ammo
SWEP.HealDist = 45 -- Distance you can heal other players/npcs from

local HealSound = Sound( "cybertronian/energon_inject.wav" )
local DenySound = Sound( "WallHealth.Deny" )

if SERVER then
	AddCSLuaFile()
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	if(CLIENT) then return end
end

function HealTarget(ent,owner)
	local self = owner:GetWeapon("weapon_energon")

	if(IsValid(ent) and ent:IsPlayer() or ent:IsNPC()) then
		print("valid")
		if(self:Ammo1() > 0 and ent:Health() < ent:GetMaxHealth()) then
			timer.Create("EnergonHeal" .. self:EntIndex(),0.1,self.HealAmount,function()
				if(IsValid(ent)) then
					ent:SetHealth(math.Clamp(ent:Health() + 1,0,ent:GetMaxHealth()))
				else
					timer.Stop("EnergonHeal" .. self:EntIndex())
				end
			end)
			
			self:EmitSound(HealSound)

			if(ent == owner) then
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			else
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			end

			self:TakePrimaryAmmo(1)
			self:SetNextSecondaryFire(CurTime() + self:SequenceDuration() + 1)

			timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function()
				if(IsValid(self)) then 
					self:SendWeaponAnim(ACT_VM_IDLE)
				end 
			end)
		else
			self:EmitSound(DenySound)
		end
	end
end

function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.HealDist and IsValid(tr.Entity)) then
		HealTarget(tr.Entity,self:GetOwner())
	else
		self:EmitSound(DenySound)
	end

	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	HealTarget(self:GetOwner(),self:GetOwner())

	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonHeal" .. self:EntIndex())
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonHeal" .. self:EntIndex())

	return true
end


		




