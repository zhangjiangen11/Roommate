@tool
class_name RoommateOutOfBounds
extends RoommateBlocksArea


func _create_block() -> RoommateBlocksArea.Block:
	return Block.new()


class Block:
	extends RoommateBlocksArea.Block
