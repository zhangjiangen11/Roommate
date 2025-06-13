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

@export var global_style: RoommateStyle = null

@export_group("Mesh")
@export var index_mesh := true
@export var generate_normals := true
@export var generate_tangents := true

@export_group("Collision")
@export var collision_shape := CollisionShape.CONCAVE
@export_node_path("CollisionShape3D") var linked_collision_shape: NodePath

@export_group("Scenes")
@export var scenes_group := &"roommate_generated_scenes"
@export var transform_scene_relative_to_part := true
@export var use_fallback_parent := true
@export var force_readable_scene_names := true

@export_group("Navigation")
@export_node_path("NavigationRegion3D") var linked_navigation_region: NodePath

var _blocks_area_apply_order: Array[Script] = [
	RoommateSpace, 
	RoommateOutOfBounds,
]
var _part_processors := {
	RoommateBlock.SPACE_TYPE: _process_space_block_part,
	RoommateBlock.OUT_OF_BOUNDS_TYPE: _process_skip_part,
	RoommateBlock.NONE_TYPE: _process_skip_part,
}

var _tools := {}
var _collision_faces := PackedVector3Array()
var _scene_infos: Array[SceneInfo] = []


func generate() -> void:
	var this_node := _resolve_self()
	
	# Searching for areas which are not children of other root nodes
	var child_areas := this_node.find_children("*", "RoommateBlocksArea")
	var child_roots := this_node.find_children("*", "RoommateRoot")

	var areas: Array[RoommateBlocksArea] = []
	areas.assign(child_areas.filter(_filter_by_parents.bind(child_roots)))
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
	
	# clearing
	_tools.clear()
	_collision_faces.clear()
	_scene_infos.clear()
	clear_scenes()
	
	# generating everything
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
	
	# applying mesh
	var result_mesh := ArrayMesh.new()
	for surface_material in _tools:
		var tool := _tools[surface_material] as SurfaceTool
		if index_mesh:
			tool.index()
		if generate_normals:
			tool.generate_normals()
		if generate_tangents:
			tool.generate_tangents()
		tool.commit(result_mesh)
		result_mesh.surface_set_material(result_mesh.get_surface_count() - 1, surface_material)
	mesh = result_mesh
	
	# applying collision
	var collision_shape_node := this_node.get_node_or_null(linked_collision_shape) as CollisionShape3D
	if collision_shape_node:
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
	
	#applying scenes
	for info in _scene_infos:
		var scene_parent := this_node.get_node_or_null(info.parent_path)
		var valid_parent := scene_parent and (this_node.is_ancestor_of(scene_parent) or this_node == scene_parent)
		if info.parent_path.is_empty():
			push_warning("Scene creation. Path is empty")
		elif not valid_parent:
			push_warning("Scene creation. There is no valid node on path %s" % info.parent_path)
		
		if info.parent_path.is_empty() or not valid_parent:
			if not use_fallback_parent:
				continue
			var fallback := this_node.get_node_or_null(^"./RoommateFallbackContainer")
			if not fallback:
				fallback = Node.new()
				fallback.name = "RoommateFallbackContainer"
				this_node.add_child(fallback)
				fallback.owner = this_node.owner
				fallback.add_to_group(scenes_group, true)
			scene_parent = fallback
		
		var new_scene := info.scene.instantiate()
		scene_parent.add_child(new_scene, force_readable_scene_names)
		new_scene.owner = this_node.owner
		new_scene.add_to_group(scenes_group, true)
		
		var node3d_scene := new_scene as Node3D
		if not node3d_scene:
			continue
		if transform_scene_relative_to_part:
			node3d_scene.global_transform = this_node.global_transform * info.scene_transform
		else:
			node3d_scene.transform = info.scene_transform
	
	# applying navigation
	var navigation_region := this_node.get_node_or_null(linked_navigation_region) as NavigationRegion3D
	if navigation_region:
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


func clear_scenes() -> void:
	var this_node := _resolve_self()
	var all_scenes := this_node.get_tree().get_nodes_in_group(scenes_group)
	var child_roots := this_node.find_children("*", "RoommateRoot")
	var filter_by_self := func (target: Node) -> bool:
		return this_node.is_ancestor_of(target)
	var scenes := all_scenes.filter(filter_by_self).filter(_filter_by_parents.bind(child_roots)) as Array[Node]
	for scene in scenes:
		scene.get_parent().remove_child(scene)
		scene.queue_free()


func _generate_part(part: RoommatePart, parent_block: RoommateBlock) -> void:
	if not part:
		return
	var part_origin := parent_block.position * block_size + block_size * part.anchor
	
	if part.collision_mesh:
		var part_collision_faces := part.collision_transform.translated(part_origin) * part.collision_mesh.get_faces()
		_collision_faces.append_array(part_collision_faces)
	
	if part.scene:
		var info := SceneInfo.new()
		info.scene = part.scene
		info.scene_transform = part.scene_transform.translated(part_origin)
		info.parent_path = part.scene_parent_path
		_scene_infos.append(info)
	
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
		surface_tool.append_from(part_mesh, 0, part.mesh_transform.translated(part_origin))


func _process_space_block_part(slot_id: StringName, part: RoommatePart, block: RoommateBlock, 
		all_blocks: Dictionary) -> RoommatePart:
	var adjacent_block := all_blocks.get(block.position + (part.direction as Vector3i)) as RoommateBlock
	if not RoommateBlock.in_bounds(adjacent_block) or part.direction == Vector3.ZERO:
		return part
	return null


func _process_skip_part(slot_id: StringName, part: RoommatePart, block: RoommateBlock, 
		all_blocks: Dictionary) -> RoommatePart:
	return null


func _resolve_self() -> RoommateRoot:
	if Engine.is_editor_hint():
		return EditorPlugin.new().get_editor_interface().get_edited_scene_root().get_node(get_path()) as RoommateRoot
	return self


func _sort_by_area_apply_order(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	var a_index := _blocks_area_apply_order.find(a.get_script())
	var b_index := _blocks_area_apply_order.find(b.get_script())
	return b_index > a_index


func _sort_by_style(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	return a.style.apply_order < b.style.apply_order


func _filter_by_style(target: RoommateBlocksArea) -> bool:
	return target.style != null


func _filter_by_parents(target: Node, parents: Array[Node]) -> bool:
	for parent in parents:
		if parent.is_ancestor_of(target):
			return false
	return true


class SceneInfo:
	extends RefCounted
	
	var scene: PackedScene
	var parent_path: NodePath
	var scene_transform: Transform3D
