# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateAllSpacePartsSetter
extends RoommatePartsSetter

@export var setter: RoommatePart
@export var exclude_center := true


func set_all(source_parts: Array[RoommatePart]) -> void:
	for part in source_parts:
		var space_part := part as RoommateSpacePart
		if not space_part:
			continue
		if exclude_center and space_part.part_position == Vector3i.ZERO:
			continue
		space_part.set_values(setter)


func get_materials() -> Array[Material]:
	if setter and setter.material:
		return [setter.material]
	return []
