@tool
class_name RoommateBlocksSelector
extends Resource


func select(selected_blocks: RoommateBlocksArea.Blocks, source_blocks: RoommateBlocksArea.Blocks) -> RoommateBlocksArea.Blocks:
	var blocks := RoommateBlocksArea.Blocks.new()
	blocks.merge(selected_blocks)
	return blocks
