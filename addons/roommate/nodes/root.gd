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

@export_group("editor")
@export var test := 1


func generate_mesh() -> void:
	var nodes := find_children("*", _name_of(RoommateBlocksArea), true, false)
	var areas: Array[RoommateBlocksArea] = []
	areas.assign(nodes)
	areas.sort_custom(_sort_by_type)
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
		style.apply(all_blocks)
		all_materials.append_array(style.get_all_materials())
	
	var areas_with_style := areas.filter(_filter_by_style) as Array[RoommateBlocksArea]
	areas_with_style.sort_custom(_sort_by_style)
	for area in areas_with_style:
		var area_blocks := all_blocks.get_blocks(area.get_block_positions(block_size))
		area.style.apply(area_blocks)
	
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


func _sort_by_type(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	if a is RoommateOutOfBounds:
		return false
	return true


func _sort_by_style(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	return a.style.apply_priority < b.style.apply_priority


func _filter_by_style(a: RoommateBlocksArea) -> bool:
	return a.style != null


func _name_of(script: Script) -> StringName:
	return script.get_global_name()
