ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "BIBI"
ENT.PrintName = "SCP-024-FR"
ENT.Purpose = "Et maintenant, on est cool ?"
ENT.Spawnable = true
ENT.Category = "BIBI entities"

ENT.DistanceEffect = 70 -- Distance effect of the object.  -- TODO Revoir la taille de la place de son confinement.

-- Return true if the player is close from the entitie.
function ENT:CheckDistance(ply)
	local tracePly = ply:GetPos()
	local entsSpherePly = ents.FindInSphere(tracePly, self.DistanceEffect)
	for k,v in pairs(entsSpherePly) do
		if v == self then
			return true
		end
	end
	return false
end

local HandledLanguage = {
    "fr",
    "en"
}

-- Get the current language of the user
langUser = GetConVar("gmod_language"):GetString()
cvars.AddChangeCallback("gmod_language", function(name, old, new)
    langUser = new
end)
if (langUser) then
    if !table.HasValue(HandledLanguage, langUser) then
        langUser = "en"
    end
else
    langUser = "en"
end