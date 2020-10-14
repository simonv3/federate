extends InteractableEntity
class_name Town

signal inform_councils

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


func _init():
	pass


func _ready():
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
	HUDDetails.close_everything()
	if new_selected:
		var all_towns = get_tree().get_nodes_in_group("towns")
		for town in all_towns:
			town.selected = false
		draw_self_in_HUD_details()
		($TownSelected as Sprite).show()
	else:
		($TownSelected as Sprite).hide()
	selected = new_selected


func create_council(name: String, resource, population, priorities) -> void:
	var council = Council.instance()
	council.council_name = name
	council.resource = resource
	council.member_number = population
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
	._on_world_new_season_start(season)


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
			growth_priority.member_number = clamp(growth_priority.member_number + 1, 0, population)


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


func draw_self_in_HUD_details():
	var town = self

	var town_vbox = toggle_to_show(
		"Town", "%s (Federation: %s)" % [town.town_name, town.federations[0].federation_name]
	)

	var councils = HBoxContainer.new()

	var aggregateOpinion = 0
	var federation = get_node('/root/world').player_federation

	for council in town.councils:
		var councilBox = VBoxContainer.new()
		aggregateOpinion += council.calculate_opinion_of('federation', federation)
		add_label(councilBox, council.council_name)
		add_button(councilBox, "View Details", "_on_Council_clicked", [council])
		if town.is_player_town():
			if council.town.growth_priority == council:
				add_label(councilBox, "Is Growth Priority")
			else:
				add_button(
					councilBox, "Set as Growth Priority", "_on_Council_growth_priority", [council]
				)
		councils.add_child(councilBox)

	add_label(town_vbox, "Opinion of %s: %s" % [federation.federation_name, aggregateOpinion])

	town_vbox.add_child(councils)
	var stats = VBoxContainer.new()
	town_vbox.add_child(stats)

	# TODO: make resources only show if they exist.
	for resource in town.town_resources:
		add_label(stats, "Surplus %s: %s" % [resource, town.town_resources[resource]])
#		add_label(stats, "Food: %s" % details_town.town_resources.food)
#		add_label(stats, "Stone: %s" % details_town.town_resources.stone)
	add_label(stats, "Population: %s" % town.population)
	add_label(stats, "Happiness: %s" % town.calculate_happiness())


func _on_Council_growth_priority(council: Council):
	council.town.set_growth_priority(council)
