-- Show Me Everything 2.0
-- Event-only actor bridge. Idle actors do no polling and no per-frame work.

local I = require('openmw.interfaces')
local self = require('openmw.self')
local types = require('openmw.types')

I.Combat.addOnHitHandler(function(attack)
    if not attack or not attack.successful or not attack.attacker then
        return
    end
    if not types.Player.objectIsInstance(attack.attacker) then
        return
    end
    if not attack.damage or not attack.damage.health or attack.damage.health <= 0 then
        return
    end

    -- This handler runs before the resulting stat change is observed by the
    -- player's event handler. Sending the pre-hit health lets us recover the
    -- real post-armor/post-difficulty damage one frame later.
    local health = types.Actor.stats.dynamic.health(self)
    attack.attacker:sendEvent('SME_PlayerHitActor', {
        target = self.object,
        healthBefore = health.current,
    })
end)

return {}
