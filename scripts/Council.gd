extends InteractableEntity
class_name Council

signal produce_resource
signal on_resources_updated
signal on_statistics_updated

export var council_name := ''
export var member_number := 0 setget set_member_number
export var output_multiplier := "medium"
export var member_minimum := 0

var resource_multiplier_map = {
	"food": {"low": 0.1, "medium": 0.15, "high": 0.25},
	"stone": {"low": 0.5, "medium": 0.1, "high": 0.13}
}

var town

var resource: String
var priorities := []
var relationships := []

var resource_quantity


func _on_town_inform_councils(season: int) -> void:
	if season % 4 == 0:
		resource_quantity = resource_multiplier_map[resource][output_multiplier] * member_number
		emit_signal("produce_resource", resource, resource_quantity)
		emit_signal("on_statistics_updated")


func set_member_number(new_number: int):
	emit_signal("on_statistics_updated")
	member_number = new_number


func set_productivity(level: String):
	if level in ["low", "medium", "high"]:
		output_multiplier = level
		emit_signal("on_statistics_updated")


func calculate_opinion_of(type: String, opining_about):
	var opinion = []

	if type == 'federation':
		if self.town.is_in_federation(opining_about):
			opinion.push_back({"value": 10, "reason": "Same federation"})
		if has_envoy_from(opining_about):
			opinion.push_back({"value": 10, "reason": "Has envoy"})

		for priority in self.priorities:
			for town in get_node("/root/world").towns:
				if town.is_in_federation(opining_about):
					for council in town.councils:
						for council_priority in council.priorities:
							if council_priority["name"] == priority["name"]:
								opinion.push_back(
									{"value": 2, "reason": "Both value %s" % [priority["name"]]}
								)

	var opinion_sum = 0
	for item in opinion:
		opinion_sum += item["value"]
	return [opinion_sum, opinion]


func has_envoy_from(federation):
	var found = false
	for relationship in relationships:
		if relationship.source == federation:
			found = relationship
	return found


func _send_federation_envoy(envoy_of_federation):
	var world = get_node('/root/world')
	relationships.push_back(
		{
			"type": "has_federation_envoy",
			"readable": "Envoy (%s)" % [envoy_of_federation.federation_name],
			"created_at": world.months,
			"source": envoy_of_federation
		}
	)
	emit_signal("on_statistics_updated")


func _split_council(new_council_type: String, council: Council):
	council.member_number -= 5
	council.town.create_council(
		get_node('/root/world').resources[new_council_type], new_council_type, 5, council.priorities
	)
	emit_signal("on_statistics_updated")
