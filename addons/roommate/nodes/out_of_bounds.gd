@tool
class_name RoommateOutOfBounds
extends RoommateAreaBase


func _create_block() -> RoommateAreaBase.Block:
	return Block.new()


class Block:
	extends RoommateAreaBase.Block
