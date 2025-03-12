@tool
class_name RoommateBlocksArea
extends Node3D

@export var area_size := Vector3.ONE


func create_blocks(block_size: float) -> RoommateBlocksArea.Blocks:
	var start_space_position := position - area_size / 2
	var box := AABB(start_space_position, area_size)
	var start_block_position := (box.position / block_size).floor() as Vector3i
	var end_block_position := (box.end / block_size).ceil() as Vector3i
	
	var results := RoommateBlocksArea.Blocks.new()
	for x in range(start_block_position.x, end_block_position.x):
		for y in range(start_block_position.y, end_block_position.y):
			for z in range(start_block_position.z, end_block_position.z):
				var block := _create_block()
				assert(block)
				block.position = Vector3i(x, y, z)
				block.block_size = block_size
				results.add(block)
	return results


func _create_block() -> Block:
	assert(false, "Not Implemented")
	return null


class Block:
	extends RefCounted
	
	var position := Vector3i.ZERO
	var block_size := 1.0
	var parts := Dictionary()
	
	
	func generate_parts(target_material: Material, tool: SurfaceTool, blocks: RoommateBlocksArea.Blocks) -> bool: # virtual method
		return false
	
	
	func to_position(block_position: Vector3i) -> Vector3:
		return block_position * block_size + Vector3.ONE * block_size / 2


class Blocks:
	extends RefCounted

	var _blocks := Dictionary()


	func get_array() -> Array[RoommateBlocksArea.Block]:
		var result: Array[RoommateBlocksArea.Block] = []
		result.assign(_blocks.values())
		return result


	func add(new_block: RoommateBlocksArea.Block) -> void:
		_blocks[new_block.position] = new_block


	func merge(blocks: RoommateBlocksArea.Blocks) -> void:
		for new_block in blocks.get_array():
			_blocks[new_block.position] = new_block


	func generate_parts(tool: SurfaceTool, target_material: Material) -> bool:
		var _blocks_to_handle: Array[RoommateBlocksArea.Block] = []
		_blocks_to_handle.assign(_blocks.values())
		var any_parts_generated := false
		for block in _blocks_to_handle:
			var parts_generated := block.generate_parts(target_material, tool, self)
			if parts_generated:
				any_parts_generated = true
		return any_parts_generated


	func get_single(position: Vector3i) -> RoommateBlocksArea.Block:
		var result := _blocks.get(position) as RoommateBlocksArea.Block
		if result:
			return result
		return RoommateOutOfBounds.Block.new()
