local assets =
{
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
    Asset("IMAGE", "images/inventoryimages/vanilla/opamulet.tex"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

--- RED
local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:IsHurt())
            and (owner.components.hunger and owner.components.hunger.current > 5) then
        owner.components.health:DoDelta(TUNING.REDAMULET_CONVERSION, false, "redamulet")
    end
end

local function onequip_red(inst, owner)
    inst.task = inst:DoPeriodicTask(30, function() healowner(inst, owner) end)
end

local function onunequip_red(inst, owner)
    if inst.task then inst.task:Cancel() inst.task = nil end
end

--- BLUE
local function onequip_blue(inst, owner)
    inst.freezefn = function(attacked, data)
        if data and data.attacker and data.attacker.components.freezable then
            data.attacker.components.freezable:AddColdness(0.67)
            data.attacker.components.freezable:SpawnShatterFX()
        end
    end

    inst:ListenForEvent("attacked", inst.freezefn, owner)
end

local function onunequip_blue(inst, owner)
    inst:RemoveEventCallback("attacked", inst.freezefn, owner)
end

--- PURPLE
local function induceinsanity(val, owner)
    if owner.components.sanity then
        owner.components.sanity.inducedinsanity = val
    end
    if owner.components.sanitymonsterspawner then
        --Ensure the popchangetimer fully ticks over by running max tick time twice.
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
    end

    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 100, nil, nil, { 'rabbit', 'manrabbit' })

    for k, v in pairs(ents) do
        if v.CheckTransformState ~= nil then
            v.CheckTransformState(v)
        end
    end
end

--- ORANGE
local function SpawnEffect(inst)
    local pt = inst:GetPosition()
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(pt.x, pt.y, pt.z)
    fx.Transform:SetScale(0.5, 0.5, 0.5)
end

local function getitem(player, amulet, item)
    --Amulet will only ever pick up items one at a time. Even from stacks.
    SpawnEffect(item)

    if item.components.stackable then
        item = item.components.stackable:Get()
    end

    if item.components.trap and item.components.trap:IsSprung() then
        item.components.trap:Harvest(player)
        return
    end

    player.components.inventory:GiveItem(item)
end

local function pickup(inst, owner)
    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.ORANGEAMULET_RANGE)

    for k, v in pairs(ents) do
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer and not
        v.components.inventoryitem:IsHeld() then

            if not owner.components.inventory:IsFull() then
                --Your inventory isn't full, you can pick something up.
                getitem(owner, inst, v)
                return

            elseif v.components.stackable then
                --Your inventory is full, but the item you're trying to pick up stacks. Check for an exsisting stack.
                --An acceptable stack should: Be of the same item type, not be full already and not be in the "active item" slot of inventory.
                local stack = owner.components.inventory:FindItem(function(item) return (item.prefab == v.prefab and not item.components.stackable:IsFull()
                        and item ~= owner.components.inventory.activeitem)
                end)
                if stack then
                    getitem(owner, inst, v)
                    return
                end
            end
        end
    end
end

--- COMMON FUNCTIONS
local function onfinished(inst)
end


local function caninteract(inst)
    return inst:HasTag("nonighmare")
end

local function onuse(inst)
    local owner = inst.components.inventoryitem.owner
    inst:RemoveTag("nonighmare")
    induceinsanity(true, owner)
end

local function onstopusing(inst)
    local owner = inst.components.inventoryitem.owner
    inst:AddTag("nonighmare")
    induceinsanity(nil, owner)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")
    onequip_red(inst, owner)
    onequip_blue(inst, owner)

    owner.components.builder.ingredientmod = TUNING.GREENAMULET_INGREDIENTMOD

    inst.Light:Enable(true)

    inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, function() pickup(inst, owner) end)

--    owner.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    onunequip_red(inst, owner)
    onunequip_blue(inst, owner)

    onstopusing(inst)

    owner.components.builder.ingredientmod = 1

    inst.Light:Enable(false)

    if inst.task then inst.task:Cancel() inst.task = nil end
end

local function ondaycomplete(inst)
    local seasonmgr = GetSeasonManager()
    if seasonmgr then
        if seasonmgr.current_season == SEASONS.SUMMER or
                seasonmgr.current_season == SEASONS.SPRING and seasonmgr.percent_season > 0.5 or
                seasonmgr.current_season == SEASONS.AUTUMN and seasonmgr.percent_season < 0.5 then
            inst.components.heater.iscooler = true
            inst.components.heater.equippedheat = TUNING.BLUEGEM_COOLER
        else
            inst.components.heater.iscooler = false
            inst.components.heater.equippedheat = -TUNING.BLUEGEM_COOLER
        end
    end
end

local function fn(inst)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("amulets")

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL


    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    inst.components.inventoryitem.imagename = "opamulet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/opamulet.xml"

    inst.AnimState:PlayAnimation("redamulet")
    inst.components.inventoryitem.keepondeath = true
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.components.equippable.walkspeedmult = 1.2
    inst.components.inventoryitem:SetOnDroppedFn(function(inst) inst.Light:Enable(false) end)

    local light = inst.entity:AddLight()
    light:SetFalloff(0.4)
    light:SetIntensity(.7)
    light:SetRadius(2.5)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(false)

    inst:AddComponent("heater")
    ondaycomplete(inst)

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetCanInteractFn(caninteract)
    inst.components.useableitem:SetOnUseFn(onuse)
    inst.components.useableitem:SetOnStopUseFn(onstopusing)

    inst:ListenForEvent("daycomplete", ondaycomplete)

    inst:AddTag("nonighmare")
    inst:AddTag("OPAmulet")

    return inst
end

return Prefab("common/inventory/opamulet", fn, assets)
