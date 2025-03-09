@tool
class_name RoommateStyle
extends Resource

@export var rulesets: Array[RoommateRuleset] = []


func apply_style(source_blocks: RoommateAreaBase.Blocks) -> void:
	for ruleset in rulesets:
		if ruleset:
			ruleset.apply_ruleset(source_blocks)


func get_all_materials() -> Array[Material]:
	var result: Array[Material] = []
	for ruleset in rulesets:
		var material := ruleset.get_material()
		if material and not result.has(material):
			result.append(material)
	return result
