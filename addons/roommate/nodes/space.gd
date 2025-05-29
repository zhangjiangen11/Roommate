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

const PART_DEFINITIONS := {
	Vector3i.ZERO: Quaternion.IDENTITY,
	Vector3i.UP: Quaternion(Vector3.RIGHT, PI / 2),
	Vector3i.DOWN: Quaternion(Vector3.LEFT, PI / 2),
	Vector3i.LEFT: Quaternion(Vector3.UP, PI / 2),
	Vector3i.RIGHT: Quaternion(Vector3.DOWN, PI / 2),
	Vector3i.FORWARD: Quaternion.IDENTITY,
	Vector3i.BACK: Quaternion(Vector3.UP, PI),
}


func _process_block(new_block: RoommateBlock) -> void:
	new_block.block_type_id = "btid_space";
	new_block.slots = {
		"sid_center": _create_part(Vector3i.ZERO),
		"sid_up": _create_part(Vector3i.ZERO),
		"sid_down": _create_part(Vector3i.ZERO),
		"sid_left": _create_part(Vector3i.ZERO),
		"sid_right": _create_part(Vector3i.ZERO),
		"sid_forward": _create_part(Vector3i.ZERO),
		"sid_back": _create_part(Vector3i.ZERO),
	}


func _create_part(anchor: Vector3i) -> RoommatePart:
	var result := RoommatePart.new()
	
	result.anchor = anchor
	result.mesh = QuadMesh.new()
	result.material = preload("../defaults/default_material.tres")
	return result
