local assets =
{
    Asset("ANIM", "anim/hat_ruins.zip"),
    Asset("IMAGE", "images/inventoryimages/vanilla/ophat.tex"),
}

local function OnBlocked(owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onperish(inst)
end

local function spider_disable(inst)
    if inst.updatetask then
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then

        if not owner:HasTag("spiderwhisperer") then --Webber has to stay a monster.

        for k, v in pairs(owner.components.leader.followers) do
            if k:HasTag("spider") and k.components.combat then
                k.components.combat:SuggestTarget(owner)
            end
        end
        owner.components.leader:RemoveFollowersByTag("spider")
        else
            owner.components.leader:RemoveFollowersByTag("spider", function(follower)
                if follower and follower.components.follower then
                    if follower.components.follower:GetLoyaltyPercent() > 0 then
                        return false
                    else
                        return true
                    end
                end
            end)
        end
    end
end

local function spider_update(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, TUNING.SPIDERHAT_RANGE, { "spider" })
        for k, v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                owner.components.leader:AddFollower(v)
            end
        end
    end
end


local function eyebrella_updatesound(inst)
    local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
            inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound")
        else
            inst.SoundEmitter:KillSound("umbrellarainsound")
        end
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
    local fx = SpawnPrefab("forcefieldfx")
    fx.entity:SetParent(owner.entity)
    fx.Transform:SetPosition(0, 0.2, 0)
    local fx_hitanim = function()
        fx.AnimState:PlayAnimation("hit")
        fx.AnimState:PushAnimation("idle_loop")
    end
    fx:ListenForEvent("blocked", fx_hitanim, owner)

    inst.active = true

    owner:DoTaskInTime(--[[Duration]] TUNING.ARMOR_RUINSHAT_DURATION, function()
        fx:RemoveEventCallback("blocked", fx_hitanim, owner)
        fx.kill_fx(fx)
        if inst:IsValid() then
            inst:RemoveTag("forcefield")
            inst.components.armor.ontakedamage = nil
            inst.components.armor:SetAbsorption(TUNING.ARMOR_SANITY_ABSORPTION)
            owner:DoTaskInTime(--[[Cooldown]] TUNING.ARMOR_RUINSHAT_COOLDOWN, function() inst.active = false end)
        end
    end)
end

local function tryproc(inst, owner)
    if not inst.active and math.random() < --[[ Chance to proc ]] TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
        ruinshat_proc(inst, owner)
    end
end

local function onequip(inst, owner, fname_override)
    local build = fname_override or "hat_ruins"
    owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAIR")
    end

    inst.procfn = function() tryproc(inst, owner) end
    owner:ListenForEvent("attacked", inst.procfn)

    owner:AddTag("beefalo")


    local owner = inst.components.inventoryitem.owner
    if owner:HasTag("wagstaff_inventor") then
        inst:AddTag("nearsighted_glasses")
    end

    if owner:HasTag("wagstaff_inventor") then
        owner:AddTag("revealtraps")
    end

    local ground = GetWorld()
    if ground and ground.components.birdspawner then
        ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY_FEATHERHAT)
        ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX_FEATHERHAT)
    end

    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)

    eyebrella_updatesound(inst)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")
    end

    owner:RemoveEventCallback("attacked", inst.procfn)

    owner:RemoveTag("beefalo")

    if owner:HasTag("wagstaff_inventor") then
        owner:RemoveTag("revealtraps")
    end

    local ground = GetWorld()
    if ground and ground.components.birdspawner then
        ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY)
        ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX)
    end

    spider_disable(inst)

    eyebrella_updatesound(inst)
end

local function ondropped(inst)
    spider_disable(inst)
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ruinshat")
    inst.AnimState:SetBuild("hat_ruins")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("metal")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "ophat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanilla/ophat.xml"

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

    inst.entity:AddSoundEmitter()

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
    inst.components.equippable.insulated = true

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.DAPPERNESS_LARGE)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("armor")
    inst.components.armor.dontremove = true
    inst.components.armor:InitCondition(TUNING.ARMOR_OPVEST, TUNING.ARMOR_SANITY_ABSORPTION)
    inst.components.armor:SetTags({"bee"})

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:ListenForEvent("rainstop", function() eyebrella_updatesound(inst) end, GetWorld())
    inst:ListenForEvent("rainstart", function() eyebrella_updatesound(inst) end, GetWorld())
    inst:ListenForEvent("daycomplete", ondaycomplete)

    ondaycomplete(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
--    inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled.accepting = true

    inst:AddTag("OPHat")

    return inst
end

return Prefab("common/inventory/ophat", fn, assets)
