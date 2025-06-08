extends Node3D

# References
@onready var camera = $Camera3D
@onready var terrain = $Terrain

# Unit systems - Create them as child nodes
var unit_factory
var unit_manager

func _ready():
	# Set up camera
	camera.position = Vector3(10, 10, 10)
	camera.look_at(Vector3.ZERO)
	
	# Initial camera settings for tactical view
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 15  # Orthogonal size (zoom level)
	
	# Initialize unit systems
	setup_unit_systems()
	
	# Wait for terrain to be fully generated, then create units
	await get_tree().process_frame
	await get_tree().process_frame  # Wait an extra frame to be safe
	create_test_units()

func setup_unit_systems():
	# Create unit factory and manager as child nodes
	unit_factory = preload("res://scripts/systems/UnitFactory.gd").new()
	unit_manager = preload("res://scripts/systems/UnitManager.gd").new()
	
	add_child(unit_factory)
	add_child(unit_manager)
	
	print("Unit systems initialized")

func create_test_units():
	print("Attempting to create test units...")
	
	# Get terrain data
	var terrain_grid = GameState.terrain.grid
	if terrain_grid.size() == 0:
		push_error("No terrain found! Cannot place units.")
		return
	
	# Find valid positions on the terrain
	var valid_positions = []
	for cell in terrain_grid:
		if cell.traversable and not cell.occupied_by:
			valid_positions.append(Vector3(cell.x, cell.y, cell.z))
			if valid_positions.size() >= 4:  # Get a few positions for testing
				break
	
	print("Found ", valid_positions.size(), " valid positions for units")
	
	if valid_positions.size() == 0:
		push_error("No valid positions found for units!")
		return
	
	# Create test units
	var units_created = 0
	
	# Create a warrior
	if valid_positions.size() > 0:
		var unit1 = unit_factory.create_unit("test_warrior", valid_positions[0], "player")
		if unit1:
			add_child(unit1)
			unit_manager.register_unit(unit1)
			units_created += 1
			print("Created warrior at: ", valid_positions[0])
	
	# Create a mage  
	if valid_positions.size() > 1:
		var unit2 = unit_factory.create_unit("test_mage", valid_positions[1], "player")
		if unit2:
			add_child(unit2)
			unit_manager.register_unit(unit2)
			units_created += 1
			print("Created mage at: ", valid_positions[1])
	
	# Create another warrior
	if valid_positions.size() > 2:
		var unit3 = unit_factory.create_unit("test_warrior", valid_positions[2], "enemy")
		if unit3:
			add_child(unit3)
			unit_manager.register_unit(unit3)
			units_created += 1
			print("Created enemy warrior at: ", valid_positions[2])
	
	print("Total units created: ", units_created)

func _input(event):
	# Handle mouse clicks for unit selection
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_mouse_click(event.position)
	
	# Keep the existing debug functionality  
	if event.is_action_pressed("ui_accept"):  # Spacebar
		print("=== DEBUG INFO ===")
		print("Terrain cells: ", GameState.terrain.grid.size())
		print("Unit templates loaded: ", DataManager.unit_templates.keys())
		print("Units in manager: ", unit_manager.units.size())

func handle_mouse_click(mouse_pos: Vector2):
	# Step 1: Create ray from camera through mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	print("Mouse ray origin: ", ray_origin, "Mouse ray direction: ", ray_direction)

	
	# Step 2: Cast ray into world space to find click position
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)
	var result = space_state.intersect_ray(query)
	print("Ray query: ", query)
	print("Ray result: ", result)
	
	# Step 3: Find the closest unit to the click position
	if result:
		var click_world_pos = result.position
		var closest_unit = find_closest_unit_to_position(click_world_pos)
		
		if closest_unit:
			unit_manager.select_unit(closest_unit)
			print("Selected unit: ", closest_unit.unit_id)
		else:
			unit_manager.deselect_unit()
			print("Clicked terrain at: ", click_world_pos)

func find_closest_unit_to_position(world_pos: Vector3) -> Node3D:
	print("find_closest_unit_to_position reached...")
	var closest_unit = null
	var closest_distance = 2.0  # Maximum selection distance
	
	for unit_id in unit_manager.units:
		var unit = unit_manager.units[unit_id]
		var distance = unit.position.distance_to(world_pos)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_unit = unit
	
	return closest_unit
