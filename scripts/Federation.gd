extends Node2D
class_name Federation

export var is_feudal := false
export var federation_name: String


func _ready():
	get_node("/root/world").connect("new_season_start", self, "_on_world_new_season_start")
