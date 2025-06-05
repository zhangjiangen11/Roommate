# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends EditorNode3DGizmoPlugin

const HANDLE_NAMES: Array[String] = [
	"Area Size Y",
	"Area Size Y",
	"Area Size X",
	"Area Size X",
	"Area Size Z",
	"Area Size Z",
]


func _init() -> void:
	create_material("area", Color.AQUA)
	create_material("blocks", Color.GREEN)
	create_handle_material("handles")


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RoommateBlocksArea


func _get_gizmo_name() -> String:
	return "Roommate"


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	var root := _get_root(area)
	var area_selected := area in EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()
	
	# area
	var area_box := AABB(-area.area_size / 2, area.area_size)
	gizmo.add_lines(_get_aabb_lines(area_box), get_material("area", gizmo), false)
	
	# blocks range
	if root:
		var blocks_box := area.get_blocks_range(root.global_transform, root.block_size)
		blocks_box.size *= root.block_size
		blocks_box.position *= root.block_size
		var blocks_box_lines := area.global_transform.affine_inverse() * (root.global_transform * _get_aabb_lines(blocks_box))
		gizmo.add_lines(blocks_box_lines, get_material("blocks", gizmo), false)
	
	if not area_selected:
		return
	
	# handles
	var handles := [
		area_box.get_center() + area_box.size * Vector3.UP * 0.5,
		area_box.get_center() + area_box.size * Vector3.DOWN * 0.5,
		area_box.get_center() + area_box.size * Vector3.LEFT * 0.5,
		area_box.get_center() + area_box.size * Vector3.RIGHT * 0.5,
		area_box.get_center() + area_box.size * Vector3.FORWARD * 0.5,
		area_box.get_center() + area_box.size * Vector3.BACK * 0.5,
	]
	gizmo.add_handles(handles, get_material("handles", gizmo), [])


func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> String:
	return HANDLE_NAMES[handle_id]


func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> Variant:
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	return area.area_size


func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, 
		camera: Camera3D, screen_pos: Vector2) -> void:
	var area := gizmo.get_node_3d() as RoommateBlocksArea
	var plane := Plane()
	match handle_id:
		0, 1:
			plane = area.global_transform * Plane.PLANE_XY
		2, 3:
			plane = area.global_transform * Plane.PLANE_XZ
		4, 5:
			plane = area.global_transform * Plane.PLANE_XZ
	
	var ray_from := camera.project_ray_origin(screen_pos)
	var ray_direction := camera.project_ray_normal(screen_pos)
	
	var hit_result := plane.intersects_ray(ray_from, ray_direction)
	if hit_result == null:
		return
	var relative_hit := (hit_result as Vector3) - area.global_position
	var new_size := area.area_size
	new_size.z = relative_hit.z
	area.area_size = new_size


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
