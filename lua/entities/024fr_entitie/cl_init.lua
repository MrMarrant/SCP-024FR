include("shared.lua")

function ENT:Draw()
    self:DrawModel() 
end

function ENT:Think()
    if CLIENT then
        local trace = self:GetPos()
        local ents_in_shpere = ents.FindInSphere(trace, self.DistanceEffect)
        for k,v in pairs(ents_in_shpere) do
            if v:IsPlayer() then
                if !v:Alive() then return end
                v:SetEyeAngles((trace - v:GetShootPos()):Angle())
                if (!v.IsAffectBy024FR) then
                    v.IsAffectBy024FR = true
                    self:NearBy024FR(v)
                end
            end
        end
    end
end

-- Checks if a player is close to the entity, if it moves away, remove the blurry effect.
function ENT:NearBy024FR(victim)
	timer.Create("near_by_024fr_"..victim:SteamID(),( 1 / 100 ),1,function()
		if !IsValid(victim) then return end
        if !IsValid(self) then 
            victim.IsAffectBy024FR = false
            return 
        end
		if (self:CheckDistance(victim)) then
			self:NearBy024FR(victim)
		else
            victim.IsAffectBy024FR = false
		end
	end)
end

if (CLIENT) then
    -- Make a blurry vision on the screen of the player if it is affect by the entity.
    function EffectScreenAffectBy024FR()
        local ply = LocalPlayer()
        local curTime = FrameTime()
        if !ply.AddAlpha then ply.AddAlpha = 1 end
        if !ply.DrawAlpha then ply.DrawAlpha = 0 end
        if !ply.Delay then ply.Delay = 0 end
        if !ply.ColorDrain then ply.ColorDrain = 1 end
            
        if ply.IsAffectBy024FR then 
            ply.AddAlpha = 0.2
            ply.DrawAlpha = 0.5
            ply.Delay = 0.05
            ply.ColorDrain = 0
        else
            ply.AddAlpha = math.Clamp(ply.AddAlpha + curTime * 0.4, 0.2, 1)
            ply.DrawAlpha = math.Clamp(ply.DrawAlpha - curTime * 0.4, 0, 0.99)
            ply.Delay = math.Clamp(ply.Delay - curTime * 0.4, 0, 0.05)
            ply.ColorDrain = math.Clamp(ply.ColorDrain + curTime * 0.4, 0.66, 1)
        end
        
        DrawMotionBlur( ply.AddAlpha, ply.DrawAlpha, ply.Delay )
    end

    -- Hook called every tick who call the function EffectScreenAffectBy024FR().
    hook.Add("RenderScreenspaceEffects","EffectScreenAmnesiacA",EffectScreenAffectBy024FR)
end