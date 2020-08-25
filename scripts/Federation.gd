#extends Node
class_name Federation

export var is_feudal := false
export var federation_name: String


func _init(new_federation_name: String) -> void:
	federation_name = new_federation_name
