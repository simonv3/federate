extends VBoxContainer

signal open_with_council

onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")

var council


func _on_CouncilDetails_open_with_council(new_council):
	self.show()
	council = new_council
	if not council.is_connected("on_statistics_updated", self, "_update"):
		council.connect("on_statistics_updated", self, "_update")
	_update()


func _update():
	$CouncilName.text = council.council_name

	var federation = get_node('/root/world').player_federation
	var opinion_array = council.calculate_opinion_of('federation', federation)

	if not ($Opinion.is_connected("mouse_entered", OpinionHover, "_on_opinion_mouse_entered")):
		$Opinion.connect(
			"mouse_entered", OpinionHover, "_on_opinion_mouse_entered", [opinion_array[1]]
		)
		$Opinion.connect("mouse_exited", OpinionHover, "_on_opinion_mouse_exited")
		$Opinion.text = "Opinion of %s: %s" % [federation.federation_name, opinion_array[0]]

	$Statistics.set_current_council(council)
	$PlayerActions/ProductivityToggles.set_current_council(council)

	if council.town.is_player_town():
		$PlayerActions/ProductivityToggles.show()
		$PlayerActions/SendEnvoy.hide()
		$PlayerActions/SplitCouncil.show()
	else:
		$PlayerActions/ProductivityToggles.hide()
		$PlayerActions/SendEnvoy.show()
		$PlayerActions/SplitCouncil.hide()

	var priorities_text = ''

	for priority in council.priorities:
		priorities_text += "   %s\n" % [priority.name]

	$Priorities/PrioritiesList.text = priorities_text

	var relationships_text = ''
	for relationship in council.relationships:
		relationships_text += "   %s\n" % [relationship.readable]

	$Relationships/RelationshipsList.text = relationships_text


func _on_ViewTown_pressed():
	get_node("/root/world/HUD/UI/Bottom/Panel/Details").emit_signal("open_town", council.town)


func _on_SplitCouncil_pressed():
	# Pop up a confirmation dialog.
	var actions = []
	for type in self.get_node('/root/world').resources:
		actions.push_back(
			{
				"label": type,
				"func_ref": funcref(council, "_split_council"),
				"parameters": [type, council]
			}
		)
	get_node('/root/world/HUD').receive_message(
		"Split this council? What should its resource be?", actions, false
	)


func _on_SendEnvoy_pressed():
	var player_federation = get_node("/root/world").player_federation
	var actions = [
		{
			"label": "Yes",
			"func_ref": funcref(council, "_send_federation_envoy"),
			"parameters": [player_federation]
		}
	]
	get_node('/root/world/HUD').receive_message(
		"Do you want to send an envoy to this council??", actions, false
	)
