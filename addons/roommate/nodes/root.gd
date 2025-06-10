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

enum CollisionShape 
{ 
	CONCAVE, 
	CONVEX, 
}

@export var block_size := 1.0:
	set(value):
		block_size = value
		for node in find_children("*", "RoommateBlocksArea"):
			var area := node as RoommateBlocksArea
			area.update_gizmos()
@export var scale_with_block_size := true
@export var force_white_vertex_color := true

@export var global_style: RoommateStyle

@export_group("Mesh")
@export var index_mesh := true
@export var generate_normals := true
@export var generate_tangents := true

@export_group("Collision")
@export var collision_shape := CollisionShape.CONCAVE
@export_node_path("CollisionShape3D") var linked_collision_shape: NodePath

@export_group("Navigation")
@export_node_path("NavigationRegion3D") var linked_navigation_region: NodePath

var _blocks_area_apply_order: Array[Script] = [
	RoommateSpace, 
	RoommateOutOfBounds,
]
var _part_processors := {
	&"btid_space": _process_space_block_part,
	&"btid_out_of_bounds": _process_skip_part,
	&"btid_none": _process_skip_part,
}
var _tools := {}
var _collision_faces := PackedVector3Array()


func generate_mesh(generate_collision := false, generate_navigation := false) -> void:
	# Searching for areas which are not children of other root nodes
	var child_areas := find_children("*", "RoommateBlocksArea")
	var child_roots := find_children("*", "RoommateRoot")
	var filter_areas := func (area: Node) -> bool:
		for root in child_roots:
			if root.is_ancestor_of(area):
				return false
		return true
	
	var areas: Array[RoommateBlocksArea] = []
	areas.assign(child_areas.filter(filter_areas))
	areas.sort_custom(_sort_by_area_apply_order)
	if child_roots.size() > 0:
		push_warning("RoommateRoot has other RoommateRoots as a children. " + 
				"Their BlocksAreas are ignored.")
	if areas.size() == 0:
		push_warning("RoommateRoot doesnt own any blocks areas.")
		return
	
	# Creating all the blocks that defined by areas and applying styles
	var all_blocks := {}
	for area in areas:
		var area_blocks := area.create_blocks(global_transform, block_size)
		all_blocks.merge(area_blocks, true)
	
	# Applying internal style
	var internal_style := preload("../resources/internal_style.gd").new()
	if scale_with_block_size:
		internal_style.scale = Vector3.ONE * block_size
	internal_style.force_white_vertex_color = force_white_vertex_color
	internal_style.apply(all_blocks)
	
	# Applying global style
	if global_style:
		global_style.apply(all_blocks)
	
	# Applying area styles
	var areas_with_style := areas.filter(_filter_by_style) as Array[RoommateBlocksArea]
	areas_with_style.sort_custom(_sort_by_style)
	for area in areas_with_style:
		var area_blocks := {}
		for area_block_position in area.get_block_positions(global_transform, block_size):
			var area_block := all_blocks.get(area_block_position) as RoommateBlock
			if area_block:
				area_blocks[area_block_position] = area_block
		area.style.apply(area_blocks)
	
	# generating mesh
	var result := ArrayMesh.new()
	_tools.clear()
	_collision_faces.clear()
	for block_position in all_blocks:
		var block := all_blocks[block_position] as RoommateBlock
		if not _part_processors.has(block.type_id):
			push_error("Unknown block type: %s." % block.type_id)
			continue
		var processor := _part_processors[block.type_id] as Callable
		for slot_id in block.slots:
			var part := block.slots[slot_id] as RoommatePart
			var processed_part := processor.call(slot_id, part, block, all_blocks) as RoommatePart
			if processed_part:
				_generate_part(processed_part, block)
	
	# stitching it all together
	for surface_material in _tools:
		var tool := _tools[surface_material] as SurfaceTool
		if index_mesh:
			tool.index()
		if generate_normals:
			tool.generate_normals()
		if generate_tangents:
			tool.generate_tangents()
		tool.commit(result)
		result.surface_set_material(result.get_surface_count() - 1, surface_material)
	mesh = result
	
	# preparing for other actions
	var this_node: Node = self
	if Engine.is_editor_hint():
		this_node = EditorPlugin.new().get_editor_interface().get_edited_scene_root().get_node(get_path())
	
	# applying collision
	var collision_shape_node := this_node.get_node_or_null(linked_collision_shape) as CollisionShape3D
	if generate_collision and collision_shape_node:
		var shape: Shape3D
		match collision_shape:
			CollisionShape.CONCAVE:
				var concave := ConcavePolygonShape3D.new()
				concave.set_faces(_collision_faces)
				collision_shape_node.shape = concave
			CollisionShape.CONVEX:
				var convex := ConvexPolygonShape3D.new()
				convex.points = _collision_faces.duplicate()
				collision_shape_node.shape = convex
			_:
				push_error("Unknown collision shape %s." % collision_shape)
	
	# applying navigation
	var navigation_region := this_node.get_node_or_null(linked_navigation_region) as NavigationRegion3D
	if generate_navigation and navigation_region:
		navigation_region.bake_navigation_mesh()


