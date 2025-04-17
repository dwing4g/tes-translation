core = require('openmw.core')
types = require('openmw.types')

local target = nil
local player = nil

local function getFatigueTerm(target) -- float CreatureStats::getFatigueTerm() const
	local max = types.Actor.stats.dynamic.fatigue(target).base  --float max = getFatigue().getModified();
	local current = types.Actor.stats.dynamic.fatigue(target).current  --float current = getFatigue().getCurrent();
	local normalised = math.max(0,current/max) --float normalised = std::floor(max) == 0 ? 1 : std::max(0.0f, current / max);
	
	--const MWWorld::Store<ESM::GameSetting>& gmst
	--	= MWBase::Environment::get().getESMStore()->get<ESM::GameSetting>();
	
	local fFatigueBase = core.getGMST("fFatigueBase") --static const float fFatigueBase = gmst.find("fFatigueBase")->mValue.getFloat();
	local fFatigueMult = core.getGMST("fFatigueMult") --static const float fFatigueMult = gmst.find("fFatigueMult")->mValue.getFloat();
	
	return fFatigueBase - fFatigueMult * (1 - normalised);
end


local function getPickpocketingChanceModifier(target, add) --float Pickpocket::getChanceModifier(const MWWorld::Ptr& ptr, float add)
		--NpcStats& stats = ptr.getClass().getNpcStats(ptr);
        local agility = types.Actor.stats.attributes.agility(target).modified  --float agility = stats.getAttribute(ESM::Attribute::Agility).getModified();
        local luck = types.Actor.stats.attributes.luck(target).modified        --float luck = stats.getAttribute(ESM::Attribute::Luck).getModified();
        local sneak = types.NPC.stats.skills.sneak(target).modified          --float sneak = static_cast<float>(ptr.getClass().getSkill(ptr, ESM::Skill::Sneak));
        return (add + 0.2 * agility + 0.1 * luck + sneak) *getFatigueTerm(target) --return (add + 0.2f * agility + 0.1f * luck + sneak) * stats.getFatigueTerm();
end

local function toInt(x)
    if x >= 0 then
        return math.floor(x)
    else
        return math.ceil(x - 1)
    end
end

return function (item, self, target) --bool Pickpocket::pick(const MWWorld::Ptr& item, int count)
	target = target
	self = self
	local valueTerm = 0
	if item then
		local count = item.count or 1
		local record = item.type.records[item.recordId]
		local stackValue = record.value * count --float stackValue = static_cast<float>(item.getClass().getValue(item) * count);
		
		local fPickPocketMod = core.getGMST("fPickPocketMod")   -- float fPickPocketMod = MWBase::Environment::get()
																--	.getESMStore()
																--	->get<ESM::GameSetting>()
																--	.find("fPickPocketMod")
																--	->mValue.getFloat();
		valueTerm = 10*fPickPocketMod * stackValue --float valueTerm = 10 * fPickPocketMod * stackValue;
	end
    local x = getPickpocketingChanceModifier(self, 0) --float x = getChanceModifier(mThief);
    local y = getPickpocketingChanceModifier(target, valueTerm) --float y = getChanceModifier(mVictim, valueTerm);

    local t = 2 * x - y --float t = 2 * x - y;

    local pcSneak = types.NPC.stats.skills.sneak(self).modified --float pcSneak = static_cast<float>(mThief.getClass().getSkill(mThief, ESM::Skill::Sneak));
    local iPickMinChance = core.getGMST("iPickMinChance")	--int iPickMinChance = MWBase::Environment::get()
															--.getESMStore()
															--->get<ESM::GameSetting>()
															--.find("iPickMinChance")
															--->mValue.getInteger();
    local iPickMaxChance = core.getGMST("iPickMaxChance")	--int iPickMaxChance = MWBase::Environment::get()
															--.getESMStore()
															--->get<ESM::GameSetting>()
															--.find("iPickMaxChance")
															--->mValue.getInteger();

    --    auto& prng = MWBase::Environment::get().getWorld()->getPrng();
    --local roll = math.floor(100*math.random()) --int roll = Misc::Rng::roll0to99(prng);
	
    if t < pcSneak / iPickMinChance then --if (t < pcSneak / iPickMinChance)
        return toInt(pcSneak / iPickMinChance) --return (roll > int(pcSneak / iPickMinChance));
    else
        local t = math.min(iPickMaxChance, t) --t = std::min(float(iPickMaxChance), t);
        return toInt(t) --return (roll > int(t));
    end
end