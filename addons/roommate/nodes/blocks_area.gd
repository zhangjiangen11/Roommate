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
## Base class for creating multiple [RoommateBlock] and applying styles over 
## occupied area.
##
## This node doesn't create blocks on it's own, but it still can be used to 
## apply style on certain area.

const SNAP_STEP := Vector3.ONE * 0.5

@export var size := Vector3.ONE:
	set(value):
		size = value
		update_gizmos()
@export var style: RoommateStyle
@export var apply_order := 0

var box: AABB:
	get:
		return AABB(-size / 2, size)
var _default_apply_order := 0


static func get_class_name() -> StringName:
	return &"RoommateBlocksArea"


func _ready():
	if not owner:
		apply_order = _default_apply_order
	set_notify_transform(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		update_gizmos()


func _property_can_revert(property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	if property == &"apply_order":
		return _default_apply_order
	return (RoommateBlocksArea as Script).get_property_default_value(property)


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
		new_block.type_id = RoommateBlock.NONE_TYPE
		new_block.position = block_position
		var processed_block := _process_block(new_block)
		if processed_block:
			result[block_position] = new_block
	return result


func get_blocks_range(root_transform: Transform3D, block_size: float) -> AABB:
	var start := Vector3.INF
	var end := -Vector3.INF
	for i in 8:
		var corner := root_transform.affine_inverse() * global_transform * box.get_endpoint(i)
		start = Vector3(minf(start.x, corner.x), minf(start.y, corner.y), minf(start.z, corner.z))
		end = Vector3(maxf(end.x, corner.x), maxf(end.y, corner.y), maxf(end.z, corner.z))
	var start_block_position := (start / block_size).snapped(SNAP_STEP).floor()
	var end_block_position := (end / block_size).snapped(SNAP_STEP).ceil()
	var range := AABB(start_block_position, Vector3.ZERO).expand(end_block_position)
	range.size.x = 1 if range.size.x == 0 and size.x != 0 else range.size.x
	range.size.y = 1 if range.size.y == 0 and size.y != 0 else range.size.y
	range.size.z = 1 if range.size.z == 0 and size.z != 0 else range.size.z
	return range


func _process_block(new_block: RoommateBlock) -> RoommateBlock: # virtual method
	return null
