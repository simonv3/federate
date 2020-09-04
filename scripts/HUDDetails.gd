extends VBoxContainer

var are_details_open = true
var details_town: Town
var details_council: Council
var viewing := 'Town'


func _process(_delta: float):
	if viewing == 'Town':
		set_details_to_town(details_town)
	if viewing == 'Council':
		set_details_to_council(details_council)


func set_details_label(node_name, text):
	var node_to_add_to = self.get_node(node_name)
	add_label(node_to_add_to, text)


func clean_details(node_path):
	var children = self.get_node(node_path).get_children()
	for child in children:
		child.queue_free()


func open_details_for_town(town: Town):
	are_details_open = true
	set_details_to_town(town)


func toggle_details_container(should_open):
	are_details_open = should_open
	if should_open:
		self.get_parent().show()
	else:
		clean_details("Town")
		clean_details("Council")
		self.get_parent().hide()


func toggle_to_show(showing: String, title: String) -> VBoxContainer:
	viewing = showing
	clean_details(showing)
	for child in self.get_children():
		if child.get_class() != 'Button':
			child.hide()

	toggle_details_container(true)
	set_details_label(showing, title)
	var vbox = self.get_node(showing)

	self.get_node(showing).hide()
	vbox.show()
	return vbox


func set_details_to_town(town: Town):
	if town and are_details_open:
		# FIXME: is redrawing all the labels the most efficient way of doing this?
		details_council = null
		details_town = town

		var town_vbox = toggle_to_show(
			"Town", "%s (Federation: %s)" % [town.town_name, town.federations[0].federation_name]
		)

		var councils = HBoxContainer.new()
		town_vbox.add_child(councils)

		for council in town.councils:
			var councilBox = VBoxContainer.new()
			add_label(councilBox, council.council_name)
			add_button(councilBox, "View Details", "_on_Council_clicked", [council])
			if details_town.is_player_town():
				if council.town.growth_priority == council:
					add_label(councilBox, "Is Growth Priority")
				else:
					add_button(
						councilBox,
						"Set as Growth Priority",
						"_on_Council_growth_priority",
						[council]
					)
			councils.add_child(councilBox)

		var stats = HBoxContainer.new()
		town_vbox.add_child(stats)

		add_label(stats, "Food: %s" % details_town.town_resources.food)
		add_label(stats, "Population: %s" % details_town.population)
		add_label(stats, "Happiness: %s" % details_town.calculate_happiness())


func set_details_to_council(council: Council):
	if council:
		# FIXME: is redrawing all the labels the most efficient way of doing this?
		details_council = council

		var council_vbox = toggle_to_show(
			"Council", "Council: %s (%s)" % [council.council_name, council.town.town_name]
		)

		add_button(council_vbox, "View Town", "_on_Town_clicked", [council.town])

		var resource_multiplier = council.output_multiplier if council.output_multiplier else 0.00

		add_label(council_vbox, "%s (%s)" % [council.resource, resource_multiplier])
		add_label(council_vbox, "Population: %s" % council.member_number)

		var council_actions = HBoxContainer.new()
		council_vbox.add_child(council_actions)

		if council.town.is_player_town():
			var buttons = ["low", "medium", "high"]
			var production_rate_buttons = HBoxContainer.new()
			council_vbox.add_child(production_rate_buttons)

			for button in buttons:
				add_button(
					production_rate_buttons, button, "_on_Productivity_clicked", [council, button]
				)

			add_button(council_actions, "Split Council", "_on_Council_Split_clicked", [council])

		add_label(council_vbox, "Council Priorities")
		for priority in council.priorities:
			add_label(council_vbox, priority.name)


func add_button(parent: Node, text: String, function_name: String, parameters: Array):
	var council_name = Button.new()
	council_name.connect("pressed", self, function_name, parameters)
	council_name.text = text
	parent.add_child(council_name)


func add_label(box_to_add_to: Container, text: String):
	var resource_label = Label.new()
	resource_label.text = text
	box_to_add_to.add_child(resource_label)


func _on_Town_clicked(town: Town):
	toggle_details_container(true)
	set_details_to_town(town)


func _on_Council_clicked(council: Council):
	toggle_details_container(true)
	set_details_to_council(council)


func _on_Council_growth_priority(council: Council):
	council.town.set_growth_priority(council)


func _on_Productivity_clicked(council: Council, level: String):
	council.set_productivity(level)


func _on_Council_Split_clicked(council: Council):
	# Pop up a confirmation dialog.
	get_node('/root/world/HUD').receive_message("Split this council?", [], false)


func _on_Close_pressed():
	toggle_details_container(false)
	if details_town:
		details_town.set_selected(false)
	details_town = null
	viewing = ''
