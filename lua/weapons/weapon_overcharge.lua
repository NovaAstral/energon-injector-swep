SWEP.PrintName = "Energon Overcharge"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "RMB - Recharge your suit armor"

SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.DrawAmmo = true
SWEP.Category = "Disposable Transformers"	

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/megarexfoc/viewmodels/c_overcharge_injector_stim.mdl")
SWEP.WorldModel = Model("models/megarexfoc/w_overcharge_injector.mdl")
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

local HealSound = Sound("cybertronian/energon_inject.wav")
local DenySound = Sound("SuitRecharge.Deny")

if SERVER then
	AddCSLuaFile()
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	if(CLIENT) then return end
end

local function HealTarget(ent,owner)
	local self = owner:GetWeapon("weapon_overcharge")

	if(IsValid(ent)) then
		if(self:Ammo1() > 0 and ent:Armor() < ent:GetMaxArmor()) then
			if(SERVER) then
				timer.Create("EnergonCharge" .. self:EntIndex(),0.1,self.HealAmount,function()
					if(IsValid(ent)) then
						ent:SetArmor(math.Clamp(ent:Armor() + 1,0,ent:GetMaxArmor()))
					else
						timer.Stop("EnergonCharge" .. self:EntIndex())
					end
				end)
			end
			
			self:EmitSound(HealSound)

			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

			self:TakePrimaryAmmo(1)
			self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())

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

function SWEP:PrimaryAttack() return false end -- This stops it from making the 'out of ammo' sound

function SWEP:SecondaryAttack()
	HealTarget(self:GetOwner(),self:GetOwner())
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonCharge" .. self:EntIndex())
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonCharge" .. self:EntIndex())

	return true
end


		




