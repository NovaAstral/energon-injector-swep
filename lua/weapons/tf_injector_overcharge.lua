SWEP.PrintName = "Energon Overcharge Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Recharge a Cybertronian's armor"
SWEP.Instructions = "LMB - Recharge Target Player Armor \nRMB - Recharge your armor"

SWEP.Base = "tf_injector_base"

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = true

SWEP.HealAmount = 20 -- Maximum heal amount per use
SWEP.LiquidMat = "transformersg2/light_yellow"

SWEP.ChargeColor = Color(255,250,0,200)
SWEP.ChargeBGColor = Color(255,250,0,100)

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer()) then
		if(self.Charge >= 100 and ent:Armor() < ent:GetMaxArmor()) then
			if(ent:Armor() < ent:GetMaxArmor()) then
				timer.Create("EnergonArmor" .. self:EntIndex(),0.1,self.HealAmount,function()
					if(IsValid(ent)) then
						if SERVER then ent:SetArmor(math.Clamp(ent:Armor() + 1,0,ent:GetMaxArmor())) end
					else
						timer.Stop("EnergonArmor" .. self:EntIndex())
					end
				end)
			end
			
			self:EmitSound(self.HealSound)

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

			timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function()
				if(IsValid(self)) then 
					self:SendWeaponAnim(ACT_VM_IDLE)
				end 
			end)
		else
			self:EmitSound(self.DenySound)
		end
	end
end

function SWEP:OnRemove()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())
	timer.Remove("EnergonArmor" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("EnergonArmor" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end

	return true
end