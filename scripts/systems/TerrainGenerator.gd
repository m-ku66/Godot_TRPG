extends Node
class_name TerrainGenerator

# Generate terrain using noise
static func generate_terrain_grid(width: int, height: int, depth: int, noise_scale: float) -> Array:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	var x_offset = width / 2
	var z_offset = depth / 2
	var y_offset = height / 2
	
	var noise_amplitude = height
	var octaves = 4
	var persistence = 0.5
	var lacunarity = 2.0
	
	var cells = []
	
	for x in range(width):
		for z in range(depth):
			var noise_value = generate_octave_noise(noise, x, z, noise_scale, octaves, persistence, lacunarity)
			var stack_height = max(1, floor(noise_value * noise_amplitude))
			
			for y in range(stack_height):
				var cell = TerrainCell.new()
				cell.x = x - x_offset
				cell.y = y - y_offset
				cell.z = z - z_offset
				cell.traversable = y == stack_height - 1  # Only top cells are traversable
				cell.terrain_type = "grass"  # Default terrain type
				cells.append(cell)
	
	return cells

# Helper function for octave noise
static func generate_octave_noise(noise: FastNoiseLite, x: float, z: float, scale: float, 
								 octaves: int, persistence: float, lacunarity: float) -> float:
	var amplitude = 1.0
	var frequency = 1.0
	var noise_value = 0.0
	
	for i in range(octaves):
		var nx = (x * frequency) / scale
		var nz = (z * frequency) / scale
		noise_value += amplitude * noise.get_noise_2d(nx, nz)
		amplitude *= persistence
		frequency *= lacunarity
	
	# Convert from -1..1 to 0..1
	return (noise_value + 1) / 2
