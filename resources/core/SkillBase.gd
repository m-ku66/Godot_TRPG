extends Resource
class_name SkillBase

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture
@export var animation_id: String

@export var type: String  # "Active", "Passive", "Reactive"
@export var mp_cost: int = 0
@export var sp_cost: int = 0
@export var hp_cost: int = 0
@export var cooldown: int = 0  # In turns

@export var range: int = 1
@export var area_of_effect: int = 1
@export var target_type: String  # "individual", "splash", "individual_ally", etc.

@export var affinity: String = "neutral"

# Implemented in derived classes
func apply_effect(user, targets):
	pass
