@tool
class_name RoommateOutOfBounds
extends RoommateAreaBase


func _create_block() -> Block:
	var block := Block.new()
	return block


class Block:
	extends RoommateAreaBase.Block
