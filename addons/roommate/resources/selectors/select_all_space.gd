@tool
class_name RoommateSelectAllSpaceParts
extends RoommateSpaceSelectorBase


func get_parts(source_blocks: RoommateAreaBase.Blocks) -> Array[RoommatePart]:
	var result: Array[RoommatePart] = []
	var selected_part_positions := get_selected_part_positions()
	for block in source_blocks.get_array():
		for part_position in selected_part_positions:
			result.append(block.parts[part_position])
	return result
