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

enum ExtendAxis {
	X = 0,
	Y = 1,
	Z = 2,
}
enum BevelRotation {
	A,
	B,
	C,
	D,
}

@export var extend_axis := ExtendAxis.X
@export var bevel_rotation := BevelRotation.A

var _endpoints := {
	ExtendAxis.X: {
		BevelRotation.A: [4, 0],
		BevelRotation.B: [6, 2],
		BevelRotation.C: [7, 3],
		BevelRotation.D: [5, 1],
	},
	ExtendAxis.Y: {
		BevelRotation.A: [6, 4],
		BevelRotation.B: [2, 0],
		BevelRotation.C: [3, 1],
		BevelRotation.D: [7, 5],
	},
	ExtendAxis.Z: {
		BevelRotation.A: [5, 4],
		BevelRotation.B: [7, 6],
		BevelRotation.C: [3, 2],
		BevelRotation.D: [1, 0],
	},
}


func _process_block(new_block: RoommateBlock, blocks_range: AABB) -> RoommateBlock:
	const HALF := Vector3.ONE / 2
	
	var scale_axis := Vector3.UP
	if extend_axis == ExtendAxis.Z:
		scale_axis = Vector3.RIGHT
	
	var used_size := blocks_range.size
	used_size[extend_axis] = 0
	
	var max_side_size := used_size[used_size.max_axis_index()]
	
	var next_direction := Vector3.ONE
	next_direction[extend_axis] = 0
	next_direction[used_size.max_axis_index()] = 0
	
	var next := Vector3.ZERO
	next[extend_axis] = 1
	
	var endpoints := _endpoints[extend_axis][bevel_rotation] as Array
	var plane := Plane(blocks_range.get_endpoint(endpoints[0]) - HALF, 
			blocks_range.get_center() - HALF, blocks_range.get_endpoint(endpoints[1]) - HALF)
	
	var is_on_plane := plane.has_point(new_block.position, 0.5)
	var next_is_on_plane := plane.has_point((new_block.position as Vector3) + next_direction, 0.5)
	if not is_on_plane or next_is_on_plane:
		return null
	
	var ray_front := plane.intersects_ray(new_block.position, next_direction)
	var ray_back := plane.intersects_ray(new_block.position, -next_direction)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - (new_block.position as Vector3) + HALF
	
	var a := Vector3.ONE
	a[extend_axis] = 0
	var bevel_length := (blocks_range.size * a).length()
	var part_scale_delta := (bevel_length - max_side_size) / max_side_size
	var part_transform := Transform3D.IDENTITY.looking_at(plane.normal, Vector3.FORWARD).scaled_local(Vector3.ONE + part_scale_delta * scale_axis)
	var bevel_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	new_block.type_id = RoommateBlock.BEVEL_TYPE;
	var slots := {}#_create_space_parts()
	slots[RoommateBlock.BEVEL_SLOT] = bevel_part
	new_block.slots = slots
	return new_block
