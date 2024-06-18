SWEP.PrintName = "Energon Overcharge Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Recharge a Cybertronian's armor"
SWEP.Instructions = "LMB - Recharge Target Player Armor \nRMB - Recharge your armor"

SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Category = "Transformers Injectors"

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/megarexfoc/viewmodels/c_overcharge_injector_stim.mdl")
SWEP.WorldModel = Model("models/megarexfoc/w_overcharge_injector.mdl")
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.DrawAmmo = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HealAmount = 20 -- Maximum heal amount per use
SWEP.MaxUses = 10 -- Maxumum ammo
SWEP.UsesLeft = SWEP.MaxUses -- Uses Left
SWEP.InjDist = 45 -- Distance you can inject other players/npcs from

local HealSound = Sound("cybertronian/energon_inject.wav")
local DenySound = Sound("WallHealth.Deny")

if SERVER then
	AddCSLuaFile()
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	self:SetNWInt("Uses",self.UsesLeft)

	if(CLIENT) then return end
end

function SWEP:TakeAmmo()
	self.UsesLeft = self.UsesLeft - 1
	self:SetNWInt("Uses",self.UsesLeft)
end

if SERVER then

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer()) then
		if(self.UsesLeft > 0 and ent:Armor() < ent:GetMaxArmor()) then
			if(ent:Armor() < ent:GetMaxArmor()) then
				timer.Create("EnergonArmor" .. self:EntIndex(),0.1,self.HealAmount,function()
					if(IsValid(ent)) then
						ent:SetArmor(math.Clamp(ent:Armor() + 1,0,ent:GetMaxArmor()))
					else
						timer.Stop("EnergonArmor" .. self:EntIndex())
					end
				end)
			end
			
			self:EmitSound(HealSound)

			if(ent == self:GetOwner()) then
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				self:SetNextSecondaryFire(CurTime() + self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)))
	
				timer.Simple(self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),function() 
					self:TakeAmmo()
				end)
			else
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
	
				timer.Simple(self:SequenceDuration(),function() 
					self:TakeAmmo()
				end)
			end

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

end

function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.InjDist and IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
		self:InjectTarget(tr.Entity)
	else
		self:EmitSound(DenySound)
	end
end

function SWEP:SecondaryAttack()
	self:InjectTarget(self:GetOwner())
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonArmor" .. self:EntIndex())
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonArmor" .. self:EntIndex())

	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display uses
		draw.WordBox(10, ScrW() - 200, ScrH() - 140, "Uses Left: " .. self:GetNWInt("Uses"), "Default", Color(0, 0, 0, 80), Color(255, 220, 0, 220))
	end
end