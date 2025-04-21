extends SkillBase
class_name ActiveSkill

@export var return_type: String  # "Damage", "Healing", "Null"
@export var damage_type: String  # "slash", "pierce", "fire", etc.
@export var base_power: float = 0.0  # Percentage of stat used

@export var stat_mods: Dictionary = {}  # {"luck": 10.0} means 10% of luck added to damage
@export var inflicts: Array[Dictionary] = []  # [{"status": "burn", "duration": 2}]

func apply_effect(user, targets):
	# Implementation of active skill logic
	var effect_results = []
	
	if return_type == "Damage":
		for target in targets:
			var damage = calculate_damage(user, target)
			# Apply damage to target
			effect_results.append({
				"target": target,
				"damage": damage
			})
			
			# Apply status effects
			for status in inflicts:
				# Logic to apply status effect
				pass
	
	elif return_type == "Healing":
		# Healing logic
		pass
	
	return effect_results

func calculate_damage(user, target):
	# Damage calculation logic based on user stats, target stats, and skill properties
	var base_stat = 0
	
	if damage_type in ["slash", "pierce", "blunt", "projectile"]:
		base_stat = user.stats.patk
	else:
		base_stat = user.stats.matk
	
	var damage = (base_stat * base_power / 100)
	
	# Apply stat modifiers
	for stat_name in stat_mods:
		var stat_value = user.stats.get(stat_name, 0)
		damage += stat_value * stat_mods[stat_name] / 100
	
	# Apply defenses
	# This is simplified - actual implementation would be more complex
	if damage_type in ["slash", "pierce", "blunt", "projectile"]:
		damage -= target.stats.def
	else:
		damage -= target.stats.res
	
	return max(0, damage)
