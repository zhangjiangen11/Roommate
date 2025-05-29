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

@export var area_size := Vector3.ONE
@export var style: RoommateStyle


func get_block_positions(block_size: float) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var start_space_position := position - area_size / 2
	var box := AABB(start_space_position, area_size)
	var start_block_position := (box.position / block_size).floor() as Vector3i
	var end_block_position := (box.end / block_size).ceil() as Vector3i
	for x in range(start_block_position.x, end_block_position.x):
		for y in range(start_block_position.y, end_block_position.y):
			for z in range(start_block_position.z, end_block_position.z):
				result.append(Vector3i(x, y, z))
	return result


func create_blocks(block_size: float) -> Dictionary:
	var result := {}
	for block_position in get_block_positions(block_size):
		var new_block := RoommateBlock.new()
		new_block.block_type_id = "btid_none"
		new_block.block_position = block_position
		_process_block(new_block)
		result[block_position] = new_block
	return result


func _process_block(new_block: RoommateBlock) -> void: # virtual method
	push_error("Not Implemented")
