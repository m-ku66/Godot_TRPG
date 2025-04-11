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
