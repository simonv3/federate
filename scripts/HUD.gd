extends CanvasLayer
class_name HUD

var paused := false

onready var details_container: VBoxContainer = get_node("UI/Bottom/Panel/Details")


func _process(_delta: float):
	if Input.is_action_just_pressed("ui_select") and paused:
		_pause_game(false)


func receive_message(message: String, possible_actions: Array, pause_game = true):
	var actionable: WindowDialog = get_node("Actionable")

	var margin = actionable.get_child(1).get_child(0)

	var hbox = VBoxContainer.new()
	margin.add_child(hbox)

	var label := Label.new()
	label.text = message
	hbox.add_child(label)

	actionable.popup_centered()

	for action in possible_actions:
		var button := Button.new()
		button.add_to_group("action_buttons")
		button.connect("pressed", self, "_on_action_button_pressed", [action])
		button.text = action["label"]
		hbox.add_child(button)

	_pause_game(pause_game)


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
	var custom_func = action["func_ref"]

	if custom_func.is_valid():
		custom_func.call_funcv(action["parameters"])
		var actionable: WindowDialog = get_node("Actionable")
		actionable.visible = false
	_pause_game(false)
