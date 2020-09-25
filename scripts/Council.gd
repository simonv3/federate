extends Node
class_name Council

signal produce_resource

export var council_name := ''
export var member_number := 0 setget set_member_number
export var output_multiplier := "medium"
export var member_minimum := 0

var resource_multiplier_map = {
	"food": {"low": 0.05, "medium": 0.10, "high": 0.15},
	"stone": {"low": 0.01, "medium": 0.03, "high": 0.05}
}

var town

var resource: String
var priorities := []
var relationships := []

var resource_quantity


func _init(
	new_council_name: String,
	new_resource: String,
	new_council_amount: int,
	new_priorities: Array,
	new_town
) -> void:
	council_name = new_council_name
	resource = new_resource
	member_number = new_council_amount
	priorities = new_priorities
	town = new_town


func _on_town_inform_councils(season: int) -> void:
	if season % 4 == 0:
		resource_quantity = resource_multiplier_map[resource][output_multiplier] * member_number
		emit_signal("produce_resource", resource, resource_quantity)


func set_member_number(new_number: int):
	member_number = new_number


func set_productivity(level: String):
	if level in ["low", "medium", "high"]:
		output_multiplier = level


func calculate_opinion_of(type: String, OpiningAbout):
	var opinion = []

	if type == 'federation':
		if self.town.is_in_federation(OpiningAbout):
			opinion.push_back({"value": 10, "reason": "Same federation"})
	var opinion_sum = 0
	for item in opinion:
		opinion_sum += item["value"]
	return opinion_sum
