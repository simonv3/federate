extends VBoxContainer

var council


func _ready():
	$CouncilName.text = council.council_name
	if council.town.is_player_town():
		$Control.show()
		if council.town.growth_priority == council:
			$Control/IsGrowthPriority.show()
			$Control/SetAsGrowthPriority.hide()
		else:
			$Control/IsGrowthPriority.hide()
			$Control/SetAsGrowthPriority.show()
			var view_details = Button.new()
			view_details.text = "Set as Growth Priority"
			view_details.connect("pressed", self, "_on_Council_growth_priority", [council])


func _on_SetAsGrowthPriority_pressed():
	council.town.set_growth_priority(council)


func _on_ViewDetails_pressed():
	get_node("/root/world/HUD/UI/Bottom/Panel/Details").emit_signal("open_council", council)
