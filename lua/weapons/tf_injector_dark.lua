SWEP.PrintName = "Dark Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Create Terrorcons"
SWEP.Instructions = "LMB - Turn Target NPC or Player into a Terrorcon \nRMB - Turn yourself into a Terrorcon"

SWEP.Base = "tf_injector_base"

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = true

SWEP.LiquidMat = "transformersg2/light_purple" -- Liquid material

SWEP.ChargeColor = Color(200,125,255,200)
SWEP.ChargeBGColor = Color(200,125,255,100)

if SERVER then
	function SWEP:CreateZombie(ent)
		if(SERVER and IsValid(ent)) then
			local spawnent = ents.Create("npc_zombie")
			--Jank pos because spawning it directly ontop of the player makes it invisible to them
			spawnent:SetPos(ent:GetShootPos() + ent:GetAimVector():Angle():Forward()*24)
			spawnent:Activate()
			spawnent:Spawn()

			if(ent:IsPlayer()) then
				local hands = ent:Give("tf_injector_hands")
				ent:SetActiveWeapon(hands)
				ent:Spectate(OBS_MODE_CHASE)
				ent:SpectateEntity(spawnent)
			else
				ent:Remove()
			end
		end
	end
end

function SWEP:InjectTarget(ent)
	if(IsValid(ent) and ent:IsPlayer() or ent:IsNPC()) then
		if(self.Charge >= 100) then
			self:EmitSound(self.HealSound)

			if(ent == self:GetOwner()) then
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				self:SetNextSecondaryFire(CurTime() + 0.1 + self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)))

				timer.Simple(self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),function() 
					if(IsValid(self)) then
						self:TakeAmmo()
					end

					if SERVER then
						self:CreateZombie(ent)
					end
				end)
			else
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self:SetNextPrimaryFire(CurTime() + 0.1 + self:SequenceDuration())


				timer.Simple(self:SequenceDuration(),function()
					if(IsValid(self)) then
						self:TakeAmmo()

						if SERVER then
							self:CreateZombie(ent)
						end
					end
				end)

				timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function()
					if(IsValid(self)) then 
						self:SendWeaponAnim(ACT_VM_IDLE)
					end 
				end)
			end
		else
			self:EmitSound(self.DenySound)
		end
	else
		self:EmitSound(self.DenySound)
	end
end

function SWEP:OnRemove()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())

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