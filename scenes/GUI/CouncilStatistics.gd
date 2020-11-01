extends VBoxContainer

var current_council setget set_current_council


func set_current_council(val):
	current_council = val
#	if not current_council.is_connected("on_statistics_updated", self, "set_button_labels"):
#		current_council.connect("on_statistics_updated", self, "set_button_labels")
	set_button_labels()


func set_button_labels():
	var resource_multiplier = (
		current_council.output_multiplier
		if current_council.output_multiplier
		else 0.00
	)
	$Resources.text = "%s (%s)" % [current_council.resource, resource_multiplier]
	$Population.text = "Population: %s" % current_council.member_number
