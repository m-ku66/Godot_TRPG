extends SkillBase
class_name PassiveSkill

@export var stat_bonuses: Dictionary = {}  # {"patk": 10} means +10 patk
@export var attribute_bonuses: Dictionary = {}  # {"hitRate": 5} means +5% hit rate
@export var conditional_trigger: String = ""  # E.g., "health_below_50", "after_kill"

func apply_effect(user, _targets):
	# Apply passive bonuses to user
	for stat_name in stat_bonuses:
		if stat_name in user.stats:
			user.stats[stat_name] += stat_bonuses[stat_name]
	
	for attr_name in attribute_bonuses:
		if attr_name in user.attributes:
			user.attributes[attr_name] += attribute_bonuses[attr_name]
