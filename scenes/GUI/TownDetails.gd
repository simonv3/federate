extends VBoxContainer

signal open_with_town

var town

var CouncilButton = preload("res://scenes/GUI/CouncilButton.tscn")
onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")


func _on_TownDetails_open_with_town(new_town):
	self.show()
	town = new_town

	for council in town.councils:
		if not council.is_connected("on_statistics_updated", self, "_update"):
			council.connect("on_statistics_updated", self, "_update")

	_update()


func _update():
	$TownTitle.text = town.town_name

	$Statistics/Population.text = "Population: %s" % town.population
	$Statistics/Happiness.text = "Happiness: %s" % town.calculate_happiness()

	var aggregateOpinion = 0
	var opinion_array = []

	var federation = get_node('/root/world').player_federation

	for child in $Councils.get_children():
		child.queue_free()

	for council in town.councils:
		var council_button = CouncilButton.instance()
		council_button.council = council
		$Councils.add_child(council_button)
		var opinion = council.calculate_opinion_of('federation', federation)
		aggregateOpinion += opinion[0]
		opinion_array += opinion[1]

	if not $Opinion.is_connected("mouse_entered", OpinionHover, "_on_opinion_mouse_entered"):
		$Opinion.connect(
			"mouse_entered", OpinionHover, "_on_opinion_mouse_entered", [opinion_array]
		)
		$Opinion.connect("mouse_exited", OpinionHover, "_on_opinion_mouse_exited")
		$Opinion.text = "Opinion of %s: %s" % [federation.federation_name, aggregateOpinion]

	for child in $Resources.get_children():
		child.queue_free()

	for resource in town.town_resources:
		var resource_label = Label.new()
		resource_label.text = "Surplus %s: %s" % [resource, town.town_resources[resource]]
		$Resources.add_child(resource_label)
