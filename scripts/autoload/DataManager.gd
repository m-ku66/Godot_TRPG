extends Node

# ============================================================================
# DataManager - Professional Live Service Data Management System
# ============================================================================
# Handles loading, validation, and caching of game data from external sources
# Designed for live service games with external database integration
# ============================================================================

# Data Storage
var unit_templates: Dictionary = {}
var class_templates: Dictionary = {}
var skill_templates: Dictionary = {}
var equipment_templates: Dictionary = {}

# Loading State
var is_data_loaded: bool = false
var loading_errors: Array[String] = []

# Signals for UI/System Integration
signal data_loading_started()
signal data_loading_completed(success: bool, errors: Array[String])
signal unit_templates_loaded(count: int)

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready():
	_initialize_data_loading()

func _initialize_data_loading():
	data_loading_started.emit()
	loading_errors.clear()
	
	print("[DataManager] Starting data initialization...")
	
	# Load in dependency order - classes first, then units that reference them
	var success = true
	success = success and _load_class_templates()      # Load classes first
	success = success and _load_skill_templates()      # Then skills
	success = success and _load_equipment_templates()  # Then equipment
	success = success and _load_units_from_json()      # Finally units (which reference classes)
	
	is_data_loaded = success
	
	if success:
		print("[DataManager] Data loading completed successfully")
		print("[DataManager] Loaded %d unit templates" % unit_templates.size())
		print("[DataManager] Loaded %d class templates" % class_templates.size())
	else:
		push_error("[DataManager] Data loading completed with errors: " + str(loading_errors))
	
	data_loading_completed.emit(success, loading_errors)

# ============================================================================
# JSON DATA LOADING
# ============================================================================

func _load_units_from_json() -> bool:
	const FILE_PATH = "res://resources/data/units.json"
	
	print("[DataManager] Loading unit templates from: " + FILE_PATH)
	
	# Load and parse JSON
	var json_data = _load_json_file(FILE_PATH)
	if json_data.is_empty():
		_add_loading_error("Failed to load units.json")
		return false
	
	# Process each unit template
	var loaded_count = 0
	for unit_id in json_data:
		var unit_data = json_data[unit_id]
		
		# Validate required fields
		if not _validate_unit_data(unit_id, unit_data):
			continue
		
		# Create template
		var template = _create_unit_template_from_data(unit_data)
		if template:
			unit_templates[unit_id] = template
			loaded_count += 1
		else:
			_add_loading_error("Failed to create template for unit: " + unit_id)
	
	print("[DataManager] Successfully loaded %d/%d unit templates" % [loaded_count, json_data.size()])
	unit_templates_loaded.emit(loaded_count)
	
	return loaded_count > 0

# ============================================================================
# RESOURCE TEMPLATE LOADING
# ============================================================================

func _load_class_templates() -> bool:
	const FILE_PATH = "res://resources/data/classes.json"
	
	print("[DataManager] Loading class templates from: " + FILE_PATH)
	
	# Load and parse JSON
	var json_data = _load_json_file(FILE_PATH)
	if json_data.is_empty():
		print("[DataManager] No classes.json found, continuing without class templates")
		return true  # Not critical for basic functionality
	
	# Process each class template
	var loaded_count = 0
	for class_id in json_data:
		var class_data = json_data[class_id]
		
		# Validate required fields
		if not _validate_class_data(class_id, class_data):
			continue
		
		# Create template
		var template = _create_class_template_from_data(class_data)
		if template:
			class_templates[class_id] = template
			loaded_count += 1
		else:
			_add_loading_error("Failed to create class template: " + class_id)
	
	print("[DataManager] Successfully loaded %d/%d class templates" % [loaded_count, json_data.size()])
	return loaded_count >= 0  # Allow 0 classes for minimal functionality

func _load_skill_templates() -> bool:
	return _load_templates_from_directory(
		"res://resources/skill_templates", 
		"SkillBase",
		skill_templates,
		"skill templates"
	)

func _load_equipment_templates() -> bool:
	return _load_templates_from_directory(
		"res://resources/equipment_templates",
		"EquipmentTemplate", 
		equipment_templates,
		"equipment templates"
	)

