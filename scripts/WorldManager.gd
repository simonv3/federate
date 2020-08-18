extends Node2D

signal game_paused
signal new_season_start

export var towns := []

var player_federation: Federation 
var months := 0
var season := 1
var season_length := 4

var rng := RandomNumberGenerator.new()

var Town = preload("res://scenes/Town.tscn")
var Federation = preload("res://scripts/Federation.gd")

func _ready() -> void:
	player_federation = Federation.new("Baller")
	$SeasonsTimer.start()
	create_town("Arkanos", Vector2(400.0, 400.0), {"federation": player_federation})
	create_town("Babylon", Vector2(100.0, 200.0), {})


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_select"):
		emit_signal("game_paused")


func _on_SeasonsTimer_timeout() -> void:
	months += 1
	if (months % season_length == 0):
		season += 1
		emit_signal("new_season_start", season)


func create_town(town_name: String, position: Vector2, options: Dictionary) -> Town:
	var town = Town.instance()
	town.town_name = town_name
	town.position = position
	if (options.has("federation")):
		town.federations = [options.get("federation")]
	else:
		rng.randomize()
		town.federations = [Federation.new("Federation %s" % rng.randi())]
	add_child(town)
	town.add_to_group("towns")
	self.connect("new_season_start", town, "_on_world_new_season_start")
	town.connect("input_event", town, "_on_Town_pressed_event")
	towns.append(town)
	return town
