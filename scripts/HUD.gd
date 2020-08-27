extends CanvasLayer
class_name HUD

var paused := false

onready var actionable: CenterContainer = get_node("ActionableMessage")
onready var details_container: VBoxContainer = get_node("UI/Bottom/Panel/Details")


func _process(_delta: float):
	if Input.is_action_just_pressed("ui_select") and paused:
		_pause_game(false)


func receive_message(message: String, possible_actions: Array):
	actionable.show()
	var content_label := $ActionableMessage/MessageContainer/VBoxContainer/Message/MessageText
	var buttons := $ActionableMessage/MessageContainer/VBoxContainer/Buttons
	content_label.text = message
	for action in possible_actions:
		var new_label = Button.new()
		new_label.add_to_group("action_buttons")
		new_label.connect("pressed", self, "_on_action_button_pressed", [action])
		new_label.text = action["message"]
		buttons.add_child(new_label)

	_pause_game(true)


func _pause_game(new_paused: bool):
	get_tree().paused = new_paused
	var label = $UI/Top/TopGui/HBoxContainer/Counters/PausedLabel as Label
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
