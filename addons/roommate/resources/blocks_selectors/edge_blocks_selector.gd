# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateEdgeBlocksSelector
extends RoommateBlocksSelector

@export var selected_edge := Vector3i.ZERO


func select(source_blocks: RoommateBlocksArea.Blocks) -> RoommateBlocksArea.Blocks:
	var result := RoommateBlocksArea.Blocks.new()
	
	var biggest_values := Vector3i(-Vector3.INF)
	var smallest_values := Vector3i(Vector3.INF) - Vector3i.ONE
	for block in source_blocks.get_in_bounds():
		biggest_values = Vector3i(maxi(block.position.x, biggest_values.x),
				maxi(block.position.y, biggest_values.y), maxi(block.position.z, biggest_values.z))
		smallest_values = Vector3i(mini(block.position.x, smallest_values.x),
				mini(block.position.y, smallest_values.y), mini(block.position.z, smallest_values.z))
	
	var required_x = null
	var required_y = null
	var required_z = null
	
	if selected_edge.x > 0:
		required_x = biggest_values.x
	elif selected_edge.x < 0:
		required_x = smallest_values.x
	
	if selected_edge.y > 0:
		required_y = biggest_values.y
	elif selected_edge.y < 0:
		required_y = smallest_values.y
	
	if selected_edge.z > 0:
		required_z = biggest_values.z
	elif selected_edge.z < 0:
		required_z = smallest_values.z
	
	for block in source_blocks.get_all():
		if required_x != null and required_x != block.position.x:
			continue
		if required_y != null and required_y != block.position.y:
			continue
		if required_z != null and required_z != block.position.z:
			continue
		result.add(block)
	
	return result
