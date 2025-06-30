# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBlock
extends RefCounted

const NODRAW_TYPE := &"btid_nodraw"
const SPACE_TYPE := &"btid_space"
const OBLIQUE_TYPE := &"btid_oblique"
const OUT_OF_BOUNDS_TYPE := &"btid_out_of_bounds"

const CEIL_SLOT := &"sid_ceil"
const FLOOR_SLOT := &"sid_floor"
const WALL_LEFT_SLOT := &"sid_wall_left"
const WALL_RIGHT_SLOT := &"sid_wall_right"
const WALL_FORWARD_SLOT := &"sid_wall_forward"
const WALL_BACK_SLOT := &"sid_wall_back"
const CENTER_SLOT := &"sid_center"

const OBLIQUE_SLOT := &"sid_oblique"
const OBLIQUE_SIDE_RIGHT_SLOT := &"sid_oblique_side_right"
const OBLIQUE_SIDE_LEFT_SLOT := &"sid_oblique_side_left"

var type_id: StringName
var position: Vector3i
var slots := {}
var center: Vector3:
	get: return (position as Vector3) + Vector3.ONE / 2


static func raycast(start: Vector3i, position_change: Vector3i, source_blocks: Dictionary) -> int:
	var result := 0
	var block := source_blocks.get(start + position_change) as RoommateBlock
	while block:
		result += 1
		block = source_blocks.get(block.position + position_change) as RoommateBlock
	return result
