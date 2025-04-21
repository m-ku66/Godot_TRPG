extends Resource
class_name ClassTemplate

@export var id: String
@export var name: String
@export var description: String
@export var max_level: int = 10
@export var max_proficiency: int = 5

@export var active_skills: Array[Resource]  # References to Skill resources
@export var passive_skills: Array[Resource]  # References to Skill resources
@export var reaction_skills: Array[Resource]  # References to Skill resources

@export var stat_modifiers: Dictionary = {
	"hp": 1.0,
	"maxHp": 1.0,
	"patk": 1.0,
	"sp": 1.0,
	"maxSp": 1.0,
	"def": 1.0,
	"matk": 1.0,
	"mp": 1.0,
	"maxMp": 1.0,
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

@export var attribute_modifiers: Dictionary = {
	"hitRate": 0.1,
	"healRate": 0.0,
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

@export var proficiency_bonuses: Array[Dictionary] = [
	{
		"level": 1,
		"stat_boosts": {"sp": 0.5, "maxSp": 0.5, "patk": 0.5},
		"attribute_boosts": {"hitRate": 0.5}
	},
	{
		"level": 2,
		"stat_boosts": {"sp": 0.5, "maxSp": 0.5, "patk": 0.5},
		"attribute_boosts": {"hitRate": 0.5}
	},
	{
		"level": 3,
		"stat_boosts": {"sp": 0.5, "maxSp": 0.5, "def": 0.5},
		"attribute_boosts": {"resolve": 0.5}
	},
	{
		"level": 4,
		"stat_boosts": {"sp": 0.5, "maxSp": 0.5, "def": 0.5},
		"attribute_boosts": {"resolve": 0.5}
	},
	{
		"level": 5,
		"stat_boosts": {"mp": 0.5, "maxMp": 0.5, "matk": 0.5},
		"attribute_boosts": {"evasionRate": 0.5}
	},
	{
		"level": 6,
		"stat_boosts": {"mp": 0.5, "maxMp": 0.5, "matk": 0.5},
		"attribute_boosts": {"evasionRate": 0.5}
	},
	{
		"level": 7,
		"stat_boosts": {"mp": 0.5, "maxMp": 0.5, "res": 0.5},
		"attribute_boosts": {"resolve": 0.5}
	},
	{
		"level": 8,
		"stat_boosts": {"mp": 0.5, "maxMp": 0.5, "res": 0.5},
		"attribute_boosts": {"resolve": 0.5}
	},
	{
		"level": 9,
		"stat_boosts": {"hp": 1.0, "maxHp": 1.0, "skill": 1.0},
		"attribute_boosts": {"resolve": 0.5}
	},
	{
		"level": 10,
		"stat_boosts": {"hp": 1.0, "maxHp": 1.0, "wis": 1.0},
		"attribute_boosts": {"resolve": 0.5}
	},
	# ... additional proficiency levels
]
