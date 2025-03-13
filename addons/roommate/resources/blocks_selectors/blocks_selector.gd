@tool
class_name RoommateBlocksSelector
extends Resource


func select(source_blocks: RoommateBlocksArea.Blocks) -> RoommateBlocksArea.Blocks:
	var blocks := RoommateBlocksArea.Blocks.new()
	blocks.merge(source_blocks)
	return blocks
