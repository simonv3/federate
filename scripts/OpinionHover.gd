extends Control
var opinions = []

onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")


func set_content(label_opinions: Array):
	print("opinions", label_opinions)
	opinions = label_opinions
	$Container/Text.clear()
	var text = "[b]Opinion modifiers[/b]: \n\n"
	for opinion in opinions:
		text += "%s: %s\n" % [opinion["reason"], opinion["value"]]
	$Container/Text.bbcode_text = text


func _on_opinion_mouse_entered(label_opinions):
	set_content(label_opinions)
	var lines = $Container/Text.get_line_count()
	var height = $Container/Text.get_font("normal_font").get_height()
	var min_height = clamp(lines * height, 50, 200)

	var pos = get_viewport().get_mouse_position()
	$Container.set_position(Vector2(pos.x - 40, pos.y - 40))

	$Container.set_size(Vector2(200, min_height))

	self.show()


func _on_opinion_mouse_exited():
	self.hide()
