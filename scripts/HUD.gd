extends CanvasLayer
class_name HUD

var paused := false
var are_details_open = true
onready var actionable: CenterContainer = get_node("ActionableMessage")
onready var details_container: VBoxContainer = get_node("UI/Bottom/Panel/Details")
var details_town: Town
var details_council: Council

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_select") and paused:
		_pause_game(false)


func receive_message(message: String, possible_actions: Array):
	actionable.show()
	var content_label := ($ActionableMessage/MessageContainer/VBoxContainer/Message/MessageText as RichTextLabel)
	var buttons := ($ActionableMessage/MessageContainer/VBoxContainer/Buttons as VBoxContainer)
	content_label.text = message
	for action in possible_actions:
		var new_label = Button.new()
		new_label.add_to_group("action_buttons")
		new_label.connect("pressed", self, "_on_action_button_pressed", [action])
		new_label.text = action["message"]
		buttons.add_child(new_label)
	
	_pause_game(true)


func set_details_label(node_name, text):
	var node_to_add_to = details_container.get_node(node_name)
	add_label(node_to_add_to, text)
	

func clean_details(node_path):
	var children = details_container.get_node(node_path).get_children()
	for child in children:
		child.queue_free()


func open_details_for_town(town: Town):
	are_details_open = true
	set_details_to_town(town)


func toggle_details_container(should_open):
	are_details_open = should_open
	if should_open:
		details_container.get_parent().show()
	else:
		clean_details("Town")
		clean_details("Council")
		details_container.get_parent().hide()


func set_details_to_town(town: Town):
	if town and are_details_open:
		details_council = null
		details_town = town

		clean_details("Town")
		toggle_details_container(true)
		
		var town_vbox = details_container.get_node("Town")
		details_container.get_node("Council").hide()
		town_vbox.show()
		set_details_label("Town", "%s (Federation: %s)" % [town.town_name, town.federations[0].federation_name])
		
		var councils = HBoxContainer.new()
		town_vbox.add_child(councils)
	
		for council in town.councils:
			print('council %s %s' % [town.town_name, council])
			var council_name = Button.new()
			council_name.connect("pressed", self, "_on_Council_clicked", [council])
			council_name.text = council.council_name
			councils.add_child(council_name)
	
		var stats = HBoxContainer.new()
		town_vbox.add_child(stats)

		add_label(stats, "Food: %s" % details_town.town_resources.food)
		add_label(stats, "Population: %s" % details_town.population)			

func set_details_to_council(council: Council):
	if council:
		details_council = council
		clean_details("Council")
		set_details_label("Council", "Council %s" % council.council_name)
		var council_vbox = details_container.get_node("Council")
		details_container.get_node("Town").hide()
		council_vbox.show()
		var resource_multiplier = council.output_multiplier if council.output_multiplier else 0.00 
		add_label(council_vbox, "%s (%s)" % [council.resource, stepify(resource_multiplier, 0.01)])
		add_label(council_vbox, "Council Priorities")
		
		for priority in council.priorities:
			add_label(council_vbox, priority.name)
			
		
func add_label(box_to_add_to: Container, text: String):
	var resource_label = Label.new()
	resource_label.text = text
	box_to_add_to.add_child(resource_label)
	

func _pause_game(new_paused: bool):
	get_tree().paused = new_paused
	var label = ($UI/Top/TopGui/HBoxContainer/Counters/PausedLabel as Label)
	if new_paused:
		label.show()
	else:
		label.hide()
	# FIXME: This pause functionality would be better if we 
	# looked for an input_event or something similar on the town, or 
	# something similar
	yield(get_tree().create_timer(1), 'timeout')
	paused = new_paused


func _on_world_game_paused():
	_pause_game(true)
	

func _on_world_new_season_start(season: int):
	($UI/Top/TopGui/HBoxContainer/Counters/SeasonsLabel as Label).text = "%s seasons" % season
	# These two function just make sure that the Details
	# for either the council or the town are updated
	# on season changes. 
	# FIXME: The way of checking the visibility of
	# the town vs the council is probably bad form here because
	# it updates the state based on what's displayed,
	# rather than what the state is
	if details_container.get_node("Town").is_visible_in_tree():
		set_details_to_town(details_town)
	if details_container.get_node("Council").is_visible_in_tree():
		set_details_to_council(details_council)


func _on_action_button_pressed(action):
	var custom_func = action["function"]
	if custom_func.is_valid():
		custom_func.call_func(action["parameters"])
	_pause_game(false)
	actionable.hide()
	# FIXME: it might be better to unload the parent node here
	# in its entirety, rather than keeping it in the screen.
	for button in get_tree().get_nodes_in_group("action_buttons"):
		button.queue_free()


func _on_Close_panel_pressed():
	toggle_details_container(false)
	if details_town:
		details_town.set_selected(false)
	details_town = null
	
	
func _on_Council_clicked(council: Council):
	toggle_details_container(true)
	set_details_to_council(council)
	
