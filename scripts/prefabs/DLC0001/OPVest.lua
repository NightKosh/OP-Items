local assets = {
--    Asset("IMAGE", "images/inventoryimages/vanilla/opvest.tex"),
    Asset("ANIM", "anim/armor_ruins.zip"),
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_ruins", "swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = TUNING.ARMORSLURPER_SLOW_HUNGER
    end

    if owner.components.health then
        owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale - TUNING.ARMORDRAGONFLY_FIRE_RESIST
    end

    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = 1
    end

    if owner.components.health then
        owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale + TUNING.ARMORDRAGONFLY_FIRE_RESIST
    end

    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function onperish(inst)
end


local function ondaycomplete(inst)
    local seasonmgr = GetSeasonManager()
    if seasonmgr then
        if seasonmgr.current_season == SEASONS.SUMMER or
                seasonmgr.current_season == SEASONS.SPRING and seasonmgr.percent_season > 0.5 or
                seasonmgr.current_season == SEASONS.AUTUMN and seasonmgr.percent_season < 0.5 then
            inst.components.insulator:SetSummer()
        else
            inst.components.insulator:SetWinter()
        end
    end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("torso_bearger")
    inst.AnimState:SetBuild("torso_bearger")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("OPVest")
    inst:AddTag("metal")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "opvest"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/opvest.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED_LARGE
    inst.components.equippable.insulated = true

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("armor")
    inst.components.armor.dontremove = true
    inst.components.armor:InitCondition(TUNING.ARMOR_OPVEST, TUNING.ARMOR_SANITY_ABSORPTION)

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:ListenForEvent("daycomplete", ondaycomplete)

    ondaycomplete(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
--    inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled.accepting = true

    inst:AddTag("OPVest")

    return inst
end

return Prefab("common/inventory/opvest", fn, assets)
