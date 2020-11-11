include("shared.lua")

--Set up the entity and its render targts and materials
function ENT:Initialize()
    --Set up back panel
    self.ClientModel = ClientsideModel("models/kingpommes/startrek/intrepid/breach_inside.mdl")
    self.ClientModel:SetPos(self:GetPos())
    self.ClientModel:SetAngles(self:GetAngles())
    self.ClientModel:SetParent(self)
    self.ClientModel:SetNoDraw(true)

    self.Offset       = 5
    self.TopBorder    = 5
    self.BottomBorder = 5
    self.LeftBorder   = 10
    self.RightBorder  = 10

    Star_Trek.Damage.Entities[self:EntIndex()] = self
end

function ENT:OnRemove()
    Star_Trek.Damage.Entities[self:EntIndex()] = nil
end