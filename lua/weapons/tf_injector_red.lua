SWEP.PrintName = "Red Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Replace Energon with Red Energon and become very fast"
SWEP.Instructions = "LMB - Increase the target players speed \nRMB - Increase your speed"

SWEP.Base = "tf_injector_base"

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = true

SWEP.SpeedInc = 1000 -- How fast you will go
SWEP.LiquidMat = "transformersg2/energon_red"

SWEP.ChargeColor = Color(255,100,100,200)
SWEP.ChargeBGColor = Color(255,100,100,100)

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

		self:EmitSound(self.HealSound)

		timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function() 
			if(IsValid(self)) then 
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end)
	else
		self:EmitSound(self.DenySound)
	end
end


function SWEP:OnRemove()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())

	self:GetOwner():SetNWInt("EnergonSpeedActive",0)

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end
end

function SWEP:Holster()
	timer.Stop("weapon_idle" .. self:EntIndex())
	timer.Stop("SpeedWait" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end

	return true
end