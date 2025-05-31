# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateRoot
extends MeshInstance3D

@export var block_size := 1.0:
	get:
		return block_size
	set(value):
		block_size = value
		generate_mesh()

@export var global_style: RoommateStyle

@export_group("Editor")
@export_node_path("CollisionShape3D") var linked_collision_shape: NodePath

var _tools := {}
var _collision_faces := PackedVector3Array()


func generate_mesh() -> void:
	# Searching for areas
	var nodes := find_children("*", "RoommateBlocksArea", true, false)
	var areas: Array[RoommateBlocksArea] = []
	areas.assign(nodes)
	areas.sort_custom(_sort_by_type)
	if areas.size() == 0:
		return
	
	# Creating all the blocks that defined by areas and applying styles
	var all_blocks := {}
	for area in areas:
		var area_blocks := area.create_blocks(block_size)
		all_blocks.merge(area_blocks, true)
	
	# Applying global style
	if global_style:
		global_style.apply(all_blocks)
	
	# Applying per area style
	var areas_with_style := areas.filter(_filter_by_style) as Array[RoommateBlocksArea]
	areas_with_style.sort_custom(_sort_by_style)
	for area in areas_with_style:
		var area_blocks := {}
		for area_block_position in area.get_block_positions(block_size):
			area_blocks[area_block_position] = all_blocks[area_block_position]
		area.style.apply(area_blocks)
	
	# generating mesh
	var result := ArrayMesh.new()
	_tools.clear()
	_collision_faces.clear()
	for block_position in all_blocks:
		var block := all_blocks[block_position] as RoommateBlock
		match block.block_type_id:
			&"btid_space":
				_generate_space_block(block, all_blocks)
			_:
				push_error("Unknown block type: %s" % block.block_type_id)
				return
	
	# stitching it all together
	for surface_material in _tools:
		var tool := _tools[surface_material] as SurfaceTool
		tool.index()
		tool.generate_normals()
		tool.generate_tangents()
		var mesh_surface := tool.commit_to_arrays()
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_surface)
		result.surface_set_material(result.get_surface_count() - 1, surface_material)
	mesh = result
	
	# other actions
	var this_node: Node = self
	if Engine.is_editor_hint():
		this_node = EditorPlugin.new().get_editor_interface().get_edited_scene_root().get_node(get_path())
	var collision_shape := this_node.get_node_or_null(linked_collision_shape) as CollisionShape3D
	if collision_shape:
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(_collision_faces)
		collision_shape.shape = shape


func _generate_space_block(block: RoommateBlock, all_blocks: Dictionary) -> void:
	for slot_id in block.slots:
		var part := block.slots.get(slot_id) as RoommatePart
		var direction := RoommateBlock.SLOT_DIRECTIONS.get(slot_id, Vector3i.ZERO) as Vector3i
		var adjacent_block := all_blocks.get(block.block_position + direction) as RoommateBlock
		if not adjacent_block or adjacent_block.block_type_id == &"btid_out_of_bounds" or direction == Vector3i.ZERO:
			_generate_part(part, block)


func _generate_part(part: RoommatePart, parent_block: RoommateBlock) -> void:
	if not part or not part.mesh:
		return
	
	var origin := _to_position(parent_block.block_position) + block_size * part.anchor
	if part.collision_mesh:
		var part_collision_faces := part.get_collision_transform(origin) * part.collision_mesh.get_faces()
		_collision_faces.append_array(part_collision_faces)
	
	for surface_id in part.mesh.get_surface_count():
		var part_material_override := part.material_overrides.get(surface_id) as RoommatePart.MaterialOverride
		
		# modifying uv
		var part_mesh := ArrayMesh.new()
		part_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, part.mesh.surface_get_arrays(surface_id))
		var mesh_data_tool := MeshDataTool.new()
		var create_error := mesh_data_tool.create_from_surface(part_mesh, 0)
		assert(create_error == OK)
		
		part.material_overrides.get(surface_id)
		for vertex_id in mesh_data_tool.get_vertex_count():
			var uv := mesh_data_tool.get_vertex_uv(vertex_id)
			if part_material_override:
				mesh_data_tool.set_vertex_uv(vertex_id, part_material_override.get_uv_transform() * uv)
		
		part_mesh.clear_surfaces()
		var commit_error := mesh_data_tool.commit_to_surface(part_mesh)
		assert(commit_error == OK)
		
		# appending surface
		var part_material := part.mesh.surface_get_material(surface_id)
		if part_material_override and part_material_override.material:
			part_material = part_material_override.material
			
		if not _tools.has(part_material):
			var new_surface_tool := SurfaceTool.new()
			new_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			new_surface_tool.set_material(part_material)
			_tools[part_material] = new_surface_tool
		var surface_tool := _tools.get(part_material) as SurfaceTool
		surface_tool.append_from(part_mesh, 0, part.get_transform(origin))


func _to_position(block_position: Vector3i) -> Vector3:
		return block_position * block_size


func _sort_by_type(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	if a is RoommateOutOfBounds:
		return false
	return true


func _sort_by_style(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	return a.style.apply_order < b.style.apply_order


func _filter_by_style(a: RoommateBlocksArea) -> bool:
	return a.style != null
