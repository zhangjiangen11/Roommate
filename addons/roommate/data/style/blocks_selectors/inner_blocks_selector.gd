# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends "./blocks_selector.gd"

var segments: Array[RoommateSegment] = []


func _init(init_segments: Array[RoommateSegment]) -> void:
	segments = init_segments


func _block_is_selected(offset_position: Vector3i, block: RoommateBlock, 
		source_blocks: Dictionary) -> bool:
	if not source_blocks.has(offset_position):
		return false
	for segment in segments:
		var forward_count := RoommateBlock.raycast(offset_position, segment.step, source_blocks)
		var back_count := RoommateBlock.raycast(offset_position, -segment.step, source_blocks)
		if absi(forward_count - back_count) > segment.max_steps:
			return false
	return true
