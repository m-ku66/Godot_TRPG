extends Node

# Terrain state
var terrain = {
	"grid": [],
	"width": 20,
	"height": 10,
	"depth": 20,
	"noise_scale": 30
}

# Game entities
var units = {}
var players = {}

# Game state
var current_turn = ""
var current_phase = "movement"
var selected_unit_id = null
var selected_ability_id = null
var highlighted_cells = []
var current_path = []

# Signals
signal terrain_generated(grid)
signal unit_moved(unit_id, position)
signal unit_selected(unit_id)
signal path_found(path)
signal turn_started(player_id)
signal turn_ended(player_id)

# Get a cell at a specific position
func get_cell_at_position(position):
	for cell in terrain.grid:
		if cell.x == position.x and cell.y == position.y and cell.z == position.z:
			return cell
	return null

# Initialize empty terrain grid
func clear_terrain():
	terrain.grid = []
