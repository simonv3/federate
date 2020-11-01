extends VBoxContainer

var current_council setget set_current_council


func set_current_council(val):
	current_council = val
	set_button_labels()


func set_button_labels():
	if current_council.output_multiplier == "low":
		$Toggles/High.text = 'high'
		$Toggles/Low.text = '(low)'
		$Toggles/Medium.text = 'medium'
	if current_council.output_multiplier == "medium":
		$Toggles/High.text = 'high'
		$Toggles/Low.text = 'low'
		$Toggles/Medium.text = '(medium)'
	if current_council.output_multiplier == "high":
		$Toggles/High.text = '(high)'
		$Toggles/Low.text = 'low'
		$Toggles/Medium.text = 'medium'


func _on_Low_pressed():
	current_council.set_productivity("low")
	set_button_labels()


func _on_Medium_pressed():
	current_council.set_productivity("medium")
	set_button_labels()


func _on_High_pressed():
	current_council.set_productivity("high")
	set_button_labels()
