extends Camera3D

# Camera parameters
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 5.0
@export var max_zoom: float = 25.0
@export var rotation_step: float = 45.0
@export var pan_speed: float = 10.0

# Camera state
var current_rotation: float = 45.0
var target_position: Vector3 = Vector3.ZERO
var orbit_distance: float = 15.0

func _ready():
	# Set initial position
	position = Vector3(60, 60, 60)
	
	# Set target position (where to look at)
	target_position = Vector3.ZERO
	
	# Update the transform (this will make it look at the target)
	update_camera_transform()
	make_current()


func _process(delta):
	# Camera control logic will go here
	pass

func _input(event):
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(zoom_speed)

func zoom_camera(amount):
	# Adjust orthographic size (zoom)
	size = clamp(size + amount * size, min_zoom, max_zoom)

func rotate_camera(direction: String):
	if direction == "left":
		current_rotation = fmod(current_rotation + rotation_step, 360.0)
	else:  # right
		current_rotation = fmod(current_rotation - rotation_step, 360.0)
	
	update_camera_transform()

func reset_camera():
	current_rotation = 45.0
	update_camera_transform()

func update_camera_transform():
	# Calculate position based on rotation and distance
	var angle_rad = deg_to_rad(current_rotation)
	var new_x = orbit_distance * cos(angle_rad)
	var new_z = orbit_distance * sin(angle_rad)
	
	# Update camera position
	position = Vector3(new_x, position.y, new_z)
	look_at(target_position)
