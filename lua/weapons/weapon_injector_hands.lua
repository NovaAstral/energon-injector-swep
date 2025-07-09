SWEP.PrintName = "Injector Hands"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "To not let you switch weapons when you get injected with dark energon"

SWEP.DrawCrosshair = false
SWEP.SlotPos = 1
SWEP.Slot = 0
SWEP.Spawnable = false
SWEP.Weight = 1
SWEP.HoldType = "normal"
SWEP.Primary.Ammo = "none" --This stops it from giving pistol ammo when you get the hands
SWEP.Primary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true

function SWEP:DrawWorldModel() end
function SWEP:DrawWorldModelTranslucent() end
function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return false end -- Prevent the player from switching away from the hands
function SWEP:ShouldDropOnDie() return false end
function SWEP:PreDrawViewModel() return true end -- This stops it from displaying as a pistol in your hands

function SWEP:Initialize()
    timer.Simple(0.1,function()
        self.OwnPly = self:GetOwner()
        print(self.OwnPly)
    end)

    timer.Create("DarkInjector_Death_Check"..self:EntIndex(),0.1,0,function()
        if(IsValid(self) and IsValid(self:GetOwner())) then
            self.obstar = self:GetOwner():GetObserverTarget()
            self:GetOwner():DrawViewModel(false)

            if(SERVER and !IsValid(self.obstar)) then
                if(self:GetOwner():GetObserverMode() != OBS_MODE_NONE) then
                    self:GetOwner():UnSpectate()
                    self:GetOwner():Kill()
                    self:GetOwner():GetRagdollEntity():Remove()
                end
            end
        end
    end)
end

function SWEP:Ded()
    timer.Remove("DarkInjector_Death_Check"..self:EntIndex())

    if(SERVER and IsValid(self.obstar)) then
        if(IsValid(self.OwnPly)) then
            self.OwnPly:UnSpectate()
            self.OwnPly:Kill()
            self.OwnPly:GetRagdollEntity():Remove()
        end
        
        self.obstar:TakeDamage(200) -- yeet the zombi because player died and player is supposed to tbe the zombi

        timer.Simple(0.1,function() -- if for whatever reason the zombie didnt die, delete it
            if(IsValid(self.obstar)) then
                self.obstar:Remove()
                self.OwnPly:GetRagdollEntity():Remove()
            end
        end)
    end
end

function SWEP:OnRemove()
	self:Ded()
end

function SWEP:OnDrop()
    self:Ded()
end

function SWEP:CalcView(ply,pos,ang,fov)
	if(IsValid(self.obstar)) then
		local newpos = pos + Vector(0,0,30)
		return newpos,ang,fov
	end
end