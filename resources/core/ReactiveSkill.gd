extends SkillBase
class_name ReactiveSkill

@export var trigger_condition: String  # "on_hit", "before_attack", "after_attack", etc.
@export var effect_type: String  # "counter", "buff", "heal", etc.
@export var effect_power: float = 0.0
@export var trigger_chance: float = 100.0  # Percentage chance to activate

func check_trigger(event_type, user, source):
	# Check if this reaction should trigger based on the event
	if event_type != trigger_condition:
		return false
		
	# Check trigger chance
	if randf() * 100 > trigger_chance:
		return false
		
	return true

func apply_effect(user, targets):
	# Implementation based on effect_type
	match effect_type:
		"counter":
			# Counter attack logic
			pass
		"buff":
			# Apply buff to user
			pass
		"heal":
			# Heal user
			pass
