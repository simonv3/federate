extends VBoxContainer


func _on_Close_pressed():
	get_parent().hide()
	close_everything()


func close_everything():
	for town in get_node("/root/world").towns:
		town.are_details_open = false
		for council in town.councils:
			council.are_details_open = false
