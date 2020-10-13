extends InteractableEntity
class_name Council

signal produce_resource

export var council_name := ''
export var member_number := 0 setget set_member_number
export var output_multiplier := "medium"
export var member_minimum := 0

var resource_multiplier_map = {
	"food": {"low": 0.1, "medium": 0.15, "high": 0.25},
	"stone": {"low": 0.5, "medium": 0.1, "high": 0.13}
}

var town

var resource: String
var priorities := []
var relationships := []

var resource_quantity


func _init() -> void:
	pass


#	council_name = new_council_name
#	resource = new_resource
#	member_number = new_council_amount
#	priorities = new_priorities
#	town = new_town


func _on_town_inform_councils(season: int) -> void:
	if season % 4 == 0:
		resource_quantity = resource_multiplier_map[resource][output_multiplier] * member_number
		emit_signal("produce_resource", resource, resource_quantity)


func set_member_number(new_number: int):
	member_number = new_number


func set_productivity(level: String):
	if level in ["low", "medium", "high"]:
		output_multiplier = level


func calculate_opinion_of(type: String, OpiningAbout):
	var opinion = []

	if type == 'federation':
		if self.town.is_in_federation(OpiningAbout):
			opinion.push_back({"value": 10, "reason": "Same federation"})
	var opinion_sum = 0
	for item in opinion:
		opinion_sum += item["value"]
	return opinion_sum


func draw_self_in_HUD_details():
	# FIXME: is redrawing all the labels the most efficient way of doing this?
	var council = self

	var council_vbox = self.toggle_to_show(
		"Council", "Council: %s (%s)" % [council.council_name, council.town.town_name]
	)

	var federation = get_node('/root/world').player_federation
	add_label(
		council_vbox,
		(
			"Opinion of %s: %s"
			% [federation.federation_name, council.calculate_opinion_of('federation', federation)]
		)
	)

	add_button(council_vbox, "View Town", "_on_Town_clicked", [council.town])

	var resource_multiplier = council.output_multiplier if council.output_multiplier else 0.00

	add_label(council_vbox, "%s (%s)" % [council.resource, resource_multiplier])
	add_label(council_vbox, "Population: %s" % council.member_number)

	var council_actions = HBoxContainer.new()
	council_vbox.add_child(council_actions)

	if council.town.is_player_town():
		var buttons = ["low", "medium", "high"]
		add_label(council_vbox, 'Toggle Productivity:')
		var production_rate_buttons = HBoxContainer.new()
		council_vbox.add_child(production_rate_buttons)

		for button in buttons:
			add_button(
				production_rate_buttons, button, "_on_Productivity_clicked", [council, button]
			)

		add_button(council_actions, "Split Council", "_on_Council_Split_clicked", [council])
	else:
		add_button(council_actions, "Send Envoy", "_on_Council_Send_Envoy", [council])

	add_label(council_vbox, "Council Priorities")
	for priority in council.priorities:
		add_label(council_vbox, priority.name)


func _on_Productivity_clicked(council: Council, level: String):
	council.set_productivity(level)


func _on_Council_Split_clicked(council: Council):
	# Pop up a confirmation dialog.
	var actions = []
	for type in self.get_node('/root/world').resources:
		actions.push_back(
			{
				"label": type,
				"func_ref": funcref(self, "_split_council"),
				"parameters": [type, council]
			}
		)
	get_node('/root/world/HUD').receive_message(
		"Split this council? What should its resource be?", actions, false
	)


func _on_Council_Send_Envoy(council: Council):
	# Pop up a confirmation dialog.
	var actions = []
	for type in self.get_node('/root/world').resources:
		actions.push_back(
			{
				"label": type,
				"func_ref": funcref(self, "_split_council"),
				"parameters": [type, council]
			}
		)
	get_node('/root/world/HUD').receive_message(
		"Split this council? What should its resource be?", actions, false
	)


func _split_council(new_council_type: String, council: Council):
	council.member_number -= 5
	council.town.create_council(
		get_node('/root/world').resources[new_council_type], new_council_type, 5, council.priorities
	)
