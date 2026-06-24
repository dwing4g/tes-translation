--- Voices of Vvardenfell - OpenMW 0.51 global script.

local core = require('openmw.core')

return {
    eventHandlers = {
        --- Plays the resolved voice file on the given actor (keeps lip-sync).
        --- @param e any Event data with `actor` and `file`.
        VoV_PlayLine = function(e)
            if e.actor and e.file then
                core.sound.say(e.file, e.actor)
            end
        end,
        --- Stops any line currently playing on the given actor.
        --- @param e any Event data with `actor`.
        VoV_StopLine = function(e)
            if e.actor then
                core.sound.stopSay(e.actor)
            end
        end,
    },
}