func _load_templates_from_directory(directory_path: String, type_name: String, storage_dict: Dictionary, display_name: String) -> bool:
	print("[DataManager] Loading %s from: %s" % [display_name, directory_path])
	
	var dir = DirAccess.open(directory_path)
	if not dir:
		print("[DataManager] Directory not found: " + directory_path + " (creating...)")
		DirAccess.make_dir_recursive_absolute(directory_path)
		return true  # Not an error for missing optional directories
	
	var loaded_count = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var template = load(directory_path + "/" + file_name)
			if template and "id" in template:
				storage_dict[template.id] = template
				loaded_count += 1
			else:
				_add_loading_error("Invalid template file (missing id): %s" % file_name)
		
		file_name = dir.get_next()
	
	print("[DataManager] Loaded %d %s" % [loaded_count, display_name])
	return true

# ============================================================================
# DATA VALIDATION
# ============================================================================

func _validate_unit_data(unit_id: String, data: Dictionary) -> bool:
	var required_fields = ["id", "name", "base_stats"]
	
	for field in required_fields:
		if not data.has(field):
			_add_loading_error("Unit '%s' missing required field: %s" % [unit_id, field])
			return false
	
	# Validate base_stats structure
	if not data["base_stats"] is Dictionary:
		_add_loading_error("Unit '%s' has invalid base_stats format" % unit_id)
		return false
	
	var required_stats = ["hp", "maxHp", "patk", "matk", "def", "res", "agi", "mov"]
	for stat in required_stats:
		if not data["base_stats"].has(stat):
			_add_loading_error("Unit '%s' missing required stat: %s" % [unit_id, stat])
			return false
	
	return true

func _validate_class_data(class_id: String, data: Dictionary) -> bool:
	var required_fields = ["id", "name", "stat_modifiers"]
	
	for field in required_fields:
		if not data.has(field):
			_add_loading_error("Class '%s' missing required field: %s" % [class_id, field])
			return false
	
	return true

# ============================================================================
# TEMPLATE CREATION
# ============================================================================

func _create_unit_template_from_data(data: Dictionary) -> UnitTemplate:
	var template = UnitTemplate.new()
	
	# Basic Properties
	template.id = _get_string(data, "id", "")
	template.name = _get_string(data, "name", "")
	template.description = _get_string(data, "description", "")
	template.rarity = _get_string(data, "rarity", "common")
	template.model_id = _get_string(data, "model_id", "")
	template.race = _get_string(data, "race", "human")
	template.origin = _get_string(data, "origin", "")
	template.weight = _get_float(data, "weight", 70.0)
	template.height = _get_float(data, "height", 170.0)
	template.can_dual_wield = _get_bool(data, "can_dual_wield", false)
	template.max_bond_level = _get_int(data, "max_bond_level", 10)
	
	# Array Properties (with type conversion)
	template.personality = _convert_to_string_array(data.get("personality", []))
	template.weapon_types = _convert_to_string_array(data.get("weapon_types", []))
	
	# Complex Data Structures
	if data.has("base_stats"):
		template.base_stats = _sanitize_dictionary(data["base_stats"])
	
	if data.has("growth_rates"):
		template.growth_rates = _sanitize_dictionary(data["growth_rates"])
	
	if data.has("attributes"):
		_merge_attributes(template.attributes, data["attributes"])
	
	if data.has("attribute_growth_rates"):
		_merge_attributes(template.attribute_growth_rates, data["attribute_growth_rates"])
	
	return template


