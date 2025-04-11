extends Resource
class_name TerrainCell

@export var x: int
@export var y: int 
@export var z: int
@export var traversable: bool = true
@export var terrain_type: String = "grass"
@export var occupied_by: String = ""

# For easy comparison of positions
func position_equals(other_pos: Vector3) -> bool:
	return x == other_pos.x and y == other_pos.y and z == other_pos.z
	
func position_vector() -> Vector3:
	return Vector3(x, y, z)
