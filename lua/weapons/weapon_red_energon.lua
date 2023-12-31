SWEP.PrintName = "Energon Red Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Replace Energon with Red Energon and become fast"
SWEP.Instructions = "LMB - Increase the target players speed \nRMB - Increase your speed"

SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.Category = "Transformers Injectors"

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
SWEP.MaxUses = 10 -- Maxumum ammo
SWEP.UsesLeft = SWEP.MaxUses -- Uses Left
SWEP.InjDist = 45 -- Distance you can inject other players/npcs from

local HealSound = Sound("cybertronian/energon_inject.wav")
local DenySound = Sound("WallHealth.Deny")

function SWEP:Initialize()
	self:SetHoldType("slam")

	self:SetNWInt("Uses",self.UsesLeft)

	if(CLIENT) then return end
end

function SWEP:TakeAmmo()
	self.UsesLeft = self.UsesLeft - 1
	self:SetNWInt("Uses",self.UsesLeft)
end

function SWEP:InjectTarget(ent)
	if(ent:GetNWInt("EnergonSpeedActive") == 0) then
		timer.Create("SpeedWait" .. self:EntIndex(),2,1,function()
			ent:SetNWInt("EnergonSpeed",ent:GetRunSpeed())
			ent:SetNWInt("EnergonSpeedActive",1)

			ent:SetRunSpeed(self.SpeedInc)
		end)

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

		self:EmitSound(HealSound)

		timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function() 
			if(IsValid(self)) then 
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end)
	else
		self:EmitSound(DenySound)
	end
end

function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTraceNoCursor()
	ply = tr.Entity

	if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.InjDist and IsValid(ply) and ply:IsPlayer()) then
		self:InjectTarget(ply)
	else
		self:EmitSound(DenySound)
	end
end

function SWEP:SecondaryAttack()
	self:InjectTarget(self:GetOwner())
end

function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())

	self:GetOwner():SetNWInt("EnergonSpeedActive",0)
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())

	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display uses
		draw.WordBox(10, ScrW() - 200, ScrH() - 140, "Uses Left: " .. self:GetNWInt("Uses"), "Default", Color(0, 0, 0, 80), Color(255, 220, 0, 220))
	end
end