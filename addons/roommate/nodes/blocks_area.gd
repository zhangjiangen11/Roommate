# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBlocksArea
extends Node3D

@export var area_size := Vector3.ONE:
	set(value):
		area_size = value
		update_gizmos()
@export var style: RoommateStyle


func get_block_positions(root_transform: Transform3D, block_size: float) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var range := get_blocks_range(root_transform, block_size)
	for x in range(range.position.x, range.end.x):
		for y in range(range.position.y, range.end.y):
			for z in range(range.position.z, range.end.z):
				result.append(Vector3i(x, y, z))
	return result


func create_blocks(root_transform: Transform3D, block_size: float) -> Dictionary:
	var result := {}
	for block_position in get_block_positions(root_transform, block_size):
		var new_block := RoommateBlock.new()
		new_block.block_type_id = "btid_none"
		new_block.block_position = block_position
		_process_block(new_block)
		result[block_position] = new_block
	return result


func get_blocks_range(root_transform: Transform3D, block_size: float) -> AABB:
	var box := AABB(-area_size / 2, area_size)
	var start := Vector3.INF
	var end := -Vector3.INF
	for i in 8:
		var corner := root_transform.affine_inverse() * global_transform * box.get_endpoint(i)
		start = Vector3(minf(start.x, corner.x), minf(start.y, corner.y), minf(start.z, corner.z))
		end = Vector3(maxf(end.x, corner.x), maxf(end.y, corner.y), maxf(end.z, corner.z))
	# no floor or ceil because of rounding error
	var start_block_position := (start / block_size).round()
	var end_block_position := (end / block_size).round()
	var range := AABB(start_block_position, Vector3.ZERO).expand(end_block_position)
	range.size.x = 1 if range.size.x == 0 and area_size.x != 0 else range.size.x
	range.size.y = 1 if range.size.y == 0 and area_size.y != 0 else range.size.y
	range.size.z = 1 if range.size.z == 0 and area_size.z != 0 else range.size.z
	return range


func _process_block(new_block: RoommateBlock) -> void: # virtual method
	push_error("Not Implemented")
