extends Node

var unit_templates: Dictionary = {}
var class_templates: Dictionary = {}
var skill_templates: Dictionary = {}
var equipment_templates: Dictionary = {}

func _ready():
	load_unit_templates()
	load_class_templates()
	load_skill_templates()
	load_equipment_templates()

func load_unit_templates():
	var dir = DirAccess.open("res://resources/unit_templates")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var template = load("res://resources/unit_templates/" + file_name)
				if template is UnitTemplate:
					unit_templates[template.id] = template
			file_name = dir.get_next()

func load_class_templates():
	var dir = DirAccess.open("res://resources/class_templates")
	if dir:
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
	if dir:
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
	if dir:
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
