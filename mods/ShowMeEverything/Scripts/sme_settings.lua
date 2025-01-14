local storage = require('openmw.storage')
local I = require('openmw.interfaces')
local async = require('openmw.async')

I.Settings.registerPage {
    key = "SMESettingsBehavior",
    l10n = "SMESettingsBehavior",
    name = "显示一切：角色UI",
    description = "小部件的表现设置。"
}

I.Settings.registerPage {
    key = "SMESettingsStyle",
    l10n = "SMESettingsStyle",
    name = "显示一切：可视化",
    description = "小部件的样式设置。"
}

I.Settings.registerPage {
    key = "SMEhitChance",
    l10n = "SMEhitChance",
    name = "显示一切：命中率",
    description = "命中率小部件。基于Safeicus Boxius的代码和思想。"
}

I.Settings.registerGroup({
    key = 'SMESettingsBh', 
    page = 'SMESettingsBehavior',
    l10n = 'SMESettingsBehavior',
    name = '可视化',
    permanentStorage = true,
    settings = {
        {
            key = "SMEisActive",
            renderer = "checkbox",
            name = "允许修改",
            description =
            "取消选中可禁用显示一切的小部件。此设置用于控制和修改是否处于活动状态。",
            default = true
        },
        {
            key = "SMEClass",
            renderer = "checkbox",
            name = "显示NPC职业",
            description =
            "如果启用，小部件将显示NPC的职业。",
            default = true
        },
        {
            key = 'SMELevel',
            renderer = "checkbox",
            name = "显示NPC等级",
            description =
            "如果启用，小部件将显示NPC的等级。",
            default = true
        },
        {
            key = 'SMEHealth',
            renderer = "checkbox",
            name = "显示NPC血条",
            description =
            "如果启用，小部件将显示NPC的血条。",
            default = true
        },
        {
            key = 'SMEDamage',
            renderer = "checkbox",
            name = "显示伤害数值小部件",
            description =
            "如果启用，每次攻击NPC时，伤害数值都会显示出来。",
            default = true
        },
        {
            key = 'SMERaycastLength',
            name = '光线投射长度',
            description = '设置光线投射的长度。更高的值可以让你选择更远的目标，但可能会损失一些性能。默认值为3000，取值范围为1000 ~ 6000。',
            default = 3000,
            renderer = 'number',
            argument = {
                min = 1000,
                max = 6000,
                integer = true,
            },
        },
        {
            key = 'SMEShowDistance',
            name = '小部件显示距离',
            description = '设置小部件在注视角色时才会显示的距离。设置为192，显示范围类似原版游戏的激活距离。取值介于192到1000之间。',
            default = 500,
            renderer = 'number',
            argument = {
                min = 192,
                max = 1000,
                integer = true,
            },
        },
        {
            key = 'SMEStance',
            renderer = "checkbox",
            name = "只在战斗状态显示",
            description =
            "如果启用，小部件程序将在后台工作，但只有当你处于战斗状态或注视的人受到伤害时，小部件才会显示。",
            default = false
        },
        {
            key = 'SMEonHit',
            renderer = "checkbox",
            name = "只在命中后显示",
            description =
            "如果启用，该小部件将只在您击中角色并对其造成伤害时显示。覆盖之前的设置",
            default = false
        },
        {
            key = 'SMEnotForDead',
            renderer = "checkbox",
            name = "小部件显示死亡角色",
            description =
            "若被禁用，所有死去的角色都将被忽略，并且小部件将只显示活着（或是不死）的角色。",
            default = true
        },
    },
})

I.Settings.registerGroup({
    key = 'SMESettingsSt', 
    page = 'SMESettingsStyle',
    l10n = 'SMESettingsStyle',
    name = '可视化',
    permanentStorage = true,
    settings = {
        {
            key = 'SMEWidgetStyle',
            name = '小部件的可视化预设',
            description = '在这里，您可以为小部件选择两种预设中的一种。',
            default = '原版风格', 
            renderer = 'select',
            argument = {
                disabled = false,
                l10n = 'LocalizationContext', 
                items = {'原版风格', '天际风格', 'ESO风格', '简约平面风格', '原版极简风格', '第六家族风格'},
            },
        },
    },
})

