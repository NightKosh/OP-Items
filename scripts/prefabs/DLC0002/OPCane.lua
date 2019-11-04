local assets =
{
    Asset("ANIM", "anim/cane.zip"),
    Asset("ANIM", "anim/swap_cane.zip"),
    Asset("IMAGE", "images/inventoryimages/vanilla/opcane.tex"),
}

local prefabs =
{
    "shadowtentacle",
}

local summonchance = 0.2

local function onattack(inst, owner, target)
    if math.random() < summonchance then
        local pt = target:GetPosition()
        local st_pt =  FindWalkableOffset(pt or owner:GetPosition(), math.random()*2*PI, 2, 3)
        if st_pt then
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
            st_pt = st_pt + pt
            local st = SpawnPrefab("shadowtentacle")
            --print(st_pt.x, st_pt.y, st_pt.z)
            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
            st.components.combat:SetTarget(target)
        end
    end

    if owner.components.health and owner.components.health:GetPercent() < 1 and not target:HasTag("wall") then
        owner.components.health:DoDelta(TUNING.BATBAT_DRAIN,false,"batbat")
        owner.components.sanity:DoDelta(-TUNING.BATBAT_DRAIN * 0.5)
    end
end


local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_cane", "swap_cane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn(Sim, target, inst)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    anim:SetBank("cane")
    anim:SetBuild("cane")
    anim:PlayAnimation("idle")

    inst:AddTag("sharp")

    ---------------------------------
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.OPCANE_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddInherentAction(ACTIONS.TERRAFORM)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "opcane"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/opcane.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.OPCANE_SPEED_MULT

    inst:AddComponent("tool")
    inst:AddComponent("shaver")
    inst:AddComponent("workable")
    inst:AddComponent("terraformer")

    inst.components.tool:SetAction(ACTIONS.MINE)
    inst.components.tool:SetAction(ACTIONS.CHOP)
    inst.components.tool:SetAction(ACTIONS.DIG)
    inst.components.tool:SetAction(ACTIONS.HACK)
    inst.components.tool:SetAction(ACTIONS.HAMMER)
    inst.components.tool:SetAction(ACTIONS.TERRAFORM)
    inst.components.tool:SetAction(ACTIONS.SHAVE)

    inst:AddTag("OPCane")

    return inst
end

return Prefab("common/inventory/opcane", fn, assets)
