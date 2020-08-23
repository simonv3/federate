extends Node2D
class_name Town

signal inform_councils

export var town_name := ""
export var population := 5 setget set_population

var councils := []
var town_resources = {"food": 5}
# TODO: I have some concerns that structuring federations this way is 
# not the right way to do this. Every town we look at we have to 
# look at the world node for the player federation, and see if it's 
# the same federation as the player's
var federations := []

var selected = false setget set_selected
var Federation = preload("Federation.gd")
var Council = preload("Council.gd")

var food_cost_of_person := 5
var go_to_town_message = {
	"message": "Go to town", 
	"function": funcref(self, "set_selected"), 
	"parameters": true
}

var HUD

func _init():
	pass


func _ready():
	HUD = get_tree().get_root().get_node("world/HUD")
	# TODO: We possibly don't want this automatically for every town?

func _is_player_town() -> bool:
	for federation in federations:
		if federation == get_node("/root/world").player_federation:
			return true
	return false


func set_selected(new_selected) -> void:
	selected = new_selected
	if (new_selected):
		var all_towns = get_tree().get_nodes_in_group("towns")
		for town in all_towns:
			town.selected = false
		_is_player_town()
		HUD.open_details_for_town(self)
		($TownSelected as Sprite).show()
	else:
		($TownSelected as Sprite).hide()


func create_council(name: String, resource, priorities) -> void:
	var council = Council.new(name, resource, 5, priorities)
	council.connect("produce_resource", self, "_on_produce_resource")
	self.connect("inform_councils", council, "_on_town_inform_councils")
	self.councils.append(council)


func set_population(new_population: int) -> void:
	population = new_population


func _on_world_new_season_start(season) -> void:
	_grow_town()
	emit_signal("inform_councils", season)
	
	
func _on_produce_resource(resource, quantity) -> void:
	town_resources[resource] += quantity


func _grow_town() -> void:
	if town_resources.food > population:
		set_population(population + 1)
		town_resources.food -= food_cost_of_person
		# TODO: assign to council based on town preference.


func _calculate_idle_people() -> int:
	var sum = 0
	for council in councils:
		sum += council.member_number
	return population - sum


func _on_Town_pressed_event(_viewport, event, _shade) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		set_selected(!selected)
