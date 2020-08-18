extends Node2D
class_name Town

signal inform_councils

export var town_name := "Anarkos 1"
export var councils: Array = []
export var town_resources = {"food": 5}
export var population := 5 setget set_population

# TODO: I have some concerns that structuring federations this way is 
# not the right way to do this. Every town we look at we have to 
# look at the world node for the player federation, and see if it's 
# the same federation as the player's
export var federations := []

var selected = false setget set_selected
var Federation = preload("Federation.gd")
var Council = preload("Council.gd")

var food_cost_of_person := 5
var go_to_town_message = {
	"message": "Go to town", 
	"function": funcref(self, "set_selected"), 
	"parameters": true
}

func _init():
	print("created town")


func _ready():
	# TODO: We possibly don't want this automatically for every town?
	create_council("farmers", "food")

func _is_player_town() -> bool:
	for federation in federations:
		if federation == get_node("/root/world").player_federation:
			return true
	return false


func set_selected(new_selected) -> void:
	selected = new_selected
	if (new_selected):
		_is_player_town()
		($TownSelected as Sprite).show()
	else:
		($TownSelected as Sprite).hide()


func create_council(name: String, resource) -> void:
	var farmer_council = Council.new(name, resource, population)
	farmer_council.connect("produce_resource", self, "_on_produce_resource")
	self.connect("inform_councils", farmer_council, "_on_town_inform_councils")
	councils.append(farmer_council)


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
		if _calculate_idle_people():
			var HUD := get_tree().get_root().get_node("world/HUD")
			# FIXME: Can the message be a class here? 
			var text := "we have an idle person in %s!" % town_name
			HUD.receive_message(text, [go_to_town_message])

		print("resources: %s, population: %s" % [town_resources, population])


func _calculate_idle_people() -> int:
	var sum = 0
	for council in councils:
		sum += council.member_number
	return population - sum


func _on_Town_pressed_event(_viewport, event, _shade) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		set_selected(!selected)
