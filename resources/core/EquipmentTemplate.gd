extends Resource
class_name EquipmentTemplate

@export var id: String
@export var name: String
@export var description: String
@export var type: String  # "weapon", "armor", "accessory"
@export var subtype: String  # "sword", "bow", "heavy_armor", etc.
@export var rarity: String
@export var model_id: String

@export var stat_bonuses: Dictionary = {}
@export var attribute_bonuses: Dictionary = {}
@export var skill_bonuses: Array[Resource] = []  # Skills granted by equipment
