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
function SWEP:CreateZombie(ent)
	if(IsValid(ent)) then
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
		self:EmitSound(HealSound)

		if(ent == self:GetOwner()) then
			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			self:SetNextSecondaryFire(CurTime() + self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)))

			if SERVER then
				timer.Simple(self:SequenceDuration(self:SelectWeightedSequence(ACT_VM_SECONDARYATTACK)),function() 
					self:TakeAmmo()
					self:CreateZombie(ent)
				end)
			end
		else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())

			if SERVER then
				timer.Simple(self:SequenceDuration()+0.1,function() 
					self:TakeAmmo()
					self:CreateZombie(ent)
				end)
			end

			timer.Create("weapon_idle" .. self:EntIndex(),self:SequenceDuration(),1,function()
				if(IsValid(self)) then 
					self:SendWeaponAnim(ACT_VM_IDLE)
				end 
			end)
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
	timer.Stop( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Holster()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
	return true
end

if CLIENT then
	function SWEP:DrawHUD() -- Display uses
		draw.WordBox(10, ScrW() - 200, ScrH() - 140, "Uses Left: " .. self:GetNWInt("Uses"), "Default", Color(0, 0, 0, 80), Color(255, 220, 0, 220))
	end
end