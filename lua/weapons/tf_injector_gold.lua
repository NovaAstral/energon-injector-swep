SWEP.PrintName = "Gold Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Make a Cybertronian Invulnerable"
SWEP.Instructions = "LMB - Goldenize Target Player \nRMB - Goldenize Yourself"

SWEP.Base = "tf_injector_base"

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = true

SWEP.LiquidMat = "models/player/shared/gold_player"

SWEP.ChargeColor = Color(255,220,0,200)
SWEP.ChargeBGColor = Color(255,220,0,100)

function SWEP:DisableGold(ent,oldmat)
	timer.Simple(0.1,function()
		if(ent:IsPlayer() and ent:Alive()) then 
			ent:GodDisable()
		end
	end)

    ent:SetMaterial(oldmat)
end

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer() and self.Charge >= 100) then
		timer.Create("EnergonGold" .. self:EntIndex(),self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),1,function()
			if(SERVER and IsValid(ent)) then
				ent:GodEnable()
				OldMat = ent:GetMaterial()
				ent:SetMaterial("models/player/shared/gold_player")

				timer.Create("GoldDisable"..self:EntIndex(),10,1,function()
					self:DisableGold(ent,OldMat)
				end)
			end
		end)
		
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


function SWEP:OnRemove()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())
	timer.Remove("EnergonGold" .. self:EntIndex())
	timer.Remove("GoldDisable" .. self:EntIndex())

	self:DisableGold(self:GetOwner(),"")

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("EnergonGold" .. self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end

	return true
end