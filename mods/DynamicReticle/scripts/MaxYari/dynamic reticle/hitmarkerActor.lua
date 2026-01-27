local mp = "scripts/MaxYari/dynamic reticle/"

local omwself = require('openmw.self')
local animation = require('openmw.animation')
local AI = require('openmw.interfaces').AI

local gutils = require(mp.."gutils")
local AnimManager = require(mp.."anim_manager")
local EventsManager = require(mp .. "events_manager")
local DEFS = require(mp .. "defs")

local selfActor = gutils.Actor:new(omwself)
local selfObject = omwself.object

local onDamageEvents = EventsManager:new()

DebugLevel = 0

local recordBlackList = {"ab01alsonar","ab01bird01"} -- From where all birds going, don't need to process those, only wastes performance.
if gutils.foundInList(recordBlackList, omwself.recordId) then return end

local imAGuard = selfActor:isAGuard()
local healthData = selfActor.stats.dynamic.health()
local lastHealth = healthData.current


local function onUpdate(dt)
   
    local baseHealth = healthData.base
    local currentHealth = healthData.current
    local damageValue = lastHealth - currentHealth

    if damageValue > 0 then
        -- Should probably only fetch active packages here
        local activeAiPackage = AI.getActivePackage()
        if not activeAiPackage then return end        
        if activeAiPackage.type == "Combat" or (imAGuard and activeAiPackage.type == "Pursue") then
            local damageEventData = {
                hostile = selfObject,
                damage = damageValue, 
                damageFrac = damageValue/baseHealth,
                currentHealth = currentHealth 
            }

            local targets = AI.getTargets(activeAiPackage.type)
            for _, actor in ipairs(targets) do
                actor:sendEvent(DEFS.e.HostileDamaged, damageEventData)
            end

            onDamageEvents:emit(damageEventData)
        end
    end
    
    lastHealth = currentHealth
end

return {
    engineHandlers = {
        onUpdate = onUpdate,
    },
    interfaceName = "DynamicReticle",
    interface = {
        version=1.0, 
        onDamage = onDamageEvents,
    }
}