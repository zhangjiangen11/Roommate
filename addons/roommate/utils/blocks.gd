@tool
class_name Blocks
extends RefCounted

var _blocks := Dictionary()


func add_array(new_blocks: Array[RoommateAreaBase.Block]) -> void:
	for new_block in new_blocks:
		if not _blocks.has(new_block.position):
			_blocks[new_block.position] = new_block
			continue
		var old_block := _blocks[new_block.position] as RoommateAreaBase.Block
		assert(old_block)
		old_block.geometry.merge(new_block.geometry, true)
		old_block.materials.merge(new_block.materials, true)


func generate_parts(tool: SurfaceTool, target_material: Material) -> bool:
	var _blocks_to_handle: Array[RoommateAreaBase.Block] = []
	_blocks_to_handle.assign(_blocks.values())
	var any_parts_generated := false
	for block in _blocks_to_handle:
		var parts_generated := block.generate_parts(target_material, tool, self)
		if parts_generated:
			any_parts_generated = true
	return any_parts_generated


func get_single(position: Vector3i) -> RoommateAreaBase.Block:
	var result := _blocks.get(position) as RoommateAreaBase.Block
	if result:
		return result
	return RoommateOutOfBounds.Block.new()
