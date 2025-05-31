extends Node

var unit_templates: Dictionary = {}
var class_templates: Dictionary = {}
var skill_templates: Dictionary = {}
var equipment_templates: Dictionary = {}

func _ready():
	load_units_from_json()
	load_class_templates()
	load_skill_templates() 
	load_equipment_templates()

func load_units_from_json():
	var file_path = "res://resources/data/units.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if not file:
		push_error("Could not open units.json file at: " + file_path)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Error parsing units.json: " + json.get_error_message())
		return
	
	var units_data = json.get_data()
	
	for unit_id in units_data:
		var unit_data = units_data[unit_id]
		var template = create_unit_template_from_json(unit_data)
		unit_templates[unit_id] = template
		print("Loaded unit template: ", unit_id)

func create_unit_template_from_json(data: Dictionary) -> UnitTemplate:
	var template = UnitTemplate.new()
	
	# Basic properties
	template.id = data.get("id", "")
	template.name = data.get("name", "")
	template.description = data.get("description", "")
	template.rarity = data.get("rarity", "common")
	template.model_id = data.get("model_id", "")
	template.race = data.get("race", "")
	template.origin = data.get("origin", "")
	template.personality = data.get("personality", [])
	template.weight = data.get("weight", 70.0)
	template.height = data.get("height", 170.0)
	template.weapon_types = data.get("weapon_types", [])
	template.can_dual_wield = data.get("can_dual_wield", false)
	template.max_bond_level = data.get("max_bond_level", 10)
	
	# Base stats
	if data.has("base_stats"):
		template.base_stats = data["base_stats"].duplicate()
	
	# Growth rates
	if data.has("growth_rates"):
		template.growth_rates = data["growth_rates"].duplicate()
	
	# Attributes
	if data.has("attributes"):
		# Merge with default attributes
		for attr_key in data["attributes"]:
			template.attributes[attr_key] = data["attributes"][attr_key]
	
	return template

# Keep your existing loading functions for other templates
func load_class_templates():
	var dir = DirAccess.open("res://resources/class_templates")
	if not dir:
		print("class_templates directory not found")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var template = load("res://resources/class_templates/" + file_name)
			if template is ClassTemplate:
				class_templates[template.id] = template
		file_name = dir.get_next()

func load_skill_templates():
	var dir = DirAccess.open("res://resources/skill_templates")
	if not dir:
		print("skill_templates directory not found")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var template = load("res://resources/skill_templates/" + file_name)
			if template is SkillBase:
				skill_templates[template.id] = template
		file_name = dir.get_next()

func load_equipment_templates():
	var dir = DirAccess.open("res://resources/equipment_templates")
	if not dir:
		print("equipment_templates directory not found")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var template = load("res://resources/equipment_templates/" + file_name)
			if template is EquipmentTemplate:
				equipment_templates[template.id] = template
		file_name = dir.get_next()

func get_unit_template(id: String) -> UnitTemplate:
	return unit_templates.get(id)

func get_class_template(id: String) -> ClassTemplate:
	return class_templates.get(id)

func get_skill_template(id: String) -> SkillBase:
	return skill_templates.get(id)

func get_equipment_template(id: String) -> EquipmentTemplate:
	return equipment_templates.get(id)

func create_unit_instance(template_id: String, instance_id: String = "") -> UnitInstance:
	var template = get_unit_template(template_id)
	if not template:
		push_error("Template not found: " + template_id)
		return null
	
	if instance_id.is_empty():
		instance_id = template_id + "_" + str(randi())
	
	var instance = UnitInstance.new(template, instance_id)
	return instance
