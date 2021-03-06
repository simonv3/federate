extends Node2D
class_name Town

signal inform_councils
signal statistics_updated

export var town_name := ""
export var population := 5 setget set_population

var tile_position: Vector2
var councils := []
var town_resources = {"food": 5}
# TODO: I have some concerns that structuring federations this way is 
# not the right way to do this. Every town we look at we have to 
# look at the world node for the player federation, and see if it's 
# the same federation as the player's
var federations := []

var selected = false setget set_selected
var Federation = preload("res://scenes/Federation.tscn")
var Council = preload("res://scenes/Council.tscn")

var food_cost_of_person := 5
var growth_priority: Council
var go_to_town_message = {
	"message": "Go to town", "function": funcref(self, "set_selected"), "parameters": true
}

var radius_needed = 4  # in tiles

var label

onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")
onready var HUDDetails = get_node("/root/world/HUD/UI/Bottom/Panel/Details")


func _init():
	pass


func _ready():
	get_node("/root/world").connect("new_season_start", self, "_on_world_new_season_start")
	label = get_node("TownName")
	label.text = self.town_name


func is_player_town() -> bool:
	return is_in_federation(get_node("/root/world").player_federation)


func is_in_federation(other_federation: Federation) -> bool:
	for federation in federations:
		if federation == other_federation:
			return true
	return false


func set_selected(new_selected) -> void:
#	HUDDetails.close_everything()
	if new_selected:
		var all_towns = get_tree().get_nodes_in_group("towns")
		for town in all_towns:
			town.selected = false

		HUDDetails.emit_signal("open_town", self)
		($TownSelected as Sprite).show()
	else:
		($TownSelected as Sprite).hide()
	selected = new_selected


func create_council(name: String, resource, council_population, priorities) -> void:
	var council = Council.instance()
	council.council_name = name
	council.resource = resource
	council.member_number = council_population
	council.priorities = priorities
	council.town = self
	council.connect("produce_resource", self, "_on_produce_resource")
	self.connect("inform_councils", council, "_on_town_inform_councils")
	self.councils.append(council)
	self.add_child(council)


func set_population(new_population: int) -> void:
	population = new_population


func set_growth_priority(council):
	growth_priority = council
	growth_priority.emit_signal("on_statistics_updated")


# We'll want a more sophisticated way of calculating happiness at some point!
func calculate_happiness():
	var happiness = 0
	for council in self.councils:
		if council.output_multiplier == 'low':
			happiness += council.resource_multiplier_map[council.resource]['low'] * 100
		if council.output_multiplier == 'high':
			happiness -= (council.resource_multiplier_map[council.resource]['high'] * 100)
	return happiness


func _on_world_new_season_start(season):
	_grow_town()
	emit_signal("inform_councils", season)


func _on_produce_resource(resource, quantity) -> void:
	if town_resources.get(resource):
		town_resources[resource] += quantity
	else:
		town_resources[resource] = quantity


func _grow_town() -> void:
	if town_resources.food > population:
		set_population(population + 1)
		town_resources.food -= food_cost_of_person
		if growth_priority:
			var new_member_num = clamp(growth_priority.member_number + 1, 0, population)
			growth_priority.set_member_number(new_member_num)


func _calculate_idle_people() -> int:
	var sum = 0
	for council in councils:
		sum += council.member_number
	return population - sum


func _on_Town_pressed_event(_viewport, event, _shade) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		set_selected(! selected)


func _on_Town_mouse_entered():
	label.visible = true


func _on_Town_mouse_exited():
	label.visible = false
