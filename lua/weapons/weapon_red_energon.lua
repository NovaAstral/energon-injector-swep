SWEP.PrintName = "Red Energon Injector"
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

SWEP.SpeedInc = 1000 -- How fast you will go in h/u
SWEP.Charge = 100
SWEP.InjDist = 45 -- Distance you can inject other players/npcs from

local HealSound = Sound("cybertronian/energon_inject.wav")
local DenySound = Sound("WallHealth.Deny")

function SWEP:Initialize()
	self:SetHoldType("slam")

	self:SetNWInt("InjectorCharge",self.Charge)

	if(CLIENT) then return end
end

function SWEP:TakeAmmo()
	self.Charge = self.Charge - 100 -- incase you want to be able to 'overcharge' the injector
	self:SetNWInt("InjectorCharge",self.Charge)

	timer.Create("InjectorRecharge"..self:EntIndex(),0.01,0,function()
		if(self.Charge < 100) then
			self.Charge = self.Charge+0.3
			self:SetNWInt("InjectorCharge",self.Charge)
		else
			self:SetNWInt("InjectorCharge",self.Charge)
			timer.Remove("InjectorRecharge"..self:EntIndex())
		end
	end)
end

function SWEP:InjectTarget(ent)
	if(ent:GetNWInt("EnergonSpeedActive") == 0 and self.Charge >= 100) then
		timer.Create("SpeedWait" .. self:EntIndex(),2,1,function()
			ent:SetNWInt("EnergonSpeed",ent:GetRunSpeed())
			ent:SetNWInt("EnergonSpeedActive",1)

			ent:SetRunSpeed(self.SpeedInc)
		end)

		if(ent == self:GetOwner()) then
			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			self:SetNextSecondaryFire(CurTime() + 0.1 + self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)))

			timer.Simple(self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),function() 
				if(IsValid(self)) then
					self:TakeAmmo()
				end
			end)
		else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:SetNextPrimaryFire(CurTime() + 0.1 + self:SequenceDuration())

			timer.Simple(self:SequenceDuration(),function() 
				if(IsValid(self)) then
					self:TakeAmmo()
				end
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
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("SpeedWait" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())

	self:GetOwner():SetNWInt("EnergonSpeedActive",0)
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("SpeedWait" .. self:EntIndex())

	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display Charge
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, 200, 40, Color(255,100,100,100))
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, math.Clamp(self:GetNWInt("InjectorCharge")*2,0,200), 40, Color(255,100,100,200))
	end
end