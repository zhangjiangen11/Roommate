@tool
class_name RoommateEdgeBlocksSelector
extends RoommateBlocksSelector

enum Axis { X, Y, Z }

@export var axis := Axis.X
@export var positive := true


func select(selected_blocks: RoommateBlocksArea.Blocks, source_blocks: RoommateBlocksArea.Blocks) -> RoommateBlocksArea.Blocks:
	var result := RoommateBlocksArea.Blocks.new()
	
	var biggest_values := Vector3i.MIN
	var smallest_values := Vector3i.MAX
	for block in selected_blocks.get_array():
		biggest_values = biggest_values.max(block.position)
		smallest_values = smallest_values.min(block.position)
	
	for block in selected_blocks.get_array():
		match axis:
			Axis.X:
				if positive and block.position.x == biggest_values.x:
					result.add(block)
				if not positive and block.position.x == smallest_values.x:
					result.add(block)
			Axis.Y:
				if positive and block.position.y == biggest_values.y:
					result.add(block)
				if not positive and block.position.y == smallest_values.y:
					result.add(block)
			Axis.Z:
				if positive and block.position.z == biggest_values.z:
					result.add(block)
				if not positive and block.position.z == smallest_values.z:
					result.add(block)
	return result
