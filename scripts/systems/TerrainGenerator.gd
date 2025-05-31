extends Node
class_name TerrainGenerator

# Generate terrain using noise
static func generate_terrain_grid(width: int, height: int, depth: int, noise_scale: float) -> Array:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	 
	# Choose from multiple noise types
	var noise_types = [
		FastNoiseLite.TYPE_SIMPLEX,
		FastNoiseLite.TYPE_PERLIN, 
		FastNoiseLite.TYPE_VALUE_CUBIC
		]
	noise.noise_type = noise_types[randi() % noise_types.size()]
	
	# Randomize fractal type too for even more variety
	var fractal_types = [
		FastNoiseLite.FRACTAL_NONE,
		FastNoiseLite.FRACTAL_FBM,
		FastNoiseLite.FRACTAL_RIDGED
		]
	noise.fractal_type = fractal_types[randi() % fractal_types.size()]
	
	# Randomize other parameters within reasonable ranges
	noise.fractal_octaves = 3 + randi() % 4  # 3-6 octaves
	
	var x_offset = width / 2.0
	var z_offset = depth / 2.0
	var y_offset = height / 2.0
	
	var noise_amplitude = height
	var octaves = 8
	var persistence = 0.7
	var lacunarity = 2.5
	#var octaves = 6 + randi() % 3  # 4-6 octaves
	#var persistence = 0.4 + randf() * 0.3  # 0.4-0.7
	#var lacunarity = 1.8 + randf() * 0.7  # 1.8-2.5
	
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
