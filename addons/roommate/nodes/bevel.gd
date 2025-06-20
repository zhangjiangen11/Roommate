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
@export var add_out_of_bounds := true

var _bevel_infos := {
	ExtendAxis.X: {
		BevelRotation.A: BevelInfo.new(4, 0, Vector3.ZERO),
		BevelRotation.B: BevelInfo.new(6, 2, Vector3.ZERO),
		BevelRotation.C: BevelInfo.new(7, 3, Vector3.ZERO),
		BevelRotation.D: BevelInfo.new(5, 1, Vector3.ZERO),
	},
	ExtendAxis.Y: {
		BevelRotation.A: BevelInfo.new(6, 4, Vector3.ZERO),
		BevelRotation.B: BevelInfo.new(2, 0, Vector3.ZERO),
		BevelRotation.C: BevelInfo.new(3, 1, Vector3.ZERO),
		BevelRotation.D: BevelInfo.new(7, 5, Vector3.ZERO),
	},
	ExtendAxis.Z: {
		BevelRotation.A: BevelInfo.new(5, 4, Vector3.ZERO),
		BevelRotation.B: BevelInfo.new(7, 6, Vector3.ZERO),
		BevelRotation.C: BevelInfo.new(3, 2, Vector3.ZERO),
		BevelRotation.D: BevelInfo.new(1, 0, Vector3.ZERO),
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
	
	var info := _bevel_infos[extend_axis][bevel_rotation] as BevelInfo
	var plane := Plane(blocks_range.get_endpoint(info.first_endpoint) - HALF, 
			blocks_range.get_center() - HALF, 
			blocks_range.get_endpoint(info.second_endpoint) - HALF)
	
	var is_on_plane := plane.has_point(new_block.position, 0.5)
	var next_is_on_plane := plane.has_point((new_block.position as Vector3) + next_direction, 0.5)
	if not is_on_plane or next_is_on_plane:
		if add_out_of_bounds and plane.is_point_over(new_block.position):
			new_block.type_id = RoommateBlock.OUT_OF_BOUNDS_TYPE
			return new_block
		return null
	
	var ray_front := plane.intersects_ray(new_block.position, next_direction)
	var ray_back := plane.intersects_ray(new_block.position, -next_direction)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - (new_block.position as Vector3) + HALF
	
	var part_scale_delta := (used_size.length() - max_side_size) / max_side_size
	var part_transform := Transform3D.IDENTITY.looking_at(plane.normal, Vector3.FORWARD).scaled_local(Vector3.ONE + part_scale_delta * scale_axis)
	var bevel_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	new_block.type_id = RoommateBlock.BEVEL_TYPE;
	var slots := {}#_create_space_parts()
	slots[RoommateBlock.BEVEL_SLOT] = bevel_part
	new_block.slots = slots
	return new_block


class BevelInfo:
	extends RefCounted
	
	var first_endpoint := 0
	var second_endpoint := 0
	var flow := Vector3.ZERO
	
	
	func _init(init_first_endpoint: int, init_second_endpoint: int, init_flow: Vector3) -> void:
		first_endpoint = init_first_endpoint
		second_endpoint = init_second_endpoint
		flow = init_flow
