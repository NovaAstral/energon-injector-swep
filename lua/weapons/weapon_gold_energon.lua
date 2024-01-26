SWEP.PrintName = "Gold Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Make a cybertronain invulnerable"
SWEP.Instructions = "LMB - Goldenize Target Player \nRMB - Goldenize Yourself"

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

function SWEP:DisableGold(ent,oldmat)
	timer.Simple(0.1,function()
		if(ent:IsPlayer() and ent:Alive()) then 
			ent:GodDisable()
		end
	end)

    ent:SetMaterial(oldmat)
end

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer()) then
		if(self.UsesLeft > 0) then
			timer.Create("EnergonGold" .. self:EntIndex(),self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),1,function()
				if(IsValid(ent)) then
					ent:GodEnable()
                    OldMat = ent:GetMaterial()
                    ent:SetMaterial("models/player/shared/gold_player")

                    timer.Create("GoldDisable"..self:EntIndex(),10,1,function()
                        self:DisableGold(ent,OldMat)
                    end)
				end
			end)
			
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

function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.InjDist and IsValid(tr.Entity)) then
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
	timer.Stop("EnergonGold" .. self:EntIndex())
	timer.Stop("GoldDisable" .. self:EntIndex())
	self:DisableGold(self:GetOwner(),"")
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("EnergonGold" .. self:EntIndex())

	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display uses
		draw.WordBox(10, ScrW() - 200, ScrH() - 140, "Uses Left: " .. self:GetNWInt("Uses"), "Default", Color(0, 0, 0, 80), Color(255, 220, 0, 220))
	end
end