I.Settings.registerGroup({
    key = 'SMEHitChanceSettings', 
    page = 'SMEhitChance',
    l10n = 'SMEhitChance',
    name = '命中率小部件设置',
    permanentStorage = true,
    settings = {
        {
            key = "hitChanceIsActive",
            renderer = "checkbox",
            name = "命中率指示开关",
            description =
            "取消选中以禁用命中率指示。此设置控制指示器是否显示。",
            default = true
        },
        {
            key = 'SMEhitChanceWidget',
            name = '命中率小部件可视化预设',
            description = '在这里，您可以从几种预设小部件中选择一种。',
            default = '百分比',
            renderer = 'select',
            argument = {
                disabled = false,
                l10n = 'LocalizationContext', 
                items = {'百分比', '圆圈', '比例尺'},
            },
        },
        {
            key = "SMEhitChanceReticle",
            renderer = "checkbox",
            name = "命中率彩色准心",
            description =
            "如果启用，准心将会根据命中率显示相应的颜色。",
            default = false
        },
    },
})


local settings = {
    behavior = storage.playerSection('SMESettingsBh'),
    style = storage.playerSection('SMESettingsSt'),
    hitChance = storage.playerSection('SMEHitChanceSettings'),
}

local stanceIsEnabled = false
local onHitIsEnabled = false

local function disableModification()
    local disabled = not settings.behavior:get('SMEisActive')
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEClass', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMELevel', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEHealth', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEDamage', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEStance', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEonHit', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEnotForDead', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMERaycastLength', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsBh', 'SMEShowDistance', {disabled = disabled})
    I.Settings.updateRendererArgument('SMESettingsSt', 'SMEWidgetStyle', {disabled = disabled, l10n = 'randomValue', items = {'原版风格', '天际风格', 'ESO风格', '简约平面风格', '原版极简风格', '第六家族风格'}})
    
    
end

local function disableHitChance()
    local disabled = not settings.hitChance:get('hitChanceIsActive')
    I.Settings.updateRendererArgument('SMEHitChanceSettings', 'SMEhitChanceReticle', {disabled = disabled})
    I.Settings.updateRendererArgument('SMEHitChanceSettings', 'SMEhitChanceWidget', {disabled = disabled, l10n = 'randomValue', items = {'百分比', '圆圈', '比例尺'}})
    
    
end


disableModification()
disableHitChance()


settings.behavior:subscribe(async:callback(disableModification))
settings.hitChance:subscribe(async:callback(disableHitChance))


local mxRaycastLengthLastCheck = 0
local mxRaycastLengthThisCheck = 0
local raycastLength = 0
local timeToUpdateSettings = 0
local activateLength = 0
local onHitThisFrame
local onHitLastFrame
local onStanceThisFrame
local onStanceLastFrame


local function onFrame(dt)

    if I.UI.getMode() == 'SettingsMenu' then
        timeToUpdateSettings = timeToUpdateSettings + 1
    end

    if timeToUpdateSettings > 20 and I.UI.getMode() == 'SettingsMenu' then
        
        raycastLength = settings.behavior:get('SMERaycastLength')
        activateLength = settings.behavior:get('SMEShowDistance')

        if settings.behavior:get('SMERaycastLength') and raycastLength > 6000 then
            settings.behavior:set('SMERaycastLength', 6000)
        elseif settings.behavior:get('SMERaycastLength') and raycastLength < 1000 then
            settings.behavior:set('SMERaycastLength', 1000)
        end

        if settings.behavior:get('SMEShowDistance') and activateLength > 1000 then
            settings.behavior:set('SMEShowDistance', 1000)
        elseif settings.behavior:get('SMEShowDistance') and activateLength < 192 then
            settings.behavior:set('SMEShowDistance', 192)
        end
        onStanceThisFrame = settings.behavior:get('SMEStance')

        if settings.behavior:get('SMEonHit') and onStanceThisFrame == onStanceLastFrame and settings.behavior:get('SMEStance') then
            print(settings.behavior:get('SMEonHit'), settings.behavior:get('SMEStance'), onStanceThisFrame, onStanceLastFrame)
            settings.behavior:set('SMEStance', false)
            
        elseif settings.behavior:get('SMEonHit') and settings.behavior:get('SMEStance') then
            print(settings.behavior:get('SMEonHit'), settings.behavior:get('SMEStance'), onStanceThisFrame, onStanceLastFrame)
            settings.behavior:set('SMEonHit', false)
        end
        onStanceLastFrame = onStanceThisFrame
        timeToUpdateSettings = 0
    end

end

return {
    engineHandlers = {
        dt = dt,
        onUpdate = onUpdate,
        onFrame = onFrame,
        onLoad = onLoad,
    },
}
