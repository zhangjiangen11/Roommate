@tool
class_name RoommateRuleset
extends Resource

@export var selectors: Array[RoommateSelectorBase]
@export var part: RoommatePart


func apply_ruleset(source_blocks: RoommateAreaBase.Blocks) -> void:
	var selected_parts: Array[RoommatePart] = []
	for selector in selectors:
		if not selector:
			continue
		selected_parts.append_array(selector.get_parts(source_blocks))
	for selected_part in selected_parts:
		if not selected_part:
			continue
		selected_part.set_values(part)


func get_material() -> Material:
	if not part:
		return null
	return part.material
