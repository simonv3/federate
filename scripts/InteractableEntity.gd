extends Node2D
class_name InteractableEntity

#var OpinionHover = preload("res://scenes/OpinionHover.tscn")
onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")
onready var HUDDetails = get_node("/root/world/HUD/UI/Bottom/Panel/Details")
var are_details_open = false


func _ready():
	get_node("/root/world").connect("new_season_start", self, "_on_world_new_season_start")


# This should probably be happening on _process, because otherwise user feedback
# isn't immediately reflected, but on _process it looks like buttons
# aren't clickable
func _on_world_new_season_start(_season):
	if are_details_open:
		draw_self_in_HUD_details()


func draw_self_in_HUD_details():
	pass


func add_button(parent: Node, text: String, function_name: String, parameters: Array):
	var button_name = Button.new()
	button_name.connect("pressed", self, function_name, parameters)
	button_name.text = text
	parent.add_child(button_name)


func add_label(box_to_add_to: Container, text: String):
	var resource_label = Label.new()
	resource_label.set_text(text)
	box_to_add_to.add_child(resource_label)


func add_opinion_hover(box_to_add_to: Container, text: String, opinion: Array):
	var resource_label = Label.new()
	resource_label.connect("mouse_entered", OpinionHover, "_on_opinion_mouse_entered", [opinion])
	resource_label.connect("mouse_exited", OpinionHover, "_on_opinion_mouse_exited")
	resource_label.text = text
	resource_label.mouse_filter = Control.MOUSE_FILTER_STOP
	box_to_add_to.add_child(resource_label)


func clean_details():
	var children = HUDDetails.get_node("Content").get_children()
	for child in children:
		child.queue_free()


func toggle_to_show(showing: String, title: String) -> VBoxContainer:
	clean_details()
	are_details_open = true

	var vbox = HUDDetails.get_node('Content')
	HUDDetails.get_parent().show()
	add_label(vbox, title)

	vbox.show()
	return vbox


func _on_Town_clicked(town: InteractableEntity):
	HUDDetails.close_everything()
	town.draw_self_in_HUD_details()


func _on_Council_clicked(council: InteractableEntity):
	HUDDetails.close_everything()
	council.draw_self_in_HUD_details()
