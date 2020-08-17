extends Node2D
class_name Town

signal inform_councils

export var town_name := "Anarkos 1"
export var councils: Array = []
export var town_resources = {"food": 5}
export var population := 5 setget set_population

var selected = false setget set_selected
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
	create_council("farmers", "food")


func set_selected(new_selected):
	selected = new_selected
	if (new_selected):
		($TownSelected as Sprite).show()
	else:
		($TownSelected as Sprite).hide()


func create_council(name: String, resource):
	var farmer_council = Council.new(name, resource, population)
	farmer_council.connect("produce_resource", self, "_on_produce_resource")
	self.connect("inform_councils", farmer_council, "_on_town_inform_councils")
	councils.append(farmer_council)


func set_population(new_population: int):
	population = new_population


func _on_world_new_season_start(season):
	_grow_town()
	emit_signal("inform_councils", season)
	
	
func _on_produce_resource(resource, quantity):
	town_resources[resource] += quantity
	print(town_resources)


func _grow_town():
	if town_resources.food > population:
		set_population(population + 1)
		town_resources.food -= food_cost_of_person
		if _calculate_idle_people():
			var HUD := get_tree().get_root().get_node("world/HUD")
			# FIXME: Can the message be a class here? 
			var text := "we have an idle person in %s!" % town_name
			HUD.receive_message(text, [go_to_town_message])

		print("resources: %s, population: %s" % [town_resources, population])


func _calculate_idle_people():
	var sum = 0
	for council in councils:
		sum += council.member_number
	return population - sum


func _on_Town_pressed_event(_viewport, event, _shade):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		set_selected(!selected)
