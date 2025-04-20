extends Node3D

# References
@onready var camera = $Camera3D
@onready var terrain = $Terrain

func _ready():
	# Set up camera
	camera.position = Vector3(10, 10, 10)
	camera.look_at(Vector3.ZERO)
	
	# Initial camera settings for tactical view
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 15  # Orthogonal size (zoom level)
	
	 # Add a visible marker at origin
	#var marker = MeshInstance3D.new()
	#var sphere = SphereMesh.new()
	#sphere.radius = 1.0
	#marker.mesh = sphere
	#
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color.BLUE
	#marker.material_override = material
	#
	#add_child(marker)
