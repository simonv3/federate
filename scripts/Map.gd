extends Node2D

var noise: OpenSimplexNoise
var map_size := Vector2(20, 20)  # * 64 for tile size
var water_cap = -0.02
var woods_cap = 0


func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 2
	noise.period = 7

	make_grass_map()

	make_water()
	make_woods()


func make_grass_map():
	for x in map_size.x:
		for y in map_size.y:
			$Grass.set_cell(x, y, 0)

	$Grass.update_bitmask_region(Vector2(0.0, 0.0), map_size)


func make_woods():
	randomize()
	var wood_noise = OpenSimplexNoise.new()
	wood_noise.octaves = 1
	wood_noise.period = 3
	wood_noise.seed = randi()
	for x in map_size.x:
		for y in map_size.y:
			var a = wood_noise.get_noise_2d(x, y)
			var cellv = $Water.get_cellv(Vector2(x, y))
			print('cellv', cellv)
			var has_water = cellv != -1
			if a > woods_cap and not has_water:
				$Woods.set_cell(x, y, 0)

	$Woods.update_bitmask_region(Vector2(0, 0), map_size)


func make_water():
	for x in map_size.x:
		for y in map_size.y:
			var a = noise.get_noise_2d(x, y)
			if a < water_cap:
				$Water.set_cell(x, y, 0)
				if y == 0:
					$Water.set_cell(x, -1, 0)
				if x == 0:
					$Water.set_cell(-1, y, 0)
				if x == map_size.x - 1:
					$Water.set_cell(x + 1, y, 0)
				if y == map_size.y - 1:
					$Water.set_cell(x, y + 1, 0)

	$Water.update_bitmask_region(Vector2(0.0, 0.0), map_size)
