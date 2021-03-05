include("shared.lua")

local GRAV_SPARKS = Vector(0, 0, -500)

function ENT:SpawnSparks()
	local dir = self:GetForward()

	for i = 1, 300 do
		local spark = self.Emitter:Add("effects/spark", self:GetPos())
		if spark then
			spark:SetVelocity(dir * math.random(10, 20) + AngleRand():Forward() * math.random(20, 40))
			spark:SetGravity(GRAV_SPARKS / 5)
			
			spark:SetDieTime(1)
	
			spark:SetStartAlpha(127)
			spark:SetEndAlpha(0)
		
			spark:SetStartSize(2)
			spark:SetEndSize(0)
		end
	end
	
	for i = 1, 100 do
		local spark = self.Emitter:Add("effects/spark", self:GetPos())
		if spark then
			spark:SetVelocity(dir * math.random(100, 150) + AngleRand():Forward() * math.random(40, 80))
			spark:SetGravity(GRAV_SPARKS)
			
			spark:SetDieTime(2)
	
			spark:SetStartAlpha(255)
			spark:SetEndAlpha(0)
		
			spark:SetStartSize(1)
			spark:SetEndSize(0)
		end
	end
end

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
	
	self.Emitter = ParticleEmitter(self:GetPos(), false)
	self.LastThink = CurTime()
	self:SpawnSparks()

	self.FlameDir = self:GetForward() * 5 + AngleRand():Forward()
	self.FlameDir:Normalize()

	Star_Trek.Damage.Entities[self:EntIndex()] = self
end

function ENT:Think()
	if self.LastThink + 0.05 > CurTime() then return end
	self.LastThink = CurTime()

	local flame = self.Emitter:Add("effects/energyball", self:GetPos())
	if flame then
		flame:SetVelocity(self.FlameDir * math.random(40, 50))
		flame:SetGravity(-GRAV_SPARKS / 5)
		
		flame:SetDieTime(0.8)
		flame:SetColor(math.random(200, 255), math.random(0, 50), 0)

		flame:SetStartAlpha(127)
		flame:SetEndAlpha(0)
	
		flame:SetStartSize(3)
		flame:SetEndSize(10)
	end
	
	local flame = self.Emitter:Add("effects/energyball", self:GetPos())
	if flame then
		flame:SetVelocity(self.FlameDir * math.random(40, 50))
		flame:SetGravity(-GRAV_SPARKS / 5)
		
		flame:SetDieTime(0.9)
		flame:SetColor(math.random(80, 120), math.random(80, 120), 0)

		flame:SetStartAlpha(200)
		flame:SetEndAlpha(1)
	
		flame:SetStartSize(2)
		flame:SetEndSize(5)
	end
	
	local spark = self.Emitter:Add("effects/energyball", self:GetPos())
	if spark then
		spark:SetVelocity(self.FlameDir * math.random(40, 50) + AngleRand():Forward() * math.random(0, 5))
		spark:SetGravity(-GRAV_SPARKS / 5)
		
		spark:SetDieTime(0.3)

		spark:SetStartAlpha(31)
		spark:SetEndAlpha(0)
	
		spark:SetStartSize(2)
		spark:SetEndSize(1)
	end
end

function ENT:OnRemove()
	self.ClientModel:Remove()
	self.Emitter:Finish()
	Star_Trek.Damage.Entities[self:EntIndex()] = nil
end