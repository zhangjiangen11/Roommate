@tool
class_name RoommateSpace
extends RoommateAreaBase

const PART_DEFINITIONS := {
	Vector3i.ZERO: Quaternion.IDENTITY,
	Vector3i.UP: Quaternion(Vector3.RIGHT, PI / 2),
	Vector3i.DOWN: Quaternion(Vector3.LEFT, PI / 2),
	Vector3i.LEFT: Quaternion(Vector3.UP, PI / 2),
	Vector3i.RIGHT: Quaternion(Vector3.DOWN, PI / 2),
	Vector3i.FORWARD: Quaternion.IDENTITY,
	Vector3i.BACK: Quaternion(Vector3.UP, PI),
}


func _create_block() -> RoommateAreaBase.Block:
	var block := Block.new()
	var default_part := preload("res://addons/roommate/defaults/default_part.tres") as RoommatePart
	for part_position in PART_DEFINITIONS:
		block.parts[part_position] = default_part.duplicate()
	var center_part := block.parts[Vector3i.ZERO] as RoommatePart
	center_part.skip = true
	return block


class Block:
	extends RoommateAreaBase.Block
	
	
	func generate_parts(target_material: Material, tool: SurfaceTool, blocks: RoommateAreaBase.Blocks) -> bool:
		var part_generated := false
		for part_position in PART_DEFINITIONS:
			var part_rotation := PART_DEFINITIONS[part_position] as Quaternion
			var part := parts.get(part_position) as RoommatePart
			if not part or part.skip or not part.mesh or part.material != target_material:
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
