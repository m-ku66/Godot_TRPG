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
		
		# NEW: Calculate and display movement range!
		var reachable_cells = get_reachable_cells(selected_unit)
		print("=== MOVEMENT RANGE ===")
		print("Unit: ", selected_unit.unit_id)
		print("Movement: ", selected_unit.unit_instance.stats.mov)
		print("Jump: ", selected_unit.unit_instance.stats.jump)
		print("Reachable cells: ", reachable_cells.size())
		for cell_pos in reachable_cells:
			print("  -> ", cell_pos)

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
	
# Calculate all cells a unit can reach based on movement and jump stats
func get_reachable_cells(unit: Node3D) -> Array[Vector3]:
	if not unit or not unit.unit_instance:
		return []
	
	var start_pos = unit.grid_position
	var movement_range = unit.unit_instance.stats.mov
	var jump_range = unit.unit_instance.stats.jump
	var reachable_cells: Array[Vector3] = []
	
	# BFS flood-fill with movement constraints
	var queue: Array = [start_pos]
	var visited: Dictionary = {}
	var distances: Dictionary = {}
	
	visited[start_pos] = true
	distances[start_pos] = 0
	
	while queue.size() > 0:
		var current_pos = queue.pop_front()
		var current_distance = distances[current_pos]
		
		# Add current position to reachable cells (except starting position)
		if current_pos != start_pos:
			reachable_cells.append(current_pos)
		
		# Stop expanding if we've reached movement limit
		if current_distance >= movement_range:
			continue
		
		# Check all 4 cardinal directions (Manhattan distance)
		var directions = [
			Vector3(1, 0, 0),   # Right
			Vector3(-1, 0, 0),  # Left
			Vector3(0, 0, 1),   # Forward
			Vector3(0, 0, -1)   # Backward
		]
		
		for direction in directions:
			var next_pos = current_pos + direction
			
			# Skip if already visited
			if visited.has(next_pos):
				continue
			
			# Check if cell exists and is traversable
			var cell = game_state.get_cell_at_position(next_pos)
			if not cell or not cell.traversable:
				continue
			
			# Check vertical distance (jump constraint)
			var vertical_distance = abs(next_pos.y - start_pos.y)
			if vertical_distance > jump_range:
				continue
			
			# Check if cell is occupied by another unit
			if is_cell_occupied(next_pos, unit):
				continue
			
			# Mark as visited and add to queue
			visited[next_pos] = true
			distances[next_pos] = current_distance + 1
			queue.append(next_pos)
	
	return reachable_cells

# Helper function to check if a cell is occupied by another unit
func is_cell_occupied(pos: Vector3, excluding_unit: Node3D) -> bool:
	for unit_id in units:
		var unit = units[unit_id]
		if unit != excluding_unit and unit.grid_position == pos:
			return true
	return false
