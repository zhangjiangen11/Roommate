# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBevel
extends RoommateBlocksArea
## Area that represents sloped surface


func _process_block(new_block: RoommateBlock, blocks_range: AABB) -> RoommateBlock:
	const HALF := Vector3.ONE / 2
	
	var ignored_axis_index := 0
	var used_size := blocks_range.size
	used_size[ignored_axis_index] = 0
	
	var max_side_size := used_size[used_size.max_axis_index()]
	
	var next_direction := Vector3.ONE
	next_direction[ignored_axis_index] = 0
	next_direction[used_size.max_axis_index()] = 0
	
	var next := Vector3.ZERO
	next[ignored_axis_index] = 1
	var plane := Plane(blocks_range.position - HALF, blocks_range.end - HALF, 
			blocks_range.position + next - HALF)
	
	var is_on_plane := plane.has_point(new_block.position, 0.5)
	var next_is_on_plane := plane.has_point((new_block.position as Vector3) + next_direction, 0.5)
	if not is_on_plane or next_is_on_plane:
		return null
	
	var ray_front := plane.intersects_ray(new_block.position, next_direction)
	var ray_back := plane.intersects_ray(new_block.position, -next_direction)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - (new_block.position as Vector3) + HALF
	
	var a := Vector3.ONE
	a[ignored_axis_index] = 0
	var bevel_length := (blocks_range.size * a).length()
	var part_scale := (bevel_length - max_side_size) / max_side_size + 1
	var part_transform := Transform3D.IDENTITY.looking_at(plane.normal, Vector3.FORWARD).scaled_local(Vector3(1, part_scale, 1))
	var bevel_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	new_block.type_id = RoommateBlock.BEVEL_TYPE;
	var slots := {}#_create_space_parts()
	slots[RoommateBlock.BEVEL_SLOT] = bevel_part
	new_block.slots = slots
	return new_block
