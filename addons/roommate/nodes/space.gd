@tool
class_name RoommateSpace
extends RoommateBlocksArea

const PART_DEFINITIONS := {
	Vector3i.ZERO: Quaternion.IDENTITY,
	Vector3i.UP: Quaternion(Vector3.RIGHT, PI / 2),
	Vector3i.DOWN: Quaternion(Vector3.LEFT, PI / 2),
	Vector3i.LEFT: Quaternion(Vector3.UP, PI / 2),
	Vector3i.RIGHT: Quaternion(Vector3.DOWN, PI / 2),
	Vector3i.FORWARD: Quaternion.IDENTITY,
	Vector3i.BACK: Quaternion(Vector3.UP, PI),
}


func _create_block() -> RoommateBlocksArea.Block:
	var block := Block.new()
	var default_part := RoommateSpacePart.new()
	default_part.action = RoommatePart.Action.INCLUDE
	default_part.mesh = QuadMesh.new()
	default_part.material = preload("../defaults/default_material.tres") as Material
	for part_position in PART_DEFINITIONS:
		var part_duplicate := default_part.duplicate() as RoommateSpacePart
		part_duplicate.part_position = part_position
		block.parts[part_position] = part_duplicate
	var center_part := block.parts[Vector3i.ZERO] as RoommateSpacePart
	center_part.action = RoommatePart.Action.SKIP
	return block


class Block:
	extends RoommateBlocksArea.Block
	
	
	func generate_parts(target_material: Material, tool: SurfaceTool, blocks: RoommateBlocksArea.Blocks) -> bool:
		var part_generated := false
		for part_position in PART_DEFINITIONS:
			var part_rotation := PART_DEFINITIONS[part_position] as Quaternion
			var part := parts.get(part_position) as RoommateSpacePart
			if not part or part.action == RoommatePart.Action.SKIP or not part.mesh or part.material != target_material:
				continue
			
			var next_block := blocks.get_single(position + part_position)
			if part_position != Vector3i.ZERO and next_block is RoommateSpace.Block:
				continue
			
			if next_block is RoommateOutOfBounds.Block or part_position == Vector3i.ZERO:
				var origin: Vector3 = to_position(position) + part_position * block_size / 2
				var part_transform := Transform3D(Basis(part_rotation), origin).scaled_local(Vector3.ONE * block_size)
				tool.append_from(part.mesh, 0, part_transform)
				part_generated = true
		return part_generated
