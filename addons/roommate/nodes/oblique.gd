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

@export var extend_axis := ExtendAxis.X:
	set(value):
		extend_axis = value
		update_gizmos()
@export var oblique_part_rotated := false:
	set(value):
		oblique_part_rotated = value
		update_gizmos()
@export var oblique_part_flipped := false:
	set(value):
		oblique_part_flipped = value
		update_gizmos()
@export var nodraw_start := -1.0


func _process_block(new_block: RoommateBlock, blocks_range: AABB) -> RoommateBlock:
	new_block.type_id = RoommateBlock.OBLIQUE_TYPE
	
	var used_size := blocks_range.size
	used_size[extend_axis] = 0
	
	var max_side_size := used_size[used_size.max_axis_index()]
	
	var next_direction := Vector3.ONE
	next_direction[extend_axis] = 0
	next_direction[used_size.max_axis_index()] = 0
	
	var plane := get_oblique_plane(blocks_range)
	var ray_front := plane.intersects_ray(new_block.center, next_direction)
	var ray_back := plane.intersects_ray(new_block.center, -next_direction)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - new_block.center + Vector3.ONE / 2
	
	if not anchor.clamp(Vector3.ZERO, Vector3.ONE).is_equal_approx(anchor):
		var plane_distance := plane.distance_to(new_block.center)
		if plane_distance < 0 and absf(plane_distance) > nodraw_start and nodraw_start >= 0:
			new_block.type_id = RoommateBlock.NODRAW_TYPE
			return new_block
		new_block.type_id = RoommateBlock.SPACE_TYPE
		new_block.slots = _create_space_parts()
		return new_block
	
	var part_scale_delta := (used_size.length() - max_side_size) / max_side_size
	var part_transform := Transform3D.IDENTITY.looking_at(-plane.normal, next_direction).scaled_local(Vector3(1, 1 + part_scale_delta, 1))
	var oblique_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	var slots := _create_space_parts()
	slots[RoommateBlock.OBLIQUE_SLOT] = oblique_part
	new_block.slots = slots
	return new_block


func get_oblique_plane(blocks_range: AABB) -> Plane:
	var used_size := blocks_range.size
	used_size[extend_axis] = 0
	
	var extend_axis_vector := Vector3.ZERO
	extend_axis_vector[extend_axis] = 1
	var plane_normal := used_size.normalized().rotated(extend_axis_vector, PI / 2)
	if extend_axis != ExtendAxis.Z:
		# top of oblique should be visible by default
		plane_normal = -plane_normal
	if oblique_part_rotated:
		var part_rotation_axis := Vector3.ZERO
		part_rotation_axis[extend_axis_vector.min_axis_index()] = 1
		plane_normal = plane_normal.rotated(part_rotation_axis, PI)
	if oblique_part_flipped:
		plane_normal = -plane_normal
	return Plane(plane_normal, blocks_range.get_center())
