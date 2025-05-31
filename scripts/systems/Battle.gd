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

# Optional: Add this for debugging
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Spacebar
		print("=== DEBUG INFO ===")
		print("Terrain cells: ", GameState.terrain.grid.size())
		print("Unit templates loaded: ", DataManager.unit_templates.keys())
		print("Units in manager: ", unit_manager.units.size())
