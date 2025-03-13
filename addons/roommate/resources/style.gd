@tool
class_name RoommateStyle
extends Resource

@export var rulesets: Array[RoommateRuleset] = []


func apply(source_blocks: RoommateBlocksArea.Blocks) -> void:
	for ruleset in rulesets:
		if ruleset:
			ruleset.apply(source_blocks)


func get_all_materials() -> Array[Material]:
	var result: Array[Material] = []
	for ruleset in rulesets:
		if not ruleset:
			continue
		var ruleset_materials := ruleset.get_materials()
		for material in ruleset_materials:
			if material and not material in result:
				result.append(material)
	return result
