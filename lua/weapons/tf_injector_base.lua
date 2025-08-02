SWEP.PrintName = "Energon Injector Base"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "Injector Base, you shouldn't have this"
SWEP.Instructions = "You don't use this"

SWEP.Slot = 4
SWEP.SlotPos = 3

SWEP.Category = "Transformers Injectors"
SWEP.Spawnable = false

SWEP.DrawAmmo = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = Model("models/megarexfoc/2023/c_energon_injector_stim.mdl")
SWEP.WorldModel = Model("models/megarexfoc/2023/w_energon_injector.mdl")
SWEP.ViewModelFOV = 75
SWEP.UseHands = true

SWEP.Charge = 100
SWEP.InjDist = 45 -- Distance you can inject other players/npcs from
SWEP.LiquidMat = "" -- Liquid material

SWEP.HealSound = Sound("cybertronian/energon_inject.wav")
SWEP.DenySound = Sound("WallHealth.Deny")

if SERVER then
	AddCSLuaFile()
end

function SWEP:Initialize()
	self:SetHoldType("slam")

	self:SetNWInt("InjectorCharge",self.Charge)
end

--cant use deploy/initialize because SWEP:Deploy() doesn't get called if you switch to a swep by spawning it while you already have it 
function SWEP:Think()
	if CLIENT then
		if(self:GetOwner():GetViewModel():GetSubMaterial(0) ~= self.LiquidMat) then
			self:GetOwner():GetViewModel():SetSubMaterial(0,self.LiquidMat)
		end
	else
		if(self:GetSubMaterial(0) ~= self.LiquidMat) then
			self:SetSubMaterial(0,self.LiquidMat)
		end
	end
end

function SWEP:TakeAmmo()
	self.Charge = self.Charge - 100
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

function SWEP:PrimaryAttack()
	local tr = self:GetOwner():GetEyeTraceNoCursor()

	if(self:GetOwner():GetShootPos():Distance(tr.HitPos) <= self.InjDist and IsValid(tr.Entity)) then
		self:InjectTarget(tr.Entity)
	else
		self:EmitSound(self.DenySound)
	end
end

function SWEP:SecondaryAttack()
	self:InjectTarget(self:GetOwner())
end

function SWEP:OnRemove()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("EnergonHeal" .. self:EntIndex())
	timer.Remove("InjectorRecharge"..self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end
end

function SWEP:Holster()
	timer.Remove("weapon_idle" .. self:EntIndex())
	timer.Remove("take_liquid"..self:EntIndex())

	if CLIENT then
		self:GetOwner():GetViewModel():SetSubMaterial(0,nil)
	end

	return true
end

if CLIENT then
	local goldmat = Material("models/player/shared/gold_player")

	function SWEP:DrawHUD() -- Display Charge
		
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, 200, 40, self.ChargeBGColor)

		if(self.ChargeColor == Color(255,220,0,200)) then --this doesn't work :(
			surface.SetMaterial(goldmat)
		end
		
		draw.RoundedBox(4,ScrW() - 300, ScrH() - 200, math.Clamp(self:GetNWInt("InjectorCharge")*2,0,200), 40, self.ChargeColor)
	end
end