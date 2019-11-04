local assets=
{
	Asset("ANIM", "anim/bugnet.zip"),
	Asset("ANIM", "anim/swap_bugnet.zip"),
    Asset("IMAGE", "images/inventoryimages/vanilla/opbugnet.tex"),
}


local function onfinished(inst)
    inst:Remove()
end

local function onequip (inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_bugnet", "swap_bugnet")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("bugnet")
    anim:SetBuild("bugnet")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BUGNET_DAMAGE)
	inst.components.weapon.attackwear = 3

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.NET)
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "opbugnet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/opbugnet.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    
    return inst
end

return Prefab( "common/inventory/opbugnet", fn, assets)
