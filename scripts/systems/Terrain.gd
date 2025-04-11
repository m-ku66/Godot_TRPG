extends Node3D

# Configuration
@export var width: int = 20
@export var height: int = 10
@export var depth: int = 20
@export var noise_scale: float = 30

# References
@onready var game_state = get_node("/root/GameState")

# Visual components
var terrain_mesh_library = {}
var cell_meshes = {}

func _ready():
	# Generate terrain when the node enters the scene
	generate_terrain()

func generate_terrain():
	# Clear previous terrain if any
	clear_terrain()
	
	# Generate new terrain grid
	var grid = TerrainGenerator.generate_terrain_grid(width, height, depth, noise_scale)
	
	# Update GameState
	game_state.terrain.grid = grid
	game_state.terrain.width = width
	game_state.terrain.height = height
	game_state.terrain.depth = depth
	game_state.terrain.noise_scale = noise_scale
	
	# Render terrain visually
	render_terrain()
	
	# Emit signal from GameState
	game_state.emit_signal("terrain_generated", grid)

func render_terrain():
	# Remove existing terrain meshes
	for mesh_id in cell_meshes:
		if is_instance_valid(cell_meshes[mesh_id]):
			cell_meshes[mesh_id].queue_free()
	cell_meshes.clear()
	
	# Create new meshes for each cell
	for cell in game_state.terrain.grid:
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 1, 1)
		
		# Set material based on traversability
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.GREEN if cell.traversable else Color.RED
		
		mesh_instance.mesh = box_mesh
		mesh_instance.material_override = material
		mesh_instance.position = Vector3(cell.x, cell.y, cell.z)
		
		# Add to scene
		add_child(mesh_instance)
		
		# Store reference
		var cell_id = "%d,%d,%d" % [cell.x, cell.y, cell.z]
		cell_meshes[cell_id] = mesh_instance

func clear_terrain():
	# Clear existing visual terrain
	for mesh_id in cell_meshes:
		if is_instance_valid(cell_meshes[mesh_id]):
			cell_meshes[mesh_id].queue_free()
	cell_meshes.clear()
	
	# Clear terrain data
	game_state.clear_terrain()
