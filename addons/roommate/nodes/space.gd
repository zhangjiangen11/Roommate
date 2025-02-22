@tool
class_name RoommateSpace
extends RoommateAreaBase

@export_group("Skip")
@export var skip_ceil := false
@export var skip_floor := false
@export var skip_forward_wall := false
@export var skip_back_wall := false
@export var skip_left_wall := false
@export var skip_right_wall := false


func _create_block() -> Block:
	var block := Block.new()
	if skip_ceil:
		block.geometry[Vector3i.UP] = null
	if skip_floor:
		block.geometry[Vector3i.DOWN] = null
	if skip_left_wall:
		block.geometry[Vector3i.LEFT] = null
	if skip_right_wall:
		block.geometry[Vector3i.RIGHT] = null
	if skip_forward_wall:
		block.geometry[Vector3i.FORWARD] = null
	if skip_back_wall:
		block.geometry[Vector3i.BACK] = null
	return block


class Block:
	extends RoommateAreaBase.Block
	
	
	func handle(target_material: Material, tool: SurfaceTool, blocks: Blocks) -> bool:
		var faces_created := false
		for face in FACES:
			if geometry.has(face) and not geometry[face]:
				continue
			
			var next_block := blocks.get_single(position + face)
			if next_block is RoommateSpace.Block:
				continue
			
			var face_material: Material = materials.get(face, DEFAULT_MATERIAL)
			if target_material != face_material:
				continue
			
			if next_block is RoommateOutOfBounds.Block:
				var origin: Vector3 = to_position(position) + face * block_size / 2
				var face_transform := Transform3D(Basis(ROTATIONS[face]), origin).scaled_local(Vector3.ONE * block_size)
				var face_mesh := geometry.get(face, QuadMesh.new())
				tool.append_from(face_mesh, 0, face_transform)
				faces_created = true
		return faces_created
