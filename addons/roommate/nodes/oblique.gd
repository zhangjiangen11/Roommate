# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateOblique
extends RoommateBlocksArea
## Area that represents sloped surface

enum ExtendAxis {
	X = 0,
	Y = 1,
	Z = 2,
}
enum ObliqueAxisDirection {
	AllPositive,
	AllNegative,
	Mixed,
	InverseMixed,
}

@export var extend_axis := ExtendAxis.X
@export var oblique_axis_direction := ObliqueAxisDirection.AllPositive

var _oblique_infos := {
	ExtendAxis.X: {
		ObliqueAxisDirection.AllPositive: ObliqueInfo.new(6, 2, Vector3.ZERO),
		ObliqueAxisDirection.AllNegative: ObliqueInfo.new(5, 1, Vector3.ZERO),
		ObliqueAxisDirection.Mixed: ObliqueInfo.new(4, 0, Vector3.ZERO),
		ObliqueAxisDirection.InverseMixed: ObliqueInfo.new(7, 3, Vector3.ZERO),
	},
	ExtendAxis.Y: {
		ObliqueAxisDirection.AllPositive: ObliqueInfo.new(3, 1, Vector3.ZERO),
		ObliqueAxisDirection.AllNegative: ObliqueInfo.new(6, 4, Vector3.ZERO),
		ObliqueAxisDirection.Mixed: ObliqueInfo.new(7, 5, Vector3.ZERO),
		ObliqueAxisDirection.InverseMixed: ObliqueInfo.new(2, 0, Vector3.ZERO),
	},
	ExtendAxis.Z: {
		ObliqueAxisDirection.AllPositive: ObliqueInfo.new(5, 4, Vector3.ZERO),
		ObliqueAxisDirection.AllNegative: ObliqueInfo.new(3, 2, Vector3.ZERO),
		ObliqueAxisDirection.Mixed: ObliqueInfo.new(1, 0, Vector3.ZERO),
		ObliqueAxisDirection.InverseMixed: ObliqueInfo.new(7, 6, Vector3.ZERO),
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
	
	var plane := Plane(get_first_endpoint(blocks_range) - HALF, 
			blocks_range.get_center() - HALF, 
			get_second_endpoint(blocks_range) - HALF)
	
	var ray_front := plane.intersects_ray(new_block.position, next_direction)
	var ray_back := plane.intersects_ray(new_block.position, -next_direction)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - (new_block.position as Vector3) + HALF
	
	var anchor_over_max := anchor.x > 1 or anchor.y > 1 or anchor.z > 1
	var anchor_below_min := anchor.x < 0 or anchor.y < 0 or anchor.z < 0
	if anchor_over_max or anchor_below_min:
		new_block.type_id = RoommateBlock.SPACE_TYPE
		new_block.slots = _create_space_parts()
		return new_block
	
	var part_scale_delta := (used_size.length() - max_side_size) / max_side_size
	var part_transform := Transform3D.IDENTITY.looking_at(-plane.normal, Vector3.FORWARD).scaled_local(Vector3.ONE + part_scale_delta * scale_axis)
	var oblique_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	new_block.type_id = RoommateBlock.OBLIQUE_TYPE;
	var slots := _create_space_parts()
	slots[RoommateBlock.OBLIQUE_SLOT] = oblique_part
	new_block.slots = slots
	return new_block


func get_first_endpoint(box: AABB) -> Vector3:
	var info := _oblique_infos[extend_axis][oblique_axis_direction] as ObliqueInfo
	return box.get_endpoint(info.first_endpoint)


func get_second_endpoint(box: AABB) -> Vector3:
	var info := _oblique_infos[extend_axis][oblique_axis_direction] as ObliqueInfo
	return box.get_endpoint(info.second_endpoint)


class ObliqueInfo:
	extends RefCounted
	
	var first_endpoint := 0
	var second_endpoint := 0
	var flow := Vector3.ZERO
	
	
	func _init(init_first_endpoint: int, init_second_endpoint: int, init_flow: Vector3) -> void:
		first_endpoint = init_first_endpoint
		second_endpoint = init_second_endpoint
		flow = init_flow
