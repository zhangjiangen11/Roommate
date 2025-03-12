@tool
class_name RoommateRuleset
extends Resource

@export var block_selectors: Array[RoommateBlocksSelector]
@export var part_selectors: Array[RoommatePartsSelector]
@export var setter: RoommatePart


func apply(source_blocks: RoommateBlocksArea.Blocks) -> void:
	var selected_blocks := source_blocks
	for selector in block_selectors:
		if not selector:
			continue
		selected_blocks = selector.select(selected_blocks, source_blocks)
	
	var source_parts: Array[RoommatePart] = []
	for block in selected_blocks.get_array():
		source_parts.append_array(block.parts.values())
	
	var selected_parts := source_parts
	for selector in part_selectors:
		if not selector:
			continue
		selected_parts = selector.select(selected_parts, source_parts)
	
	for part in selected_parts:
		part.set_values(setter)


func get_material() -> Material:
	if not setter:
		return null
	return setter.material
