extends Node2D

signal game_paused
signal new_season_start

var towns = []
var global_priorities = []

var player_federation: Federation
var months := 0
var season := 1
var season_length := 1

var rng := RandomNumberGenerator.new()

var Town = preload("res://scenes/Town.tscn")
var Federation = preload("res://scripts/Federation.gd")

var resources = {"food": "farmers", "stone": "stone cutters"}


func _ready() -> void:
	player_federation = Federation.new("Baller")
	global_priorities = openJSON("priorities")
	var initial_towns = openJSON("initial_towns")
	$SeasonsTimer.start()

	var priorities = global_priorities.slice(0, 4)

	var player_town = initial_towns.pop_front()

	player_town["federation"] = player_federation
	player_town["councils"][0]["priorities"] = priorities
	var created_player_town = create_town("Arkanos", player_town)

	$Camera2D.position = created_player_town.position

	for town in initial_towns:
		town["councils"][0]["priorities"] = priorities
		create_town("Babylon", town)


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


func create_town(town_name: String, options: Dictionary) -> Town:
	var town = Town.instance()
	town.town_name = town_name
	town.position = _generate_town_position()
	if options.has("federation"):
		town.federations = [options.get("federation")]
	else:
		rng.randomize()
		town.federations = [Federation.new("Federation %s" % rng.randi())]

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
	self.connect("new_season_start", town, "_on_world_new_season_start")
	town.connect("input_event", town, "_on_Town_pressed_event")
	towns.append(town)
	return town


func _generate_town_position():
	rng.randomize()
	var offset_from_side = 4
	var random_spot = Vector2(
		rng.randi_range(offset_from_side, $Map.map_size.x - offset_from_side),
		rng.randi_range(offset_from_side, $Map.map_size.y - offset_from_side)
	)
	# If there is water in this spot, go find a new spot.
	# TODO: Don't put this near existing towns
	if $Map/Water.get_cellv(random_spot) != -1:
		return _generate_town_position()
	return Vector2(random_spot.x * $Map/Grass.cell_size.x, random_spot.y * $Map/Grass.cell_size.y)
