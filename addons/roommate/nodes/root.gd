@tool
class_name RoommateRoot
extends MeshInstance3D

@export var block_size := 1.0:
	get:
		return block_size
	set(value):
		block_size = value
		generate_mesh()

@export var style: RoommateStyle


func generate_mesh() -> void:
	var nodes := find_children("*", _name_of(RoommateBlocksArea), true, false)
	var areas: Array[RoommateBlocksArea] = []
	areas.assign(nodes)
	if areas.size() == 0:
		return
	
	var all_blocks := RoommateBlocksArea.Blocks.new()
	for area in areas:
		var area_blocks := area.create_blocks(block_size)
		all_blocks.merge(area_blocks)
	
	var all_materials: Array[Material] = [
		preload("../defaults/default_material.tres"),
	]
	if style:
		all_materials.append_array(style.get_all_materials())
		style.apply(all_blocks)
	
	var result := ArrayMesh.new()
	for target_material in all_materials:
		var tool := SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		var faces_created := all_blocks.generate_parts(tool, target_material)
		if not faces_created:
			continue
		tool.index()
		tool.generate_normals()
		tool.generate_tangents()
		var mesh_surface := tool.commit_to_arrays()
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_surface)
		var last_surface_id := result.get_surface_count() - 1
		result.surface_set_material(last_surface_id, target_material)
	mesh = result


func _name_of(script: Script) -> StringName:
	return script.get_global_name()
