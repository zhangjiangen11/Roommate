# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateSpace
extends RoommateBlocksArea


func _process_block(new_block: RoommateBlock) -> RoommateBlock:
	new_block.type_id = "btid_space";
	var center_part := _create_part(Vector3(0.5, 0.5, 0.5), Vector3i.ZERO, Vector3.ZERO)
	center_part.mesh = null
	center_part.collision_mesh = null
	new_block.slots = {
		&"sid_center": center_part,
		&"sid_up": _create_part(Vector3(0.5, 1, 0.5), Vector3i.UP, Vector3.RIGHT * PI / 2),
		&"sid_down": _create_part(Vector3(0.5, 0, 0.5), Vector3i.DOWN, Vector3.LEFT * PI / 2),
		&"sid_left": _create_part(Vector3(0, 0.5, 0.5), Vector3i.LEFT, Vector3.UP * PI / 2),
		&"sid_right": _create_part(Vector3(1, 0.5, 0.5), Vector3i.RIGHT, Vector3.DOWN * PI / 2),
		&"sid_forward": _create_part(Vector3(0.5, 0.5, 0), Vector3i.FORWARD, Vector3.ZERO),
		&"sid_back": _create_part(Vector3(0.5, 0.5, 1), Vector3i.BACK, Vector3.UP * PI),
	}
	return new_block


func _create_part(anchor: Vector3, direction: Vector3, euler: Vector3) -> RoommatePart:
	var result := RoommatePart.new()
	result.anchor = anchor
	result.direction = direction
	result.transform.basis = Basis.from_euler(euler)
	result.collision_transform.basis = Basis.from_euler(euler)
	var default_mesh := QuadMesh.new()
	default_mesh.material = preload("../defaults/default_material.tres")
	result.mesh = default_mesh
	result.collision_mesh = default_mesh
	return result
