extends Resource
class_name UnitTemplate

# Meta
@export var id: String
@export var rarity: String  # Common, Uncommon, Rare, Epic, Legendary
@export var model_id: String

# Profile
@export var name: String
@export var description: String
@export var origin: String
@export var race: String
@export var personality: Array[String]
@export var weight: float
@export var height: float
@export var weapon_types: Array[String]
@export var can_dual_wield: bool = false

# Bond Information
@export var max_bond_level: int = 10
@export var memories: Array[Resource]  # Reference to Memory resources
@export var special_skill: Resource  # Reference to Skill resource

# Base Stats
@export var base_stats: Dictionary = {
	"lvl": 1,
	"exp": 0,
	"affinity": "neutral",
	"hp": 55,
	"maxHp": 55,
	"patk": 10,
	"sp": 50,
	"maxSp": 50,
	"def": 10,
	"matk": 10,
	"mp": 50,
	"maxMp": 50,
	"res": 10,
	"range": 1,
	"skill": 5,
	"wis": 5,
	"luck": 5,
	"agi": 5,
	"mov": 3,
	"jump": 1,
	"spRegenRate": 10,
	"mpRegenRate": 10,
	"hpRegenRate": 0
}

# Growth Rates
@export var growth_rates: Dictionary = {
	"hp": 2.0,
	"maxHp": 2.0,
	"patk": 1.0,
	"sp": 2.0,
	"maxSp": 2.0,
	"def": 1.0,
	"matk": 1.0,
	"mp": 2.0,
	"maxMp": 2.0,
	"res": 1.0,
	"range": 0.0,
	"skill": 1.0,
	"wis": 1.0,
	"luck": 1.0,
	"agi": 1.0,
	"mov": 0.0,
	"jump": 0.0,
	"spRegenRate": 1.0,
	"mpRegenRate": 1.0,
	"hpRegenRate": 0.0
	}

# Base Attributes
@export var attributes: Dictionary = {
	"hitRate": 95,
	"healRate": 100,
	"slashAttack": 0,
	"pierceAttack": 0,
	"bluntAttack": 2,
	"projectileAttack": 0,
	"slashDefense": 0,
	"pierceDefense": 0,
	"bluntDefense": 0,
	"projectileDefense": 0,
	"evasionRate": 0,
	"slashEvasionRate": 0,
	"pierceEvasionRate": 0,
	"bluntEvasionRate": 0,
	"projectileEvasionRate": 0,
	"splashAttackPower": 0,
	"splashAttackRes": 0,
	"individualAttackPower": 0,
	"individualAttackRes": 0,
	"resolve": 0,
	"affiliationLight": 0,
	"affiliationDark": 0
}

# Growth Rates for Attributes
@export var attribute_growth_rates: Dictionary = {
	"hitRate": 0.5,
	"healRate": 0.5,
	"slashAttack": 0.0,
	"pierceAttack": 0.0,
	"bluntAttack": 0.1,
	"projectileAttack": 0.0,
	"slashDefense": 0.0,
	"pierceDefense": 0.0,
	"bluntDefense": 0.0,
	"projectileDefense": 0.0,
	"evasionRate": 0.0,
	"slashEvasionRate": 0.0,
	"pierceEvasionRate": 0.0,
	"bluntEvasionRate": 0.0,
	"projectileEvasionRate": 0.0,
	"splashAttackPower": 0.0,
	"splashAttackRes": 0.0,
	"individualAttackPower": 0.0,
	"individualAttackRes": 0.0,
	"resolve": 0.0,
	"affiliationLight": 0.0,
	"affiliationDark": 0.0
	}

# Classes
@export var starting_class: Resource  # Reference to ClassTemplate
@export var available_classes: Array[Resource]  # References to ClassTemplate resources

# Calculate stats at a specific level
func get_stats_at_level(level: int) -> Dictionary:
	var stats = base_stats.duplicate(true)
	
	# Apply level-based growth
	for stat_name in growth_rates.keys():
		if stat_name in stats:
			var growth = growth_rates[stat_name] * (level - 1)
			stats[stat_name] += int(growth)
	
	return stats
