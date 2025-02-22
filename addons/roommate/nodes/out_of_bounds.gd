@tool
class_name RoommateOutOfBounds
extends RoommateAreaBase


func _create_block() -> Block:
	return Block.new()


class Block:
	extends RoommateAreaBase.Block
