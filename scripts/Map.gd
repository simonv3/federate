extends Node2D

var noise: OpenSimplexNoise
var map_size := Vector2(60, 60)  # * 64 for tile size
var water_cap = -0.02


func _ready():
	noise = OpenSimplexNoise.new()
	noise.octaves = 1.0
	noise.period = 7

	make_grass_map()
	make_water()


func make_grass_map():
	for x in map_size.x:
		for y in map_size.y:
			$Grass.set_cell(x, y, 0)

	$Grass.update_bitmask_region(Vector2(0.0, 0.0), Vector2(map_size.x, map_size.y))


func make_water():
	for x in map_size.x:
		for y in map_size.y:
			var a = noise.get_noise_2d(x, y)
			if a < water_cap:
				$Water.set_cell(x, y, 0)

	$Water.update_bitmask_region(Vector2(0.0, 0.0), Vector2(map_size.x, map_size.y))
