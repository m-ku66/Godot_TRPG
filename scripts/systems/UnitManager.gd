extends Node

signal unit_selected(unit)
signal unit_deselected(unit)

# References
@onready var game_state = get_node("/root/GameState")

# State
var selected_unit: Node3D = null
var units = {}  # Dictionary of all units on the battlefield

# Initialize
func _ready():
	pass

# Register a unit with the manager
func register_unit(unit: Node3D):
	if unit and unit.unit_id:
		units[unit.unit_id] = unit

# Unregister a unit
func unregister_unit(unit_id: String):
	units.erase(unit_id)
	
	# If this was the selected unit, deselect
	if selected_unit and selected_unit.unit_id == unit_id:
		deselect_unit()

# Select a unit
func select_unit(unit: Node3D):
	# Deselect current unit if any
	if selected_unit:
		selected_unit.set_selected(false)
		emit_signal("unit_deselected", selected_unit)
	
	# Select new unit
	selected_unit = unit
	
	if selected_unit:
		selected_unit.set_selected(true)
		emit_signal("unit_selected", selected_unit)
		
		# Later: Calculate movement range, show abilities

# Deselect current unit
func deselect_unit():
	if selected_unit:
		selected_unit.set_selected(false)
		emit_signal("unit_deselected", selected_unit)
		selected_unit = null

# Get unit at grid position
func get_unit_at_position(grid_pos: Vector3) -> Node3D:
	for unit_id in units:
		var unit = units[unit_id]
		if unit.grid_position == grid_pos:
			return unit
	return null

# Move selected unit to target position
func move_selected_unit(target_pos: Vector3):
	if not selected_unit:
		return false
	
	# Check if movement is valid
	# (Later: check movement range, path validity)
	
	# For now, simple direct path
	var path = [selected_unit.grid_position, target_pos] 
	return selected_unit.start_movement(path)
