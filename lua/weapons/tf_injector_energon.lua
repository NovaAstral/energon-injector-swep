SWEP.PrintName = "Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Replenish a Cybertronian's Energon Reserves"
SWEP.Instructions = "LMB - Heal Target NPC or Player \nRMB - Heal Yourself"

SWEP.Base = "tf_injector_base"

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = true

SWEP.HealAmount = 20 -- Maximum heal amount per use
SWEP.LiquidMat = "transformersg2/energon" -- Liquid material

SWEP.ChargeColor = Color(0,255,220,200) -- Charge bar color
SWEP.ChargeBGColor = Color(0,255,220,100) -- Charge bar background color

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer() or ent:IsNPC()) then
		if(self.Charge >= 100 and ent:Health() < ent:GetMaxHealth() or ent:GetNWInt("EnergonSpeedActive") == 1) then
			if(ent:Health() < ent:GetMaxHealth()) then
				timer.Create("EnergonHeal" .. self:EntIndex(),0.1,self.HealAmount,function()
					if(IsValid(ent)) then
						ent:SetHealth(math.Clamp(ent:Health() + 1,0,ent:GetMaxHealth()))
					else
						timer.Stop("EnergonHeal" .. self:EntIndex())
					end
				end)
			end

			if(ent:GetNWInt("EnergonSpeedActive") == 1) then
				timer.Create("SpeedWait" .. self:EntIndex(),2,1,function()
					ent:SetRunSpeed(ent:GetNWInt("EnergonSpeed"))
					ent:SetNWInt("EnergonSpeedActive",0)
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
	timer.Remove("EnergonHeal" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end

	return true
end