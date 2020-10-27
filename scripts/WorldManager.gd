extends Node2D

signal game_paused
signal new_season_start

var towns = []
var global_priorities = []
var relationships = []
var possible_federation_names = []
var possible_town_names = []

var months := 0
var season := 1
var season_length := 1

var rng := RandomNumberGenerator.new()

var Town = preload("res://scenes/Town.tscn")
var Federation = preload("res://scenes/Federation.tscn")

var player_federation: Federation
var resources = {"food": "farmers", "stone": "stone cutters"}


func _ready() -> void:
	player_federation = Federation.instance()
	player_federation.federation_name = "Baller"
	global_priorities = openJSON("priorities")
	var initial_towns = openJSON("initial_towns")
	possible_federation_names = openJSON("federation_names")
	possible_town_names = openJSON("town_names")
	$SeasonsTimer.start()

	var priorities = pick_random_priorities(global_priorities)

	var player_town = initial_towns.pop_front()

	player_town["federation"] = player_federation
	player_town["councils"][0]["priorities"] = priorities
	var created_player_town = create_town("Arkanos", player_town)

	$Camera2D.position = created_player_town.position

	for town in initial_towns:
		town["councils"][0]["priorities"] = pick_random_priorities(global_priorities)
		create_town("Babylon", town)


func pick_random_federation_name():
	randomize()
	var suggested_name = possible_federation_names[randi() % possible_federation_names.size()]
	for town in towns:
		for federation in town.federations:
			if federation.federation_name == suggested_name:
				suggested_name = pick_random_federation_name()
	return suggested_name


func pick_random_priorities(global_priorities: Array):
	var new_priorities = []
	var used_indexes = []
	for i in range(0, 5):
		randomize()
		var idx = randi() % global_priorities.size()
		while used_indexes.has(idx):
			randomize()
			idx = randi() % global_priorities.size()
		used_indexes.push_back(idx)
		new_priorities.push_back(global_priorities[idx])
	return new_priorities


func openJSON(file_location):
	var file = File.new()
	file.open("res://data/%s.json" % file_location, file.READ)
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	file.close()
	return json_result


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_select"):
		emit_signal("game_paused")


func _on_SeasonsTimer_timeout() -> void:
	months += 1
	if months % season_length == 0:
		season += 1
		emit_signal("new_season_start", season)


func create_town(town_name: String, options: Dictionary):
	var town = Town.instance()
	town.add_to_group("towns")
	town.town_name = town_name
	town.tile_position = _generate_town_position()
	town.position = _convert_tile_position_to_x_y(town.tile_position)
	if options.has("federation"):
		options.get("federation").add_to_group("federations")
		town.federations = [options.get("federation")]
	else:
		var fed = Federation.instance()
		fed.add_to_group("federations")
		fed.federation_name = pick_random_federation_name()
		town.federations = [fed]

	if options.has("resources"):
		town.town_resources = options.get("resources")

	if options.has("councils"):
		for council in options.get("councils"):
			town.create_council(
				council.get("name"),
				council.get("resource"),
				council.get("population", 5),
				council.get("priorities", [])
			)

	add_child(town)
	town.add_to_group("towns")
#	self.connect("new_season_start", town, "_on_world_new_season_start")
	town.connect("input_event", town, "_on_Town_pressed_event")
	towns.append(town)
	return town


func _convert_tile_position_to_x_y(position: Vector2):
	var cell_size_x = $Map/Grass.cell_size.x
	var cell_size_y = $Map/Grass.cell_size.y

	return Vector2(position.x * cell_size_x, position.y * cell_size_y)


func _generate_town_position():
	rng.randomize()
	var offset_from_map_edge = 1

	var random_tile_spot = Vector2(
		rng.randi_range(offset_from_map_edge, $Map.map_size.x - offset_from_map_edge),
		rng.randi_range(offset_from_map_edge, $Map.map_size.y - offset_from_map_edge)
	)
	# If there is water in this spot, go find a new spot.
	if $Map/Water.get_cellv(random_tile_spot) != -1:
		return _generate_town_position()

	if _is_there_space_around_other_towns(random_tile_spot):
		return _generate_town_position()

	return Vector2(random_tile_spot.x, random_tile_spot.y)


func _is_there_space_around_other_towns(random_tile_spot: Vector2):
	var is_in_personal_space = false
	for town in towns:
		if town.tile_position:
			var town_min_x = town.tile_position.x - town.radius_needed
			var town_max_x = town.tile_position.x + town.radius_needed
			var town_min_y = town.tile_position.y - town.radius_needed
			var town_max_y = town.tile_position.y + town.radius_needed
			if (
				random_tile_spot.x > town_min_x
				and random_tile_spot.x < town_max_x
				and random_tile_spot.y > town_min_y
				and random_tile_spot.y < town_max_y
			):
				is_in_personal_space = true
	return is_in_personal_space
