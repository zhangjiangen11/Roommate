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

@export_enum("X:0", "Y:1", "Z:2") var extend_axis := 0:
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

@export var fill_start_distance := -1.0
@export_enum("Nodraw", "Out Of Bounds") var fill_block_type := "Nodraw":
	set(value):
		const BLOCK_MAP := {
			"Nodraw": RoommateBlock.NODRAW_TYPE,
			"Out Of Bounds": RoommateBlock.OUT_OF_BOUNDS_TYPE,
		}
		fill_block_type = value
		_fill_block_type_id = BLOCK_MAP[value]

var _fill_block_type_id := RoommateBlock.NODRAW_TYPE


func _process_block(new_block: RoommateBlock, blocks_range: AABB) -> RoommateBlock:
	new_block.type_id = RoommateBlock.OBLIQUE_TYPE
	
	var used_size := blocks_range.size
	used_size[extend_axis] = 0
	
	var max_side_size := used_size[used_size.max_axis_index()]
	
	var up_axis := Vector3.ONE
	up_axis[extend_axis] = 0
	up_axis[used_size.max_axis_index()] = 0
	var forward_axis := Vector3.ONE
	forward_axis[extend_axis] = 0
	forward_axis[up_axis.max_axis_index()] = 0
	
	var plane := get_oblique_plane(blocks_range)
	var ray_front := plane.intersects_ray(new_block.center, up_axis)
	var ray_back := plane.intersects_ray(new_block.center, -up_axis)
	var intersection := ray_front as Vector3 if ray_front else ray_back as Vector3
	var anchor := intersection - new_block.center + Vector3.ONE / 2
	
	if not anchor.clamp(Vector3.ZERO, Vector3.ONE).is_equal_approx(anchor):
		var plane_distance := plane.distance_to(new_block.center)
		if plane_distance < 0 and absf(plane_distance) > fill_start_distance and fill_start_distance >= 0:
			new_block.type_id = _fill_block_type_id
			return new_block
		new_block.type_id = RoommateBlock.SPACE_TYPE
		new_block.slots = _create_space_parts()
		return new_block
	
	var part_scale := (used_size.length() - max_side_size) / max_side_size + 1
	var part_transform := Transform3D.IDENTITY.looking_at(-plane.normal, up_axis).scaled_local(Vector3(1, part_scale, 1))
	var oblique_part := _create_default_part(anchor, Vector3.ZERO, part_transform)
	
	var slots := _create_space_parts()
	slots[RoommateBlock.Slot.OBLIQUE] = oblique_part
	
	new_block.slots = slots
	return new_block


func get_oblique_plane(blocks_range: AABB) -> Plane:
	var used_size := blocks_range.size
	used_size[extend_axis] = 0
	
	var extend_axis_vector := Vector3.ZERO
	extend_axis_vector[extend_axis] = 1
	var plane_normal := used_size.normalized().rotated(extend_axis_vector, PI / 2)
	if extend_axis != Vector3.AXIS_Z:
		# top of oblique should be visible by default
		plane_normal = -plane_normal
	if oblique_part_rotated:
		var part_rotation_axis := Vector3.ZERO
		part_rotation_axis[extend_axis_vector.min_axis_index()] = 1
		plane_normal = plane_normal.rotated(part_rotation_axis, PI)
	if oblique_part_flipped:
		plane_normal = -plane_normal
	return Plane(plane_normal, blocks_range.get_center())


func _create_oblique_side(anchor: Vector3, flow: Vector3, part_transform: Transform3D) -> RoommatePart:
	var result := _create_default_part(anchor, flow, part_transform)
	var default_mesh := preload("../defaults/oblique_side_model.tres")
	default_mesh.surface_set_material(0, preload("../defaults/default_material.tres"))
	result.mesh = default_mesh
	result.collision_mesh = default_mesh
	return result
