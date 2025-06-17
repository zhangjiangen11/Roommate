# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends EditorNode3DGizmoPlugin

const MIN_AREA_SIZE := 0.002

var handles_3d_size: float = 0.0
var _handle_infos: Array[HandleInfo] = [
	HandleInfo.new(Vector3.UP),
	HandleInfo.new(Vector3.DOWN),
	HandleInfo.new(Vector3.LEFT),
	HandleInfo.new(Vector3.RIGHT),
	HandleInfo.new(Vector3.FORWARD),
	HandleInfo.new(Vector3.BACK),
]
var _original_area_transform: Variant = null
var _original_area_global_transform: Variant = null
var _original_area_size: Variant = null


func _init() -> void:
	var version := Engine.get_version_info()
	if version["major"] == 4 and version["minor"] == 0:
		handles_3d_size = 0.1
	_handle_infos.make_read_only()
	create_material("area", Color.AQUA)
	create_material("blocks", Color.GREEN)
	create_material("handles_3d", Color.YELLOW, false, true)
	create_handle_material("handles")


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RoommateBlocksArea


func _get_gizmo_name() -> String:
	return "Roommate"


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	var root := _get_root(area)
	var area_selected := EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes().has(area)
	
	# area
	gizmo.add_lines(_get_aabb_lines(area.box), get_material("area", gizmo))
	
	# blocks range
	if root:
		var blocks_box := area.get_blocks_range(root.global_transform, root.block_size)
		blocks_box.size *= root.block_size
		blocks_box.position *= root.block_size
		var blocks_box_lines := area.global_transform.affine_inverse() * (root.global_transform * _get_aabb_lines(blocks_box))
		gizmo.add_lines(blocks_box_lines, get_material("blocks", gizmo))
	
	if not area_selected:
		return
	
	# handles
	var info_to_point := func (handle: HandleInfo) -> Vector3: 
		return handle.get_position(area.box)
	var handles_positions := _handle_infos.map(info_to_point)
	if handles_3d_size > 0:
		for handle_position in handles_positions:
			var mesh := SphereMesh.new()
			mesh.height = handles_3d_size
			mesh.radius = handles_3d_size / 2
			var material := get_material("handles_3d", gizmo)
			material.no_depth_test = true
			gizmo.add_mesh(mesh, material, Transform3D.IDENTITY.translated(handle_position))
	gizmo.add_handles(handles_positions, get_material("handles", gizmo), [])


func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> String:
	return _handle_infos[handle_id].name


func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> Variant:
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	if _original_area_transform == null:
		_original_area_transform = area.transform
	if _original_area_global_transform == null:
		_original_area_global_transform = area.global_transform
	if _original_area_size == null:
		_original_area_size = area.size
	return area.size


func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, 
		camera: Camera3D, screen_pos: Vector2) -> void:
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	var original_area_transform := _original_area_transform as Transform3D
	var original_area_global_transform := _original_area_global_transform as Transform3D
	var original_area_size := _original_area_size as Vector3
	var handle := _handle_infos[handle_id]
	var handle_position := area.global_transform * handle.get_position(area.box)
	var handle_normal := (area.global_transform.basis * handle.direction).normalized()
	var projected_cam := (camera.global_position - handle_position).project(handle_normal) + handle_position
	var to_cam_normal := projected_cam.direction_to(camera.global_position)
	var plane := Plane(to_cam_normal, handle_position)
	var ray_origin := camera.project_ray_origin(screen_pos)
	var ray_direction := camera.project_ray_normal(screen_pos)
	var hit_result := plane.intersects_ray(ray_origin, ray_direction)
	if hit_result == null:
		return
	var hit_position := hit_result as Vector3
	var projected_hit := (hit_position - handle_position).project(handle_normal) + handle_position
	
	var local_hit := original_area_global_transform.affine_inverse() * projected_hit
	var local_handle_normal := (area.transform.basis * handle.direction).normalized()
	
	var distance_sign := signf((projected_hit - original_area_global_transform.origin).dot(handle_normal))
	var delta_to_center := local_hit.length() * distance_sign
	
	if Input.is_physical_key_pressed(KEY_ALT):
		# growing in both sides
		area.global_position = original_area_global_transform.origin
		var new_area_size := delta_to_center * 2
		if Input.is_physical_key_pressed(KEY_CTRL):
			new_area_size = snappedf(new_area_size, 1)
		area.size[handle.axis_index] = maxf(new_area_size, MIN_AREA_SIZE)
		return
#
#	# growing in one side
	var new_area_size := delta_to_center + original_area_size[handle.axis_index] / 2
	if Input.is_physical_key_pressed(KEY_CTRL):
		new_area_size = snappedf(new_area_size, 1)
	new_area_size = maxf(new_area_size, MIN_AREA_SIZE)
	var grow_start := original_area_transform.origin - local_handle_normal * area.scale * original_area_size[handle.axis_index] / 2
	area.position = grow_start + local_handle_normal * area.scale * new_area_size / 2
	area.size[handle.axis_index] = new_area_size


func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, 
		restore, cancel: bool) -> void:
	_original_area_transform = null
	_original_area_global_transform = null
	_original_area_size = null


func _get_aabb_lines(aabb: AABB) -> PackedVector3Array:
	var result := PackedVector3Array()
	const TOP := [[2, 1], [0, 3]]
	const BOTTOM := [[6, 5], [4, 7]]
	for i in 2:
		for j in 2:
			# corner 1
			result.push_back(aabb.get_endpoint(TOP[0][i]))
			result.push_back(aabb.get_endpoint(TOP[1][j]))
			# corner 2
			result.push_back(aabb.get_endpoint(BOTTOM[0][i]))
			result.push_back(aabb.get_endpoint(BOTTOM[1][j]))
			# vertical line
			result.push_back(aabb.get_endpoint(TOP[i][j]))
			result.push_back(aabb.get_endpoint(BOTTOM[i][j]))
	return result


func _get_root(node: Node) -> RoommateRoot:
	var parent := node.get_parent()
	while not parent is RoommateRoot:
		parent = parent.get_parent()
		if not parent:
			return null
	return parent as RoommateRoot


class HandleInfo:
	extends RefCounted
	
	const AXIS_NAMES: Array[String] = ["X", "Y", "Z"]
	
	var direction := Vector3.ZERO
	var axis_index := 0
	var name: String:
		get:
			return "Axis Size %s" % AXIS_NAMES[axis_index]
	
	
	func _init(init_direction: Vector3) -> void:
		direction = init_direction
		if direction.x != 0:
			axis_index = 0
		elif direction.y != 0:
			axis_index = 1
		elif direction.z != 0:
			axis_index = 2
	
	
	func get_position(box: AABB) -> Vector3:
		return box.get_center() + box.size * direction * 0.5
