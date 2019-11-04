local assets =
{
    Asset("ANIM", "anim/cane.zip"),
    Asset("ANIM", "anim/swap_cane.zip"),
--    Asset("ANIM", "anim/staffs.zip"),
--    Asset("ANIM", "anim/swap_staffs.zip"),
    Asset("IMAGE", "images/inventoryimages/vanilla/opstaff.tex"),
}

local prefabs =
{
    "shadowtentacle",
}

local summonchance = 0.2

local DESTSOUNDS =
{
    {   --magic
        soundpath = "dontstarve/common/destroy_magic",
        ing = {"nightmarefuel", "livinglog"},
    },
    {   --cloth
        soundpath = "dontstarve/common/destroy_clothing",
        ing = {"silk", "beefalowool"},
    },
    {   --tool
        soundpath = "dontstarve/common/destroy_tool",
        ing = {"twigs"},
    },
    {   --gem
        soundpath = "dontstarve/common/gem_shatter",
        ing = {"redgem", "bluegem", "greengem", "purplegem", "yellowgem", "orangegem"},
    },
    {   --wood
        soundpath = "dontstarve/common/destroy_wood",
        ing = {"log", "board"}
    },
    {   --stone
        soundpath = "dontstarve/common/destroy_stone",
        ing = {"rocks", "cutstone"}
    },
    {   --straw
        soundpath = "dontstarve/common/destroy_straw",
        ing = {"cutgrass", "cutreeds"}
    },
}

local function candestroy(staff, caster, target)
    if not target then return false end

    local recipe = GetRecipe(target.prefab)

    return recipe ~= nil
end

local function SpawnLootPrefab(inst, lootprefab)
    if lootprefab then
        local loot = SpawnPrefab(lootprefab)
        if loot then

            local pt = Point(inst.Transform:GetWorldPosition())

            loot.Transform:SetPosition(pt.x,pt.y,pt.z)

            if loot.Physics then

                local angle = math.random()*2*PI
                loot.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))

                if loot.Physics and inst.Physics then
                    pt = pt + Vector3(math.cos(angle), 0, math.sin(angle))*(loot.Physics:GetRadius() + inst.Physics:GetRadius())
                    loot.Transform:SetPosition(pt.x,pt.y,pt.z)
                end

                loot:DoTaskInTime(1,
                    function()
                        if not (loot.components.inventoryitem and loot.components.inventoryitem:IsHeld()) then
                            if not loot:IsOnValidGround() then
                                local fx = SpawnPrefab("splash_ocean")
                                local pos = loot:GetPosition()
                                fx.Transform:SetPosition(pos.x, pos.y, pos.z)
                                --PlayFX(loot:GetPosition(), "splash", "splash_ocean", "idle")
                                if loot:HasTag("irreplaceable") then
                                    loot.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
                                else
                                    loot:Remove()
                                end
                            end
                        end
                    end)
            end

            return loot
        end
    end
end

local function getsoundsforstructure(inst, target)

    local sounds = {}

    local recipe = GetRecipe(target.prefab)

    if recipe then
        for k, soundtbl in pairs(DESTSOUNDS) do
            for k2, ing in pairs(soundtbl.ing) do
                for k3, rec_ingredients in pairs(recipe.ingredients) do
                    if rec_ingredients.type == ing then
                        table.insert(sounds, soundtbl.soundpath)
                    end
                end
            end
        end
    end

    return sounds

end

local function destroystructure(staff, target)

    local ingredient_percent = 1

    if target.components.finiteuses then
        ingredient_percent = target.components.finiteuses:GetPercent()
    elseif target.components.fueled and target.components.inventoryitem then
        ingredient_percent = target.components.fueled:GetPercent()
    elseif target.components.armor and target.components.inventoryitem then
        ingredient_percent = target.components.armor:GetPercent()
    end

    local recipe = GetRecipe(target.prefab)

    local caster = staff.components.inventoryitem.owner

    local loot = {}

    if recipe then
        for k,v in ipairs(recipe.ingredients) do
            if not string.find(v.type, "gem") then
                local amt = math.ceil(v.amount * ingredient_percent)
                for n = 1, amt do
                    table.insert(loot, v.type)
                end
            end
        end
    end

    if #loot <= 0 then
        return
    end

    local sounds = {}
    sounds = getsoundsforstructure(staff, target)
    for k,v in pairs(sounds) do
        print("playing ",v)
        staff.SoundEmitter:PlaySound(v)
    end

    for k,v in pairs(loot) do
        SpawnLootPrefab(target, v)
    end

    staff.SoundEmitter:PlaySound("dontstarve/common/staff_star_dissassemble")

    if target.components.inventory then
        target.components.inventory:DropEverything()
    end

    if target.components.container then
        target.components.container:DropEverything()
    end

    if target.components.stackable then
        --if it's stackable we only want to destroy one of them.
        target = target.components.stackable:Get()
    end

    target:Remove()

    if target.components.resurrector and not target.components.resurrector.used then
        local player = GetPlayer()
        if player then
            player.components.health:RecalculatePenalty()
        end
    end
end

local function onblink(staff, pos, caster)
    if caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MED)
    end
end

local function cancreatelight(staff, caster, target, pos)
    local ground = GetWorld()
    if ground and pos then
        local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        return tile ~= GROUND.IMPASSIBLE and tile < GROUND.UNDERGROUND
    end
    return false
end

local function createlight(staff, target, pos)
    local light = SpawnPrefab("stafflight")
    light.Transform:SetPosition(pos.x, pos.y, pos.z)
    staff.components.finiteuses:Use(1)

    local caster = staff.components.inventoryitem.owner
    if caster and caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
    end

end

local function onattack_blue(inst, attacker, target)

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable and target.components.burnable:IsBurning() then
        target.components.burnable:Extinguish()
    end
    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
        if target.sg and not target.sg:HasStateTag("frozen") and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
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

local function caninteract(inst)
    return inst:HasTag("orange_op_staff")
end

local function onuse(inst)
    if inst:HasTag("orange_op_staff") then
        inst:RemoveTag("orange_op_staff")
        inst:AddTag("yellow_op_staff")
    end
end

local function onstopusing(inst)
    inst:RemoveTag("yellow_op_staff")
    inst:AddTag("orange_op_staff")
end

local function fn(Sim, target, inst)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    anim:SetBank("staffs")
    anim:SetBuild("staffs")
    anim:PlayAnimation("orangestaff")

    ---------------------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "opstaff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/opstaff.xml"

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.OPCANE_SPEED_MULT

    inst:AddTag("icestaff")
--    inst:AddTag("rangedlighter")
    inst:AddTag("extinguisher")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_blue)
    inst.components.weapon:SetProjectile("ice_projectile")

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff.onblinkfn = onblink

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        return inst.components.blinkstaff:GetBlinkPoint()
    end
    inst.components.reticule.ease = true

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetCanInteractFn(caninteract)
    inst.components.useableitem:SetOnUseFn(onuse)
    inst.components.useableitem:SetOnStopUseFn(onstopusing)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster:SetSpellTestFn(candestroy)
    inst.components.spellcaster:SetSpellFn(destroystructure)

    inst:AddTag("OPStaff")

    return inst
end

return Prefab("common/inventory/opstaff", fn, assets)
