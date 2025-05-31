extends Node

# Reference to game systems
@onready var game_state = get_node("/root/GameState")
@onready var data_manager = get_node("/root/DataManager")

# Scene references
const UnitScene = preload("res://scenes/units/Unit.tscn")

# Create a unit and place it on the battlefield
func create_unit(template_id: String, position: Vector3, owner_id: String = "") -> Node3D:
	# Create the unit instance data
	var unit_instance = data_manager.create_unit_instance(template_id)
	
	if not unit_instance:
		push_error("Failed to create unit instance from template: " + template_id)
		return null
	
	# Set owner
	unit_instance.owner_id = owner_id
	
	# Create the visual scene
	var unit_scene = UnitScene.instantiate()
	unit_scene.initialize(unit_instance, position)
	
	# Check if terrain cell is valid
	var cell = game_state.get_cell_at_position(position)
	if not cell:
		push_error("Invalid position for unit: " + str(position))
		return null
		
	if not cell.traversable:
		push_error("Cell not traversable: " + str(position))
		return null
	
	# Mark cell as occupied
	cell.occupied_by = unit_instance.id
	
	# Return the created unit
	return unit_scene

# Remove a unit from the battlefield
func remove_unit(unit_node: Node):
	if unit_node and unit_node.unit_instance:
		# Clear grid occupation
		var cell = game_state.get_cell_at_position(unit_node.grid_position)
		if cell and cell.occupied_by == unit_node.unit_id:
			cell.occupied_by = ""
		
		# Remove from scene
		unit_node.queue_free()
