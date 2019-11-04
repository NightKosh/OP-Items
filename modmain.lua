

local images_path = "images/inventoryimages/"
local OPCane_atlas = images_path .. "vanilla/opcane.xml"
local OPStaff_atlas = images_path .. "vanilla/opstaff.xml"
local OPVest_atlas = images_path .. "vanilla/opvest.xml"
local OPHat_atlas = images_path .. "vanilla/ophat.xml"
local OPAmulet_atlas = images_path .. "vanilla/opamulet.xml"
local OPFishingrod_atlas = images_path .. "vanilla/opfishingrod.xml"
local OPBugnet_atlas = images_path .. "vanilla/opbugnet.xml"


Assets = {
    Asset("ATLAS", OPCane_atlas),
    Asset("ATLAS", OPStaff_atlas),
    Asset("ATLAS", OPVest_atlas),
    Asset("ATLAS", OPHat_atlas),
    Asset("ATLAS", OPAmulet_atlas),
    Asset("ATLAS", OPFishingrod_atlas),
    Asset("ATLAS", OPBugnet_atlas),
}

if GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
    PrefabFiles = {
        "DLC0001/OPHat",
        "DLC0001/OPVest",
        "DLC0001/OPAmulet",
        "DLC0002/OPCane",
        "vanilla/OPStaff",
        "vanilla/OPFishingrod",
        "vanilla/OPBugnet"
    }
elseif GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
    PrefabFiles = {
        "DLC0002/OPCane",
        "vanilla/OPFishingrod",
        "vanilla/OPBugnet"
    }
elseif GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
    PrefabFiles = {
        "DLC0001/OPHat",
        "DLC0001/OPVest",
        "DLC0001/OPAmulet",
        "vanilla/OPCane",
        "vanilla/OPStaff",
        "vanilla/OPFishingrod",
        "vanilla/OPBugnet"
    }
else
    PrefabFiles = {
        "vanilla/OPCane",
        "vanilla/OPFishingrod",
        "vanilla/OPBugnet"
    }
end


TUNING.OPCANE_SPEED_MULT = TUNING.CANE_SPEED_MULT * 1.2
TUNING.OPCANE_DAMAGE = TUNING.NIGHTSWORD_DAMAGE * 1.5
TUNING.ARMOR_OPVEST = 2000000000

function Opcane_Quicken(inst)
    if inst.components.locomotor then

        inst.components.locomotor.walkspeed = 10
        inst.components.locomotor.runspeed = 15
    end
end

AddPrefabPostInit("chester", Opcane_Quicken)

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH


GLOBAL.STRINGS.NAMES.OPCANE = "OP Cane"
GLOBAL.STRINGS.NAMES.OPSTAFF = "OP Staff"
GLOBAL.STRINGS.NAMES.OPVEST = "OP Vest"
GLOBAL.STRINGS.NAMES.OPHAT = "OP Hat"
GLOBAL.STRINGS.NAMES.OPAMULET = "OP Amulet"
GLOBAL.STRINGS.NAMES.OPFISHINGROD = "OP Fishing rod"
GLOBAL.STRINGS.NAMES.OPBUGNET = "OP Bug net"
if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
    AddPrefabPostInit("packim", Opcane_Quicken)

    Recipe("cane", { Ingredient("obsidian", 3), Ingredient("goldnugget", 2), Ingredient("twigs", 4), Ingredient("ox_horn", 1) },
        RECIPETABS.DRESS, TECH.OBSIDIAN_TWO)
end

--if GLOBAL.IsDLCEnabled(GLOBAL.PORKLAND_DLC) then
--
--elseif GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
--    AddPrefabPostInit("packim", Opcane_Quicken)
--
--    Recipe("cane", { Ingredient("obsidian", 3), Ingredient("goldnugget", 2), Ingredient("twigs", 4), Ingredient("ox_horn", 1) },
--        RECIPETABS.DRESS, TECH.OBSIDIAN_TWO)
--
--elseif GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
    Recipe("OPVest", { Ingredient("beargervest", 1), Ingredient("raincoat", 1), Ingredient("hawaiianshirt", 1),
        Ingredient("armorruins", 1), Ingredient("armordragonfly", 1),
        Ingredient("nightmarefuel", 20), Ingredient("goldnugget", 20) },
        RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPVest_atlas

    Recipe("OPHat", { Ingredient("eyebrellahat", 1), Ingredient("icehat", 1),
        Ingredient("beefalohat", 1), Ingredient("walrushat", 1), Ingredient("featherhat", 1),
        Ingredient("spiderhat", 1), Ingredient("ruinshat", 1),
        Ingredient("nightmarefuel", 20), Ingredient("goldnugget", 20) },
        RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPHat_atlas

    Recipe("OPAmulet", { Ingredient("amulet", 1), Ingredient("blueamulet", 1), Ingredient("purpleamulet", 1),
        Ingredient("yellowamulet", 1), Ingredient("greenamulet", 1), Ingredient("orangeamulet", 1),
        Ingredient("nightmarefuel", 20), Ingredient("goldnugget", 20) },
        RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPAmulet_atlas
--end

Recipe("OPCane", { Ingredient("cane", 1), Ingredient("multitool_axe_pickaxe", 1), Ingredient("goldenshovel", 1),
    Ingredient("pitchfork", 1), Ingredient("razor", 1), Ingredient("ruins_bat", 1), Ingredient("batbat", 1),
    Ingredient("nightmarefuel", 20), Ingredient("goldnugget", 20), Ingredient("thulecite", 20) },
    RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPCane_atlas

Recipe("OPStaff", { Ingredient("orangestaff", 1), Ingredient("greenstaff", 1), Ingredient("yellowstaff", 1),
    Ingredient("firestaff", 1), Ingredient("icestaff", 1),
    Ingredient("nightmarefuel", 20), Ingredient("goldnugget", 20), Ingredient("thulecite", 20) },
    RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPStaff_atlas

Recipe("OPFishingrod", { Ingredient("fishingrod", 1), Ingredient("silk", 10),
    Ingredient("nightmarefuel", 10), Ingredient("goldnugget", 10), Ingredient("thulecite", 1) },
    RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPFishingrod_atlas

Recipe("OPBugnet", { Ingredient("bugnet", 1), Ingredient("silk", 10),
    Ingredient("nightmarefuel", 10), Ingredient("goldnugget", 10), Ingredient("thulecite", 1) },
    RECIPETABS.MAGIC, TECH.MAGIC_TWO).atlas = OPBugnet_atlas
