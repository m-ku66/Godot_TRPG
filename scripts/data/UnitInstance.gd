extends Node3D
class_name UnitInstance

var id: String  # Unique instance ID
var template: UnitTemplate
var owner_id: String  # Player ID

# Current state
var stats: Dictionary
var attributes: Dictionary
var current_class: Resource  # ClassInstance
var equipped_gear: Dictionary = {
	"weapon": null,
	"armor": null,
	"accessory": null
}
var active_skills: Array[Resource]  # Currently equipped skills
var passive_skills: Array[Resource]
var reaction_skill: Resource

# Bond / Progression
var bond_level: int = 1
var unlocked_memories: Array = []

# Battle state
var buffs: Array = []
var debuffs: Array = []
var status_ailments: Array = []
var current_state: String = "idle"  # "idle", "moving", "attacking", etc.

func _init(unit_template: UnitTemplate, instance_id: String):
	id = instance_id
	template = unit_template
	
	# Initialize stats from template
	stats = template.get_stats_at_level(1)
	attributes = template.attributes.duplicate()
	
	# Set up initial class
	if template.starting_class:
		set_class(template.starting_class)

func set_class(class_template):
	current_class = class_template
	
	# Update stats and attributes based on class modifiers
	for stat_name in current_class.stat_modifiers:
		if stat_name in stats:
			stats[stat_name] = int(stats[stat_name] * current_class.stat_modifiers[stat_name])
	
	for attr_name in current_class.attribute_modifiers:
		if attr_name in attributes:
			attributes[attr_name] = attributes[attr_name] * current_class.attribute_modifiers[attr_name]
	
	# Set up available skills
	active_skills = []
	passive_skills = []
	
	for skill in current_class.active_skills:
		active_skills.append(skill)
	
	for skill in current_class.passive_skills:
		passive_skills.append(skill)
	
	if current_class.reaction_skills.size() > 0:
		reaction_skill = current_class.reaction_skills[0]

func level_up():
	stats.lvl += 1
	
	# Apply growth rates
	for stat_name in template.growth_rates:
		if stat_name in stats:
			var growth = template.growth_rates[stat_name]
			stats[stat_name] += int(growth)
	
	# Apply attribute growth
	for attr_name in template.attribute_growth_rates:
		if attr_name in attributes:
			var growth = template.attribute_growth_rates[attr_name]
			attributes[attr_name] += growth

func take_damage(amount: int, damage_type: String):
	# Apply damage reduction based on defenses and attributes
	var final_damage = amount
	
	# Handle physical damage types
	if damage_type in ["slash", "pierce", "blunt", "projectile"]:
		# Apply physical defense
		final_damage -= stats.def
		
		# Apply specific defense type if available
		var defense_attr = damage_type + "Defense"
		if defense_attr in attributes:
			final_damage -= (stats.def * attributes[defense_attr] / 100)
	
	# Handle magical damage types
	elif damage_type in ["fire", "water", "earth", "wind", "lightning"]:
		# Apply magical resistance
		final_damage -= stats.res
		
		# Apply affinity modifiers
		if damage_type == stats.affinity:
			final_damage *= 0.5  # Resistance to own element
	
	# Ensure damage isn't negative
	final_damage = max(0, final_damage)
	
	# Apply damage
	stats.hp -= final_damage
	
	# Check for KO
	if stats.hp <= 0:
		stats.hp = 0
		current_state = "knocked_out"
	
	return final_damage

func use_skill(skill_id: String, targets):
	# Find the skill
	var skill = null
	for s in active_skills:
		if s.id == skill_id:
			skill = s
			break
	
	if not skill:
		return {"success": false, "message": "Skill not found"}
	
	# Check costs
	if stats.mp < skill.mp_cost:
		return {"success": false, "message": "Not enough MP"}
	
	if stats.sp < skill.sp_cost:
		return {"success": false, "message": "Not enough SP"}
	
	if stats.hp <= skill.hp_cost:
		return {"success": false, "message": "Not enough HP"}
	
	# Apply costs
	stats.mp -= skill.mp_cost
	stats.sp -= skill.sp_cost
	stats.hp -= skill.hp_cost
	
	# Execute skill
	var result = skill.apply_effect(self, targets)
	
	return {"success": true, "result": result}
