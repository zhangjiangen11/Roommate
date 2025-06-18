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

const NONE_TYPE := &"btid_none"
const SPACE_TYPE := &"btid_space"

const CEIL := &"sid_up"
const FLOOR := &"sid_down"
const WALL_LEFT := &"sid_left"
const WALL_RIGHT := &"sid_right"
const WALL_FORWARD := &"sid_forward"
const WALL_BACK := &"sid_back"
const CENTER := &"sid_center"

var type_id: StringName
var position: Vector3i
var slots := {}


static func raycast(start: Vector3i, position_change: Vector3i, source_blocks: Dictionary) -> int:
	var result := 0
	var block := source_blocks.get(start + position_change) as RoommateBlock
	while block:
		result += 1
		block = source_blocks.get(block.position + position_change) as RoommateBlock
	return result
