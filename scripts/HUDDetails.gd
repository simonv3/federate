extends VBoxContainer

signal open_town
signal open_council


func _on_Close_pressed():
	get_parent().hide()
	close_everything()


func close_everything():
	for town in get_node("/root/world").towns:
		town.are_details_open = false
		for council in town.councils:
			council.are_details_open = false


func _on_open_town(town):
	$Content/CouncilDetails.hide()
	$Content/TownDetails.emit_signal("open_with_town", town)
	get_node("/root/world/HUD").emit_signal("open_details")


func _on_open_council(council):
	$Content/TownDetails.hide()
	$Content/CouncilDetails.emit_signal("open_with_council", council)
	get_node("/root/world/HUD").emit_signal("open_details")
