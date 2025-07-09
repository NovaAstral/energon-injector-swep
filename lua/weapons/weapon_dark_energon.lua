SWEP.PrintName = "Dark Energon Injector"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Create Terrorcons"
SWEP.Instructions = "LMB - Turn Target NPC or Player into a Terrorcon \nRMB - Turn yourself into a Terrorcon"
SWEP.Slot = 4
SWEP.SlotPos = 3
SWEP.DrawAmmo = false
SWEP.Category = "Transformers Injectors"

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/megarexfoc/viewmodels/c_dark_energon_injector_stim.mdl" )
SWEP.WorldModel = Model( "models/megarexfoc/w_dark_injector.mdl" )
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Charge = 100
SWEP.InjDist = 45 -- Distance you can inject other players/npcs from

local HealSound = Sound("cybertronian/energon_inject.wav")
local DenySound = Sound("WallHealth.Deny")

if SERVER then
	AddCSLuaFile()
end

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

if SERVER then
	function SWEP:CreateZombie(ent)
		if(SERVER and IsValid(ent)) then
			local spawnent = ents.Create("npc_zombie")
			--Jank pos because spawning it directly ontop of the player makes it invisible to them
			spawnent:SetPos(ent:GetShootPos() + ent:GetAimVector():Angle():Forward()*24)
			spawnent:Activate()
			spawnent:Spawn()

			if(ent:IsPlayer()) then
				local hands = ent:Give("weapon_injector_hands")
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
			self:EmitSound(HealSound)

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
			self:EmitSound(DenySound)
		end
	else
		self:EmitSound(DenySound)
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
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())
	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display Charge
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, 200, 40, Color(200,125,255,100))
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, math.Clamp(self:GetNWInt("InjectorCharge")*2,0,200), 40, Color(200,125,255,200))
	end
end