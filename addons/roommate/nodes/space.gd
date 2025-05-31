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


func _process_block(new_block: RoommateBlock) -> void:
	new_block.block_type_id = "btid_space";
	var center_part := _create_part(Vector3(0.5, 0.5, 0.5), Vector3.ZERO)
	center_part.mesh = null
	center_part.collision_mesh = null
	new_block.slots = {
		&"sid_center": center_part,
		&"sid_up": _create_part(Vector3(0.5, 1, 0.5), Vector3.RIGHT * PI / 2),
		&"sid_down": _create_part(Vector3(0.5, 0, 0.5), Vector3.LEFT * PI / 2),
		&"sid_left": _create_part(Vector3(0, 0.5, 0.5), Vector3.UP * PI / 2),
		&"sid_right": _create_part(Vector3(1, 0.5, 0.5), Vector3.DOWN * PI / 2),
		&"sid_forward": _create_part(Vector3(0.5, 0.5, 0), Vector3.ZERO),
		&"sid_back": _create_part(Vector3(0.5, 0.5, 1), Vector3.UP * PI),
	}


func _create_part(anchor: Vector3, euler: Vector3) -> RoommatePart:
	var result := RoommatePart.new()
	result.anchor = anchor
	result.rotation = euler
	result.collision_rotation = euler
	var default_mesh := QuadMesh.new()
	default_mesh.material = preload("../defaults/default_material.tres")
	result.mesh = default_mesh
	result.collision_mesh = default_mesh
	return result
