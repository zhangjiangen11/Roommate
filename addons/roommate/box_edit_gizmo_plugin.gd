# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends EditorNode3DGizmoPlugin


func _init() -> void:
	create_material("area", Color.AQUA)
	create_material("blocks", Color.GREEN)


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RoommateBlocksArea


func _get_gizmo_name() -> String:
	return "Roommate"


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var area = gizmo.get_node_3d() as RoommateBlocksArea
	var area_box := AABB(-area.area_size / 2, area.area_size)
	gizmo.add_lines(_get_aabb_lines(area_box), get_material("area", gizmo), false)
	
	var selected_nodes := EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()
	if area in selected_nodes:
		var block_size := _get_block_size(area)
		var blocks_box := RoommateBlocksArea.get_blocks_range(area.global_transform, area.area_size, block_size)
		blocks_box.size *= block_size
		blocks_box.position = blocks_box.position * block_size - area.position
		gizmo.add_lines(_get_aabb_lines(blocks_box), get_material("blocks", gizmo), false)


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


func _get_block_size(node: Node) -> float:
	var parent := node.get_parent()
	while not parent is RoommateRoot:
		parent = parent.get_parent()
		if not parent:
			return 0
	return (parent as RoommateRoot).block_size