func register_block_type_id(block_type_id: StringName, part_processor: Callable) -> void:
	if _part_processors.has(block_type_id):
		push_error("Block type %s already registered." % block_type_id)
		return
	_part_processors[block_type_id] = part_processor


func register_blocks_area(block_area_script: Script, insert_before_block_area_script: Script) -> void:
	if not block_area_script:
		push_error("Blocks area script is null.")
		return
	if _blocks_area_apply_order.has(block_area_script):
		push_error("Blocks area %s already registered." % block_area_script)
		return
	var insert_index := _blocks_area_apply_order.find(insert_before_block_area_script)
	if insert_index < 0:
		insert_index = _blocks_area_apply_order.size()
	_blocks_area_apply_order.insert(insert_index, block_area_script)


func _generate_part(part: RoommatePart, parent_block: RoommateBlock) -> void:
	if not part:
		return
	
	var part_origin := parent_block.position * block_size + block_size * part.anchor
	if part.collision_mesh:
		var part_collision_faces := part.collision_transform.translated(part_origin) * part.collision_mesh.get_faces()
		_collision_faces.append_array(part_collision_faces)
	
	if not part.mesh:
		return
	for surface_id in part.mesh.get_surface_count():
		var part_surface_override := part.resolve_surface_override_with_fallback(surface_id)
		
		# modifying mesh
		var part_mesh := ArrayMesh.new()
		var mesh_arrays := part.mesh.surface_get_arrays(surface_id)
		if part_surface_override.flip_faces:
			if mesh_arrays[Mesh.ARRAY_INDEX] and mesh_arrays[Mesh.ARRAY_INDEX].size() > 0:
				mesh_arrays[Mesh.ARRAY_INDEX].reverse()
			else:
				push_warning("Cant flip faces. Mesh array doesnt have indexes.")
		part_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
		var mesh_data_tool := MeshDataTool.new()
		var create_error := mesh_data_tool.create_from_surface(part_mesh, 0)
		assert(create_error == OK)
		
		for vertex_id in mesh_data_tool.get_vertex_count():
			var uv := mesh_data_tool.get_vertex_uv(vertex_id)
			mesh_data_tool.set_vertex_uv(vertex_id, part_surface_override.uv_transform * uv)
			var color := mesh_data_tool.get_vertex_color(vertex_id)
			mesh_data_tool.set_vertex_color(vertex_id, color.lerp(part_surface_override.color, part_surface_override.color_weight))
		
		part_mesh.clear_surfaces()
		var commit_error := mesh_data_tool.commit_to_surface(part_mesh)
		assert(commit_error == OK)
		
		# appending surfaces
		var part_material := part.mesh.surface_get_material(surface_id)
		if part_surface_override.material:
			part_material = part_surface_override.material
			
		if not _tools.has(part_material):
			var new_surface_tool := SurfaceTool.new()
			new_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			new_surface_tool.set_material(part_material)
			_tools[part_material] = new_surface_tool
		var surface_tool := _tools[part_material] as SurfaceTool
		surface_tool.append_from(part_mesh, 0, part.transform.translated(part_origin))


func _process_space_block_part(slot_id: StringName, part: RoommatePart, block: RoommateBlock, 
		all_blocks: Dictionary) -> RoommatePart:
	var adjacent_block := all_blocks.get(block.position + (part.direction as Vector3i)) as RoommateBlock
	if not adjacent_block or adjacent_block.type_id == &"btid_out_of_bounds" or part.direction == Vector3.ZERO:
		return part
	return null


func _process_skip_part(slot_id: StringName, part: RoommatePart, block: RoommateBlock, 
		all_blocks: Dictionary) -> RoommatePart:
	return null


func _sort_by_area_apply_order(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	var a_index := _blocks_area_apply_order.find(a.get_script())
	var b_index := _blocks_area_apply_order.find(b.get_script())
	return b_index > a_index


func _sort_by_style(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	return a.style.apply_order < b.style.apply_order


func _filter_by_style(a: RoommateBlocksArea) -> bool:
	return a.style != null
