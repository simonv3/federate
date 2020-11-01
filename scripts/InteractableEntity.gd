extends Node2D
class_name InteractableEntity

signal statistics_updated

onready var OpinionHover = get_node("/root/world/HUD/OpinionHover")
onready var HUDDetails = get_node("/root/world/HUD/UI/Bottom/Panel/Details")


func _ready():
	get_node("/root/world").connect("new_season_start", self, "_on_world_new_season_start")


#func _process(_delta):
#	if are_details_open:
#		draw_self_in_HUD_details()


# This should probably be happening on _process, because otherwise user feedback
# isn't immediately reflected, but on _process it looks like buttons
# aren't clickable
func _on_world_new_season_start(_season):
	pass
