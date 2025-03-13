@tool
class_name RoommateStyle
extends Resource

@export var rulesets: Array[RoommateRuleset] = []
@export var apply_priority := 0
var _current_rulesets: Array[RoommateRuleset] = []


func apply(source_blocks: RoommateBlocksArea.Blocks) -> void:
	_current_rulesets = rulesets
	if _current_rulesets.size() == 0:
		_build_rulesets()
	for ruleset in rulesets:
		if ruleset:
			ruleset.apply(source_blocks)


func get_all_materials() -> Array[Material]:
	var result: Array[Material] = []
	for ruleset in _current_rulesets:
		if not ruleset:
			continue
		var ruleset_materials := ruleset.get_materials()
		for material in ruleset_materials:
			if material and not material in result:
				result.append(material)
	return result


func _build_rulesets() -> void: # virtual function
	pass