func _create_class_template_from_data(data: Dictionary) -> ClassTemplate:
	var template = ClassTemplate.new()
	
	# Basic Properties
	template.id = _get_string(data, "id", "")
	template.name = _get_string(data, "name", "")
	template.description = _get_string(data, "description", "")
	template.max_level = _get_int(data, "max_level", 10)
	template.max_proficiency = _get_int(data, "max_proficiency", 5)
	
	# Stat modifiers
	if data.has("stat_modifiers"):
		template.stat_modifiers = _sanitize_dictionary(data["stat_modifiers"])
	
	# Attribute modifiers
	if data.has("attribute_modifiers"):
		_merge_attributes(template.attribute_modifiers, data["attribute_modifiers"])
	
	# Skills - Create properly typed empty arrays for now
	# Since we don't have skills implemented yet, we'll just initialize as empty
	template.active_skills = Array([], TYPE_OBJECT, "Resource", null)
	template.passive_skills = Array([], TYPE_OBJECT, "Resource", null)
	template.reaction_skills = Array([], TYPE_OBJECT, "Resource", null)
	
	# Future: When we implement skills, we can load them like this:
	# template.active_skills = _convert_skill_ids_to_resources(data.get("active_skills", []))
	
	return template
# ============================================================================
# TYPE CONVERSION UTILITIES
# ============================================================================

func _convert_to_string_array(data: Array) -> Array[String]:
	var result: Array[String] = []
	for item in data:
		result.append(str(item))
	return result

func _convert_to_resource_array(data: Array, resource_path: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for item in data:
		var resource = load(resource_path + str(item) + ".tres")
		if resource:
			result.append(resource)
		else:
			_add_loading_error("Failed to load resource: " + str(item))
	return result

func _sanitize_dictionary(dict: Dictionary) -> Dictionary:
	var result = {}
	for key in dict:
		var value = dict[key]
		# Ensure numeric values are properly typed
		if value is String and value.is_valid_float():
			result[key] = float(value)
		elif value is String and value.is_valid_int():
			result[key] = int(value)
		else:
			result[key] = value
	return result

func _merge_attributes(target: Dictionary, source: Dictionary):
	for attr_key in source:
		target[attr_key] = source[attr_key]

# ============================================================================
# SAFE DATA ACCESS
# ============================================================================

func _get_string(data: Dictionary, key: String, default: String) -> String:
	return str(data.get(key, default))

func _get_int(data: Dictionary, key: String, default: int) -> int:
	var value = data.get(key, default)
	if value is String:
		return int(value) if value.is_valid_int() else default
	return int(value)

func _get_float(data: Dictionary, key: String, default: float) -> float:
	var value = data.get(key, default)
	if value is String:
		return float(value) if value.is_valid_float() else default
	return float(value)

func _get_bool(data: Dictionary, key: String, default: bool) -> bool:
	var value = data.get(key, default)
	if value is String:
		return value.to_lower() in ["true", "1", "yes"]
	return bool(value)

# ============================================================================
# FILE I/O UTILITIES
# ============================================================================

func _load_json_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		_add_loading_error("Could not open file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	if json_string.is_empty():
		_add_loading_error("File is empty: " + file_path)
		return {}
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		_add_loading_error("JSON parse error in %s: %s" % [file_path, json.get_error_message()])
		return {}
	
	var data = json.get_data()
	if not data is Dictionary:
		_add_loading_error("JSON root is not a dictionary in: " + file_path)
		return {}
	
	return data

# ============================================================================
# ERROR HANDLING
# ============================================================================

func _add_loading_error(error_message: String):
	loading_errors.append(error_message)
	push_error("[DataManager] " + error_message)

# ============================================================================
# PUBLIC API
# ============================================================================

func get_unit_template(id: String) -> UnitTemplate:
	if not is_data_loaded:
		push_warning("[DataManager] Accessing data before loading is complete")
	
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
		push_error("[DataManager] Template not found: " + template_id)
		return null
	
	if instance_id.is_empty():
		instance_id = template_id + "_" + str(randi())
	
	var instance = UnitInstance.new(template, instance_id)
	return instance

func get_available_unit_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in unit_templates.keys():
		ids.append(id)
	return ids

func is_ready() -> bool:
	return is_data_loaded

func get_loading_errors() -> Array[String]:
	return loading_errors.duplicate()

# ============================================================================
# LIVE SERVICE EXTENSIONS (Future Implementation)
# ============================================================================

# func reload_data_from_api():
# 	# Future: Reload data from external API
# 	pass

# func validate_data_integrity() -> bool:
# 	# Future: Validate all loaded data for consistency
# 	pass

# func get_data_version() -> String:
# 	# Future: Return current data version for cache management
# 	pass
