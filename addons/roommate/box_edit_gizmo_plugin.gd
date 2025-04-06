# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name BoxEditGizmoPlugin
extends EditorNode3DGizmoPlugin


func _init() -> void:
	create_material("main", Color.AQUA)


func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is RoommateBlocksArea


func _get_gizmo_name() -> String:
	return "Roommate"


func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var space = gizmo.get_node_3d() as RoommateBlocksArea
	var lines = PackedVector3Array()
	var box := AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	for i in 8:
		for j in 8:
			var vertex_1 := box.get_endpoint(i)
			var vertex_2 := box.get_endpoint(j)
			if vertex_1.distance_squared_to(vertex_2) != 4:
				continue
			lines.push_back(vertex_1 * space.area_size / 2)
			lines.push_back(vertex_2 * space.area_size / 2)
	
	gizmo.add_lines(lines, get_material("main", gizmo), false)
