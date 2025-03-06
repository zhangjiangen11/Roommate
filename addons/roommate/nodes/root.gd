@tool
class_name RoommateRoot
extends MeshInstance3D

@export var block_size := 1.0:
	get:
		return block_size
	set(value):
		block_size = value
		generate_mesh()


func generate_mesh() -> void:
	var nodes := find_children("*", _name_of(RoommateAreaBase), true, false)
	var areas: Array[RoommateAreaBase] = []
	areas.assign(nodes)
	areas.sort_custom(_sort_by_priority)
	if areas.size() == 0:
		return
	
	var blocks := Blocks.new()
	for area in areas:
		var area_blocks := area.get_blocks(block_size)
		blocks.add_array(area_blocks)
	
	var global_mat := [
		RoommateAreaBase.Block.DEFAULT_MATERIAL,
		preload("res://test/floor_material.tres"),
		preload("res://test/wall_material.tres"),
	]
	var result := ArrayMesh.new()
	for target_material in global_mat:
		var tool := SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		var faces_created := blocks.generate_parts(tool, target_material)
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


func _sort_by_priority(a: RoommateAreaBase, b: RoommateAreaBase) -> bool:
	return a.space_priority > b.space_priority


func _name_of(script: Script) -> StringName:
	return script.get_global_name()
