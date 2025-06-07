extends Node3D

# References to nodes in the scene
@onready var visuals = $Visuals
@onready var mesh_instance = $Visuals/MeshInstance3D
@onready var selection_indicator = $SelectionIndicator
@onready var animation_player = $AnimationPlayer

# Unit data references
var unit_instance: UnitInstance
var unit_id: String
var grid_position: Vector3i
var is_selected: bool = false

# Movement variables
var move_path: Array = []
var is_moving: bool = false
var move_speed: float = 3.0
var current_path_index: int = 0

# Reference to game systems
@onready var game_state = get_node("/root/GameState")

# Flag to track if we need to update visuals after _ready
var pending_visual_update: bool = false

func _ready():
	# Initialize
	selection_indicator.visible = false
	
	# Connect to signals if needed
	if game_state:
		pass
	
	# Update visuals if we have pending data
	if pending_visual_update:
		update_visuals()
		pending_visual_update = false

# Initialize with unit data
func initialize(instance: UnitInstance, start_position: Vector3):
	unit_instance = instance
	unit_id = instance.id
	
	# Set initial grid position
	grid_position = Vector3i(start_position)
	
	# Check if nodes are ready, if not, flag for later update
	if mesh_instance:
		update_visuals()
	else:
		pending_visual_update = true
	
	# Position in the world
	position = Vector3(start_position.x, start_position.y + 0.5, start_position.z)

# Update the unit's visual representation based on its type/class
func update_visuals():
	if not unit_instance or not mesh_instance:
		return
		
	var material = StandardMaterial3D.new()
	
	# Use class-based coloring instead of ID parsing
	if unit_instance.current_class:
		match unit_instance.current_class.id:
			"warrior_class":
				material.albedo_color = Color(0.8, 0.2, 0.2) # Red
			"mage_class":
				material.albedo_color = Color(0.2, 0.2, 0.8) # Blue
			"archer_class":
				material.albedo_color = Color(0.2, 0.8, 0.2) # Green
			"healer_class":
				material.albedo_color = Color(0.8, 0.8, 0.2) # Yellow
			"rogue_class":
				material.albedo_color = Color(0.8, 0.2, 0.8) # Purple
			_:
				material.albedo_color = Color(0.7, 0.7, 0.7) # Gray default
	else:
		# Fallback to gray if no class assigned
		material.albedo_color = Color(0.5, 0.5, 0.5) # Dark gray for unclassed
	
	mesh_instance.material_override = material
	
	# Later: Replace with proper models
	# var model_id = unit_instance.template.model_id
	# load_model(model_id)

# Select or deselect this unit
func set_selected(selected: bool):
	is_selected = selected
	selection_indicator.visible = selected
	
	# Later: Add selection effects or animations
	if selected:
		# Show movement range, abilities, etc.
		pass

# Start moving along a path
func start_movement(path: Array):
	if path.size() < 2:
		return false
	
	move_path = path
	current_path_index = 1  # Start from index 1 (next cell after current)
	is_moving = true
	
	# Update grid position to the final destination
	var final_pos = path[path.size() - 1]
	grid_position = Vector3i(final_pos.x, final_pos.y, final_pos.z)
	
	return true

# Process movement along path
func _process(delta):
	if is_moving and move_path.size() > 1:
		if current_path_index < move_path.size():
			var target_pos = Vector3(
				move_path[current_path_index].x,
				move_path[current_path_index].y + 0.5, # Offset for display
				move_path[current_path_index].z
			)
			
			# Move towards the next point
			var step = position.move_toward(target_pos, delta * move_speed)
			position = step
			
			# Check if we've reached the current target
			if position.distance_to(target_pos) < 0.1:
				current_path_index += 1
				
				# If we reached the end of the path
				if current_path_index >= move_path.size():
					is_moving = false
					# Emit signal or call method to signify movement is complete
		else:
			is_moving = false

# Handle damage and other combat effects
func take_damage(amount: int, damage_type: String = "neutral"):
	if unit_instance:
		var damage_taken = unit_instance.take_damage(amount, damage_type)
		# Update health display
		# Add visual effects
		return damage_taken
	return 0

# Clean up when removing the unit
func _exit_tree():
	# Perform any necessary cleanup
	pass

# Future feature: Load model based on model_id
# func load_model(model_id: String):
#     # Load the 3D model for this unit
#     # This would replace the simple mesh with an actual model
#     pass
