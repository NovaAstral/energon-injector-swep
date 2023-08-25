SWEP.PrintName = "Injector Hands"
SWEP.Author = "Nova Astral"
SWEP.Purpose = "To not let you switch weapons when you get injected with dark energon"

SWEP.DrawCrosshair = false
SWEP.SlotPos = 1
SWEP.Slot = 0
SWEP.Spawnable = true
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
    timer.Create("DarkInjector_Death_Check"..self:EntIndex(),0.1,0,function()
        local tar = self:GetOwner():GetObserverTarget()
        self:GetOwner():DrawViewModel(false)

        if(!IsValid(tar)) then
            if(self:GetOwner():GetObserverMode() != OBS_MODE_NONE) then
                self:GetOwner():UnSpectate()
                self:GetOwner():Kill()
                self:GetOwner():GetRagdollEntity():Remove()
            end
        end
    end)
end

function SWEP:OnRemove()
	timer.Stop("DarkInjector_Death_Check"..self:EntIndex())
end