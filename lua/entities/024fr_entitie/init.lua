AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local TimerNextChrono = {
	15,
	20,
	10,
	5,
	10,
	10,
	15,

}

local TextToSay = {
	["fr"] = {
		"s'interesse au sandwich et commence à tourner autour pour mieux apprécier sa longueur.",
		"utilise désormais ses mains pour mesurer le sandwich, comparant visiblement la longueur, la largeur, et le diamètre.",
		"est en intense réflexion, reportant les mesures effectué précedemment sur sa mâchoire.",
		"saisi l'objet et tente de l’insérer dans sa bouche, sans succès.",
		"tente d'ouvrir la bouche plus grand, s'aidant de ses mains, reportant toujours les mesures sur sa mâchoire.",
		"se saisit d'une main de sa mâchoire inférieure et de l'autre sa mâchoire supérieure, et appuyant avec force.",
		"casse sa mâchoire. Il persiste à tenter de mettre l'objet dans sa bouche sans succès."
	},
	["en"] = {
		"becomes interested in the sandwich and begins to turn it around to better appreciate its length.",
		"now uses his hands to measure the sandwich, visibly comparing length, width, and diameter.",
		"is in deep thought, transferring the measurements he made earlier to his jaw.",
		"grasped the object and tried to insert it into his mouth, without success.",
		"tries to open his mouth wider, helping himself with his hands, still transferring the measurements to his jaw.",
		"takes hold of his lower jaw with one hand and his upper jaw with the other, and presses with force",
		"breaks his jaw. He persists in trying to put the object in his mouth without success."
	}
}

local TextFarFrom = {
	["fr"] = {
		"reprend ses esprits et n'est plus obsédé par l'entité."
	},
	["en"] = {
		"comes to his senses and is no longer obsessed with the entity."
	}
}

local TextOnDeath = {
	["fr"] = {
		"Et maintenant, on est délicieux ?"
	},
	["en"] = {
		"Are we tasty yet ?"
	}
}

local TextInfo = {
	["fr"] = {
		"Vous êtes désormais affecté par SCP-024FR, vous ne devez pas vous éloigner de l'entité sauf si on vous force."
	},
	["en"] = {
		"You are now affected by SCP-024FR, you should not move away from the entity unless forced."
	}
}

-- Return true if the player is no sleeping or frozen.
local function StatusPlayer(ply)
	if ply.Sleeping then return false end
	if ply:IsFrozen() then return false end
	if !IsValid(ply) then return false end
	return true
end

-- Principal function where it go step by steps in the affection to SCP-024-FR.
function ENT:AffectedBy024FR(ply, i)
	timer.Create("affect_by_024_fr_"..ply:SteamID(),TimerNextChrono[i],1,function()
		if !IsValid(ply) then return end
		if !IsValid(self) then 
			ply.AffectedBy024FR = false
			return 
		end
		if (!StatusPlayer(ply)) then return end -- If the player is sleeping or freeze, stop the effect.
		if (self:CheckDistance(ply)) then -- If the player is far away from the entitie, stop the effect.
			if (i == 1) then
				ply:PrintMessage(HUD_PRINTTALK, TextInfo[langUser][1])
			end
			ply:Say("/me "..TextToSay[langUser][i])
			if (i == 4) then
				ply:EmitSound("scp_024fr/animal_eating.mp3")
			end
			if (i == 7) then
				ply:TakeDamage(ply:Health()*0.8)
				ply:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav")
				timer.Create("blood_lost_"..ply:SteamID(),5,0,function()
					if !IsValid(ply) then return end
					ply:EmitSound("vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav")
					ply:TakeDamage(ply:GetMaxHealth() * 0.1 )
					if (ply:Health() <= 0) then
						ply:Kill()
						ply:PrintMessage(HUD_PRINTTALK, TextOnDeath[langUser][1])
					end
				end)
			end
			if (i < 7) then
				self:AffectedBy024FR(ply, i + 1)
			end
		else
			ply.AffectedBy024FR = false
			if (i >= 2) then
				ply:Say("/me "..TextFarFrom[langUser][1])
			end
		end
	end)
end

function ENT:Initialize()
    self:SetModel( 'models/scp_024fr/sandwich.mdl' )
	self:SetModelScale(4)
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Think()
	local trace = self:GetPos()
	local ents_in_shpere = ents.FindInSphere(trace, self.DistanceEffect)
	for k,v in pairs(ents_in_shpere) do
		if v:IsPlayer() then
			if !v:Alive() then return end
			if timer.Exists("affect_by_024_fr_"..v:SteamID()) then return end
			if timer.Exists("blood_lost_"..v:SteamID()) then return end
			if v.AffectedBy024FR then return end
			if StatusPlayer(v) then 
				v.AffectedBy024FR = true
				self:AffectedBy024FR(v, 1)
			end
		end
	end
end

-- Function called to remove all effect on death or changed team
function RemoveEffect024FR(victim)
	if (victim.AffectedBy024FR) then
		victim.AffectedBy024FR = false
	end
	if timer.Exists("affect_by_024_fr_"..victim:SteamID()) then
		timer.Remove("affect_by_024_fr_"..victim:SteamID())
	end
	if timer.Exists("blood_lost_"..victim:SteamID()) then
		timer.Remove("blood_lost_"..victim:SteamID())
	end
end

hook.Add( "PlayerDeath", "effect_024_fr_remove", RemoveEffect024FR )
hook.Add( "PlayerChangedTeam", "PlayerChangedTeam_effect_024_fr_remove", RemoveEffect024FR )